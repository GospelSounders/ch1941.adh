#!/bin/bash

mkdir -p splitOriginalFiles

NUMPAGES=$(ls splitOriginalFiles| wc -l)
# echo $NUMPAGES
let "NUMPAGES=NUMPAGES+1"
echo $NUMPAGES


pdfseparate -f $NUMPAGES -l $NUMPAGES 1941-sda-hymnal-1.pdf splitOriginalFiles/page%d.pdf
cd splitOriginalFiles
pdf2htmlEX "page$NUMPAGES.pdf"
rm *.pdf
cd ..

git add .
git commit -m "page$NUMPAGES"
git push origin master

./splitter.sh
