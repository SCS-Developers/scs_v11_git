; File: Knob.pbi

;Multi KNOB by einander, modified for SCS by MJD

;PB 5.20 LTS
EnableExplicit

; CompilerIf 1=2
  ; Define Instances=9,Index,Ev,Catch,Offx
  ; Global Dim _Knob.Knob(Instances),_BkRGB=$55
; CompilerElse
  ; Global Dim _Knob.Knob(7),_BkRGB=$55
; CompilerEndIf


Macro MMk()
  Abs(GetAsyncKeyState_(#VK_LBUTTON) +GetAsyncKeyState_(#VK_RBUTTON)*2+GetAsyncKeyState_(#VK_MBUTTON)*3)/$8000   
EndMacro

Macro CMMx(Canv) 
  GetGadgetAttribute(Canv, #PB_Canvas_MouseX)
EndMacro

Macro CMMy(Canv) 
  GetGadgetAttribute(Canv, #PB_Canvas_MouseY)
EndMacro

Procedure Distance(X1, Y1, X2, Y2) ; Ret Int con LONGIT DE LA HIPOTEN DEL TRIANG RECTANG DADOS 2 LADOS
  ProcedureReturn Sqr((X1-X2)*(X1-X2)+(Y1-Y2)*(Y1-Y2))
EndProcedure 

Procedure DrawArc(X, Y, fAng1.f, fAng2.f, fRadius.f, nColor=#SCS_Red)
  Protected fRadian1.f, fRadian2.f
  Protected fStp.f = #PI / (fRadius*4)
  
  fRadian1 = Radian(fAng1)
  fRadian2 = Radian(fAng2)
  If fRadian2 < fRadian1
    Swap fRadian1,fRadian2
  EndIf
  Repeat
    Box(X+Cos(fRadian1) * fRadius, Y+Sin(fRadian1) * fRadius, 2, 2, nColor)
    fRadian1 + fStp
  Until fRadian1 > fRadian2
EndProcedure

Procedure Lim(nValue, nMinValue, nMaxValue)
  If nValue < nMinValue
    ProcedureReturn nMinValue
  ElseIf nValue > nMaxValue
    ProcedureReturn nMaxValue
  Else
    ProcedureReturn nValue
  EndIf
EndProcedure     

Procedure AngLine(X.d,Y.d,Ang.d,LineSize.d,RGB=0)
  ; AngLine(x,y,Ang,LineSize) - Draw Line with Len LineSize From x y with Angle Ang
  LineXY(X,Y,X+Cos(Radian(Ang))*LineSize ,Y+Sin(Radian(Ang))*LineSize,RGB)
EndProcedure 

Macro ConicGradient(X,Y,RGB1,RGB2,Ang)
  DrawingMode(#PB_2DDrawing_Gradient)     
  FrontColor(RGB1)
  BackColor(RGB2)
  ConicalGradient(X, Y,Ang)     
EndMacro

Procedure AngleEndPoint(X.d,Y.d,Ang.d,LineSize.d,*P.Pointf) ; Ret circular end PointF for Line, Angle, Size
  *P\X= X+Cos(Radian(Ang))*LineSize
  *P\Y= Y+Sin(Radian(Ang))*LineSize
EndProcedure

Procedure DrawPie(X,Y, Ang1, Ang2, Radius, RGB)
  Protected Pf.Pointf
  Protected nMyAng1, nMyAng2
  
  nMyAng1 = Ang1
  nMyAng2 = Ang2
  AngLine(X,Y,nMyAng1,Radius,RGB)
  AngLine(X,Y,nMyAng2,Radius,RGB)
  DrawArc(X,Y,nMyAng1,nMyAng2,Radius,RGB)
  AngleEndPoint(X,Y,(nMyAng1+nMyAng2)/2,Radius/2,@Pf)
  FillArea(Pf\X,Pf\Y,-1,RGB)
EndProcedure

Procedure.f GetAngle(X1.f,Y1.f,X2,Y2)  ; Ret Angle (Float)   
  Protected.f a = X2-X1 , B = Y2-Y1 , c = Sqr(a*a+B*B)
  Protected fAng.f = Degree(ACos(a/c))
  Protected fResult.f
  If Y1 > Y2
    fResult = 360.0 - fAng
  Else
    fResult = fAng
  EndIf
  ProcedureReturn fResult
EndProcedure

Procedure SpinKNOB(nIndex)
  PROCNAMEC()
  Protected nPieAngle1, nPieAngle2
  Protected fQAngleSpan.f, fQAngleHalfSpan.f
  Protected fWorkValue.f
  Protected fAngleOfFirstMark.f
  
  CheckSubInRange(nIndex, ArraySize(_Knob()), "_Knob()")
  With _Knob(nIndex)
    Protected RGB
    Protected nRadius = \nSize / 2 - 1
    Protected n, p.Pointf, R = nRadius * 0.8
    
    If IsGadget(\nCanv) = #False
      Debug "_Knob(" + nIndex + ")\nCanv=" + \nCanv
    Else
      StartDrawing(CanvasOutput(\nCanv))
        Box(0,0,OutputWidth(),OutputHeight(),\nBkRGB)
        ConicGradient(\nXCenter,\nYCenter,$333333,$888888,90)
        Circle(\nXCenter,\nYCenter,nRadius)
        DrawingMode(0)
        For n = 0 To 6
          ; AngLine(\nXCenter,\nYCenter,(n*40)-160,Radius*0.93,$AAAAAA)
          ; AngLine(\nXCenter,\nYCenter,(n*40)-160,Radius*0.93,#SCS_Yellow)
          AngLine(\nXCenter,\nYCenter,(n*45)+135,nRadius*0.93,#SCS_Yellow)
        Next n
        ; fAngleOfFirstMark = 90.0 + \fAnglePerMark
        ; For n = 0 To (\nNrOfMarks-1)
          ; AngLine(\nXCenter,\nYCenter,(n*\fAnglePerMark)+fAngleOfFirstMark,nRadius*0.93,#SCS_Yellow)
        ; Next n
        RGB = Point(p\X,p\Y)
        AngleEndPoint(\nXCenter,\nYCenter,\fAngle-90,nRadius*0.84,p.Pointf)
        Circle(\nXCenter,\nYCenter,nRadius*0.85,$121212)
        
        LineXY(\nXCenter,\nYCenter,\nXCenter,\nYCenter-nRadius,0)
        LineXY(\nXCenter,\nYCenter,p\X,p\Y,0)
        
        Select \nKnobType
          Case #SCS_EQTYPE_GAIN
            If \nValue = \nMidValue
              nPieAngle1 = \fAngle-94
              nPieAngle2 = \fAngle-86
            ElseIf \nValue > \nMidValue
              nPieAngle1 = -90
              nPieAngle2 = \fAngle-90
            Else
              nPieAngle1 = \fAngle-90
              nPieAngle2 = 270
            EndIf
            ; Debug "(G) \nValue=" + Str(\nValue) + ", \fAngle=" + StrF(\fAngle,0) + ", nPieAngle1=" + Str(nPieAngle1) + ", nPieAngle2=" + Str(nPieAngle2)
            
          Case #SCS_EQTYPE_Q
            If \nValue = 0
              fWorkValue = \nMaxValue
            Else
              ; If 1=2
                ; fWorkValue = \nMaxValue - (Log10(\nValue) / Log10(\nMaxValue) * \nMaxValue)
              ; Else
                ; ; fWorkValue = \nMaxValue - \nValue
                fWorkValue = \nMaxValue - (Sqr(\nValue) / Sqr(\nMaxValue) * \nMaxValue)
              ; EndIf
            EndIf
            fQAngleSpan = fWorkValue * \fAnglePerUnit
            ; Debug "(Q) \nValue=" + Str(\nValue) + ", \nMaxValue=" + Str(\nMaxValue) + ", fWorkValue=" + StrF(fWorkValue,3) + ", \fAnglePerUnit=" + StrF(\fAnglePerUnit,3) + ", fQAngleSpan=" + StrF(fQAngleSpan,3)
            If (fQAngleSpan >= 0) And (fQAngleSpan < 3)
              fQAngleSpan = 3
            EndIf
            fQAngleHalfSpan = fQAngleSpan / 2
            nPieAngle1 = -90 - fQAngleHalfSpan
            nPieAngle2 = -90 + fQAngleHalfSpan
            ; Debug "(Q) \nValue=" + Str(\nValue) + ", \fAngle=" + StrF(\fAngle,0) + ", fQAngleSpan=" + StrF(fQAngleSpan,0) + ", fQAngleHalfSpan=" + StrF(fQAngleHalfSpan,0) + ", nPieAngle1=" + Str(nPieAngle1) + ", nPieAngle2=" + Str(nPieAngle2)
            
          Default
            nPieAngle1 = \fAngle-94
            nPieAngle2 = \fAngle-86
            ; Debug "(F) \nValue=" + Str(\nValue) + ", \fAngle=" + StrF(\fAngle,0) + ", nPieAngle1=" + Str(nPieAngle1) + ", nPieAngle2=" + Str(nPieAngle2)
            
        EndSelect
        DrawPie(\nXCenter, \nYCenter, nPieAngle1, nPieAngle2, nRadius*0.85, #SCS_Red)
        ConicGradient(\nXCenter,\nYCenter,\nRGB1,\nRGB2,-\fAngle+90)
        Circle(\nXCenter,\nYCenter,nRadius*0.75)
        ConicGradient(\nXCenter,\nYCenter,\nRGB2,\nRGB1,-\fAngle+90)
        Circle(\nXCenter,\nYCenter,nRadius*0.70)
        DrawingMode(#PB_2DDrawing_Outlined)
        Circle(\nXCenter,\nYCenter,nRadius*0.75,$676767)
      StopDrawing()
    EndIf
  EndWith
EndProcedure

Procedure.s knobValueToString(nIndex, bIncludeSuffix)
  PROCNAMEC()
  Protected sStringValue.s
  Protected fUnitValue.f
  Protected fConvertedValue.f
  Protected bFrequency
  Protected nMinFreq, nMaxFreq, nFreqRange
  Protected dMinFreqLog.d, dMaxFreqLog.d, dLogFreqRange.d
  Protected dFreqLog.d
  Protected nMinQ, nMaxQ, nQRange
  Protected dMinQLog.d, dMaxQLog.d, dLogQRange.d
  Protected dQLog.d
  
  CheckSubInRange(nIndex, ArraySize(_Knob()), "_Knob()")
  With _Knob(nIndex)
    Select \nKnobType
      Case #SCS_EQTYPE_LOWCUT_FREQ
        nMinFreq = 20
        nMaxFreq = 400
        bFrequency = #True
        
      Case #SCS_EQTYPE_GAIN
        ; range -15dB to +15dB
        fUnitValue = 30.0 / (\nMaxValue - \nMinValue)
        If \nValue = \nMidValue
          fConvertedValue = 0.0
          sStringValue = "0"
        ElseIf \nValue < \nMidValue
          fConvertedValue = ((\nMidValue - \nValue) * fUnitValue) * -1
          sStringValue = StrF(fConvertedValue,0)
        Else
          fConvertedValue = (\nValue - \nMidValue) * fUnitValue
          sStringValue = "+" + StrF(fConvertedValue,0)
        EndIf
        Select sStringValue
          Case "-0", "+0"
            sStringValue = "0"
        EndSelect
        If bIncludeSuffix
          sStringValue + "dB"
        EndIf
        ; debugMsg(sProcName, "\nValue=" + Str(\nValue) + ", \nMidValue=" + Str(\nMidValue) + ", fUnitValue=" + StrF(fUnitValue,4) + ", fConvertedValue=" + StrF(fConvertedValue,4) + ", sStringValue=" + sStringValue)
        
      Case #SCS_EQTYPE_FREQ
        nMinFreq = 20
        nMaxFreq = 20000
        bFrequency = #True
        
      Case #SCS_EQTYPE_Q
        ; range 1 to 20
        nMinQ = 1
        nMaxQ = 20
        nQRange = nMaxQ - nMinQ
        dMinQLog = Log10(nMinQ)
        dMaxQLog = Log10(nMaxQ)
        dLogQRange = dMaxQLog - dMinQLog
        fUnitValue = dLogQRange / (\nMaxValue - \nMinValue)
        dQLog = dMinQLog + (\nValue * fUnitValue)
        sStringValue = StrD(Pow(10.0, dQLog), 1)
        
    EndSelect
    
    If bFrequency
      nFreqRange = nMaxFreq - nMinFreq
      dMinFreqLog = Log10(nMinFreq)
      dMaxFreqLog = Log10(nMaxFreq)
      dLogFreqRange = dMaxFreqLog - dMinFreqLog
      fUnitValue = dLogFreqRange / (\nMaxValue - \nMinValue)
      dFreqLog = dMinFreqLog + (\nValue * fUnitValue)
      sStringValue = StrD(Pow(10.0, dFreqLog), 0)
      If bIncludeSuffix
        sStringValue + "Hz"
      EndIf
    EndIf
    
    ; debugMsg(sProcName, #SCS_END + ", nIndex=" + nIndex + ", \nValue=" + Str(\nValue) + ", returning " + sStringValue)
    
  EndWith
  
  ProcedureReturn sStringValue
EndProcedure

Procedure setKnobValueFromString(nIndex, sStringValue.s)
  PROCNAMEC()
  Protected fUnitValue.f
  Protected fConvertedValue.f
  Protected bFrequency
  Protected nMinFreq, nMaxFreq, nFreqRange
  Protected dMinFreqLog.d, dMaxFreqLog.d, dLogFreqRange.d
  Protected dFreqLog.d
  Protected nMinQ, nMaxQ, nQRange
  Protected dMinQLog.d, dMaxQLog.d, dLogQRange.d
  Protected dQLog.d
  Protected fTmp.f
  
  CheckSubInRange(nIndex, ArraySize(_Knob()), "_Knob()")
  With _Knob(nIndex)
    Select \nKnobType
      Case #SCS_EQTYPE_LOWCUT_FREQ
        nMinFreq = 20
        nMaxFreq = 400
        bFrequency = #True
        
      Case #SCS_EQTYPE_GAIN
        ; range -15dB to +15dB
        ; debugMsg(sProcName, "\nMaxValue=" + Str(\nMaxValue) + ", \nMinValue=" + Str(\nMinValue) + ", \nMidValue=" + Str(\nMidValue))
        fUnitValue = 30.0 / (\nMaxValue - \nMinValue)
        fConvertedValue = ValF(sStringValue)
        ; debugMsg(sProcName, "fUnitValue=" + StrF(fUnitValue,4) + ", fConvertedValue=" + StrF(fConvertedValue,4))
        If fConvertedValue = 0
          \nValue = \nMidValue
        Else
          fTmp = (fConvertedValue / fUnitValue) + \nMidValue
          \nValue = fTmp
        EndIf
        
      Case #SCS_EQTYPE_FREQ
        nMinFreq = 20
        nMaxFreq = 20000
        bFrequency = #True
        
      Case #SCS_EQTYPE_Q
        ; range 1 to 20
        nMinQ = 1
        nMaxQ = 20
        nQRange = nMaxQ - nMinQ
        dMinQLog = Log10(nMinQ)
        dMaxQLog = Log10(nMaxQ)
        dLogQRange = dMaxQLog - dMinQLog
        fUnitValue = dLogQRange / (\nMaxValue - \nMinValue)
        dQLog = Log10(ValD(sStringValue))
        \nValue = (dQLog - dMinQLog) / fUnitValue
        
    EndSelect
    
    If bFrequency
      nFreqRange = nMaxFreq - nMinFreq
      dMinFreqLog = Log10(nMinFreq)
      dMaxFreqLog = Log10(nMaxFreq)
      dLogFreqRange = dMaxFreqLog - dMinFreqLog
      fUnitValue = dLogFreqRange / (\nMaxValue - \nMinValue)
      dFreqLog = Log10(ValD(sStringValue))
      \nValue = (dFreqLog - dMinFreqLog) / fUnitValue
    EndIf
    
    ; debugMsg(sProcName, #SCS_END + ", nIndex=" + nIndex + ", sStringValue=" + sStringValue + ", \nValue=" + Str(\nValue))
    
  EndWith
  
EndProcedure

Procedure knobGetMinValue(nIndex)
  ProcedureReturn _Knob(nIndex)\nMinValue
EndProcedure

Procedure knobGetMaxValue(nIndex)
  ProcedureReturn _Knob(nIndex)\nMaxValue
EndProcedure

Procedure knobSetValue(nIndex, nValue)
  PROCNAMEC()
  
  CheckSubInRange(nIndex, ArraySize(_Knob()), "_Knob()")
  With _Knob(nIndex)
    If (nValue >= \nMinValue) And (nValue <= \nMaxValue)
      \nValue = nValue
    EndIf
  EndWith
EndProcedure

Procedure.f RotaF(X.f, Min.f, Max.f)
  Protected a.f
  If X >= Min And X <= Max
    ProcedureReturn X
  EndIf
  If X < -Min
    a = -1
  EndIf
  If X >= Min
    ProcedureReturn Mod((X -Min -a), (1+Max -Min )) + a+Min
  EndIf
  ProcedureReturn Mod((1+X -Min -a), (1+Max -Min )) + a+Max
EndProcedure

Procedure Proportion(fAngle.f, nMinAngle, nMaxAngle, fMinValue.f, fMaxValue.f)
  If fAngle = nMinAngle
    ProcedureReturn fMinValue
  EndIf
  If fAngle = nMaxAngle
    ProcedureReturn fMaxValue
  EndIf
  Protected fTmp.f = (nMaxAngle - nMinAngle) / (fAngle - nMinAngle)
  ProcedureReturn Lim(fMinValue + (fMaxValue - fMinValue) / fTmp, fMinValue, fMaxValue)
EndProcedure

Procedure knobCalcAngleFromValue(nIndex)
  PROCNAMEC()
  
  With _Knob(nIndex)
    \fAngle = (\nValue * \fAnglePerUnit) + \fMaxDeadAngle
    If \fAngle >= 360.0
      \fAngle - 360.0
    EndIf
  EndWith
EndProcedure

Procedure KNOBSetting(Index,nLeft,nTop,nSize,nKnobType,nEQBand=-1)
  PROCNAMEC()
  
  ; debugMsg(sProcName, #SCS_START + ", Index=" + Index + ", nKnobType=" + nKnobType)
  
  If Index > ArraySize(_Knob())
    ReDim _Knob(Index)
  EndIf
  
  With _Knob(Index)
    \nMinValue = 0       ; ----------------  your settings here
    \nMaxValue = 10000
    \nRGB1 = $BFBFBF
    \nRGB2 = $454545                                           
    \nLightRGB = $FFAA                                         
    \nBkRGB = _BkRGB                                           
    \nKnobType = nKnobType
    \nEQBand = nEQBand
    \fMinDeadAngle = 135
    ; \fMinDeadAngle = 157.5
    \fMaxDeadAngle = 360.0 - \fMinDeadAngle
    \nNrOfMarks = 15
    \bKnobCreated = #True
    ; -----------------------------------
    \nMidValue = (\nMaxValue - \nMinValue) >> 1
    \nValueRange = \nMaxValue - \nMinValue
    \fAngleRange = 360.0 - (\fMaxDeadAngle - \fMinDeadAngle)
    \fAnglePerUnit = \fAngleRange / \nValueRange
    \fAnglePerMark = \fAngleRange / \nNrOfMarks
    \nSize = nSize
    \nCanv = scsCanvasGadget(nLeft, nTop, nSize, nSize, #PB_Canvas_Keyboard)
    \nXCenter = \nSize/2.0
    \nYCenter = \nSize/2.0
    ; \nInfo=scsTextGadget(GadgetX(\nCanv)+\nXCenter,GadgetY(\nCanv)-35,100,30,"")
    \nInfo = scsTextGadget(GadgetX(\nCanv),GadgetY(\nCanv)-15,nSize,15,"",#PB_Text_Center)
    SetGadgetColor(\nInfo,#PB_Gadget_FrontColor,#SCS_White)
    SetGadgetColor(\nInfo,#PB_Gadget_BackColor,\nBkRGB)
    SpinKNOB(Index)
    SetGadgetText(\nInfo, Str(\nValue))
  EndWith 
EndProcedure

; EOF

; IDE Options = PureBasic 5.45 LTS (Windows - x64)
; CursorPosition = 428
; FirstLine = 381
; Folding = ----
; EnableUnicode
; EnableThread
; EnableXP
; EnableOnError