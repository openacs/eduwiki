<?xml version="1.0"?>

<queryset>
  <fullquery name="select_group_pages">
    <querytext>
      select page_id as page_item_id
      from eduwiki_pages_map
      where party_id = :group_id
    </querytext>  
  </fullquery>
</queryset>
