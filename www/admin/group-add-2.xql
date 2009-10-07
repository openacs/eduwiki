<?xml version="1.0"?>

<queryset>
  <fullquery name="insert_eduwiki_group_map">
    <querytext>
      insert into eduwiki_groups_map
         (eduwiki_id, party_id)
      values
         (:item_id, :eduwiki_group_id)
    </querytext>  
  </fullquery>

  <fullquery name="insert_eduwiki_pages_map">
    <querytext>
      insert into eduwiki_pages_map
         (eduwiki_id, page_id, party_id, index_p)
      values
         (:item_id, :eduwiki_page_id, :eduwiki_group_id, 't')
    </querytext>  
  </fullquery>

</queryset>
