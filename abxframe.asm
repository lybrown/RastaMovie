	ift emulator
        org scr
        :16 dta 0
        ins "FRAME.out.png.mic",0,204*40
        :16 dta 0
        ins "FRAME.out.png.mic",204*40,36*40

        org rp
        icl "FRAME.out.rp.asq"
        rts

        org loadaudio1
        icl "FRAME.out.aud.asm"

        org players
        icl "FRAME.out.pmg.asm"

	ini showtwice

        els
        org scr
        :12 dta 0
        ins "FRAME.out.png.mic",0,204*40
        :16 dta 0
        ins "FRAME.out.png.mic",204*40,36*40

        :[rp-*] dta 0
        icl "FRAME.out.rp.asq"
        rts

        :[loadaudio1-*] dta 0
        icl "FRAME.out.aud.asm"

        :[players-*] dta 0
        icl "FRAME.out.pmg.asm"

	eif
