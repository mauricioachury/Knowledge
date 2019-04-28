//SPlit file from line 1 to 15000000 into file1.log
perl -ne "print if 1 .. 15000000" refs-moca-thread1094.log > file1.log