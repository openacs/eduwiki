<?xml version="1.0"?>

<queryset>
  <fullquery name="get_groups_in_eduwiki">
    <querytext>
	select
	        g.group_name,
	        g.group_id
	from
	        groups g,
	        acs_objects ao
	where
	        g.group_id = ao.object_id
	and
	        ao.context_id = :package_id
    </querytext>
  </fullquery>

  <fullquery name="get_groups_in_eduwiki">
    <querytext>
	select
	        g.group_name,
	        g.group_id
	from
	        groups g,
	        acs_objects ao
	where
	        g.group_id = ao.object_id
	and
	        ao.context_id = :package_id
    </querytext>
  </fullquery>

  <fullquery name="insert_eduwiki_group_map">
    <querytext>
      insert into eduwiki_groups_map
         (eduwiki_id, party_id)
      values
         (:data_item_id, :group_id)
    </querytext>  
  </fullquery>

  <fullquery name="insert_eduwiki_pages_map">
    <querytext>
      insert into eduwiki_pages_map
         (eduwiki_id, page_id, party_id, index_p)
      values
         (:data_item_id, :eduwiki_page_id, :eduwiki_party_id, 't')
    </querytext>  
  </fullquery>

  <fullquery name="select_current_members">
    <querytext>
      select dmra.user_id as party_id,
             p.first_names,
             p.last_name
      from   dotlrn_member_rels_approved dmra,
             persons p
      where  dmra.community_id = :community_id
      and    dmra.user_id = p.person_id
      and    dmra.rel_type = 'dotlrn_student_rel'
    </querytext>  
  </fullquery>

  <fullquery name="get_eduwiki_pages">
    <querytext>
      select page_id as eduwiki_page_id,
             party_id as eduwiki_party_id,
             index_p as page_index_p
      from eduwiki_pages_map
      where eduwiki_id = :data_item_id
    </querytext>  
  </fullquery>

</queryset>
