module GINIC::Node
  # 各ノードの基幹となるモジュール
  #
  # @@node_id は冗長ではあるがこの基幹モジュールを経由して管理することとする
  module Base
    # モジュール変数
    # ノードに割り振るID
    @@node_id = 1

    # ノードへ割り振るIDを初期化する
    # - 遺伝子からノードを生成する場合に利用する
    def self.reset_id
      @@node_id = 1
    end

    # ノードへ割り振るIDを更新する
    def self.odd_id
      @@node_id += 1
    end

    # ノードに割り振ることのできるIDを返す
    def self.node_id
      @@node_id
    end

    # ノードの生成を行う
    # 引数を取る場合の処理は各ノードクラスを参照
    # - `GINIC::Node::ImageTransformation`
    # - `GINIC::Node::FeatureExtraction`
    # - `GINIC::Node::Arithmetic`
    # - `GINIC::Node::Output`
    # def initialize(*args)
    #   @id     = Base.node_id
    #   @inputs = [] of Int32
    #   @active = false
    #
    #   Base.odd_id
    # end

    # ノード内容の初期設定を行う
    # - 入力元を有効範囲内(入力元を有効範囲内(range)から2つ選択する
    #
    # 処理内容は各ノードクラスにて設定を行う
    # - `GINIC::Node::ImageTransformation#init_node`
    # - `GINIC::Node::FeatureExtraction#init_node`
    # - `GINIC::Node::Arithmetic#init_node`
    def init_node(range)
      inputs << rand(range) << rand(range)
    end

    # 入力元ノードを設定する
    def add_input(node_id)
      inputs << node_id
    end

    # アクティブノード化(フラグ付け)を行う
    def set_active
      self.active = true
    end

    # 対象がアクティブノードであればtrue、そうでなければfalse
    def active?
      active
    end

    # アクティブノード判定、フラグ付けを行う
    #   `GINIC::GIN:Base#checkup_active` のヘルパーとして利用する
    #   出力ノードから入力ノード(存在しないがID = 0)まで逆トレースを行い、
    #   その間に通ったノードをアクティブノードとする
    #
    #   *nodes* はGINにおける全ノード(Array)
    def checkup_active(nodes)
      set_active
      inputs.each do |node_id|
        nodes[node_id - 1].checkup_active(nodes) unless node_id.zero?
      end
    end

    # :nodoc:
    abstract def to_genotype

    # :nodoc:
    abstract def mutate(probability, range)
  end
end
