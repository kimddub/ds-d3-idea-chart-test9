<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>d3 chart</title>

<link rel=stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/3.3.7/css/bootstrap.min.css">
<style>
	
* {
	font-family: 'FranklinGothic-Book' "Franklin Gothic Medium", "Franklin Gothic", "ITC Franklin Gothic", Arial, sans-serif;
}

body {
    position: relative;
    margin-left:15px;
    background-color:#eee;
}
#positive-chart-type,
#negative-chart-type{
    font-size:23px;
    font-weight:bold;
    fill:#000;
}

#positive-chart-ratio tspan,
#negative-chart-ratio tspan{
    font-size:30px;
    font-weight:bold;
    fill:#000;
}

#positive-chart-labels tspan,
#negative-chart-labels tspan {
    font-size:12px;
    fill:#6D6E71;
}

#positive-chart-values tspan,
#negative-chart-values tspan {
    font-size: 12px;
    font-weight:bold;
    fill:#000;
}

#positive-chart-values tspan {
    fill: #684E88;
}
#negative-chart-values tspan {
    fill: #7D3A4D;
}
</style>

<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>

<script src="https://cdnjs.cloudflare.com/ajax/libs/d3/5.9.1/d3.min.js"></script>

<script> 

	var pPalette = ["#3366cc","#5c85d6","#85a3e0","#adc2eb","#c2d1f0"];
	var nPalette = ["#ff3333","#ff8080","#ffb3b3","#ffcccc","#ffe6e6"];
	
	//{"positive": 
	//	 {"ratio":0.6,
	//	 "assoc":[{"index":0, "frequency":39, "label":"긍정어1"}, ...] },
	//"negative":
	//	 {"ratio":0.4,
	//	 "assoc":[{"index":0, "frequency":39, "label":"부정어1"}, ...] }
	//}
	
	var chartData = ${data};

	$(function(){
	
		// Animation Queue
		setTimeout(function(){drawCircleBarChart(chartData.positive,pPalette,"#positive-chart","#positive-chart-ratio","#positive-chart-values","#positive-chart-labels")},500);
		setTimeout(function(){drawCircleBarChart(chartData.negative,nPalette,"#negative-chart","#negative-chart-ratio","#negative-chart-values","#negative-chart-labels")},800);

		
		d3.select("#positive-chart-type")
		    .transition()
		    .delay(700)
		    .duration(500)
		    .attr("opacity","1");
		d3.select("#positive-chart-ratio")
	    .transition()
	    .delay(700)
	    .duration(500)
	    .attr("opacity","1");
		d3.select("#positive-chart-clipLabels")
		    .transition()
		    .delay(750)
		    .duration(1500)
		    .attr("height","150");
	    

		d3.select("#negative-chart-type")
		    .transition()
		    .delay(1050)
		    .duration(500)
		    .attr("opacity","1");
		d3.select("#negative-chart-ratio")
	    .transition()
	    .delay(1050)
	    .duration(500)
	    .attr("opacity","1");
		d3.select("#negative-chart-clipLabels")
		    .transition()
		    .delay(900)
		    .duration(1250)
		    .attr("height","150");
	});

	function drawCircleBarChart(sentimtntData,palette,target,sentimentRatio,values,labels){
		var data = sentimtntData.assoc,
			ratio = sentimtntData.ratio;
		
		var fill = palette;
		
	    var w = 362,
	        h = 362,
	        size = data[0].frequency / ratio * 1.2,
	        radius = 200,
	        sectorWidth = .1 ,
	        radScale = 25,
	        sectorScale = 1.45,
	        target = d3.select(target),
	        valueText = d3.select(values),
	        labelText = d3.select(labels),
	        ratioText = d3.select(sentimentRatio);
	
	
	    var arc = d3.arc()
	        .innerRadius(function(d,i){return ((0.3 + 0.1*d.index)/sectorScale) * radius + radScale; })
	        .outerRadius(function(d,i){return (((0.3 + 0.1*d.index)/sectorScale) + (sectorWidth/sectorScale)) * radius + radScale; })
	        .cornerRadius(3)
	        .startAngle(Math.PI)
	        .endAngle(function(d) { return Math.PI + (d.frequency / size) * 2 * Math.PI; });
	    
	    var path = target.selectAll("path")
	        .data(data);
	
	    //TODO: seperate color and index from data object, make it a pain to update object order
	    path.enter().append("svg:path")
	        .attr("fill",function(d,i){return fill[d.index];})
	        .attr("stroke","#D1D3D4")
		    .attr("y",10)
	        .transition()
	//	        .ease("elastic")
	        .duration(1000)
	        .delay(function(d,i){return i*100})
	        .attrTween("d", arcTween);
	
	    valueText.selectAll("tspan").data(data).enter()
	    .append("tspan")
	    .attr("x",10)
	    .attr("y",function(d,i){return i*14})
	    .text(function(d,i){return data[i].index + 1 + ". "});
	
		labelText.selectAll("tspan").data(data).enter()
		.append("tspan")
		.attr("x",0)
		.attr("y",function(d,i){return i*14})
		.text(function(d,i){return data[i].label});

		
	    ratioText.append("tspan")
			.attr("x",0)
			.attr("y",0)
		    .text(function(){

				if (ratio == 0) {
					return "데이터 없음";
				}
				
			    return parseFloat(ratio*100).toFixed(1) + "%"; });
	
	
	    function arcTween(b) {
	        var i = d3.interpolate({frequency: 0}, b);
	        return function(t) {
	            return arc(i(t));
	        };
	    }
	}

</script>

</head>
<body>

<svg width="724px" height="350px" margin="0 auto">
    
    <g id="circleBarCharts">
        
        <!-- Circle Bar Chart 1 -->
        <g id="positive-group" transform="translate(0,0)">
        	<text id="positive-chart-type" opacity="0" x="190" y="30">긍정</text>
        	<text id="positive-chart-ratio" opacity="0" transform="translate(180,175)"></text>         
            
            <g id="positive-chart" transform="translate(215,170)"></g>
            
            <clippath id="positive-chart-clipPath">
                <rect id="positive-chart-clipLabels" x="205" y="235" width="180" height="0"></rect>
            </clippath>
            
            <g id="positive-chart-legend" clip-path="url(#circleBar-web-clipPath)">
                <text id="positive-chart-values" transform="translate(222,245)"></text>
                <text id="positive-chart-labels" transform="translate(247,245)"></text>
            </g>
        </g>
        <!-- END -->
    
        <!--Circle Bar Chart 2 -->
        <g id="negative-group" transform="translate(362,0)">
        	<text id="negative-chart-type" opacity="0" x="190" y="30">부정</text>
        	<text id="negative-chart-ratio" opacity="0" transform="translate(180,175)"></text>
            
            <g id="negative-chart" transform="translate(215,170)"></g>
            
            <clippath id="negative-chart-clipPath">
                <rect id="negative-chart-clipLabels" x="205" y="235" width="170" height="0"></rect>
            </clippath>
            
            <g id="negative-chart-legend" clip-path="url(#circleBar-mobile-clipPath)">
                <text id="negative-chart-values" transform="translate(222,245)"></text>
                <text id="negative-chart-labels" transform="translate(247,245)"></text>
            </g>
        </g>
        <!-- END -->
    </g>
	 
</svg>



</body>
</html>


<!-- <svg version="1.1" -->
<!--  xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:a="http://ns.adobe.com/AdobeSVGViewerExtensions/3.0/" -->
<!--  x="0px" y="0px" width="724px" height="400px" -->
<!--  overflow="visible" xml:space="preserve"> -->
    
<!--     <g id="circleBarCharts"> -->
        
<!--         Web Circle Bar Chart -->
<!--         <g id="circleBar-web-group" transform="translate(0,0)"> -->
<!--           <image id="circleBar-web-icon" opacity="0" x="166" y="112" overflow="visible" width="98" height="77" xlink:href="http://www.frank-designs.com/images/icon_web.png" /> -->
<!--             <text id="circleBar-web-text" opacity="0" x="200" y="143">WEB</text> -->
<!--             <g id="circleBar-web-chart" transform="translate(215,150)"></g> -->
<!--             <clippath id="circleBar-web-clipPath"> -->
<!--                 <rect id="circleBar-web-clipLabels" x="205" y="215" width="180" height="0"></rect> -->
<!--             </clippath> -->
<!--             <g id="circleBar-web-legend" clip-path="url(#circleBar-web-clipPath)"> -->
<!--                 <text id="circleBar-web-values" transform="translate(222,225)"></text> -->
<!--                 <text id="circleBar-web-labels" transform="translate(277,225)"></text> -->
<!--             </g> -->
<!--         </g> -->
<!--         END: Web Circle Bar Chart -->
    
<!--         Mobile Circle Bar Chart -->
<!--         <g id="circleBar-mobile-group" transform="translate(362,0)"> -->
<!--             <image id="circleBar-mobile-icon" opacity="0" x="195" y="112" overflow="visible" width="40" height="77" xlink:href="http://www.frank-designs.com/images/icon_mobile.png" /> -->
<!--             <text id="circleBar-mobile-text" opacity="0" x="187" y="155">MOBILE</text> -->
<!--             <g id="circleBar-mobile-chart" transform="translate(215,150)"></g> -->
<!--             <clippath id="circleBar-mobile-clipPath"> -->
<!--                 <rect id="circleBar-mobile-clipLabels" x="205" y="215" width="150" height="0"></rect> -->
<!--             </clippath> -->
<!--             <g id="circleBar-mobile-legend" clip-path="url(#circleBar-mobile-clipPath)"> -->
<!--                 <text id="circleBar-mobile-values" transform="translate(222,225)"></text> -->
<!--                 <text id="circleBar-mobile-labels" transform="translate(277,225)"></text> -->
<!--             </g> -->
<!--         </g> -->
<!--         END: Mobile Circle Bar Chart -->
<!--     </g> -->
	 
<!-- </svg> -->