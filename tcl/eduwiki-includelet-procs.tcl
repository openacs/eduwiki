# /packages/eduwiki/tcl/eduwiki-includelet-procs.tcl

::xo::library doc {
  Eduwiki - includelet definitions

  @author Hector Amado (hr_amado@galileo.edu)
  @creation-date 2009-07-16
}

::xo::db::require package xowiki

namespace eval ::xowiki::includelet {
  #
  # Define additional elements for includelets
  # eduwiki-activities-pages
  # activity-pages
  # activity-info

  #
  # Create an includelet called eduwiki-activities-pages, to present the pages for the activity
  # 

  ::xowiki::IncludeletClass create eduwiki-activities-pages \
      -superclass ::xowiki::Includelet \
      -parameter {
	  {title "#eduwiki.activities#"}
        {parameter_declaration {
          {-eduwiki_id ""}
          {-orderby "title,desc"}
          {-menu_buttons edit}
          {-locale ""}
	  {-range ""}
        }}
      }

  eduwiki-activities-pages instproc render {} {
    my get_parameters

    my instvar __including_page
    ::xo::Page requireCSS "/resources/acs-templating/lists.css"
    set admin_p [::xo::cc permission -object_id $package_id -privilege admin \
                     -party_id [::xo::cc set untrusted_user_id]]
    set show_heritage $admin_p

    lappend ::xowiki_page_item_id_rendered [$__including_page item_id]
    $__including_page set __is_book_page 1

    foreach {locale locale_clause} \
        [::xowiki::Includelet locale_clause -revisions p -items p $package_id $locale] break

    set return_url [::xo::cc url]
    # eduwiki_category
    set ecategory ""
 
      if { ![empty_string_p $eduwiki_id] } {
	  # show activity related pages
	  if {[::xo::db::Class exists_in_db -id $eduwiki_id]} { 
	      set eduwiki_item_id [::eduwiki::EduwikiTask get_instance_from_db -item_id $eduwiki_id]
	      set ecategory [$eduwiki_item_id set eduwiki_category]
	  }

	  TableWidget index -volatile \
	      -actions "" \
	      -columns {
		  AnchorField title -label "[_ eduwiki.Eduwiki_Title_]" -orderby title
		  Field creator -label "[_ eduwiki.Eduwiki_creator_]" -orderby creator
	      }

	  foreach {att order} [split $orderby ,] break
	  index orderby -order [expr {$order eq "asc" ? "increasing" : "decreasing"}] $att

	  #
	  # The query selects all Eduwiki Pages from the Package specific folder.
	  # Per default the following attributes are retrieved:
	  #  - item_id, name, publish_status, and object_type.  
	  #
	  set folder_id [$package_id folder_id]
	  set where_clause "e.page_id = ci.item_id and e.index_p = 't'"
	  if { ![empty_string_p $eduwiki_id] } {
	      append where_clause " and e.eduwiki_id = :eduwiki_id"
	  }
	  # check publish_status
	  append where_clause " and ci.publish_status = 'ready'"

	  db_foreach instance_select \
	      [::xowiki::Page instance_select_query \
		   -parent_id $folder_id \
		   -from_clause ", eduwiki_pages_map e" \
		   -select_attributes [list "bt.revision_id as page_id" title creation_user party_id ]\
		   -where_clause $where_clause \
		  ] {

		      if { [permission::permission_p -object_id $item_id -privilege read] } {
			  set page_url "./$name"
			  if {![empty_string_p $party_id] } {
			      set creator [eduwiki::get_party_name -party_id $party_id]
			  } else {
			      set creator ""
			  }
			  index add \
			      -title $title \
			      -title.href [export_vars -base $page_url {{m view}}] \
			      -creator $creator
		      }
		  }
      } else {
	  my set title "#eduwiki.activities#"
	  # show eduwiki activities
	  TableWidget index -volatile \
	      -actions "" \
	      -columns {
		  AnchorField title -label "[_ eduwiki.Eduwiki_Title_]" -orderby title
	      }
	  foreach {att order} [split $orderby ,] break
	  index orderby -order [expr {$order eq "asc" ? "increasing" : "decreasing"}] $att
	  set folder_id [$package_id folder_id]
	  set user_id [::xo::cc user_id]

	  db_foreach instance_select \
	      [::eduwiki::EduwikiTask instance_select_query \
		   -parent_id $package_id \
		   -from_clause ", eduwiki_tasks e" \
		   -select_attributes [list "object_id as eduwiki_id" title eduwiki_category creation_user \
					   "to_char(release_date,'DD-MM-YYYY HH24:MI:SS') as release_date" \
					   "to_char(close_date,'DD-MM-YYYY HH24:MI:SS') as close_date"]\
		   -where_clause "e.eduwiki_id = acs_objects.object_id and ci.publish_status = 'ready'" \
		  ] {
		    
		      set page_url [eduwiki::get_best_eduwiki_page_url -eduwiki_id $item_id \
					                               -user_id $user_id \
					                               -folder_id $folder_id \
					                               -eduwiki_category $eduwiki_category]
		      if {[empty_string_p $page_url]} {
			  set page_url "./"
			  set page_url [export_vars -base $page_url {{eduwiki_id $item_id}}]
		      } else {
			  set page_url "./$page_url"
			  set page_url [export_vars -base $page_url {{m view}}]
		      }


		      index add \
			  -title $title \
			  -title.href $page_url
		      }

      }
      
      if { [llength [$index children]] } {
	  if { ![empty_string_p $eduwiki_id] } {
	      if {$ecategory == "student"} {
		  my set title #eduwiki.activities_by_other_students#
	      } 
	      if {$ecategory == "group"} {
		  my set title #eduwiki.activities_by_other_groups#
	      }
	  }

	  return [index asHTML]
	  
      } else {
	  return "[_ eduwiki.There_are_not_eduwiki_activities]"
      }

  }
######
## activity-pages

  ::xowiki::IncludeletClass create activity-pages \
      -superclass ::xowiki::Includelet \
      -parameter {
	  {title "#eduwiki.Eduwiki_task_Pages#"}
        {parameter_declaration {
          {-eduwiki_id ""}
          {-party_id ""}
          {-orderby "title,desc"}
          {-menu_buttons edit}
          {-locale ""}
	  {-range ""}
        }}
      }

  activity-pages instproc render {} {
    my get_parameters

    my instvar __including_page
    ::xo::Page requireCSS "/resources/acs-templating/lists.css"
    template::head::add_css -href "/resources/eduwiki/xowiki.css"
    set admin_p [::xo::cc permission -object_id $package_id -privilege admin \
                     -party_id [::xo::cc set untrusted_user_id]]
    set show_heritage $admin_p
    set activity_pages_p 0

    lappend ::xowiki_page_item_id_rendered [$__including_page item_id]
    $__including_page set __is_book_page 1

      set page_item_id [$__including_page item_id]
      #set party_id
      if {![empty_string_p $page_item_id]} {
	  if {[empty_string_p $eduwiki_id]} {
	      set eduwiki_id [eduwiki::get_eduwiki_task_id -page_item_id $page_item_id]
	  }

	  if {![empty_string_p $eduwiki_id] && [empty_string_p $party_id] } {
	      set party_id [eduwiki::get_eduwiki_party_id -eduwiki_id $eduwiki_id -page_item_id $page_item_id]
	  }

      }
      # check for index activity page
      if {![empty_string_p $page_item_id] && ![empty_string_p $eduwiki_id]} {
	  set index_eduwiki_id [eduwiki::get_eduwiki_task_id -page_item_id $page_item_id]
	  if { [empty_string_p $index_eduwiki_id] } {
	      set activity_pages_p 1
	  }
      }


      foreach {locale locale_clause} \
        [::xowiki::Includelet locale_clause -revisions p -items p $package_id $locale] break

      set return_url [::xo::cc url]

      if { !$activity_pages_p } {

	  TableWidget index -volatile \
	      -actions "" \
	      -columns {
		  AnchorField title -label "[_ eduwiki.Page_Title_]"
	      }

	  #
	  # The query selects all Eduwiki Pages from the Activity
	  # Per default the following attributes are retrieved:
	  #  - item_id, name, publish_status, and object_type.  
	  #
	  set folder_id [$package_id folder_id]
	  set where_clause "e.page_id = ci.item_id"
	  set eduwiki_category "professor"
	  if { ![empty_string_p $eduwiki_id] } {
	      append where_clause " and e.eduwiki_id = :eduwiki_id"
	  }
	  if { ![empty_string_p $party_id] } {
	      append where_clause " and e.party_id = :party_id"
	  }
	  if { ![empty_string_p $eduwiki_id] } {
	      # get eduwiki_category
	      set eduwiki_task_id [content::item::get_live_revision -item_id $eduwiki_id]
	      if {![empty_string_p $eduwiki_task_id]} {
		  set data_id [::xo::db::CrClass get_instance_from_db -revision_id $eduwiki_task_id]
		  set eduwiki_category [$data_id set eduwiki_category]
	      }
	  }
      
	  # check publish_status
	  append where_clause " and ci.publish_status = 'ready'"

	  set user_id [::xo::cc user_id]
	  db_foreach instance_select \
	      [::xowiki::Page instance_select_query \
		   -parent_id $folder_id \
		   -from_clause ", eduwiki_pages_map e" \
		   -select_attributes [list "bt.revision_id as page_id" title creation_user "e.party_id as creator_id" index_p]\
		   -where_clause $where_clause \
		  ] {
		      
		      if { [permission::permission_p -object_id $item_id -privilege read] } {
			  set page_url "./$name"
			  if { $index_p } {
			      if {![empty_string_p $creator_id] } {
				  set creator [eduwiki::get_party_name -party_id $creator_id]
			      } else {
				  set creator ""
			      }
			  } else {
			      if {![empty_string_p $creation_user] } {
				  set creator [eduwiki::get_party_name -party_id $creation_user]
			      } else {
				  set creator ""
			      }
			  }

			  if { ![empty_string_p $party_id] } {
			      index add \
				  -title $title \
				  -title.href [export_vars -base $page_url {{m view}}] 
			  } else {
			      if { $eduwiki_category == "professor" } {
				  #category professor
				  index add \
				      -title $title \
				      -title.href [export_vars -base $page_url {{m view}}] 
			      } elseif { $eduwiki_category == "student" } {
				  #category student
				  if { $user_id == $creator_id } {
				      index add \
					  -title $title \
					  -title.href [export_vars -base $page_url {{m view}}] 
				  }
			      } else {
				  #category group , check if member
				  if {[group::member_p -user_id $user_id -group_id $creator_id]} {
				      index add \
					  -title $title \
					  -title.href [export_vars -base $page_url {{m view}}] 
				  }
			      }
			  }
		      }
		  }
      } else {

	  my set title "#eduwiki.activities#"
	  # show eduwiki activities
	  TableWidget index -volatile \
	      -actions "" \
	      -columns {
		  AnchorField title -label "[_ eduwiki.Eduwiki_Title_]" -orderby title
	      }
	  foreach {att order} [split $orderby ,] break
	  index orderby -order [expr {$order eq "asc" ? "increasing" : "decreasing"}] $att
	  set folder_id [$package_id folder_id]
	  set user_id [::xo::cc user_id]

	  db_foreach instance_select \
	      [::eduwiki::EduwikiTask instance_select_query \
		   -parent_id $package_id \
		   -from_clause ", eduwiki_tasks e" \
		   -select_attributes [list "object_id as eduwiki_id" title eduwiki_category creation_user \
					   "to_char(release_date,'DD-MM-YYYY HH24:MI:SS') as release_date" \
					   "to_char(close_date,'DD-MM-YYYY HH24:MI:SS') as close_date"]\
		   -where_clause "e.eduwiki_id = acs_objects.object_id and ci.publish_status = 'ready'" \
		  ] {
		    
		      set page_url [eduwiki::get_best_eduwiki_page_url -eduwiki_id $item_id \
					                               -user_id $user_id \
					                               -folder_id $folder_id \
					                               -eduwiki_category $eduwiki_category]
		      if {[empty_string_p $page_url]} {
			  set page_url "./"
			  set page_url [export_vars -base $page_url {{eduwiki_id $item_id}}]
		      } else {
			  set page_url "./$page_url"
			  set page_url [export_vars -base $page_url {{m view}}]
		      }


		      index add \
			  -title $title \
			  -title.href $page_url
		      }

      }

      set output ""
      if { ![empty_string_p $eduwiki_id] } {
	  if { [llength [$index children]] } {
	      set output [index asHTML]
	      #append autor
	      if {![empty_string_p $party_id] } {
		  set creator [eduwiki::get_party_name -party_id $party_id]
		  append output "<b>#eduwiki.Eduwiki_creator_#:</b> $creator<br/>"
	      }
	      set description_link [$package_id make_link -privilege public -link "" $package_id {} eduwiki_id party_id]
	      set title_desc_link "#eduwiki.View_activity_description#"
	      if { $eduwiki_category == "student"} {
		  set title_desc_link "#eduwiki.view_activities_by_other_students#"
	      }
	      if { $eduwiki_category == "group"} {
		  set title_desc_link "#eduwiki.view_activities_by_other_groups#"
	      }
	      append output "<br/><a href=\"$description_link\" >$title_desc_link</a><br/>"
	      if { $activity_pages_p } {
		  set output [index asHTML]
	      }

	      return $output
	  } else {
	      return "[_ eduwiki.select_eduwiki_to_see_pages]"
	  }
      } else {
	  return "[_ eduwiki.select_eduwiki_to_see_pages]"
      }

  }

######
## activity-info

  ::xowiki::IncludeletClass create activity-info \
      -superclass ::xowiki::Includelet \
      -parameter {
	  {__decoration portlet}
	  {title "#eduwiki.Eduwiki_task_Info#"}
        {parameter_declaration {
          {-eduwiki_id ""}
          {-menu_buttons edit}
          {-locale ""}
	  {-range ""}
        }}
      }

  activity-info instproc render {} {
    my get_parameters

    my instvar __including_page
    ::xo::Page requireCSS "/resources/acs-templating/lists.css"
    set admin_p [::xo::cc permission -object_id $package_id -privilege admin \
                     -party_id [::xo::cc set untrusted_user_id]]
    set show_heritage $admin_p

    lappend ::xowiki_page_item_id_rendered [$__including_page item_id]
    $__including_page set __is_book_page 1

    foreach {locale locale_clause} \
        [::xowiki::Includelet locale_clause -revisions p -items p $package_id $locale] break

      set return_url [::xo::cc url]
      set output ""
      if {[exists_and_not_null eduwiki_id] && [::xo::db::Class exists_in_db -id $eduwiki_id]} {
	  set eduwiki_id [::eduwiki::EduwikiTask get_instance_from_db -item_id $eduwiki_id]
	  set description [$eduwiki_id set description]
	  set title [$eduwiki_id set title]
	  set eduwiki_category [$eduwiki_id set eduwiki_category]
	  set release_date [$eduwiki_id set release_date]
	  set close_date [$eduwiki_id set close_date]
	  append output "<b>#eduwiki.Eduwiki_Title_# :</b> $title <br/>"

	  append output "<b>#eduwiki.Eduwiki_Descripti# :</b> "
	  if { [llength $description] == 2 } {
	      set contents [lindex $description 0]
	      set format [lindex $description 1]
		  # if format is specified
		  append output $contents
		  return $output
	  }
	  append output $description
	  return $output
      } else {
	  my set title "#eduwiki.IndexPage#"
	  return "[_ eduwiki.Eduwiki_instructions]"
      }

  }

######
}
