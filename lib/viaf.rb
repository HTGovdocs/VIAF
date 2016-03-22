require "viaf/version"
require 'mysql2'
require 'normalize_corporate'
require 'dotenv'
require 'pp'

Dotenv.load()
##
# Basic handling of VIAF corporate names. 
class Viaf
  attr_accessor :nsubs
  attr_accessor :ncorp
  attr_accessor :results
  attr_accessor :viafs
 
  def initialize() 
    @db_conn = Mysql2::Client.new(:host => ENV['db_host'], 
                                  :username => ENV['db_user'],
                                  :password => ENV['db_pw'],
                                  :database => ENV['db_name'],
                                  :reconnect => true
                                 )
    #1. select headings
    #   "SELECT viaf_id, heading FROM viaf_headings WHERE heading_normalized = " 

    #2. select viaf corporates
    #   "SELECT vc.viaf_id, raw_corporate, heading FROM viaf_corporates vc 
    #          LEFT JOIN viaf_headings vh ON vh.viaf_id = vc.viaf_id 
    #          WHERE normalized_corporate = "
  end
  
  ##
  # Takes an array of subfields: [<a_sub>, <b_sub>, <b_sub>, ...]. 
  # Returns viaf ids and main entry text
  def get_viaf( field )
    @viafs = {}
    raw_corporate = field.join(' ')
    @nsubs  = field.map{ |sf| normalize_corporate(sf) }
    @ncorp = normalize_corporate(@nsubs.join(' '), false)
    #1. check main headings for exact matches
    begin
      ncorp_escaped = @db_conn.escape(@ncorp.encode("ISO-8859-1"))
      @results = @db_conn.query("SELECT viaf_id, heading FROM viaf_headings 
                          WHERE heading_normalized = '#{ncorp_escaped}'") 
    rescue Exception => e
      PP.pp e
      STDOUT.flush
      #text encoding problems, abandon all hope
      return @viafs
    end
    @results.each do | row |
      if @viafs.has_key? row['viaf_id'] 
        @viafs[row['viaf_id']].push row['heading'] #heading
      else
        @viafs[row['viaf_id']] = [row['heading']]
      end
      #viafs[:match_type] = 'main heading'
    end
    if @viafs.count > 0 
      return @viafs #good enough
    end

    #2. search the corporates (110s)
    @results = @db_conn.query("SELECT vc.viaf_id, raw_corporate, heading FROM viaf_corporates vc 
                                LEFT JOIN viaf_headings vh ON vh.viaf_id = vc.viaf_id 
                                WHERE normalized_corporate = '#{ncorp_escaped}'")
    @results.each do | row |
      if @viafs.has_key? row['vc.viaf_id']
        @viafs[row['vc.viaf_id']].push row['heading'] #heading
      else
        @viafs[row['vc.viaf_id']] = [row['heading']]
      end
      #viafs[:match_type] = "corporate (110)"
    end
    if @viafs.count > 0
      return @viafs  #good enough
    end

    ##
    # Calculate best fit somehow?  
    # eh, whatever
    return @viafs

  end #get_viafs()

 
end
