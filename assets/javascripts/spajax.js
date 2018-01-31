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

function cpyBranchChanged(curDDId, changeDDId,  needBlank, type)
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
	complete: function(){  branchProjectChanged(changeDDId, 'project_id',  true, 'project'); $this.removeClass('ajax-loading'); }	      
	});
}

function branchProjectChanged(curDDId, changeDDId, needBlank, type)
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
	complete: function(){  changedMembers(); $this.removeClass('ajax-loading'); }	      
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
	var table = document.getElementById(tableId);
	var rowlength = table.rows.length;
	var lastRow = table.rows[rowlength - 1];
	var lastDatePicker = $('.date', lastRow);
	var $rowClone = $(lastRow).clone(true);
	$rowClone.find('input:text').val('');	
	var g=1;
	$rowClone.find('td').each(function(){
		var el = $(this).find(':first-child');
		var id = el.attr('id') || null;
		if(id) {
			var i = id.substr(id.length-1);
			var prefix = id.substr(0, (id.length-1));
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
		var datePickerCloneId = 'billdate' + rowlength;
		
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
    }
	document.getElementById(rowCount).value = rowlength;	
	document.getElementById('time_entry_id'+rowlength).value = "";
	/* 
	if(document.getElementById('item_index' + rowlength) != null)
	{
		document.getElementById('item_index' + rowlength).innerHTML = rowlength; 
	} */
	
}

function deleteRow(tableId, totalrow)
{
	var table = document.getElementById(tableId);
	var rowlength = table.rows.length;
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