# /packages/eduwiki/www/admin/eduwiki-index.tcl

::eduwiki::Package initialize -ad_doc {
    This is the main page for the package.  It displays all of the EduwikiTasks and provides links to create, edit and delete EduwikiTasks.

    @author Hector Amado (hr_amado@galileo.edu)
    @creation-date 2009-06-10
    @cvs-id $Id$
} -parameter {
  {-orderby:optional "title,desc"}
}

set page_title "[_ eduwiki.Eduwiki_tasklist_]"
set context {}
# get limit_dates_p
set limit_dates_p [parameter::get -package_id $package_id \
		       -parameter with_limit_dates \
		       -default 0]

#
# We define a table with an action to add new items
#

TableWidget index -volatile \
    -set limit_dates_p $limit_dates_p \
    -actions "" \
    -columns {
	ImageField_EditIcon edit -label "" -html {style "padding-right: 2px;"}
	AnchorField title -label "[_ eduwiki.Eduwiki_Title_]" -orderby title
	if { [[my info parent] set limit_dates_p] } {
	    Field release_date -label "[_ eduwiki.Release_Date]" -orderby release_date
	    Field close_date -label "[_ eduwiki.Close_Date]" -orderby close_date
	}
	AnchorField eduwiki_category -label "[_ eduwiki.Category]" -orderby eduwiki_category
	AnchorField groups_admin -label ""
        ImageField_ViewIcon view -label ""
	ImageAnchorField publish_status -label "[_ eduwiki.enabled]" \
	                       -src /resources/acs-subsite/checkboxchecked.gif \
	                       -width 16 -height 16 -border 0 -html {align center}
    }

#
# to sort the items of the table, we take the values from the query parameter and
# use the orderby method of the table to achieve sorting.
#
foreach {att order} [split $orderby ,] break
index orderby -order [expr {$order eq "asc" ? "increasing" : "decreasing"}] $att

#
# The query selects all Eduwiki Tasks from the Package specific folder.
# Per default the following attributes are retrieved:
#  - item_id, name, publish_status, and object_type.  
#

db_foreach instance_select \
    [::eduwiki::EduwikiTask instance_select_query \
	 -parent_id $package_id \
         -from_clause ", eduwiki_tasks e" \
	 -select_attributes [list "object_id as eduwiki_id" publish_status title eduwiki_category creation_user \
             "to_char(release_date,'DD-MM-YYYY HH24:MI:SS') as release_date" \
             "to_char(close_date,'DD-MM-YYYY HH24:MI:SS') as close_date"]\
          -where_clause "e.eduwiki_id = acs_objects.object_id" \
    ] {
	set groups_admin ""
	set groups_adminhref ""
	if { $eduwiki_category == "student" } {
	    set eduwiki_category "#eduwiki.Student_category#"
	    set groups_admin "[_ eduwiki.students_admin]"
	    set groups_adminhref [export_vars -base "eduwiki-list" {{eduwiki_id $item_id}}]
	}
	if { $eduwiki_category == "professor"} {
	    set eduwiki_category "#eduwiki.Teacher_category#"
	}
	if { $eduwiki_category == "group" } {
	    set groups_admin "[_ eduwiki.Group_Admin]"
	    set groups_adminhref [export_vars -base "groups-admin" {{eduwiki_id $item_id}}]
	    set eduwiki_category "#eduwiki.Group_category#"
	}	

	if { $publish_status == "ready" } {
	    set publish_status_icon "/resources/acs-subsite/checkboxchecked.gif"
	    set publish_status_link [export_vars -base set-publish-state {item_id {publish_status "production"}}]
	    set publish_title "#eduwiki.disabled#"
	} else {
	    set publish_status_icon "/resources/acs-subsite/checkbox.gif"
	    set publish_status_link [export_vars -base set-publish-state {item_id {publish_status "ready"}}]
	    set publish_title "#eduwiki.enabled#"
	}

	if { $limit_dates_p } {
	 index add \
	  -title $title \
	  -title.href [export_vars -base "../" {{eduwiki_id $item_id}}] \
	  -release_date $release_date \
          -close_date $close_date \
          -eduwiki_category $eduwiki_category \
	  -groups_admin $groups_admin \
	  -groups_admin.href $groups_adminhref \
	  -edit.href [export_vars -base eduwiki-new {eduwiki_id}] \
	  -view.href [export_vars -base eduwiki-list {{eduwiki_id $item_id}}] \
	  -publish_status.href $publish_status_link \
	  -publish_status.title $publish_title \
	  -publish_status.src $publish_status_icon
	} else {
	 index add \
	  -title $title \
	  -title.href [export_vars -base "../" {{eduwiki_id $item_id}}] \
          -eduwiki_category $eduwiki_category \
	  -groups_admin $groups_admin \
	  -groups_admin.href $groups_adminhref \
	  -edit.href [export_vars -base eduwiki-new {eduwiki_id}] \
	  -view.href [export_vars -base eduwiki-list {{eduwiki_id $item_id}}] \
	  -publish_status.href $publish_status_link \
	  -publish_status.title $publish_title \
	  -publish_status.src $publish_status_icon
	}

    }


      if { [llength [$index children]] } {   
	  set html [index asHTML]
      } else {
	  set html "[_ eduwiki.There_are_not_eduwiki_activities]"
      }


