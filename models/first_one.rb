module Reconciler
  
  module FirstOne  
    class Base < ActiveRecord::Base
      env = ENV['RECONCILER_ENV'] || 'development'
      
      @first_one_conf = YAML::load(File.open(File.expand_path(File.dirname(__FILE__) + "../../config/first_one_database.yml")))[env]
      establish_connection @first_one_conf

      self.abstract_class = true #ensure ActiveRecord doesn't treat this as STI

      def self.model_name
       ActiveSupport::ModelName.new(self.name.split("::").last)
      end
    end

    class Reconciler::FirstOne::Blog < Reconciler::FirstOne::Base
    end
  end
end