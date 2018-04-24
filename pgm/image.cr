module PGM
  # 画像情報を保持するためのクラス
  class Image
    # *@itype* : 画像のタイプ(P5はバイナリ形式のグレースケール画像を示す)
    # *@width* : 画像の幅
    # *@height* : 画像の高さ
    # *@pixels* : 画素データ
    # *@histogram* : 各画素値(256段階: 0 - 255)に対する出現回数のヒストグラム
    # *@maximum* : 最大階調値
    property itype, width, height, pixels, histogram, maximum

    def initialize
      @itype  = "P5"
      @width  = 0
      @height = 0
      @pixels = [] of Array(UInt8)
      @histogram = [] of Int32
      @maximum = -1
    end

    # 最大階調値を求める
    #
    # 存在する場合はその値を返す
    def max
      return maximum unless maximum == -1
      m = -1
      height.times do |y|
        width.times do |x|
          m = Math.max(m, pixel_i(y, x))
        end
      end
      self.maximum = m
    end

    # 指定位置における画素を返す
    # - 範囲外の画素を補完する
    def pixel(y, x)
      x = x < 0 ? 0 : x >= width ? (width - 1) : x
      y = y < 0 ? 0 : y >= height ? (height - 1) : y
      pixels[y][x]
    end

    # 指定位置における画素を整数(Int32)で返す
    # - 範囲外の画素を補完する
    def pixel_i(y, x)
      pixel(y, x).to_i
    end

    # 指定位置における画素を浮動小数(倍精度)で返す
    # - 範囲外の画素を補完する
    def pixel_f64(y, x)
      pixel(y, x).to_f64
    end

    # 画像のヒストグラムを返す
    # ない場合は生成する
    #
    # histogram は インデックス:階調値 要素:出現回数 とする配列である
    def histogramake
      return histogram unless histogram.empty?
      self.histogram = Array.new(256, 0)
      pixels.each do |row|
        row.each { |pixel| self.histogram[pixel] += 1 }
      end
      histogram
    end

    # 画像を書き出す
    def write(filename)
      File.open(filename + ".pgm", "w") do |f|
        f.puts(itype)
        f.puts("#{width} #{height}")
        f.puts(max)
        height.times do |y|
          width.times do |x|
            f.write_byte(pixels[y][x])
          end
        end
      end
    end
  end
end
