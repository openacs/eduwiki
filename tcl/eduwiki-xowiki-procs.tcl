#/packages/eduwiki/tcl/eduwiki-xowiki-procs.tcl

::xo::library doc {

    Educational Wiki package procs

    @author Hector Amado (hr_amado@galileo.edu)
    @creation-date 2009-06-01
}

::xo::db::require package xowiki

namespace eval ::eduwiki {

    ::xo::PackageMgr create ::eduwiki::Package \
      -package_key "eduwiki" -pretty_name "Educational Wiki" \
      -superclass ::xowiki::Package

    Package instproc initialize {} {
	::xowiki::Link instmixin add ::eduwiki::EduWikiLink
	::xowiki::Page instmixin add ::eduwiki::EduWikiPage
	::xowiki::WikiForm instmixin add ::eduwiki::EduWikiForm
        next
    }

    Package instproc destroy {} {
	::xowiki::Link instmixin delete ::eduwiki::EduWikiLink
	::xowiki::Page instmixin delete ::eduwiki::EduWikiPage
	::xowiki::WikiForm instmixin delete ::eduwiki::EduWikiForm
        next
    }

    Package instproc return_page {
        {-adp:required}
        {-variables:required}
        {-form}
    } {
        foreach _var $variables {
            if {[llength $_var] == 2} {
                upvar [lindex $_var 0] [lindex $_var 0]
                upvar [string trim [lindex $_var 1] $] \
                        [string trim [lindex $_var 1] $]
            } else {
                upvar $_var [set _var]
            }
        }

	set activity_pages_p 1
	set page_title ""
	set index_link ""
	
        if {[exists_and_not_null item_id]} {
	    if {[exists_and_not_null context_package_id]} {
		set eduwiki_id [eduwiki::get_eduwiki_task_id -page_item_id $item_id]
		if { ![empty_string_p $eduwiki_id] } {
		    set party_id [eduwiki::get_eduwiki_party_id -eduwiki_id $eduwiki_id -page_item_id $item_id]
		    set index_link [$context_package_id make_link -privilege public -link "" $context_package_id {} {eduwiki_id $eduwiki_id} party_id]
		    set page_title "#eduwiki.activity_index#"
		} else {
		    set new_link ""
		    set page_title "#eduwiki.IndexPage#"
		    set index_link [$context_package_id make_link -privilege public -link "" $context_package_id {} {}]
		    set activity_pages_p 0
		    if {[ns_queryexists eduwiki_id]} {
			set title "#eduwiki.activity_index#"
			set eduwiki_id [ns_queryget eduwiki_id]
			set activity_pages_p 1
		    }
		}
	    }
	}

	lappend variables page_title activity_pages_p

        if {[exists_and_not_null form]} {
            upvar form [set form]
        } else {
            set form ""
        }

        return [next -adp $adp -variables $variables -form $form]
   }

    # instproc create_new_snippet
    Package instproc create_new_snippet {
	{-object_type ::xowiki::Page}
	provided_name
    } {
        #disable create_new_snippet
	return ""
    }

    # New class to store eduwiki_task_information

    ::xo::db::CrClass create EduwikiTask -superclass ::xo::db::CrItem \
	-pretty_name "Eduwiki Task" -pretty_plural "Eduwiki Tasks" \
	-table_name "eduwiki_tasks" -id_column "eduwiki_id" \
	-slots {
	    ::xo::db::CrAttribute create release_date \
		-datatype date \
		-sqltype timestamp
	    ::xo::db::CrAttribute create close_date \
		-datatype date \
		-sqltype timestamp
	    ::xo::Attribute create name \
		-required true
	    ::xo::db::CrAttribute create eduwiki_category \
		-datatype text \
		-sqltype varchar(15)
	    ::xo::db::CrAttribute create eduwiki_visible_all_p \
		-datatype text \
		-sqltype char(1) \
		-default "t"
	    ::xo::db::CrAttribute create eduwiki_editable_all_p \
		-datatype text \
		-sqltype char(1) \
		-default "t"
	    ::xo::db::CrAttribute create eduwiki_create_all_p \
		-datatype text \
		-sqltype char(1) \
		-default "t"
	    ::xo::db::CrAttribute create eduwiki_evaluation_related_p \
		-datatype text \
		-sqltype char(1) \
		-default "t"
	}

    # create various extra tables, indices and views                          

    ::xo::db::require table eduwiki_groups_map \
	"eduwiki_id integer references cr_items(item_id) on delete cascade,
         party_id integer references parties(party_id),
         constraint eduwiki_groups_map_pk primary key (eduwiki_id, party_id)"

    ::xo::db::require index -table eduwiki_groups_map -col eduwiki_id,party_id -unique true

    ::xo::db::require table eduwiki_pages_map \
	"eduwiki_id integer references cr_items(item_id) on delete cascade,
         page_id integer references cr_items(item_id) on delete cascade,
         party_id integer references parties(party_id),
         index_p char(1) default 'f',
         constraint eduwiki_pages_map_pk primary key (eduwiki_id, page_id, party_id),
         constraint eduwiki_pages_map_indexp_ck check(index_p in ('t','f'))"

    ::xo::db::require index -table eduwiki_pages_map -col eduwiki_id,page_id

    # extend Link functionality
    Class EduWikiLink

    EduWikiLink instproc render_not_found {href label} {
	if {$href eq ""} {
	    return \[$label\]
	} else {
	    return "<a style=\"color:#FF0000;\" href='$href'>$label</a>"
	}
    }

    Class EduWikiPage

    EduWikiPage instproc new_link {-name -title -nls_language page_package_id} {
	#check create permissions
	set item_id [my item_id]
	set base_url [$page_package_id package_url]
	if {[permission::permission_p -object_id $item_id -privilege create]} {
	    return [export_vars -base "${base_url}eduwiki-page-new" {name title nls_language item_id}]
	} else {
	    return ""
	}
    }

    # proc to hide delete revisions button
    EduWikiPage instproc revisions {} {
	my instvar package_id name title item_id
	set context [list [list [$package_id url] $title ] [_ xotcl-core.revisions]]
	set title "[_ eduwiki.revisions_history] '$title'"
	::xo::Page set_property doc title $title

	::TableWidget t1 -volatile \
	    -columns {
		Field version_number -label "" -html {align right}
		ImageAnchorField edit -label "" -src /resources/acs-subsite/Zoom16.gif \
		    -title "[_ eduwiki.view_eduwiki_page]" -alt  "view" \
		    -width 16 -height 16 -border 0
		AnchorField diff -label ""
		AnchorField author -label [_ file-storage.Author]
		Field content_size -label [_ file-storage.Size] -html {align right}
		Field last_modified_ansi -label [_ file-storage.Last_Modified]
		Field description -label [_ file-storage.Version_Notes] 
		ImageAnchorField live_revision -label [_ eduwiki.live_version] \
		    -src /resources/acs-subsite/radio.gif \
		    -width 16 -height 16 -border 0 -html {align center}
	    }
	
	set user_id [my current_user_id]
	set page_id [my set item_id]
	set live_revision_id [::xo::db::sql::content_item get_live_revision -item_id $page_id]
	my instvar package_id
	set base [$package_id url]
	set sql [::xo::db::sql select \
		     -map_function_names true \
		     -vars "ci.name, n.revision_id as version_id,\
                        person__name(n.creation_user) as author, \
                        n.creation_user as author_id, \
                        to_char(n.last_modified,'YYYY-MM-DD HH24:MI:SS') as last_modified_ansi,\
                        n.description,\
                        acs_permission__permission_p(n.revision_id,:user_id,'admin') as admin_p,\
                        acs_permission__permission_p(n.revision_id,:user_id,'delete') as delete_p,\
                        r.content_length,\
                        content_revision__get_number(n.revision_id) as version_number " \
		     -from "cr_revisionsi n, cr_items ci, cr_revisions r" \
		     -where "ci.item_id = n.item_id and ci.item_id = :page_id
             and r.revision_id = n.revision_id 
             and exists (select 1 from acs_object_party_privilege_map m
                         where m.object_id = n.revision_id
                          and m.party_id = :user_id
                          and m.privilege = 'read')" \
		     -orderby "n.revision_id desc"]
	
	db_foreach [my qn revisions_select] $sql {
	    if {$content_length < 1024} {
		if {$content_length eq ""} {set content_length 0}
		set content_size_pretty "[lc_numeric $content_length] [_ file-storage.bytes]"
	    } else {
		set content_size_pretty "[lc_numeric [format %.2f [expr {$content_length/1024.0}]]] [_ file-storage.kb]"
	    }
      
	    set last_modified_ansi [lc_time_system_to_conn $last_modified_ansi]
      
	    if {$version_id != $live_revision_id} {
		set live_revision "[_ eduwiki.make_as_current]"
		set live_revision_icon /resources/acs-subsite/radio.gif
	    } else {
		set live_revision "[_ eduwiki.view_current]"
		set live_revision_icon /resources/acs-subsite/radiochecked.gif
	    }
      
	    set live_revision_link [export_vars -base $base \
					{{m make-live-revision} {revision_id $version_id}}]
	    t1 add \
		-version_number $version_number: \
		-edit.href [export_vars -base $base {{revision_id $version_id}}] \
		-author $author \
		-content_size $content_size_pretty \
		-last_modified_ansi [lc_time_fmt $last_modified_ansi "%x %X"] \
		-description $description \
		-live_revision.src $live_revision_icon \
		-live_revision.title $live_revision \
		-live_revision.href $live_revision_link
	    
	    [t1 last_child] set payload(revision_id) $version_id
	}
    
	# providing diff links to the prevision versions. This can't be done in
	# the first loop, since we have not yet the revision id of entry in the next line.
	set lines [t1 children]
	for {set i 0} {$i < [llength $lines]-1} {incr i} {
	    set e [lindex $lines $i]
	    set n [lindex $lines [expr {$i+1}]]
	    set revision_id [$e set payload(revision_id)]
	    set compare_revision_id [$n set payload(revision_id)]
	    $e set diff.href [export_vars -base $base {{m diff} compare_revision_id revision_id}]
	    $e set diff "diff"
	}
	set e [lindex $lines end]
	if {$e ne ""} {
	    $e set diff.href ""
	    $e set diff ""
	}
	#set content [next]
	set content [t1 asHTML]

	array set property_doc [::xo::Page get_property doc]
	$package_id return_page -adp /packages/xowiki/www/revisions -variables {
	    content context {page_id $item_id} title property_doc
	}   
    }

    # proc to hide delete revisions button
    EduWikiPage instproc diff {} {

	my instvar package_id
	
	set compare_id [my query_parameter "compare_revision_id" 0]
	if {$compare_id == 0} {
	    return ""
	}
	::xo::Page requireCSS /resources/xowiki/xowiki.css
	set my_page [::xowiki::Package instantiate_page_from_id -revision_id [my revision_id]]
	$my_page volatile
	
	if {[catch {set html1 [$my_page render]} errorMsg]} {
	    set html2 "Error rendering [my revision_id]: $errorMsg"
	}
	set text1 [ad_html_text_convert -from text/html -to text/plain -- $html1]
	set user1 [::xo::get_user_name [$my_page set creation_user]]
	set time1 [$my_page set creation_date]
	set revision_id1 [$my_page set revision_id]
	regexp {^([^.]+)[.]} $time1 _ time1

	set other_page [::xowiki::Package instantiate_page_from_id -revision_id $compare_id]
	$other_page volatile
	#$other_page absolute_links 1
	
	if {[catch {set html2 [$other_page render]} errorMsg]} {
	    set html2 "Error rendering $compare_id: $errorMsg"
	}
	set text2 [ad_html_text_convert -from text/html -to text/plain -- $html2]
	set user2 [::xo::get_user_name [$other_page set creation_user]]
	set time2 [$other_page set creation_date]
	set revision_id2 [$other_page set revision_id]
	regexp {^([^.]+)[.]} $time2 _ time2
	
	set page_title [my set title]
	set title "[_ eduwiki.differences]"
	set context [list [list [$package_id url] $title ] [_ eduwiki.diff]]
	
	# try util::html diff if it is available and works
	if {[catch {set content [::util::html_diff -old $html2 -new $html1 -show_old_p t]}]} {
	    # otherwise, fall back to proven text based diff
	    set content [::xowiki::html_diff $text2 $text1]
	}

	::xo::Page set_property doc title $title
	array set property_doc [::xo::Page get_property doc]
	set header_stuff [::xo::Page header_stuff]
	
	$package_id return_page -adp /packages/eduwiki/www/diff -variables {
	    content title context header_stuff
	    time1 time2 user1 user2 revision_id1 revision_id2 property_doc
	}

    }

    Class create EduWikiForm -superclass ::xowiki::WikiForm \
        -parameter {
            {add_page_title [_ eduwiki.edit_eduwiki_page]}
            {edit_page_title [_ eduwiki.edit_eduwiki_page]}
        }

    Class create Policy -superclass ::xo::Policy

    Policy policy3 -contains {
    #
    # we require side wide admin rights for deletions
    # we perform checking on item_ids for pages. 
    #

    Class Package -array set require_permission {
      reindex             {{id admin}}
      rss                 none
      refresh-login       none
      google-sitemap      none
      google-sitemapindex none
      change-page-order   {{id admin}}
      manage-categories   {{id admin}}
      edit-category-tree  {{id admin}}
      delete              swa
      edit-new            {
	{{has_class ::xowiki::Object} swa} 
	{{has_class ::xowiki::FormPage} nobody}
	{{has_name {[.](js|css)$}} swa}
	{id create}
      }
    }
    
    Class Page -array set require_permission {
      view               {{item_id read}}
      revisions          {{item_id write}}
      diff               {{item_id write}}
      edit               {{item_id write}}
      make-live-revision {{item_id write}}
	delete-revision  {{item_id admin}}
	delete           {
	                  {item_id delete}
	                  {item_id admin}
	                 }
      save-tags          login
      popular-tags       login
      create-new         swa
      create-or-use      swa
    }

    Class Object -array set require_permission {
      edit               swa
    }
    Class File -array set require_permission {
      download           {{package_id read}}
    }
    Class Form -array set require_permission {
      create-new        swa
      create-or-use     swa
      list              {{item_id read}}
    }
  }


}