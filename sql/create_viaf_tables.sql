use ht_repository;

DROP TABLE IF EXISTS viaf_headings;
DROP TABLE IF EXISTS viaf_corporates;
DROP TABLE IF EXISTS viaf_subfields;

CREATE TABLE viaf_headings(
  id INT NOT NULL auto_increment,
  viaf_id INT NOT NULL,
  heading TEXT NOT NULL, 
  heading_normalized TEXT NOT NULL,
  source_date DATE NOT NULL,
  primary key (id)
);

CREATE TABLE viaf_corporates(
  id INT NOT NULL auto_increment,
  viaf_id INT NOT NULL, 
  indicator CHAR(1) NULL,
  raw_corporate TEXT NOT NULL,
  normalized_corporate TEXT NOT NULL,
  primary key (id)
);

/* Not currently used but good to have */
CREATE TABLE viaf_subfields(
  id INT NOT NULL auto_increment,
  vc_id INT NOT NULL,
  viaf_id INT NOT NULL,
  field VARCHAR(255) NOT NULL DEFAULT "110",
  code CHAR(1) null,
  subfield TEXT NOT NULL,
  subfield_normalized TEXT NOT NULL, 
  /* ordinal number in the subfield array */
  position INT NOT NULL DEFAULT 0, 
  /* # of subs in the field. In here and not viaf_corporates for convenience */
  subfield_count INT NOT NULL DEFAULT 1,
  primary key (id)
);

