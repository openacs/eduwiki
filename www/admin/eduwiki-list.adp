<master>
  <property name="title">@page_title;noquote@</property>
  <property name="context">@context;noquote@</property>

<a href="eduwiki-index" class="button">#eduwiki.back#</a>
<br/>
<h2>#eduwiki.Eduwiki_task_Pages#</h2>
@html;noquote@
<br/>
<if @eduwiki_category@ eq "student">
    <if @html2@ not nil>
    	<h2>#eduwiki.Eduwiki_students_not_in_task#</h2>
	@html2;noquote@
    </if>
</if>
