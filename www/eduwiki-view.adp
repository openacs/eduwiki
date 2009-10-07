<master>
  <property name="title">@title;noquote@</property>
  <property name="context">@context;noquote@</property>
  <if @item_id@ not nil><property name="displayed_object_id">@item_id@</property></if> 
  <property name="&body">property_body</property>
  <property name="&doc">property_doc</property>
<br/><br/>
<!-- The following DIV is needed for overlib to function! -->
  <div id="overDiv" style="position:absolute; visibility:hidden; z-index:1000;"></div>	
<div class='xowiki-content'>
<div id='wikicmds'>
  <if @view_link@ not nil><a href="@view_link@" accesskey='v' title='#xowiki.view_title#'>#xowiki.view#</a> &middot; </if>
  <if @edit_link@ not nil><a href="@edit_link@" accesskey='e' title='#eduwiki.edit_eduwiki_page#'>#xowiki.edit#</a> &middot; </if>
  <if @rev_link@ not nil><a href="@rev_link@" accesskey='r' title='#eduwiki.show_revisions#'>#xotcl-core.revisions#</a> &middot; </if>
  <if @new_link@ not nil><a href="@new_link@" accesskey='n' title='#eduwiki.new_page#'>#eduwiki.new_page#</a> &middot; </if>
  <if @delete_link@ not nil><a href="@delete_link@" accesskey='d' title='#eduwiki.delete_title#'>#xowiki.delete#</a> &middot; </if>
  <if @admin_link@ not nil><a href="@admin_link@eduwiki-index" accesskey='a' title='#eduwiki.admin#'>#eduwiki.admin#</a> &middot; </if>
  <if @index_link@ not nil><a href="@index_link@" accesskey='i' title='#eduwiki.index_title#'>@page_title@</a></if>
</div>
 <if @page_context@ not nil><h1>@title@ (@page_context@)</h1></if>
 <else><h1>@title@</h1></else>

<div id="navbar" class="navbar">
     <if @activity_pages_p@ eq "1">
       <div style="font-size: 85%; background: url(/resources/xowiki/bw-shadow.png) no-repeat bottom right; margin-left: 2px; margin-top: 2px; padding: 0px 6px 6px 0px; width: 95%;">
     
     	 <div class="left_menu">
	      @top_includelets;noquote@
     	  </div>
       </div>
      </if>
</div>

   <div id="cont" class="cont_style">
      @content;noquote@
   </div>

@footer;noquote@
</div> <!-- class='xowiki-content' -->
