<?xml version="1.0"?>

<queryset>

    <fullquery name="eduwiki::get_eduwiki_party_id.get_eduwiki_party_id">
        <querytext>
	  select party_id
	  from eduwiki_pages_map
	  where eduwiki_id = :eduwiki_id
	  and page_id = :page_item_id
        </querytext>
    </fullquery>

  <fullquery name="eduwiki::get_eduwiki_task_id.get_eduwiki_task_id">
    <querytext>
      select eduwiki_id
      from eduwiki_pages_map
      where page_id = :page_item_id
    </querytext>  
  </fullquery>

  <fullquery name="eduwiki::get_party_name.get_object_type">
    <querytext>
      select object_type
      from acs_objects
      where object_id = :party_id
    </querytext>  
  </fullquery>

  <fullquery name="eduwiki::get_party_name.get_user_party_name">
    <querytext>
      select last_name || ',' || first_names
      from persons
      where person_id = :party_id
    </querytext>  
  </fullquery>

  <fullquery name="eduwiki::get_party_name.get_group_party_name">
    <querytext>
      select group_name
      from groups
      where group_id = :party_id
    </querytext>  
  </fullquery>

</queryset>
