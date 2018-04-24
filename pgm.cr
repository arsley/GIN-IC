# .pgm形式(Binary)画像の読み込みライブラリ
module PGM
  # 画像を読み込みImageのインスタンスを返す
  #
  # ```
  # image = PGM.load("path/to/file.pgm")
  # ```
  def self.load(filename : String)
    pgm = Image.new
    counter = 0
    low = [] of UInt8

    File.open(filename) do |f|
      t, s, m = f.read_line, f.read_line, f.read_line
      w, h = s.split(" ")
      pgm.width, pgm.height = w.to_i, h.to_i

      f.each_byte do |b|
        low << b
        counter += 1
        if counter % pgm.width == 0
          pgm.pixels << low.dup
          low.clear
        end
      end
    end
    pgm
  end

  # w(Width) x h(Height) の大きさのスタブ画像(0埋め)作成する
  #
  # ```
  # stab_img = PGM.create_stab(64, 64)
  # ```
  def self.create_stab(w, h)
    stab = Image.new
    stab.width  = w
    stab.height = h
    stab.pixels = Array.new(h) { Array.new(w, 0_u8) }
    stab
  end
end
