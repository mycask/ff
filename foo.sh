for i in x a b b c d e f
do
    echo log: $i >&2
    echo $i
    if [ $i = c ]
    then
        exit
    fi
done
echo :::: outside
