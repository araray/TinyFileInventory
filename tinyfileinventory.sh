#!/bin/bash

# First parameter $1 = path to start listing files
# Second parameter $2 = file to store the sql data

files_path="$1"
#dbfile="$base_path/files.db"
n_files=$(find $files_path -type f | wc -l)
bi="insert into files (filename, filename_hash, file_size, file_hash) values";
fout="$2"
iterator=0
progress=0
percent=0

estimated_time=0
i=0
interval=25
start_time=$(date +'%s')
elapsed=0
rows_per_second=0

for f in $(find $files_path -type f -printf "%f\n");
    do 
        let iterator++
        filename_hash="$(echo "$f" | sha1sum --text | awk '{print $1}')"
        file_hash="$(sha1sum --binary $(find $files_path -type f -name "$f") | awk '{print $1}')"
        file_size="$(find $files_path -type f -name "$f" -printf "%s")"
        #sql="'$bi (\"$f\",\"$filename_md5\",$file_size,\"$file_md5\");'"
        sql="$bi (\"$f\",\"$filename_hash\",\"$file_size\",\"$file_hash\");"
        #sqlite3 $dbfile $sql
        echo $sql >> $fout
        #clear
        let i++

        #sleep 0.01
        
        if [ $i == $interval ]; then
            progress=$(bc <<< "scale=3; $iterator / $n_files")
            percent=$(bc <<< "scale=1; ($progress * 100)/1.0")
            elapsed=$(bc <<< "$(date +'%s') - $start_time")
            rows_per_second=$(bc <<< "scale=2; $iterator / $elapsed")
            estimated_time=$(bc <<< "scale=2; ($n_files - $iterator) / $rows_per_second")
            i=0
        fi

        #echo "$iterator/$n_files $estimated_time $rows_per_second"
        echo -ne " $percent% :: $iterator of $n_files :: Estimated $estimated_time seconds to finish   "\\r
done

echo ".exit" >> $fout
echo "Elapsed time: $(bc <<< "$(date +'%s') - $start_time") seconds                                               "
echo "Job Completed."

exit 0

