module GINIC::Processing
  # 特徴量抽出処理をまとめたモジュール
  # - 常に引数として画像データ2つを取り、1つ目のみに処理を適応させる
  # - ただし2つ目を必要とする処理もある
  # gradation value(階調値), count(出現回数)
  module FeatureExtraction
    alias IMG = PGM::Image

    # 全画素数(ヒストグラムにおけるデータの総数)を返すユーティリティ関数
    def self._pixels(img)
      img.width * img.height
    end

    # 画像(ヒストグラム)における平均値(平均階調値)を求める
    def self.average(imgs)
      histogram = imgs[0].as(IMG).histogramake
      sum = 0.0
      histogram.each_with_index { |count, grad| sum += grad * count }
      average = sum / _pixels(imgs[0].as(IMG)).to_f
      average
    end

    # 画像(ヒストグラム)における最頻値を求める
    def self.mode(imgs)
      histogram = imgs[0].as(IMG).histogramake
      mode = -1.0
      max_count = -1
      histogram.each_with_index do |count, grad|
        if count > max_count
          mode = grad
          max_count = count
        end
      end
      mode
    end

    # 画像(ヒストグラム)における分散値を求める
    def self.variance(imgs)
      average   = average(imgs)
      histogram = imgs[0].as(IMG).histogramake
      sum = 0.0
      histogram.each_with_index { |count, grad| sum += (grad - average)**2 * count }
      variance = sum / _pixels(imgs[0].as(IMG)).to_f
      variance
    end

    # 画像(ヒストグラム)における標準偏差を求める
    def self.standard_deviation(imgs)
      Math.sqrt(variance(imgs))
    end

    # 画像における歪度(ヒストグラムの非対称性)を求める
    #
    # - 0に近いほど左右対称な分布を表す
    #   - 正の値の時は右寄り
    #   - 負の値の時は左寄り
    def self.skew(imgs)
      std       = standard_deviation(imgs)
      average   = average(imgs)
      histogram = imgs[0].as(IMG).histogramake
      sum       = 0.0
      histogram.each_with_index { |count, grad| sum += (grad - average)**3 * count }
      skew = sum / (std**3 * _pixels(imgs[0].as(IMG)))
      skew
    end

    # 画像における尖度(ヒストグラムの尖り具合)を求める
    #
    # 3を引かない場合
    # - 3に近いほど正規分布に近似する
    #   - 3より大きいと尖った分布
    #   - 3より小さいとなだらかな分布
    #
    # 3を引く場合(利用したのはこっち)
    # - 0に近いほど正規分布に近似する
    #   - 0より大きいと尖った分布
    #   - 0より小さいとなだらかな分布
    def self.kurtosis(imgs)
      std       = standard_deviation(imgs)
      average   = average(imgs)
      histogram = imgs[0].as(IMG).histogramake
      sum       = 0.0
      histogram.each_with_index { |count, grad| sum += (grad - average)**4 * count }
      kurtosis = sum / (std**4 * _pixels(imgs[0].as(IMG))) - 3
      kurtosis
    end

    # 指定した点における分位数を求める
    #
    # 以下の処理のヘルパーとして利用する
    # `#min`
    # `#percentile_25`
    # `#median`
    # `#percentile_75`
    # `#max`
    #
    # *q* : パーセント点(0..1の百分率で指定する)
    def self._quantile(img, q)
      histogram = img.histogramake
      point = (q * _pixels(img)).round.to_i
      freq = 0
      histogram.each_with_index do |count, grad|
        freq += count
        return grad if freq > point
      end
      255 # 精査仕切った場合は理論最大階調値を返す
    end

    # メディアン(中央値を求める)
    #
    # 50%点は実質メディアンと等しい
    def self.median(imgs)
      _quantile(imgs[0].as(IMG), 0.5)
    end

    # 25%点を求める
    # - 第1四分位数とも言う
    def self.percentile_25(imgs)
      _quantile(imgs[0].as(IMG), 0.25)
    end

    # 75%点を求める
    # - 第3四分位数とも言う
    def self.percentile_75(imgs)
      _quantile(imgs[0].as(IMG), 0.75)
    end

    # IQR(四分位範囲)を求める
    # - 第1四分位数と第3四分位数の差で求められる
    def self.interquartile_range(imgs)
      percentile_75(imgs).not_nil! - percentile_25(imgs).not_nil!
    end

    # 四分位偏差を求める
    # - IQRを2で割ったもの
    def self.quartile_deviation(imgs)
      interquartile_range(imgs) / 2.0
    end

    # 0%点(最小値)を求める
    def self.min(imgs)
      _quantile(imgs[0].as(IMG), 0)
    end

    # 1分位点(最大値)を求める
    def self.max(imgs)
      _quantile(imgs[0].as(IMG), 1)
    end

    # nσ内/外確率を求める上での開始点(階調値)を返す
    #
    # `#_sigma_in_rate`
    #
    # *ave* : 平均
    # *std* : 標準偏差(すでにn倍されているもの)
    def self._from(ave, std)
      (ave - std) < 0 ? 0 : (ave - std).round.to_i
    end

    # nσ内/外確率を求める上での終点(階調値)を返す
    #
    # `#_sigma_in_rate`
    #
    # *ave* : 平均
    # *std* : 標準偏差(すでにn倍されているもの)
    def self._to(ave, std)
      (ave + std) > 255 ? 255 : (ave + std).round.to_i
    end

    # nσ内確率を求める
    #
    # 求めた確率は100倍して0..100の範囲で返す
    #
    # `#sigma_in_rate_2`
    # `#_sigma_out_rate`
    # `#sigma_out_rate_2`
    #
    # *n* : σに対する係数
    def self._sigma_in_rate(imgs, n)
      ave = average(imgs)
      std = standard_deviation(imgs)
      histogram = imgs[0].as(IMG).histogramake
      from = _from(ave, n * std)
      to   = _to(ave, n * std)
      rate_count = 0.0
      (from..to).each do |i|
        rate_count += histogram[i]
      end
      rate_count / _pixels(imgs[0].as(IMG)) * 100
    end

    # nσ外確率を求める
    #
    # 100からσ内確率を引くことで表現可能
    #
    # `#sigma_out_rate_2`
    #
    # *range* : 求める範囲
    def self._sigma_out_rate(imgs, range)
      100.0 - _sigma_in_rate(imgs, range)
    end

    # 2σ内確率を求める
    def self.sigma_in_rate_2(imgs)
      _sigma_in_rate(imgs, 2)
    end

    # 2σ外確率を求める
    def self.sigma_out_rate_2(imgs)
      _sigma_out_rate(imgs, 2)
    end

    # 処理番号に対応した特徴量抽出処理を実行する
    #
    # *process* : 実行したい特徴量抽出メソッドの番号
    # *imgs*    : 画像データ(常に2枚取る)
    def self.execute(process, imgs)
      case process
      when 1 then average(imgs)
      when 2 then mode(imgs)
      when 3 then variance(imgs)
      when 4 then standard_deviation(imgs)
      when 5 then skew(imgs)
      when 6 then kurtosis(imgs)
      when 7 then median(imgs)
      when 8 then percentile_25(imgs)
      when 9 then percentile_75(imgs)
      when 10 then interquartile_range(imgs)
      when 11 then quartile_deviation(imgs)
      when 12 then min(imgs)
      when 13 then max(imgs)
      when 14 then sigma_in_rate_2(imgs)
      when 15 then sigma_out_rate_2(imgs)
      end
    end

    # 処理番号を1つランダムに選択して返す
    def self.set
      rand(1..15)
    end
  end
end
