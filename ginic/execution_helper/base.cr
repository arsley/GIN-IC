module GINIC::ExecutionHelper
  module Base
    # カテゴリ分類実験用のディレクトリ
    EXP_DATA_PATH     = "./experience/data/"
    EXP_RESULT_PATH   = "./experience/result/"
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
      data << PGM.load(EXP_DATA_PATH + img)
    end

    # 分類結果へ書き込む
    #
    # /experience/result/classified/img へ data[0](元画像)を書き出す
    def write_image(classified, img)
      data[0].write(%(#{EXP_RESULT_PATH + classified}/#{img}))
    end

    # 処理データの削除を行う
    # 各画像を分類するごとに、各ノードにおける出力値を初期化させるためのもの
    def clear_data
      data.clear
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

    # 実行系をまとめたもの
    def do_operation(gin)
      experiences.not_nil!.each do |exp_data|
        clear_data
        load_image(exp_data)
        classified = operate(gin)
        show_progress(exp_data, classified)
      end
    end
  end
end
