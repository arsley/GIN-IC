# 全ファイルのインポート
# 各モジュールにおいて Base が一番初めに読み込まれる必要がある
require "./ginic/train_helper/base"
require "./ginic/train_helper/**"
require "./ginic/train"

require "./ginic/execution_helper/base"
require "./ginic/execution_helper/**"
require "./ginic/execution"

require "./ginic/gin/base"
require "./ginic/gin/**"

require "./ginic/node/base"
require "./ginic/node/**"

require "./ginic/processing/**"

# PGM画像読み込みモジュール
require "./pgm"
require "./pgm/image"

# Genetic Image Network for Image Classification
# 画像カテゴリ分類アルゴリズム with 遺伝的アルゴリズム
module GINIC
  # 学習実行系の生成
  def self.train_new(option)
    GINIC::Train.new(option)
  end

  # 実験実行系の生成
  def self.execution_new(config, genotype)
    GINIC::Execution.new(config, genotype)
  end
end
