<%
Function var_dump(var)
	response.write "<pre>" & var_dump_indent(var, 0) & "</pre>"
End Function
%>
<%
Function var_dump_get(var)
	var_dump_get=var_dump_indent(var, 0)
End Function
%>
<%
Function var_dump_indent(var, i)
	Dim varType : varType=TypeName(var)
	Dim ret : ret=""
	Select Case varType
		Case "String":
			ret = "String(" & Len(var) & ")""" & var & """"
		Case "Double", "Integer":
			ret = varType & "(" & var & ")"
		Case "Boolean":
			If var Then
				var = "True"
			Else
				var = "False"
			End If
			ret = "Boolean(" & var & ")"
		Case "Dictionary":
			ret = "Dictionary(" & var.Count & "){" & vbCrLf
				Dim key
				For Each key In var.Keys
					ret=ret & indent(i) & key & " => " & var_dump_indent(var.Item(key), i+1) & vbCrLf
				Next
			ret = ret & indent(i-1) & "}"
		Case "DOMDocument":
			ret = "DOMDocument(){" & vbCrLf & _
				indent(i+1) & "XMLtext => """ & Server.HTMLEncode(var.xml) & """, " & vbCrLf
			If var.parseError.errorCode <> 0 Then
				ret = ret & _
					indent(i+1) & "parseError => {" & vbCrLf & _
						indent(i+2) & "errorCode  => " & var.parseError.errorCode  & vbCrLf & _
						indent(i+2) & "reason => " & var.parseError.reason & vbCrLf & _
					indent(i+1) & "}" & vbCrLf
			Else
				ret = ret & _
					indent(i+1) & "XML => " & XML_Indent(var, i+1)
			End If

			ret = ret & "}"
		Case Else:
			ret = "Undefined type '" & varType & "'"
	End Select
	var_dump_indent = ret
End Function
%>
<%
Function indent(x)
	Dim i, ret : ret = ""
	For i = 0 To x
		ret = ret & vbTab
	Next
	indent = ret
End Function
%>
<%
Function XMLIndent(objXMLNode)
	XMLIndent = XML_Indent(objXMLNode, 0)
End Function
%>
<%
Function XML_Indent(objXMLNode, intIndent)
	'Incrémentation de l'indentation
	intIndent = intIndent + 1
	
	Dim objChildNode
	For Each objChildNode In objXMLNode.childNodes
		'Gestion de l'indentation
		Select Case getNodeType(objChildNode)
			Case "element":
				XML_Indent = XML_Indent & indent(intIndent) & _
					"&lt;" & objChildNode.nodeName & getAttributes(objChildNode) & "&gt;" & vbCrLf
				XML_Indent = XML_Indent & XML_Indent(objChildNode, intIndent)
				intIndent = intIndent - 1
				XML_Indent = XML_Indent & indent(intIndent) & _
					"&lt;/" & objChildNode.nodeName & "&gt;" & vbCrLf
			Case "simple-element":
				XML_Indent = XML_Indent & indent(intIndent) & _
					"&lt;" & objChildNode.nodeName & getAttributes(objChildNode) & "&gt;" & _
					objChildNode.text & _
					"&lt;/" & objChildNode.nodeName & "&gt;"
			Case "auto-element":
				XML_Indent = XML_Indent & _
					"&lt;" & objChildNode.nodeName & getAttributes(objChildNode) & "/&gt;"
		End Select
		XML_Indent = XML_Indent & vbCrLf
	Next
End Function
%>
<%
Function getAttributes(objXMLNode)
	'Dim ret : ret = ""
	'If Not objXMLNode.attributes is Nothing Then
	'	If (objXMLNode.attributes.length>0) Then
	'		Dim objXMLAttribute
	'		For Each objXMLAttribute In objXMLNode.attributes
	'			ret = "&nbsp;" & objXMLAttribute.name & "=""" & objXMLAttribute.nodeValue & """"
	'		Next	
	'	End If
	'End If
	'getAttributes = ret
	getAttributes = ""
End Function
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
	getNodeType = strType
End Function
%>