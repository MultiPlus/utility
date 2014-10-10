<%
Function Math_Truncate(X)
	If(isNumeric(X)) Then
		Dim intX : intX = CInt(X)
		Dim restX : restX = X - intX
		If (restX>0) Then
			intX = intX + 1
		End If
	End If
	Math_Truncate = intX
End Function
%>