# /packages/eduwiki/www/admin/eduwiki-new.tcl

ad_page_contract {
    Page to add or edit new eduwiki

    @author Hector Amado (hr_amado@galileo.edu)
    @creation-date 2009-07-07
    @cvs-id $Id$
} {
    eduwiki_id:integer,notnull,optional
    {mode "edit"}
}

set new_p [ad_form_new_p -key eduwiki_id]
set form_format "DD MM YYYY HH24 MI"
set package_id [ad_conn package_id]
set community_id [dotlrn_community::get_community_id]

if { $new_p } {
    set page_title "[_ eduwiki.Add_eduwiki_]"
} else {
    set page_title "[_ eduwiki.Edit_eduwiki_]"
}
set context [list $page_title]

set groups_ids ""
set eduwiki_groups ""
# get limit_dates_p
set limit_dates_p [parameter::get -package_id $package_id \
		       -parameter with_limit_dates \
		       -default 0]

ad_form -name eduwiki -mode $mode -cancel_url "eduwiki-index" -form {

    eduwiki_id:key

    {eduwiki_title:text
	{label "[_ eduwiki.Eduwiki_Title_]"}
	{html {size 40}}
    }
    {eduwiki_description:richtext(richtext),optional,nospell
	{label "[_ eduwiki.Eduwiki_Descripti]"}
	{html {rows 8 cols 50}}
    }

}

if { $new_p } {

    ad_form -extend -name eduwiki -form {
	{eduwiki_category:text
	    {label "[_ eduwiki.Wiki_type]"}
	    {widget select}
	    {options {{"[_ eduwiki.Teacher_category]" professor} {"[_ eduwiki.Group_category]" group} {"[_ eduwiki.Student_category]" student}}}
	    {value "professor"}
	}
    }

} else {

    ad_form -extend -name eduwiki -form {
	{eduwiki_category:text
	    {label "[_ eduwiki.Wiki_type]"}
	    {widget select}
	    {mode "display"}
	    {options {{"[_ eduwiki.Teacher_category]" professor} {"[_ eduwiki.Group_category]" group} {"[_ eduwiki.Student_category]" student}}}
	    {value "professor"}
	}
    }

}

ad_form -extend -name eduwiki -form {

    {eduwiki_visible_all_p:text(radio)
	{label "[_ eduwiki.lt_Will_be_visible_by_all]"}
	{options {{"[_ eduwiki.Yes_]" t} {"[_ eduwiki.No_]" f}}}
	{value t}
    }
    {eduwiki_editable_all_p:text(radio)
	{label "[_ eduwiki.lt_Will_be_editable_by_all]"}
	{options {{"[_ eduwiki.Yes_]" t} {"[_ eduwiki.No_]" f}}}
	{value f}
	{help_text "[_ eduwiki.help_editable_by_all]"}
    }
    {eduwiki_create_all_p:text(radio)
	{label "[_ eduwiki.lt_student_Will_create_]"}
	{options {{"[_ eduwiki.Yes_]" t} {"[_ eduwiki.No_]" f}}}
	{value f}
    }

}

if { $limit_dates_p } {

    ad_form -extend -name eduwiki -form {

	{publish_date:date,optional
	    {label "[_ eduwiki.Release_Date]"}
	    {format $form_format}
	    {value ""}
	    {help}
	    {help_text "[_ eduwiki.help_publish_date]"}
	}
	{close_date:date,optional
	    {label "[_ eduwiki.Close_Date]"}
	    {format $form_format}
	    {value ""}
	    {help}
	    {help_text "[_ eduwiki.help_close_date]"}
	}
    }

} else {

    ad_form -extend -name eduwiki -form {

	{publish_date:date(hidden),optional
	    {label "[_ eduwiki.Release_Date]"}
	    {format $form_format}
	    {value ""}
	    {help}
	    {help_text "[_ eduwiki.help_publish_date]"}
	}
	{close_date:date(hidden),optional
	    {label "[_ eduwiki.Close_Date]"}
	    {format $form_format}
	    {value ""}
	    {help}
	    {help_text "[_ eduwiki.help_close_date]"}
	}
    }

}

ad_form -extend -name eduwiki -form {

    {eduwiki_evaluation_related_p:text(hidden)
	{label "[_ eduwiki.lt_Will_this_task_requir]"}
	{options {{"[_ eduwiki.Yes_]" t} {"[_ eduwiki.No_]" f}}}
	{value f}
    }
} -edit_request {

    #Get eduwiki task info                                                     
    db_1row get_instance_select [::eduwiki::EduwikiTask instance_select_query \
         -parent_id $package_id \
         -from_clause ", eduwiki_tasks e" \
	 -select_attributes [list eduwiki_id \
				  eduwiki_category \
				  creation_user \
				  eduwiki_visible_all_p \
				  eduwiki_editable_all_p \
				  eduwiki_create_all_p \
				  eduwiki_evaluation_related_p \
				  "description as eduwiki_description" \
				  "bt.title as eduwiki_title" \
				  "name as eduwiki_name" \
				  "to_char(release_date,'YYYY MM DD HH24 MI SS') as publish_date" \
			          "to_char(close_date,'YYYY MM DD HH24 MI SS') as close_date"] \
	 -where_clause "e.eduwiki_id = acs_objects.object_id and e.eduwiki_id = :eduwiki_id" \
				 ]

} -validate {
    {publish_date
	{ [empty_string_p $publish_date] || ([template::util::date::compare $publish_date [template::util::date::now]] > 0) }
	{[_ eduwiki.publish_date_must_Be_after_now]}
    }
    {close_date
	{ [empty_string_p $close_date] || ([template::util::date::compare $close_date [template::util::date::now]] > 0) }
	{[_ eduwiki.close_date_must_Be_after_now]}
    }
    {close_date
	{ [empty_string_p $close_date] || (![empty_string_p $publish_date] && ([template::util::date::compare $close_date $publish_date] > 0)) }
	{[_ eduwiki.close_date_must_Be_after_publish]}
    }
    {eduwiki_editable_all_p
	{ !$eduwiki_editable_all_p || $eduwiki_visible_all_p }
	{[_ eduwiki.visible_must_be_true_to_edit]}
    }
} -on_submit {

    if { ![empty_string_p $publish_date] } {
	set publish_date [db_string get_publish_date "select to_timestamp('[template::util::date::get_property linear_date $publish_date]','YYYY MM DD HH24 MI SS')" -default ""]
    }
    if { ![empty_string_p $close_date] } {
	set close_date [db_string get_close_date "select to_timestamp('[template::util::date::get_property linear_date $close_date]','YYYY MM DD HH24 MI SS')" -default ""]
    }

    if { [ad_form_new_p -key eduwiki_id] && ![::xo::db::Class exists_in_db -id $eduwiki_id] } {
	#new eduwiki_task
	set data_id [::eduwiki::EduwikiTask create $eduwiki_id]
	$data_id set name task_$eduwiki_id
	$data_id set title $eduwiki_title
	$data_id set description $eduwiki_description
	$data_id set release_date $publish_date
	$data_id set close_date $close_date
	$data_id set eduwiki_category $eduwiki_category
	$data_id set eduwiki_visible_all_p $eduwiki_visible_all_p
	$data_id set eduwiki_editable_all_p $eduwiki_editable_all_p
	$data_id set eduwiki_create_all_p $eduwiki_create_all_p
	$data_id set eduwiki_evaluation_related_p $eduwiki_evaluation_related_p
	$data_id set parent_id $package_id
	$data_id initialize_loaded_object
	$data_id save_new

	set data_item_id [$data_id set item_id]

	#mapping groups
	if { [llength $eduwiki_groups] > 0 } {
	    if {![empty_string_p $data_item_id]} {
		foreach group_id $eduwiki_groups {
		    db_dml insert_eduwiki_group_map { *SQL* }
	        }
	    }
	}

	# creating eduwiki pages
	# eduwiki_category
	if { $eduwiki_category == "professor" } {
	    set eduwiki_data [eduwiki::create_page -page_title $eduwiki_title]
	    set eduwiki_page_id [lindex $eduwiki_data 0]
	    if {![empty_string_p $eduwiki_page_id]} {
		set eduwiki_party_id [ad_conn user_id]
		db_dml insert_eduwiki_pages_map { *SQL* }
		eduwiki::set_eduwiki_permissions -eduwiki_page_id $eduwiki_page_id \
		    -eduwiki_category $eduwiki_category \
		    -eduwiki_visible_all_p $eduwiki_visible_all_p \
		    -eduwiki_editable_all_p $eduwiki_editable_all_p \
		    -eduwiki_create_all_p $eduwiki_create_all_p \
		    -eduwiki_index_p "t"
	    }	
	}

	# groups_category
	if { $eduwiki_category == "group" } {
	    if { [llength $eduwiki_groups] > 0 } {
		foreach eduwiki_group_id $eduwiki_groups {
		    set group_name [group::get_element -group_id $eduwiki_group_id -element "group_name"]
		    set eduwiki_group_title "$eduwiki_title ($group_name)"
		    set eduwiki_page_data [eduwiki::create_page -page_title $eduwiki_group_title]
		    set eduwiki_page_id [lindex $eduwiki_page_data 0]
		    if { ![empty_string_p $eduwiki_page_id] && ![empty_string_p $data_item_id] } {
			set eduwiki_party_id $eduwiki_group_id
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
	    
	    # redirect to group administration
	    ad_returnredirect [export_vars -base "groups-admin" {{eduwiki_id $data_item_id}}]
	    ad_script_abort

	}

	if { $eduwiki_category == "student" } {
	    db_foreach select_current_members { *SQL* } {
		set eduwiki_page_data [eduwiki::create_page -page_title $eduwiki_title]
		set eduwiki_page_id [lindex $eduwiki_page_data 0]
		if { ![empty_string_p $eduwiki_page_id] && ![empty_string_p $data_item_id] } {
		    set eduwiki_party_id $party_id
		    db_dml insert_eduwiki_pages_map { *SQL* }
		    eduwiki::set_eduwiki_permissions -eduwiki_page_id $eduwiki_page_id \
			-party_id $eduwiki_party_id \
			-eduwiki_category $eduwiki_category \
			-eduwiki_visible_all_p $eduwiki_visible_all_p \
			-eduwiki_editable_all_p $eduwiki_editable_all_p \
			-eduwiki_create_all_p $eduwiki_create_all_p \
			-eduwiki_index_p "t"
		}
	    }
	}


    } else {
	# edit eduwiki_task
	if { [::xo::db::Class exists_in_db -id $eduwiki_id] } {
	    set data_id [::xo::db::CrClass get_instance_from_db -revision_id $eduwiki_id]
	    $data_id set title $eduwiki_title
	    $data_id set description $eduwiki_description
	    $data_id set release_date $publish_date
	    $data_id set close_date $close_date
	    $data_id set eduwiki_visible_all_p $eduwiki_visible_all_p
	    $data_id set eduwiki_editable_all_p $eduwiki_editable_all_p
	    $data_id set eduwiki_create_all_p $eduwiki_create_all_p
	    $data_id set eduwiki_evaluation_related_p $eduwiki_evaluation_related_p
	    $data_id set parent_id $package_id
	    $data_id initialize_loaded_object
	    $data_id save
	    set data_item_id [$data_id set item_id]

	    # update eduwiki permissions
	    # get pages and set permissions
	    if { ![empty_string_p $data_item_id] } {
		db_foreach get_eduwiki_pages { *SQL* } {
    		    eduwiki::set_eduwiki_permissions -eduwiki_page_id $eduwiki_page_id \
			-party_id $eduwiki_party_id \
			-eduwiki_category $eduwiki_category \
			-eduwiki_visible_all_p $eduwiki_visible_all_p \
			-eduwiki_editable_all_p $eduwiki_editable_all_p \
			-eduwiki_create_all_p $eduwiki_create_all_p \
			-eduwiki_index_p $page_index_p

		    if {[permission::cache_p]} {
			#clean cache for eduwiki_page_id
			set pattern $eduwiki_page_id
			set cached_names [ns_cache names util_memoize]
			foreach name $cached_names {
			    if {[regexp -nocase -- $pattern $name match]} {
				ns_cache flush util_memoize $name
			    }
			}
		    }
		}
	    }


	    if { $eduwiki_category == "group" } {
		#update group pages permissions

		# redirect to group administration
		ad_returnredirect [export_vars -base "groups-admin" {{eduwiki_id $data_item_id}}]
		ad_script_abort
	    }

	}
    }

} -after_submit {
    ad_returnredirect "eduwiki-index"
    ad_script_abort
}


ad_return_template
