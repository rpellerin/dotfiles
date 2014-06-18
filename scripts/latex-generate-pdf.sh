#!/bin/sh

# HANDY SCRIPT FOR GENERATING LATEX DOCUMENTS
# Author: Romain PELLERIN <contact@romainpellerin.eu>
#
# REQUIREMENTS
# sudo apt-get install inotify-tools
#
# ARGUMENT TO PASS
# $1: .tex file to compile (without extention)
# Example: ./generate-pdf.sh latex_files/Document (where Document is a .tex file)

EVENTS="create,modify,close_write,moved_to"
BASEDIR=$(dirname $1)

compile() {
    { # Try
        pdflatex -halt-on-error -output-directory $2 $1
        echo "STEP 1 [OK]"
        bibtex $1
        echo "STEP 2 [OK]"
        makeglossaries $1
        echo "STEP 3 [OK]"
        pdflatex -halt-on-error -output-directory $2 $1
        echo "STEP 4 [OK]"
        pdflatex -halt-on-error -output-directory $2 $1
        echo "STEP 5 [OK]"
    }
}

show_error() {
    echo "Illegal usage" >&2
    echo "Usage: generate-pdf.sh <directory-where-tex-files-are> <file-to-compile-without-extention>"
    echo "For example, to compile latex/Document.tex, write: 'generate-pdf.sh latex/Document'"
}

############################## BEGINNING OF THE SCRIPT ##############################

# Some checks
if [ "$#" -ne 1 ] || [ ! -d $BASEDIR ] || [ ! -f $1.tex ]; then
    show_error
    exit 0
fi
if ! dpkg -s inotify-tools > /dev/null; then
    echo "Please install inotifywait with '$ sudo apt-get install inotify-tools'"
    exit 0
fi

# The most interesting part...
while inotifywait -e $EVENTS $(dirname $1); do
    compile $1 $BASEDIR
    rm $BASEDIR/*.aux $BASEDIR/*.bbl $BASEDIR/*.blg $BASEDIR/*.toc $BASEDIR/*.log $BASEDIR/*.out $BASEDIR/*.glg $BASEDIR/*.gls $BASEDIR/*.ist $BASEDIR/*.glo -vf # Remove all output files except PDF
    echo "PDF generated!"
done