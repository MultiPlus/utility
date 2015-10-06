<%
'************************************************************************************************************
'*	 PROCEDURE   : applyTemplateToXML
'*   PARAM 	     : - objXMLDoc (OBJECT DOM) 	: Ressources à afficher (Arbre XML)
'*				   - strTemplatePath (STRING) 	: Chemin vers le fichier XSL pour la transformation en HTML
'*   RETURN		 : Output (OBJECT DOM) 		: Ressource à afficher (Arbre HTML)
'*   DESCRIPTION : Permet de transformer une ressource XML en ressource HTML en appliquant un fichier XSL
'************************************************ DEBUT *****************************************************
Function applyTemplateToXML(objXMLDoc, strTemplatePath)
	Dim objXSLDoc : Set objXSLDoc = getXMLDocument(strTemplatePath)
	Dim strHTML
	If Not(objXMLDoc Is Nothing) Then
		strHTML = objXMLDoc.transformNode(objXSLDoc) 
		If objXMLDoc.ParseError.ErrorCode <> 0 Then
			Dim objError : Set objError = objXMLDoc.ParseError
			Response.Write("XML transformation error " & objError.ErrorCode & " [" & objError.Reason & "]")
			Set objError = Nothing
		End If 
	Else
		Response.Write("No XML provided")
	End If
	
	'Retour de la fonction
	applyTemplateToXML = strHTML

	'Suppresion des objets inutilisés
	Set objXSLDoc = Nothing
End Function
'************************************************  FIN  *****************************************************
%>
<%
'************************************************************************************************************
'*	 PROCEDURE   : getSource
'*   PARAM 	     : strURL (STRING) : URL de la ressource à récupérer
'*	 RETURN      : 
'*   DESCRIPTION : Permet de récupérer le code source HTML à partir d'une URL
'************************************************ DEBUT *****************************************************
Function getSource(strURL)
	Dim objHTTPRequester : Set objHTTPRequester = CreateObject(strMSXML_SERVERXMLHTTP) 
	
	Call objHTTPRequester.Open("GET", strURL, False)
	Call objHTTPRequester.setRequestHeader("Content-Type", "application/x-www-form-urlencoded; Charset=utf-8")
	Call objHTTPRequester.Send()

	Dim strSource : strSource = ""

	If objHTTPRequester.Status = 200 Then
	
		If objHTTPRequester.ResponseText<>"" Then
			'Récupération du contenu sous format texte
			strSource = BytesToString(objHTTPRequester.ResponseBody, "ISO-8859-1")
		End If

		'Note @SRL
		' Remplacement de l'apostrophe (= char 92 en hexadécimal):
		' Le problème est que cette apostrophe qui est à l'origine le caractère de code e28099 en Unicode (et qui est correctement géré en UTF-8)
		' est mal converti lors du passage en ISO-8859-1 (conversion automatique en passant par MSXML2.ServerXMLHTTP.6.0) car il n'a pas d'équivalent en ISO-8859-1.
		' Ce caractère est donc transformé dans le caractère de code 92 (= apostrophe en Windows-1252) alors que le reste est en ISO-8859-1 ce qui pose problème ensuite.
		' Pour éviter ces problèmes, on remplace automatiquement le caractère de code 92 dans le flux provenant de l'appel d'une URL par le caractère ' (= apostrophe normale)
		strSource = Replace(strSource, ChrW("&H0092"), "'")
	Else
		Response.Write("HTTP Error " & objHTTPRequester.Status & " [" & objHTTPRequester.StatusText & "]")
	End If

	'Retour de la fonction
	getSource = strSource 

	'Suppresion des objets inutilisés
	Set objHTTPRequester = Nothing   
End Function
'************************************************  FIN  *****************************************************
%>
<%
'************************************************************************************************************
'*	 PROCEDURE   : getXMLDocument
'*   PARAM 	     : strURL (STRING) 		  : URL de la resource à charger
'*	 RETURN      : objXMLDoc (OBJECT DOM) : Document XML de la ressource voulue
'*   DESCRIPTION : Permet de récupérer un document XML à partir de son URL
'************************************************ DEBUT *****************************************************
Function getXMLDocument(strURL)
	Dim strSource   : strSource = getSource(strURL)
	Dim objXMLDoc : Set objXMLDoc = Nothing
	
	If (strSource<>"") Then
		Set objXMLDoc = CreateObject(strMSXML_DOMDOC)
		objXMLDoc.async = False
		objXMLDoc.ValidateOnParse = False
		
		objXMLDoc.LoadXML(strSource)
		
		'If objXMLDoc.childNodes.Item(0).nodeName<>"xml" Then
		'	Dim objNodeHeader : Set objNodeHeader = objXMLDoc.createProcessingInstruction("xml", "version=""1.0"" encoding=""utf-8""")
		'	If objXMLDoc.childNodes.Length>0 Then
		'		Call objXMLDoc.insertBefore(objNodeHeader, objXMLDoc.childNodes.Item(0))
		'	End If
		'End If

		If objXMLDoc.ParseError.ErrorCode <> 0 Then
			Dim parseError
			Set parseError = objXMLDoc.ParseError
			Response.Write("XML parse error " & parseError.ErrorCode & " [" & parseError.Reason & "]")
			Set parseError = Nothing
		End If
	End If

	'Retour de la fonction
	Set getXMLDocument = objXMLDoc

	'Suppresion des objets inutilisés
	Set objXMLDoc = Nothing
End Function
'************************************************  FIN  *****************************************************
%>