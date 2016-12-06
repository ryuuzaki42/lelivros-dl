#!/bin/bash

countPage=1
countPageEnd=465

linkLeLivros="http://lelivros.top"
linkDlSite="$linkLeLivros/book/page"

((countPageEnd++))

tmpLogName="log_"`date +%s`".r"
echo -e "\nLog of Downloading book start at:`date`" > $tmpLogName

tmpLogName="../"$tmpLogName
mkdir books
cd books

while [ $countPage -lt $countPageEnd ]; do
    echo -e "\n        Downloading the page: $countPage" | tee -a $tmpLogName
    wget -c $linkDlSite/$countPage/ -O index.html

    pageLink=`cat index.html | grep "<a href=\"http.*rel" | cut -d"\"" -f2`
    rm index.html

    for linkBook in `echo -e "$pageLink"`; do
        echo -e "\n    Downloading: $linkBook" | tee -a $tmpLogName
        wget -c "$linkBook" -O index.html

        linkBookDlMobi=`cat index.html | grep "jegueajato.*mobi.*rel" | cut -d"'" -f2`
        linkBookDlPDF=`cat index.html | grep "jegueajato.*pdf.*rel" | cut -d"'" -f2`
        rm index.html

        echo -e "\n$linkBookDlMobi" >> $tmpLogName
        echo -e "$linkBookDlPDF" >> $tmpLogName

        bookFileName=`echo "$linkBook" | sed 's/http:\/\/lelivros.top//g' | cut -d "?" -f1 | sed 's/^\///1' | sed 's/-em-pdf-epub-e-mobi-ou-ler-online\///1' | sed 's/\//-/g'`

        sizeName=`echo "$bookFileName" | wc -c`

        if [ $sizeName -lt 10 ]; then
            echo -e "\nError: Book file name is very small - exiting\n"
            exit 1
        fi

        wget -c "$linkBookDlMobi" -O $bookFileName.mobi
        wget -c "$linkBookDlPDF" -O $bookFileName.pdf
    done

    ((countPage++))
done
