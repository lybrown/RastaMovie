        org scr
        ins "FRAME.out.png.mic",0,102*40
        :16 dta 0
        ins "FRAME.out.png.mic",102*40,102*40
        :16 dta 0
        ins "FRAME.out.png.mic",204*40,36*40

        org rp
        icl "FRAME.out.rp.asq"
        rts

        org loadaudio1
        icl "FRAME.out.aud.asm"

        org players
        icl "FRAME.out.pmg.asm"

	ift emulator
	ini showtwice
	eif
