 #!/usr/bin/env bash

# set -e
 set -o xtrace


 target="/storage_bulk/mastodon"
 remote="mastodon_backup@<<MASTODON_SERVER>>:/data/mastodon"


 

 while true; do 

  starttime=`date`

   scp mastodon_backup@<<MASTODON_SERVER>>:/var/lib/redis/dump.rdb /storage_bulk/redis

   date=`date`
   echo "Starting Mastodon sync - $date"
   rsync -av --info=progress2 "$remote" "$target"/
   date=`date`
   echo "Finished Mastodon sync - $date"

   sleep 5

   date=`date`
   echo "Starting Postgres sync - $date"

   ssh mastodon_backup@<<POSTGRES_SERVER>> "/srv/mastodon_backup/run_dump.sh"

   #psql_target="/storage_bulk/postgres/dumps-$date"
   psql_target="/storage_bulk/postgres/dumps"
   psql_target2="/storage_bulk/postgres/main"
   psql_remote="mastodon_backup@<<POSTGRES_SERVER>>:/data/postgres-dumps/"
   psql_remote2="postgres@<<POSTGRES_SERVER>>:/data/postgresql/"


   mkdir -p $psql_target

   rsync -av --info=progress2 "$psql_remote" "$psql_target"/
   rsync -av --info=progress2 "$psql_remote2" "$psql_target2"/
   date=`date`
   
   echo "Started At - $starttime" 
   echo "Finished Postgres sync - $date"


   sleep 3600
 done
