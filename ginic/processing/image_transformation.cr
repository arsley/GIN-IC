module GINIC::Processing
  # 画像変換処理をまとめたモジュール
  # - 常に引数として画像データ2つを取り、1つ目のみに処理を適応させる
  # - ただし2つ目を必要とする処理もある
  #
  # *imgs* には `PGM::Image` をとる
  module ImageTransformation
    alias IMG = PGM::Image

    # スタブ画像を返す
    #
    # 実験を行いやすくするために固定のメソッドを作るのではなく、
    # 内部を書き換えることで自由なサイズの画像を生成できる形にする
    def self.stab
      # width, heightを画像サイズに合わせて書き換える
      PGM.create_stab(width, height)
    end

    # 2値化
    #
    # 基本的にこのメソッドは利用しない
    # 閾値が指定された次のメソッドを利用する
    # - `#thresholding_50`
    # - `#thresholding_100`
    # - `#thresholding_150`
    # - `#thresholding_200`
    def self._thresholding(img, threshold)
      img = img.as(IMG)
      img_processed = stab
      max_brightness = 255_u8
      img.height.times do |h|
        img.width.times do |w|
          img_processed.pixels[h][w] = img.pixels[h][w] >= threshold ? max_brightness : 0_u8
        end
      end
      img_processed
    end

    def self.thresholding_50(imgs)
      _thresholding(imgs[0], 50)
    end

    def self.thresholding_100(imgs)
      _thresholding(imgs[0], 100)
    end

    def self.thresholding_150(imgs)
      _thresholding(imgs[0], 150)
    end

    def self.thresholding_200(imgs)
      _thresholding(imgs[0], 200)
    end

    # 3x3内の平均値(平滑化)
    def self.mean(imgs)
      img = imgs[0].as(IMG)
      img_processed = stab
      img.height.times do |y|
        img.width.times do |x|
          sum = 0
          (-1..1).each do |i|
            (-1..1).each do |j|
              sum += img.pixel_i(y + i, x + j)
            end
          end
          img_processed.pixels[y][x] = (sum / 9).to_u8
        end
      end
      img_processed
    end

    # 3x3内の中央値(平滑化)
    def self.median(imgs)
      img = imgs[0].as(IMG)
      img_processed = stab
      img.height.times do |y|
        img.width.times do |x|
          square = [] of UInt8
          (-1..1).each do |i|
            (-1..1).each do |j|
              square << img.pixel(y + i, x + j)
            end
          end
          img_processed.pixels[y][x] = square.sort[4]
        end
      end
      img_processed
    end

    # 3x3の最小値
    def self.min(imgs)
      img = imgs[0].as(IMG)
      img_processed = stab
      img.height.times do |y|
        img.width.times do |x|
          min = 255
          (-1..1).each do |i|
            (-1..1).each do |j|
              min = img.pixel_i(y + i, x + j) if min > img.pixel_i(y + i, x + j)
            end
          end
          img_processed.pixels[y][x] = min.to_u8
        end
      end
      img_processed
    end

    # 3x3の最大値
    def self.max(imgs)
      img = imgs[0].as(IMG)
      img_processed = stab
      img.height.times do |y|
        img.width.times do |x|
          max = 0
          (-1..1).each do |i|
            (-1..1).each do |j|
              max = img.pixel_i(y + i, x + j) if max < img.pixel_i(y + i, x + j)
            end
          end
          img_processed.pixels[y][x] = max.to_u8
        end
      end
      img_processed
    end

    # ソーベルフィルタによる1次微分
    # *option = 1* : 横方向
    # *option = 2* : 縦方向
    # *option = 3* : 微分の大きさ
    #
    # 基本的にこれは実行しない
    # どの方向で微分するかをあらかじめ決めた以下のメソッドを利用する
    # - `#sobel_horizontal`
    # - `#sobel_vertical`
    # - `#sobel_mixed`
    def self._sobel(img, option)
      img = img.as(IMG)
      img_processed  = stab
      max_brightness = 255
      strength = 0
      img.height.times do |y|
        img.width.times do |x|
          horizontal = - img.pixel_i(y - 1, x - 1) - 2 * img.pixel_i(y, x - 1) - img.pixel_i(y + 1, x - 1) \
                       + img.pixel_i(y - 1, x + 1) + 2 * img.pixel_i(y, x + 1) + img.pixel_i(y + 1, x + 1)
          vertical = - img.pixel_i(y - 1, x - 1) - 2 * img.pixel_i(y - 1, x) - img.pixel_i(y - 1, x + 1) \
                     + img.pixel_i(y + 1, x - 1) + 2 * img.pixel_i(y + 1, x) + img.pixel_i(y + 1, x + 1)
          case option
          when 1
            strength = horizontal.to_i
          when 2
            strength = vertical.to_i
          when 3
            strength = Math.sqrt(horizontal**2 + vertical**2).to_i
          end
          if strength < 0
            strength = 0
          elsif strength > max_brightness
            strength = max_brightness
          end
          img_processed.pixels[y][x] = strength.to_u8
        end
      end
      img_processed
    end

    def self.sobel_horizontal(imgs)
      _sobel(imgs[0], 1)
    end

    def self.sobel_vertical(imgs)
      _sobel(imgs[0], 2)
    end

    def self.sobel_mixed(imgs)
      _sobel(imgs[0], 3)
    end

    # プリューウィットフィルタによる平均化処理を行う
    #
    # おおよその処理はソーベルフィルタとほぼ変わりない
    #
    # *option = 1* : 横方向
    # *option = 2* : 縦方向
    #
    # `#prewitt_horizontal`
    # `#prewitt_vertical`
    def self._prewitt(img, option)
      img = img.as(IMG)
      img_processed  = stab
      max_brightness = 255
      strength = 0
      img.height.times do |y|
        img.width.times do |x|
          horizontal = - img.pixel_i(y - 1, x - 1) - img.pixel_i(y, x - 1) - img.pixel_i(y + 1, x - 1) \
                       + img.pixel_i(y - 1, x + 1) + img.pixel_i(y, x + 1) + img.pixel_i(y + 1, x + 1)
          vertical = - img.pixel_i(y - 1, x - 1) - img.pixel_i(y - 1, x) - img.pixel_i(y - 1, x + 1) \
                     + img.pixel_i(y + 1, x - 1) + img.pixel_i(y + 1, x) + img.pixel_i(y + 1, x + 1)
          case option
          when 1
            strength = horizontal.to_i
          when 2
            strength = vertical.to_i
          when 3
            strength = Math.sqrt(horizontal**2 + vertical**2).to_i
          end
          if strength < 0
            strength = 0
          elsif strength > max_brightness
            strength = max_brightness
          end
          img_processed.pixels[y][x] = strength.to_u8
        end
      end
      img_processed
    end

    def self.prewitt_horizontal(imgs)
      _prewitt(imgs[0], 1)
    end

    def self.prewitt_vertical(imgs)
      _prewitt(imgs[0], 2)
    end

    # ラプラシアンによる2次微分値
    def self.lightedge(imgs)
      img = imgs[0].as(IMG)
      img_processed = stab
      max_brightness = 255
      img.height.times do |y|
        img.width.times do |x|
          strength = - img.pixel_i(y - 1, x - 1) - img.pixel_i(y - 1, x) - img.pixel_i(y - 1, x + 1) \
                     - img.pixel_i(y, x - 1) + 8 * img.pixel_i(y, x) - img.pixel_i(y, x + 1) \
                     - img.pixel_i(y + 1, x - 1) - img.pixel_i(y + 1, x) - img.pixel_i(y + 1, x + 1)
          if strength < 0
            strength = 0
          elsif strength > max_brightness
            strength = max_brightness
          end
          img_processed.pixels[y][x] = strength.to_u8
        end
      end
      img_processed
    end

    # ラプラシアンによる2次微分値 + max_brightness
    def self.darkedge(imgs)
      img = imgs[0].as(IMG)
      img_processed = stab
      max_brightness = 255
      img.height.times do |y|
        img.width.times do |x|
          strength = - img.pixel_i(y - 1, x - 1) - img.pixel_i(y - 1, x) - img.pixel_i(y - 1, x + 1) \
                     - img.pixel_i(y, x - 1) + 8 * img.pixel_i(y, x) - img.pixel_i(y, x + 1) \
                     - img.pixel_i(y + 1, x - 1) - img.pixel_i(y + 1, x) - img.pixel_i(y + 1, x + 1)
          strength += max_brightness
          if strength < 0
            strength = 0
          elsif strength > max_brightness
            strength = max_brightness
          end
          img_processed.pixels[y][x] = strength.to_u8
        end
      end
      img_processed
    end

    # 平均階調値より暗い画素 => 0
    def self.lightpixel(imgs)
      img = imgs[0].as(IMG)
      img_processed = stab
      average = 0.0
      img.height.times do |y|
        img.width.times do |x|
          average += img.pixels[y][x].to_f / img.width / img.height
        end
      end
      img.height.times do |y|
        img.width.times do |x|
          img_processed.pixels[y][x] = img.pixels[y][x] < average ? 0_u8 : img.pixels[y][x]
        end
      end
      img_processed
    end

    # 平均階調値より明るい画素 => 255
    def self.darkpixel(imgs)
      img = imgs[0].as(IMG)
      img_processed = stab
      average = 0.0
      img.height.times do |y|
        img.width.times do |x|
          average += img.pixels[y][x].to_f / img.width / img.height
        end
      end
      img.height.times do |y|
        img.width.times do |x|
          img_processed.pixels[y][x] = img.pixels[y][x] < average ? 255_u8 : img.pixels[y][x]
        end
      end
      img_processed
    end

    # 反転
    def self.inversion(imgs)
      img = imgs[0].as(IMG)
      img_processed = stab
      img.height.times do |y|
        img.width.times do |x|
          img_processed.pixels[y][x] = 255_u8 - img.pixels[y][x]
        end
      end
      img_processed
    end

    # 差分の絶対値
    # - img1からimg2を引く
    def self.substruct1(imgs)
      img1 = imgs[0].as(IMG)
      img2 = imgs[1].as(IMG)
      img_processed = stab
      img1.height.times do |y|
        img1.width.times do |x|
          img_processed.pixels[y][x] = (img1.pixel_i(y, x) - img2.pixel_i(y, x)).abs.to_u8
        end
      end
      img_processed
    end

    # 差分の絶対値
    # - img2からimg1を引く
    def self.substruct2(imgs)
      img1 = imgs[0].as(IMG)
      img2 = imgs[1].as(IMG)
      img_processed = stab
      img1.height.times do |y|
        img1.width.times do |x|
          img_processed.pixels[y][x] = (img2.pixel_i(y, x) - img1.pixel_i(y, x)).abs.to_u8
        end
      end
      img_processed
    end

    # ガンマ補正フィルタ(γ = 2)
    def self.gamma(imgs)
      gamma = 2.0
      img = imgs[0].as(IMG)
      img_processed = stab
      img.height.times do |y|
        img.width.times do |x|
          img_processed.pixels[y][x] = (255 * (img.pixel_i(y, x) / 255.0)**(1 / gamma)).to_u8
        end
      end
      img_processed
    end

    # 処理をしない
    #
    # 第1引数に格納されている画像を返す
    def self.nop1(imgs)
      imgs[0].as(IMG)
    end

    # 処理をしない
    #
    # 第2引数に格納されている画像を返す
    def self.nop2(imgs)
      imgs[1].as(IMG)
    end

    # 処理番号に対応した画像変換を実行する
    #
    # *process* : 実行したい画像変換メソッドの番号
    # *imgs*    : 画像データ(常に2枚取る)
    def self.execute(process, imgs)
      case process
      when 1 then thresholding_50(imgs)
      when 2 then thresholding_100(imgs)
      when 3 then thresholding_150(imgs)
      when 4 then thresholding_200(imgs)
      when 5 then mean(imgs)
      when 6 then median(imgs)
      when 7 then min(imgs)
      when 8 then max(imgs)
      when 9 then sobel_horizontal(imgs)
      when 10 then sobel_vertical(imgs)
      when 11 then prewitt_horizontal(imgs)
      when 12 then prewitt_vertical(imgs)
      when 13 then sobel_mixed(imgs)
      when 14 then lightedge(imgs)
      when 15 then darkedge(imgs)
      when 16 then lightpixel(imgs)
      when 17 then darkpixel(imgs)
      when 18 then inversion(imgs)
      when 19 then substruct1(imgs)
      when 20 then substruct2(imgs)
      when 21 then gamma(imgs)
      when 22 then nop1(imgs)
      when 23 then nop2(imgs)
      end
    end

    # 処理番号を1つランダムに選択して返す
    def self.set
      rand(1..23)
    end
  end
end
