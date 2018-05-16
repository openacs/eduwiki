# /packages/eduwiki/tcl/apm-callback-procs.tcl

ad_library {

    @author Hector Amado (hr_amado@galileo.edu)
    @creation-date 2009-07-22
}

::xo::db::require package xowiki

namespace eval eduwiki::apm {}

ad_proc -public eduwiki::apm::after_mount {
    {-package_id:required}
    {-node_id:required}
} {
    Set eduwiki pages permissions
} {

   ::xowiki::Package initialize -package_id $package_id

   # set eduwiki permissions
   if { [permission::inherit_p -object_id $package_id] } {
        permission::toggle_inherit -object_id $package_id
   }

   # set admin_rels
   set sw_group_id [application_group::group_id_from_package_id -package_id [ad_conn subsite_id]]
   set rel_id [group::get_rel_segment -group_id $sw_group_id -type admin_rel]
   permission::grant -object_id $package_id -party_id $rel_id -privilege admin

   # set dotlrn_admin_rel
   set comm_id [dotlrn_community::get_community_id]
   set rel_id [group::get_rel_segment -group_id $comm_id -type dotlrn_admin_rel]
   permission::grant -object_id $package_id -party_id $rel_id -privilege admin
        
   # set dotlrn_member_rel
   set rel_id [group::get_rel_segment -group_id $comm_id -type dotlrn_member_rel]
   permission::grant -object_id $package_id -party_id $rel_id -privilege read

    set root_directory [acs_root_dir]
    set prototypes_path "$root_directory/packages/eduwiki/www/prototypes"
    set folder_id [content::folder::get_folder_from_package \
		      -package_id $package_id]

    # set object_id
    set folder_object_id [content::item::get_id_by_name \
                    -name "::$folder_id"\
			     -parent_id $folder_id]
    set p [::xowiki::Package instantiate_page_from_id -item_id $folder_object_id]
    set editor_page [source "${prototypes_path}/editor.page"]
    $p set text [$editor_page set text]
    $p save

    # set index
    set index "$prototypes_path/index.page"
    set lang_prefix [string range [lang::system::locale] 0 1]
    set index_name "${lang_prefix}:index"
    if {[file readable $index]} {
	set page [source $index]
	$page configure -name $index_name \
	    -parent_id $folder_id -package_id $package_id
	$page set nls_language [lang::system::locale]
	$page destroy_on_cleanup
	$page initialize_loaded_object
	$page save_new
	set item_id [$page set item_id]
	#set index permissions
	if { [permission::inherit_p -object_id $item_id] } {
	    permission::toggle_inherit -object_id $item_id
	}

	# set admin_rels
	set sw_group_id [application_group::group_id_from_package_id -package_id [ad_conn subsite_id]]
	set rel_id [group::get_rel_segment -group_id $sw_group_id -type admin_rel]
	permission::grant -object_id $item_id -party_id $rel_id -privilege admin

	# set dotlrn_admin_rel
	set comm_id [dotlrn_community::get_community_id]
	set rel_id [group::get_rel_segment -group_id $comm_id -type dotlrn_admin_rel]
	permission::grant -object_id $item_id -party_id $rel_id -privilege read

	# set dotlrn_member_rel
	set rel_id [group::get_rel_segment -group_id $comm_id -type dotlrn_member_rel]
	permission::grant -object_id $item_id -party_id $rel_id -privilege read
    }
}

