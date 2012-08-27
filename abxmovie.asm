; RastaMovie
        opt f+h+
        icl "hardware.asm"
        icl "abxcommon.asm"
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
        ;bne continue
        jsr print
        jmp *
continue
        sei               ; stop interrupts
        mva #$00 NMIEN    ; stop all interrupts
        ldy #0
clearaudio
        sta $0,y
        sta a:$40,y+
        bne clearaudio
        mvx #$ff SIZEM    ; wide missiles
        stx GRAFM         ; solid missiles
        stx SIZEP0        ; wide players
        stx SIZEP1
        stx SIZEP2
        stx SIZEP3
        txs               ; reset stack pointer
        mva #$20 HPOSM0   ; use missiles as left and right borders
        mva #$28 HPOSM1
        mva #$d0 HPOSM2
        mva #$d8 HPOSM3
        mva #$02 GRACTL   ; DMA for players, GRAFM for missiles
        mva #$14 PRIOR    ; fifth player color, middle player priority
        mva >pm PMBASE
        jsr loadaudio2    ; load first audio clip into zero-page/one-page buffer
	lda:rne VCOUNT    ; sync to last line of loadaudio, line 0
loop
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
        jmp loop
showframe
        sta WSYNC
        mva audio+0 AUDC1 ; line 1
        sta WSYNC
        mva audio+1 AUDC1
        sta WSYNC
        mva audio+2 AUDC1
        mva #%00111010 DMACTL ; DL DMA, PM Rez, Player DMA, 40-byte playfield
        mva <dlist DLISTL
        mva >dlist DLISTH
        sta WSYNC
	mva audio+3 AUDC1
	sta WSYNC
	mva audio+4 AUDC1
	sta WSYNC
	mva audio+5 AUDC1 ; line 6
        :2 pha:pla        ; sync raster program
        :1 nop
        :1 cmp byt2       ; abx blit must be complete by this point
        jsr rp            ; line 7
        mva #0 COLBAK     ; line 247
        rts
        icl 'print.asm'
dlist
	:51 dta $4e,a(scr+$0000+#*40)
	:102 dta $4e,a(scr+$0800+#*40)
	:87 dta $4e,a(scr+$1800+#*40)
	dta $41,a(dlist)
residentend equ *

debug equ 1
        ift debug
        ini $4000
        icl 'abxframe.asm'
        eif
