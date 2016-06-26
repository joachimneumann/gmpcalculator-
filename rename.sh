for file in $(grep -rl VISAMED Calculator/*); do
    echo $file
    sed -e 's/\VISAMED IT./mindo software S.L./g' $file > tmp
    mv tmp $file
done
