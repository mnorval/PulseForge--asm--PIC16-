# PulseForge-PIC16

Bare-metal **PIC16F877A** assembly: software PWM breathe on `RB0` and a 9600 baud UART heartbeat (`PF-OK`).

## Toolchain
[gputils](https://gputils.sourceforge.io/) (`gpasm`, `gplink`)

```bash
gpasm -p p16f877a -o build/pulseforge.hex src/pulseforge.asm
```

## Hardware
| Pin | Function |
|-----|----------|
| OSC1/OSC2 | 4 MHz HS crystal |
| RB0 | LED + 330 Ω to GND |
| RC6/TX | UART 9600 8N1 |

Flash with PICkit / `pk2cmd`. No C runtime — every cycle is yours.
