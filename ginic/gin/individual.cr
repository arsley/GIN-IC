module GINIC::GIN
  # GINを遺伝的アルゴリズムにおける個体として扱うためのクラス
  # 進化計算に関連する要素を持つ
  class Individual < Base
    include GINIC::GIN::Architect
    include GINIC::GIN::GeneticOperator

    # *@genotype* : 遺伝子型
    # *@fitness*  : 適応度
    # *@corrects* : このGINにて正しくクラス分けできた画像の枚数
    # *@actives*  : このGINにおけるアクティブノード数
    # *@mutate_probability* : 突然変異率
    property genotype, fitness, corrects, actives, mutate_probability

    # `GINIC::GIN::Base`
    def initialize(config)
      super
      @genotype = ""
      @fitness  = -1.0
      @corrects = 0
      @actives  = 0
      @mutate_probability = -1.0 # ありえない値として代入する `GINIC::Execution#operate_to_children`
    end

    # 生成されたGINにおけるアクティブノード(出力に繋がりうるノード)にフラグ付けを行う
    # `GINIC::Node::Base#checkup_active`
    def checkup_active
      nodes.last(o_count).each do |o_node|
        o_node.checkup_active(nodes)
      end
    end

    # GINにおけるアクティブノード数をカウントする
    def countup_active
      self.actives = 0
      nodes.each { |node| self.actives += 1 if node.active? }
    end

    # 画像の分類結果をカウントする
    #   正しい画像に分類した時に実行させる
    def correct
      self.corrects += 1
    end

    # 適応度計算を行う
    def calculate
      self.fitness = corrects.to_f64 + 1.0 / actives.to_f64
    end

    # GINを表現する遺伝子型(文字列)を生成する
    # - 生成した遺伝子型を返す
    def make_genotype
      genotype = ""
      nodes.each { |node| genotype += node.to_genotype }
      self.genotype = genotype.chomp(",")
    end

    # 遺伝子型を返す
    # ない場合は生成する
    def to_genotype
      make_genotype if genotype.empty?
      genotype
    end
  end
end
