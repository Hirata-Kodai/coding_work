if [ $# == 1 ]
then
	echo "catch a arg"
	echo $1
elif [ $# == 0 ]
then
	echo "no arg"
else
	echo "too many args"
	exit 1
fi

