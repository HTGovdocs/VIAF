/* Do this AFTER loading viaf data, or there will be pain */
use ht_repository;

CREATE INDEX vh_heading on viaf_headings(heading);
CREATE INDEX vh_viaf_id on viaf_headings(viaf_id);
CREATE INDEX vh_normal on viaf_headings(heading_normalized);

CREATE INDEX vc_viaf_id ON viaf_corporates(viaf_id);
CREATE INDEX vc_raw on viaf_corporates(raw_corporate);
CREATE INDEX vc_normal on viaf_corporates(normalized_corporate);

CREATE INDEX vs_sub on viaf_subfields(subfield);
CREATE INDEX vs_normal on viaf_subfields(subfield_normalized);
CREATE INDEX vs_viaf_id ON viaf_subfields(viaf_id);
