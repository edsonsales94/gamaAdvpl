User Function A200BOK
Local x,y := 0
Local cDescrOri	:= ''
aTempSG1:= {}
aSg1Rel:={}
aRegs := PARAMIXB[1]
cCod := PARAMIXB[2]
nOpcX := PARAMIXB[3]

//2 = visualização, 3 = inclusão e 4 = alteração.
/*
Array
AllTrim(Str(aRegs[x][1]) = RECNO
AllTrim(Str(aRegs[x][2]) = (ICLUSAO)
AllTrim(Str(aRegs[x][3][1]) = G1_FILIAL
AllTrim(Str(aRegs[x][3][2]) = G1_COD
AllTrim(Str(aRegs[x][3][3]) = G1_COMP
AllTrim(Str(aRegs[x][3][4]) = G1_TRT
AllTrim(Str(aRegs[x][3][5]) = G1_QUANT
AllTrim(Str(aRegs[x][3][6]) = G1_PERDA
AllTrim(Str(aRegs[x][3][7]) = G1_INI
AllTrim(Str(aRegs[x][3][8]) = G1_FIM
AllTrim(Str(aRegs[x][3][9]) = G1_OBSERV
AllTrim(Str(aRegs[x][3][10]) = G1_FIXVAR
AllTrim(Str(aRegs[x][3][11]) = G1_GROPC
AllTrim(Str(aRegs[x][3][12]) = G1_OPC
AllTrim(Str(aRegs[x][3][13]) = G1_REVINI
AllTrim(Str(aRegs[x][3][14]) = G1_REVFIM
AllTrim(Str(aRegs[x][3][15]) = G1_NIV
AllTrim(Str(aRegs[x][3][16]) = G1_NIVINV
AllTrim(Str(aRegs[x][3][17]) = G1_POTENCI
AllTrim(Str(aRegs[x][3][18]) = G1_VLCOMPE
AllTrim(Str(aRegs[x][3][19]) = G1_OK
AllTrim(Str(aRegs[x][3][20]) = G1_VECTOR
AllTrim(Str(aRegs[x][3][21]) = G1_TIPVEC
AllTrim(Str(aRegs[x][3][24]) = G1_USERLGI
AllTrim(Str(aRegs[x][3][25]) = G1_USERLGA
AllTrim(Str(aRegs[x][3][26]) = G1_USAALT
AllTrim(Str(aRegs[x][3][27]) = G1_LOCCONS
AllTrim(Str(aRegs[x][3][28]) = G1_FANTASM
AllTrim(Str(aRegs[x][3][28]) = G1_LISTA
*/

//Alert("Produto sendo alterado: " + cCod)
For x := 1 to Len(aRegs)
aTempSG1 :={}
aTempSG1 :=sfTempSG1(aRegs[x][1])

    If aRegs[x][2] == 3 // ALTERACAO
        For y:=1 to 27
            IF VALTYPE(aRegs[x][3][y])=VALTYPE(aTempSG1[1][y])
                if aRegs[x][3][y]<>aTempSG1[1][y]
                
                    cDescrOri:=Posicione("SB1",1,xFilial("SB1")+aRegs[x][3][3],"B1_DESC") //	Produto (Descricao)

                    Aadd(aSg1Rel,{  y,;
                                    VALTYPE(aRegs[x][3][y]),;
                                    aRegs[x][3][2],;
                                    aRegs[x][3][3],;
                                    cDescrOri,;
                                    aRegs[x][3][y],;
                                    aTempSG1[1][y]})
                endif    
            ENDIF
        Next
    Else
        For y:=1 to 27

            cDescrOri:=Posicione("SB1",1,xFilial("SB1")+aTempSG1[1][3],"B1_DESC") //	Produto (Descricao)

            Aadd(aSg1Rel,{  y,;
                            VALTYPE(aTempSG1[1][y]),;
                            aTempSG1[1][2],;
                            aTempSG1[1][3],;
                            cDescrOri,;
                            IIF(aRegs[x][2] == 2,aTempSG1[1][y],'INCLUSÃO'),;
                            IIF(aRegs[x][2] == 2,'EXCLUSÃO',aTempSG1[1][y])})
        
        NEXT
                
    Endif



Next

if len(aSg1Rel)>0
     U_fEmailSG1(aSg1Rel,cCod)
     MsgInfo('Foi enviado um e-mail, com as alterações realizadas na estrutura.', 'Workflow - BOM')
endif
Return(.T.) // aceito as alteracoes. Para nao aceitar, retornar .F.

/*/{Protheus.doc} sfTempSG1
    (long_description)
    @type  Static Function
    @author Ricky
    @since 27/08/2021
    @version 1
    @param nRECNO, 
    @return aTemp
/*/
Static Function sfTempSG1(nRECNO)
Local aTemp:={}
Local cAliasTMP:= GetNextAlias()


BeginSql alias cAliasTMP
	SELECT 
        G1_FILIAL,//1
        G1_COD,//2
        G1_COMP,//3
        G1_TRT,//4
        G1_QUANT,//5
        G1_PERDA,//6
        G1_INI,//7
        G1_FIM,//8
        G1_OBSERV,//9
        G1_FIXVAR,//10
        G1_GROPC,//11
        G1_OPC,//12
        G1_REVINI,//13
        G1_REVFIM,//14
        G1_NIV,//15
        G1_NIVINV,//16
        G1_POTENCI,//17
        G1_VLCOMPE,//18
        G1_OK,//19
        G1_VECTOR,//20
        G1_TIPVEC,//21
        G1_XPERDA,//22
        G1_XQUANT,//23
        G1_USERLGI,//24
        G1_USERLGA,//25
        G1_USAALT,//26
        G1_LOCCONS,//27
        G1_FANTASM,//28
        G1_LISTA //29
	FROM %table:SG1% SG1
	WHERE  R_E_C_N_O_= %exp:nRECNO%	
	EndSql

    dbSelectArea(cAliasTMP)  
    dbgotop()

    aAdd(aTemp,{    (cAliasTMP)->(G1_FILIAL),;
                    (cAliasTMP)->(G1_COD),;
                    (cAliasTMP)->(G1_COMP),;
                    (cAliasTMP)->(G1_TRT),;
                    (cAliasTMP)->(G1_QUANT),;
                    (cAliasTMP)->(G1_PERDA),;
                    STOD((cAliasTMP)->(G1_INI)),;
                    STOD((cAliasTMP)->(G1_FIM)),;
                    (cAliasTMP)->(G1_OBSERV),;
                    (cAliasTMP)->(G1_FIXVAR),;
                    (cAliasTMP)->(G1_GROPC),;
                    (cAliasTMP)->(G1_OPC),;
                    (cAliasTMP)->(G1_REVINI),;
                    (cAliasTMP)->(G1_REVFIM),;
                    (cAliasTMP)->(G1_NIV),;
                    (cAliasTMP)->(G1_NIVINV),;
                    (cAliasTMP)->(G1_POTENCI),;
                    (cAliasTMP)->(G1_VLCOMPE),;
                    (cAliasTMP)->(G1_OK),;
                    (cAliasTMP)->(G1_VECTOR),;
                    (cAliasTMP)->(G1_TIPVEC),;
                    (cAliasTMP)->(G1_XPERDA),;
                    (cAliasTMP)->(G1_XQUANT),;
                    (cAliasTMP)->(G1_USERLGI),;
                    (cAliasTMP)->(G1_USERLGA),;
                    (cAliasTMP)->(G1_USAALT),;
                    (cAliasTMP)->(G1_LOCCONS),;
                    (cAliasTMP)->(G1_FANTASM),;
                    (cAliasTMP)->(G1_LISTA),;
                })

    dbSelectArea(cAliasTMP) 
    dbclosearea()     
Return aTemp
