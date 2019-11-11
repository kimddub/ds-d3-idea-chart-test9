<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>검색</title>

<link rel="stylesheet" href="/lib/lib.css">
<style>
	.con {
		width:800px;
		margin:0 auto;
		text-align:center;
	}
	
	#search {
		width:500px;
		margin:50px auto;
		background-color:#003399;
		border:5px solid #003399;
		border-radius:30px;
	}
	
	#search input[type="text"] {
		width:84.5%;
		border:none;
		background-color:white;
		border-radius:20px 0 0  20px;
		padding:10px;
		padding-left:30px;
		font-size:18px;
		font-weight:bold;
		outline:none;
		box-sizing:border-box;
	}
	
	#search input[type="submit"] {
		width:14.4%;
		background-color:#003399;
		border:none;
		border-radius:0 20px 20px 0;
		padding:10px;
		font-size:20px;
		color:white;
		box-sizing:border-box;
	}
	
	#search input[type="submit"]:hover {
		font-weight:bold;
	}
	
</style>

</head>
<body>

	<div class="con">
		
		<h2 style="margin-top:200px; color:#003399;">연관감성어 분석</h2>
		
		<form id="search" action="/d3/chart" method="POST" target="_blank">
		
			<input type="text" name="keyword" placeholer="감성 분석을 할 키워드를 입력하세요">
			<input type="submit" value="검색">
		
		</form>
		
	</div>

</body>
</html>