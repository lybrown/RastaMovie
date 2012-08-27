        opt f+h-
        ;opt f+
        icl "hardware.asm"

        org scr
        ins "birds2000.out.png.mic",0,51*40
        :8 dta 0
        ins "birds2000.out.png.mic",51*40,102*40
        :16 dta 0
        ins "birds2000.out.png.mic",153*40,87*40

        org rp
        icl "birds2000.out.rp.asq"
        rts

        org audio1
        sta WSYNC
        mva audio+244 AUDC1 ; 7 cycles
        :19 mva #SAMPLE0 audio+0 ; 5 cycles
        cmp byt2 ; 3 cycles
        ; ...
        rts

        org audio2
        sta WSYNC
        mva audio+244 AUDC1 ; 7 cycles
        :19 mva #SAMPLE0 audio+0 ; 5 cycles
        cmp byt2 ; 3 cycles
        ; ...
        rts

        org players
        icl "birds2000.out.pmg.asm"
