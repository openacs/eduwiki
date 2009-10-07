<?xml version="1.0"?>

<queryset>
<fullquery name="get_students_not_in_activity">
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
		and p.person_id  not in (select party_id
	                                 from eduwiki_pages_map
	                                 where eduwiki_id = :eduwiki_id
	                                 and index_p = 't' )
		order by p.last_name asc

  </querytext>
</fullquery>

</queryset>

