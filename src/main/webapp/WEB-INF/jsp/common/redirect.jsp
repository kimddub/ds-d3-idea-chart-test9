<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>redirect page..</title>

<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
<script>

	var msg = "${alertMsg}";
	var redirectUrl = "${redirectUrl}";
	var historyBack = "${historyBack}";
	var closeWindow = "${closeWindow}";

	if (msg.trim().length != 0) {
		alert(msg);
	}

	if (closeWindow == "true") {
		window.close();
	}
	
	if (historyBack == "true") {
		history.back();
	}

	if (redirectUrl.length) {
		location.replace(redirectUrl);
	}

</script>

</body>
</html>