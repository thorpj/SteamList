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

    public

    def url(val)
      @config[:url] = val
    end

    def output_filename(val)
      @config[:output_filename] = val
    end

    def output_stdout(val)
      @config[:output_stdout] = val
    end
  end
end