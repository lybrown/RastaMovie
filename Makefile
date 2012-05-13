test:
	./mads.exe movie.asq; altirra movie.obx
pngs = $(shell echo simpsons????.png)
xexs = $(patsubst %.png,%.xex,$(pngs))
rps = $(patsubst %.png,%.rp.asq,$(pngs))
max_evals = 100000

all: $(rps)

%.xex: %.png
	./RastaConverter.exe $< /o=$*.out.png /noborder /dither=chess /max_evals=$(max_evals)
	perl -pe 's/output.png/$*.out.png/g' no_name.asq > $*.out.png.asq
	./mads $*.out.png.asq -o:$@

%.rp.asq: %.xex
	perl -ne 'print if /Init/ .. /ldy/; print if /line0/ .. /line160/' \
	$*.out.png.rp.ini $*.out.png.rp > $@
	perl -pe 's/FRAME/$*/' frame.asq > $*.frame.asq

%.show: %.xex
	altirra $<

clean:
	rm -f *.out.*

.PRECIOUS: %.xex
