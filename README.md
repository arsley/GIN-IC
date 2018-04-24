# GIN-IC

## About

- 論文[Genetic Image Networkに基づく画像分類アルゴリズムの自動構築](https://www.jstage.jst.go.jp/article/tjsai/25/2/25_2_262/_article/-char/ja/)に提示されている手法GIN-ICを再現したもの

### GIN-IC

- GIN-ICは与えられた教師セット(画像とクラスラベル)から、画像分類器をGA(遺伝的アルゴリズム)により構築する手法である
- 分類器はフィードフォワードのネットワーク構造で表現され、人による解析が容易だという特徴を持つ

## Specification

- Crystal 0.24.1

## Usage

### 教師画像の配置

- `/train/teacher/`以下へ`{クラスラベル}.{番号}.pgm`の形式で投入する
- 投入した教師データの各クラスラベルに対応するよう`main.cr`13行目の`groups`を書き換える
  - `main.cr`での「学習サンプル」を参照

### 扱う画像サイズの指定

- `ginic/processing/image_transformation.cr`15行目の`PGM.create_stab`の引数に入力画像のサイズを与える
  - `width, height`の順で与える

### 未知画像分類

- `experience/data/`以下へ教師画像と同等の形式で未知画像を投入する
- 投入した未知画像の各クラスラベルと対応するよう`groups`を書き換える
- 学習により得られた遺伝子を`main.cr`29行目`genotypes...`へ書き換える
  - `main.cr`での「遺伝子実行サンプル」を参照

### コンパイルと実行

```
$ crystal build main.cr --release
$ ./main
```

※コンパイルができない場合は以下を試す

```
$ crystal build main.cr --release --no-debug
```

## Attention

- 場合によっては削除する可能性があります
