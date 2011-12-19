require 'rubygems'
require "bundler/setup"
require 'active_record'
require 'redis'

$LOAD_PATH << './models'

require 'first_one'
require 'second_one'

class Reconcile
  attr_accessor :env, :redis_conf, :redis
  
  def initialize(env)
    @env = env || 'development'
    @redis_conf = YAML::load(File.open(File.dirname(__FILE__) + '/config/redis.yml'))[env]
    @redis = Redis.new(:host => redis_conf["host"], :port => redis_conf["port"])
  end
  
  def run_all
    blogs
    #...other methods here...
  end
  
  
  def blogs
    p "Running blogs..."
    Reconciler::FirstOne::Blog.all.each {|a| redis.sadd(:blogs_first_one, a.blog_key)}
    Reconciler::SecondOne::Blog.all.each {|a| redis.sadd(:blogs_second_one, a.blog_key)}
    p "Union of all:        #{redis.sunionstore(:all_blogs, :blogs_first_one, :blogs_second_one)}"
    p "Not in second_one:     #{redis.sdiffstore(:blogs_remove_from_first_one, :all_blogs, :blogs_second_one)}"
    p "Missing from first_one: #{redis.sdiffstore(:blogs_add_to_first_one, :all_blogs, :blogs_first_one)}"
  end
  
  
  def empty_all_stats
    keys = [ 
             :all_blogs, :blogs_first_one, :blogs_second_one,
             :blogs_remove_from_first_one, :blogs_add_to_first_one
           ]
    results = keys.collect { |key| redis.del(key)}
    p "#{results.size} keys processed: #{results.inspect} (0 means deleted)"
  end
  
  def stats(which)
    case which
    when :all
      p "Not in first_one:    #{redis.scard(:blogs_add_to_first_one)}"
    when :blogs
      p "Blog stats..."
      p "Union of all:     #{redis.scard(:all_works)}"
      p "Not in first_one:    #{redis.scard(:blogs_add_to_first_one)}"
      p "Not in second_one:  #{redis.scard(:blogs_remove_from_first_one)}"
    else
      p "Sorry no matching stats..."
    end
  end
  
  def get_members_of_set(key)
   p redis.smembers(key)
  end
  
  

end

#r = Reconcile.new("development")
#p Reconciler::FirstOne::Blog.first
#r.get_members_of_set(:all_works)