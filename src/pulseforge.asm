; PulseForge-PIC16
; PIC16F877A @ 4 MHz — PWM-ish LED breathe on RB0 + UART heartbeat
; Assemble with gpasm:  gpasm -p p16f877a src/pulseforge.asm

    list        p=16f877a
    #include    <p16f877a.inc>

    __CONFIG _HS_OSC & _WDT_OFF & _PWRTE_ON & _BODEN_OFF & _LVP_OFF & _CPD_OFF & _WRT_OFF & _DEBUG_OFF & _CP_OFF

    cblock  0x20
delay_hi
delay_lo
duty
dir
tx_tmp
    endc

    org     0x0000
    goto    main
    org     0x0004
    retfie

main
    banksel STATUS
    bcf     STATUS, RP0
    bcf     STATUS, RP1
    clrf    PORTB
    clrf    PORTC

    bsf     STATUS, RP0          ; bank 1
    movlw   0x00
    movwf   TRISB                ; PORTB out
    movlw   0x80                 ; RC7 RX in, RC6 TX out
    movwf   TRISC
    movlw   d'25'                ; 9600 @ 4 MHz BRGH=1  SPBRG=25
    movwf   SPBRG
    movlw   b'00100100'          ; TXEN, BRGH
    movwf   TXSTA
    bcf     STATUS, RP0          ; bank 0
    movlw   b'10010000'          ; SPEN, CREN
    movwf   RCSTA

    movlw   0x01
    movwf   duty
    clrf    dir

loop
    call    pulse_rb0
    call    uart_hello
    call    tweak_duty
    goto    loop

pulse_rb0
    movf    duty, W
    movwf   delay_hi
on_phase
    bsf     PORTB, 0
    call    tiny
    decfsz  delay_hi, F
    goto    on_phase
    movlw   0x20
    movwf   delay_hi
    movf    duty, W
    subwf   delay_hi, F
off_phase
    bcf     PORTB, 0
    call    tiny
    decfsz  delay_hi, F
    goto    off_phase
    return

tweak_duty
    btfsc   dir, 0
    goto    down
    incf    duty, F
    movlw   0x1E
    subwf   duty, W
    btfss   STATUS, Z
    return
    bsf     dir, 0
    return
down
    decf    duty, F
    movf    duty, F
    btfss   STATUS, Z
    return
    bcf     dir, 0
    incf    duty, F
    return

uart_hello
    movlw   'P'
    call    putc
    movlw   'F'
    call    putc
    movlw   '-'
    call    putc
    movlw   'O'
    call    putc
    movlw   'K'
    call    putc
    movlw   0x0D
    call    putc
    movlw   0x0A
    call    putc
    return

putc
    banksel TXSTA
wait_tx
    btfss   TXSTA, TRMT
    goto    wait_tx
    banksel TXREG
    movwf   TXREG
    return

tiny
    movlw   0x20
    movwf   delay_lo
tiny_l
    decfsz  delay_lo, F
    goto    tiny_l
    return

    end
