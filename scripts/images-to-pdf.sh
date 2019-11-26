#!/bin/sh -e

dirr=`mktemp -d`
echo "Output files will be put in $dirr."

echo "A4 format is 210x297mm."
echo "For best results, we will set the format of the PDF to A4."
echo "It means that your source picture must be either 1050x1485 pixels or another multiple of that."
echo "What size is your picture size?"
echo "  1. 1050x1485 (default)"
echo "  2. 2100x2970"
read -r choice
echo "You chose $choice."
echo "Now paste all the file paths to concatenate into a PDF file, one by line. Hit enter twice to finish."
files=""
while read -r file
do
    if [ -z "$file" ]; then break; fi
    files="$files $file"
    echo "Next."
done <&0

if [ "$choice" = "2" ]; then
    density="254"
    page="2100x2970"
else
    density="127"
    page="1050x1485"
fi
echo "Assembling with density=$density and page=$page..."
convert -page "$page" -density "$density" $files "$dirr/output.pdf"
xdg-open "$dirr"
echo "Done"
