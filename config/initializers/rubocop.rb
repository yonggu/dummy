$cops_hash = RuboCop::Cop::Cop.all.inject({}) do |hash, cop|
               hash[cop.cop_name] = cop
               hash
             end
