#!/bin/sh
echo "Update NZ"

cd /home/danil/projects/

utf="nz/utils/.update_time"
utf2="nz/utils/.update_time2"

dirs="nz/"

/home/danil/projects/dpl/update.sh zhazhda.ru
restart=$?
echo "dpl update result: $restart"

if [ "$restart" -eq '1' ]; then
 touch nz/templ/inc/header
fi

files=`find $dirs -newer $utf -type f | grep -v \~ | grep -v db\.xml | grep -v "log/" | grep -v bz2 | grep -v "tmp/" | grep -v gz  | grep -v "var/" | grep -v CVS | grep -v log/ | grep -v images/ | grep -vi .bak$ | grep -vi .db$ | grep -v BAK | grep -v "openbill/etc/local.xml" | grep -v \.# | grep -v \.update_time.* | grep -v "/\."`
#files=`find $dirs -type f | grep -v \~ | grep -v db\.xml | grep -v "log/" | grep -v bz2 | grep -v "tmp/" | grep -v gz  | grep -v "var/" | grep -v CVS | grep -v log/ | grep -v images/ | grep -vi .bak$ | grep -vi .db$ | grep -v BAK | grep -v "openbill/etc/local.xml" | grep -v \.# | grep -v \.update_time.* | grep -v "/\."`
if [ "$files" ]; then
  echo "Files to copy:"
  if echo "$files" | grep ".pm\|.xml"  >/dev/null; then
     if [ "$1" != "1" ]; then
        restart=1
     fi
  fi
  list=`echo "$files" | xargs`
  echo "Restart: $restart"
  touch $utf2
  (tar cvf - $list -c | ssh danil@zhazhda.ru /home/danil/projects/nz/utils/receiveupdate.sh $restart) && mv $utf2 $utf
else
   echo "No new files.."
fi
