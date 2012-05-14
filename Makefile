movie = homer
j = 3

all: $(movie).xex

par:
	make -j$(j) all

show: all
	altirra $(movie).xex

pngs = $(wordlist 1,64,$(shell echo $(movie)????.png))
xexs = $(patsubst %.png,%.xex,$(pngs))
frames = $(patsubst %.png,%.out.frame.asq,$(pngs))
max_evals = 100000

%.xex: %.png
	./RastaConverter.exe $< /o=$*.out.png /noborder /dither=chess /max_evals=$(max_evals)
	perl -pe 's/output.png/$*.out.png/g' no_name.asq > $*.out.png.asq
	./mads $*.out.png.asq -o:$@

%.out.frame.asq: frame.asq %.xex
	perl -ne 'print if /Init/ .. /ldy/; print if /line0/ .. /line160/' \
	$*.out.png.rp.ini $*.out.png.rp > $*.out.rp.asq
	perl -pe 's/FRAME/$*/' frame.asq > $@

%.show: %.xex
	altirra $<

$(movie).xex: movie.asq $(frames)
	perl -pe 'BEGIN{@x=qw($(frames));$$count=@x;}' \
	-e 's/FRAMES/join "", map " icl \"$$_\"\n", @x/e;' \
	-e 's/frame_count = .*/frame_count = $$count/;' \
	movie.asq > $(movie).out.asq
	./mads.exe $(movie).out.asq -o:$@

clean:
	rm -f *.out.*

distdir = RastaMovie-0.1
dist:
	rm -rf $(distdir)
	mkdir -p $(distdir)
	cp Makefile $(distdir)
	cp movie.asq $(distdir)
	cp frame.asq $(distdir)
	cp README.txt $(distdir)
	cp Rasta-opthack5.patch $(distdir)
	rm $(distdir).zip
	zip $(distdir).zip $(distdir)/*

.PRECIOUS: %.xex %.out.frame.asq
