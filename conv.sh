#!/bin/sh -ex
# conv-cov19-tokyo-0.1.0 - 東京都新型コロナ対策サイトデータ抽出・変換器 (昆布)
# Author: Nomura Suzume <suzume315@g00.g1e.org>
# usagi: cd path/to/covid19/repo; conv.sh [all|clean]
# 注記1: 2020年5月以前のデータは正常に取得できません。
# 注記2: [バグ] 2020/6/1 および 9/10, 9/11, 10/29 のデータは異常値が出力されます。
# 注記3: 2021/11/29現在、データの整合性・正確性は検証していません。

PATH="${0%/*}:$PATH"
data_root=hack
diff_dir=$data_root/data-diffs
dest_dir=$data_root/out
repo_url="https://github.com/tokyo-metropolitan-gov/covid19"
repo_dir=tokyocovid19-repo

throw(){
	echo $* >&2
	exit 1
}

usagi(){ #usage
	head -4 $0 | tail -3 | tr -d \\\#
}

clean(){
	: ${data_root:?data_root not specified}
	[ -d $data_root ] && rm -rv $data_root || :
	git reset --hard origin/HEAD
}

fetch(){
	git clone ${repo_url:?repo_url must be set} ${repo_dir:?repo_dir must be set}
}

prepare(){
	[ -z "$NOP" ] || return 
	cd $repo_dir
	git status > /dev/null || {
		usagi
		throw "Gitリポジトリ $repo_dir が見つかりません"
	}
	git pull
	for i in $data_root $diff_dir $dest_dir
	do
		[ -d "$i" ] || mkdir -vp $i
	done

}


#参照対象データ一覧を取得
get_data_categories(){
	ls -1 data/* | sed -re s@\^data\/@@g -e s@.json\$@@g
}

#データ更新コミットrefを一覧取得。
#コミットログが `update data` から始まるすべてのコミットのみ対象とすｒ
get_refs(){
	git log --oneline \
		| egrep "^[[:xdigit:]]* update data" \
		| awk '{print $1}'
}

#HEAD初期化
set_initial_ref(){
	git reset --hard $(get_refs | head -1)
}

#すべての公開データ種別について、すべてのデータ更新におけるdiffを取得
get_diffs_foreach(){
	: ${diff_dir:?diff_dir not set}
	[ ! -d data ] && throw データが存在しません。
	while [ $# -ge 2 ]
	do
		git diff $1 $2 data > $diff_dir/$1-$2.diff &
		shift
		sleep 0.01
	done
	wait
}

#patient.json のデータフィールドから日付取得
get_date_from_data(){
	jq .datasets.date < data/patient.json \
		| sed -re y@/@-@ \
			-e s/\"//g \
			-e "s/ .+//g" \
			-e "s/-([[:digit:]])-/-0\1-/g" \
			-e "s/-([[:digit:]])$/-0\1/g"
}


#すべての公開データ種別について、すべてのデータ更新時における状態をパッチ生成し取得
#日付ごとにディレクトリを作成して保管。
#同一日に複数回のコミットが存在した場合には、最も新しいもののみを取得。
patch_diffs_foreach(){
	: ${diff_dir:?diff_dir not set}
	shift #latest update is omitted
	while [ $# -ge 2 ]
	do
		git reset --hard $1
		cat $(ls -1 $diff_dir/*.diff | grep $1-$2) \
			| patch -p1 -i -
		d=$(get_date_from_data)
		[ ! -d $dest_dir/$d ] && cp -rv data $dest_dir/$d
		shift

	done
}

pickup_data(){
	for m in $dest_dir/*
	do
		jq .datasets.data < $m/patient.json > $m/patient-mod.json 2> /dev/null
	done
	wait
}

extract(){
	set_initial_ref
	get_diffs_foreach $(get_refs)
	patch_diffs_foreach $(get_refs)
}

case $1 in
	fetch)
		fetch
		;;
	analyze)
		prepare
		conv.py
		;;
	extract)
		prepare
		extract
		pickup_data
		;;
	all)
		fetch
		[ -d "$repo_dir" ] || throw "\"conv.sh fetch\" first"
		prepare
		extract
		pickup_data
		echo PWD=$(pwd)
		ls
		cd ${data_root:?data_root must be set}
		${0%/*}/conv.py # -> 外部スクリプト(pandas) -> CSV吐 (地域別患者数のみ)
		;;
	clean)
		prepare
		clean
		;;
	*)
		usagi
		;;
esac

