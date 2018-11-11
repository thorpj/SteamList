module SteamList
  class Config
    require 'yaml'

    attr_accessor :config
    def initialize
      @config = { }
    end

    def [](v)
      @config[v]
    end
    def []=(k,v)
      @config[k] = v
    end

  end
end