<%
Option Explicit
%>
<style type="text/css">
	.element-start, .element-end, .auto-element {
		font-weight: bold;
		color: DarkViolet;
	}
	.attribute-value{
		font-weight: bold;
		color: Dark;
	}
	.attribute-name{
		font-weight: normal;
		color: Blue;
	}
</style>
<%
Dim objXMLDoc : Set objXMLDoc = Server.CreateObject("MSXML2.DOMDocument.5.0") 
objXMLDoc.async = False
objXMLDoc.validateOnParse=False
Call objXMLDoc.load(Server.mapPath("./MyXML.xml"))
Call XMLIndent(objXMLDoc)
Set objXMLDoc = Nothing
%>
<%
Function XMLIndent(objXMLNode)
	Call XML_Indent(objXMLNode, 0)
End Function
%>
<%
Function XML_Indent(objXMLNode, intIndent)
	'Incrémentation de l'indentation
	intIndent = intIndent+2
	
	Dim objChildNode
	For Each objChildNode In objXMLNode.childNodes
		'Gestion de l'indentation
		Dim i, strIndent : strIndent = ""
		For i=1 To intIndent
			strIndent = strIndent & "&nbsp;&nbsp;&nbsp;&nbsp;"
		Next

		Response.Write(strIndent)
		
		Select Case getNodeType(objChildNode)
			Case "element":
				%>&lt;<span class="element-start"><%=objChildNode.nodeName%></span><%Call getAttributes(objChildNode)%>&gt;<br/><%
				Call XML_Indent(objChildNode, intIndent)
				Response.Write(strIndent)
				%>&lt;/<span class="element-end"><%=objChildNode.nodeName%></span>&gt;<%
			Case "simple-element":
				%>&lt;<span class="element-start"><%=objChildNode.nodeName%></span><%Call getAttributes(objChildNode)%>&gt;<%
				%><span class="text"><%=objChildNode.text%></span><%
				%>&lt;/<span class="element-end"><%=objChildNode.nodeName%></span>&gt;<%
			Case "auto-element":
				%>&lt;<span class="auto-element"><%=objChildNode.nodeName %></span><%Call getAttributes(objChildNode)%>/&gt;<%
		End Select
		Response.Write("<br/>")
	Next
	intIndent = intIndent-2
End Function
%>
<%
Sub getAttributes(objXMLNode)
	If Not objXMLNode.attributes is Nothing Then
		If (objXMLNode.attributes.length>0) Then
			Dim objXMLAttribute
			For Each objXMLAttribute In objXMLNode.attributes
				%>&nbsp;<span class="attribute-name"><%=objXMLAttribute.name%></span>=<span class="attribute-value">"<%=objXMLAttribute.nodeValue%>"</span><%
			Next	
		End If
	End If
End Sub
%>
<%
Function getNodeType(objXMLNode)
	Dim strType : strType = objXMLNode.nodeTypeString
	If strType="element" And objXMLNode.hasChildNodes Then
		If (objXMLNode.attributes.length=0) And inStr(objXMLNode.firstChild.nodeTypeString, "text")>0 Then
			strType = "simple-element"
		End If
	End If
	If strType="element" And Not objXMLNode.hasChildNodes Then
		strType = "auto-element"
	End If
	'Function Return :
	getNodeType = strType
End Function
%>