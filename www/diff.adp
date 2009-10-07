<master>
  <property name="title">@title;noquote@</property>
  <property name="&doc">property_doc</property>
  <property name="context">@context;noquote@</property>
  <property name="header_stuff">
  @header_stuff;noquote@
<style type='text/css'>
.added {
  color: green;
  text-decoration: underline;
}
.removed {
  color: red;
  text-decoration: line-through;
}
span.diff-deleted {color: red; text-decoration: line-through;}
span.diff-added {color: green;  text-decoration: underline;}
</style>
</property>

  <property name="head">
  @header_stuff;noquote@
<style type='text/css'>
.added {
  color: green;
  text-decoration: underline;
}
.removed {
  color: red;
  text-decoration: line-through;
}
span.diff-deleted {color: red; text-decoration: line-through;}
span.diff-added {color: green;  text-decoration: underline;}
</style>
</property>  
  <!-- The following DIV is needed for overlib to function! -->
  <div id="overDiv" style="position:absolute; visibility:hidden; z-index:1000;"></div>	

  <p><h2>#eduwiki.comparing#</h2> 
<ul>
<li>#eduwiki.version# @revision_id1@ #eduwiki.modified_by# @user1@ #eduwiki.at# @time1@ #eduwiki.with# 
<li>#eduwiki.version# @revision_id2@ #eduwiki.modified_by# @user2@ #eduwiki.at# @time2@
</ul>
  </p>
  <hr>

@content;noquote@

