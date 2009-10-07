<master>
	<property name="title">@page_title;noquote@</property>
	<property name="context">@context;noquote@</property>

<a href="@cancel_url@" class="button">#eduwiki.back#</a>
<h2>#eduwiki.Group_Admin# <if @eduwiki_title@ not nil>: @eduwiki_title@</if></h2>
<div id="container" class="contStandard">
<formtemplate id="eduwiki_groups">
<!-- Form elements -->
     <div id="topgrupos" style="float:left;width:100%;margin:10px;">
         <div style="float:left;margin:3px;">
	    <label for="eduwiki_groups_actualgroups">
    	    <p><b>#eduwiki.Groups_selected_#</b></p>
     	    </label>
     	    <formwidget id="eduwiki_groups_actualgroups">
     	    <br/><br/>
<a href="javascript:;" onclick="add_group();" id="control_addgroup" class="button">#eduwiki.Add_Group_#</a>
	    <if @group_ids@ not nil><a href="javascript:;" onclick="remove_group();" id="control_removegroup" class="button">#eduwiki.Delete_group_#</a></if>
     	    <div id="groupaddcontainer" style="visibility:hidden;">
	     <br/><br/>
	      #eduwiki.Group_name_# 
	     <formwidget id="eduwiki_group_name"><br/><br/><a href="javascript:;" onclick="add_check_group();" class="button">#eduwiki.Add_task_Group_#</a>&nbsp;<a href="javascript:;" onclick="cancel_add_group();" class="button">#eduwiki.Cancel_#</a>
     	    </div>
     	 </div>
     </div>
     
     <div id="members" style="float:left;width:100%;margin:10px;">
     	  <div style="float:left;margin:3px;">
		<label for="eduwiki_groups_comm_members">
		<p><b>#eduwiki.Comm_Members_#</b></p>
      	        </label>
		<center>
		<formwidget id="eduwiki_groups_comm_members">
		</center>
          </div>
	  <div style="float:left;margin:3px;">
<br/><br/><br/>
	  <center>
<a href="javascript:;" onclick="add_group_member();" id="add_member"><img src="/resources/acs-subsite/stock_right.png" alt="#eduwiki.Add_Member_#" title="#eduwiki.Add_Member_#"></a><br/>
<a href="javascript:;" onclick="remove_group_member();" id="remove_member"><img src="/resources/acs-subsite/stock_left.png" alt="#eduwiki.Remove_Member_#" title="#eduwiki.Remove_Member_#"></a><br/>
          </center>
	  </div>
          <div style="float:left;margin:1px;align:center;">
     	       <label for="eduwiki_groups_members">
      	       <p><b>#eduwiki.Group_members_#</b><if @group_name@ not nil><b> : @group_name@</b></if></p>
     	       </label>
	       <center>
     	       <formwidget id="eduwiki_groups_members">
	       </center>
     	  </div>
     </div>
</formtemplate>
<br/>
<a href="@cancel_url@" class="button">#eduwiki.finish#</a>
<br/<br/>
</div>


