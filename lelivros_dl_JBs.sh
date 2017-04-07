#!/bin/bash
#
# Autor= João Batista Ribeiro
# Bugs, Agradecimentos, Criticas "construtivas"
# Mande me um e-mail. Ficarei Grato!
# e-mail: joao42lbatista@gmail.com
#
# Este programa é um software livre; você pode redistribui-lo e/ou
# modifica-lo dentro dos termos da Licença Pública Geral GNU como
# publicada pela Fundação do Software Livre (FSF); na versão 2 da
# Licença, ou (na sua opinião) qualquer versão.
#
# Este programa é distribuído na esperança que possa ser útil,
# mas SEM NENHUMA GARANTIA; sem uma garantia implícita de ADEQUAÇÃO a
# qualquer MERCADO ou APLICAÇÃO EM PARTICULAR.
#
# Veja a Licença Pública Geral GNU para mais detalhes.
# Você deve ter recebido uma cópia da Licença Pública Geral GNU
# junto com este programa, se não, escreva para a Fundação do Software
#
# Livre(FSF) Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
#
# Script: Download the books (mobi, pdf, epub) from a lelivros site
#
# Last update: 07/04/2017
#
echo -e "\nThis script download book (files mobi, pdf, epub) from a lelivros site\n"

linkLeLivros="http://lelivros.top"
linkDlSite="$linkLeLivros/book/page"

echo -n "Which page you want start the download: "
read -r startPage

if [ "$startPage" != '' ]; then
    countPage=$startPage
else
    countPage=1
fi

echo -n "Which page you want end the download: "
read -r endPage

if [ "$endPage" != '' ]; then
    countPageEnd=$endPage
else
    wget $linkLeLivros/ -O index.html
    countPageEnd=$(grep "ltima " < index.html | rev | cut -d "=" -f1 | cut -d"/" -f3 | rev)
    rm index.html
fi

echo -e "\nWill download from page \"$countPage\" to page \"$countPageEnd\""
echo -en "Want continue? (y)es - (n)o (press enter to no): "
read -r contine

if [ "$contine" != 'y' ]; then
    echo -e "\nJust exiting by user choice\n"
    exit 0
fi

echo -e "\nFiles type download"
echo -en "\nMobi: (y)es - (n)o (hit enter to no): "
read -r downloadMobi
if [ "$downloadMobi" == 'y' ]; then
    downloadMobi=true
else
    downloadMobi=false
fi

echo -en "\nPdf: (y)es - (n)o (hit enter to no): "
read -r downloadPdf
if [ "$downloadPdf" == 'y' ]; then
    downloadPdf=true
else
    downloadPdf=false
fi

echo -en "\nEpub: (y)es - (n)o (hit enter to no): "
read -r downloadEpub
if [ "$downloadEpub" == 'y' ]; then
    downloadEpub=true
else
    downloadEpub=false
fi

mkdir books_"$countPage"to"$countPageEnd" 2> /dev/null
cd books_"$countPage"to"$countPageEnd"/ || exit

tmpLogName="log_$(date +%s).r"
tmpLogNameError="logError_$(date +%s).r"

echo -e "Log of Downloading book start at: $(date)" | tee -a "$tmpLogName" -a "$tmpLogNameError"

tmpLogName="../"$tmpLogName
tmpLogNameError="../"$tmpLogNameError
printLinkBookError=true

downloadFile () {
    linkBook=$1
    fileType=$2

    linkBookDl=$(grep "jegueajato.*$fileType.*rel" < index.html | cut -d"'" -f2)
    wget "$linkBookDl"

    fileNameDownload=$(basename "$linkBookDl")

    if echo "$fileNameDownload" | grep -q "%20"; then
        fileNameDownload=${fileNameDownload//%20/ }
    fi

    fileNameNew=${fileNameDownload//?.*=/)}
    fileNameNewSize=${#fileNameNew}

    if [ "$fileNameNewSize" -lt 10 ]; then
        mkdir error 2> /dev/null
        mv index.html"$fileNameDownload" error/

        if [ "$printLinkBookError" == "true" ]; then
            echo -e "    ## Error downloading: $linkBook" | tee -a "$tmpLogNameError"
        fi

        printLinkBookError=false
        echo -e "        $fileType: $linkBookDl" | tee -a "$tmpLogNameError"
    else
        echo "        $linkBookDl" >> "$tmpLogName"
        mv "$fileNameDownload" "$fileNameNew"
    fi
}

((countPageEnd++))
while [ $countPage -lt $countPageEnd ]; do
    mkdir $countPage
    cd $countPage || exit

    echo -e "\n## Downloading the page: $countPage" | tee -a "$tmpLogName" -a "$tmpLogNameError"
    echo
    wget $linkDlSite/$countPage/ -O index.html

    pageLink=$(grep "<a href=\"http.*rel" < index.html | cut -d"\"" -f2)
    rm index.html

    countBookInThisPage=1
    for linkBook in $(echo -e "$pageLink"); do
        echo -e "\n    ## Downloading Page: $countPage BookNumber: $countBookInThisPage link: $linkBook" | tee -a "$tmpLogName"
        echo
        wget "$linkBook" -O index.html

        if [ $downloadMobi == "true" ]; then
            downloadFile "$linkBook" mobi
        fi

        if [ $downloadPdf == "true" ]; then
            downloadFile "$linkBook" pdf
        fi

        if [ $downloadEpub == "true" ]; then
            downloadFile "$linkBook" epub
        fi

        rm index.html

        printLinkBookError=true
        ((countBookInThisPage++))
    done

    ((countPage++))
    cd ../ || exit
done

tmpLogName=$(echo "$tmpLogName" | sed 's/..\///1')
tmpLogNameError=$(echo "$tmpLogNameError" | sed 's/..\///1')
echo -e "\nEnd of log downloading at: $(date)" | tee -a "$tmpLogName" -a "$tmpLogNameError"
