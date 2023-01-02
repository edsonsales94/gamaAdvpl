// ------------------------------------------------------------------------------------------
// Reginaldo Souza - 19/09/2007 - 19:37
// Simulacao adaptada para utilizar codigos substitutos customizados na ENVISION.
// ------------------------------------------------------------------------------------------
// Alteracao: 24/09/2007 - Reginaldo Souza
// Motivo: Nao considerar DETERMINADO endereco no saldo de estoque, conforme parametro MV_OUTEND.
// ------------------------------------------------------------------------------------------
// Alteracao:
// Motivo:
// ------------------------------------------------------------------------------------------

#INCLUDE "rwmake.ch"

//User Function SmlCSub()
User Function SmlMain()
Local nUsado := 4
Local nItem  := 1
Public cArqTxt
aCols := {}
aHeader := {}
Pergunte("SIMULA",.F.)


AADD( aHeader ,{ "Produto"     , "C6_PRODUTO"     ,"@!"      , 15 , 0 , "" , "€€€€€€€€€€€€€€ " ,"C","SC6" } )
//AADD( aHeader ,{ "Descricao"   , "C6_DESCRI"      ,"@!"     , 30 , 0 , "" , "€€€€€€€€€€€€€€ "  ,"C","SC6" } )
AADD( aHeader ,{ "Quantidade"  , "nQUANT"         ,"@e 999,999" , 12 , 2 , "" , "€€€€€€€€€€€€€€ "  ,"N","" } )

//AADD( aCOLS , { SPACE(15) , SPACE(30) , 0 , .F. } )
AADD( aCOLS , { SPACE(15) ,  0 , .F. } )



@ 6,1 TO 400,750 DIALOG oDlg4 TITLE "ITENS PARA SIMULACAO"
@ 11,005 To 200,320 MULTILINE MODIFY DELETE VALID LIneOk(N) Object oMultaCols

@ 10,330 BUTTON "Simular" SIZE 40,15 ACTION SmlRun()
@ 35,330 BUTTON "Parametros"    SIZE 40,15 ACTION Pergunte("SIMULA")

@ 55,330 BUTTON "SAIR"      SIZE 40,15 ACTION Close(oDlg4)

ACTIVATE DIALOG oDlg4 CENTERED

Return Nil




Static Function LineOk(N)
LOCAL lRet := .T.
lDel   := aCols[N,3]
nQtde  := aCols[ N,2 ]
cProd  := aCols[ N,1]

If !lDel
	
	IF  nQtde <= 0 .or. EMPTY(cProd)
		MsgBox("Dado invalido !", "Validando o Item...")
		lRet := .F.
	ENDIF
	
ENDIF

Return lRet




Static Function SmlRun()

// Faz explosao da BOM conforme ACOLS.
Processa({|| Processando() },"Processando...")

// Gera informaçoes para o EXCELL
Processa({|| RunExcel() },"Exportando p/ Excell...")

Return Nil








Static Function Processando()

Local dDataIni,dDataFim,cTipo,cQuant
Local aTabela,cPaiTemp,cLinha,ni,x
Private nHdl
Private CRLF := CHR(13)+CHR(10)
Private bCondi
Private cPai, cFilho, cDescPai, cDescFilho,cUM
Private nEstru := 0

//Private cDescEnd := ALLTRIM(GetMv("MV_OUTEND")) // Parametros para desconsiderar enderecos
//cDescEnd := cDescEnd+SPACE(15-LEN(cDescEnd))


cDataArq := ALLTRIM(TIME())
cDataArq := STRTRAN( cDataArq , ":" , "" )
nSq := 1
Do While .t.
	If !File("C:\TEMP\s"+cDataArq + strzero(nSq,1)+".CSV")
		cArqTxt := "C:\TEMP\s"+cDataArq+strzero(nSq,1)+".CSV"
		Exit
	Endif
	nSq := nSq + 1
EndDo



nHdl := MsFCreate(cArqTxt,0)

/*
IF EMPTY(mv_par01)
	bCondi  := "{|| nQtdUti > 0 .AND. nNivel <= mv_par02  } "
ELSE
	bCondi  := "{|| nQtdUti > 0 .AND. POSICIONE('SB1',1,xFilial('SB1')+cFilho,'B1_GRUPO') $ mv_par01 .and. nNivel <= mv_par02  } "
ENDIF
*/


IF EMPTY(mv_par01)
	bCondi  := "{|| nQtdUti > 0 .AND. nNivel <= mv_par02 .AND. _cBlock<>'1' } "
ELSE
	bCondi  := "{|| nQtdUti > 0 .AND. POSICIONE('SB1',1,xFilial('SB1')+cFilho,'B1_GRUPO') $ mv_par01 .and. nNivel <= mv_par02 .AND. _cBlock<>'1' } "
ENDIF     





nTotIt := LEN( aCols ) // Total de itens a serem simulados.


cLinha := "Produtos Simulados:"+CRLF

FOR nI:=1 to nTotIt
	
	cLinha += aCols[nI,1]+";"+POSICIONE("SB1",1,xFilial("SB1")+aCols[nI,1],"B1_DESC")+";"+Transform(aCols[nI,2],"@E 99999999.999999")+CRLF
	
Next nI
cLinha+= CRLF

FWrite(nHdl,cLinha)



//cLinha := "Codigo;Descricao;UM;TIPO;Nec.Produzir;Estoque_01;Estoque_70;Estoque_07;Saldo Estoque;Empenhado;Dt.Inicial;Dt.Final"+CRLF
cLinha := "Codigo;Descricao;UM;TIPO;Nec.Produzir;Est.Padrao;Est.Processo;Empenhado;Sld Disp;(SldDsp-Nec.Prod);Dt.Inicial;Dt.Final;Main\Opc;Seq;GrpOpc;ItOpc"+CRLF

FWrite(nHdl,cLinha)



SB1->(dbSetOrder(1))
SB2->(dbSetOrder(1))
SD3->(dbSetOrder(7))

aTabela := {}



For nI := 1 TO nTotIt
	
	IF !aCols[nI,3]
		cPai    := aCols[nI,1]
		nQtdPA  := aCols[nI,2]
		
		aEstrutura  := {}
		//nEstru  := 0
		aEstru  := Estrut(cPai,nQtdPA,.F.)  // Faz a explosao da BOM, conforme funcao da MICROSIGA
		
		ProcRegua(Len(aEstru))   // Numero de registros a processar
		//ALERT( TRANSFORM(Len(aEstru),"999,999") )
		
		For x := 1 to Len(aEstru)
			
			IncProc("Produto: "+cPai)
			nNivel     := aEstru[x,1]
			cDescPai   := POSICIONE("SB1",1,xFilial("SB1")+cPai,"B1_DESC")
			cPaiTemp   := aEstru[x,2]
			cFilho     := aEstru[x,3]
			
			cDescFilho := POSICIONE("SB1",1,xFilial("SB1")+cFilho,"B1_DESC")
			cUM        := POSICIONE("SB1",1,xFilial("SB1")+cFilho,"B1_UM")
			cTipo      := POSICIONE("SB1",1,xFilial("SB1")+cFilho,"B1_TIPO")
			dDataIni   := POSICIONE("SG1",1,xFilial("SG1")+cPaiTemp+cFilho,"G1_INI")
			dDataFim   := POSICIONE("SG1",1,xFilial("SG1")+cPaiTemp+cFilho,"G1_FIM")
			nQtdUti    := aEstru[x,4]  // POSICIONE("SG1",1,xFilial("SG1")+cPaiTemp+cFilho,"G1_QUANT")
			
			//nQtdBOM    := aEstru[x,4]
			//nQtdUti    := (nQtdBOM * nQtdPA)
			
			cComp := cFilho
			
			//Adicionado para a GAMA Italy   
			_cTipo    :=POSICIONE("SB1",1,XFILIAL("SB1")+cComp,"B1_TIPO")
			_cKanban  :=POSICIONE("SB1",1,XFILIAL("SB1")+cComp,"B1_XKANBAN")
			_cFantas  := POSICIONE("SB1",1,XFILIAL("SB1")+cComp,"B1_FANTASM")
			_cBlock   := POSICIONE("SB1",1,XFILIAL("SB1")+cComp,"B1_MSBLQL")
			_cAprop  := ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+cComp,"B1_APROPRI"))
			_cAlmox  := IIF(_cTipo=="PI","11",ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+cComp,"B1_LOCPAD")))
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
			                       
			If dDataFim < ddatabase 
			   loop                 
			Endif                 
			If _cTipo$"MO/MOD" .or. _cKanban =="S" .or. nQtdUti==0
			 loop
			Endif
			IF MV_PAR05==1 //1="N" nao imprimir fantasma
			   IF _cFantas == "S" 
                  LOOP
		       ENDIF
		    ENDIF   
			
			
			
			IF EVAL( &(bCondi) )
				
				
				IF (nPos:=AScan(aTabela, {|x| x[3] == cFilho})) > 0
					aTabela[nPos,7]:= aTabela[nPos,7]+nQtdUti
					aTabela[nPos,11]:= aTabela[nPos,11]+_cSaldo
					
				ELSE
					//nMM := BaixaMM(cFilho,"01",dDataBase)
					//nMM := POSICIONE("SB2",1,xFilial("SB2")+cFilho+"20","B2_QEMP")
					
					//"Codigo;Descricao;UM;TIPO;Nec.Produzir;Estoque_Padrao;Estoque Processo;Empenhado;Dt.Inicial;Dt.Final"+CRLF
					AADD(aTabela,{cPai,cDescPai,cFilho,cDescFilho,cUM,cTipo,;
					nQtdUti,;
					_ValEst[1],;// vetor 8
					_ValEst2[1],;// vetor 9
					_cSldEmp,; //vetor 10
					_cSaldo,;  // Vetor 11
					dDataIni,dDataFim,IIF(EMPTY(aEstru[x,6]),"MAIN","OPC"), aEstru[x,5],aEstru[x,6],aEstru[x,7] })
				Endif
				
				//ChkCodSub( cPaiTemp , cFilho , aTabela , nQtdUti)
				
			EndIf
			
		Next x
		
	ENDIF
	
Next nI

//aSort(aTabela,,,{|x,y| x[3] < y[3] })

FOR nI:=1 TO LEN(aTabela)
	
	
	//"Codigo;Descricao;UM;TIPO;Nec.Produzir;Estoque_01;Estoque_70;Estoque_07;Saldo Estoque;Empenhado;Dt.Inicial;Dt.Final"+CRLF
	cLinha := aTabela[nI,3]+";"+LEFT(STRTRAN(aTabela[nI,4],";","/"),35)+";"+aTabela[nI,5]+";"+aTabela[nI,6]
	cLinha += ";"+Transform(aTabela[nI,7],"@E 99999999.999999")+";"+Transform(aTabela[nI,8],"@E 99999999.999999")+";"
	//cLinha += Transform(aTabela[nI,9],"@E 99999999.999999")+";"+Transform(aTabela[nI,10],"@E 99999999.999999")+";"+Transform((aTabela[nI,8]+aTabela[nI,9]+aTabela[nI,10])-aTabela[nI,7],"@E 99999999.999999")+";"
	cLinha += Transform(aTabela[nI,9],"@E 99999999.999999")+";"+Transform(aTabela[nI,10],"@E 99999999.999999")+";"
	cLinha += Transform(nSldDsp:=(aTabela[nI,8]-(aTabela[nI,10]-aTabela[nI,9])),"@E 99999999.999999")+";" // Calculo do Saldo disponivel
	cLinha += Transform(nSldDsp-aTabela[nI,7],"@E 99999999.999999")+";" //Saldo apos diminuir o qtde nec producao
	cLinha += DtoC(aTabela[nI,12])+";"+DtoC(aTabela[nI,13])+";"+aTabela[nI,14]+";"
	clinha += aTabela[nI,15]+";"+aTabela[nI,16]+";"+aTabela[nI,17]+";"
	
	cLinha+=CHR(13)+CHR(10)
	
	FWrite(nHdl,cLinha)
	
Next nI

fClose(nHdl)

Return Nil




Static Function RunExcel()
Local oExcelApp

If ! ApOleClient( 'MsExcel' )        //Verifica se o Excel esta instalado
	MsgStop( 'MsExcel nao instalado' )
	Return nil
EndIf

oExcelApp := MsExcel():New()                      // Cria um objeto para o uso do Excel
oExcelApp:WorkBooks:Open(cArqTxt) // Atribui à propriedade WorkBooks do Excel
oExcelApp:SetVisible(.T.)   // Abre o Excel com o arquivo criado exibido na Primeira planilha.
//Close(oLeEstru)
Return



Static Function BaixaMM(cCod,cArm,dData)
LOCAL nSaldo := 0

IF SD3->( dbSeek(xFilial("SD3")+cCod+cArm+DTOS(dData)) )
	
	DO WHILE SD3->D3_FILIAL+SD3->D3_COD+SD3->D3_LOCAL+DTOS(SD3->D3_EMISSAO)== xFilial("SD3")+cCod+cArm+DTOS(dData) .AND. !SD3->(EOF())
		IF SD3->D3_ESTORNO!="S" .AND. SD3->D3_TM=="510"
			nSaldo += SD3->D3_QUANT
		ENDIF
		SD3->(dbSkip())
	ENDDO
	
ENDIF

Return nSaldo






Static Function ChkCodSub( cPaiTemp , cFilho , aTabela , nQtdUti)
Local nSaldo,cProdPai
Local calias:=alias()
Local cOrdem:=dbSetOrder()
Local cRecno:=recno()
Local aSaldo:={},i,ix,cTipo
Local lGeraSubst:=GetMv("MV_GERSUBS")
Local cEst      :=SubStr(GetMv("MV_LOCSUBS"),1,2)
Local nI
Private aOpcional
If lGeraSubst //.or. MsgBox("Gera OP com Opcionais?"," OP "+SC2->C2_NUM,"YESNO")
	aOpcional:={}
	DbSelectArea("SG1")
	nReg:=RecNo()
	cProdPai := cPaiTemp     //If(Len(ParamixB[1])=15,ParamixB[1],SubStr(Right(ParamixB[1],18),1,15))
	//For i:=1 to Len(aCols)
	nSaldo:=Posicione("SB2",1,xFilial("SB2")+cFilho+cEst,"B2_QATU")
	cTipo :=Posicione("SB1",1,xFilial("SB1")+cFilho,"B1_TIPO")
	aSaldo:={}
	DbSelectArea("SG1")
	DbSetOrder(01)
	If DbSeek(xFilial("SG1")+cProdPai+cFilho)
		If !(cTipo $ "PA/PL" ) .and. nQtdUti > 0
			If !Empty(SG1->G1_Subst1).and. dDataBase >= SG1->G1_SUBINI1 .and. dDataBase <= SG1->G1_SUBFIM1
				Aadd(aSaldo,{SG1->G1_Subst1,Posicione("SB2",1,xFilial("SB2")+SG1->G1_Subst1+cEst,"B2_QATU"),SG1->G1_SUBINI1,SG1->G1_SUBFIM1,"OPC" })
			Endif
			If !Empty(SG1->G1_Subst2).and. dDataBase >= SG1->G1_SUBINI2 .and. dDataBase <= SG1->G1_SUBFIM2
				Aadd(aSaldo,{SG1->G1_Subst2,Posicione("SB2",1,xFilial("SB2")+SG1->G1_Subst2+cEst,"B2_QATU"),SG1->G1_SUBINI2,SG1->G1_SUBFIM2,"OPC" })
			Endif
			If !Empty(SG1->G1_Subst3).and. dDataBase >= SG1->G1_SUBINI3 .and. dDataBase <= SG1->G1_SUBFIM3
				Aadd(aSaldo,{SG1->G1_Subst3,Posicione("SB2",1,xFilial("SB2")+SG1->G1_Subst3+cEst,"B2_QATU"),SG1->G1_SUBINI3,SG1->G1_SUBFIM3,"OPC"})
			Endif
			If !Empty(SG1->G1_Subst4).and. dDataBase >= SG1->G1_SUBINI4 .and. dDataBase <= SG1->G1_SUBFIM4
				Aadd(aSaldo,{SG1->G1_Subst4,Posicione("SB2",1,xFilial("SB2")+SG1->G1_Subst4+cEst,"B2_QATU"),SG1->G1_SUBINI4,SG1->G1_SUBFIM4,"OPC"})
			Endif
			If !Empty(SG1->G1_Subst5).and. dDataBase >= SG1->G1_SUBINI5 .and. dDataBase <= SG1->G1_SUBFIM5
				Aadd(aSaldo,{SG1->G1_Subst5,Posicione("SB2",1,xFilial("SB2")+SG1->G1_Subst5+cEst,"B2_QATU"),SG1->G1_SUBINI5,SG1->G1_SUBFIM5,"OPC"})
			Endif
			If !Empty(SG1->G1_Subst6).and. dDataBase >= SG1->G1_SUBINI6 .and. dDataBase <= SG1->G1_SUBFIM6
				Aadd(aSaldo,{SG1->G1_Subst6,Posicione("SB2",1,xFilial("SB2")+SG1->G1_Subst6+cEst,"B2_QATU"),SG1->G1_SUBINI6,SG1->G1_SUBFIM6,"OPC"})
			Endif
			If !Empty(SG1->G1_Subst7).and. dDataBase >= SG1->G1_SUBINI7 .and. dDataBase <= SG1->G1_SUBFIM7
				Aadd(aSaldo,{SG1->G1_Subst7,Posicione("SB2",1,xFilial("SB2")+SG1->G1_Subst7+cEst,"B2_QATU"),SG1->G1_SUBINI7,SG1->G1_SUBFIM7,"OPC"})
			Endif
			
			For nI:=1 TO LEN(aSaldo)
				
				cFilho := aSaldo[nI,1]
				
				IF EVAL( &(bCondi) )
					
					IF (nPos:=AScan(aTabela, {|x| x[3] == aSaldo[nI,1]} ) ) > 0
						aTabela[nPos,7]:= aTabela[nPos,7]+nQtdUti
					ELSE
						//IF (nPos:=AScan(aTabela, {|x| x[3] == aSaldo[nI,1]} ) ) == 0
						//nMM := BaixaMM(aSaldo[nI,1],"01",dDataBase)
						nMM := POSICIONE("SB2",1,xFilial("SB2")+aSaldo[nI,1]+"10","B2_QEMP")
						AADD(aTabela,{cPai,cDescPai,aSaldo[nI,1],;
						Posicione("SB1",1,xFilial("SB1")+aSaldo[nI,1],"B1_DESC"),;
						Posicione("SB1",1,xFilial("SB1")+aSaldo[nI,1],"B1_UM"),;
						Posicione("SB1",1,xFilial("SB1")+aSaldo[nI,1],"B1_TIPO"),;
						nQtdUti,;
						POSICIONE("SB2",1,xFilial("SB2")+aSaldo[nI,1]+"01","B2_QATU")-POSICIONE("SBF",1,xFilial("SBF")+"01"+cDescEnd+aSaldo[nI,1],"BF_QUANT" ),;
						POSICIONE("SB2",1,xFilial("SB2")+aSaldo[nI,1]+"70","B2_QATU")-POSICIONE("SBF",1,xFilial("SBF")+"70"+cDescEnd+aSaldo[nI,1],"BF_QUANT" ),;
						POSICIONE("SB2",1,xFilial("SB2")+aSaldo[nI,1]+"07","B2_QATU")-POSICIONE("SBF",1,xFilial("SBF")+"07"+cDescEnd+aSaldo[nI,1],"BF_QUANT" ),;
						nMM,;
						aSaldo[nI,3],;
						aSaldo[nI,4],;
						aSaldo[nI,5] })
					Endif
					
				ENDIF
				
			Next nI
			
			
		Endif
		
	Endif
	
Endif
//Retorna ao Status antes de entra
dbSelectArea(calias)
dbSetOrder(cOrdem)
dbGoto(cRecno)

Return Nil
