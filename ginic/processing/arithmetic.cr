module GINIC::Processing
  # 数値演算処理をまとめたモジュール
  # *exts* : 特徴量2つを含む配列
  module Arithmetic
    # 和を求める
    def self.summation(exts)
      exts[0].as(Float64) + exts[1].as(Float64)
    end

    # 差を求める(1)
    # この差は第1引数-第2引数とする
    def self.difference1(exts)
      exts[0].as(Float64).as(Float64) - exts[1].as(Float64)
    end

    # 差を求める(2)
    # この差は第2引数-第1引数とする
    def self.difference2(exts)
      exts[1].as(Float64) - exts[0].as(Float64)
    end

    # 積を求める
    def self.multiplication(exts)
      exts[0].as(Float64) * exts[1].as(Float64)
    end

    # 商を求める(1)
    # この商は第1引数 / 第2引数とする
    # - 割る数が0の場合は第1引数を返す
    #   - ZeroDivisionErrorに対応するため
    def self.quotient1(exts)
      return exts[0].as(Float64) if exts[1].as(Float64).zero?
      exts[0].as(Float64) / exts[1].as(Float64)
    end

    # 商を求める(2)
    # この商は第2引数 / 第1引数とする
    # - 割る数が0の場合は第2引数を返す
    #   - ZeroDivisionErrorに対応するため
    def self.quotient2(exts)
      return exts[1].as(Float64) if exts[0].as(Float64).zero?
      exts[1].as(Float64) / exts[0].as(Float64)
    end

    # 絶対値を返す(1)
    # 第1引数の絶対値を返す
    def self.absolute_value1(exts)
      exts[0].as(Float64).abs
    end

    # 絶対値を返す(2)
    # 第2引数の絶対値を返す
    def self.absolute_value2(exts)
      exts[1].as(Float64).abs
    end

    # 2数のうち大きい方を返す
    def self.maximize(exts)
      Math.max(exts[0].as(Float64), exts[1].as(Float64))
    end

    # 2数のうち小さい方を返す
    def self.minimize(exts)
      Math.min(exts[0].as(Float64), exts[1].as(Float64))
    end

    # 処理番号に対応した演算処理を実行する
    #
    # *process* : 実行したい演算メソッドの番号
    # *exts*  : 特徴量
    def self.execute(process, exts)
      case process
      when 1 then summation(exts)
      when 2 then difference1(exts)
      when 3 then difference2(exts)
      when 4 then multiplication(exts)
      when 5 then quotient1(exts)
      when 6 then quotient2(exts)
      when 7 then absolute_value1(exts)
      when 8 then absolute_value2(exts)
      when 9 then maximize(exts)
      when 10 then minimize(exts)
      end
    end

    # 処理番号を1つランダムに選択して返す
    def self.set
      rand(1..10)
    end
  end
end
