﻿B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
#Region Shared Files
#CustomBuildAction: folders ready, %WINDIR%\System32\Robocopy.exe,"..\..\Shared Files" "..\Files"
'Ctrl + click to sync files: ide://run?file=%WINDIR%\System32\Robocopy.exe&args=..\..\Shared+Files&args=..\Files&FilesSync=True
#End Region

'Ctrl + click to export as zip: ide://run?File=%B4X%\Zipper.jar&Args=Project.zip

Sub Class_Globals
	Private Root As B4XView
	Private xui As XUI
	Private AS_SelectionList1 As AS_SelectionList
	Private xtf_Search As B4XView
End Sub

Public Sub Initialize
	
End Sub

'This event will be called once, before the page becomes visible.
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	Root.LoadLayout("frm_main")
	
	B4XPages.SetTitle(Me,"AS_SelectionList Example")
	
	AS_SelectionList1.SideGap = 100dip
	
	AS_SelectionList1.SelectedItemProperties.xFont = xui.CreateDefaultBoldFont(24)
	AS_SelectionList1.SelectedItemProperties.BackgroundColor = xui.Color_Red
	AS_SelectionList1.MaxSelectionCount = 3
	For i = 0 To 80 -1
		'AS_SelectionList1.AddItem("Test " & (i+1),AS_SelectionList1.FontToBitmap(Chr(0xF179),False,30,xui.Color_Black),i)
		AS_SelectionList1.AddItem("Test " & (i+1),Null,i)
	Next
	
'	Sleep(4000)
'	Dim lst As List
'	lst.Initialize
'	lst.Add(1)
'	lst.Add(3)
'	AS_SelectionList1.SetSelections2(lst)
End Sub


Private Sub xtf_Search_TextChanged (OldText As String, NewText As String)
	Sleep(0)
	AS_SelectionList1.SearchByText(NewText)
End Sub

Private Sub AS_SelectionList1_SelectionChanged
	
	For Each Item As AS_SelectionList_Item In AS_SelectionList1.GetSelections
		Log("Item selected: " & Item.Text)
	Next

End Sub