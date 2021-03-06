movie := birds
abx := 1
j := 3

all: $(movie).xex

par:
	make -j$(j) all

test show: all
	atari $(movie).xex

sofar:
	make pngs="$(shell printf '%s\n' $(movie)????.out.png | sed s/\.out//)"

emulator :=
max_frame := 6029
max_line := 240
pngs := $(wordlist 1,$(max_frame),$(shell echo $(movie)????.png))
xexs := $(patsubst %.png,%.xex,$(pngs))
frames := $(patsubst %.png,%.f.asm,$(pngs))
max_evals := 300000
dither := /dither=chess
#samples_per_frame := 312
#sample_rate := 15600
samples_per_frame := 262
sample_rate := 15720

%.out.png.rp: %.png
	./RastaConverter.exe $< /o=$*.out.png $(dither) /max_evals=$(max_evals) \
	/audio /pal=Palettes/authntsc.act

%.xex: %.out.png.rp
	perl -pe 's/output.png/$*.out.png/g' no_name.asq > $*.out.png.asq
	./mads $*.out.png.asq -o:$@

frametmpl := $(if $(fake),fakeframe.asm,$(if $(abx),abxframe.asm,frame.asq))
movietmpl := $(if $(fake),fakemovie.asm,$(if $(abx),abxmovie.asm,movie.asq))

# -1 below disables skipping over zero-page byte Altirra (used to?) write
%.f.asm: $(frametmpl) %.out.png.rp $(movie).audc
	perl -ne 'print if /Init/ .. /ldy/; print if /line0/ .. /line$(max_line)/' \
	$*.out.png.rp.ini $*.out.png.rp \
	| perl -e '@l=<>;splice@l,25,0,splice(@l,7,2),splice@l,23,1;print@l' \
	| perl -pe '0 if 1 .. s/COLBAK/HITCLR/;s/; on/ ; on/;s/^(\w)/;$$1/' \
	| perl -pe 'BEGIN{$$s=8}s/lda.*/lda 7/ if $$.==26;s/HITCLR/AUDC1/ if $$.==27; \
	$$s++ if s/lda (\S+) ; sample/lda $$s ; sample/; $$s++ if $$s == 0x30*-1; s/cmp byt2/nop/;' \
	> $*.out.rp.asq
	perl -nle 's/\.he// or next;@x=split;print" dta \$$",join",\$$",@x' $*.out.png.pmg > $*.out.pmg.asm
	./genaudio.pl $(if $(emulator),--org) \
	--offset `perl -e '"$*" =~ /(\d+)/;print((2*$$1+1)*$(samples_per_frame))'` \
	$(movie).audc > $*.out.aud.asm
	perl -pe 's/FRAME/$*/' $(frametmpl) > $@

%.show: %.xex
	altirra $<

$(movie).xex: $(movietmpl) $(frames)
	./genaudio.pl --org --offset 0 $(movie).audc \
	| perl -ne 'print if (/audio1/../audio2/)&&!/org/' > $(movie).out.aud.asm
	perl -pe 'BEGIN{@x=qw($(frames));$$count=@x;}' \
	-e 's/FRAMES/join "", map " icl \"$$_\"\n", @x/e;' \
	-e 's/FRAMECOUNT/$$count/; s/MOVIE/$(movie)/;' \
	$(movietmpl) > $(movie).out.asq
	time xasm /d:emulator=$(if $(emulator),1,0) $(movie).out.asq /o:$@

%.audc: %.wav
	sox -v 0.3 $< -u -b 8 -c 1 -r $(sample_rate) -D -t raw $*.raw
	perl -pe 's/(.)/ord($$1) < 0x78 ? chr(0x10) : ord($$1) > 0x87 ? chr(0x1f) : chr(ord($$1) - 0x78 | 0x10)/ge' $*.raw > $@

clean:
	rm -f *.out.* *.xex

distdir = RastaMovie-0.3
dist:
	rm -rf $(distdir)
	mkdir -p $(distdir)
	cp Makefile $(distdir)
	cp movie.asq $(distdir)
	cp frame.asq $(distdir)
	cp fakemovie.asq $(distdir)
	cp fakeframe.asq $(distdir)
	cp README.txt $(distdir)
	cp Rasta-opthack5.patch $(distdir)
	rm -f $(distdir).zip
	zip $(distdir).zip $(distdir)/*

.PRECIOUS: %.xex %.out.png.rp %.f.asm
