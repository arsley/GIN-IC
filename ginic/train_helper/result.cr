module GINIC::TrainHelper
  # 処理内容や結果の表示を行うためのユーティリティ群
  # 結果出力も含める
  module Result
    # 全体の結果表示を行う
    #
    # 1世代目は親個体のみを結果表示し、
    # それ以降の世代は子個体の評価値と選択された個体を表示する
    #   選択された個体を明示することで親個体の表示を省いている
    def show_result(choosed)
      puts current_generation != 1 ? result_particular_generation(choosed) : result_first_generation
    end

    # 結果表示 for 第1世代
    def result_first_generation
      <<-RESULT
      Generation : #{current_generation}
      | Parent Fitness : #{parent_gin.fitness} Actives : #{parent_gin.actives}
      -----------------------------------------
      RESULT
    end

    # 結果表示 for 第2世代以降
    def result_particular_generation(choosed)
      <<-RESULT
      Generation : #{current_generation}
      | Child1 Fitness : #{children_gin[0].fitness} Actives : #{children_gin[0].actives}
      | Child2 Fitness : #{children_gin[1].fitness} Actives : #{children_gin[1].actives}
      | Child3 Fitness : #{children_gin[2].fitness} Actives : #{children_gin[2].actives}
      | Parent as next generation is **#{show_choosed(choosed.not_nil!)}**
      -----------------------------------------
      RESULT
    end

    # 次の親個体として選択されたものを返す
    #
    # -1の時は親個体据え置きの場合としている
    def show_choosed(choosed)
      return "NOT CHANGED(Parent)" if choosed == -1
      "Child#{choosed + 1}"
    end

    # グラフ作成のための出力
    #
    # 出力されるテキストデータ名は'graph.txt'で統一とする
    #
    # 以下の内容で記述する
    # 世代目 評価値
    def out_result_for_graph(generation, choosed)
      choosed_gin = choosed != -1 ? children_gin[choosed.not_nil!] : parent_gin
      `echo '#{generation} #{choosed_gin.fitness}' >> graph.txt`
    end

    # 結果をファイルへ出力する
    #
    # `#result_info_execution`
    #
    # *filename* : 出力するファイル名 .txtとして保存する
    def out_result(filename)
      result = ""
      result += result_last_train
      result += "\n----------------------------------------\n"
      result += result_info_execution
      File.write(filename + ".txt", result)
    end

    # 学習にて得られたGINの情報を出力する
    # 保存させるGINは最終世代における評価値が最良のもの
    #
    # GINの情報として以下のものを返す
    # - アクティブノード数
    # - 適応度
    # - 遺伝子
    def result_last_train
      <<-RESULT
      **Best GIN of last generation**
      Actives  : #{parent_gin.actives}
      Fitness  : #{parent_gin.fitness}
      Genotype : #{parent_gin.to_genotype}
      RESULT
    end

    # 学習に用いた実行処理系の情報を出力する
    #
    # 実行処理系の情報として以下のものを返す
    # - 終了条件世代数
    # - 突然変異率
    def result_info_execution
      <<-RESULT
      **Infomation of Execution**
      End of generation  : #{end_generation}
      Mutate Probability : #{mutate_probability}
      RESULT
    end
  end
end
