#!/bin/sh

#### BEGIN CONFIGURATION ####

# set dump directory variables
SRCDIR='/tmp/s3backups'
DESTDIR='bucket-folder'
BUCKET='bucket'

# database access details
HOST=''
USER='root'
PASS=''

#### END CONFIGURATION ####

# make the temp directory if it doesn't exist and cd into it
mkdir -p $SRCDIR
cd $SRCDIR

# get list of databases
DBLIST=`psql -l -U $USER \
  | awk '{print $1}' | grep -v "+" | grep -v "Name" | \
  grep -v "List" | grep -v "(" | grep -v "template" | \
  grep -v "postgres" | grep -v "root" | grep -v "|" | grep -v "|"`

# dump each database to its own sql file and upload it to s3
for DB in ${DBLIST}
do
pg_dump -Oxc -U $USER $DB > $DB.sql 
tar -czPf $DB.tar.gz $DB.sql
/usr/bin/s3cmd put $SRCDIR/$DB.tar.gz s3://$BUCKET/$DESTDIR/
done

# remove all files in our source directory
cd
rm -f $SRCDIR/*