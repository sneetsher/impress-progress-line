REM  *****  BASIC  *****

Dim iFileNumber As Integer
Dim iSectionCount As Integer
Dim iSectionPage As Integer
Dim iSectionIndex As Integer
Dim iSectionIndexCurrent As Integer

Dim oDocument As Object
Dim oPage As Object
Dim iPageCount As Integer
Dim oPositionPageMark As New com.sun.star.awt.Point
Dim oSizePageMark As New com.sun.star.awt.Size
Dim oSizeSectionTitle As New com.sun.star.awt.Size


Sub ProgressLineAdd

    'Default values
    'sBulletShape = "com.sun.star.drawing.RectangleShape"
    sBulletShape = "com.sun.star.drawing.EllipseShape"
    'Values are fracture of page width
    oSizePageMark_Width = 0.02
    oSizePageMark_Height = 0.02
    oSizeSectionTitle_Width = 0.20
    oSizeSectionTitle_Height = 0.03
    dSeparationRatioSection = 3.0
    dMargin_Start = 0.05
    dMargin_End = 0.10
    dMargin_Side = 0.03

    oFillColorPageMarkActive = RGB(255,0,0)
    oFillColorPageMarkInactive = RGB(240, 200, 200)
    oCharColorSectionTitleActive = RGB(255, 0, 0)
    oCharColorSectionTitleInactive = RGB(150, 150, 150)


    ProgressLineRemove()

    oDocument = ThisComponent
    If oDocument.supportsService("com.sun.star.drawing.GenericDrawingDocument") Then
        'Load index
        sIndexPath = oDocument.URL
        sIndexPath = Mid( Left(sIndexPath, InStr(sIndexPath, ".odp")-1) & ".index",1,Len(sIndexPath)+2)
        iFileNumber = Freefile
        Open sIndexPath For Input As #iFileNumber
        'First line is section total count
        If Not eof(#iFileNumber) Then
            Line Input #iFileNumber, sLine
            If sLine<>"" Then
                iSectionCount = Int(sLine)
            End If
        End If
        'Remaining lines for sections: page, title
        iPageCount = oDocument.DrawPages.Count
        Dim sSectionTitle(iPageCount) As String
        While Not eof(#iFileNumber)
            Line Input #iFileNumber, sLine
            If sLine<>"" Then
                iSectionPage = Int(Left(sLine, InStr(sLine, ",")-1))
                sSectionTitle(iSectionPage-1) = Right(sLine, Len(sLine)-InStr(sLine, ","))
            End If
        Wend

        'loop over pages
        iSectionIndex=-1
        For iPageIndex=0 To iPageCount-1
            If sSectionTitle(iPageIndex)<>"" Then
                iSectionIndex = iSectionIndex+1
            End If
            oPage = oDocument.DrawPages(iPageIndex)
            oSizePageMark.Width = oPage.Width*oSizePageMark_Width
            oSizePageMark.Height = oPage.Width*oSizePageMark_Height
            dSeparation = (oPage.Width*(1-dMargin_Start-dMargin_End)-oSizePageMark.Width*iPageCount)/((iPageCount-iSectionCount)+(iSectionCount-1)*dSeparationRatioSection)


            'Place new shapes, loop over page for progress
            iSectionIndexCurrent=-1
            For iPageIndexCurrent=0 To iPageCount-1
                If sSectionTitle(iPageIndexCurrent)<>"" Then
                    iSectionIndexCurrent = iSectionIndexCurrent+1
                End If
                oShape = oDocument.createInstance(sBulletShape)
                oPositionPageMark.x = (iPageIndexCurrent+iSectionIndexCurrent*(dSeparationRatioSection-1))*dSeparation+iPageIndexCurrent*oSizePageMark.Width+oPage.Width*dMargin_Start
                oPositionPageMark.y = oPage.Height-oPage.Width*dMargin_Side-oSizePageMark.Height
                oShape.Size = oSizePageMark
                oShape.Position = oPositionPageMark
                oShape.LineStyle = none
                If (iPageIndexCurrent=iPageIndex) Then
                    oShape.FillColor = oFillColorPageMarkActive
                Else
                    oShape.FillColor = oFillColorPageMarkInactive
                End If
                oShape.Name = "Progress Line RS_" + (iPageIndex+1)+"_"+(iPageIndexCurrent+1)
                oPage.add(oShape)

                'Section titles, skip dummy title: "_"
                If sSectionTitle(iPageIndexCurrent)<>"" And sSectionTitle(iPageIndexCurrent)<>"_" Then        
                    oShape = oDocument.createInstance("com.sun.star.drawing.RectangleShape")    
                    oShape.TextVerticalAdjust = com.sun.star.drawing.TextVerticalAdjust.TOP
                    oShape.TextHorizontalAdjust = com.sun.star.drawing.TextHorizontalAdjust.LEFT
                    oShape.TextLeftDistance = 0
                    oSizeSectionTitle.Width = oPage.Width*oSizeSectionTitle_Width
                    oSizeSectionTitle.Height = oPage.Width*oSizeSectionTitle_Height
                    oShape.Size = oSizeSectionTitle
                    oPositionPageMark.y = oPositionPageMark.y-oSizeSectionTitle.Height
                    oShape.Position = oPositionPageMark
                    oShape.LineStyle = none
                    oShape.FillStyle = none
                    oShape.Name = "Progress Line TS_" + (iPageIndex+1)+"_"+(iPageIndexCurrent+1)
                    oPage.add(oShape)
                    oShape.String = sSectionTitle(iPageIndexCurrent)
                    oShape.CharWeight = com.sun.star.awt.FontWeight.BOLD  
                    oShape.CharFontName = "Arial" 'todo: doesn't work

                    If iSectionIndexCurrent=iSectionIndex Then
                        oShape.CharColor = oCharColorSectionTitleActive
                    Else
                        oShape.CharColor = oCharColorSectionTitleInactive
                    End If 

                End If
            Next iPageIndexCurrent
        Next iPageIndex
        Close #iFileNumber
    End If
End Sub

Sub ProgressLineRemove
    oDocument = ThisComponent
    If oDocument.supportsService("com.sun.star.drawing.GenericDrawingDocument") Then
        'loop over pages
        iSectionIndexCurrent=0
        For iPageIndex=0 To oDocument.DrawPages.Count-1
            oPage = oDocument.DrawPages(iPageIndex)
            'Cleanup old shapes
            iShapeIndex = oPage.getCount-1
            Do While (iShapeIndex>=0)
                oShape = oPage.getByIndex(iShapeIndex)
                If (InStr(oShape.Name, "Progress Line") <> 0) Then
                    oPage.remove(oShape)
                End If
                iShapeIndex = iShapeIndex-1
            Loop
        Next iPageIndex
    End If
End Sub
