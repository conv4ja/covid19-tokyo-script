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

# Usage

### 一括処理 (可搬性未検証)

コマンドラインから次のスクリプトを実行してください。
取得データ量が膨大(8GB以上?)となります。事前にファイルシステム容量をご確認の上、必要に応じてNFSを利用するなど、事前の対策をおすすめします。

```
git clone https://github.com/tokyo-metropolitan-gov/covid19 covid
cd covid
PATH=${PWD:%/*}:$PATH conv.sh all
```

### 抽出済み日時データjsonの集計・CSVへの変換

`conv.sh analyze` を実行することで、`out`配下に出力された感染者データを解析(差分計算・7日移動平均等)し、CSVとして出力します。実体としては`conv.py`を呼んでいます。

このスクリプトは東京都専用の実装です。

```
./conv.sh analyze
```


# Testing

未テスト。CIが通ることを確認できていません。

# Credit

`data-diff` および `out` 配下の生成済みデータは[東京都 新型コロナウイルス感染症対策サイトの公式リポジトリ](https://github.com/tokyo-metropolitan-gov/covid19)から取得されました。これら上流のデータに関しては[MITライセンス](https://github.com/tokyo-metropolitan-gov/covid19/blob/development/LICENSE.txt)で提供されます。

上記ディレクトリを除く本プロジェクトの成果物は [CC-BY-SA 4.0](LICENSE.md)で提供されます。
