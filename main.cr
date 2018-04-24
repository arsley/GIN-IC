require "./ginic"

########## 学習サンプル #########
# e = {
#   end_generation: 112500,
#   mutate_probability: 0.02,
#   train?: true,
#   gin_params: {
#     it_count: 100,
#     fe_count: 100,
#     a_count: 100,
#     o_count: 6,
#     groups: %w[Bark Food Grass Metal Stone Fabric]
#   }
# }
#
# main = GINIC.train_new(e)
# main.train
# main.out_result("test")

######### 遺伝子実行サンプル ##########
# c = {
#   it_count: 100,
#   fe_count: 100,
#   a_count: 100,
#   o_count: 6,
#   groups: %w[Bark Food Grass Metal Stone Fabric]
# }
# g = %(genotype...)
#
# expr = GINIC.execution_new(c, g)
# expr.execute
