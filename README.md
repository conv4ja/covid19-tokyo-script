# About

東京都の地域別(区市町村)の感染者統計を[東京都 新型コロナウイルス感染症対策サイトの公式リポジトリ](https://github.com/tokyo-metropolitan-gov/covid19)から抽出(json)し、日次データに変換、最終的にCSVとして出力するスクリプトです。

# Requirement

* Windows はサポート対象外です。WSLを導入いただくかUnix系OSでの検証をご検討ください。
* POSIX互換なシェル, e.g. GNU Bash (1)
* git
* jq >= 1.4
* python >= 3.8
* pandas >= 1.1.3  (debian derivatives: python3-pandas >= 1.1.3)
* xlrd >= 1.2.0 (debian derivatives: python3-xlrd >= 1.2.0)

上記以外のバージョンは動作保証の対象外となります。

ハードウェアとしてRAM 4GiB+, CPU としては Core i series 以上を推奨いたします。

* 可搬性はdash/bash においてのみ検証済みです(debian11/ubuntu)。macOSで検証頂ける方を募集しています。

# Usage

### 一括処理 


コマンドラインから次のスクリプトを実行してください。
取得データ量が膨大(8GB以上)となります。事前にファイルシステム容量をご確認の上、必要に応じてNFSを利用するなど、事前の対策をおすすめします。

```
./conv.sh all
```

### 本家Gitリポジトリの取得

https://github.com/tokyo-metropolitan-gov/covid19 のリポジトリを複製します。
取得データ量が膨大(8GB以上)となります。ご注意ください。


```
./conv.sh fetch
```


### 本家Gitリポジトリから区市町村別陽性者統計のjson取得

コミットログからデータ更新コミットのみを判別し、当該コミット間における公開データを隔離、感染者統計ファイルの差分(diff)を抽出します。
上記diffから再帰的に各日の区市町村別陽性者数を計算し、結果をJSONファイルとして生成します。

数分かかります。

```
./conv.sh fetch   # <--(取得済みの場合不要)
./conv.sh extract
```

### 抽出済み日次データjsonの集計・CSVへの変換

`conv.sh analyze` を実行することで、`out`配下に出力された日次データを解析し、区市町村・日付ごとの検査陽性者数をCSVとして出力します。
既に本家リポジトリをクローン済みであり、かつシェルによる集計ファイルの抽出`extract`が終了している場合には、こちらがおすすめです。
(conv.pyを単独で実行する場合と同じ結果が得られます。)

このスクリプトは東京都専用の実装です。

```
./conv.sh analyze
```

# Testing

- CI通過(Ubuntu)を確認。
- [ ] データ形式テストを記述していません。<-TODO
- [ ] zsh および macOSでの動作検証
- [ ] WSL

# Credit

本リポジトリに含まれる生成済みデータ`data-raw.csv`は[東京都 新型コロナウイルス感染症対策サイトの公式リポジトリ](https://github.com/tokyo-metropolitan-gov/covid19)から計算されました。
上流リポジトリのライセンスは[こちら](DATA_LICENSE)を参照ください。

本プロジェクトの成果物は [CC-BY-SA 4.0](LICENSE.md)で提供されます。
