#/packages/eduwiki/www/admin/set-item-publish-state.tcl

::eduwiki::Package initialize -ad_doc {

  Change item publish_state
  
  @author Hector Amado (hr_amado@galileo.edu)
  @creation-date 2009-07-28
  @cvs-id $Id$
  
  @param item_id The item_id to change publish_state
} -parameter {
  {-publish_status "ready"}
  {-item_id:integer}
  {-eduwiki_id:integer}
}

permission::require_write_permission -object_id $item_id
# change publish_state to task and pages
db_transaction {
    
    if { ($publish_status == "ready") || ($publish_status == "production") } {
	    db_dml update_pages_publish_state { *SQL* }
    }

} on_error {
    ns_log notice "There was an error changing publish_status to item_id $item_id"
}

ad_returnredirect [export_vars -base "eduwiki-list" {eduwiki_id}]

