<?xml version="1.0"?>

<queryset>
  <fullquery name="get_count_eduwiki_pages">
    <querytext>
      select count(*)
      from eduwiki_pages_map
      where party_id = :group_id
    </querytext>  
  </fullquery>

  <fullquery name="get_count_eduwiki_groups">
    <querytext>
      select count(*)
      from eduwiki_groups_map
      where party_id = :group_id
    </querytext>  
  </fullquery>

  <fullquery name="delete_eduwiki_group_map">
    <querytext>
      delete from eduwiki_groups_map
      where party_id = :group_id
      and eduwiki_id = :eduwiki_id
    </querytext>  
  </fullquery>

  <fullquery name="delete_eduwiki_pages_map">
    <querytext>
      delete from eduwiki_pages_map
      where party_id = :group_id
      and eduwiki_id = :eduwiki_id
    </querytext>  
  </fullquery>

  <fullquery name="select_eduwiki_pages_map">
    <querytext>
      select page_id from eduwiki_pages_map
      where party_id = :group_id
      and eduwiki_id = :eduwiki_id
    </querytext>  
  </fullquery>

  <fullquery name="update_pages_publish_state">
    <querytext>
      update cr_items
      set publish_status = 'production'
      where item_id = :page_id
    </querytext>  
  </fullquery>

</queryset>
