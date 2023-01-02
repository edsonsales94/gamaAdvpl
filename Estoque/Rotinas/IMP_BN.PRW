#Include "Rwmake.ch"
#include "topconn.ch"

User Function IMP_BN()
Private nUsado,aHeader,aCols
Private cCadastro
Private cCadastro := "Ajuste NF-SERVICO Beneficiamento"
Private cAlias    := "SD2"
cOpcao := ""


//   aAdd(aCOLS,{TRA->D2_COD,TRA->D2_DOC,TRA->D2_SERIE,TRA->D2_EMISSAO,TRA->D2_CF,TRA->D2_QUANT,TRA->D2_CLIENTE,TRA->D2_NFORI,TRA->D2_SERIORI,.F.})

aCampo := { "D2_COD" , "D2_DOC" , "D2_SERIE", "D2_EMISSAO" , "D2_CF" , "D2_QUANT","D2_CLIENTE","D2_NFORI","D2_SERIORI", "D2_LOJA" }

DbSelectArea( cAlias )
DbSetOrder(1)

aFixos  := {}

aAdd( aFixos, { "Codigo"     , "D2_COD"     , AllTrim(X3Picture("D2_COD") ) } )
aAdd( aFixos, { "Documento"  , "D2_DOC"     , AllTrim(X3Picture("D2_DOC")    ) } )
aAdd( aFixos, { "Seire"      , "D2_SERIE"   , AllTrim(X3Picture("D2_SEIRE")    ) } )
aAdd( aFixos, { "Emissao"    , "D2_EMISSAO" , AllTrim(X3Picture("D2_EMISSAO")) } )
aAdd( aFixos, { "CF"         , "D2_CF"      , AllTrim(X3Picture("D2_CF")) } )
aAdd( aFixos, { "Qtde"       , "D2_QUANT"   , AllTrim(X3Picture("D2_QUANT")  ) } )
aAdd( aFixos, { "NF.ORIGEM"  , "D2_NFORI"   , AllTrim(X3Picture("D2_NFORI")  ) } )
aAdd( aFixos, { "Ser.Origem" , "D2_SERIORI" , AllTrim(X3Picture("D2_SERIORI")  ) } )
aAdd( aFixos, { "Loja Cli"   , "D2_LOJA"    , AllTrim(X3Picture("D2_LOJA")  ) } )




aRotina  := {{"Pesquisar"  ,"AXPESQUI"     ,0,1},;
{"Visualizar" ,"AXVISUAL"	    ,0,2},;
{"Transferir" ,"U_ZATRANSF()" ,0,3},;
{"Baixar"     ,"U_ZABAIXA()"	 ,0,3},;
{"Imprimir"   ,"U_ZAPAGIMP()" ,0,4},;
{"Mudar"      ,"U_ZAMUDAR()" ,0,5}} //,;
//{"Legenda"    ,"U_ZALEG1()"   ,0,6}}

/*
aCores 	:= {{'ZA_OK==" "','ENABLE' } ,;  // Cores padroes do semaforo
{'ZA_OK=="E"','DISABLE' } ,;  // Cores padroes do semaforo
{'ZA_OK=="S"','BR_AZUL'} }
*/


DbSelectArea(cAlias)


//mBrowse(06,01,22,75,cAlias,aFixos,,,,,aCores)
mBrowse(06,01,22,75,cAlias,aFixos,,,,,)

Return Nil







User Function ZABAIXA()

/*
Private cTM       := SZA->ZA_TIPMOV
Private dEmissao  := SZA->ZA_EMISSAO
Private cDoc      := SZA->ZA_DOC
Private cCC       := SZA->ZA_CC
Private dDt_Lote  := dDataBase
*/

PRIVATE ddt1:= ctod("01/01/2014")
PRIVATE ddt2:= ddatabase

cSelect := "* "

cFrom   := RetSqlName('SD2') + ' '

cWhere  := RetSqlName('SD2') + '.D_E_L_E_T_ <> ' + CHR(39) + '*' + CHR(39) + ' AND '+;
"D2_FILIAL  = '" + xFilial('SD2') + "' AND D2_CF =  '"+'5124'+"' "

cWhere  += "    AND D2_EMISSAO BETWEEN  '"+DTOS(ddt1)+"'  AND    '"+DTOS(ddt2)+"' "

cQuery  :=	' SELECT '   + cSELECT + ;
' FROM '     + cFROM   + ;
' WHERE '    + cWHERE  + ;
' ORDER BY D2_EMISSAO '

TcQuery cQuery New Alias 'TRA'

If ! Used()
	MsgBox(cQuery+'. Query errada','Erro!!!','STOP')
EndIf

DbSelectArea('TRA')
TRA->(LastRec())
nCnt := TRA->(Recno())
ProcRegua(nCnt)

TRA->(DbGoTop())

aHeader := MONT_AHEADER({"D2_NFORI", "D2_SERIORI"})

If Empty(nCnt)
	MsgBox("Nao existem NF neste periodo" )
	Return Nil
Endif

aCols := {}

While !TRA->(Eof())
	
	//aAdd(aCOLS,{TRA->ZA_COD,TRA->ZA_DESC,TRA->ZA_QUANT,TRA->ZA_LOCORIG,TRA->ZA_LOCDEST,dDATABASE,.F.})
	aAdd(aCOLS,{TRA->D2_COD,TRA->D2_DOC,TRA->D2_SERIE,TRA->D2_EMISSAO,TRA->D2_CF,TRA->D2_QUANT,TRA->D2_CLIENTE,TRA->D2_NFORI,TRA->D2_SERIORI,TRA->D2_LOJA,.F.})
	
	TRA->( DbSkip() )
	
EndDo


@ 000,000 To 550,800 Dialog oDlgSolicitacao Title "NF DE SERV ENVIADAS"
/*
@ 005,010 Say OemToAnsi("Tipo Mov.: "+cTM+" - "+SF5->F5_TEXTO )
@ 005,120 Say OemToAnsi("Emissao:   "+DTOC(dEmissao))
@ 005,194 Say OemToAnsi("C.C. Destino: "+ALLTRIM(cCC))
@ 020,010 Say OemToAnsi("Documento: "+cDoc)
@ 020,120 Say OemToAnsi("Dt. Baixa: "+dTOc(dDataBase) )
*/

@ 034,010 To 245,400 Multiline Modify Delete Valid Validar(N) //FREEZE 1
@ 250,225 BmpButton Type 1 Action SALV_BX()
@ 250,265 BmpButton Type 2 Action FectelaBx()
Activate Dialog oDlgSolicitacao Centered
Return(.T.)


// Baixa de transferencia.
Static Function SALV_BX()
LOCAL cTexto := ""
Local nIt, nI, nIt, j

For j:=1 to Len(aCols)
	
	//aAdd(aCOLS,{TRA->D2_COD,TRA->D2_DOC,TRA->D2_SERIE,TRA->D2_EMISSAO,TRA->D2_CF,TRA->D2_QUANT,TRA->D2_CLIENTE,TRA->D2_NFORI,TRA->D2_SERIORI,TRA->D2_LOJA ,.F.})
	
	cCod    := aCols[j,1]
	nQtde   := aCols[j,6]
	cNfOri  := aCols[j,8]
	cSeOri  := aCols[j,9]
	
	If !aCols[j,11]  // Se item nao estiver deletado
		
	 
		// 1) Procura os componentes que foram retornados na nf de componentes referente a NF de servico.
		aCpRet := CompUsed(aCols[j,8],aCols[j,9] , aCols[j,7],aCols[j,10], aCols[j,05] )
		nCpRet := LEN(aCpRet)
		
		// 2) Explode a estrutura do produto da NF de servico para coletar a necessidade conforme estrutura
		aItBOM := ExpBN_a( cCod , nQtde , "")
		nItBOM := LEN( aItBOM )
		
		
		
		// 3) Faz a conciliacao dos vetores
		
		FOR nIt:=1 TO LEN(aCpRet)
			
			IF ( nI := aScan( aItBOM , {|x| x[1]== aCpRet[nIt,1] } ) ) == 0
				
				aadd(aItBOM, { "FORA DA BOM" , 0 ,aCpRet[nIt,1] , aCpRet[nIt,2], aCpRet[nIt,3], aCols[j,8]  } )
				nI := len( aItBOM )
						
			ENDIF
			aItBOM[nI,3] := aCpRet[nIt,1] // codigo
			aItBOM[nI,4] := aCpRet[nIt,2] // quantidade 
			aItBOM[nI,5] := aCpRet[nIt,3] // preco unitario
			aItBOM[nI,6] := aCols[j,8]    // nf componente de retorno 
			
			
						
		NEXT nIt     
		
		
	
		FOR nI:=1 TO LEN(aItBOM)
			
			
			_CDesc   := POSICIONE("SB1",1,XFILIAL("SB1")+cCod,"B1_DESC")
			
            cTexto += "NF: "+aCols[j,2]+"-"+aCols[j,3]+"; Produto: " + ALLTRIM(cCod) + ";"+ALLTRIM(_CDesc)        
            
            ctexto += "; QTDE: ;"+Str(nQtde, 15, 4)+"; Componente; "+aItBOM[nI,1]+"; Necessidade: ;" + Str(aItBOM[nI,2], 15, 4) 
            
            cTexto += "; Item NF Comp ;"+ aItBOM[nI,3]+"; qtde ret:; "+Str( aItBOM[nI,4] , 15, 4)+"; prc unit; "+Str( aItBOM[nI,5] , 15, 4)+"; Nf Compon:; "+aItBOM[nI,6]+chr(13)+chr(10)
			
	
		NEXT nI
		
		cTexto += chr(13)+chr(10)
		
	Endif
	
Next J

If !Empty(cTexto)
	
	
	U_GRVTXT(CTEXTO)
	oFont:= TFont():New("COURIER NEW",07,15)
	
	@ 000,000 To 300,700 Dialog oDlgMemo Title "Produtos sem Saldo"
	@ 001,003 Get cTexto Size 340,130  MEMO Object oMemo When .F.
	oMemo:oFont:=oFont
	
	@ 140,170 BmpButton Type 1 Action CLOSE(oDLGMEMO) Object oConf
	
	Activate Dialog oDlgMemo CENTERED On Init (oMemo:SetFocus())
	
	
EndIf




DbSelectArea("TRA")
TRA->(dbClosearea())
DbSelectArea("SD2")
Close(oDlgSolicitacao)

Return Nil




Static Function MONT_AHEADER(aEditar)
Local nI
If aEditar==Nil
	aEditar:={}
Endif

aHeader := {}
DbSelectArea("SX2")
DbSeek(cAlias)

DbSelectArea("SX3")
SX3->(dbSetOrder(2))
DbSeek(cAlias)
nUsado := 0

For nI:=1 To Len( aCampo )
	SX3->( DbSeek( aCampo[nI] ) )
	If SX3->x3_usado != " " .And. cNivel >= SX3->X3_NIVEL
		nUsado := nUsado + 1
		AADD(aHeader,{ Trim(X3_TITULO), X3_CAMPO  , X3_PICTURE  ,;
		X3_TAMANHO, X3_DECIMAL, IIf(aSCAN(aEditar,aCampo[nI] ) > 0  ,".T.",".F.") ,;
		X3_USADO  , X3_TIPO   , X3_ARQUIVO })
	Endif
Next nI
Return(aHeader)


Static Function Validar(N)

Return .T.



STATIC FUNCTION CompUsed(cNfSerie,cSerie,cForBN,cSForBN,cCF)
Local aVolta :={}
Local aArea := GetArea()

IF ALLTRIM(cCF) == "5124" //ALLTRIM(GetMv("MV_CFOPIND"))
	
	cQuery := " SELECT * "
	cQuery += " FROM "+Retsqlname("SB6")+" SB6 "
	cQuery += " WHERE SB6.D_E_L_E_T_ <> '*' "
	cQuery += " AND B6_FILIAL='"+xFilial("SB6")+"' "
	cQuery += " AND B6_CLIFOR='"+cForBN+"' "
	cQuery += " AND B6_LOJA= '"+cSForBN+"' "
	cQuery += " AND B6_DOC ='"+cNfSerie+"' "
	cQuery += " AND B6_SERIE ='"+cSerie+"' " 
	cQuery += " AND B6_TPCF='C' "
	cQuery += " AND B6_PODER3='D' "
	//cQuery += " AND B6_PODER3='R' "
	
	cQuery := ChangeQuery(cQuery)
	If Select("TMPSD1") <> 0
		dbSelectArea("TMPSD1")
		TMPSD1->(DbCloseArea())
	Endif
	DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TMPSD1",.F.,.T.)
	dbSelectArea("TMPSD1")
	Count to nRecSD1

	If nRecSD1==0    
	   //	msgStop("NAO Encontrou nf: "+cNfSerie ,"SD1100I")
		//msgStop("Nota de serviço não possui NF Retorno (componentes) atrelada!","SD1100I")
	ELSE
	 	msgStop("Encontrou nf: "+cNfSerie ,"SD1100I")
	   	TMPSD1->(dbgotop())
		DO WHILE !TMPSD1->(eof())
			aadd(aVolta , {TMPSD1->B6_PRODUTO , TMPSD1->B6_QUANT, TMPSD1->B6_PRUNIT } )
			TMPSD1->( dbSkip() )
		ENDDO
	Endif
	
	TMPSD1->(DbCloseArea())
	
ENDIF

RestArea(aArea)

RETURN( aVolta )





// Explode os PAs para TECHIT/BRASITECH
STATIC FUNCTION ExpBN_a(cCodPai,nQuant)
LOCAL nTotCus2 := 0
SG1->(dbsetorder(1))
SG1->( dbseek(xFilial("SG1")+cCodPai) )

aComp := {}
DO WHILE SG1->G1_FILIAL+SG1->G1_COD == xFilial("SG1")+cCodPai .AND. !SG1->(eof())
	nRecno := SG1->( RECNO() )
	ExpBN_b( SG1->G1_COMP , (nQuant * SG1->G1_Quant) , (SG1->G1_GROPC + SG1->G1_OPC) , @aComp )
	SG1->( dbGoTo(nRecno) )
	SG1->( dbSkip() )
ENDDO

RETURN( aComp )




// Explode os componentes para TECHIT/BRASITECH
STATIC FUNCTION ExpBN_b( cComp , nQtd , cOpc, aComp )
LOCAL nRec,nI

_cFantas  := POSICIONE("SB1",1,XFILIAL("SB1")+cComp,"B1_FANTASM")
_cBlock   := POSICIONE("SB1",1,XFILIAL("SB1")+cComp,"B1_MSBLQL")

// Validacao de estrutura, fantasmado, opcional e bloqueado.
//IF (dDataBase<SG1->G1_Ini .or. dDataBase>SG1->G1_Fim) .OR. _cFantas == "S" .OR. !(cOpc $ M->C2_Opc) .OR. _cBlock == "1"
//IF (SG1->G1_Ini > dDataBase .or. SG1->G1_Fim < dDataBase) .OR. _cFantas == "S" .OR. !(cOpc $ M->C2_Opc) .OR. _cBlock == "1"
IF (SG1->G1_Ini > dDataBase .or. SG1->G1_Fim < dDataBase) .OR. _cFantas == "S" .OR. _cBlock == "1"
	SG1->(dbskip())
	Return
ENDIF

_cTipo   := POSICIONE("SB1",1,XFILIAL("SB1")+cComp,"B1_TIPO")
_cAprop  := ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+cComp,"B1_APROPRI"))
_cAlmox  := ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+cComp,"B1_LOCPAD"))
_ValEst  := CALCEST(cComp,_cAlmox,DDATABASE+1) // Saldo em estoque do almoxarifado padrao
_ValEst2 := CALCEST(cComp,GETMV("MV_LOCPROC"),DDATABASE+1) // Saldo em estoque do almoxarifado de processo (WIP)


IF _cAprop == "D"
	_cSldEmp := POSICIONE("SB2",1,XFILIAL("SB2")+cComp+_cAlmox,"B2_QEMP")
	_cSaldo  := ( _ValEst[1]- _cSldEmp ) // Saldo disponivel=(saldo do ALMOX PADRAO - (empenho do ALMOX PADRAO)
ELSE
	_cSldEmp := POSICIONE("SB2",1,XFILIAL("SB2")+cComp+GETMV("MV_LOCPROC"),"B2_QEMP")
	//_cSaldo:= _ValEst[1] - ( _ValEst2[1]-_cSldEmp)  // Saldo disponivel=(saldo do 11 - (empenho do 20 - saldo est 20) )
	_cSaldo:= _ValEst[1] - ( _cSldEmp-_ValEst2[1])  // Saldo disponivel=(saldo do 11 - (empenho do 20 - saldo est 20) )
ENDIF


/*
//IF _cSaldo < nQtd .AND. !(_cTipo$"MO\SA")
IF ((_cSaldo >= nQtd) .AND. _cTipo=="SA")
SG1->(dbskip())
Return
ENDIF
*/

//Nova alteracao, porem ainda nao compilada - Reginaldo (15/01/2014) as 13:25
cCheck := IIF( SM0->M0_CODIGO == "04" , '!(_cTipo$"MO/SA")' , '!(_cTipo=="MO")' )



//IF _cSaldo < nQtd .AND. &cCheck

IF &cCheck
	
	IF ( nI := aScan(aComp , {|x| x[1]== cComp} ) ) == 0
		aadd(aComp, {cComp , 0,SPACE(15),0,0, spac(9) } )
		nI := len( aComp )
	ENDIF
	aComp[nI,2] += nQtd //necessidaade
	//aComp[nI,3] := _ValEst[1]
	//aComp[nI,4] := _cSldEmp
	//aComp[nI,5] := _cSaldo
	
ENDIF

nRec := SG1->( recno() )
IF SG1->( dbSeek( xFilial("SG1")+cComp ) )
	Do While SG1->G1_FILIAL==xFilial("SG1") .AND. SG1->G1_COD == cComp .and. !SG1->(eof())
		ExpBN_b(SG1->G1_COMP , SG1->G1_Quant * nQtd , (SG1->G1_GROPC + SG1->G1_OPC) ,@aComp )
		SG1->(dbskip())
	EndDo
ENDIF
SG1->( dbGoTo(nRec) )

RETURN .T.




