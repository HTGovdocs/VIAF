require "viaf/version"
require 'htph'
require 'normalize_corporate'

##
# Basic handling of VIAF corporate names. 
module Viaf
  
  DB = HTPH::Hathidb::Db.new();
  DB_CONN = DB.get_conn();
  
  #1. select headings
  VH_SQL = "SELECT viaf_id, heading FROM viaf_headings 
            WHERE heading_normalized = ?" 
  SELECT_HEADINGS = DB_CONN.prepare(vh_sql)

  #2. select viaf corporates
  VC_SQL = "SELECT vc.viaf_id, raw_corporate, heading FROM viaf_corporates vc 
            LEFT JOIN viaf_headings vh ON vh.viaf_id = vc.viaf_id 
            WHERE normalized_corporate = ?"
  SELECT_CORPORATES = DB_CONN.prepare(vc_sql) 
  
  ##
  # Takes an array of subfields: [<a_sub>, <b_sub>, <b_sub>, ...]. 
  # Returns viaf ids and main entry text
  def get_viaf( field )
    viafs = {}
    raw_corporate = field.join(' ')
    nsubs  = field.map{ |sf| normalize_corporate(sf) }
    ncorp = normalize_corporate(nsubs.join(' '), false)
    
    #1. check main headings for exact matches
    SELECT_HEADINGS.enumerate(ncorp) do | row |
      if viafs.has_key? row[0] 
        viafs[row[0]].push row[1] #heading
      else
        viafs[row[0]] = [row[1]]
      end
      viafs[:match_type] = 'main heading'
    end
    if viafs.count > 0 
      return viafs #good enough
    end

    #2. search the corporates (110s)
    SELECT_CORPORATES.enumerate(ncorp) do | row |
      if viafs.has_key? row[0]
        viafs[row[0]].push row[2] #heading
      else
        viafs[row[0]] = [row[2]]
      end
      viafs[:match_type] = "corporate (110)"
    end
    if viafs.count > 0
      return viafs  #good enough
    end

    ##
    # Calculate best fit somehow?  
    # eh, whatever
    return viafs

  end #get_viafs()

 
end
