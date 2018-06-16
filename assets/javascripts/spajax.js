var row_id = 0;
var parentId = 1;
var addChild = false;
$(document).ready(function()
{	
	$('.date').each(function() {
        $(this).datepicker({ dateFormat: 'yy-mm-dd' });
	});
	var table = document.getElementById('timeEntryTable');
	if(document.getElementById('timeEntryTable') != null)
	{
		var rowlength = table.rows.length;
		for(var i =0; i< rowlength; i++)
		{
			projectId = "#project_id"+i;
			issueId = "#issue_id"+i;
			memberId = "#member_id"+i;
			ddAutoComplete(projectId, true);
			ddAutoComplete(issueId, false);
			ddAutoComplete(memberId, false);
		}
	
	}
	
});

function loadDD(itemStr, dropdown, needBlankOption, skipFirst, blankText)
{
	var items = itemStr.split('\n');
	var i, index, val, text, start;
	if(dropdown != null){
		dropdown.options.length = 0;
		if(needBlankOption){
			dropdown.options[0] = new Option(blankText, "", false, false) 
		}
		for(i=0; i < items.length-1; i++){
			index = items[i].indexOf(',');
			if(skipFirst){
				if(index != -1){
					start = index+1;
					index = items[i].indexOf(',', index+1);
				}
			}else{
				start = 0;
			}
			if(index != -1){
				val = items[i].substring(start, index);
				text = items[i].substring(index+1);
				dropdown.options[needBlankOption ? i+1 : i] = new Option( 
					text, val, false, false);
			}
		}
	}
}

function cpyBranchChanged(curDDId, changeDDId,  needBlank, type, projectBlank, loadMember)
{	
	var currDD = document.getElementById(curDDId);
	var needBlankOption = needBlank;
	var changeDD = document.getElementById(changeDDId);	
	var cpyId = "";
	if(document.getElementById('company_id') != null)
	{
		cpyId = document.getElementById('company_id').value;
	}
	var $this = $(this);
	$.ajax({
	url: cpybranchUrl,
	type: 'get',
	data: {id: currDD.value, filter_type: type, company_id: cpyId },
	success: function(data){ loadDD(data, changeDD,  needBlankOption, false, "");},
	beforeSend: function(){ $this.addClass('ajax-loading'); },
	complete: function(){  branchProjectChanged(changeDDId, 'project_id',  projectBlank, 'project', loadMember); $this.removeClass('ajax-loading'); }	      
	});
}

function branchProjectChanged(curDDId, changeDDId, needBlank, type, loadMember)
{	
	
	var currDD = document.getElementById(curDDId);
	var needBlankOption = needBlank;
	var changeDD = document.getElementById(changeDDId);	
	var cpyId = "";
	if(document.getElementById('company_id') != null)
	{
		cpyId = document.getElementById('company_id').value;
	}
	var $this = $(this);
	$.ajax({
	url: cpybranchUrl,
	type: 'get',
	data: {id: currDD.value, filter_type: type, company_id: cpyId },
	success: function(data){ loadDD(data, changeDD,  needBlankOption, false, "");},
	beforeSend: function(){ $this.addClass('ajax-loading'); },
	complete: function(){  if(loadMember){changedMembers(); }else {projectVersionChanged('project_id', 'version_id', true);} $this.removeClass('ajax-loading'); }	      
	});
}

function changedMembers()
{
	var cpyId, branchId, projectId;
	if(document.getElementById('company_id') != null)
	{
		cpyId = document.getElementById('company_id').value;
	}
	if(document.getElementById('branch_id') != null)
	{
		branchId = document.getElementById('branch_id').value;
	}
	if(document.getElementById('project_id') != null)
	{
		projectId = document.getElementById('project_id').value;
	}
	var changeDD = document.getElementById('user_id');	
	var $this = $(this);
	$.ajax({
	url: cpybranchUrl,
	type: 'get',
	data: {company_id: cpyId, branch_id: branchId, project_id: projectId, filter_type: 'member' },
	success: function(data){ loadDD(data, changeDD,  true, false, "");},
	beforeSend: function(){ $this.addClass('ajax-loading'); },
	complete: function(){  $this.removeClass('ajax-loading'); }	      
	});
}

function AddRow(tableId, rowCount)
{
	if(tableId == "projPlanTable")
    {		
		$('.datetimepicker').datetimepicker("destroy");
	}
    
	var table = document.getElementById(tableId);
	var rowlength = table.rows.length;
	var lastRow = table.rows[rowlength - 1];
	var lastDatePicker = $('.date', lastRow);
	var lastDateTimePicker = $('.datetimepicker', lastRow);
	var $rowClone = $(lastRow).clone(true);
	$rowClone.find('input:text').val('');	
	var g=1;
	var id = null;
	$rowClone.find('td').each(function(){
		var el = $(this).find(':first-child');
		id = el.attr('id') || null;
		if(id) {
			var i = id.match(/\d+/g); //id.substr(id.length-1);
			var prefix = id.substr(0, (id.length- i.toString().length));
			new_id = prefix+(+i+1);
			id = +i+1;
			issueId = "issue_id"+id;
			memberId = "member_id"+id;
			activityId = "activity_id"+id;
			el.attr('id', new_id);
			el.attr('name', prefix+(+i+1));
			if(prefix == "project_id")
			{
				el.attr('onchange', "projectIssueOrMemberChanged('"+new_id+"', '"+issueId+"', "+false+", 'Issue'  ); projectIssueOrMemberChanged('"+new_id+"', '"+memberId+"', "+false+", 'Member'  );projectIssueOrMemberChanged('"+new_id+"', '"+activityId+"', "+false+", 'Activity'  );");
			}			
		}		
		
	});	
    
    if(tableId == "timeEntryTable")
    {
	    var datePickerClone = $('.date', $rowClone);
		var datePickerCloneId = 'spent_on' + rowlength;
		
		datePickerClone.data( "datepicker", 
			$.extend( true, {}, lastDatePicker.data("datepicker") ) 
		).attr('id', datePickerCloneId);
		
		datePickerClone.data('datepicker').input = datePickerClone;
		datePickerClone.data('datepicker').id = datePickerCloneId;
    }   
	$(table).append($rowClone);
	
   
    if(tableId == "timeEntryTable")
    {
		datePickerClone.datepicker();
		document.getElementById(rowCount).value = rowlength;	
		document.getElementById('time_entry_id'+rowlength).value = "";		
    }	
	if(tableId == "projPlanTable")
    {
		 $('.datetimepicker').datetimepicker();
		document.getElementById(rowCount).value = rowlength;
		
		if(addChild)
		{
			document.getElementById("lbl_issue_parent"+id).innerHTML = parentId;
			document.getElementById("issue_parent"+id).value = parentId;
			document.getElementById("is_child"+parentId).value = true;
			addChild = false;
		}
		else
		{
			document.getElementById("lbl_issue_parent"+id).innerHTML = "";
			document.getElementById("issue_parent"+id).value = "";
			document.getElementById("is_child"+id).value = false;
		}
		document.getElementById("issue_root"+id).value = rowlength;
		document.getElementById("issue_id"+id).value = "";
	} 
	if(document.getElementById('item_index' + rowlength) != null)
	{
		document.getElementById('item_index' + rowlength).innerHTML = rowlength; 		
	}
	
	
}

function deleteRow(tableId, totalrow)
{
	var table = document.getElementById(tableId);
	var rowlength = table.rows.length;
	var isdelete = true;
	if(tableId == "projPlanTable")
    {		
		rootVal = document.getElementById("issue_root"+row_id).value;
		for(i = 1; i < rowlength; i++)
		{
			parentVal = document.getElementById("issue_parent"+i).value;
			if(parentVal == rootVal)
			{
				isdelete = false;
				break;
			}
		}
	}
	
	if(isdelete)
	{
		document.getElementById(tableId).deleteRow(row_id);	
		document.getElementById(totalrow).value = document.getElementById(totalrow).value - 1;
		for(i = 1; i < rowlength-1; i++)
		{
			var colCount = table.rows[i].cells.length;			
			for(var j=0; j<colCount; j++) 
			{
				var input = document.getElementById(tableId).rows[i].cells[j].getElementsByTagName("*")[0];	
				input.id = table.rows[i].cells[j].headers + i;
				input.name = table.rows[i].cells[j].headers + i;					
			}
		}	
	}
	else
	{
		alert("Please delete the sub tasks.");
	}
	
}

function projectIssueOrMemberChanged(curDDId, changeDDId, needBlank, type)
{		
	var currDD = document.getElementById(curDDId);
	var needBlankOption = needBlank;
	var changeDD = document.getElementById(changeDDId);		
	var $this = $(this);
	$.ajax({
	url: projectUrl,
	type: 'get',
	data: {id: currDD.value, filter_type: type },
	success: function(data){ loadDD(data, changeDD,  needBlankOption, false, "");},
	beforeSend: function(){ $this.addClass('ajax-loading'); },
	complete: function(){  $this.removeClass('ajax-loading'); }	      
	});
}

function showOrHide(field, elment1,element2)
{
	fldVal = document.getElementById(field).value;
	if(fldVal == "")
	{
		document.getElementById(elment1).style.display = "block";
		document.getElementById(element2).style.display = "block";	
	}
	else
	{
		document.getElementById(elment1).style.display = "none";
		document.getElementById(element2).style.display = "none";
	}
}
 
function addParentChildRow(tableId, fld)
{
	parentId = fld.id.match(/\d+/g);
	addChild = true;
	AddRow('projPlanTable', 'totalrow');
} 

function ddAutoComplete(id, isProjectChanged)
{
	$( function() {
		$.widget( "custom.combobox", {
		  _create: function() {
			this.wrapper = $( "<span>" )
			  .addClass( "custom-combobox" )
			  .insertAfter( this.element );
	 
			this.element.hide();
			this._createAutocomplete();
			this._createShowAllButton();
		  },
	 
		  _createAutocomplete: function() {
			var selected = this.element.children( ":selected" ),
			  value = selected.val() ? selected.text() : "";
			  
			this.input = $( "<input>" )
			  .appendTo( this.wrapper )
			  .val( value )
			  .attr( "title", "" )
			  .addClass( "custom-combobox-input ui-widget ui-widget-content ui-state-default ui-corner-left" )
			  .autocomplete({
				delay: 0,
				minLength: 0,
				source: $.proxy( this, "_source" )
			  })
			  .tooltip({
				classes: {
				  "ui-tooltip": "ui-state-highlight"
				}
			  });
	 
			this._on( this.input, {
			  autocompleteselect: function( event, ui ) {
				ui.item.option.selected = true;
				this._trigger( "select", event, {
				  item: ui.item.option
				});
			  },
	 
			  autocompletechange: "_removeIfInvalid"
			});
		  },
	 
		  _createShowAllButton: function() {
			var input = this.input,
			  wasOpen = false;
	 
			$( "<a>" )
			  .attr( "tabIndex", -1 )
			  .attr( "title", "Show All Items" )
			  .tooltip()
			  .appendTo( this.wrapper )
			  .button({
				icons: {
				  primary: "ui-icon-triangle-1-s"
				},
				text: false
			  })
			  .removeClass( "ui-corner-all" )
			  .addClass( "custom-combobox-toggle ui-corner-right" )
			  .on( "mousedown", function() {
				wasOpen = input.autocomplete( "widget" ).is( ":visible" );
			  })
			  .on( "click", function() {
				input.trigger( "focus" );
	 
				// Close if already visible
				if ( wasOpen ) {
				  return;
				}
	 
				// Pass empty string as value to search for, displaying all results
				input.autocomplete( "search", "" );
			  });
		  },
	 
		  _source: function( request, response ) {
			var matcher = new RegExp( $.ui.autocomplete.escapeRegex(request.term), "i" );
			response( this.element.children( "option" ).map(function() {
			  var text = $( this ).text();
			  if ( this.value && ( !request.term || matcher.test(text) ) )
				return {
				  label: text,
				  value: text,
				  option: this
				};
			}) );
		  },
	 
		  _removeIfInvalid: function( event, ui ) {
			
			// call the project onchange function
			if(isProjectChanged)
			{
				var i = id.match(/\d+/g);	
				projectIssueOrMemberChanged('project_id'+i, 'issue_id'+i, true, 'Issue'  ); projectIssueOrMemberChanged('project_id'+i, 'member_id'+i, true, 'Member');projectIssueOrMemberChanged('project_id'+i, 'activity_id'+i, true, 'Activity' );
			}
			
				
			// Selected an item, nothing to do
			if ( ui.item ) {
			  return;
			}
	 
			// Search for a match (case-insensitive)
			var value = this.input.val(),
			  valueLowerCase = value.toLowerCase(),
			  valid = false;
			this.element.children( "option" ).each(function() {
			  if ( $( this ).text().toLowerCase() === valueLowerCase ) {
				this.selected = valid = true;
				return false;
			  }
			});
	 
			// Found a match, nothing to do
			if ( valid ) {
			  return;
			}
	 
			// Remove invalid value
			this.input
			  .val( "" )
			  .attr( "title", value + " didn't match any item" )
			  .tooltip( "open" );
			this.element.val( "" );
			this._delay(function() {
			  this.input.tooltip( "close" ).attr( "title", "" );
			}, 2500 );
			this.input.autocomplete( "instance" ).term = "";
		  },
	 
		  _destroy: function() {
			this.wrapper.remove();
			this.element.show();
		}
    });
    $(id).combobox();    
  } );
}

function projectVersionChanged(curDDId, changeDDId, needBlank)
{		
	var currDD = document.getElementById(curDDId);
	var needBlankOption = needBlank;
	var changeDD = document.getElementById(changeDDId);		
	var $this = $(this);
	$.ajax({
	url: versionUrl,
	type: 'get',
	data: {project_id: currDD.value },
	success: function(data){ loadDD(data, changeDD,  needBlankOption, false, "");},
	beforeSend: function(){ $this.addClass('ajax-loading'); },
	complete: function(){  $this.removeClass('ajax-loading'); }	      
	});
}

function tableFieldAddition(tableId, position, elementId)
{
	var table = document.getElementById(tableId);
	var rowlength = table.rows.length;
	var total = 0;
	for(i = 1; i < rowlength; i++)
	{
		var colCount = table.rows[i].cells.length;			
		for(var j=0; j<colCount; j++) 
		{
			if(j == position){
				var input = document.getElementById(tableId).rows[i].cells[j].getElementsByTagName("*")[0];	
				total = total + parseInt(input.value);	
			}
						
		}
	}
	document.getElementById(elementId).innerHTML = "Total Hours : " + total;
}