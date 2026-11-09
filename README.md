# Snake en MARS MIPS 🐍

**Universidad Nacional de Costa Rica**  
Facultad de Ciencias Exactas y Naturales — Escuela de Informática  
**Curso:** Arquitectura de Computadoras (EIF205)  
**Proyecto 2:** Implementación de un juego 2D en lenguaje ensamblador

## Integrantes

- Fabricio Villalobos Vargas
- José Navarrete Oviedo

## Descripción

Este proyecto implementa una versión del juego clásico **Snake** en lenguaje ensamblador **MIPS**, utilizando el simulador **MARS**. El jugador controla una serpiente que se desplaza por un tablero, consume alimentos para aumentar su longitud y sumar puntos, y evita chocar contra las paredes, su propio cuerpo y los obstáculos.

El juego incluye un menú, pausa, reinicio sin cerrar el simulador, puntuación acumulativa y un récord máximo (*High Score*) que se conserva durante la ejecución del programa.

## Características

- Tablero de **32 × 32 celdas**, con borde verde y área interior de 30 × 30.
- Movimiento automático y control por teclado mediante **W, A, S, D**.
- Prevención de giros directos de 180°.
- Alimentos normales de color rojo: **+10 puntos** y crecimiento de un segmento.
- Alimentos especiales de color amarillo: **+30 puntos** y crecimiento de un segmento. Aparecen después de tres alimentos normales.
- **12 obstáculos fijos** de color gris, distribuidos en cuatro grupos.
- Colisiones con las paredes, los obstáculos y el cuerpo de la serpiente.
- Dificultad progresiva: la serpiente acelera al acumular puntos.
- Menú principal, pausa, reanudación, reinicio, victoria y Game Over.
- **Victoria al alcanzar 100 puntos** (meta ajustada para facilitar la demostración).
- High Score conservado entre partidas mientras no se cierre o reinicie la ejecución del programa.

## Requisitos

- **MARS MIPS 4.5** (o una versión compatible con las herramientas y llamadas al sistema utilizadas).
- Un entorno capaz de ejecutar MARS y sus herramientas gráficas.
- Archivo principal: `Snake.asm`.

No requiere bibliotecas externas ni un compilador adicional: el archivo se ensambla y ejecuta desde MARS.

## Configuración de MARS

### 1. Bitmap Display

En MARS, abre **Tools → Bitmap Display** y selecciona:

| Opción | Valor |
|---|---|
| Unit Width in Pixels | `16` |
| Unit Height in Pixels | `16` |
| Display Width in Pixels | `512` |
| Display Height in Pixels | `512` |
| Base address for display | `0x10008000 ($gp)` |

Presiona **Connect to MIPS**. Esta configuración crea una cuadrícula de 32 × 32 celdas.

### 2. Keyboard and Display MMIO Simulator

Abre **Tools → Keyboard and Display MMIO Simulator** y presiona **Connect to MIPS**.

**Importante:** para controlar el juego, haz clic dentro del área **KEYBOARD** de esta herramienta. Las teclas se envían allí, no a la consola *Run I/O*.

## Cómo ejecutar

1. Descarga o clona este repositorio.
2. Abre `Snake.asm` en **MARS MIPS** mediante **File → Open**.
3. Ensambla el programa con **Run → Assemble** (`F3`).
4. Configura y conecta **Bitmap Display** y **Keyboard and Display MMIO Simulator** como se indica arriba.
5. Ejecuta con **Run → Go** (`F5`).
6. Haz clic en el área **KEYBOARD** del simulador MMIO y presiona **`1`** para iniciar una partida.
7. Controla la serpiente con **W, A, S, D**.

Los mensajes de puntuación, niveles, pausa y resultados aparecen en la consola **Run I/O** de MARS. Si los controles no responden, revisa que Keyboard MMIO esté conectado y tenga el foco del teclado.

## Controles

| Tecla | Acción | Disponibilidad |
|---|---|---|
| `1` | Iniciar partida | Menú principal |
| `W` | Mover arriba | Durante la partida |
| `A` | Mover a la izquierda | Durante la partida |
| `S` | Mover abajo | Durante la partida |
| `D` | Mover a la derecha | Durante la partida |
| `P` | Pausar o reanudar | Durante partida / pausa |
| `R` | Reiniciar partida | Pausa / pantalla de resultado |
| `M` | Regresar al menú | Pausa / pantalla de resultado |
| `Q` | Salir del programa | Menú / pausa / pantalla de resultado |

La serpiente no puede invertir directamente su dirección (por ejemplo, pasar de derecha a izquierda).

## Puntuación y dificultad

| Alimento | Color | Puntos | Efecto |
|---|---|---:|---|
| Normal | Rojo | 10 | Crece un segmento |
| Especial | Amarillo | 30 | Crece un segmento |

El alimento especial aparece cada cuatro alimentos del ciclo: **tres normales y luego uno especial**. La nueva comida se genera en una celda que no esté ocupada por la serpiente ni por un obstáculo.

| Nivel | Puntuación acumulada | Espera aproximada por movimiento |
|---|---|---|
| 1 | 0–29 | 180 ms |
| 2 | 30–59 | 155 ms |
| 3 | 60–89 | 130 ms |
| 4 | 90–119 | 105 ms |
| 5 | 120–149 | 80 ms |
| 6 | 150 o más | 65 ms |

La **meta de victoria es 100 puntos**, por lo que normalmente una partida ganadora termina durante el nivel 4. Los niveles 5 y 6 están definidos en el código, pero no se alcanzan en una partida normal con esa meta.

### Fin de la partida

- **Victoria:** alcanzar la meta de 100 puntos.
- **Game Over:** chocar contra una pared, un obstáculo o el propio cuerpo.
- Tras finalizar, es posible **reiniciar (`R`)**, **volver al menú (`M`)** o **salir (`Q`)** sin reiniciar MARS.

## Organización del código

El archivo `Snake.asm` utiliza los segmentos `.data` (datos, arreglos, colores y mensajes) y `.text` (instrucciones y procedimientos). Entre las rutinas principales están:

| Procedimiento o sección | Responsabilidad |
|---|---|
| `iniciar_serpiente` | Reinicia coordenadas, longitud, puntos y dificultad |
| `dibujar_tablero` / `pintar_celda` | Dibuja el fondo, los bordes y las celdas en memoria gráfica |
| `dibujar_serpiente` | Representa la cabeza y los segmentos |
| `leer_tecla` / `procesar_direccion` | Lee Keyboard MMIO e interpreta movimientos |
| `mover_serpiente` | Desplaza los segmentos, verifica colisiones y procesa alimentos |
| `generar_comida` | Ubica alimentos normales o especiales en celdas libres |
| `dibujar_obstaculos` / `verificar_obstaculo` | Dibuja obstáculos y detecta colisiones con ellos |
| `actualizar_velocidad` | Determina el nivel y la espera entre movimientos |
| `actualizar_record` / `mostrar_record` | Gestiona y muestra el récord de la sesión |
| `mostrar_puntos` | Muestra la puntuación actual |
| `menu_principal`, `ciclo_juego` y estados | Controlan el menú, la partida, la pausa y el resultado |

La posición de cada segmento se almacena en dos arreglos de palabras (`snake_x` y `snake_y`). Las rutinas que realizan llamadas anidadas guardan los registros necesarios y la dirección de retorno en la pila.

## Modificaciones respecto al Snake clásico

1. **Obstáculos fijos:** el jugador debe esquivar bloques adicionales dentro del tablero.
2. **Velocidad progresiva:** la dificultad aumenta de acuerdo con la puntuación.
3. **Alimentos especiales:** algunos alimentos otorgan una bonificación mayor.

## Limitaciones y compatibilidad

- El proyecto está desarrollado y probado en **MARS MIPS**. Usa herramientas y servicios específicos del simulador, como **Bitmap Display**, **Keyboard MMIO** y llamadas al sistema de MARS.
- **No se ha verificado la ejecución en QEMU/Linux**; el mismo archivo no debe considerarse directamente compatible sin adaptar entrada, salida, visualización y servicios del sistema.
- El **High Score es temporal**: se conserva entre partidas de la ejecución actual, pero no se escribe en un archivo persistente.
- La meta está configurada en 100 puntos para que la demostración sea más breve.

## Evidencias y documentación

Las capturas del funcionamiento se organizan en `evidencias/`, y el informe técnico y la bitácora de pruebas pueden guardarse en `documentacion/`. Entre las pruebas se incluyen inicio, movimiento, comida y crecimiento, alimento especial, pausa, colisiones, High Score y victoria.

## Control de versiones

El proyecto utiliza **Git y GitHub** para registrar los avances. Cada actualización debe incluir un mensaje de commit que describa los cambios realizados.

---

**Proyecto académico — Escuela de Informática, Universidad Nacional de Costa Rica.**
