B4i=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=8.45
@EndOfDesignText@
#If Documentation
Updates
V1.00
	-Release
V1.01
	-BugFixes
	-Add get and set MaxSelectionCount - Only in SelectionMode = Multi - Defines the maximum number of items that may be selected
		-Default: 0
V1.02
	-Add Designer Property HapticFeedback
		-Default: True
	-BugFix on SearchByText - No longer takes capitalization into account
V1.03
	-BugFixes and Improvemets
	-Add Clear
	-Add RebuildList
	-Add CreateViewPerCode
	-Add "Height" to AS_SelectionList_ItemProperties Type 
V1.04
	-BugFixes
#End If

#DesignerProperty: Key: ThemeChangeTransition, DisplayName: ThemeChangeTransition, FieldType: String, DefaultValue: Fade, List: None|Fade
#DesignerProperty: Key: SelectionMode, DisplayName: SelectionMode, FieldType: String, DefaultValue: Single, List: Single|Multi
#DesignerProperty: Key: CanDeselect, DisplayName: CanDeselect, FieldType: Boolean, DefaultValue: True , Description: If true, then the user can remove the selection by clicking again
#DesignerProperty: Key: HapticFeedback, DisplayName: HapticFeedback, FieldType: Boolean, DefaultValue: True

#DesignerProperty: Key: BackgroundColor, DisplayName: Background Color, FieldType: Color, DefaultValue: 0xFFFFFFFF
#DesignerProperty: Key: ItemBackgroundColor, DisplayName: ItemBackgroundColor Color, FieldType: Color, DefaultValue: 0xFFE3E2E8
#DesignerProperty: Key: ShowSeperators, DisplayName: ShowSeperators, FieldType: Boolean, DefaultValue: True , Description: Show seperators between items
#DesignerProperty: Key: SeperatorColor, DisplayName: SeperatorColor, FieldType: Color, DefaultValue: 0x28000000

#Event: SelectionChanged

Sub Class_Globals
	
	Type AS_SelectionList_Item(Text As String,Icon As B4XBitmap,Value As Object)
	Type AS_SelectionList_ItemProperties(BackgroundColor As Int,xFont As B4XFont,TextColor As Int,SeperatorColor As Int,Height As Float)
	
	Private mEventName As String 'ignore
	Private mCallBack As Object 'ignore
	Public mBase As B4XView
	Private xui As XUI 'ignore
	Public Tag As Object
	Private m_DataMap As B4XOrderedMap
	
	Private g_ItemProperties As AS_SelectionList_ItemProperties
	
	Private xclv_Main As CustomListView
	Private m_SelectionMap As Map
	
	Private m_SideGap As Float = 10dip
	Private m_SelectionMode As String
	Private m_CanDeselect As Boolean
	Private m_BackgroundColor As Int
	Private m_ThemeChangeTransition As String
	Private m_ShowSeperators As Boolean
	Private m_MaxSelectionCount As Int = 0
	Private m_HapticFeedback As Boolean
	
	Private xiv_RefreshImage As B4XView
	
	Type AS_SelectionList_Theme(BackgroundColor As Int,Item_BackgroundColor As Int,Item_TextColor As Int,Item_SeperatorColor As Int)
	
End Sub

Public Sub setTheme(Theme As AS_SelectionList_Theme)
	
	xiv_RefreshImage.SetBitmap(mBase.Snapshot)
	xiv_RefreshImage.SetVisibleAnimated(0,True)

	g_ItemProperties.BackgroundColor = Theme.Item_BackgroundColor
	g_ItemProperties.TextColor = Theme.Item_TextColor
	g_ItemProperties.SeperatorColor = Theme.Item_SeperatorColor
	
	Sleep(0)
	
	setBackgroundColor(Theme.BackgroundColor)
	For i = 0 To xclv_Main.Size -1
		xclv_Main.GetPanel(i).RemoveAllViews
	Next
	xclv_Main.Refresh
	
	Sleep(250)
	
	Select m_ThemeChangeTransition
		Case "None"
			xiv_RefreshImage.SetVisibleAnimated(0,False)
		Case "Fade"
			xiv_RefreshImage.SetVisibleAnimated(250,False)
	End Select
	
End Sub

Public Sub getTheme_Dark As AS_SelectionList_Theme
	
	Dim Theme As AS_SelectionList_Theme
	Theme.Initialize
	Theme.BackgroundColor = xui.Color_ARGB(255,19, 20, 22)
	Theme.Item_BackgroundColor = xui.Color_ARGB(255,32, 33, 37)
	Theme.Item_TextColor = xui.Color_White
	Theme.Item_SeperatorColor = xui.Color_ARGB(40,255,255,255)
	
	Return Theme
	
End Sub

Public Sub getTheme_Light As AS_SelectionList_Theme
	
	Dim Theme As AS_SelectionList_Theme
	Theme.Initialize
	Theme.BackgroundColor = xui.Color_White
	Theme.Item_BackgroundColor = xui.Color_ARGB(255,227, 226, 232)
	Theme.Item_TextColor = xui.Color_Black
	Theme.Item_SeperatorColor = xui.Color_ARGB(40,0,0,0)
	
	Return Theme
	
End Sub

Public Sub Initialize (Callback As Object, EventName As String)
	mEventName = EventName
	mCallBack = Callback
	m_SelectionMap.Initialize
	m_DataMap.Initialize
End Sub

Public Sub CreateViewPerCode(Parent As B4XView,Left As Float,Top As Float,Width As Float,Height As Float)
	
	Dim xpnl_ViewBase As B4XView = xui.CreatePanel("")
	Parent.AddView(xpnl_ViewBase,Left,Top,Width,Height)
	
	DesignerCreateView(xpnl_ViewBase,CreateLabel(""),CreateMap())
	
End Sub

'Base type must be Object
Public Sub DesignerCreateView (Base As Object, Lbl As Label, Props As Map)
	mBase = Base
    Tag = mBase.Tag
	mBase.Tag = Me

	IniProps(Props)

	mBase.Color = m_BackgroundColor

	Dim xpnl_ListBackground As B4XView = xui.CreatePanel("")
	mBase.AddView(xpnl_ListBackground,0,0,mBase.Width,mBase.Height)
	xclv_Main = ini_xclv("xclv_Main",xpnl_ListBackground,xui.IsB4J)

	xiv_RefreshImage = CreateImageView("")
	xiv_RefreshImage.Visible = False
	mBase.AddView(xiv_RefreshImage,0,0,mBase.Width,mBase.Height)

	#If B4A
	Base_Resize(mBase.Width,mBase.Height)
	#End If

End Sub

Private Sub IniProps(Props As Map)
	
	m_ThemeChangeTransition = Props.GetDefault("ThemeChangeTransition","Fade")
	m_BackgroundColor = xui.PaintOrColorToColor(Props.GetDefault("BackgroundColor",0xFFFFFFFF))
	m_SelectionMode = Props.GetDefault("SelectionMode","Single")
	m_CanDeselect = Props.GetDefault("CanDeselect",True)
	m_ShowSeperators = Props.GetDefault("ShowSeperators",True)
	m_HapticFeedback = Props.GetDefault("HapticFeedback",True)
	
	g_ItemProperties.Initialize
	g_ItemProperties.BackgroundColor = xui.PaintOrColorToColor(Props.GetDefault("ItemBackgroundColor",0xFFE3E2E8))
	g_ItemProperties.TextColor = xui.Color_Black
	g_ItemProperties.xFont = xui.CreateDefaultBoldFont(18)
	g_ItemProperties.SeperatorColor = xui.PaintOrColorToColor(Props.GetDefault("SeperatorColor",0x28000000))
	g_ItemProperties.Height = 50dip
	
End Sub

Public Sub Base_Resize (Width As Double, Height As Double)
	mBase.SetLayoutAnimated(0,mBase.Left,mBase.Top,Width,Height)
	xiv_RefreshImage.SetLayoutAnimated(0,0,0,Width,Height)
	xclv_Main.AsView.SetLayoutAnimated(0,0,0,Width,Height)
	xclv_Main.Base_Resize(Width,Height)
End Sub

#Region Methods

Public Sub AddItem(Text As String,Icon As B4XBitmap,Value As Object) As AS_SelectionList_Item
	
	Dim Item As AS_SelectionList_Item
	Item.Initialize
	Item.Text = Text
	Item.Icon = Icon
	Item.Value = Value
	
	AddItemIntern(Item,True)
	Return Item
End Sub

Private Sub AddItemIntern(Item As AS_SelectionList_Item,Add2DataMap As Boolean)
	
	Dim xpnl_Background As B4XView = xui.CreatePanel("")
	xpnl_Background.SetLayoutAnimated(0,0,0,mBase.Width,g_ItemProperties.Height)
	xpnl_Background.Color = m_BackgroundColor
	
	If Add2DataMap Then m_DataMap.Put(Item,xclv_Main.Size)
	xclv_Main.Add(xpnl_Background,Item)
	
End Sub

Public Sub Clear
	xclv_Main.Clear
	m_DataMap.Clear
End Sub

Public Sub RebuildList
	xiv_RefreshImage.SetBitmap(mBase.Snapshot)
	xiv_RefreshImage.SetVisibleAnimated(0,True)
	Sleep(0)
	
	xclv_Main.Clear
	m_DataMap.Values.Sort(True)
	For Each Item As AS_SelectionList_Item In m_DataMap.Keys
		AddItemIntern(Item,False)
	Next
	
	Sleep(0)
	xiv_RefreshImage.SetVisibleAnimated(0,False)
End Sub

Public Sub SearchByText(Text As String)
	xiv_RefreshImage.SetBitmap(mBase.Snapshot)
	xiv_RefreshImage.SetVisibleAnimated(0,True)
	Sleep(0)
	
	xclv_Main.Clear
	m_DataMap.Values.Sort(True)
	For Each Item As AS_SelectionList_Item In m_DataMap.Keys
		If Item.Text.ToLowerCase.Contains(Text.ToLowerCase) Then AddItemIntern(Item,False)
	Next
	
	Sleep(0)
	xiv_RefreshImage.SetVisibleAnimated(0,False)
End Sub

Public Sub SearchByValue(Value As Object)
	xiv_RefreshImage.SetBitmap(mBase.Snapshot)
	xiv_RefreshImage.SetVisibleAnimated(0,True)
	Sleep(0)
	
	xclv_Main.Clear
	m_DataMap.Values.Sort(True)
	For Each Item As AS_SelectionList_Item In m_DataMap.Keys
		If Item.Value = Value Then AddItemIntern(Item,False)
	Next
	
	Sleep(0)
	xiv_RefreshImage.SetVisibleAnimated(0,False)
End Sub

Public Sub ClearSearch
	RebuildList
End Sub

Public Sub ClearSelections
	m_SelectionMap.Clear
	For i = 0 To xclv_Main.Size -1
		xclv_Main.GetPanel(i).RemoveAllViews
	Next
	xclv_Main.Refresh
	SelectionChanged
End Sub

'<code>
'	For Each Item As AS_SelectionList_Item In AS_SelectionList1.GetSelections
'		Log("Item selected: " & Item.Text)
'	Next
'</code>
Public Sub GetSelections As List
	Dim lst As List
	lst.Initialize
	For Each k As AS_SelectionList_Item In m_SelectionMap.Keys
		lst.Add(k)
	Next
	Return lst
End Sub

'<code>AS_SelectionList1.SetSelections(Array As Object(1,3))</code>
Public Sub SetSelections(Values() As Object)
	xiv_RefreshImage.SetBitmap(mBase.Snapshot)
	xiv_RefreshImage.SetVisibleAnimated(0,True)
	Sleep(0)
	
	Dim tmpMap As Map
	tmpMap.Initialize
	For Each Value As Object In Values
		tmpMap.Put(Value,"")
	Next
	
	m_SelectionMap.Clear
	For i = 0 To xclv_Main.Size -1
		Dim ThisItem As AS_SelectionList_Item = xclv_Main.GetValue(i)
		If tmpMap.ContainsKey(ThisItem.Value) Then
			m_SelectionMap.Put(ThisItem,i)
		End If
		xclv_Main.GetPanel(i).RemoveAllViews
	Next
	xclv_Main.Refresh
	Sleep(0)
	xiv_RefreshImage.SetVisibleAnimated(0,False)
	
End Sub

#End Region

#Region Properties

'Fade or None
Public Sub setThemeChangeTransition(ThemeChangeTransition As String)
	m_ThemeChangeTransition = ThemeChangeTransition
End Sub

Public Sub getThemeChangeTransition As String
	Return m_ThemeChangeTransition
End Sub

Public Sub setHapticFeedback(HapticFeedback As Boolean)
	m_HapticFeedback = HapticFeedback
End Sub

Public Sub getHapticFeedback As Boolean
	Return m_HapticFeedback
End Sub

'Single or Multi
Public Sub getSelectionMode As String
	Return m_SelectionMode
End Sub

Public Sub setSelectionMode(SelectionMode As String)
	m_SelectionMode = SelectionMode
End Sub

'Only in SelectionMode = Multi - Defines the maximum number of items that may be selected
'Default: 0
Public Sub setMaxSelectionCount(MaxSelecion As Int)
	m_MaxSelectionCount = MaxSelecion
End Sub

Public Sub getMaxSelectionCount As Int
	Return m_MaxSelectionCount
End Sub

Public Sub getSize As Int
	Return m_DataMap.Size
End Sub

Public Sub setBackgroundColor(BackgroundColor As Int)
	m_BackgroundColor = BackgroundColor
	mBase.Color = BackgroundColor
	xclv_Main.AsView.Color = BackgroundColor
	xclv_Main.sv.ScrollViewInnerPanel.Color = BackgroundColor
	xclv_Main.GetBase.Color = BackgroundColor
End Sub

Public Sub getBackgroundColor As Int
	Return m_BackgroundColor
End Sub

'Height: Default: 50dip
Public Sub getItemProperties As AS_SelectionList_ItemProperties
	Return g_ItemProperties
End Sub

#End Region

#Region InternFunctions

Private Sub BuildItem(xpnl_Background As B4XView,Item As AS_SelectionList_Item)
	Dim xpnl_ItemBackground As B4XView = xui.CreatePanel("")
	xpnl_ItemBackground.Tag = "xpnl_ItemBackground"
	xpnl_Background.AddView(xpnl_ItemBackground,m_SideGap,0,mBase.Width - m_SideGap*2,xpnl_Background.Height)
	xpnl_Background.Color = m_BackgroundColor
	xpnl_ItemBackground.Color = g_ItemProperties.BackgroundColor
	
	Dim TextGap As Float = 5dip
	

	Dim xlbl_ItemText As B4XView = CreateLabel("")
	xlbl_ItemText.Text = Item.Text
	xlbl_ItemText.Font = g_ItemProperties.xFont
	xlbl_ItemText.TextColor = g_ItemProperties.TextColor
	xlbl_ItemText.SetTextAlignment("CENTER","LEFT")
	#If B4I
	xlbl_ItemText.As(Label).Multiline = True
	#Else If B4J
	xlbl_ItemText.As(Label).WrapText = True
	#Else B4A
	xlbl_ItemText.As(Label).SingleLine = False
	#End If
	
	Dim xlbl_CheckItem As B4XView = CreateLabel("")
	xlbl_CheckItem.TextColor = g_ItemProperties.TextColor
	xlbl_CheckItem.SetTextAlignment("CENTER","CENTER")
	xlbl_CheckItem.Font = xui.CreateMaterialIcons(20)
	
	If m_SelectionMap.ContainsKey(Item) Then
		xlbl_CheckItem.Text = Chr(0xE5CA)
	Else
		xlbl_CheckItem.Text = ""
	End If

	Private xpnl_Seperator As B4XView = xui.CreatePanel("")
	xpnl_Seperator.Color = g_ItemProperties.SeperatorColor

	xpnl_ItemBackground.AddView(xlbl_ItemText,TextGap,0,xpnl_ItemBackground.Width - TextGap*2,xpnl_Background.Height)
	xpnl_ItemBackground.AddView(xlbl_CheckItem,xpnl_ItemBackground.Width - 40dip,0,40dip,xpnl_ItemBackground.Height)
	
	Dim xiv_Icon As B4XView = CreateImageView("")
	If Item.Icon.IsInitialized Then
		xpnl_ItemBackground.AddView(xiv_Icon,TextGap,(xpnl_Background.Height)/2 - ((xpnl_Background.Height)/2)/2,(xpnl_Background.Height)/2,(xpnl_Background.Height)/2)
		xlbl_ItemText.Left = xiv_Icon.Left + xiv_Icon.Width + 5dip
		xlbl_ItemText.Width = xlbl_ItemText.Width - xiv_Icon.Width - 5dip
		xiv_Icon.SetBitmap(Item.Icon)
	End If
	
	xpnl_ItemBackground.AddView(xpnl_Seperator,xlbl_ItemText.Left,0,xpnl_ItemBackground.Width,1dip)
	
	Dim CurrentIndex As Int = xclv_Main.GetItemFromView(xpnl_ItemBackground)
	xpnl_Seperator.Visible = m_ShowSeperators And CurrentIndex > 0
	If CurrentIndex = 0 Or CurrentIndex = (xclv_Main.Size -1) Then
		xpnl_ItemBackground.SetColorAndBorder(xpnl_ItemBackground.Color,0,0,10dip)
		
		Dim xpnl_Tmp As B4XView = xui.CreatePanel("")
		xpnl_Tmp.Color = xpnl_ItemBackground.Color
		xpnl_Background.AddView(xpnl_Tmp,xpnl_ItemBackground.Left,IIf(CurrentIndex = 0,xpnl_ItemBackground.Height/2,xpnl_ItemBackground.Top),xpnl_ItemBackground.Width,IIf(CurrentIndex = (xclv_Main.Size -1),xpnl_ItemBackground.Height/2,xpnl_ItemBackground.Height))
		xpnl_Tmp.SendToBack
	End If
	
End Sub

#End Region

#Region ViewEvents

Private Sub xclv_Main_ItemClick (Index As Int, Value As Object)
	
	Dim ThisItem As AS_SelectionList_Item = Value
	
	If m_SelectionMap.ContainsKey(ThisItem) And m_CanDeselect Then
		m_SelectionMap.Remove(ThisItem)
		HandleSelection(xclv_Main.GetPanel(Index),False)
		SelectionChanged
	Else If m_SelectionMap.ContainsKey(ThisItem) = False Then
		
		If m_SelectionMode = "Single" Then
			For i = 0 To xclv_Main.size -1
				If m_SelectionMap.ContainsKey(xclv_Main.GetValue(i).As(AS_SelectionList_Item)) Then
					HandleSelection(xclv_Main.GetPanel(i),False)
					Exit
				End If
			Next
			m_SelectionMap.Clear
			m_SelectionMap.Put(ThisItem,Index)
			HandleSelection(xclv_Main.GetPanel(Index),True)
			SelectionChanged
		Else If m_SelectionMode = "Multi" Then
			If m_MaxSelectionCount > 0 And m_MaxSelectionCount = m_SelectionMap.Size Then Return
			m_SelectionMap.Put(ThisItem,Index)
			HandleSelection(xclv_Main.GetPanel(Index),True)
			SelectionChanged
		End If
		
	End If

End Sub

Private Sub HandleSelection(xpnl_Background As B4XView,isSelected As Boolean)
	
	Dim xpnl_ItemBackground As B4XView
	For Each view As B4XView In xpnl_Background.GetAllViewsRecursive
		If view.Tag Is String And view.Tag = "xpnl_ItemBackground" Then
			xpnl_ItemBackground = view
			Exit
		End If
	Next
	If xpnl_ItemBackground.IsInitialized = False Then Return
	
	Dim xlbl_CheckItem As B4XView = xpnl_ItemBackground.GetView(1)
	If isSelected Then
		xlbl_CheckItem.Text = Chr(0xE5CA)
	Else
		xlbl_CheckItem.Text = ""
	End If

End Sub


Private Sub xclv_Main_VisibleRangeChanged (FirstIndex As Int, LastIndex As Int)
	Dim ExtraSize As Int = 20
	For i = 0 To xclv_Main.Size - 1
		Dim p As B4XView = xclv_Main.GetPanel(i)
		If i > FirstIndex - ExtraSize And i < LastIndex + ExtraSize Then
			'visible+
			If p.NumberOfViews = 0 Then
				BuildItem(p,xclv_Main.GetValue(i))
			End If
		Else
			'not visible
			If p.NumberOfViews > 0 Then
				p.RemoveAllViews
			End If
		End If
	Next
End Sub

#End Region

#Region Events

Private Sub SelectionChanged
	If m_HapticFeedback Then XUIViewsUtils.PerformHapticFeedback(mBase)
	If xui.SubExists(mCallBack, mEventName & "_SelectionChanged",0) Then
		CallSub(mCallBack, mEventName & "_SelectionChanged")
	End If
End Sub

#End Region

#Region Enums

Public Sub getThemeChangeTransition_Fade As String
	Return "Fade"
End Sub

Public Sub getThemeChangeTransition_None As String
	Return "None"
End Sub

Public Sub getSelectionMode_Single As String
	Return "Single"
End Sub

Public Sub getSelectionMode_Multi As String
	Return "Multi"
End Sub

#End Region

#Region Functions

Private Sub ini_xclv(EventName As String,Parent As B4XView,ShowScrollBar As Boolean) As CustomListView
	Dim tmplbl As Label
	tmplbl.Initialize("")
 
	Dim clv As CustomListView
 
	Dim tmpmap As Map
	tmpmap.Initialize
	tmpmap.Put("DividerColor",0x00FFFFFF)
	tmpmap.Put("DividerHeight",0)
	tmpmap.Put("PressedColor",0x00FFFFFF)
	tmpmap.Put("InsertAnimationDuration",0)
	tmpmap.Put("ListOrientation","Vertical")
	tmpmap.Put("ShowScrollBar",False)
	clv.Initialize(Me,EventName)
	clv.DesignerCreateView(Parent,tmplbl,tmpmap)

	#If B4I
	Do While clv.sv.IsInitialized = False
		'Sleep(0)
	Loop
	Dim sv As ScrollView = clv.sv
	sv.Color = xui.Color_Transparent
	clv.sv.As(NativeObject).SetField("contentInsetAdjustmentBehavior", 1) 'Always
	#Else IF B4J
	clv.sv.As(ScrollPane).Style = "-fx-background:transparent;-fx-background-color:transparent;"
	#End If
	
	Return clv
	
End Sub

Private Sub CreateLabel(EventName As String) As B4XView
	Dim lbl As Label
	lbl.Initialize(EventName)
	Return lbl
End Sub

Private Sub CreateImageView(EventName As String) As B4XView
	Dim iv As ImageView
	iv.Initialize(EventName)
	Return iv
End Sub

'https://www.b4x.com/android/forum/threads/fontawesome-to-bitmap.95155/post-603250
Public Sub FontToBitmap (text As String, IsMaterialIcons As Boolean, FontSize As Float, color As Int) As B4XBitmap
	Dim xui As XUI
	Dim p As B4XView = xui.CreatePanel("")
	p.SetLayoutAnimated(0, 0, 0, 32dip, 32dip)
	Dim cvs1 As B4XCanvas
	cvs1.Initialize(p)
	Dim fnt As B4XFont
	If IsMaterialIcons Then fnt = xui.CreateMaterialIcons(FontSize) Else fnt = xui.CreateFontAwesome(FontSize)
	Dim r As B4XRect = cvs1.MeasureText(text, fnt)
	Dim BaseLine As Int = cvs1.TargetRect.CenterY - r.Height / 2 - r.Top
	cvs1.DrawText(text, cvs1.TargetRect.CenterX, BaseLine, fnt, color, "CENTER")
	Dim b As B4XBitmap = cvs1.CreateBitmap
	cvs1.Release
	Return b
End Sub

#End Region