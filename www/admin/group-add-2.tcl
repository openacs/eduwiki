# /packages/eduwiki/www/admin/group-add-2.tcl

ad_page_contract {
    Page to add groups

    @author Hector Amado (hr_amado@galileo.edu)
    @creation-date 2009-06-03
    @cvs-id $Id$
} {
    eduwiki_id:integer,notnull
    {group_name ""}
}

set community_id [dotlrn_community::get_community_id]
set package_id [ad_conn package_id]
set group_id ""

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



if { ![empty_string_p $group_name] } {
    db_transaction {
	set group_id [group::new -group_name $group_name -context_id $package_id]
	#add to eduwiki_id
	if {![empty_string_p $group_id]} {
	    set eduwiki_group_id $group_id
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

ad_returnredirect [export_vars -base "groups-admin" {{eduwiki_id $item_id} {group_ids $group_id}}]
ad_script_abort
