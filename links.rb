require 'sinatra'


# gem 'activerecord', '=3.0.3'
# gem 'activerecord-jdbcsqlite3-adapter', '=1.1.2'  

require 'active_record'
require 'active_record/connection_adapters/jdbcsqlite3_adapter'   # needed? better way to specify??
require 'jdbc/sqlite3'   # needed? better way to specify??


ActiveRecord::Base.establish_connection(
    :adapter  => 'sqlite3',
    :database => 'db/links.sqlite3' )


#####################
# Models 

class Link < ActiveRecord::Base

  # self.table_name = 'links'
 
  attr_accessor :score 

  def recalc_score
    time_elapsed = (Time.now - self.created_at) / 3600    ## in hours?
    self.score = ((self.points-1) / (time_elapsed+2)**1.8)  ## .real
  end
 
  def self.hot
    self.all.each { |rec| rec.recalc_score }.sort { |l,r| l.score <=> r.score }.reverse
  end
  
  def url_host
    uri = URI.parse( url )
    uri.host
  end

end # class Link


##############################################
# Controllers / Routing / Request Handlers

get '/' do
  @links = Link.order( 'created_at desc' ).all
  erb :index
end

get '/hot' do 
  @links = Link.hot
  erb :index
end

post '/' do 
  l = Link.new( params[:link] )
  l.save!
  redirect back  
end

put '/:id/vote/:type' do
  l = Link.find( params[:id] )
  l.points += params[:type].to_i
  l.save!
  redirect back
end