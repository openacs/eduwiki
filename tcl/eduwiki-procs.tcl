# /packages/eduwiki/tcl/eduwiki-procs.tcl

::xo::library doc {

    Eduwiki package procs

    @author Hector Amado (hr_amado@galileo.edu)
    @creation-date 2009-06-01
}

namespace eval ::eduwiki {}

ad_proc -public eduwiki::create_page {
    {-page_title ""}
    {-page_name ""}
} {
    set package_id [ad_conn package_id]
    ::xowiki::Package initialize -package_id $package_id
    set folder_id [::xowiki::Page require_folder -name xowiki \
		       -package_id $package_id]
    set page [::xowiki::Page new]
    set object_type "::xowiki::Page"
    set lang_prefix [string range [lang::system::locale] 0 1]
    set page_index [db_string page_index [$object_type  instance_select_query -folder_id $folder_id -with_subtypes false -from_clause ",xowiki_page p" -where_clause "p.page_id = bt.revision_id" -count true]]
    if { [empty_string_p $page_name] } {
	set page_name "${lang_prefix}:page_[incr page_index]"
    } 
    if {[db_string select_name { select 1 from cr_items where name = :page_name and parent_id = :folder_id} -default 0]} {
        set page_name "${lang_prefix}:page_[incr page_index]_[format %0.0f [expr [random]* 10]]_[format \
            %0.0f [expr [random] * 10]]"
    }
    $page configure -name $page_name -parent_id $folder_id \
        -package_id $package_id

    if {![empty_string_p $page_title]} {
        $page set title $page_title
    }

    $page set nls_language [lang::system::locale]

    $page destroy_on_cleanup
    $page initialize_loaded_object
    set page_id [$page save_new]
    set page_item_id [$page set item_id]
    return [list $page_item_id $page_name]
}

ad_proc -public eduwiki::set_eduwiki_permissions {
    -eduwiki_page_id:required
    {-party_id 0}
    {-eduwiki_category "professor"}
    {-eduwiki_visible_all_p "t"}
    {-eduwiki_editable_all_p "t"}
    {-eduwiki_create_all_p "t"}
    {-eduwiki_index_p "f"}
} {

    # set eduwiki permissions

    # group or individual, party_id used
    if { [permission::inherit_p -object_id $eduwiki_page_id] } {
	permission::toggle_inherit -object_id $eduwiki_page_id
    }
    # set admin_rels
    set sw_group_id [application_group::group_id_from_package_id -package_id [ad_conn subsite_id]]
    set rel_id [group::get_rel_segment -group_id $sw_group_id -type admin_rel]
    permission::grant -object_id $eduwiki_page_id -party_id $rel_id -privilege admin

    # set dotlrn_admin_rel
    set comm_id [dotlrn_community::get_community_id]
    set rel_id [group::get_rel_segment -group_id $comm_id -type dotlrn_admin_rel]
    # if index_p dotlrn_admin_rel can't delete page
    if { !$eduwiki_index_p } {
	permission::grant -object_id $eduwiki_page_id -party_id $rel_id -privilege admin
    } else {
	permission::grant -object_id $eduwiki_page_id -party_id $rel_id -privilege read
	permission::grant -object_id $eduwiki_page_id -party_id $rel_id -privilege write
	permission::grant -object_id $eduwiki_page_id -party_id $rel_id -privilege create
    }
	
    # set dotlrn_member_rel
    set rel_id [group::get_rel_segment -group_id $comm_id -type dotlrn_member_rel]
    permission::revoke -object_id $eduwiki_page_id -party_id $rel_id -privilege read
    if { $eduwiki_visible_all_p } {
	permission::grant -object_id $eduwiki_page_id -party_id $rel_id -privilege read
    }

    # professor
    if { $eduwiki_category == "professor" } {
	permission::revoke -object_id $eduwiki_page_id -party_id $rel_id -privilege write
	if { $eduwiki_editable_all_p } {
	    permission::grant -object_id $eduwiki_page_id -party_id $rel_id -privilege write
	}
    }

    # working with party_id
    if { $party_id > 0 } {
	permission::grant -object_id $eduwiki_page_id -party_id $party_id -privilege read
	# ownwer can edit by default
        permission::grant -object_id $eduwiki_page_id -party_id $party_id -privilege write

	permission::revoke -object_id $eduwiki_page_id -party_id $rel_id -privilege write
	if { $eduwiki_editable_all_p } {
	    # can all members edit the page
	    permission::grant -object_id $eduwiki_page_id -party_id $rel_id -privilege write
	}
        permission::revoke -object_id $eduwiki_page_id -party_id $party_id -privilege create
	if { $eduwiki_create_all_p } {
	    permission::grant -object_id $eduwiki_page_id -party_id $party_id -privilege create	  
	}
    }

}

ad_proc -public eduwiki::get_eduwiki_task_id {
    -page_item_id:required
} {
    return [db_string get_eduwiki_task_id { *SQL* } -default ""]
}

ad_proc -public eduwiki::get_eduwiki_party_id {
    -eduwiki_id:required
    -page_item_id:required
} {
    return [db_string get_eduwiki_party_id { *SQL* } -default ""]
}

ad_proc -public eduwiki::get_party_name {
    -party_id:required
} {
    set object_type [db_string get_object_type { *SQL* } -default ""]
    if {![empty_string_p $object_type]} {
	if { $object_type == "user" } {
	    return [db_string get_user_party_name { *SQL* } -default ""]
	} elseif { $object_type == "group" } {
	    return [db_string get_group_party_name { *SQL* } -default ""]
	}
    }
    return ""
}

ad_proc -public eduwiki::get_best_eduwiki_page_url {
    -eduwiki_id:required
    -user_id:required
    -eduwiki_category:required
    -folder_id:required
} {

      set where_clause "e.page_id = ci.item_id and e.eduwiki_id = :eduwiki_id and index_p = 't'"
      set page_url ""

      db_foreach instance_select \
	[::xowiki::Page instance_select_query \
	 -parent_id $folder_id \
         -from_clause ", eduwiki_pages_map e" \
	 -select_attributes [list "bt.revision_id as page_id" title creation_user "e.party_id as creator_id" index_p]\
         -where_clause $where_clause \
	    ] {
    
	if { $eduwiki_category == "professor" } {
	    set page_url $name
	} elseif { $eduwiki_category == "student" } {
	    if { $user_id == $creator_id } {
		set page_url $name
	    }
	} else {
	    #category group
	    if {[group::member_p -user_id $user_id -group_id $creator_id]} {
		set page_url $name
	    }
	}

    }

    #default
    return $page_url
}
