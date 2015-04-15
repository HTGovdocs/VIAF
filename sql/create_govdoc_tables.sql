use ht_repository;
DROP TABLE IF EXISTS gd_viaf_ids;
DROP TABLE IF EXISTS gd_corporates;
DROP TABLE IF EXISTS gd_subfields;

/* alternatively, delete from gd_subs where field = '110'; */
CREATE TABLE gd_viaf_ids(
  id INT NOT NULL auto_increment,
  gd_corporate_id INT NOT NULL,
  viaf_id INT NOT NULL,
  primary key(id)
);

CREATE TABLE gd_corporates(
  id INT NOT NULL auto_increment,
  /* still have to figure out record identification */
  source VARCHAR(255) NOT NULL,
  file_name VARCHAR(255) NOT NULL,
  control_number VARCHAR(255) NOT NULL,
  field VARCHAR(255) NOT NULL,
  date_extracted DATE NOT NULL,
  indicator CHAR(1) NULL,
  raw_corporate TEXT NOT NULL,
  normalized_corporate TEXT NOT NULL,
  primary key(id)
);

/* Not currently used but good to have */
CREATE TABLE gd_subfields(
  id INT NOT NULL auto_increment,
  gd_corporate_id INT NOT NULL,
  field VARCHAR(255) NOT NULL DEFAULT "110", 
  code CHAR(1) NULL,
  subfield TEXT NOT NULL,
  subfield_normalized TEXT NOT NULL DEFAULT "",
  /* ordinal number in the subfield array */
  position INT NOT NULL DEFAULT 0,
  /* # of subs in the field. In here and not viaf_corporates for convenience */
  subfield_count INT NOT NULL DEFAULT 1,
  primary key (id)
);
  
