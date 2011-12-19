module Reconciler
  module SecondOne  
    class Base < ActiveRecord::Base
      env = ENV['RECONCILER_ENV'] || 'development'
 
      @hsecond_one_conf = YAML::load(File.open(File.expand_path(File.dirname(__FILE__) + "../../config/second_one.yml")))[env]
      establish_connection @hsecond_one_conf

      self.abstract_class = true #ensure ActiveRecord doesn't treat this as STI

      def self.model_name
       ActiveSupport::ModelName.new(self.name.split("::").last)
      end
    end
  
    class Reconciler::SecondOne::Blog < Reconciler::SecondOne::Base
    end
    
  end
end