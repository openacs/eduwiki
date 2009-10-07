#/packages/eduwiki/www/admin/set-publish-state.tcl

::eduwiki::Package initialize -ad_doc {

  Change publish_state to EduwikiTask
  
  @author Hector Amado (hr_amado@galileo.edu)
  @creation-date 2009-07-27
  @cvs-id $Id$
  
  @param eduwiki_id The eduwiki_id of the Task to change publish_state
} -parameter {
  {-publish_status "ready"}
  {-item_id:integer}
}

permission::require_write_permission -object_id $item_id
#::xo::db::CrItem delete -item_id $item_id 
# change publish_state to task and pages
db_transaction {
    
    if { ($publish_status == "ready") || ($publish_status == "production") } {
	set eduwiki_item_id $item_id
	db_dml update_publish_state { *SQL* }
	db_foreach update_activity_pages { *SQL* } {
	    db_dml update_pages_publish_state { *SQL* }
	}

    }

} on_error {
    ns_log notice "There was an error changing publish_status to eduwiki_id $item_id"
}

ad_returnredirect "eduwiki-index"

