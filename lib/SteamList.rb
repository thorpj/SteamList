require_relative 'SteamList/config'

module SteamList
  require 'httparty'
  require 'nokogiri'
  require 'active_support'
  require 'active_attr'
  require 'active_support/inflector'
  require 'yaml'

  mattr_accessor :configuration
  self.configuration ||= SteamList::Config.new
  def SteamList.config
    yield self.configuration if block_given?
    self.configuration.config
  end
  begin
    require File.expand_path('../config.rb', File.dirname(__FILE__))
  rescue LoadError
  end

  class Scraper
    include ActiveSupport::Inflector
    attr_accessor :games

    def initialize
      config = SteamList.config
      document = HTTParty.get(config[:url])
      @page ||= Nokogiri::HTML(document)
      @table = @page.at('table')
      @games ||= []
      @headings ||= get_headings
      process_table
      pp games

    end


    def convert_heading(string)
      string.strip.downcase.parameterize.underscore.to_sym
    end

    def convert_attribute(attribute)
      attribute = attribute.gsub " Dedicated Server", ""
      attribute.downcase.strip
    end

    def get_headings
      headings = []
      @page.xpath("//th").each do |heading|
        heading = convert_heading(heading.text)
        if !(headings.include? heading)
          headings << heading
        end
      end
      headings
    end

    def process_table
      @page.xpath("//tr").each do |table_row|
        row = process_row table_row.text
        add_game row
      end
    end

    def process_row(row)
      new_row = []
      row = row.strip.split("\n")
      row.each do |r|
        new_row << r.strip
      end
      new_row
    end

    def add_game(attributes)
      game = {}
      if ! (attributes.any? { |attribute| @headings.include? convert_heading(attribute)})
        if !(@games.any? { |game| game[:server] == convert_attribute(attributes[0]) })
          attributes.zip(@headings).each do |attribute, heading|
            attribute = convert_attribute(attribute)
            game[heading] = attribute || ""
          end
        @games << game
        end
      end
    end

    def write_to_file(filename, data)
      File.open(filename, 'w') do |file|
        file.write(data.to_yaml)

      end
    end

    def find_id(name)
      found = {}
      @games.each do |game|
        if game[:server] == name.downcase and found == {}
          found = game
        end
      end
      found
    end

  end
end
