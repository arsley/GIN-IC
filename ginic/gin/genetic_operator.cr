module GINIC::GIN
  # 遺伝的オペレータをGINに施すためのユーティリティ群
  module GeneticOperator
    # 親個体の遺伝子を複製して返す
    #   ない場合(空文字)は生成する
    def make_child
      make_genotype if genotype.empty?
      genotype.dup
    end

    # この個体(GIN)を複製したものを返す
    def duplicate
      gin = GINIC::GIN::Individual.new(config)
      gin.create_from_genotype(make_child)
      gin
    end

    # 突然変異処理を行う
    #   突然変異率に基づいて遺伝子座を選択し、制約の範囲内で突然変異させる
    #   突然変異処理をしたノードが全て非アクティブノードだった場合は、親個体と同じ適応度として扱う
    #
    # - 文字列処理ではないので進化計算から遠ざかってしまっているかもしれない
    def mutate(parent)
      mutations = 0
      inactives = 0
      nodes.each_with_index do |node, i|
        if operate_mutation(node)
          mutations += 1
          inactives += 1 unless parent.nodes[i].active?
        end
      end
      # puts "M : #{mutations} I : #{inactives}"
      self.fitness = parent.fitness if mutations == inactives
      # puts "child : #{self.fitness} parent : #{parent.fitness}"
    end

    # 各ノードに対応した突然変異処理を実行する
    #   ノードによって入力元とできるIDのレンジを変える必要がある
    def operate_mutation(node)
      case node.class.to_s
      when "GINIC::Node::ImageTransformation"
        node.mutate(mutate_probability, rule_range_image_transformation(node.id))
      when "GINIC::Node::FeatureExtraction"
        node.mutate(mutate_probability, rule_range_feature_extraction)
      when "GINIC::Node::Arithmetic"
        node.mutate(mutate_probability, rule_range_arithmetic(node.id))
      when "GINIC::Node::Output"
        node.mutate(mutate_probability, rule_range_output)
      end
    end
  end
end
