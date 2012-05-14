movie = homer
j = 3

all: $(movie).xex

par:
	make -j$(j) all

show: all
	altirra $(movie).xex

pngs = $(shell echo $(movie)????.png)
xexs = $(patsubst %.png,%.xex,$(pngs))
rps = $(patsubst %.png,%.out.rp.asq,$(pngs))
max_evals = 100000

%.xex: %.png
	./RastaConverter.exe $< /o=$*.out.png /noborder /dither=chess /max_evals=$(max_evals)
	perl -pe 's/output.png/$*.out.png/g' no_name.asq > $*.out.png.asq
	./mads $*.out.png.asq -o:$@

%.out.rp.asq: %.xex
	perl -ne 'print if /Init/ .. /ldy/; print if /line0/ .. /line160/' \
	$*.out.png.rp.ini $*.out.png.rp > $@
	perl -pe 's/FRAME/$*/' frame.asq > $*.out.frame.asq

%.show: %.xex
	altirra $<

$(movie).xex: $(rps)
	perl -pe 's/MOVIE/$(movie)/g' movie.asq > $(movie).out.asq
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
	cp README $(distdir)
	cp Rasta-opthack5.patch $(distdir)

.PRECIOUS: %.xex %.out.rp.asq
