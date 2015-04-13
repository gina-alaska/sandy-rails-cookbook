module Sandy
  module Config
    def self.environment_for(env)
      env.inject({}) do |result, (k,v)|
        result[k.upcase] = v

        result
      end
    end
  end
end
