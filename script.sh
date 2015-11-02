#!/bin/bash

if [[ -d $1 ]]; then
  workdir=$1
else
  workdir="."
fi

# see http://stackoverflow.com/questions/24573584/how-to-watch-file-changes-on-mac-osx-using-fswatch
function refreshPreview {
  osascript -e "display notification \"Done\" with Title \"Rerendering\""
  open ${result_filename}
}

function notifyFileChange {
  filename=`basename $1`
  osascript -e "display notification \"Regenerating ${filename//\"/\\\"}\" with Title \"Rerendering\""
}

function renderPdf {
  path=$1
  export result_filename=${path%.*}.pdf 
  pandoc -s -f markdown -t html -c `pwd`/style.css $path | tee /dev/tty | wkhtmltopdf - ${result_filename} >/dev/null
}

export -f refreshPreview
export -f notifyFileChange
export -f renderPdf

fswatch -0 ${workdir}/*.md | xargs -0 -n 1 -I {} bash -c  'notifyFileChange "{}" && renderPdf "{}" && refreshPreview'