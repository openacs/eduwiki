<?xml version="1.0"?>

<queryset>
  <fullquery name="insert_eduwiki_pages_map">
    <querytext>
      insert into eduwiki_pages_map
         (eduwiki_id, page_id, party_id, index_p)
      values
         (:eduwiki_id, :eduwiki_page_id, :eduwiki_party_id, 'f')
    </querytext>  
  </fullquery>
</queryset>
