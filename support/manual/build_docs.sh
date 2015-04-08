#!/bin/bash

filename=Manual
doc_files=(
	'Introduction.md'
	'Safety.md'
	'Installation.md'
	'Configuration.md'
	'Cli.md'
	'Serial.md'
	'Rx.md'
	'Spektrum bind.md'
	'Failsafe.md'
	'Battery.md'
	'Gps.md'
	'Rssi.md'
	'Telemetry.md'
	'LedStrip.md'
	'Display.md'
	'Buzzer.md'
	'Sonar.md'
	'Profiles.md'
	'Modes.md'
	'Inflight Adjustments.md'
	'Controls.md'
	'Autotune.md'
	'Blackbox.md'
	'Migrating from baseflight.md'
	'Boards.md'
	'Board - AlienWii32.md'
	'Board - CC3D.md'
	'Board - CJMCU.md'
	'Board - Naze32.md'
	'Board - Sparky.md'
	'Board - Olimexino.md'
	'Board - ChebuzzF3.md'
)


BASEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
DBASE=${BASEDIR}/../../docs
DTMP=${BASEDIR}/tmp
GMD=${BASEDIR}/node_modules/markdown-styles/bin/generate-md


if ! which wkhtmltopdf >/dev/null; then
	echo "missing wkthmltopdf"
	exit 1
fi

if ! which npm >/dev/null; then
	echo "missing nodejs / npm"
	exit 1
fi

#clean up previous builds
rm ${DTMP} -Rf
mkdir -p ${DTMP}/manual_build

pushd .
#install nodejs componentns
cd $BASEDIR
npm install
#patch markdown-styles github layout
cd $DTMP
$GMD --export github
cat ${BASEDIR}/override.css >> output/assets/css/github-markdown.css
popd

echo "Building ${filename}.pdf"


#collect all non-md resources
cp ${DBASE}/* ${DTMP}/manual_build/ -Rf
find ${DTMP} -type f -name "*.md" -exec rm {} \;

#concatenate all markdown files
for i in "${doc_files[@]}"
do
	cat "${DBASE}/$i" >> ${DTMP}/${filename}.md
	echo -e "\n" >> ${DTMP}/${filename}.md
	echo -e ":PAGEBREAK:" >> ${DTMP}/${filename}.md
done

# generate html
${GMD} --layout ${DTMP}/output --input ${DTMP}/Manual.md --output ${DTMP}/manual_build/

sed -f ${BASEDIR}/postprocess_html.sed ${DTMP}/manual_build/Manual.html > ${DTMP}/manual_build/Manual_post.html

#convert html to pdf
wkhtmltopdf --margin-top 10mm --margin-bottom 10mm ${DTMP}/manual_build/Manual_post.html ${DTMP}/Manual.pdf
