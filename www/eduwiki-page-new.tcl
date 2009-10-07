# /packages/eduwiki/www/eduwiki-page-new.tcl

ad_page_contract {
    Automatically create a page related with page_item_id and eduwiki
    @author Hector Amado (hr_amado@galileo.edu)
    @creation-date 2009-07-08
} {
    {item_id 0}
    {name ""}
    {title ""}
}

set package_id [ad_conn package_id]
set package_url [apm_package_url_from_id $package_id]

# check create permissions
if { $item_id > 0} {
    permission::require_permission -object_id $item_id -privilege create
     
    set data [eduwiki::create_page -page_title $title -page_name $name]
    set eduwiki_page_id [lindex $data 0]
    set page_name [lindex $data 1]
    set link "${package_url}$page_name"

    #set page_permissions
    set page_item_id $item_id
    set eduwiki_id [eduwiki::get_eduwiki_task_id -page_item_id $page_item_id]
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
    #get eduwiki_party_id
    set eduwiki_id $item_id
    set eduwiki_party_id [eduwiki::get_eduwiki_party_id -eduwiki_id $eduwiki_id -page_item_id $page_item_id]

    if { ![empty_string_p $eduwiki_page_id] && ![empty_string_p $eduwiki_id] && ![empty_string_p $eduwiki_party_id] } {
	            db_dml insert_eduwiki_pages_map { *SQL* }
		    eduwiki::set_eduwiki_permissions -eduwiki_page_id $eduwiki_page_id \
			-party_id $eduwiki_party_id \
			-eduwiki_category $eduwiki_category \
			-eduwiki_visible_all_p $eduwiki_visible_all_p \
			-eduwiki_editable_all_p $eduwiki_editable_all_p \
			-eduwiki_create_all_p $eduwiki_create_all_p \
			-eduwiki_index_p "f"

	            #set delete permissions to creator
	            permission::grant -object_id $eduwiki_page_id -party_id [ad_conn user_id] -privilege delete
    }      
    

    ad_returnredirect  [export_vars -base $link {{m edit} {title ""}}]

} else {
    ad_return_complaint 1 "[_ eduwiki.new_page_needs_eduwiki_task]"
    ad_script_abort
}

