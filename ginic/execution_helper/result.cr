module GINIC::ExecutionHelper
  # 処理内容や結果の表示を行うためのユーティリティ群
  # 結果出力も含める
  module Result
    # 読み込んだ画像がどのクラスへ分類されたか表示する
    #
    # result.txtへ追記もさせる
    def show_progress(img, classified)
      result = "#{img} → #{classified}"
      puts result
      `echo #{result} >> result.txt`
    end

    # 実行対象のGINICのノード内容を出力する
    #
    # アクティブノードのみをIDの若い順に出力する
    def out_ginicnodes_info
      exp_gin.nodes.each do |node|
        next unless node.active?
        out_info = "ID : #{node.id} Info : #{node.to_genotype}"
        `echo #{out_info} >> ginicnodes_info.txt`
      end
    end
  end
end
