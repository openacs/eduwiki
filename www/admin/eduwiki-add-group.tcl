# /packages/eduwiki/www/admin/eduwiki-add-group.tcl

ad_page_contract {
    Page to add groups to eduwiki task

    @author Hector Amado (hr_amado@galileo.edu)
    @creation-date 2009-07-13
    @cvs-id $Id$
} {
    {group_id_list ""}
    eduwiki_id:integer,notnull
}

set community_id [dotlrn_community::get_community_id]
set package_id [ad_conn package_id]

# get EduwikiTask info
set eduwiki_task_id [content::item::get_live_revision -item_id $eduwiki_id]
db_1row get_instance_select [::eduwiki::EduwikiTask instance_select_query \
         -parent_id $package_id \
         -from_clause ", eduwiki_tasks e" \
	 -select_attributes [list eduwiki_id \
                                  eduwiki_category \
                                  eduwiki_visible_all_p \
                                  eduwiki_editable_all_p \
                                  eduwiki_create_all_p \
                                  eduwiki_evaluation_related_p \
                                  "description as eduwiki_description" \
                                  "bt.title as eduwiki_title" \
                                  "name as eduwiki_name" \
                                  "to_char(release_date,'YYYY MM DD HH24 MI SS') as publish_date" \
				  "to_char(close_date,'YYYY MM DD HH24 MI SS') as close_date"] \
         -where_clause "e.eduwiki_id = acs_objects.object_id and e.eduwiki_id = :eduwiki_task_id" \
                                 ]

# save group page
set group_id_list [string trim $group_id_list]
if { [llength $group_id_list] > 0 } {
    db_transaction {
	foreach eduwiki_group_id $group_id_list {
	    set group_name [group::get_element -group_id $eduwiki_group_id -element "group_name"]
	    if {![empty_string_p $group_name]} {
		db_dml insert_eduwiki_group_map { *SQL* }
		set eduwiki_group_title "$eduwiki_title ($group_name)"
		set eduwiki_page_data [eduwiki::create_page -page_title $eduwiki_group_title]
		set eduwiki_page_id [lindex $eduwiki_page_data 0]
		if { ![empty_string_p $eduwiki_page_id] && ![empty_string_p $item_id] } {
		    db_dml insert_eduwiki_pages_map { *SQL* }
		    eduwiki::set_eduwiki_permissions -eduwiki_page_id $eduwiki_page_id \
			-party_id $eduwiki_group_id \
			-eduwiki_category $eduwiki_category \
			-eduwiki_visible_all_p $eduwiki_visible_all_p \
			-eduwiki_editable_all_p $eduwiki_editable_all_p \
			-eduwiki_create_all_p $eduwiki_create_all_p \
			-eduwiki_index_p "t"
		}
	    }
	}
    }
}

ad_returnredirect [export_vars -base "groups-admin" {{eduwiki_id $item_id}}]
ad_script_abort
