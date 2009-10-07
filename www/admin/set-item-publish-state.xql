<?xml version="1.0"?>

<queryset>
  <fullquery name="update_pages_publish_state">
    <querytext>
      update cr_items
      set publish_status = :publish_status
      where item_id = :item_id
    </querytext>  
  </fullquery>
</queryset>
