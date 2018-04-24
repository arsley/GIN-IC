module GINIC::Node
  # 画像変換を扱うノードのクラス
  class ImageTransformation
    include Base
    # @processing : 処理内容の番号 `GINIC::Processing::ImageTransformation`
    property id, inputs, active, processing
    @id : Int32

    # ノードの生成を行う
    # - このinitializeは遺伝子を引数に取らない場合に利用される
    def initialize
      @id     = Base.node_id
      @inputs = [] of Int32
      @active = false
      @processing = 0

      Base.odd_id
    end

    # ノードの生成を行う
    # - このinitializeは遺伝子からノードを生成する場合に利用される
    def initialize(genotype)
      @id     = Base.node_id
      @inputs = [] of Int32
      @active = false
      @processing = genotype[0].to_i
      inputs << genotype[1].to_i << genotype[2].to_i

      Base.odd_id
    end

    # ノード内容の初期設定を行う
    # 1. 入力元を有効範囲内(range)から2つ選択する `GINIC::Node::Base#init_node`
    # 2. 処理内容を1つ決定する
    #
    # 遺伝子から生成した場合はこの処理は必要ない
    def init_node(range)
      super
      self.processing = GINIC::Processing::ImageTransformation.set
    end

    # 対象ノードを遺伝子型(文字列)で表現する
    # - 処理内容、入力元1、入力元2 の順番で返す
    def to_genotype
      "#{processing},#{inputs[0]},#{inputs[1]},"
    end

    # ノードに割り振られた処理を実行しその結果を返す
    # - GINIC::Node::ImageTransformation#execute では PGM::Image を返す
    #
    # *imgs* : PGM::Image の画像2つが格納された配列
    def execute(imgs)
      GINIC::Processing::ImageTransformation.execute(processing, imgs)
    end

    # 突然変異処理を行う
    #   処理内容、入力元1、入力元2のそれぞれについて変異させるか確率を取る
    #   突然変異処理をした場合はtrueを、しなかった場合はfalseを返す
    def mutate(probability, range)
      did? = false
      3.times do |i|
        if rand <= probability
          did? = true
          case i
          when 0
            self.processing = GINIC::Processing::ImageTransformation.set
          when 1
            self.inputs[0] = rand(range)
          when 2
            self.inputs[1] = rand(range)
          end
        end
      end
      did?
    end
  end
end
