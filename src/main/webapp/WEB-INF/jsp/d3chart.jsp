<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>d3 chart</title>
<link rel=stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.7/css/bootstrap.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
<script src="https://d3js.org/d3.v4.min.js"></script>
<script> 

$(function(){
	var dataset = [9, 19, 29, 39, 29, 19, 9]; 

	// javascript chart
	var mychart1 = d3.select("#myChart-1"); 
	
	for (var i=0; i < dataset.length; i++) { 
		mychart1.append("rect") 
			.attr("height", dataset[i]) 
			.attr("width", 10) 
			.attr("x",20 * i)
			.attr("y", 100 - dataset[i]);
	} 

	// d3 chart
	var mychart2 = d3.select("#myChart-2"); 

	mychart2.selectAll("bar") 
	.data(dataset)  
	.enter()
	.append("rect") 
	.attr("height", function(d, i) {
		return d
	}) 
	.attr("width", 10) 
	.attr("x", function(d, i) {
		return (50 * i)
	}) 
	.attr("y", function(d, i) {
		return (100 - dataset[i])
	});

	// draw circle
	var draw1 = d3.select("#draw-1"); 
	
    
	draw1.append("text")
	    .attr("transform", "rotate(-90)")
	    .attr("x", -100)
	    .attr("y", -100)
	    .attr("dy", ".71em")
	    .style("text-anchor", "end")
	    .text("YAxis");
    

	var cx = 100;
	var r = 50;
	
	for (var i=0; i<3; i++) {
		draw1.append('circle')
		  .attr('cx', cx)
		  .attr('cy', 100)
		  .attr('r', r)
		  .attr('stroke', 'black')
		  .attr('stroke-width', 3)
		  .attr('fill', '#FFFFFF');

		cx = cx + 50;
		r = r - 10;
	}
	
});

</script>

</head>
<body>

<h1>TEST</h1>

<svg id="myChart-1" width="500" height="300"></svg>

<svg id="myChart-2" width="500" height="300"></svg>

<div>
	<svg id="draw-1" >
	<!-- 	<circle cx="250" cy="100" r="50" stroke="black" stroke-width="3" fill="#FFFFFF" /> -->
	</svg>
</div>

</body>
</html>