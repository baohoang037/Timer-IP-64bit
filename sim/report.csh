#!/bin/csh
set log = "rep.log"
if (-f $log) then
    rm -rf $log
endif
touch $log
printf "|%-80s|\n" "--------------------------------------------------------------------------------" >> $log
printf "|%-40s |%-30s |%-20s |\n" " PAT_NAME" " RUN_DATE" " RESULT" >> $log
printf "|%-80s|\n" "--------------------------------------------------------------------------------" >> $log
foreach pat (`cat pat.list | sed '\/\//d'`)
    echo $pat
    set sim_log = "log/${pat}.log"
    set res = ""
    if( !(-f $sim_log)) then
        set res = "NA"
        echo "can not find $sim_log"
    else
        set tm = `grep "End time" $sim_log | awk -F"[ :,]" '{print $5 ":" $6 ":" $7 " " $9 " " $10 " " $11}'`
        set res = `grep "TEST PASSED" $sim_log`
        if ( "$res" != "" ) then
            set res = "PASSED"
        else
            set res = "FAILED"
        endif
    endif
    printf "|%-40s |%-30s |%-20s |\n" " $pat" " $tm" " $res" >> $log
    printf "|%-80s|\n" "--------------------------------------------------------------------------------" >> $log
end
cat $log
