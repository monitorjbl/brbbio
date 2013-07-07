<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %><!DOCTYPE html>
<html>
<head>
<title>View Data</title>
<link rel="stylesheet" href="http://blueimp.github.com/cdn/css/bootstrap.min.css">
<link rel="stylesheet" href="static/css/style.css">
<link rel="stylesheet" href="static/css/jquery.fileupload-ui.css">
<style type="text/css">
table.gridtable {
	font-family: verdana,arial,sans-serif;
	font-size:11px;
	color:#333333;
	border-width: 1px;
	border-color: #666666;
	border-collapse: collapse;
    margin-left:15px;
}
table.gridtable th {
	border-width: 1px;
	padding: 8px;
	border-style: solid;
	border-color: #666666;
	background-color: #dedede;
}
table.gridtable td {
	border-width: 1px;
	padding: 8px;
	border-style: solid;
	border-color: #666666;
	background-color: #ffffff;
}
</style>
<script src="//cdnjs.cloudflare.com/ajax/libs/jquery/2.0.2/jquery.min.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js"></script>
<script>

function displayProcessedData(data){
	$('#processed').children().remove();
	$('#processed').append('<table class="gridtable"><thead><tr><th>Plate ID</th><th>Gene</th></tr></thead><tbody></tbody></table>');
	
	var time = {};
	var tableRows = {};
	$.each(data, function(){
		var key = this.plateName+'_'+this.geneId;
		if(tableRows[key] == undefined){
			tableRows[key] = {
				plate:this.plateName,
				gene:this.geneId,
				data:[]
			};
		}
		tableRows[key].data.push(this.normalized);
		time['_'+this.timeMarker] = true;
	});
	
	for(key in time){
		$('#processed thead tr').append('<th>'+key.substring(1)+'hr</th>');
	}
	
	for(key in tableRows){
		var r = tableRows[key];
		var row = '<tr><td>'+r.plate+'</td><td>'+r.gene+'</td>';
		$.each(r.data, function(i,j){
			row+= '<td>'+j+'</td>';
		});
		row+= '</tr>';
		
		$('#processed tbody').append(row);
	}
}

$(document).ready(function(){
	$('#run').change(function(){
		$.get('getProcessedData?runId='+$(this).val(), function(data){
			displayProcessedData(data);
		})
	})
});

</script>
</head>
<body>

<h3>View Data</h3>

Run: 
<select id="run">
  <option value=""><option>
  <c:forEach var="run" items="${runs}">
   <option value="<c:out value="${run.getId()}"/>"><c:out value="${run.getRunName()}"/></option>
  </c:forEach>
</select>

<br/>
<div id="processed">
</div>

</body>
</html>