; RastaMovie
emulator equ 1
audio equ $0
resident equ $2000
pagestart equ $4000
scr equ $4000
rp equ $6600
loadaudio1 equ $9200
loadaudio2 equ $9700
pm equ $9800
missiles equ pm+$300
players equ pm+$400
byt2 equ 0
samples_per_frame equ 262
        ift emulator
        opt f-h+
        els
        opt f+h-
        eif
        icl "hardware.asm"
        org $4000
relocate
        ldx #0
        ldy >residentend
ld      lda $4000,x
st      sta $2000,x
        inx
        bne compare
        inc ld+2
        inc st+2
compare
        cpx <residentend
        bne ld
        cpy st+2
        bne ld
        jmp checkntsc
        org r:*-$2000
checkntsc
        lda #1
        cmp PAL
        bne continue
        jsr print
        jmp *
continue
        sei               ; stop interrupts
        mva #$00 NMIEN    ; stop all interrupts
        sta COLPF3        ; black missiles
        mva #$ff SIZEM    ; wide missiles
        sta GRAFM         ; solid missiles
        sta SIZEP0        ; wide players
        sta SIZEP1
        sta SIZEP2
        sta SIZEP3
        mva #$20 HPOSM0   ; position missiles as left and right borders
        mva #$28 HPOSM1
        mva #$d0 HPOSM2
        mva #$d8 HPOSM3
        mva #$02 GRACTL   ; DMA for players, GRAFM for missiles
        mva #$14 PRIOR    ; fifth player color, middle player priority
        mva >pm PMBASE
        mva #%00111010 DMACTL ; DL DMA, PM Rez, Player DMA, 40-byte playfield
        jsr loadaudio0    ; load first audio clip into zero-page/one-page buffer
        lda:rne VCOUNT    ; sync to last line of loadaudio, line 0
        ift emulator
        rts
        eif
setframe
        lda #1
        sta $d700         ; request abx to blit next frame
        cmp #<FRAMECOUNT  ; can't access abx memory until blit is complete
        bne nextframe
        lda setframe+3
        cmp #>FRAMECOUNT
        beq showtwice
nextframe
        inc setframe+1
        sne:inc setframe+3
showtwice
        jsr showframe
        jsr loadaudio1
        jsr showframe
        jsr loadaudio2
        ift emulator
        rts
        eif
        jmp setframe
showframe
        mva audio+0 AUDC1 ; line 1
        sta WSYNC
        mva audio+1 AUDC1
        sta WSYNC
        mva audio+2 AUDC1
        lda #2
        cmp:rne VCOUNT
        mva <dlist DLISTL
        mva >dlist DLISTH
        sta WSYNC
        mva audio+3 AUDC1
        sta WSYNC
        mva audio+4 AUDC1
        sta WSYNC
        mva audio+5 AUDC1 ; line 6
        :2 pla:pha        ; sync raster program
        :1 nop
        :1 cmp byt2       ; abx blit must be complete by this point
        jsr rp            ; line 7
        mva #0 COLBAK     ; line 247
        rts
dlist
        :102 dta $4e,a(scr+$0000+#*40)
        :102 dta $4e,a(scr+$1000+#*40)
        :36 dta $4e,a(scr+$2000+#*40)
        dta $41,a(dlist)
        icl 'print.asm'
loadaudio0
        icl 'MOVIE.out.aud.asm'
residentend equ *

        ift emulator
        ini relocate
        FRAMES
        org $2000
done
        jsr showtwice
        jmp done
        ini done
        eif
