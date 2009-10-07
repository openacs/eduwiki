::eduwiki::Package initialize -ad_doc {

  Delete an EduwikiTask
  
  @author Hector Amado (hr_amado@galileo.edu)
  @creation-date 2009-06-10
  @cvs-id $Id$
  
  @param eduwiki_id The eduwiki_id of the Task to delete
} -parameter {
  {-item_id:integer}
}

permission::require_write_permission -object_id $item_id
::xo::db::CrItem delete -item_id $item_id 

ad_returnredirect "eduwiki-index"

