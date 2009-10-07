/*
 * Javascript Functions for group administration
 * Eduwiki Package
 */

	function add_group_member() {
	 var selected_members = document.getElementById('eduwiki_groups_comm_members').options;
	 var selected_members_list = ""
	 var selected_members_count = 0

	 for ( i=0; i<selected_members.length; i++) {
	    if (selected_members[i].selected == true) {
	      selected_members_list = selected_members_list + " " + selected_members[i].value;
	      selected_members_count++;  
 	    }
  	 }
	 selected_members_list = selected_members_list.replace(/^\s|\s+$/g, '');
	 // get selected group_id
	 var selected_groups = document.getElementById('eduwiki_groups_actualgroups').options;
	 var eduwiki_id = document.getElementById('eduwiki_id').value;
	 var selected_groups_list = ""
	 var selected_groups_count = 0
	 for ( i=0; i<selected_groups.length; i++) {
	    if (selected_groups[i].selected == true) {
	      selected_groups_list = selected_groups[i].value;
	      selected_groups_count++; 
 	    }
  	 }

	 if (selected_members_count > 0) { 
	   if (selected_groups_count == 0) {
	         var msg_group1 = "You must select a group to add members"; 
	         alert(msg_group1);
	   } else {
	     if (selected_groups_count == 1) {
	         var selected_group_id = selected_groups_list;

		 document.getElementById('eduwiki_action').value = "member_add";
		 document.eduwiki_groups.submit();
	     } else {
	         alert("You must select only one group"); 
	     } 
	   }
	 } else {
            alert("You must select at least one member");
	 }
	}

	function remove_group_member() {
	 var selected_members = document.getElementById('eduwiki_groups_members').options;
	 var selected_members_list = ""
	 var selected_members_count = 0

	 for ( i=0; i<selected_members.length; i++) {
	    if (selected_members[i].selected == true) {
	      selected_members_list = selected_members_list + " " + selected_members[i].value;
	      selected_members_count++;  
 	    }
  	 }
	 selected_members_list = selected_members_list.replace(/^\s|\s+$/g, '');
	 // get selected group_id
	 var selected_groups = document.getElementById('eduwiki_groups_actualgroups').options;
	 var eduwiki_id = document.getElementById('eduwiki_id').value;
	 var selected_groups_list = ""
	 var selected_groups_count = 0
	 for ( i=0; i<selected_groups.length; i++) {
	    if (selected_groups[i].selected == true) {
	      selected_groups_list = selected_groups[i].value;
	      selected_groups_count++; 
 	    }
  	 }

	 if (selected_members_count > 0) { 
	   if (selected_groups_count == 0) {
	         alert("You must select a group to remove members");
	   } else {
	     if (selected_groups_count == 1) {
	         var selected_group_id = selected_groups_list;

		 document.getElementById('eduwiki_action').value = "member_remove";
		 document.eduwiki_groups.submit();  
	     } else {
	         alert("You must select only one group"); 
	     } 
	   }
	 } else {
            alert("You must select at least one member");
	 }
	}

	function add_group_to_task() {
	 // get selected group_id
	 var selected_groups = document.getElementById('eduwiki_groups_actualgroups').options;
	 var eduwiki_id = document.getElementById('eduwiki_id').value;
	 var selected_groups_list = ""
	 var selected_groups_count = 0
	 for ( i=0; i<selected_groups.length; i++) {
	    if (selected_groups[i].selected == true) {
	      selected_groups_list = selected_groups[i].value;
	      selected_groups_count++; 
 	    }
  	 }

	   if (selected_groups_count == 0) {
	         alert("You must select a group");
	   } else {
	       document.getElementById('eduwiki_action').value = "group_to_task_add";
	       document.eduwiki_groups.submit();
	   }

	}

	function remove_group_from_task() {

	 // get selected group_id
	 var selected_groups = document.getElementById('eduwiki_task_groups').options;
	 var eduwiki_id = document.getElementById('eduwiki_id').value;
	 var selected_groups_list = ""
	 var selected_groups_count = 0
	 for ( i=0; i<selected_groups.length; i++) {
	    if (selected_groups[i].selected == true) {
	      selected_groups_list = selected_groups[i].value;
	      selected_groups_count++; 
 	    }
  	 }

          if (selected_groups_count == 0) {
	        alert("You must select a group");
	  } else {
	       document.getElementById('eduwiki_action').value = "group_to_task_remove";
	       document.eduwiki_groups.submit();
	   }

	}

	function add_group() {
	    // set visibility
	    document.getElementById('groupaddcontainer').style.visibility="visible";
	}

        function cancel_add_group() {
	    document.getElementById('groupaddcontainer').style.visibility="hidden";
	    document.getElementById('eduwiki_group_name').value = "";
	}

	function add_check_group() {
            document.getElementById('eduwiki_action').value = "add_group";
	    document.eduwiki_groups.submit();
	}

	function remove_group() {
	    // get selected group_id
	    var selected_groups = document.getElementById('eduwiki_groups_actualgroups').options;
	    var selected_groups_list = "";
	    var selected_groups_count = 0;
	    for ( i=0; i<selected_groups.length; i++) {
		if (selected_groups[i].selected == true) {
		    selected_groups_list = selected_groups[i].value;
		    selected_groups_count++; 
		}
	    }

	    if (selected_groups_count == 0) {
		var msg_group1 = "You must select a group to remove";
		alert(msg_group1);
	    } else {
		if (selected_groups_count == 1) {
		    document.getElementById('eduwiki_action').value = "delete_group";
	    	    document.eduwiki_groups.submit();
		} else {
		    alert("You must select only one group to remove");
		}
	    }
	}


/*
 *  End of functions
 */