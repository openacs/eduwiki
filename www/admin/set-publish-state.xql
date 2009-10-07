<?xml version="1.0"?>

<queryset>
  <fullquery name="update_publish_state">
    <querytext>
      update cr_items
      set publish_status = :publish_status
      where item_id = :eduwiki_item_id
    </querytext>  
  </fullquery>

  <fullquery name="update_pages_publish_state">
    <querytext>
      update cr_items
      set publish_status = :publish_status
      where item_id = :page_item_id
    </querytext>  
  </fullquery>

  <fullquery name="update_activity_pages">
    <querytext>
      select page_id as page_item_id
      from eduwiki_pages_map
      where eduwiki_id = :eduwiki_item_id
    </querytext>  
  </fullquery>

</queryset>
