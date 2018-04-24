module GINIC
  # Image Classification(画像カテゴリ分類処理)を統括するクラス
  #
  # 教師セットからGAを用いて学習を行なうためのクラス
  class Train
    include GINIC::TrainHelper::Base
    include GINIC::TrainHelper::Result

    # 処理データ配列用の型宣言
    alias DATA = PGM::Image | Float64
    # 個体(individual)の型宣言
    alias INDI = GINIC::GIN::Individual

    # *@end_generation*     : 終了条件とする世代数
    # *@current_generation* : 現在の世代数(何世代目か)
    # *@mutate_probability* : 突然変異率
    # *@parent_gin*         : 親個体としてのGIN
    # *@children_gin*       : 子個体のGIN
    # *@teachers*           : 教師画像データの名前配列
    # *@data*               : 各ノードにおける処理データ
    property end_generation, current_generation, mutate_probability,
             parent_gin, children_gin, teachers, data
    @end_generation     : Int32
    @mutate_probability : Float64
    @parent_gin         : INDI
    @teachers           : Array(String) | Nil

    # 実行処理系の初期化を行う
    #
    # *config* には以下の要素が含まれる
    # - *end_generation* : Int32 最終的な終了条件とする世代数
    # - *mutate_probability* : Float64 突然変異率
    # - *train?* : Bool 教師データを読み込むかどうか
    # - *gin_params* : `GINIC::GIN::Base::CONFIG` GIN生成用のパラメータ
    def initialize(config)
      @end_generation     = config[:end_generation]
      @current_generation = 1
      @mutate_probability = config[:mutate_probability]
      @parent_gin         = init_parent(config[:gin_params])
      @children_gin       = [] of INDI
      @teachers           = config[:train?] ? obtain_teachers : nil
      @data               = [] of DATA
    end

    # 親個体としてのGINを生成する
    # これには以下の処理を含む
    # - ノードの生成
    # - ノードの初期化
    # - アクティブノードのフラグ付け
    # - アクティブノード数のカウント
    def init_parent(config)
      gin = GINIC::GIN::Individual.new(config)
      gin.create_nodes
      gin.init_nodes
      gin.checkup_active
      gin.countup_active
      gin.mutate_probability = mutate_probability
      gin
    end

    # 生成された子個体群の初期設定を行う
    #
    # アクティブノードのフラグ付け及び数え上げを行う
    def init_children
      children_gin.each do |child_gin|
        child_gin.checkup_active
        child_gin.countup_active
      end
    end

    # 学習用データの取得を行う
    # 指定されたディレクトリに配置されている画像データの名前を取得する
    def obtain_teachers
      `ls #{TRAIN_DATA_PATH}`.chomp.split("\n")
    end

    # 教師セットから画像分類アルゴリズム構築を行う
    def train
      operate_to_parent
      choosed = -1
      loop do
        out_result_for_graph(current_generation, choosed)
        show_result(choosed)
        break if current_generation >= end_generation
        _next
        migrate
        init_children
        operate_to_children
        choosed = choose
      end
    end
  end
end
