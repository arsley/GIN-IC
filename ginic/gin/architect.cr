module GINIC::GIN
  # 遺伝子からGIN(個体)を生成するためのユーティリティ群
  module Architect
    # 遺伝子からノード群を生成する
    #   各ノード数を初期化してから実行する `GINIC::GIN::Individual.new`
    def create_from_genotype(genotype)
      nodes.clear
      GINIC::Node::Base.reset_id
      node_counter = 0
      group_name_index = 0
      genotype = genotype.split(',')
      genotype.each_slice(3) do |gene|
        case
        when gene_image_transformation?(node_counter)
          nodes << GINIC::Node::ImageTransformation.new(gene)
        when gene_feature_extraction?(node_counter)
          nodes << GINIC::Node::FeatureExtraction.new(gene)
        when gene_arithmetic?(node_counter)
          nodes << GINIC::Node::Arithmetic.new(gene)
        when gene_output?(node_counter)
          gene.each do |g|
            nodes << GINIC::Node::Output.new(groups[group_name_index], g)
            group_name_index += 1
          end
        end
        node_counter += 1
      end
    end

    # 遺伝子におけるその位置は画像変換ノードか否かを確認する
    def gene_image_transformation?(index)
      image_transformation_range.includes? index
    end

    # 遺伝子におけるその位置は特徴量抽出ノードか否かを確認する
    def gene_feature_extraction?(index)
      feature_extraction_range.includes? index
    end

    # 遺伝子におけるその位置は演算ノードか否かを確認する
    def gene_arithmetic?(index)
      arithmetic_range.includes? index
    end

    # 遺伝子におけるその位置は出力ノードか否かを確認する
    def gene_output?(index)
      output_range.includes? index
    end

    # GIN(個体)における画像変換ノードが取りうるノードIDの範囲を返す
    def image_transformation_range
      0...(it_count)
    end

    # GIN(個体)における特徴量抽出ノードが取りうるノードIDの範囲を返す
    def feature_extraction_range
      it_count...(it_count + fe_count)
    end

    # GIN(個体)における演算ノードが取りうるノードIDの範囲を返す
    def arithmetic_range
      (it_count + fe_count)...(it_count + fe_count + a_count)
    end

    # GIN(個体)における出力ノードが取りうるノードIDの範囲を返す
    def output_range
      (it_count + fe_count + a_count)...(it_count + fe_count + a_count + o_count)
    end
  end
end
