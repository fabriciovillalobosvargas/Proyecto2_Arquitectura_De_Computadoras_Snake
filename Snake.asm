# ==========================================
# Universidad Nacional (UNA)
# Escuela de Informatica 
# Proyecto 2 - Arquitectura de Computadoras EIF-205
# Fabricio Villalobos Vargas y Jose Navarrete Oviedo
# Juego Snake - MARS MIPS}
# 11 de noviembre del 2026
# ==========================================


.data

mensaje:      .asciiz "SNAKE - ETAPA 5\n"
controles:    .asciiz "Controles: W A S D (Keyboard MMIO)\n"
msg_puntos:   .asciiz "Puntuacion: "
msg_fin:      .asciiz "\nGAME OVER! Colision detectada.\n"
msg_victoria: .asciiz "\nVICTORIA! Tablero completado.\n"
salto:        .asciiz "\n"

.align 2

# Arreglos para las posiciones de la serpiente
# 900 posiciones posibles (30 x 30 interiores)
snake_x: .space 3600
snake_y: .space 3600

longitud:   .word 3
direccion:  .word 0

# Coordenadas de comida
comida_x: .word 0
comida_y: .word 0

# Puntuacion
puntos: .word 0


# Record maximo de la sesion
record: .word 0
msg_record: .asciiz "High Score: "

# Estado del juego:
# 0 = menu
# 1 = jugando
# 2 = pausa
# 3 = game over
# 4 = victoria
 .align 2
estado: .word 0

# Mensajes de la interfaz
msg_menu: .asciiz "\n===== SNAKE MIPS =====\n1 - Iniciar partida\nQ - Salir\n"
msg_pausa: .asciiz "\nPAUSA - P: continuar | R: reiniciar | M: menu | Q: salir\n"
msg_volver: .asciiz "Continuando partida...\n"
msg_opciones: .asciiz "R: reiniciar | M: menu | Q: salir\n"
msg_inicio: .asciiz "\nNueva partida! Usa W A S D para moverte y P para pausar.\n"


.align 2
color_cabeza: .word 0x00CCFF00
color_cuerpo: .word 0x00008800
color_comida: .word 0x00FF0000


# ==============================================
# OBSTACULOS DEL JUEGO - ETAPA 6
# Cada par representa una posicion (X,Y)
# ==============================================

.align 2

cantidad_obstaculos: .word 12

obstaculos: .word 8,8, 9,8, 10,8
            .word 22,8, 22,9, 22,10
            .word 8,22, 9,22, 10,22
            .word 22,22, 22,23, 22,24

color_obstaculo: .word 0x00AAAAAA

.text
.globl main


# PROGRAMA PRINCIPAL - ETAPA 5
# ==============================================

main:
menu_principal:
    sw $zero, estado

    # Mostrar menu
    li $v0, 4
    la $a0, msg_menu
    syscall

    jal mostrar_record

esperar_menu:
    jal leer_tecla

    # Tecla 1 = iniciar
    li $t0, 49
    beq $v0, $t0, iniciar_partida

    # Tecla Q = salir
    li $t0, 113
    beq $v0, $t0, salir_juego

    j esperar_menu


# ==============================================
# INICIAR PARTIDA
# ==============================================

iniciar_partida:

    li $t0, 1
    sw $t0, estado

    # Reiniciar serpiente y puntuacion
    jal iniciar_serpiente

  # Limpiar y dibujar tablero
    jal dibujar_tablero

    # Dibujar los obstaculos
    jal dibujar_obstaculos

    # Generar primera comida
    jal generar_comida

    # Dibujar serpiente
    jal dibujar_serpiente

    li $v0, 4
    la $a0, msg_inicio
    syscall


# ==============================================
# CICLO PRINCIPAL DEL JUEGO
# ==============================================

ciclo_juego:

    # Leer una tecla disponible
    jal leer_tecla

    # P = pausa
    li $t0, 112
    beq $v0, $t0, abrir_pausa

    # Procesar controles W A S D
    move $a0, $v0
    jal procesar_direccion

    # Actualizar serpiente
    jal mover_serpiente

    # v0 = 1: colision
    li $t0, 1
    beq $v0, $t0, game_over

    # v0 = 3: victoria
    li $t0, 3
    beq $v0, $t0, victoria

    # v0 = 2: comio
    li $t0, 2
    bne $v0, $t0, dibujar_nueva_posicion

    # Actualizar record
    jal actualizar_record

    # Mostrar puntuacion y record
    jal mostrar_puntos
    jal mostrar_record

    # Generar siguiente comida
    jal generar_comida

dibujar_nueva_posicion:

    jal dibujar_serpiente

    # Esperar entre movimientos
    li $v0, 32
    li $a0, 180
    syscall

    j ciclo_juego


# ==============================================
# ESTADO DE PAUSA
# ==============================================

abrir_pausa:

    li $t0, 2
    sw $t0, estado

    li $v0, 4
    la $a0, msg_pausa
    syscall

esperar_pausa:

    jal leer_tecla

    # P = reanudar
    li $t0, 112
    beq $v0, $t0, reanudar_juego

    # R = reiniciar
    li $t0, 114
    beq $v0, $t0, iniciar_partida

    # M = menu
    li $t0, 109
    beq $v0, $t0, menu_principal

    # Q = salir
    li $t0, 113
    beq $v0, $t0, salir_juego

    j esperar_pausa

reanudar_juego:

    li $t0, 1
    sw $t0, estado

    li $v0, 4
    la $a0, msg_volver
    syscall

    j ciclo_juego


# ==============================================
# GAME OVER
# ==============================================

game_over:

    li $t0, 3
    sw $t0, estado

    jal actualizar_record

    li $v0, 4
    la $a0, msg_fin
    syscall

    j mostrar_resultado


# ==============================================
# VICTORIA
# ==============================================

victoria:

    li $t0, 4
    sw $t0, estado

    jal actualizar_record

    li $v0, 4
    la $a0, msg_victoria
    syscall


# ==============================================
# RESULTADO Y REINICIO
# ==============================================

mostrar_resultado:

    jal mostrar_puntos
    jal mostrar_record

    li $v0, 4
    la $a0, msg_opciones
    syscall

esperar_resultado:

    jal leer_tecla

    # R = reiniciar
    li $t0, 114
    beq $v0, $t0, iniciar_partida

    # M = menu
    li $t0, 109
    beq $v0, $t0, menu_principal

    # Q = salir
    li $t0, 113
    beq $v0, $t0, salir_juego

    j esperar_resultado


# ==============================================
# SALIR DEL PROGRAMA
# ==============================================

salir_juego:

    li $v0, 10
    syscall


# INICIALIZAR SERPIENTE

iniciar_serpiente:

    la $t0, snake_x
    la $t1, snake_y

    li $t2, 16
    sw $t2, 0($t0)

    li $t2, 15
    sw $t2, 0($t1)

    li $t2, 15
    sw $t2, 4($t0)
    sw $t2, 4($t1)

    li $t2, 14
    sw $t2, 8($t0)

    li $t2, 15
    sw $t2, 8($t1)

    li $t2, 3
    sw $t2, longitud

    sw $zero, direccion
    sw $zero, puntos

    jr $ra


# PINTAR CELDA

pintar_celda:

    sll $t0, $a1, 5
    addu $t0, $t0, $a0
    sll $t0, $t0, 2

    li $t1, 0x10008000
    addu $t1, $t1, $t0

    sw $a2, 0($t1)

    jr $ra


# DIBUJAR TABLERO 32 x 32

dibujar_tablero:

    addiu $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $s2, 0($sp)

    li $s0, 0

fila:
    bge $s0, 32, fin_tablero

    li $s1, 0

columna:
    bge $s1, 32, siguiente_fila

    li $s2, 0x00000000

    beq $s0, $zero, borde
    beq $s1, $zero, borde

    li $t0, 31
    beq $s0, $t0, borde
    beq $s1, $t0, borde

    j pintar_fondo

borde:
    li $s2, 0x0000FF00

pintar_fondo:
    move $a0, $s1
    move $a1, $s0
    move $a2, $s2

    jal pintar_celda

    addiu $s1, $s1, 1
    j columna

siguiente_fila:
    addiu $s0, $s0, 1
    j fila

fin_tablero:
    lw $s2, 0($sp)
    lw $s1, 4($sp)
    lw $s0, 8($sp)
    lw $ra, 12($sp)
    addiu $sp, $sp, 16

    jr $ra



# DIBUJAR SERPIENTE

dibujar_serpiente:

    addiu $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)
    sw $s4, 0($sp)

    la $s0, snake_x
    la $s1, snake_y

    lw $s2, longitud

    li $s3, 0

ciclo_serpiente:
    bge $s3, $s2, fin_serpiente

    sll $t0, $s3, 2

    addu $t1, $s0, $t0
    lw $a0, 0($t1)

    addu $t1, $s1, $t0
    lw $a1, 0($t1)

    beq $s3, $zero, color_de_cabeza

    lw $a2, color_cuerpo
    j dibujar_segmento

color_de_cabeza:
    lw $a2, color_cabeza

dibujar_segmento:
    jal pintar_celda

    addiu $s3, $s3, 1
    j ciclo_serpiente

fin_serpiente:
    lw $s4, 0($sp)
    lw $s3, 4($sp)
    lw $s2, 8($sp)
    lw $s1, 12($sp)
    lw $s0, 16($sp)
    lw $ra, 20($sp)
    addiu $sp, $sp, 24

    jr $ra



# LEER UNA TECLA DESDE MMIO
# Devuelve en v0 el codigo ASCII
# Devuelve 0 si no hay tecla
# ==============================================

leer_tecla:

    li $t0, 0xFFFF0000

    # Verificar si hay una tecla disponible
    lw $t1, 0($t0)
    andi $t1, $t1, 1

    beq $t1, $zero, sin_tecla

    # Obtener el caracter
    lw $v0, 4($t0)

    # Convertir mayusculas a minusculas
    li $t2, 65
    blt $v0, $t2, fin_lectura

    li $t2, 90
    bgt $v0, $t2, fin_lectura

    addiu $v0, $v0, 32

fin_lectura:
    jr $ra

sin_tecla:
    move $v0, $zero
    jr $ra


# ==============================================
# PROCESAR DIRECCION
# a0 = tecla recibida
# ==============================================

procesar_direccion:

    move $t2, $a0

    # W = arriba
    li $t3, 119
    beq $t2, $t3, tecla_w

    # S = abajo
    li $t3, 115
    beq $t2, $t3, tecla_s

    # A = izquierda
    li $t3, 97
    beq $t2, $t3, tecla_a

    # D = derecha
    li $t3, 100
    beq $t2, $t3, tecla_d

    j fin_direccion

tecla_w:
    # No cambiar de abajo a arriba
    lw $t4, direccion
    li $t5, 1
    beq $t4, $t5, fin_direccion

    li $t4, 3
    sw $t4, direccion
    j fin_direccion

tecla_s:
    # No cambiar de arriba a abajo
    lw $t4, direccion
    li $t5, 3
    beq $t4, $t5, fin_direccion

    li $t4, 1
    sw $t4, direccion
    j fin_direccion

tecla_a:
    # No cambiar de derecha a izquierda
    lw $t4, direccion
    beq $t4, $zero, fin_direccion

    li $t4, 2
    sw $t4, direccion
    j fin_direccion

tecla_d:
    # No cambiar de izquierda a derecha
    lw $t4, direccion
    li $t5, 2
    beq $t4, $t5, fin_direccion

    sw $zero, direccion

fin_direccion:
    jr $ra


# GENERAR COMIDA ALEATORIA

generar_comida:

    addiu $sp, $sp, -32
    sw $ra, 28($sp)
    sw $s0, 24($sp)
    sw $s1, 20($sp)
    sw $s2, 16($sp)
    sw $s3, 12($sp)
    sw $s4, 8($sp)

intentar_comida:

    li $v0, 42
    li $a0, 0
    li $a1, 30
    syscall

    addiu $s0, $a0, 1

    li $v0, 42
    li $a0, 0
    li $a1, 30
    syscall

    addiu $s1, $a0, 1

    lw $s2, longitud
    li $s3, 0

revisar_comida:
    bge $s3, $s2, revisar_obstaculos_comida

    sll $t0, $s3, 2

    la $t1, snake_x
    addu $t1, $t1, $t0
    lw $t2, 0($t1)

    bne $s0, $t2, siguiente_revision

    la $t1, snake_y
    addu $t1, $t1, $t0
    lw $t3, 0($t1)

    beq $s1, $t3, intentar_comida

siguiente_revision:
    addiu $s3, $s3, 1
    j revisar_comida

# VERIFICAR QUE LA COMIDA NO APAREZCA
# ENCIMA DE UN OBSTACULO
# ==============================================

revisar_obstaculos_comida:

    # Coordenadas propuestas para la comida
    move $a0, $s0
    move $a1, $s1

    # Revisar si existe obstaculo
    jal verificar_obstaculo

    # Si existe, buscar otra posicion
    bne $v0, $zero, intentar_comida

    # Si esta libre, aceptar comida
    j comida_valida

comida_valida:

    sw $s0, comida_x
    sw $s1, comida_y

    move $a0, $s0
    move $a1, $s1
    lw $a2, color_comida

    jal pintar_celda

    lw $s4, 8($sp)
    lw $s3, 12($sp)
    lw $s2, 16($sp)
    lw $s1, 20($sp)
    lw $s0, 24($sp)
    lw $ra, 28($sp)
    addiu $sp, $sp, 32

    jr $ra



# MOVER SERPIENTE
# v0 = 0 movimiento normal
# v0 = 1 colision
# v0 = 2 comida consumida
# v0 = 3 tablero completado


mover_serpiente:

    addiu $sp, $sp, -40
    sw $ra, 36($sp)
    sw $s0, 32($sp)
    sw $s1, 28($sp)
    sw $s2, 24($sp)
    sw $s3, 20($sp)
    sw $s4, 16($sp)
    sw $s5, 12($sp)
    sw $s6, 8($sp)
    sw $s7, 4($sp)

    la $s0, snake_x
    la $s1, snake_y

    lw $s2, longitud

    lw $s3, 0($s0)
    lw $s4, 0($s1)

    lw $t0, direccion

    beq $t0, $zero, ir_derecha

    li $t1, 1
    beq $t0, $t1, ir_abajo

    li $t1, 2
    beq $t0, $t1, ir_izquierda

    li $t1, 3
    beq $t0, $t1, ir_arriba

    j comprobar_pared

ir_derecha:
    addiu $s3, $s3, 1
    j comprobar_pared

ir_abajo:
    addiu $s4, $s4, 1
    j comprobar_pared

ir_izquierda:
    addiu $s3, $s3, -1
    j comprobar_pared

ir_arriba:
    addiu $s4, $s4, -1

comprobar_pared:

    # Comprobar limites del tablero
    blez $s3, colision
    blez $s4, colision

    li $t0, 31
    bge $s3, $t0, colision
    bge $s4, $t0, colision

    # Comprobar colision con obstaculos
    move $a0, $s3
    move $a1, $s4

    jal verificar_obstaculo

    # Si v0 = 1, existe colision
    bne $v0, $zero, colision

    # Continuar con la logica de comida
    li $s5, 0

    lw $t0, comida_x
    bne $s3, $t0, revisar_cuerpo

    lw $t0, comida_y
    bne $s4, $t0, revisar_cuerpo

    li $s5, 1

revisar_cuerpo:

    move $s6, $s2

    bne $s5, $zero, iniciar_revision

    addiu $s6, $s6, -1

iniciar_revision:
    li $s7, 1

buscar_choque:
    bge $s7, $s6, actualizar_posiciones

    sll $t0, $s7, 2

    addu $t1, $s0, $t0
    lw $t2, 0($t1)

    bne $s3, $t2, siguiente_segmento

    addu $t1, $s1, $t0
    lw $t3, 0($t1)

    beq $s4, $t3, colision

siguiente_segmento:
    addiu $s7, $s7, 1
    j buscar_choque

actualizar_posiciones:

    bne $s5, $zero, aumentar_longitud

    addiu $t0, $s2, -1
    sll $t0, $t0, 2

    addu $t1, $s0, $t0
    lw $a0, 0($t1)

    addu $t1, $s1, $t0
    lw $a1, 0($t1)

    move $a2, $zero
    jal pintar_celda

    j desplazar_segmentos

aumentar_longitud:

    addiu $s2, $s2, 1
    sw $s2, longitud

    lw $t0, puntos
    addiu $t0, $t0, 10
    sw $t0, puntos

desplazar_segmentos:

    addiu $t0, $s2, -1

ciclo_desplazar:
    blez $t0, colocar_cabeza

    sll $t1, $t0, 2

    addiu $t2, $t0, -1
    sll $t2, $t2, 2

    addu $t3, $s0, $t2
    lw $t4, 0($t3)

    addu $t3, $s0, $t1
    sw $t4, 0($t3)

    addu $t3, $s1, $t2
    lw $t4, 0($t3)

    addu $t3, $s1, $t1
    sw $t4, 0($t3)

    addiu $t0, $t0, -1
    j ciclo_desplazar

colocar_cabeza:

    sw $s3, 0($s0)
    sw $s4, 0($s1)

    li $t0, 900
    bge $s2, $t0, movimiento_victoria

    beq $s5, $zero, movimiento_normal

    li $v0, 2
    j fin_movimiento

movimiento_normal:
    li $v0, 0
    j fin_movimiento

movimiento_victoria:
    li $v0, 3
    j fin_movimiento

colision:
    li $v0, 1

fin_movimiento:

    lw $s7, 4($sp)
    lw $s6, 8($sp)
    lw $s5, 12($sp)
    lw $s4, 16($sp)
    lw $s3, 20($sp)
    lw $s2, 24($sp)
    lw $s1, 28($sp)
    lw $s0, 32($sp)
    lw $ra, 36($sp)
    addiu $sp, $sp, 40

    jr $ra



# ==============================================
# ACTUALIZAR HIGH SCORE
# ==============================================

actualizar_record:

    lw $t0, puntos
    lw $t1, record

    # Comparar puntuacion con record
    ble $t0, $t1, fin_actualizar_record

    # Guardar nuevo record
    sw $t0, record

fin_actualizar_record:
    jr $ra


# ==============================================
# MOSTRAR HIGH SCORE
# ==============================================

mostrar_record:

    li $v0, 4
    la $a0, msg_record
    syscall

    # Mostrar puntuacion maxima
    li $v0, 1
    lw $a0, record
    syscall

    # Salto de linea
    li $v0, 4
    la $a0, salto
    syscall

    jr $ra

# ==============================================
# MOSTRAR PUNTUACION ACTUAL
# ==============================================

mostrar_puntos:
    li $v0, 4
    la $a0, msg_puntos
    syscall

    li $v0, 1
    lw $a0, puntos
    syscall

    li $v0, 4
    la $a0, salto
    syscall

    jr $ra



# ==============================================
# DIBUJAR OBSTACULOS
# ==============================================

dibujar_obstaculos:

    # Guardar registros
    addiu $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)

    # Direccion del arreglo
    la $s0, obstaculos

    # Cantidad de obstaculos
    lw $s1, cantidad_obstaculos

    # Contador
    li $s2, 0

ciclo_obstaculos:

    bge $s2, $s1, fin_obstaculos

    # Obtener coordenada X
    lw $a0, 0($s0)

    # Obtener coordenada Y
    lw $a1, 4($s0)

    # Color gris
    lw $a2, color_obstaculo

    # Pintar celda
    jal pintar_celda

    # Siguiente par de coordenadas
    addiu $s0, $s0, 8
    addiu $s2, $s2, 1

    j ciclo_obstaculos

fin_obstaculos:

    # Restaurar registros
    lw $s2, 8($sp)
    lw $s1, 12($sp)
    lw $s0, 16($sp)
    lw $ra, 20($sp)
    addiu $sp, $sp, 24

    jr $ra
    
    
    
# ==============================================
# VERIFICAR OBSTACULO
# Entradas:
# a0 = coordenada X
# a1 = coordenada Y
#
# Salida:
# v0 = 1 si hay obstaculo
# v0 = 0 si no hay obstaculo
# ==============================================

verificar_obstaculo:

    la $t0, obstaculos

    lw $t1, cantidad_obstaculos

    li $t2, 0

buscar_obstaculo:

    # Revisar todos los obstaculos
    bge $t2, $t1, sin_obstaculo

    # Obtener X del obstaculo
    lw $t3, 0($t0)

    # Obtener Y del obstaculo
    lw $t4, 4($t0)

    # Comparar coordenada X
    bne $a0, $t3, siguiente_obstaculo

    # Comparar coordenada Y
    beq $a1, $t4, choque_obstaculo

siguiente_obstaculo:

    # Avanzar 8 bytes
    addiu $t0, $t0, 8
    addiu $t2, $t2, 1

    j buscar_obstaculo

choque_obstaculo:

    li $v0, 1
    jr $ra

sin_obstaculo:

    move $v0, $zero
    jr $ra

