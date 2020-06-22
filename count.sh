X=0
for d in `find ./ -type d`;
do
     p=`ls "$d" | wc -l`;
     X=`expr $X + $p`
done
echo $X
