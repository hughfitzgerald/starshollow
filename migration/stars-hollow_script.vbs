Include("scripts\\dest\\vpx\\tablescript.vbs")

Sub Include (strFile)
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set objTextFile = objFSO.OpenTextFile(strFile, 1)
	ExecuteGlobal objTextFile.ReadAll
	objTextFile.Close
	Set objFSO = Nothing
	Set objTextFile = Nothing
End Sub
