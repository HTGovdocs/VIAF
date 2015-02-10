/* Do this AFTER loading viaf data, or there will be pain */
use ht_repository;

CREATE INDEX gc_viaf_id ON gd_corporates(viaf_id);
CREATE INDEX gc_normal ON gd_corporates(normalized_corporate);

CREATE INDEX gs_viaf_id ON gd_subfields(viaf_id);
CREATE INDEX gs_normal ON gs_subfields(subfield_normalized);


