#!/bin/bash

echo Reverse!
cat args_for_list.txt | while read line
do
	read LOWER UPPER <<< ${line}  # read は標準入力から文字列を読むコマンド。Here String という記法で１行の文字列からリダイレクト。
	# IFS=, LOWER UPPER <<< ${line}  # csv ファイルの場合
	echo ${UPPER} ${LOWER}
done
