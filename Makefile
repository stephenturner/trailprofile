FILENAME=trailprofile

all : README.md

README.md : $(FILENAME).md
	cat $(FILENAME).md | sed 's/```r/```S/g' > README.md

$(FILENAME).md : $(FILENAME).Rmd
	R --vanilla --slave -e 'library(knitr);knit2html("trailprofile.Rmd")'

clean : 
	rm -rf figure/ $(FILENAME).md $(FILENAME).html README.md