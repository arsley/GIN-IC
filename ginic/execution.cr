module GINIC
  # Image Classification(画像カテゴリ分類処理)を統括するクラス
  #
  # 学習により得た個体に対して実行処理を行うためのクラス
  class Execution
    include GINIC::ExecutionHelper::Base
    include GINIC::ExecutionHelper::Result

    # 処理データ配列用の型宣言
    alias DATA = PGM::Image | Float64
    # 個体(individual)の型宣言
    alias INDI = GINIC::GIN::Individual

    # *@data*        : データ格納用配列
    # *@exp_gin*     : 実行対象個体
    # *@experiences* : 実行対象画像名配列
    property data, exp_gin, experiences
    @exp_gin            : INDI
    @experiences        : Array(String) | Nil

    # 遺伝子から実行処理系の初期化を行う
    #
    # *config*   : GINのプロパティ(各ノード数)
    # *genotype* : 作成したい個体の遺伝子
    def initialize(config, genotype)
      @exp_gin     = init_gin(config, genotype)
      @experiences = obtain_experiences
      @data        = [] of DATA
    end

    # 実行対象としての個体を作成する
    def init_gin(config, genotype)
      GINIC::GIN::Individual.new(config)
        .tap { |g| g.create_from_genotype(genotype) }
        .tap { |g| g.checkup_active }
        .tap { |g| g.countup_active }
    end

    # 実験用データの取得を行う
    def obtain_experiences
      `ls #{EXP_DATA_PATH}`.chomp.split("\n")
    end

    # 設定されたアルゴリズムを用いて画像カテゴリ分類を行う
    def execute
      do_operation(exp_gin)
    end
  end
end
