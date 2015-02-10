# Little more than regexing out the 110 values and throwing them in the db 
require 'normalize_corporate' 
require 'htph'

#require 'xmlsimple'  #way too slow, regex instead
start = Time.now()

db = HTPH::Hathidb::Db.new() 
db_conn = db.get_conn()
vc_sql = "INSERT INTO viaf_corporates (viaf_id, indicator, raw_corporate, normalized_corporate)
          VALUES(?, ?, ?, ?)"
vc_insert = db_conn.prepare(vc_sql)
vs_sql = "INSERT INTO viaf_subfields (vc_id, viaf_id, field, code, subfield, 
            subfield_normalized, position, subfield_count) 
          VALUES(?, ?, ?, ?, ?, ?, ?, ?)"
vs_insert = db_conn.prepare(vs_sql)
vh_sql = "INSERT INTO viaf_headings (viaf_id, heading, heading_normalized, source_date) 
          VALUES(?, ?, ?, ?)"
vh_insert = db_conn.prepare(vh_sql)
viaf_src_date = ENV['viaf_src_date']

last_id_sql = "SELECT LAST_INSERT_ID() AS id"
last_id_q = db_conn.prepare(last_id_sql)

xmlin = open(ENV['viaf_src_path'], 'r')

count = 0
xmlin.each do | line |
  count += 1
  
  viaf_id = line.match(/<viafID>(.*)<\/viafID>/)[1].chomp

  #110 fields 
  dfs = line.scan(/datafield [^t]*tag=.110. dtype=.MARC21.>.*?<\/datafield>/)
  dfs.each do | df |
    indicator = df.match(/ind1=.(.). /)[1].chomp

    subs = df.scan(/subfield code=.([a-z]).>(.*?)<\/subfield>/)
    s_count = subs.count

    normalized_subfields = []
    subs.each_with_index do | s, position |
      normalized_subfields.push normalize_corporate(s[1])
    end
    
    raw_corporate = df.scan(/subfield code=.[a-z].>(.*?)<\/subfield>/).flatten.join(' ')
    normalized_corporate = normalize_corporate(normalized_subfields.join(' '), false)

    vc_insert.execute(viaf_id, indicator, raw_corporate, normalized_corporate);
    vc_id = 0
    last_id_q.query() { |row| vc_id = row[:id] }
     
    #individual sub fields
    subs.each_with_index do | s, position | 
      code = s[0]
      s_normal = normalized_subfields[position]
      vs_insert.execute(vc_id, viaf_id, "110", code, s[1], s_normal, position.to_i, s_count)
    end

  end

  #main entry text
  #typically a few per id
  mh = line.match(/mainHeadings>.*?<mainHeadingEl>/)[0]
  mh.scan(/<text>(.*?)<\/text>/).flatten.each do |t| 
    vh_insert.execute(viaf_id, t, normalize_corporate(t, false), viaf_src_date) 
  end
  
  if count % 100000 == 0
    puts count
  end

end
done = Time.now
duration = done - start
persec = count / duration
puts duration
puts persec


