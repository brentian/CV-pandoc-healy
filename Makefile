SHELL := /bin/zsh

all: clean cv.pdf

cv.pdf: cv.tex
	latexmk --xelatex -f -cd -quiet $<

vc.tex: curriculum_vitae.yaml
	sh vc.sh

yaml_CV.md: curriculum_vitae.yaml
# Pandoc can't actually read YAML, just YAML blocks in
# Markdown. So I give it a document that's just a YAML block,
# while still editing a straight YAML file which has a bunch of advantages.
	echo "---" > $@
	cat $< >> $@
	echo "..." >> $@

cv.tex: template.latex curriculum_vitae.yaml vc.tex
# Pandoc does the initial compilation to tex; we then latex handle the actual bibliography
# and pdf creation.
	echo " " | pandoc --metadata-file curriculum_vitae.yaml --template=$< -t latex > $@
# Citekeys get screwed up by pandoc which escapes the underscores.
# Years should have en-dashes, which damned if I'm going to do it
# on my own.
	perl -pi -e 'if ($$_=~/cite\{/) {s/\\_/_/g}; s/(\d{4})-([Pp]resent|\d{4})/$$1--$$2/g' $@;

clean:
	latexmk -C *.tex
	rm cv.tex	