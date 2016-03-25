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
FILENAME=$(basename $1 | sed "s/.tex//")
CURRENT_PATH=$(pwd)

compile() {
    {
      pdflatex -halt-on-error "$1"
    } || return 1
    biber "$1"
    makeglossaries "$1"
    pdflatex -halt-on-error "$1" || return 1
    biber "$1"
    pdflatex -halt-on-error "$1" && pdflatex -halt-on-error "$1" || return 1
}

show_error() {
    echo "Illegal usage" >&2
    echo "Usage: generate-pdf.sh <directory-where-tex-files-are> <tex-file-to-compile>"
    echo "For example, to compile latex/Document.tex, write: 'generate-pdf.sh latex/Document.tex'"
}

############################## BEGINNING OF THE SCRIPT ##############################

# Some checks
if [ "$#" -ne 1 ] || [ ! -d $BASEDIR ] || [ ! -f $1 ]; then
    show_error
    exit 0
fi
if ! dpkg -s inotify-tools > /dev/null; then
    echo "Please install inotifywait with '$ sudo apt-get install inotify-tools'"
    exit 0
fi

echo $FILENAME
# The most interesting part...
while inotifywait --exclude '(.*\.swp|.*\.swx)' -r -e $EVENTS "$(dirname $1)"; do
    cd "$BASEDIR"
    if compile "$FILENAME"; then echo "PDF generated with no error!"; fi
    cd "$CURRENT_PATH"
    rm "$BASEDIR/"*.aux "$BASEDIR/"*.bbl "$BASEDIR/"*.blg "$BASEDIR/"*.toc "$BASEDIR/"*.log "$BASEDIR/"*.out "$BASEDIR/"*.glg "$BASEDIR/"*.gls "$BASEDIR/"*.ist "$BASEDIR/"*.glo "$BASEDIR/"*.xdy "$BASEDIR/"*.nav "$BASEDIR/"*.snm "$BASEDIR/"*.vrb "$BASEDIR/"*.lot "$BASEDIR/"*.lof "$BASEDIR/"*.bcf "$BASEDIR/"*.run.xml -vf # Remove all output files except PDF
done
