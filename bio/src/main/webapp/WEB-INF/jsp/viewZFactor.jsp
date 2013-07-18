<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %><!DOCTYPE html>
<html>
<head>
<title>View Data</title>
<link rel="stylesheet" href="http://blueimp.github.com/cdn/css/bootstrap.min.css">
<link rel="stylesheet" href="http://blueimp.github.com/cdn/css/bootstrap-responsive.css">
<link rel="stylesheet" href="static/css/style.css">
<link rel="stylesheet" href="static/css/jquery.fileupload-ui.css">
<style type="text/css">
#selectBox{
  margin-left:10px;
}
td.badData{
  color:red;
  text-align:center;
}
</style>
<script src="//cdnjs.cloudflare.com/ajax/libs/jquery/2.0.2/jquery.min.js"></script>
<script src="//cdnjs.cloudflare.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js"></script>
<script src="http://blueimp.github.com/cdn/js/bootstrap.min.js"></script>
<script>

function displayProcessedData(data, runId){
	var tbl = $('<table class="table table-striped"><thead><tr><th>Plate ID</th></tr></thead><tbody></tbody></table>');
	
	var time = {};
	var tableRows = {};
	$.each(data, function(){
		var key = this.plateName+'_'+this.geneId;
		if(tableRows[key] == undefined){
			tableRows[key] = {
				plate:this.plateName,
				data:[]
			};
		}
		tableRows[key].data.push(this.zFactor);
		time['_'+this.timeMarker] = true;
	});
	
	for(key in time){
		tbl.find('thead tr').append('<th>'+key.substring(1)+'hr</th>');
	}
	
	for(key in tableRows){
		var r = tableRows[key];
		var row = $('<tr><td>'+r.plate+'</td></tr>');
		
		if(Object.keys(time).length - r.data.length == 0){
			$.each(r.data, function(i,j){
				row.append('<td>'+j+'</td>');
			});
		} else {
			row.append('<td colspan="'+Object.keys(time).length+'" class="badData">Improper data found</td>');
		}
		
		tbl.append(row);
	}
	
	$('#selectBox span').remove();
	$('#processed').append(tbl);
}

$(document).ready(function(){
	$('#run').change(function(){
		var id = $(this).val();
		$('#processed').children().remove();
		$('#selectBox a, #selectBox span').remove();
		
		$('<a id="excel" href="getNormalizedDataExcel?runId='+$(this).val()+'"><img src="static/img/excel.png"/></a>').appendTo('#selectBox');
		$('<span style="display:block;"><button class="btn">Show data</button></span>').appendTo('#selectBox').find('button').click(function(){
			$(this).parent().append('<img class="loading" src="static/img/loader.gif"/>');
			$(this).text('Loading...').attr('disabled', true);
    		$.get('getZFactorData?runId='+id, function(data){
    			displayProcessedData(data, id);
    		});
		});
	})
});

</script>
</head>
<body>
  <jsp:include page="headers.jsp" />

  <div class="container">
    <div id="selectBox">
      <h3>View Z Factors</h3>

      Run: <select id="run">
        <option value="">[-Select-]</option>
        <c:forEach var="run" items="${runs}">
          <option value="<c:out value="${run.getId()}"/>">
            <c:out value="${run.getRunName()}" />
          </option>
        </c:forEach>
      </select>
    </div>
    <br />

    <div class="row">
      <div id="processed" class="span6"></div>
    </div>

  </div>

</body>
</html>