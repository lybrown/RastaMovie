; RastaMovie
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
        opt f-h+
        icl "hardware.asm"
        org $4000
        ift !emulator
        org r:$4006
        eif
relocate
        sei               ; stop interrupts
        mva #$00 NMIEN    ; stop all interrupts
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
        jsr oscr
        jsr print
        jmp *
continue
        mva #0 COLPF3     ; black missiles
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
        sta $d701         ; request abx to blit next frame
        cmp #<FRAMECOUNT  ; can't access abx memory until blit is complete
        bne nextframe
        lda setframe+3
        cmp #>FRAMECOUNT
        bne nextframe
        jmp freeze
nextframe
        inc setframe+1
        sne:inc setframe+3
showtwice
        jsr showframe
        jsr loadaudio1    ; lines 248 through 261
        mva audio+0 AUDC1 ; line 0
        jsr showframe
        jsr loadaudio2
        mva audio+0 AUDC1
        ift emulator
        rts
        eif
        jmp setframe
showframe
        sta WSYNC
        mva audio+1 AUDC1 ; line 1
        ldx #2
        sta WSYNC
        mva audio+2 AUDC1 ; line 2
        cpx:rne VCOUNT
        mva audio+3 AUDC1 ; line 3
        mva <dlist DLISTL ; dlist via CPU since ANTIC's jvb was cut-off
        mva >dlist DLISTH
        sta WSYNC
        mva audio+4 AUDC1 ; line 4
        sta WSYNC
        mva audio+5 AUDC1 ; line 5
        ift !emulator
check
        lda $4000
        bne check
        lda $4002
        cmp #$fb
        bne check
        eif
        sta WSYNC
        mva audio+6 AUDC1 ; line 6
        :2 pla:pha        ; sync raster program
        :1 nop
        :1 cmp byt2       ; abx blit must be complete by now for jsr
        jsr rp            ; lines 7 through 247
        mva #0 COLBAK
        rts
dlist
        :204 dta $4e,a(scr+$10+#*40)
        :36 dta $4e,a(scr+$2000+#*40)
        dta $41,a(dlist)
freeze
        jsr showframe
        lda #$18
        sta AUDC1
        :248 sta [#]      ; load silence into audio buffer used by showframe
done
        jsr showframe
        jmp done
        icl 'print.asm'
loadaudio0
        icl 'MOVIE.out.aud.asm'
residentend equ *

        ift emulator
        ini relocate
        FRAMES
        ini freeze
        els
        org r:*+$2000
        :[$a000-*] dta 0
        ;ini relocate
        FRAMES
        ;ini freeze
        eif
