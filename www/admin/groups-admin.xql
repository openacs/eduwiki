<?xml version="1.0"?>

<queryset>
<fullquery name="get_students_in_comm">
  <querytext>
	select
		p.last_name ||', '|| p.first_names as student_name,
		p.person_id as student_id
	from
		persons p,
		dotlrn_member_rels_approved app
	where
		app.community_id = :community_id
		and app.user_id = p.person_id
		and app.role = 'student'
		and p.person_id  not in (select map.object_id_two
	                                 from acs_rels map
	                                 where map.object_id_two = p.person_id 
	                                 and map.object_id_one in (select party_id
	                                                           from eduwiki_groups_map
	                                                           where eduwiki_id = :eduwiki_id))
		order by p.last_name asc

  </querytext>
</fullquery>

<fullquery name="get_students_not_in_group">
  <querytext>
	select
		p.last_name ||', '|| p.first_names as student_name,
		p.person_id as student_id
	from
		persons p,
		dotlrn_member_rels_approved app
	where
		app.community_id = :community_id
		and app.user_id = p.person_id
		and app.role = 'student'
		and p.person_id  not in (select map.object_id_two from acs_rels map where map.object_id_two = p.person_id and map.object_id_one in ([join $group_ids ,]))
		order by p.last_name asc

  </querytext>
</fullquery>

<fullquery name="get_students_for_group">
  <querytext>
	select
		p.last_name ||', '|| p.first_names as student_name,
		p.person_id as student_id
	from
		persons p,
		dotlrn_member_rels_approved app
	where
		app.community_id = :community_id
		and app.user_id = p.person_id
		and app.role = 'student'
		and p.person_id in (select map.object_id_two from acs_rels map where map.object_id_two = p.person_id and map.object_id_one in ([join $group_ids ,]))
		order by p.last_name asc

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
	        ao.context_id = :eduwiki_package_id
	and
	        g.group_id in ( select g1.party_id
	                        from eduwiki_groups_map g1
	                        where g1.eduwiki_id = :eduwiki_id )
  </querytext>
</fullquery>

<fullquery name="get_groups_in_eduwiki_task">
  <querytext>
	select
	        g.group_name,
	        g.group_id
	from
	        groups g,
	        eduwiki_groups_map eg
	where
	        g.group_id = eg.party_id
	and
	        eg.eduwiki_id = :eduwiki_id
  </querytext>
</fullquery>

</queryset>

