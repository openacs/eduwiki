# /packages/eduwiki/www/admin/group-add-2.tcl

ad_page_contract {
    Page to add groups

    @author Hector Amado (hr_amado@galileo.edu)
    @creation-date 2009-06-03
    @cvs-id $Id$
} {
    eduwiki_id:integer,notnull
    group_id:integer,notnull
    {confirm_p "f"}
}

set community_id [dotlrn_community::get_community_id]
set package_id [ad_conn package_id]

set count_eduwiki_pages [db_string get_count_eduwiki_pages { *SQL* } -default 0]
set count_eduwiki_groups [db_string get_count_eduwiki_groups { *SQL* } -default 0]
if { ![empty_string_p $group_id] } {

    db_transaction {
	 # delete from table, set cr_item publish_status to production
	 # set object_type [group::delete $group_id]
	 #remove_groups
	 db_dml delete_eduwiki_group_map { *SQL* }

         db_foreach select_eduwiki_pages_map { *SQL* } {
	     #foreach page set publish_status
	     db_dml update_pages_publish_state { *SQL* }
	 }
	
	 #remove pages relation
	 db_dml delete_eduwiki_pages_map { *SQL* }

    } on_error {
	ns_log notice "There was an error deleting group_id $group_id"
    }

}

ad_returnredirect [export_vars -base "groups-admin" {eduwiki_id}]
ad_script_abort
