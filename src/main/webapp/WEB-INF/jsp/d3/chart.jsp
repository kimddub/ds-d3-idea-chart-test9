<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>연관어 감성 분석</title>

<link rel="stylesheet" href="/lib/lib.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.7/css/bootstrap.min.css">
<style>
	body {
	    background-color:#eee;
	}
	
	.con {
		width:850px;
	}
	
	h3 {
	  color: gray;
	}
	
	.chart {
	  margin:0 auto;
	  width: 70%;
	  text-align:center;
	}
	
	.analysis-info {
		text-align:center;
		margin-bottom:50px;
		color:gray;
	}
	
	.analysis-info span {
		font-size:13px;
		font-weight:bold;
	}
	
	#keyword {
		background-color:coral;
		padding:10px 20px;
		border-radius:20px;
		color:white;
		font-weight:bold;
		font-size:18px;
	}
	
	#circleBarChart {
		display:inline-block;
		min-height:300px;
	}
	
	#monthlyChart {
		margin-top:30px;
	}
	
	.chart-info {
		padding:0 50px;
		text-align:right;
		font-size:12px;
		color:gray;
/* 		font-style:oblique; */
	}
	
	#detail-month {
		font-weight:bold;
		font-size:12px;
	}
	
	/* Style the lines by removing the fill and applying a stroke */
	.line {
	    fill: none;
 	    stroke: #ffffff; 
	    stroke-width: 3;
	}
	  
	.overlay {
	  fill: none;
	  pointer-events: all;
	}
	
	/* Style the dots by assigning a fill and stroke */
	.dot {
	    fill:#ffffff;
	    stroke:none;
	    cursor:pointer;
	}
	
	.here {
	    fill:#dfdfdf;
	    stroke:steelblue;
	    stroke-width:5;
	}
	
	.here:hover {
	    fill:steelblue;
	    stroke:steelblue;
	    r:8;
	    stroke-width:5;
	}
	  
	  circle.focus {
	  fill: steelblue;
	  stroke: steelblue;
	}
	
	div.tooltip {
	  color: #fff;
	  position: absolute;
	  text-align: center;
	  min-width: 100px;
	  width: 150px;
	  min-height: 50px;
	  height: auto;
	  padding: 5px;
	  font: 12px sans-serif;
	  background: #000; 
	  border: 1px #fff solid;
	  border-radius: 6px;
	  pointer-events: none;
	}
	
	.tick line,
	.tick text{
	  stroke: gray;
	}
	
	.x.axis .tick text {
		font-size:14px;
	}
	
	.x.axis path,
	.y.axis path {
 	  stroke: gray; 
 	  opacity:0;
	}
</style>

<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>

<script src="https://cdnjs.cloudflare.com/ajax/libs/d3/5.9.1/d3.min.js"></script>
<!-- <script src="https://d3js.org/d3.v5.min.js"></script> -->
<!-- <script src="/d3/d3.min.js"></script> -->
<script>
	var dataset = ${data};

	function parseDate(str) {
	    var y = str.substr(0, 4);
	    var m = str.substr(4, 2);
	    var d = str.substr(6, 2);
	    return new Date(y,m-1,d);
	}

	function parseNum(x) {
	    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
	}

	function redrawCircleBarChart(th) { // 파라미터: 몇월, tm2JsonData(:circleChart의 파라미터)

		var analysisDate = dataset[th].date;
		
		// 상세 긍부정 차트 조회 월 수정
		$('#detail-month').empty();
		$('#detail-month').append(analysisDate.substr(0,4) + "년 " + analysisDate.substr(4,2) + "월");
		
// 		$("#circleBarChart").empty();
// 		$("#circleBarChart").load("/assocSentimentChart",testData);

		$.post(
			"/d3/assocSentimentChart",
			{"keyword" : '${keyword}',
			 "analysisDate" : analysisDate},
			function(data) {

				$("#circleBarChart").empty();
				$("#circleBarChart").append(data);
			},
			"html"
		).fail(function(data) {
			alert("월별 연관어 차트를 가져올 수 없습니다.");
		});
	}


	$(function() {
		var today = new Date();
		var dd = today.getDate() < 10 ? '0'+today.getDate() : today.getDate();
		
		var analysisStartDate = dataset[0].date;
		var analysisEndDate = dataset[dataset.length - 1].date;
		var analysisToday = dataset[dataset.length - 1].date.substr(0,6) + dd;


		// 차트 조회 날짜 넣기
		$('#analysis-date').append(analysisStartDate + " ~ " + analysisToday);

		// 상세 긍부정 차트 조회 월 넣기
		$('#detail-month').append(analysisEndDate.substr(0,4) + "년 " + analysisEndDate.substr(4,2) + "월");

		// 상세 긍부정 차트 마지막 월로 초기셋팅
		redrawCircleBarChart(dataset.length - 1);

		
	//// monthly chart ////
	// 2. Use the margin convention practice 
	var margin = {top: 20, right: 100, bottom: 50, left: 100}
	  , width = 900 //(window.innerWidth*.75) - margin.left - margin.right // Use the window's width 
	  , height = 300;//window.innerHeight - margin.top - margin.bottom; // Use the window's height

	// 1. Add the SVG to the page and employ #2
	var svg = d3.select("#monthlyChart")
	  .append("svg")
	    .attr("width", width + margin.left + margin.right)
	    .attr("height", height + margin.top + margin.bottom)
	  .append("g")
	    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
	  
	// 5. X scale will use the index of our data
	var xScale = d3.scaleTime()
	    .domain([parseDate(analysisStartDate), parseDate(analysisEndDate)]) // input
	    .range([0, width]); // output

	// 6. Y scale will use the randomly generate number 
	var yScale = d3.scaleLinear()
	    .domain([100, 0]) // input 
	    .range([0, height]); // output 

	 // 3. Call the x axis in a group tag
	svg.append("g")
	    .attr("class", "x axis")
	    .attr("transform", "translate(0," + height + ")")
	    .call(d3.axisBottom(xScale)
	    		.tickFormat(d3.timeFormat('%Y-%m')) //표시할 형태를 포메팅한다.
	    		.ticks(d3.timeMonth) //틱단위를 1일로
	    ); // Create an axis component with d3.axisBottom
	    
	// 4. Call the y axis in a group tag
	svg.append("g")
	    .attr("class", "y axis")
	    .call(d3.axisLeft(yScale)); // Create an axis component with d3.axisLeft


    svg.append("rect")
   		.attr("class","positive-area")
	    .attr("x", 0) 
	    .attr("y", 0)
	    .attr("width",width)
	    .attr("height",height/2)
	    .attr("stroke","none")
	    .attr("fill","skyblue")
	    .attr("opacity","0.3");
    
    svg.append("rect")
		.attr("class","negative-area")
	    .attr("x", 0) 
	    .attr("y", height/2)
	    .attr("width",width)
	    .attr("height",height/2)
	    .attr("stroke","none")
	    .attr("fill","red")
	    .attr("opacity","0.2");
	  
	// 7. d3's line generator
	var line = d3.line()
	    .x(function(d, i) { return xScale(+parseDate(d.date)); }) // set the x values for the line generator
	    .y(function(d) { return yScale(+d.score); }) // set the y values for the line generator 
	    .curve(d3.curveMonotoneX) // apply smoothing to the line
	  
	// 9. Append the path, bind the data, and call the line generator 
	svg.append("path")
	    .datum(dataset) // 10. Binds data to the line 
	    .attr("class", "line") // Assign a class for styling 
	    .attr("d", line); // 11. Calls the line generator 
   
	// 12. Appends a circle for each datapoints 
	svg.selectAll(".dot")
	    .data(dataset).enter().append("circle") // Uses the  enter().append() method
	    .attr("class", "dot") // Assign a class for styling
	    .attr("th", function(d,i){ return i; })
	    .attr("cx", function(d, ijk) { return xScale(+parseDate(d.date)) })
	    .attr("cy", function(d) { return yScale(+d.score) })
	    .attr("r", 5)
	    .on("mouseover", function(d,i) { 
		    var id = d3.select(this).attr("th");
		       var htmlStr = dataset[id].date.substr(4,2) + "월</br>";
		       htmlStr += "긍정: " + parseNum(dataset[id].positive) + "건</br>";
		       htmlStr += "중립: " + parseNum(dataset[id].neutral) + "건</br>";
		       htmlStr += "부정: " + parseNum(dataset[id].negative) + "건</br>";
		       
	       tooltip.transition()
	         .duration(200)
	         .style("opacity", .9);
	       tooltip.html(htmlStr)
	         .style("left", (d3.event.pageX + 28) + "px")
	         .style("top", (d3.event.pageY - 50) + "px");
	        d3.select(this).classed('focus', true);
		})
        .on("mouseout", function(d) {
        	tooltip.transition()
	           .duration(500)
	           .style("opacity", 0);
	       d3.select(this).classed('focus', false);
		});


    svg.append("circle") // draggable circle to near point
	    .attr("class", "here") 
	    .attr("th", dataset.length - 1)
	    .attr("cx", xScale(+parseDate(analysisEndDate)))
	    .attr("cy", yScale(+dataset[dataset.length - 1].score))
	    .attr("r", 5)
	    .on("mouseover", function() { 
		    var id = d3.select(this).attr("th");
	       var htmlStr = dataset[id].date.substr(4,2) + "월</br>";
	       htmlStr += "긍정: " + parseNum(dataset[id].positive) + "건</br>";
	       htmlStr += "중립: " + parseNum(dataset[id].neutral) + "건</br>";
	       htmlStr += "부정: " + parseNum(dataset[id].negative) + "건</br>";
	       
	       tooltip.transition()
	         .duration(200)
	         .style("opacity", .9);
	       tooltip.html(htmlStr)
	         .style("left", (d3.event.pageX + 28) + "px")
	         .style("top", (d3.event.pageY - 50) + "px");
	        d3.select(this).classed('focus', true);
		})
        .on("mouseout", function() {
        	tooltip.transition()
	           .duration(500)
	           .style("opacity", 0);
	       d3.select(this).classed('focus', false);
		})
	    .call(d3.drag()
               .on("start", function(d){
            	   d3.select(this).attr("r", 8);
                   d3.select(this).raise().classed("active", true);
               })
               .on("drag", function(d) {
	               d3.select(this)
	               .attr("cx", function(){
		               var xCoordi = (d3.event.x)/(width/dataset.length);
	            	   return xScale(parseDate(dataset[Math.floor(xCoordi)].date)); })
	               .attr("cy", function(){
		               var xCoordi = (d3.event.x)/(width/dataset.length);
	            	   return yScale(dataset[Math.floor(xCoordi)].score); });
               })
               .on("end",  function(d) {
					var th = Math.ceil((d3.event.x)/(width/dataset.length)) - 1;
                   
            	   d3.select(this).attr("th", th);
                   d3.select(this).attr("r", 5).classed("active", false);
                   
                   redrawCircleBarChart(th);
                   
               })
            );

		// Tooltip
		var tooltip = d3.select("body").append("div")
		    .attr("class", "tooltip")
		    .style("opacity", 0);
	});
 

</script>

</head>
<body>

	<div class="analysis-info con">
		<h3 style="text-align: center">연관감성어 분석</h3>
		<div style="margin-top:20px; margin-bottom:30px;">
			<span id="keyword">${keyword}</span>
		</div>
		
		<nav class="row">
			<div class="cell">
				<span>매체: </span>
				<select>
					<option>instagram</option>
				</select>
			</div>
			
			<div class="cell-right">
				<span>기간: </span>
				<select>
					<option>1 year ago</option>
				</select>
				<span> ~ </span>
				<select>
					<option>current</option>
				</select>
			</div>
		</nav>
	</div>
	
	<div class="detailChart chart" >
		<div class="chart-info">
			<span><span id="detail-month"></span> 긍부정 비율 및 연관어 TOP5</span>
		</div>
		
		<div id="circleBarChart">
	
		</div>
	</div>
	
	<div class="chart" id="monthlyChart">
		<div class="chart-info">
			<span>월별 감성 지수 추이 ( <span id="analysis-date"></span> 기준)</span>
		</div>
	  
	</div>

</body>
</html>