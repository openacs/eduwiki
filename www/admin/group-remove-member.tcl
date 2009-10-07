# /packages/eduwiki/www/admin/group-remove-member.tcl

ad_page_contract {
    Page to remove members from group

    @author Hector Amado (hr_amado@galileo.edu)
    @creation-date 2009-06-09
    @cvs-id $Id$
} {
    {selected_members_list ""}
    group_id:integer,notnull
    eduwiki_id:integer,notnull
}

set community_id [dotlrn_community::get_community_id]
set package_id [ad_conn package_id]

set selected_members_list [string trim $selected_members_list]
if { [llength $selected_members_list] } {
    db_transaction {
	foreach user_id $selected_members_list {
	    group::remove_member -group_id $group_id -user_id $user_id
	    db_dml remove_from_approved_member_map { delete from party_approved_member_map where member_id = :user_id and party_id = :group_id  }
	}
    }
}

db_foreach select_group_pages { *SQL* } {
    # page_item_id
    # clean cache for groups item_id

    if {[permission::cache_p]} {
	set pattern $page_item_id
	set cached_names [ns_cache names util_memoize]
	foreach name $cached_names {
	    if {[regexp -nocase -- $pattern $name match]} {
		ns_cache flush util_memoize $name
	    }
	}
    }
}

ad_returnredirect [export_vars -base "groups-admin" {eduwiki_id {group_ids $group_id}}]
ad_script_abort
