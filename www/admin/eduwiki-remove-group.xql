<?xml version="1.0"?>

<queryset>
  <fullquery name="delete_eduwiki_group_map">
    <querytext>
      delete from eduwiki_groups_map
      where party_id = :eduwiki_group_id
      and eduwiki_id = :eduwiki_id
    </querytext>  
  </fullquery>

  <fullquery name="delete_eduwiki_pages_map">
    <querytext>
      delete from eduwiki_pages_map
      where party_id = :eduwiki_group_id
      and eduwiki_id = :eduwiki_id
    </querytext>  
  </fullquery>

  <fullquery name="select_eduwiki_pages_map">
    <querytext>
      select page_id from eduwiki_pages_map
      where party_id = :eduwiki_group_id
      and eduwiki_id = :eduwiki_id
    </querytext>  
  </fullquery>

</queryset>
