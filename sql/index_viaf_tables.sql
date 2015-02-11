/* Do this AFTER loading viaf data, or there will be pain */
use ht_repository;

CREATE INDEX vh_heading on viaf_headings(heading(500));
CREATE INDEX vh_viaf_id on viaf_headings(viaf_id);
CREATE INDEX vh_normal on viaf_headings(heading_normalized(500));

CREATE INDEX vc_viaf_id ON viaf_corporates(viaf_id);
CREATE INDEX vc_raw on viaf_corporates(raw_corporate(500));
CREATE INDEX vc_normal on viaf_corporates(normalized_corporate(500));

CREATE INDEX vs_sub on viaf_subfields(subfield(500));
CREATE INDEX vs_normal on viaf_subfields(subfield_normalized(500));
CREATE INDEX vs_viaf_id ON viaf_subfields(viaf_id);
