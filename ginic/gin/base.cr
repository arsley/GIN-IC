module GINIC::GIN
  # Genetic Image Netword を統括する基幹クラス
  abstract class Base
    # 型のエイリアス
    # @nodes に代入可能なクラスをまとめておくための型宣言
    alias NODES = GINIC::Node::ImageTransformation |
                  GINIC::Node::FeatureExtraction |
                  GINIC::Node::Arithmetic |
                  GINIC::Node::Output
    alias CONFIG = NamedTuple(it_count: Int32, fe_count: Int32, a_count: Int32, \
                              o_count: Int32, groups: Array(String))

    # @config   : 初期化時に利用したプロパティ
    # @it_count : 画像変換ノード数 (it = image transformationの略)
    # @fe_count : 特徴量抽出ノード数 (fe = feature extraxtionの略)
    # @a_count  : 演算ノード数 (a = arithmeticの略)
    # @o_count  : 出力ノード数 (o = outputの略)
    # @groups   : 画像分類先カテゴリの名前をまとめた配列
    # @nodes    : このGINにて定義されている全ノードをまとめた配列
    property it_count, fe_count, a_count, o_count, groups, nodes
    @it_count : Int32
    @fe_count : Int32
    @a_count  : Int32
    @o_count  : Int32
    @groups   : Array(String)

    # GINの初期設定を行いインスタンス化する
    # ノードの生成までは行わない
    #
    # *config* には以下の要素が含まれる
    # - *it_count* : Int32 画像変換ノード数
    # - *fe_count* : Int32 特徴量抽出ノード数
    # - *a_count*  : Int32 演算ノード数
    # - *o_count*  : Int32 出力ノード数
    # - *groups*   : Array(String) 分類カテゴリ名称
    def initialize(config)
      @it_count = config[:it_count]
      @fe_count = config[:fe_count]
      @a_count  = config[:a_count]
      @o_count  = config[:o_count]
      @groups   = config[:groups]
      @nodes    = [] of NODES
    end

    # インスタンス生成時のプロパティに基づいて処理ノードの生成と格納を行う
    def create_nodes
      it_count.times { nodes << GINIC::Node::ImageTransformation.new }
      fe_count.times { nodes << GINIC::Node::FeatureExtraction.new }
      a_count.times  { nodes << GINIC::Node::Arithmetic.new }
      o_count.times  { |i| nodes << GINIC::Node::Output.new(groups[i]) }
    end

    # 全ノードの初期化を行う
    def init_nodes
      nodes.each do |node|
        case node.class.to_s
        when "GINIC::Node::ImageTransformation"
          node.init_node(rule_range_image_transformation(node.id))
        when "GINIC::Node::FeatureExtraction"
          node.init_node(rule_range_feature_extraction)
        when "GINIC::Node::Arithmetic"
          node.init_node(rule_range_arithmetic(node.id))
        when "GINIC::Node::Output"
          node.init_node(rule_range_output)
        end
      end
    end

    # 画像変換ノードが入力元として選択可能なIDのレンジを返す
    # *node_id* 呼び出し元のノードID
    def rule_range_image_transformation(node_id)
      0..(node_id - 1)
    end

    # 特徴量抽出ノードが入力元として選択可能なIDのレンジを返す
    def rule_range_feature_extraction
      0..it_count
    end

    # 演算ノードが入力元として選択可能なIDのレンジを返す
    # *node_id* 呼び出し元のノードID
    def rule_range_arithmetic(node_id)
      (1 + it_count)..(node_id - 1)
    end

    # 出力ノードが入力元として選択可能なIDのレンジを返す
    def rule_range_output
      (1 + it_count)..(it_count + fe_count + a_count)
    end

    # GINのパラメータを返す
    def config
      {
        it_count: it_count,
        fe_count: fe_count,
        a_count: a_count,
        o_count: o_count,
        groups: groups
      }
    end
  end
end
