<%
'********************************************** CONSTANTE ***************************************************
Const adTypeBinary = 1
Const adTypeText = 2
'********************************************** CONSTANTE ***************************************************
%>
<%
'************************************************************************************************************
'*	 PROCEDURE   : HTMLDecode
'*   PARAM 	     : strSrc (STRING) : Ressource HTML Encodée
'*	 RETURN      : HTMLDecode (STRING) : Ressource HTML Déncodée
'*   DESCRIPTION : Permet de décoder une chaine de caractère contenant des balise HTML encodé avec la 
'*				   fonction Server.HTMLEncode()
'************************************************ DEBUT *****************************************************
Function HTMLDecode(strSrc)
    strSrc = Replace(strSrc, "&quot;", Chr(34))
    strSrc = Replace(strSrc, "&lt;"  , Chr(60))
    strSrc = Replace(strSrc, "&gt;"  , Chr(62))
    strSrc = Replace(strSrc, "&amp;" , Chr(38))
    strSrc = Replace(strSrc, "&nbsp;", Chr(32))
	Dim i
    For i = 1 to 255
        strSrc = Replace(strSrc, "&#" & i & ";", Chr(i))
    Next
	HTMLDecode = strSrc
End Function
'************************************************  FIN  *****************************************************
%>
<%
'************************************************************************************************************
'*	 FUNCTION    : StringToBytes
'*   PARAM 	     : strIn (STRING) : Ressource text (Chaîne de caractère)
'*       	     : strCharset (STRING) : Chaîne indiquant le type d'encodage en sortie (UTF-8, ISO-8859-1...)
'*	 RETURN      : bytesToString (STRING) : Chaîne de caractère encodé au Charset indiqué
'*   DESCRIPTION : Permet d'encoder une chaîne de caractère sous format binaire avec le type adéquate passer en paramêtre
'************************************************ DEBUT *****************************************************
Function StringToBytes(strIn, strCharset)
  Dim Stream : Set Stream = Server.CreateObject("ADODB.Stream")
  Stream.Type = adTypeText
  Stream.Charset = strCharset
  Stream.Open
  Call Stream.WriteText(strIn)
  Stream.Flush
  Stream.Position = 0
  
  'Réecriture de la chaîne en Bytes
  Stream.Type = adTypeBinary
  
  'Retour de la fonction
  StringToBytes = Stream.Read
  
  'Fermeture et suppresion des objets inutilisés
  Stream.Close
  Set Stream = Nothing
End Function
'************************************************  FIN  *****************************************************
%>
<%
'************************************************************************************************************
'*	 FUNCTION    : bytesToString
'*   PARAM 	     : arrBytes (ARRAY OF BYTE) : Ressource text sous format binaire
'*       	     : strCharset (STRING) : Chaîne indiquant le type d'encodage en sortie (UTF-8, ISO-8859-1...)
'*	 RETURN      : bytesToString (STRING) : Chaîne de caractère encodé au Charset indiqué
'*   DESCRIPTION : Permet d'encoder une chaîne de caractère sous format binaire avec le type adéquate passer en paramêtre
'************************************************ DEBUT *****************************************************
Function BytesToString(arrBytes, strCharset)
  Dim Stream : Set Stream = Server.CreateObject("ADODB.Stream")
  Stream.Charset = strCharset
  Stream.Type = adTypeBinary
  Stream.Open
  Call Stream.Write(arrBytes)
  Stream.Flush
  Stream.Position = 0
  
  'Réecriture du binaire en chaîne
  Stream.Type = adTypeText
  
  'Retour de la fonction
  BytesToString = Stream.ReadText
  
  'Fermeture et suppresion des objets inutilisés
  Stream.Close
  Set Stream = Nothing
End Function

' This will alter charset of a string from 1-byte charset(as windows-1252)
' to another 1-byte charset(as windows-1251)
Function AlterCharset(Str, strFromCharset, strToCharset)
  Dim arrBytes : arrBytes = StringToBytes(Str, strFromCharset)
  AlterCharset = BytesToString(arrBytes, strToCharset)
End Function
'************************************************  FIN  *****************************************************
%>
<%
'************************************************************************************************************
'*   FUNCTION    : UCaseFirst
'*   PARAM       : str (STRING) : Chaîne à transformer
'*   RETURN      : str (STRING) : Chaîne transformer
'*   DESCRIPTION : Permet de mettre le premier caractère d'un chaîne en majuscule.
'************************************************ DEBUT *****************************************************
Function UCaseFirst(str)
  UCaseFirst = UCase(Left(str,1)) & LCase(Right(str, Len(str) - 1))
End Function
'************************************************  FIN  *****************************************************
%>
<%
'************************************************************************************************************
'*   PROCEDURE   : URLDecode
'*   PARAM       : strURL (STRING) : URL à décoder
'*   RETURN      : strRet (STRING) : URL décodé
'*   DESCRIPTION : Permet de décoder une URL (caractères spéciaux %20...)
'************************************************ DEBUT *****************************************************
Function URLDecode(strURL)
    Dim arrSplit, strRet
    If IsNull(strURL) Then
       URLDecode = ""
       Exit Function
    End If

    strRet = REPLACE(strURL, "+", " ")
    arrSplit = Split(strRet, "%")

    If IsArray(arrSplit) Then
      strRet = arrSplit(0)
      Dim i
      For i = 0 to UBound(arrSplit) - 1
        strRet = strRet & _
          Chr("&H" & Left(arrSplit(i + 1), 2)) &_
          Right(arrSplit(i + 1), Len(arrSplit(i + 1)) - 2)
      Next
    End If

    URLDecode = strRet
End Function
'************************************************  FIN  *****************************************************
%>