module GINIC::TrainHelper
  module Base
    # 教師画像のディレクトリ
    TRAIN_DATA_PATH   = "./train/teacher/"
    # 画像名からカテゴリ名を切り出すための正規表現
    IMAGE_GROUP_REGEX = /^[a-zA-Z]+/

    # つじつま合わせの型キャスト
    alias PROCESS = GINIC::Node::ImageTransformation |
                    GINIC::Node::FeatureExtraction |
                    GINIC::Node::Arithmetic
    alias OUT     = GINIC::Node::Output

    # 画像データの読み込み
    # 処理データ配列へ格納する
    def load_image(img)
      data << PGM.load(TRAIN_DATA_PATH + img)
    end

    # 処理データの削除を行う
    # 各画像を分類するごとに、各ノードにおける出力値を初期化させるためのもの
    def clear_data
      data.clear
    end

    # 子個体データの削除を行う
    # 評価・選択後は初期化(空)にする
    def clear_children
      children_gin.clear
    end

    # (単一の)画像データをアルゴリズムへ適応し、分類先クラスを返す
    def operate(gin)
      classified = "Category"
      value      = Float64::NAN
      gin.nodes.each do |node|
        if node.class == GINIC::Node::Output
          value, classified = operate_classify(value.as(Float64), classified, node.as(OUT))
        else
          data << operate_process(node).not_nil!
        end
      end
      classified
    end

    # 出力ノードにおける数値比較によって画像カテゴリを決定する
    # - このアルゴリズムは出力ノード値の大小によって画像を分類する
    def operate_classify(value, classified, node)
      new_val = data[node.inputs[0]].as(Float64)
      if value.nan? || value < new_val
        [ new_val, node.group ]
      else
        [ value, classified ]
      end
    end

    # 各ノードに割り当てられた処理を、ノードの状態(active?)に基づいて実行しその結果を返す
    # 対象がアクティブノードでない場合は0を返す
    def operate_process(node)
      node.active? ? node.as(PROCESS).execute([data[node.inputs[0]], data[node.inputs[1]]]) : 0.0
    end

    # 正しいクラスに分類したか判定を行う
    # *teacher* は画像データファイル名のため、先頭のクラス名を切り出して判定する
    def evaluate(teacher, classified)
      teacher.match(IMAGE_GROUP_REGEX).not_nil![0] == classified
    end

    # 実行系をひとまとめにしたもの
    def do_operation(gin)
      teachers.not_nil!.each do |teacher|
        clear_data
        load_image(teacher)
        classified = operate(gin)
        gin.correct if evaluate(teacher, classified)
      end
    end

    # 親個体へ実行処理を施す
    #
    # この処理は第1世代のみ利用される
    # 処理内容の詳細については `GINIC::Execution#operate_to_children` を参考
    def operate_to_parent
      do_operation(parent_gin)
      parent_gin.calculate
    end

    # 子個体群に対して評価処理を実行する
    #
    # 評価処理は以下の通り
    # 1. 子個体を3つ生成(突然変異)
    # 2. それぞれを評価
    # 3. より良い個体を選択し親個体として置き換える
    #
    # 評価値が存在する場合は実行しない
    #   突然変異にてアクティブノードに変更が加えられなかった時
    def operate_to_children
      children_gin.each do |child_gin|
        if child_gin.fitness < 0.0
          do_operation(child_gin)
          child_gin.calculate
        end
      end
    end

    # 世代数を1つ進める
    def _next
      self.current_generation += 1
    end

    # 次世代への移行処理を行う
    # 突然変異処理を施した個体を3つ生成する
    #
    # 子個体群を生成し、評価可能な状態にする
    def migrate
      clear_children
      3.times do
        child_gin = parent_gin.duplicate
        child_gin.mutate_probability = mutate_probability
        child_gin.mutate(parent_gin)
        children_gin << child_gin
      end
    end

    # 親個体+子個体群から適応度(評価値)が最も良いものを選択し、親個体として置き換える
    #
    # 子個体の評価値が親個体より小さい場合、
    # 置き換えは行わず親個体は据え置きのままとする
    # - この時の返り値は -1 とする
    #
    # 置き換えがあった場合はそのインデックスを返す
    def choose
      choosed_gin = children_gin.max_by { |child_gin| child_gin.fitness }
      return -1 if choosed_gin.fitness < parent_gin.fitness
      self.parent_gin = choosed_gin
      children_gin.index(choosed_gin)
    end
  end
end
