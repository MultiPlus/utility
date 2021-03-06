<%
'********************************************** CONSTANTE ***************************************************
Const adTypeBinary = 1
Const adTypeText = 2
'********************************************** CONSTANTE ***************************************************
%>
<%
'************************************************************************************************************
'*	 PROCEDURE   : HTMLDecode
'*   PARAM 	     : strSrc (STRING) : Ressource HTML Encod�e
'*	 RETURN      : HTMLDecode (STRING) : Ressource HTML D�ncod�e
'*   DESCRIPTION : Permet de d�coder une chaine de caract�re contenant des balise HTML encod� avec la 
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
'*   PARAM 	     : strIn (STRING) : Ressource text (Cha�ne de caract�re)
'*       	     : strCharset (STRING) : Cha�ne indiquant le type d'encodage en sortie (UTF-8, ISO-8859-1...)
'*	 RETURN      : bytesToString (STRING) : Cha�ne de caract�re encod� au Charset indiqu�
'*   DESCRIPTION : Permet d'encoder une cha�ne de caract�re sous format binaire avec le type ad�quate passer en param�tre
'************************************************ DEBUT *****************************************************
Function StringToBytes(strIn, strCharset)
  Dim Stream : Set Stream = Server.CreateObject("ADODB.Stream")
  Stream.Type = adTypeText
  Stream.Charset = strCharset
  Stream.Open
  Call Stream.WriteText(strIn)
  Stream.Flush
  Stream.Position = 0
  
  'R�ecriture de la cha�ne en Bytes
  Stream.Type = adTypeBinary
  
  'Retour de la fonction
  StringToBytes = Stream.Read
  
  'Fermeture et suppresion des objets inutilis�s
  Stream.Close
  Set Stream = Nothing
End Function
'************************************************  FIN  *****************************************************
%>
<%
'************************************************************************************************************
'*	 FUNCTION    : bytesToString
'*   PARAM 	     : arrBytes (ARRAY OF BYTE) : Ressource text sous format binaire
'*       	     : strCharset (STRING) : Cha�ne indiquant le type d'encodage en sortie (UTF-8, ISO-8859-1...)
'*	 RETURN      : bytesToString (STRING) : Cha�ne de caract�re encod� au Charset indiqu�
'*   DESCRIPTION : Permet d'encoder une cha�ne de caract�re sous format binaire avec le type ad�quate passer en param�tre
'************************************************ DEBUT *****************************************************
Function BytesToString(arrBytes, strCharset)
  Dim Stream : Set Stream = Server.CreateObject("ADODB.Stream")
  Stream.Charset = strCharset
  Stream.Type = adTypeBinary
  Stream.Open
  Call Stream.Write(arrBytes)
  Stream.Flush
  Stream.Position = 0
  
  'R�ecriture du binaire en cha�ne
  Stream.Type = adTypeText
  
  'Retour de la fonction
  BytesToString = Stream.ReadText
  
  'Fermeture et suppresion des objets inutilis�s
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
'*   PARAM       : str (STRING) : Cha�ne � transformer
'*   RETURN      : str (STRING) : Cha�ne transformer
'*   DESCRIPTION : Permet de mettre le premier caract�re d'un cha�ne en majuscule.
'************************************************ DEBUT *****************************************************
Function UCaseFirst(str)
  UCaseFirst = UCase(Left(str,1)) & LCase(Right(str, Len(str) - 1))
End Function
'************************************************  FIN  *****************************************************
%>
<%
'************************************************************************************************************
'*   PROCEDURE   : URLDecode
'*   PARAM       : strURL (STRING) : URL � d�coder
'*   RETURN      : strRet (STRING) : URL d�cod�
'*   DESCRIPTION : Permet de d�coder une URL (caract�res sp�ciaux %20...)
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