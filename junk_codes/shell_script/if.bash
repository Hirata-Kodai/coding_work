if [ $1 == "2021" ]
then KOI_FILE=2021_11_06_koi.csv
	 echo 2021
fi

if [ $1 == "2019" ]
then KOI_FILE=koi.csv
	 echo 2019
fi

i=2
k=2
declare -a Ratios=(0.75 0.5 0.25)
if [ $k -ne 1 -o $i -ne 1 ]; then
	echo notfold-1_seed-1
fi

for i in {1..5}; do
    for k in {1..5}; do
		for r in ${Ratios[@]}; do
			if [ 1 -lt ${i} ] || [ 1 -eq ${i} -a 2 -lt ${k} ]; then
				echo "fold-${k}_seed-${i}_${r}"
			fi
		done
	done
done
