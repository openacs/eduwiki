# /packages/eduwiki/www/admin/eduwiki-remove-group.tcl

ad_page_contract {
    Page to remove groups from tasks

    @author Hector Amado (hr_amado@galileo.edu)
    @creation-date 2009-07-13
    @cvs-id $Id$
} {
    {group_id_list ""}
    eduwiki_id:integer,notnull
}

set community_id [dotlrn_community::get_community_id]
set package_id [ad_conn package_id]

# save group page
set group_id_list [string trim $group_id_list]
if { [llength $group_id_list] > 0 } {
    db_transaction {
	foreach eduwiki_group_id $group_id_list {
	    #remove_groups
	    db_dml delete_eduwiki_group_map { *SQL* }

	    db_foreach select_eduwiki_pages_map { *SQL* } {
		#foreach page
		#delete xowiki pages
	    }
	    
	    #remove_pages
	    db_dml delete_eduwiki_pages_map { *SQL* }
	}
    }
}

ad_returnredirect [export_vars -base "groups-admin" {eduwiki_id}]
ad_script_abort
