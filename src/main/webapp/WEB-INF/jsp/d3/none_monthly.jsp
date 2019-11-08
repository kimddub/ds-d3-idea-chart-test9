<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>

<style>
	body {
	  background-color: #eee;
	}
	
	h3 {
	  color: gray;
	}
	
	#monthlyChart {
	  margin:0 auto;
	  width: 70%;
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
	    stroke:#ffffff;
	    stroke-width:5;
	}
	
	.here:hover {
	    fill:#ffffff;
	    stroke:#ffffff;
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


$(function() {

	$('#test').load("d3chart");
	
	// 8. An array of objects of length N. Each object has key -> value pair, the key being "y" and the value is a random number
	var dataset = [
		{"month":"1","score":"24"},
		{"month":"2","score":"38"},
		{"month":"3","score":"77"},
		{"month":"4","score":"65"},
		{"month":"5","score":"79"},
		{"month":"6","score":"42"},
		{"month":"7","score":"41"},
		{"month":"8","score":"55"},
		{"month":"9","score":"61"},
		{"month":"10","score":"41"},
		{"month":"11","score":"55"},
		{"month":"12","score":"61"}];

	// 2. Use the margin convention practice 
	var margin = {top: 50, right: 100, bottom: 50, left: 100}
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
	var xScale = d3.scaleLinear()
// 	    .domain([1989, 2013]) // input
	    .range([0, width]); // output

	// 6. Y scale will use the randomly generate number 
	var yScale = d3.scaleLinear()
	    .domain([100, 0]) // input 
	    .range([0, height]); // output 

	 // 3. Call the x axis in a group tag
	svg.append("g")
	    .attr("class", "x axis")
	    .attr("transform", "translate(0," + height + ")")
	    .call(d3.axisBottom(xScale.domain([dataset[0].month, dataset[dataset.length - 1].month]))); // Create an axis component with d3.axisBottom

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
	    .x(function(d, i) { return xScale(+d.month); }) // set the x values for the line generator
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
	    .attr("cx", function(d, ijk) { return xScale(+d.month) })
	    .attr("cy", function(d) { return yScale(+d.score) })
	    .attr("r", 5)
	    .on("mouseover", function(d,i) { 
	       var htmlStr = (i + 1) + "th data info";
	       div.transition()
	         .duration(200)
	         .style("opacity", .9);
	       div.html(htmlStr)
	         .style("left", (d3.event.pageX + 28) + "px")
	         .style("top", (d3.event.pageY - 50) + "px");
	        d3.select(this).classed('focus', true);
		})
        .on("mouseout", function(d) {
	         div.transition()
	           .duration(500)
	           .style("opacity", 0);
	       d3.select(this).classed('focus', false);
		});


    svg.append("circle") // draggable circle to near point
	    .attr("class", "here") 
	    .attr("th", "12")
	    .attr("cx", xScale(+dataset[dataset.length - 1].month))
	    .attr("cy", yScale(+dataset[dataset.length - 1].score))
	    .attr("r", 5)
	    .on("mouseover", function() { 
	       var htmlStr = d3.select(this).attr("th") + "th data info";
	       div.transition()
	         .duration(200)
	         .style("opacity", .9);
	       div.html(htmlStr)
	         .style("left", (d3.event.pageX + 28) + "px")
	         .style("top", (d3.event.pageY - 50) + "px");
	        d3.select(this).classed('focus', true);
		})
        .on("mouseout", function() {
	         div.transition()
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
		               var xCoordi = (d3.event.x)/(width/12);
	            	   return xScale(dataset[Math.floor(xCoordi)].month); })
	               .attr("cy", function(){
		               var xCoordi = (d3.event.x)/(width/12);
	            	   return yScale(dataset[Math.floor(xCoordi)].score); });
               })
               .on("end",  function(d) {
            	   d3.select(this).attr("th", Math.ceil((d3.event.x)/(width/12)));
                   
                   d3.select(this).attr("r", 5).classed("active", false);
                   alert("CircleBar Chart changed!");
               })
            );

	// Tooltip
	var div = d3.select("body").append("div")
	    .attr("class", "tooltip")
	    .style("opacity", 0);
});
 

</script>

</head>
<body>

	<h3 style="text-align: center">your Keyword : KEYWORD</h3>
	<div id="monthlyChart">
	  
	</div>

</body>
</html>