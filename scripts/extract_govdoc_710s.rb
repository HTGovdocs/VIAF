# Compares 710s from ndj files to VIAFs, inserts into gd_<*> tables  
require 'normalize_corporate' 
require 'htph'
require 'json'
require 'viaf'
require 'pp'

start = Time.now()

db = HTPH::Hathidb::Db.new() 
db_conn = db.get_conn()
gv_sql = "INSERT INTO gd_viaf_ids (gd_corporate_id, viaf_id)
          VALUES(?,?)"
gv_insert = db_conn.prepare(gv_sql)
gc_sql = "INSERT INTO gd_corporates (file_name, control_number, line_number, field, date_extracted, 
            indicator, raw_corporate, normalized_corporate)
          VALUES(?, ?, ?, ?, ?, ?, ?, ? )"
gc_insert = db_conn.prepare(gc_sql)
gs_sql = "INSERT INTO gd_subfields (gd_corporate_id, field, code, subfield, 
            subfield_normalized, position, subfield_count) 
          VALUES(?, ?, ?, ?, ?, ?, ?)"
gs_insert = db_conn.prepare(gs_sql)

date_extracted = Time.now().to_date 

last_id_sql = "SELECT LAST_INSERT_ID() AS id"
last_id_q = db_conn.prepare(last_id_sql)

fin = ARGV.shift
gd_in = open(fin, 'r')

count = 0
total_count = 0
not_found_count = 0
gd_in.each do | line |
  count += 1
 
  rec = JSON.parse(line)
  
  control_number = rec["fields"].find {|f| f.has_key? "001"}
  control_number = control_number.values[0].chomp
  corp_fields = rec["fields"].find_all {|f| f.has_key? "710"}
  next if corp_fields.count == 0
  
  
  #710 fields 
  corp_fields.each do | cf | 
    corp_field = cf["710"] 
    total_count += 1
    indicator = corp_field["ind1"].chomp
    subfields = corp_field["subfields"]
    field = "710"
    sub_count = subfields.count 

    normalized_subfields = []
    raw_subs = [] 
    subfields.each_with_index do | s, position |
      normalized_subfields.push normalize_corporate(s.values[0])
      raw_subs.push s.values[0].chomp
    end
   
    raw_corporate = raw_subs.join(' ').chomp 
    normalized_corporate = normalize_corporate(normalized_subfields.join(' '), false)
    #insert into gc_corporates
    gc_insert.execute(fin, control_number, count, field, date_extracted, indicator, 
                      raw_corporate, normalized_corporate)
    gd_corporate_id = 0
    last_id_q.query() { |row| gd_corporate_id = row[:id] } 

    #insert into gd_subfields
    subfields.each_with_index do | s, position |
      code = s.keys[0]
      field = '710'
      subfield = raw_subs[position] 
      subfield_normalized = normalized_subfields[position]
      gs_insert.execute(gd_corporate_id, field, code, subfield, 
                        subfield_normalized, position, sub_count)
    end

    
    viafs = VIAF::get_viaf(raw_subs)
    gc_id = 0
    if viafs.count == 0
      viafs[0] = '' 
      not_found_count += 1
    end
 
    #connect gd_corporates with viafs 
    viafs.each { |viaf_id, headings| gv_insert.execute(gd_corporate_id, viaf_id) } 
      
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
puts "#710s: #{total_count}"
puts "#710s with no viafs: #{not_found_count}"


