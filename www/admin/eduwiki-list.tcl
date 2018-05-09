# /packages/eduwiki/www/admin/eduwiki-list.tcl

::eduwiki::Package initialize -ad_doc {
    This is the main page for eduwiki pages lists..  It displays all of the EduwikiTasks Pages and provides links to acces, edit and delete Pages.

    @author Hector Amado (hr_amado@galileo.edu)
    @creation-date 2009-07-14
    @cvs-id $Id$
} -parameter {
    {-eduwiki_id:integer,required}  
  {-orderby:optional "title,desc"}
}

set page_title "[_ eduwiki.Eduwiki_pageslist_]"
set context [list]
set community_id [dotlrn_community::get_community_id]

# get eduwiki_category
set eduwiki_category "professor"
if {[exists_and_not_null eduwiki_id] && [::xo::db::Class exists_in_db -id $eduwiki_id]} {
    set eduwiki_item_id [::eduwiki::EduwikiTask get_instance_from_db -item_id $eduwiki_id]
    set eduwiki_category [$eduwiki_item_id set eduwiki_category]
}

#
# We define a table
#

TableWidget index -volatile \
    -actions "" \
    -columns {
      AnchorField title -label "[_ eduwiki.Page_Title_]" -orderby title
      Field creator -label "[_ eduwiki.Eduwiki_creator_]"
      ImageField_EditIcon edit -label "" -html {style "padding-right: 2px;"}
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
# The query selects all Eduwiki Pages from the Package specific folder.
# Per default the following attributes are retrieved:
#  - item_id, name, publish_status, and object_type.  
#
set folder_id [$package_id folder_id]

db_foreach instance_select \
    [::xowiki::Page instance_select_query \
	 -parent_id $folder_id \
         -from_clause ", eduwiki_pages_map e" \
	 -select_attributes [list "bt.revision_id as page_id" publish_status title creation_user "e.party_id as creator_id"]\
         -where_clause "e.page_id = ci.item_id and e.eduwiki_id = :eduwiki_id and e.index_p = 't'" \
    ] {

	set page_url "../$name"
	if {![empty_string_p $creator_id] } {
	    set creator [eduwiki::get_party_name -party_id $creator_id]
	} else {
	    set creator ""
	}

	if { $publish_status == "ready" } {
	    set publish_status_icon "/resources/acs-subsite/checkboxchecked.gif"
	    set publish_status_link [export_vars -base set-item-publish-state {item_id eduwiki_id {publish_status "production"}}]
	    set publish_title "#eduwiki.disabled#"
	} else {
	    set publish_status_icon "/resources/acs-subsite/checkbox.gif"
	    set publish_status_link [export_vars -base set-item-publish-state {item_id eduwiki_id {publish_status "ready"}}]
	    set publish_title "#eduwiki.enabled#"
	}

	index add \
	  -title $title \
	  -title.href [export_vars -base $page_url {{m view}}] \
	  -creator $creator \
	  -edit.href [export_vars -base $page_url {{m edit}}] \
	  -publish_status.href $publish_status_link \
	  -publish_status.title $publish_title \
	  -publish_status.src $publish_status_icon
    }


set html [index asHTML]

# get students not in activity

TableWidget index2 -volatile \
    -actions "" \
    -columns {
      Field creator -label "[_ eduwiki.Eduwiki_student_]"
      ImageAnchorField add -label "[_ eduwiki.student_add_to_eduwiki]" \
	                       -src /resources/acs-subsite/Add16.gif \
	                       -width 16 -height 16 -border 0 -html {align center}
    }

if {$eduwiki_category == "student"} {
    db_foreach get_students_not_in_activity { *SQL* } {
	index2 add \
	    -creator $student_name \
	    -add.title "[_ eduwiki.student_add_to_eduwiki]" \
	    -add.href [export_vars -base "member-task-add" {student_id eduwiki_id}] 
    }

    if { [llength [$index2 children]] } {
	set html2 [index2 asHTML]
    } else {
	set html2 ""
    }
}
