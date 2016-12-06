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
# Last update: 6/12/2016
#
countPage=1
countPageEnd=465
countPageEnd=1

linkLeLivros="http://lelivros.top"
linkDlSite="$linkLeLivros/book/page"

tmpLogName="log_"`date +%s`".r"
tmpLogNameError="logError_"`date +%s`".r"

echo -e "Log of Downloading book start at:`date`" | tee -a $tmpLogName -a $tmpLogNameError

tmpLogName="../../"$tmpLogName
tmpLogNameError="../../"$tmpLogNameError

mkdir books
cd books

((countPageEnd++))
while [ $countPage -lt $countPageEnd ]; do
    mkdir $countPage
    cd $countPage

    echo -e "\n## Downloading the page: $countPage" | tee -a $tmpLogName -a $tmpLogNameError
    wget -c $linkDlSite/$countPage/ -O index.html

    pageLink=`cat index.html | grep "<a href=\"http.*rel" | cut -d"\"" -f2`
    rm index.html

    for linkBook in `echo -e "$pageLink"`; do
        echo -e "\n    ## Downloading: $linkBook" | tee -a $tmpLogName
        wget -c "$linkBook" -O index.html

        linkBookDlMobi=`cat index.html | grep "jegueajato.*mobi.*rel" | cut -d"'" -f2`
        linkBookDlPdf=`cat index.html | grep "jegueajato.*pdf.*rel" | cut -d"'" -f2`
        linkBookDlEpub=`cat index.html | grep "jegueajato.*epub.*rel" | cut -d"'" -f2`
        rm index.html

        ## mobi
        wget -c "$linkBookDlMobi"

        fileNameDownloadMobi=$(basename "$linkBookDlMobi")
        fileNameMobiNew=`echo "$fileNameDownloadMobi" | sed 's/?.*=//1'`

        fileNameMobiNewSize=`echo $fileNameMobiNew | wc -c`

        if [ $fileNameMobiNewSize -lt 10 ]; then
            mkdir error 2> /dev/null
            mv index.html"$fileNameDownloadMobi" error/
            echo -e "\n        ## Error downloading mobi: $linkBook" | tee -a $tmpLogNameError
        else
            echo -e "\n        $linkBookDlMobi" >> $tmpLogName
            mv "$fileNameDownloadMobi" "$fileNameMobiNew"
        fi

        ## pdf
        wget -c "$linkBookDlPdf"

        fileNameDownloadPdf=$(basename "$linkBookDlPdf")
        fileNamePdfNew=`echo "$fileNameDownloadPdf" | sed 's/?.*=//1'`

        fileNamePdfNewSize=`echo $fileNamePdfNew | wc -c`

        if [ $fileNamePdfNewSize -lt 10 ]; then
            mkdir error 2> /dev/null
            mv index.html"$fileNameDownloadPdf" error/
            echo -e "\n        ## Error downloading pdf: $linkBook" | tee -a $tmpLogNameError
        else
            echo "        $linkBookDlPdf" >> $tmpLogName
            mv "$fileNameDownloadPdf" "$fileNamePdfNew"
        fi

        ## epub
        wget -c "$linkBookDlEpub"

        fileNameDownloadEpub=$(basename "$linkBookDlEpub")
        fileNameEpubNew=`echo "$fileNameDownloadEpub" | sed 's/?.*=//1'`

        fileNameEpubNewSize=`echo $fileNameEpubNew | wc -c`

        if [ $fileNameEpubNewSize -lt 10 ]; then
            mkdir error 2> /dev/null
            mv index.html"$fileNameDownloadEpub" error/
            echo -e "\n        ## Error downloading epub: $linkBook" | tee -a $tmpLogNameError
        else
            echo "        $linkBookDlEpub" >> $tmpLogName
            mv "$fileNameDownloadEpub" "$fileNameEpubNew"
        fi
    done

    ((countPage++))
    cd ../
done

cd ../
tmpLogName=`echo "$tmpLogName" | sed 's/..\///g'`
tmpLogNameError=`echo "$tmpLogNameError" | sed 's/..\///g'`

echo -e "\nEnd of log downloading at:`date`" | tee -a $tmpLogName -a $tmpLogNameError
