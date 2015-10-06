<% Option Explicit %>
<!--#include file="./var_dump.asp.inc"-->
<%
Dim var

Set var = Server.CreateObject("Microsoft.XMLDOM")
var.loadXML("")
var_dump(var)
%>==========================================================<%
Set var = Server.CreateObject("Microsoft.XMLDOM")
var.loadXML("" & _
	"<!--  Edited by XMLSpy  -->" & _
	"<note>" & _
		"<to>Tove</to>" & _
		"<from>Jani</from>" & _
		"<heading>Reminder</heading>" & _
		"<body>Don't forget me this weekend!</body>" & _
	"</note>" & _
"")
var_dump(var)
%>==========================================================<%
var = "String test"
var_dump(var)
%>==========================================================<%
%>==========================================================<%
var = 123
var_dump(var)
%>==========================================================<%
var = "123"
var_dump(var)
%>