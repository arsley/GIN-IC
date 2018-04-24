module GINIC::Node
  # 出力関係の処理を扱うノードのクラス
  # 各出力ノードにはカテゴリ分類対象クラスの名前が設定される
  # 出力ノードは**必ず**利用されるノードのため、アクティブノードとして設定もする
  class Output
    include Base
    property id, inputs, active, group
    @id : Int32
    @group : String

    # ノードの生成を行う
    # - このinitializeは引数が1つの時に利用される
    def initialize(group_name)
      @id     = Base.node_id
      @inputs = [] of Int32
      @active = false
      @group  = group_name
      set_active

      Base.odd_id
    end

    # ノードの生成を行う
    # - このinitializeは引数が2つの時に利用される
    # - 2つ目の引数は入力元ノードの番号そのものとなっている(複雑な事情により)
    def initialize(group_name, genotype)
      @id     = Base.node_id
      @inputs = [] of Int32
      @active = false
      @group  = group_name
      inputs << genotype.to_i
      set_active

      Base.odd_id
    end

    # ノード内容の初期設定を行う
    # - 入力元は1つのみ取る
    def init_node(range)
      inputs << rand(range)
    end

    # 対象ノードを遺伝子型(文字列)で表現する
    # - 出力ノードは入力元1のみを返す
    def to_genotype
      "#{inputs[0]},"
    end

    # 突然変異処理を行う
    #   処理内容、入力元1、入力元2のそれぞれについて変異させるか確率を取る
    #   突然変異処理をした場合はtrueを、しなかった場合はfalseを返す
    def mutate(probability, range)
      if rand <= probability
        self.inputs[0] = rand(range)
        return true
      end
      false
    end
  end
end
