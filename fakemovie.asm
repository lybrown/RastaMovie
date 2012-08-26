    opt f+h-
    ;opt f+
; rasta movie
        icl "hardware.asm"

;samples_per_frame equ 312
samples_per_frame equ 262

audio equ $0
pm equ $4000
scr equ $4800
rp equ $7000
missiles equ pm+$300
players equ pm+$400

byt2 equ 0

        org $4000
init
        lda #1
        cmp PAL
        bne continue
        jsr print
        jmp *
continue

        sei                     ; stop interrupts
        mva #$00 NMIEN          ; stop all interrupts
        sta COLBAK
        sta COLPM0
        sta COLPM1
        sta COLPM2
        sta COLPM3
        sta COLOR0
        sta COLOR1
        sta COLOR2
        sta COLOR3
s0      lda #$03
        sta SIZEP0
        sta SIZEP1
        sta SIZEP2
        sta SIZEP3
        mva #$ff SIZEM          ; wide missiles
        sta GRAFM               ; solid missiles
        mva #$20 HPOSM0
        mva #$28 HPOSM1
        mva #$d0 HPOSM2
        mva #$d8 HPOSM3
        mva #$02 GRACTL         ; DMA for players, GRAFM for missiles
        mva #$14 PRIOR          ; fifth player color, middle player priority
        mva >pm PMBASE

        ; synchronization for the first screen line
	lda #2
	cmp:rne VCOUNT

showframe
        mva #%00111010 DMACTL
        mva <ant DLISTL
        mva >ant DLISTH
        sta WSYNC
	mva audio AUDC1
	sta WSYNC
	mva audio+1 AUDC1
	sta WSYNC
	mva audio+2 AUDC1
        :2 pha:pla
        :1 nop
        :1 cmp byt2

        jsr rp

        mva #0 COLBAK

testexit
	lda trig0		; FIRE #0
	beq stop

	lda consol		; START
	and #1
	beq stop

	lda skctl		; ANY KEY
	and #$04
	beq stop

sync
        ; synchronization for the first screen line
        ldx #0
        ldy #2
sync2
        lda a:audio+245,x
        sta WSYNC
        sta AUDC1
        inx
        cpy VCOUNT
        bne sync2
        jmp showframe

stop
        ; coldstart
        jmp $e477
        ;ini init
        icl 'print.asm'
ant
	:51 dta $4e,a(scr+$0000+#*40)
	:102 dta $4e,a(scr+$0800+#*40)
	:87 dta $4e,a(scr+$1800+#*40)
	dta $41,a(ant)

        org players
        icl "birds2000.out.pmg.asm"

        org scr
        ins "birds2000.out.png.mic",0,51*40
        :8 dta 0
        ins "birds2000.out.png.mic",51*40,102*40
        :16 dta 0
        ins "birds2000.out.png.mic",153*40,87*40

        org rp
        icl "birds2000.out.rp.asq"
        rts

