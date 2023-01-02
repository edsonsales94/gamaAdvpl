#Include 'Protheus.ch'

User Function ConEspOp()
   Local oDlg, oLbx
   Local aCpos  := {}
   Local aRet   := {}
   Local cQuery := ""
   Local cAlias := GetNextAlias()
   Local lRet   := .F.

   cQuery := " SELECT DISTINCT D4_COD, B1_DESC,B1_TIPO "
   cQuery += " FROM SD4010 SD4 INNER JOIN SB1010 SB1 ON B1_COD=D4_COD AND SB1.D_E_L_E_T_ = ' ' AND B1_TIPO<>'MO' AND B1_FANTASM<>'S'"
   cQuery += " WHERE SD4.D_E_L_E_T_ = ' ' "
   cQuery += " AND SD4.D4_FILIAL  = '" + xFilial("SD4") + "' "
   If !Empty(M->ZT0_OP)
      cQuery += " AND SD4.D4_OP = '" + M->ZT0_OP + "' "
   EndIf
   cQuery += " ORDER BY 1,2 "

   cQuery := ChangeQuery(cQuery)

   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

   While (cAlias)->(!Eof())
      aAdd(aCpos,{(cAlias)->(D4_COD), (cAlias)->(B1_DESC), (cAlias)->(B1_TIPO)})
      (cAlias)->(dbSkip())
   End
   (cAlias)->(dbCloseArea())

   If Len(aCpos) < 1
      aAdd(aCpos,{" "," "," "})
   EndIf

   DEFINE MSDIALOG oDlg TITLE /*STR0083*/ "Lista produtos empenhados" FROM 0,0 TO 350,550 PIXEL

     @ 05,10 LISTBOX oLbx FIELDS HEADER 'Codigo' /*"Roteiro"*/, 'Descricao' /*"Produto"*/, 'Tipo' SIZE 250,125 OF oDlg PIXEL

     oLbx:SetArray( aCpos )
     oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2], aCpos[oLbx:nAt,3]}}
     oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2], oLbx:aArray[oLbx:nAt,3]}}}

  DEFINE SBUTTON FROM 150,220 TYPE 1 ACTION (oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2], oLbx:aArray[oLbx:nAt,3]})  ENABLE OF oDlg
  ACTIVATE MSDIALOG oDlg CENTER

  If Len(aRet) > 0 .And. lRet
     If Empty(aRet[1])
        lRet := .F.
     Else
        SD4->(dbSetOrder(1))
        SD4->(dbSeek(xFilial("SD4")+aRet[1]+M->ZT0_OP))
     EndIf
  EndIf
Return lRet