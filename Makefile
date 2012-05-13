test:
	./mads.exe t.asq; altirra t.obx
pngs = $(shell echo simpsons????.png)
xexs = $(patsubst %.png,%.xex,$(pngs))
max_evals = 100000

all: $(xexs)

%.xex: %.png
	./RastaConverter.exe $< /o=$*.out.png /noborder /dither=chess /max_evals=$(max_evals)
	perl -pe 's/output.png/$*.out.png/g' no_name.asq > $*.out.png.asq
	./mads $*.out.png.asq -o:$@

%.rp.asq: %.xex
	perl -ne 'print if /Init/ .. /ldy/; s/^line/;line/; print if /line0/ .. /line160/' \
	$*.out.png.rp.ini $*.out.png.rp > $@

%.show: %.xex
	altirra $<

clean:
	rm -f *.out.*

.PRECIOUS: %.xex
