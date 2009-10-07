# /packages/eduwiki/www/admin/groups-admin.tcl

ad_page_contract {
    Page to manage eduwiki groups

    @author Hector Amado (hr_amado@galileo.edu)
    @creation-date 2009-06-03
    @cvs-id $Id$
} {
    eduwiki_id:integer,notnull
    {mode "edit"}
    {group_ids ""}
    {group_task_ids ""}
}

set page_title "[_ eduwiki.Groups_manage_]"
set context [list $page_title]
set community_id [dotlrn_community::get_community_id]
set eduwiki_package_id [ad_conn package_id]
set cancel_url "eduwiki-index"

# get eduwiki_id
set eduwiki_title ""
if {[exists_and_not_null eduwiki_id] && [::xo::db::Class exists_in_db -id $eduwiki_id]} {
    set eduwiki_item_id [::eduwiki::EduwikiTask get_instance_from_db -item_id $eduwiki_id]
    set eduwiki_title [$eduwiki_item_id set title]
}


ah::requires -sources "prototype,scriptaculous"

template::head::add_javascript \
    -src "/resources/eduwiki/groups-admin.js"

set optionsgroups [db_list_of_lists get_groups_in_eduwiki { *SQL* }]
if { ![empty_string_p $optionsgroups] } {
    set optionsgroups [lsort $optionsgroups]
} else {
    set optionsgroups "{{[_ eduwiki.not_activity_groups]} {}}"
}

set comm_members_opts [db_list_of_lists get_students_in_comm { *SQL* }]
if { ![empty_string_p $comm_members_opts] } {
    set comm_members_opts [lsort $comm_members_opts]
} else {
    set comm_members_opts "{{[_ eduwiki.not_available_members]} {}}"
}

set group_name ""
if { [info exists group_ids] } {
    if { [llength $group_ids] } {

	set groups_members_opts [db_list_of_lists get_students_for_group { *SQL* }]
	if { ![empty_string_p $groups_members_opts] } {
	    set groups_members_opts [lsort $groups_members_opts]
	} else {
	    set groups_members_opts "{{[_ eduwiki.not_members_in_group]} {}}"
	}

	#set comm_members_opts [db_list_of_lists get_students_not_in_group { *SQL* }]
	#if { ![empty_string_p $comm_members_opts] } {
	#    set comm_members_opts [lsort $comm_members_opts]
	#} else {
	#    set comm_members_opts "{{[_ eduwiki.not_available_members]} {}}"
	#}

	if {[llength $group_ids] == 1} {
	    set group_name [group::get_element -group_id [lindex $group_ids 0] -element "group_name"]
	}

    } else {
	set groups_members_opts "{{[_ eduwiki.not_selected_group]} {}}"
    }     
}

set eduwiki_groups_opts [db_list_of_lists get_groups_in_eduwiki_task { *SQL* }]
if { ![empty_string_p $eduwiki_groups_opts] } {
    set eduwiki_groups_opts [lsort $eduwiki_groups_opts]
} else {
    set eduwiki_groups_opts "{{[_ eduwiki.not_activity_groups]} {}}"
}

ad_form -name eduwiki_groups -mode $mode -form {

    {eduwiki_id:text(hidden)
	{label ""}
	{value $eduwiki_id}
	{html {id eduwiki_id}}
    }
    {eduwiki_action:text(hidden),optional
	{label ""}
	{value ""}
	{html {id eduwiki_action}}
    }
    {eduwiki_group_name:text,optional
	{label "[_ eduwiki.Group_name_]"}
	{html {size 15 id eduwiki_group_name}}
    }
    {eduwiki_groups_actualgroups:text,optional,multiple
	{label "[_ eduwiki.Select_Groups]"}
	{widget multiselect}
	{options $optionsgroups}
	{values $group_ids}
	{html {size 10 id eduwiki_groups_actualgroups onChange "document.eduwiki_groups.submit();"}}
    }
    {eduwiki_groups_comm_members:text,optional,multiple
	{label "[_ eduwiki.Comm_Members]"}
	{widget multiselect}
	{options $comm_members_opts}
	{html {size 10 id eduwiki_groups_comm_members}}
    }
    {eduwiki_groups_members:text,optional,multiple
	{label "[_ eduwiki.Groups_Members]"}
	{widget multiselect}
	{options $groups_members_opts}
	{html {size 10 id eduwiki_groups_members}}
    }
    {eduwiki_task_groups:text,optional,multiple
	{label "[_ eduwiki.task_Groups]"}
	{widget multiselect}
	{options $eduwiki_groups_opts}
	{html {size 10}}
    }
} -on_submit {
    # eduwiki_action
    set base_url "groups-admin"
    set selected_members_list ""
    set group_id_list ""
    if {![empty_string_p $eduwiki_action]} {
	if { $eduwiki_action == "member_add" } {
	    set base_url "group-add-member"
	    set selected_members_list $eduwiki_groups_comm_members
	}
	if { $eduwiki_action == "member_remove" } {
	    set base_url "group-remove-member"
	    set selected_members_list $eduwiki_groups_members
	}
	if { $eduwiki_action == "group_to_task_add" } {
	    if {![empty_string_p $eduwiki_groups_actualgroups]} {
		set base_url "eduwiki-add-group"
	        set group_id_list $eduwiki_groups_actualgroups
	    }
	}
	if { $eduwiki_action == "group_to_task_remove" } {
	    set base_url "eduwiki-remove-group"
	    set group_id_list $eduwiki_task_groups
	}
	if { $eduwiki_action == "add_group" && ![empty_string_p $eduwiki_group_name] } {
	    set base_url "group-add-2"
	}
	if { $eduwiki_action == "delete_group" } {
	    set base_url "group-delete"
	}

    }

    set group_id ""
    if { [llength $eduwiki_groups_actualgroups] == 1 } {
	set group_id [lindex $eduwiki_groups_actualgroups 0]
    }

    ad_returnredirect [export_vars -base $base_url {eduwiki_id group_id selected_members_list group_id_list {group_name $eduwiki_group_name} {group_ids $eduwiki_groups_actualgroups} {group_task_ids $eduwiki_task_groups}}]
    ad_script_abort
}


ad_return_template
