#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#DEFINE IMP_SPOOL 2

#DEFINE VBOX       080
#DEFINE VSPACE     008
#DEFINE HSPACE     010
#DEFINE SAYVSPACE  008
#DEFINE SAYHSPACE  008
#DEFINE HMARGEM    030
#DEFINE VMARGEM    030
#DEFINE MAXITEM    022                                                // Máximo de produtos para a primeira página
#DEFINE MAXITEMP2  049                                                // Máximo de produtos para a pagina 2 em diante
#DEFINE MAXITEMP2F 069                                                // Máximo de produtos para a página 2 em diante quando a página não possui informações complementares
#DEFINE MAXITEMP3  025                                                // Máximo de produtos para a pagina 2 em diante (caso utilize a opção de impressao em verso) - Tratamento implementado para atender a legislacao que determina que a segunda pagina de ocupar 50%.
#DEFINE MAXITEMC   038                                                // Máxima de caracteres por linha de produtos/serviços
#DEFINE MAXMENLIN  200                                                // Máximo de caracteres por linha de dados adicionais
#DEFINE MAXMSG     013                                                // Máximo de dados adicionais por página
//ESPECIFICO
#DEFINE MAXVALORC  010                                                // Máximo de caracteres por linha de valores numéricos
//ESPECIFICO


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³AR_PDF001 ³ Autor ³ Vescio Pereira de Moura³ Data ³11.01.2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera AR em PDF para envio ao cliente                        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
USER FUNCTION ARBR01()          
Local cPerg			:= PadR("ARPDFINT",Len(SX1->X1_GRUPO))
Local aRegs    	:= {}
Local aCabSX1		:= {"X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_GSC", "X1_VAR01"}

Local oDanfe, oSetup
Local aDevice		:= {"DISCO", "SPOOL", "EMAIL", "EXCEL", "HTML", "PDF"}
Local cSession		:= GetPrinterSession()
Local aArea			:= GetArea()
Local cFilePrint	:= "FL_" + SM0->M0_CODFIL + "_AR_" + SZG->ZG_NUMERO  //BRASITECH
Local nLocal     	:= If(GetProfString(cSession, "LOCAL", "SERVER", .T.) == "SERVER", 1, 2 )
Local nOrientation:= If(GetProfString(cSession, "ORIENTATION", "PORTRAIT", .T.) == "PORTRAIT", 1, 2)
Local cDevice     := GetProfString(cSession, "PRINTTYPE", "SPOOL", .T.)
Local nPrintType	:= aScan(aDevice,{|x| x == cDevice })

Local aItol			:= {}
Local aItens		:= {}
Local aImp			:= {0, 0, 0, 0, 0, 0, 0, 0}	//BASE ICMS,VAL. ICMS,BASE ST,VAL. ST,VAL.MERC,DESPESA,VALOR DO IPI,TOTAL DA NOTA
Local aImpOL		:= {0, 0, 0, 0, 0, 0, 0, 0}	//BASE ICMS,VAL. ICMS,BASE ST,VAL. ST,VAL.MERC,DESPESA,VALOR DO IPI,TOTAL DA NOTA
Local aDest			:= {SM0->M0_NOMECOM, SM0->M0_CGC, SM0->M0_ENDCOB, SM0->M0_BAIRCOB, SM0->M0_CEPCOB, SM0->M0_CIDCOB, SM0->M0_TEL, SM0->M0_ESTCOB, SM0->M0_INSC}
Local aDestOL		:= {"FM LOGISTIC DO BRASIL OP. DE LOG. LTDA", "02462805000778", "VIA ANHANGUERA, S/N", "JARDIM JARAGUA", "5275000", "SAO PAULO", "", "SP", "115266030117"}
Local lz
                                                          
Private nConsNeg	:= 0.4 // Constante para concertar o cálculo retornado pelo GetTextWidth para fontes em negrito.
Private nConsTex	:= 0.5 // Constante para concertar o cálculo retornado pelo GetTextWidth.

Private nPesoBru	:= 0
Private nPesoLiq	:= 0


//parametros para o processamento
aAdd(aRegs, {cPerg, "01", "Do AR número ?       ",	"mv_ch1", "C", 06, 0, "G", "mv_par01"})
aAdd(aRegs, {cPerg, "02", "Até o AR número ?    ",	"mv_ch2", "C", 06, 0, "G", "mv_par02"})

U_BRASX1(aRegs, aCabSX1)


if MsgBox("Deseja imprimir multiplos AR´s?", "Pergunta", "YESNO")
	/*
	if SX1->(dbSeek(cPerg + "01"))
		SX1->(RecLock("SX1", .F.))
		SX1->X1_CNT01	:= SZG->ZG_NUMERO
		SX1->(MsUnlock())
	endif
		
	if SX1->(dbSeek(cPerg + "02"))
		SX1->(RecLock("SX1", .F.))
		SX1->X1_CNT01	:= SZG->ZG_NUMERO
		SX1->(MsUnlock())
	endif
	*/
	if !Pergunte(cPerg, .T.)
		Return()
	endif

else

	mv_par01 := SZG->ZG_NUMERO
	mv_par02 := SZG->ZG_NUMERO

endif

//MV_PAR05 := 2

lAdjustToLegacy 	:= .F. // Inibe legado de resolução com a TMSPrinter
oDanfe 				:= FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, /*cPathInServer*/, .T.)

// ----------------------------------------------
// Cria e exibe tela de Setup Customizavel
// OBS: Utilizar include "FWPrintSetup.ch"
// ----------------------------------------------
//nFlags := PD_ISTOTVSPRINTER+ PD_DISABLEORIENTATION + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
nFlags 				:= PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
If (!oDanfe:lInJob)
	oSetup := FWPrintSetup():New(nFlags, "Espelho NF - Brasitech")
	// ----------------------------------------------
	// Define saida
	// ----------------------------------------------
	oSetup:SetPropert(PD_PRINTTYPE, 		nPrintType)
	oSetup:SetPropert(PD_ORIENTATION, 	nOrientation)
	oSetup:SetPropert(PD_DESTINATION, 	nLocal)
	oSetup:SetPropert(PD_MARGIN, 			{60,60,60,60})
	oSetup:SetPropert(PD_PAPERSIZE, 		2)

EndIf

// ----------------------------------------------
// Pressionado botão OK na tela de Setup
// ----------------------------------------------
If oSetup:Activate() == PD_OK // PD_OK =1

	//Salva os Parametros no Profile
   WriteProfString( cSession, "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )
   WriteProfString( cSession, "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==1   ,"SPOOL"     ,"PDF"       ), .T. )
   WriteProfString( cSession, "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )

	SA1->(dbSetorder(1))		//A1_FILIAL, A1_COD, A1_LOJA
	SB1->(dbSetorder(1))		//B1_FILIAL, B1_COD
	SD2->(dbSetorder(3))		//D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM
	SZG->(dbSetorder(1))		//ZG_FILIAL, ZG_NUMERO, ZG_EMISSAO, ZG_CLIENTE, ZG_LOJACLI
	SZH->(dbSetorder(1))		//ZH_FILIAL, ZH_NUMERO, ZH_ITEM, ZH_PRODUTO
	
	SZG->(dbSeek(xFilial("SZG") + mv_par01))
	do while SZG->(!eof() .and. ZG_FILIAL == xFilial("SZG") .and. ZG_NUMERO <= mv_par02)
	
		aItol			:= {}
		aItens		:= {}
		aImp			:= {0, 0, 0, 0, 0, 0, 0, 0}	//BASE ICMS,VAL. ICMS,BASE ST,VAL. ST,VAL.MERC,DESPESA,VALOR DO IPI,TOTAL DA NOTA
		aImpOL		:= {0, 0, 0, 0, 0, 0, 0, 0}	//BASE ICMS,VAL. ICMS,BASE ST,VAL. ST,VAL.MERC,DESPESA,VALOR DO IPI,TOTAL DA NOTA
		aDest			:= {SM0->M0_NOMECOM, SM0->M0_CGC, SM0->M0_ENDCOB, SM0->M0_BAIRCOB, SM0->M0_CEPCOB, SM0->M0_CIDCOB, SM0->M0_TEL, SM0->M0_ESTCOB, SM0->M0_INSC}
		aDestOL		:= {"FM LOGISTIC DO BRASIL OP. DE LOG. LTDA", "02462805000778", "VIA ANHANGUERA, S/N", "JARDIM JARAGUA", "5275000", "SAO PAULO", "", "SP", "115266030117"}
		nPesoBru		:= 0
		nPesoLiq		:= 0
		_nOutrDesp	:= 0
		_nOpDesp		:= 0
		_cMsg			:= iif(!empty(SZG->ZG_MSG), AllTrim(SZG->ZG_MSG) + " |*| ", "")
		_cMsg			+= "Endereço de Coleta: "+SZG->(AllTrim(ZG_ENDCOLE)+","+AllTrim(ZG_BAIRROC)+","+AllTrim(ZG_MUNCOLE)+"-"+AllTrim(ZG_ESTCOLE)+" CEP:"+Transform(ZG_CEPCOLE,"@R 99999-999"))
		
		if SZG->ZG_TIPO == "D"
			cTipoDev := "DEVOLUCAO DE COMPRA"
		elseif SZG->ZG_TIPO == "R"
			cTipoDev := "TROCA"
		else
			cTipoDev := ""
		endif

		SA1->(DbSeek(xFilial("SA1") + SZG->ZG_CLIENTE + SZG->ZG_LOJACLI))
		SZH->(dbSeek(xFilial("SZH") + SZG->ZG_NUMERO))
		do while SZH->(!eof() .and. ZH_FILIAL == xFilial("SZH") .and. ZH_NUMERO == SZG->ZG_NUMERO)
		
			SB1->(dbSeek(xFilial("SB1") + SZH->ZH_PRODUTO))
			SD2->(dbSeek(xFilial("SD2") + SZH->(ZH_ORIGEM + ZH_SERIE) + SZG->(ZG_CLIENTE + ZG_LOJACLI) + SZH->ZH_ITEMORI))
		
			nPesoBru	+= SZH->ZH_QTDDEVO * SB1->B1_PESBRU
			nPesoLiq	+= SZH->ZH_QTDDEVO * SB1->B1_PESO
		
			aAdd(aItens, {	SZH->ZH_PRODUTO,;
								SB1->B1_DESC,;
								SB1->B1_POSIPI,;
								SD2->D2_CLASFIS,;
								SZG->ZG_CFOP,;
								SB1->B1_UM,;
								Transform(SZH->ZH_QTDDEVO, "99999"),;
								Transform(SZH->ZH_PRECONF, "@E 9,999.99"),;
								Transform(SZH->ZH_PRECTOT, "@E 99,999.99"),;
								Transform(SZH->ZH_BASEICM, "@E 99,999.99"),;
								Transform(SZH->ZH_VALICM, 	"@E 99,999.99"),;
								Transform(SZH->ZH_VLRIPI, 	"@E 99,999.99"),;
								Transform(SZH->ZH_ICM, 		"@E 99.99"),;
								Transform(SZH->ZH_ALIQIPI, "@E 99"),;
								SZH->ZH_ORIGEM,;
								SZH->ZH_SERIE	})
			
			aImp[1]	  += SZH->ZH_BASEICM
			aImp[2]	  += SZH->ZH_VALICM
			If cFilAnt = "01"
				aImp[3]	  += iif(SZH->ZH_BASEICM > 0, SZH->ZH_BASEST, 0)
				aImp[4]	  += iif(SZH->ZH_BASEICM > 0, SZH->ZH_VALST, 0)
			Else
				aImp[3]	  += SZH->ZH_BASEST
				aImp[4]	  += SZH->ZH_VALST
			Endif
			aImp[5]	  += SZH->ZH_PRECTOT
			If cFilAnt = "01"
				aImp[6]	  += iif(SZH->ZH_BASEICM > 0, 0, SZH->ZH_VALST)
			Else 
				aImp[6]	  += 0
			Endif
			aImp[7]	  += SZH->ZH_VLRIPI
			_nOutrDesp += SZH->ZH_OUTDESP
		    
			//DEPOIS AQUI ACUMULO O VETOR aImpOL com os dados do operador logistico
			aAdd(aItol, {	SZH->ZH_PRODUTO,;
								SB1->B1_DESC,;
								SB1->B1_POSIPI,;
								SD2->D2_CLASFIS,;
								SZG->ZG_OPCFOP,;
								SB1->B1_UM,;
								Transform(SZH->ZH_QTDDEVO, 						"99999"),;
								Transform(SZH->ZH_OPVLUN, 							"@E 9,999.99"),;
								Transform(SZH->ZH_QTDDEVO * SZH->ZH_OPVLUN, 	"@E 99,999.99"),;
								Transform(SZH->ZH_OPBCICM, 						"@E 99,999.99"),;
								Transform(SZH->ZH_OPVLICM, 						"@E 99,999.99"),;
								Transform(SZH->ZH_OPVLIPI, 						"@E 99,999.99"),;
								Transform(SZH->ZH_OPALICM, 						"@E 99.99"),;
								Transform(SZH->ZH_OPALIPI, 						"@E 99")	})
			
			aImpOL[1]	+= SZH->ZH_OPBCICM
			aImpOL[2]	+= SZH->ZH_OPVLICM
			aImpOL[3]	+= SZH->ZH_OPBCST
			aImpOL[4]	+= SZH->ZH_OPVLST
			aImpOL[5]	+= (SZH->ZH_QTDDEVO * SZH->ZH_OPVLUN)
			aImpOL[7]	+= SZH->ZH_OPVLIPI
			_nOpDesp		+= SZH->ZH_OPDESP
		
			SZH->(dbSkip())
		
		enddo
		
		aImp[6]	+= SZG->ZG_VLRDESP + _nOutrDesp
		aImp[8]	:= SZG->ZG_VALOR
		
		if _nOutrDesp > 0
			IF aImp[7] > 0
				_cMsg	+= "Valor do IPI: "+TRANSFORM(aImp[7],"@E 999,999,999.99")+"|"
			Endif
			IF aImp[4] > 0
				_cMsg	+= "Valor da ST: "+TRANSFORM(aImp[4],"@E 999,999,999.99")+"|"
			Endif
			aImp[7]	:= 0
			aImp[4]	:= 0
			aImp[3]	:= 0
		Endif
		
		
		//aImpOL[8]	:= aImpol[5] + aImpol[7] + aImpol[4] + aImp[6]
		aImpOL[8]	:= aImpol[5] + aImpol[7] + aImpol[4]
		aImpOL[6]	:= SZG->ZG_VLRDESP + _nOpDesp
		if _nOpDesp > 0
			IF aImpOL[7] > 0
				_CMSG	+= "Valor do IPI: "+TRANSFORM(aImpOL[7],"@E 999,999,999.99")+"|"
			Endif
			IF aImpOL[4] > 0
				_CMSG	+= "Valor da ST: "+TRANSFORM(aImpOL[4],"@E 999,999,999.99")+"|"
			Endif
		
			aImpol[7]	:= 0
			aImpol[4]	:= 0
			aImpol[3]	:= 0
		Endif
		
		// Recuperar as notas de origem para imprimir nos dados Adicionais
		_cMsgNFOri := ""
		For lz := 1 to len (aItens)
			If ! (aItens[lz][15]) $ _cMSGNFORI
				_cMsgNFOri += iif(!empty(aItens[lz][15]), aItens[lz][15] + Iif(!empty(aItens[lz][16]), "-" + aItens[lz][16], "") + ",", ",")
			endif
		Next
		
		Do While substr(_cMSGNFORI,len(_cMSGNFORI),1) = ','
			_cMsgNFOri := Substr(_cMsgNFOri, 1, len(_cMSGNFORI)-1)
		enddo                                                
		
		if cFilAnt != "01"
			aItol := {}
			aDestOL	:= {}
			aImpOL	:= {}
		endif
	
		//Danfe Retrato DANFEII.PRW
		AR_PDF003(oDanfe, oSetup, aItens, aDest, aImp) //aitens
		
		if cEmpAnt == "01" .and. Len(aDestOL) > 0
			AR_PDF003(oDanfe, oSetup, aItOL, aDestOL, aImpOL) //aitens
		endif
	
		SZG->(dbSkip())
	
	enddo
			
	//Visualiza antes de imprimir
	oDanfe:Preview()
	FreeObj(oDanfe)
	oDanfe := Nil
	
Else
	MsgInfo("Relatório cancelado pelo usuário.")
Endif
	
oDanfe := Nil
oSetup := Nil
Restarea(aArea)
Return()

/*/
———————————————————————————————————————————————————————————————————————————————
@function		AR_PDF003                                                     /@
@type				Static function                                               /@
@date				11/05/2015                                                    /@
@description	                                                              /@
@author			Vescio Pereira de Moura                                       /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function AR_PDF003(oDanfe,oSetup,aItens,aDest,aImp) //aitens
Local aArea			:= GetArea()

oDanfe:linjob		:=.f.  //vou deixar como preview
oDanfe:SetResolution(78) //Tamanho estipulado para a Danfe
oDanfe:SetPortrait()
oDanfe:SetPaperSize(DMPAPER_A4)
oDanfe:SetMargin(60,60,60,60)
oDanfe:lServer 	:= oSetup:GetProperty(PD_DESTINATION)==AMB_SERVER
// ----------------------------------------------
// Define saida de impressão
// ----------------------------------------------
If oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
	oDanfe:nDevice := IMP_SPOOL
	// ----------------------------------------------
	// Salva impressora selecionada
	// ----------------------------------------------
	fwWriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
	oDanfe:cPrinter := oSetup:aOptions[PD_VALUETYPE]
ElseIf oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
	oDanfe:nDevice := IMP_PDF
	// ----------------------------------------------
	// Define para salvar o PDF
	// ----------------------------------------------
	oDanfe:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
Endif

Private PixelX := odanfe:nLogPixelX()
Private PixelY := odanfe:nLogPixelY()

RptStatus({|lEnd| PrtDanfe(@oDanfe,aitens,aDest,aImp)},"Imprimindo Danfe...")
RestArea(aArea)
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PrtDanfe  ³ Autor ³Eduardo Riera          ³ Data ³16.11.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do formulario DANFE grafico conforme laytout no   ³±±
±±³          ³formato retrato                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PrtDanfe()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto grafico de impressao                          ³±±
±±³          ³ExpO2: Objeto da NFe                                        ³±±
±±³          ³ExpC3: Codigo de Autorizacao do fiscal                (OPC) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PrtDanfe(oDanfe,aitens,aDest,aImp)
Local aAuxCabec     := {} // Array que conterá as strings de cabeçalho das colunas de produtos/serviços.
Local aTamCol       := {} // Array que conterá o tamanho das colunas dos produtos/serviços.
Local aAux          := {}
Local aUF           := {}
Local aMensagem     := {}
Local nHPage        := 0
Local nVPage        := 0
Local nAuxH         := 0
Local nAuxH2        := 0
Local nX            := 0
Local nY            := 0
Local nL            := 0
Local nFolha        := 1
Local nFolhas       := 0
Local nMensagem     := 0
Local nLenItens     := 0
Local nLenMensagens := 0
Local nLinhavers    := 0
Local nMaxItemP2    := MAXITEM // Variável utilizada para tratamento de quantos itens devem ser impressos na página corrente 
Local cAux          := ""
Local lPreview      := .F.
Local lFlag         := .T.
Local lConverte     := GetNewPar("MV_CONVERT",.F.)
Local lFimpar	    := .T. 	                     
Local cTxtRodape	:= GetMV("BR_ARRODAP", .F., "")
//Local aTransp       := {}
//Local aISSQN        := {}
//Local aEspVol       := {}

PRIVATE oFont10N   := TFontEx():New(oDanfe,"Times New Roman",08,08,.T.,.T.,.F.)// 1
PRIVATE oFont08    := TFontEx():New(oDanfe,"Times New Roman",07,07,.F.,.T.,.F.)// 4
PRIVATE oFont08N   := TFontEx():New(oDanfe,"Times New Roman",06,06,.T.,.T.,.F.)// 5
PRIVATE oFont11N   := TFontEx():New(oDanfe,"Times New Roman",10,10,.T.,.T.,.F.)// 11
PRIVATE oFont18N   := TFontEx():New(oDanfe,"Times New Roman",17,17,.T.,.T.,.F.)// 12 
PRIVATE OFONT12N   := TFontEx():New(oDanfe,"Times New Roman",11,11,.T.,.T.,.F.)// 12  
//PRIVATE oFont07    := TFontEx():New(oDanfe,"Times New Roman",06,06,.F.,.T.,.F.)// 3
//PRIVATE oFont12    := TFontEx():New(oDanfe,"Times New Roman",11,11,.F.,.T.,.F.)// 10

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializacao da pagina do objeto grafico                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:StartPage()
nHPage := oDanfe:nHorzRes()
nHPage *= (300/PixelX)
nHPage -= HMARGEM
nVPage := oDanfe:nVertRes()
nVPage *= (300/PixelY)
nVPage -= VBOX


oDanfe:Say(025,005, "AVISO DE RECEBIMENTO Nro " + SZG->ZG_NUMERO, oFont18N:oFont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 1 IDENTIFICACAO DO EMITENTE                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Box(042,000,137,250)
oDanfe:Say(057,010, "Identificação do emitente",oFont12N:oFont)
nLinCalc	:=	070
cStrAux		:=	AllTrim(NoChar(SA1->A1_NOME, lConverte))
for nX := 1 to MlCount(cStrAux, 60)
	oDanfe:Say(nLinCalc,010, MemoLine(cStrAux, 60, nX), oFont11N:oFont)
	nLinCalc += 10
next

cStrAux		:=	AllTrim(NoChar(SA1->A1_END))
for nX := 1 to MlCount(cStrAux, 100)
	oDanfe:Say(nLinCalc,010, MemoLine(cStrAux, 100, nX), oFont08N:oFont)
	nLinCalc += 10
next

cStrAux		:=	AllTrim(NoChar(Alltrim(SA1->A1_BAIRRO)+" - CEP: "+SA1->A1_CEP))
for nX := 1 to MlCount(cStrAux, 100)
	oDanfe:Say(nLinCalc,010, MemoLine(cStrAux, 100, nX), oFont08N:oFont)
	nLinCalc += 10
next

cStrAux		:=	AllTrim(NoChar(Alltrim(SA1->A1_MUN)+"-"+SA1->A1_EST))
for nX := 1 to MlCount(cStrAux, 100)
	oDanfe:Say(nLinCalc,010, MemoLine(cStrAux, 100, nX), oFont08N:oFont)
	nLinCalc += 10
next

cStrAux		:=	AllTrim(NoChar("Tel: "+STRZERO(val(SA1->A1_DDD),3)+"-"+SA1->A1_TEL))
for nX := 1 to MlCount(cStrAux, 100)
	oDanfe:Say(nLinCalc,010, MemoLine(cStrAux, 100, nX), oFont08N:oFont)
	nLinCalc += 10
next


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 2                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oDanfe:Box(042,248,137,603)
oDanfe:Say(055,255, "MODELO DE NOTA FISCAL ELETRONICA (DANFE)", oFont12N:oFont)
oDanfe:Say(085,266, "0-ENTRADA",oFont08:oFont)
oDanfe:Say(095,266, "1-SAÍDA"  ,oFont08:oFont)
oDanfe:Box(078,315,095,325)
oDanfe:Say(089,318, "1",oFont08N:oFont)
oDanfe:Say(110,255,"N. "+Iif(!empty(SZG->ZG_NFDEVOL) .and. ! ("ATO" $ Upper(SZG->ZG_NFDEVOL)),alltrim(SZG->ZG_NFDEVOL),"XXXXXXXXX"), oFont10N:oFont)
oDanfe:Say(120,255,"SÉRIE "+Iif(!empty(SZG->ZG_SERIENF),SZG->ZG_SERIENF ,"XXX"),oFont10N:oFont)
oDanfe:Say(130,255,"FOLHA " + StrZero(nFolha,2) , oFont10N:oFont)	//+ "/" + StrZero(nFolhas,2)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Preenchimento do Array de UF                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aUF,{"RO","11"})
aAdd(aUF,{"AC","12"})
aAdd(aUF,{"AM","13"})
aAdd(aUF,{"RR","14"})
aAdd(aUF,{"PA","15"})
aAdd(aUF,{"AP","16"})
aAdd(aUF,{"TO","17"})
aAdd(aUF,{"MA","21"})
aAdd(aUF,{"PI","22"})
aAdd(aUF,{"CE","23"})
aAdd(aUF,{"RN","24"})
aAdd(aUF,{"PB","25"})
aAdd(aUF,{"PE","26"})
aAdd(aUF,{"AL","27"})
aAdd(aUF,{"MG","31"})
aAdd(aUF,{"ES","32"})
aAdd(aUF,{"RJ","33"})
aAdd(aUF,{"SP","35"})
aAdd(aUF,{"PR","41"})
aAdd(aUF,{"SC","42"})
aAdd(aUF,{"RS","43"})
aAdd(aUF,{"MS","50"})
aAdd(aUF,{"MT","51"})
aAdd(aUF,{"GO","52"})
aAdd(aUF,{"DF","53"})
aAdd(aUF,{"SE","28"})
aAdd(aUF,{"BA","29"})
aAdd(aUF,{"EX","99"})

nHPage := oDanfe:nHorzRes()
nHPage *= (300/PixelX)
nHPage -= HMARGEM
nVPage := oDanfe:nVertRes()
nVPage *= (300/PixelY)
nVPage -= VBOX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 4                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Box(139,000,162,603)
oDanfe:Box(139,000,162,350)
oDanfe:Say(148,002, "NATUREZA DA OPERAÇÃO", oFont08N:oFont)
oDanfe:Say(158,002, cTipoDev, oFont08:oFont)

nFolha++


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro 5                                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Box(164,000,187,603)
oDanfe:Box(164,000,187,200)
oDanfe:Box(164,200,187,400)
oDanfe:Box(164,400,187,603)
oDanfe:Say(172,002,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
oDanfe:Say(180,002,SA1->A1_INSCR,oFont08:oFont)
oDanfe:Say(172,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
//oDanfe:Say(180,205,IIf(Type("oEmitente:_IEST:TEXT")<>"U",oEmitente:_IEST:TEXT,""),oFont08:oFont)
oDanfe:Say(172,405,"CNPJ",oFont08N:oFont)
oDanfe:Say(180,405,IF(LEN(TRIM(SA1->A1_CGC))> 11,TRANSFORM(SA1->A1_CGC,"@R 99.999.999/9999-99"),TRANSFORM(SA1->A1_CGC,"@R 999.999.999-99")),oFont08:oFont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro destinatário/remetente                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oDanfe:Say(195,002,"DESTINATARIO/REMETENTE",oFont08N:oFont)
oDanfe:Box(197,000,217,450)
oDanfe:Say(205,002,aDest[1],oFont08:oFont)
//oDanfe:Say(215,002,NoChar(ADEST[1],lConverte),oFont08:oFont)
oDanfe:Box(197,280,217,500)
oDanfe:Say(205,283,transform(aDest[2],"@R 99.999.999/9999-99"),oFont08:oFont)

oDanfe:Box(217,000,237,500)
oDanfe:Box(217,000,237,260)
oDanfe:Say(224,002,"ENDEREÇO",oFont08N:oFont)
oDanfe:Say(234,002,aDest[3],oFont08:oFont)
oDanfe:Box(217,230,237,380)
oDanfe:Say(224,232,"BAIRRO/DISTRITO",oFont08N:oFont)
oDanfe:Say(234,232,aDest[4],oFont08:oFont)
oDanfe:Box(217,380,237,500)
oDanfe:Say(224,382,"CEP",oFont08N:oFont)
oDanfe:Say(234,382,aDest[5],oFont08:oFont)

oDanfe:Box(236,000,257,500)
oDanfe:Box(236,000,257,180)
oDanfe:Say(245,002,"MUNICIPIO",oFont08N:oFont)
oDanfe:Say(255,002,aDest[6],oFont08:oFont)
oDanfe:Box(236,150,257,256)
oDanfe:Say(245,152,"FONE/FAX",oFont08N:oFont)
oDanfe:Say(255,152,aDest[7],oFont08:oFont)
oDanfe:Box(236,255,257,341)
oDanfe:Say(245,257,"UF",oFont08N:oFont)
oDanfe:Say(255,257,aDest[8],oFont08:oFont)
oDanfe:Box(236,340,257,500)
oDanfe:Say(245,342,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
oDanfe:Say(255,342,aDest[9],oFont08:oFont)

oDanfe:Box(197,502,217,603)
oDanfe:Say(205,504,"DATA DE EMISSÃO", oFont08N:oFont)
oDanfe:Say(215,504,"", oFont08:oFont)
oDanfe:Box(217,502,237,603)
oDanfe:Say(224,504,"DATA ENTRADA/SAÍDA",oFont08N:oFont)
oDanfe:Say(233,504,"", oFont08:oFont)
oDanfe:Box(236,502,257,603)
oDanfe:Say(243,503,"HORA ENTRADA/SAÍDA",oFont08N:oFont)
oDanfe:Say(252,503,"", oFont08:oFont)

/*
oDanfe:Say(263,002,"FATURA",oFont08N:oFont)
oDanfe:Box(265,000,296,068)
oDanfe:Box(265,067,296,134)
oDanfe:Box(265,134,296,202)
oDanfe:Box(265,201,296,268)
oDanfe:Box(265,268,296,335)
oDanfe:Box(265,335,296,403)
oDanfe:Box(265,402,296,469)
oDanfe:Box(265,469,296,537)
oDanfe:Box(265,536,296,603)
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do imposto                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Say(305,002,"CALCULO DO IMPOSTO",oFont08N:oFont)
oDanfe:Box(307,000,330,121)
oDanfe:Say(316,002,"BASE DE CALCULO DO ICMS",oFont08N:oFont)
oDanfe:Say(326,002,transform(aImp[1],"@E 999,999.99"),oFont08:oFont)
oDanfe:Box(307,120,330,200)
oDanfe:Say(316,125,"VALOR DO ICMS",oFont08N:oFont)
oDanfe:Say(326,125,transform(aImp[2],"@E 999,999.99"),oFont08:oFont)

oDanfe:Box(307,199,330,360)
oDanfe:Say(316,200,"BASE DE CALCULO DO ICMS SUBSTITUIÇÃO",oFont08N:oFont)
oDanfe:Say(326,202,transform(aImp[3],"@E 999,999.99"),oFont08:oFont)
oDanfe:Box(307,360,330,490)
oDanfe:Say(316,363,"VALOR DO ICMS SUBSTITUIÇÃO",oFont08N:oFont)
oDanfe:Say(326,363,transform(aImp[4],"@E 999,999.99"),oFont08:oFont)
oDanfe:Box(307,490,330,603)
oDanfe:Say(316,491,"VALOR TOTAL DOS PRODUTOS",oFont08N:oFont)
oDanfe:Say(327,491,transform(aImp[5],"@E 999,999.99"),oFont08:oFont)


oDanfe:Box(330,000,353,110)
oDanfe:Say(339,002,"VALOR DO FRETE",oFont08N:oFont)
//oDanfe:Say(349,002,aImp[6],oFont08:oFont)
oDanfe:Box(330,100,353,190)
oDanfe:Say(339,102,"VALOR DO SEGURO",oFont08N:oFont)
//oDanfe:Say(349,102,aImp"SEGURO",oFont08:oFont)
oDanfe:Box(330,190,353,290)
oDanfe:Say(339,194,"DESCONTO",oFont08N:oFont)
//oDanfe:Say(349,194,"DESCONTO",oFont08:oFont)
oDanfe:Box(330,290,353,415)
oDanfe:Say(339,295,"OUTRAS DESPESAS ACESSÓRIAS",oFont08N:oFont)
oDanfe:Say(349,295,transform(aImp[6],"@e 999,999.99"),oFont08:oFont)
oDanfe:Box(330,414,353,500)
oDanfe:Say(339,420,"VALOR DO IPI",oFont08N:oFont)
oDanfe:Say(349,420,transform(aImp[7],"@e 999,999.99"),oFont08:oFont)
oDanfe:Box(330,500,353,603)
oDanfe:Say(339,506,"VALOR TOTAL DA NOTA",oFont08N:oFont)
oDanfe:Say(349,506,transform(aImp[8],"@e 999,999.99"),oFont08:oFont)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transportador/Volumes transportados                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Say(361,002,"TRANSPORTADOR/VOLUMES TRANSPORTADOS",oFont08N:oFont)
oDanfe:Box(363,000,386,603)
oDanfe:Say(372,002,"RAZÃO SOCIAL",oFont08N:oFont)
//oDanfe:Say(382,002,"TRANSP",oFont08:oFont)
oDanfe:Box(363,245,386,315)
oDanfe:Say(372,247,"FRETE POR CONTA",oFont08N:oFont)
	oDanfe:Say(382,247,"1-DESTINATARIO",oFont08:oFont)
//oDanfe:Say(382,102,"0-EMITENTE/1-DESTINATARIO       [" + aTransp[02] + "]",oFont08:oFont)
oDanfe:Box(363,315,386,370)
oDanfe:Say(372,317,"CÓDIGO ANTT",oFont08N:oFont)
//oDanfe:Say(382,319,aTransp[03],oFont08:oFont)
oDanfe:Box(363,370,386,490)
oDanfe:Say(372,375,"PLACA DO VEÍCULO",oFont08N:oFont)
//oDanfe:Say(382,375,aTransp[04],oFont08:oFont)
oDanfe:Box(363,450,386,510)
oDanfe:Say(372,452,"UF",oFont08N:oFont)
//oDanfe:Say(382,452,"UF TRANSP",oFont08:oFont)
oDanfe:Box(363,510,386,603)
oDanfe:Say(372,512,"CNPJ/CPF",oFont08N:oFont)
//oDanfe:Say(382,512,"CNPJ TRANSP",oFont08:oFont)

oDanfe:Box(385,000,409,603)
oDanfe:Box(385,000,409,241)
oDanfe:Say(393,002,"ENDEREÇO",oFont08N:oFont)
//oDanfe:Say(404,002,"END.TRANSP",oFont08:oFont)
oDanfe:Box(385,240,409,341)
oDanfe:Say(393,242,"MUNICIPIO",oFont08N:oFont)
//oDanfe:Say(404,242,"MUN.TRANSP",oFont08:oFont)
oDanfe:Box(385,340,409,440)
oDanfe:Say(393,342,"UF",oFont08N:oFont)
//oDanfe:Say(404,342,"UF.TRANSP",oFont08:oFont)
oDanfe:Box(385,440,409,603)
oDanfe:Say(393,442,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
//oDanfe:Say(404,442,"INSC. TRANSP",oFont08:oFont)


oDanfe:Box(408,000,432,603)
oDanfe:Box(408,000,432,101)
oDanfe:Say(418,002,"QUANTIDADE",oFont08N:oFont)
//oDanfe:Say(428,002,"QUANTY VOL",oFont08:oFont)
oDanfe:Box(408,100,432,200)
oDanfe:Say(418,102,"ESPECIE",oFont08N:oFont)
//oDanfe:Say(428,102,aEspVol[1][1],oFont08:oFont)
oDanfe:Box(408,200,432,301)
oDanfe:Say(418,202,"MARCA",oFont08N:oFont)
//oDanfe:Say(428,202,"MARCA",oFont08:oFont)
oDanfe:Box(408,300,432,400)
oDanfe:Say(418,302,"NUMERAÇÃO",oFont08N:oFont)
//oDanfe:Say(428,302,"NUM",oFont08:oFont)
oDanfe:Box(408,400,432,501)
oDanfe:Say(418,402,"PESO BRUTO",oFont08N:oFont)
oDanfe:Say(428,402,iif(nPesoBru > 0, Transform(nPesoBru,"@E 99,9999.999"), ""), oFont08:oFont)
oDanfe:Box(408,500,432,603)
oDanfe:Say(418,502,"PESO LIQUIDO",oFont08N:oFont)
oDanfe:Say(428,502,iif(nPesoLiq > 0, Transform(nPesoLiq,"@E 99,9999.999"), ""), oFont08:oFont)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Calculo do ISSQN                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
oDanfe:Say(686,000,"CALCULO DO ISSQN",oFont08N:oFont)
oDanfe:Box(688,000,711,151)
oDanfe:Say(696,002,"INSCRIÇÃO MUNICIPAL",oFont08N:oFont)
//oDanfe:Say(706,002,aISSQN[1],oFont08:oFont)
oDanfe:Box(688,150,711,301)
oDanfe:Say(696,152,"VALOR TOTAL DOS SERVIÇOS",oFont08N:oFont)
//oDanfe:Say(706,152,aISSQN[2],oFont08:oFont)
oDanfe:Box(688,300,711,451)
oDanfe:Say(696,302,"BASE DE CÁLCULO DO ISSQN",oFont08N:oFont)
//oDanfe:Say(706,302,aISSQN[3],oFont08:oFont)
oDanfe:Box(688,450,711,603)
oDanfe:Say(696,452,"VALOR DO ISSQN",oFont08N:oFont)
//oDanfe:Say(706,452,aISSQN[4],oFont08:oFont)
*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados Adicionais                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDanfe:Say(719,000,"DADOS ADICIONAIS",oFont08N:oFont)
oDanfe:Box(721,000,865,603)
oDanfe:Say(729,002,"INFORMAÇÕES COMPLEMENTARES",oFont08N:oFont)
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Quadro de informacoes complementares                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aMensagem 	:= {}
cAux 			:= AllTrim(_CMSG) + chr(13) + chr(10) + "Notas de Origem: "+_cMSGNFORI + chr(13) + chr(10) + cTxtRodape
nLin			:= 741
for nX := 1 to MlCount(cAux, MAXMENLIN)
	oDanfe:Say(nLin, 002, MemoLine(cAux, MAXMENLIN, nX), oFont08:oFont)
	nLin:= nLin+10
Next
nMensagem := nX

//oDanfe:Box(721,350,865,603)
//oDanfe:Say(729,352,"RESERVADO AO FISCO",oFont08N:oFont)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados do produto ou servico                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAux := {{{},{},{},{},{},{},{},{},{},{},{},{},{},{}}}
nY := 0
nLenItens := Len(aItens)

For nX :=1 To nLenItens
	nY++
	aAdd(Atail(aAux)[nY],aItens[nX][01])
	nY++
	aAdd(Atail(aAux)[nY],NoChar(aItens[nX][02],lConverte))
	nY++
	aAdd(Atail(aAux)[nY],aItens[nX][03])
	nY++
	aAdd(Atail(aAux)[nY],aItens[nX][04])
	nY++
	aAdd(Atail(aAux)[nY],aItens[nX][05])
	nY++
	aAdd(Atail(aAux)[nY],aItens[nX][06])
	nY++
	aAdd(Atail(aAux)[nY],aItens[nX][07])
	nY++
	aAdd(Atail(aAux)[nY],aItens[nX][08])
	nY++
	aAdd(Atail(aAux)[nY],aItens[nX][09])
	nY++
	aAdd(Atail(aAux)[nY],aItens[nX][10])
	nY++
	aAdd(Atail(aAux)[nY],aItens[nX][11])
	nY++
	aAdd(Atail(aAux)[nY],aItens[nX][12])
	nY++
	aAdd(Atail(aAux)[nY],aItens[nX][13])
	nY++
	aAdd(Atail(aAux)[nY],aItens[nX][14])
	If nY >= 14
		nY := 0
	EndIf
Next nX
For nX := 1 To nLenItens
	nY++
	aAdd(Atail(aAux)[nY],"")
	nY++
	aAdd(Atail(aAux)[nY],"")
	nY++
	aAdd(Atail(aAux)[nY],"")
	nY++
	aAdd(Atail(aAux)[nY],"")
	nY++
	aAdd(Atail(aAux)[nY],"")
	nY++
	aAdd(Atail(aAux)[nY],"")
	nY++
	aAdd(Atail(aAux)[nY],"")
	nY++
	aAdd(Atail(aAux)[nY],"")
	nY++
	aAdd(Atail(aAux)[nY],"")
	nY++
	aAdd(Atail(aAux)[nY],"")
	nY++
	aAdd(Atail(aAux)[nY],"")
	nY++
	aAdd(Atail(aAux)[nY],"")
	nY++
	aAdd(Atail(aAux)[nY],"")
	nY++
	aAdd(Atail(aAux)[nY],"")
	If nY >= 14
		nY := 0
	EndIf
	
Next nX

// Popula o array de cabeçalho das colunas de produtos/serviços.
aAuxCabec := {;
	"COD. PROD",;
	"DESCRIÇÃO DO PROD./SERV.",;
	"NCM/SH",;
	"CST",;
	"CFOP",;
	"UN",;
	"QUANT.",;
	"V.UNITARIO",;
	"V.TOTAL",;
	"BC.ICMS",;
	"V.ICMS",;
	"V.IPI",;
	"A.ICMS",;
	"A.IPI";
}

// Retorna o tamanho das colunas baseado em seu conteudo
aTamCol := RetTamCol(aAuxCabec, aAux, oDanfe, oFont08:oFont, oFont08N:oFont)

oDanfe:Say(440,002,"DADOS DO PRODUTO / SERVIÇO",oFont08N:oFont)
oDanfe:Box(442,000,678,603)
nAuxH := 0
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[1])
oDanfe:Say(450, nAuxH + 2, "COD. PROD",oFont08N:oFont)
nAuxH += aTamCol[1]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[2])
oDanfe:Say(450, nAuxH + 2, "DESCRIÇÃO DO PROD./SERV.", oFont08N:oFont)
nAuxH += aTamCol[2]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[3])
oDanfe:Say(450, nAuxH + 2, "NCM/SH", oFont08N:oFont)
nAuxH += aTamCol[3]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[4])
oDanfe:Say(450, nAuxH + 2, "CST", oFont08N:oFont)
nAuxH += aTamCol[4]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[5])
oDanfe:Say(450, nAuxH + 2, "CFOP", oFont08N:oFont)
nAuxH += aTamCol[5]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[6])
oDanfe:Say(450, nAuxH + 2, "UN", oFont08N:oFont)
nAuxH += aTamCol[6]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[7])
oDanfe:Say(450, nAuxH + 2, "QUANT.", oFont08N:oFont)
nAuxH += aTamCol[7]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[8])
oDanfe:Say(450, nAuxH + 2, "V.UNITARIO", oFont08N:oFont)
nAuxH += aTamCol[8]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[9])
oDanfe:Say(450, nAuxH + 2, "V.TOTAL", oFont08N:oFont)
nAuxH += aTamCol[9]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[10])
oDanfe:Say(450, nAuxH + 2, "BC.ICMS", oFont08N:oFont)
nAuxH += aTamCol[10]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[11])
oDanfe:Say(450, nAuxH + 2, "V.ICMS", oFont08N:oFont)
nAuxH += aTamCol[11]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[12])
oDanfe:Say(450, nAuxH + 2, "V.IPI", oFont08N:oFont)
nAuxH += aTamCol[12]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[13])
oDanfe:Say(450, nAuxH + 2, "A.ICMS", oFont08N:oFont)
nAuxH += aTamCol[13]
oDanfe:Box(442, nAuxH, 678, nAuxH + aTamCol[14])
oDanfe:Say(450, nAuxH + 2, "A.IPI", oFont08N:oFont)


// INICIANDO INFORMAÇÕES PARA O CABEÇALHO DA PAGINA 2
nLinha	:= 460
nL	:= 0
lFlag	:= .T.

For nY := 1 To nLenItens
	nL++
	
	nLin:= 741
	nCont := 0
	
	If lflag
		If nL > nMaxItemP2
			oDanfe:EndPage()
			oDanfe:StartPage()
			nLinhavers := 0

			nLinha    	:=	181 + IIF(nFolha >=3 ,0, nLinhavers)
			
			
			oDanfe:Say(025,005, "AVISO DE RECEBIMENTO Nro " + SZG->ZG_NUMERO, oFont18N:oFont)
			
			nLinhavers := 0


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quadro 1 IDENTIFICACAO DO EMITENTE                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oDanfe:Box(042,000,137,250)
			oDanfe:Say(057,010, "Identificação do emitente",oFont12N:oFont)
			nLinCalc	:=	070
			cStrAux		:=	AllTrim(NoChar(SA1->A1_NOME, lConverte))
			for nX := 1 to MlCount(cStrAux, 60)
				oDanfe:Say(nLinCalc,010, MemoLine(cStrAux, 60, nX), oFont11N:oFont)
				nLinCalc += 10
			next
			
			cStrAux		:=	AllTrim(NoChar(SA1->A1_END))
			for nX := 1 to MlCount(cStrAux, 100)
				oDanfe:Say(nLinCalc,010, MemoLine(cStrAux, 100, nX), oFont08N:oFont)
				nLinCalc += 10
			next
			
			cStrAux		:=	AllTrim(NoChar(Alltrim(SA1->A1_BAIRRO)+" - CEP: "+SA1->A1_CEP))
			for nX := 1 to MlCount(cStrAux, 100)
				oDanfe:Say(nLinCalc,010, MemoLine(cStrAux, 100, nX), oFont08N:oFont)
				nLinCalc += 10
			next
			
			cStrAux		:=	AllTrim(NoChar(Alltrim(SA1->A1_MUN)+"-"+SA1->A1_EST))
			for nX := 1 to MlCount(cStrAux, 100)
				oDanfe:Say(nLinCalc,010, MemoLine(cStrAux, 100, nX), oFont08N:oFont)
				nLinCalc += 10
			next
			
			cStrAux		:=	AllTrim(NoChar("Tel: "+STRZERO(val(SA1->A1_DDD),3)+"-"+SA1->A1_TEL))
			for nX := 1 to MlCount(cStrAux, 100)
				oDanfe:Say(nLinCalc,010, MemoLine(cStrAux, 100, nX), oFont08N:oFont)
				nLinCalc += 10
			next
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Quadro 2                                                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oDanfe:Box(042,248,137,603)
			oDanfe:Say(055,255, "MODELO DE NOTA FISCAL ELETRONICA (DANFE)", oFont12N:oFont)
			oDanfe:Say(085,266, "0-ENTRADA",oFont08:oFont)
			oDanfe:Say(095,266, "1-SAÍDA"  ,oFont08:oFont)
			oDanfe:Box(078,315,095,325)
			oDanfe:Say(089,318, "1",oFont08N:oFont)
			oDanfe:Say(110,255,"N. "+Iif(!empty(SZG->ZG_NFDEVOL) .and. ! ("ATO" $ Upper(SZG->ZG_NFDEVOL)),alltrim(SZG->ZG_NFDEVOL),"XXXXXXXXX"), oFont10N:oFont)
			oDanfe:Say(120,255,"SÉRIE "+Iif(!empty(SZG->ZG_SERIENF),SZG->ZG_SERIENF ,"XXX"),oFont10N:oFont)
			oDanfe:Say(130,255,"FOLHA " + StrZero(nFolha++,2) , oFont10N:oFont)

			nLenMensagens:= Len(aMensagem)
			
			nColLim		:=	iif(nMensagem <= nLenMensagens, 680, 865) + nLinhavers 	//Iif(MV_PAR05==1,435,Iif(nMensagem <= nLenMensagens,680,865)) + nLinhavers 
			oDanfe:Say(131,002,"DADOS DO PRODUTO / SERVIÇO",oFont08N:oFont)
			oDanfe:Box(123,000,nColLim,603)

			nAuxH := 0
			oDanfe:Box(133, nAuxH, nColLim, nAuxH + aTamCol[1])
			oDanfe:Say(141, nAuxH + 2, "COD. PROD",oFont08N:oFont)
			nAuxH += aTamCol[1]
			oDanfe:Box(133, nAuxH, nColLim, nAuxH + aTamCol[2])
			oDanfe:Say(141, nAuxH + 2, "DESCRIÇÃO DO PROD./SERV.", oFont08N:oFont)
			nAuxH += aTamCol[2]
			oDanfe:Box(133, nAuxH, nColLim, nAuxH + aTamCol[3])
			oDanfe:Say(141, nAuxH + 2, "NCM/SH", oFont08N:oFont)
			nAuxH += aTamCol[3]
			oDanfe:Box(133, nAuxH, nColLim, nAuxH + aTamCol[4])
			oDanfe:Say(141, nAuxH + 2, "CST", oFont08N:oFont)
			nAuxH += aTamCol[4]
			oDanfe:Box(133, nAuxH, nColLim, nAuxH + aTamCol[5])
			oDanfe:Say(141, nAuxH + 2, "CFOP", oFont08N:oFont)
			nAuxH += aTamCol[5]
			oDanfe:Box(133, nAuxH, nColLim, nAuxH + aTamCol[6])
			oDanfe:Say(141, nAuxH + 2, "UN", oFont08N:oFont)
			nAuxH += aTamCol[6]
			oDanfe:Box(133, nAuxH, nColLim, nAuxH + aTamCol[7])
			oDanfe:Say(141, nAuxH + 2, "QUANT.", oFont08N:oFont)
			nAuxH += aTamCol[7]
			oDanfe:Box(133, nAuxH, nColLim, nAuxH + aTamCol[8])
			oDanfe:Say(141, nAuxH + 2, "V.UNITARIO", oFont08N:oFont)
			nAuxH += aTamCol[8]
			oDanfe:Box(133, nAuxH, nColLim, nAuxH + aTamCol[9])
			oDanfe:Say(141, nAuxH + 2, "V.TOTAL", oFont08N:oFont)
			nAuxH += aTamCol[9]
			oDanfe:Box(133, nAuxH, nColLim, nAuxH + aTamCol[10])
			oDanfe:Say(141, nAuxH + 2, "BC.ICMS", oFont08N:oFont)
			nAuxH += aTamCol[10]
			oDanfe:Box(133, nAuxH, nColLim, nAuxH + aTamCol[11])
			oDanfe:Say(141, nAuxH + 2, "V.ICMS", oFont08N:oFont)
			nAuxH += aTamCol[11]
			oDanfe:Box(133, nAuxH, nColLim, nAuxH + aTamCol[12])
			oDanfe:Say(141, nAuxH + 2, "V.IPI", oFont08N:oFont)
			nAuxH += aTamCol[12]
			oDanfe:Box(133, nAuxH, nColLim, nAuxH + aTamCol[13])
			oDanfe:Say(141, nAuxH + 2, "A.ICMS", oFont08N:oFont)
			nAuxH += aTamCol[13]
			oDanfe:Box(133, nAuxH, nColLim, nAuxH + aTamCol[14])
			oDanfe:Say(141, nAuxH + 2, "A.IPI", oFont08N:oFont)
			
			// FINALIZANDO INFORMAÇÕES PARA O CABEÇALHO DA PAGINA 2
			nL	:= 1
			lFlag	:= .F.                                         		
			
			//Verifico se ainda existem Dados Adicionais a serem impressos
			if nMensagem <= nLenMensagens		//IF MV_PAR05 <> 1 .And. nMensagem <= nLenMensagens
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Dados Adicionais                                                        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oDanfe:Say(719+nLinhavers,000,"DADOS ADICIONAIS",oFont08N:oFont)
				oDanfe:Box(721+nLinhavers,000,865+nLinhavers,603)
				oDanfe:Say(729+nLinhavers,002,"INFORMAÇÕES COMPLEMENTARES",oFont08N:oFont)				
/*				
				nLin:= 741
				nLenMensagens:= Len(aMensagem)
				--nMensagem
				For nX := 1 To Min(nLenMensagens - nMensagem, MAXMSG)
					oDanfe:Say(nLin,002,aMensagem[nMensagem+nX],oFont08:oFont)
					nLin:= nLin+10
				Next nX
				nMensagem := nMensagem+nX
				
				oDanfe:Box(721+nLinhavers,350,865+nLinhavers,603)
				oDanfe:Say(729+nLinhavers,352,"RESERVADO AO FISCO",oFont08N:oFont)
/*/				
				// Seta o máximo de itens para o MAXITEMP2
				nMaxItemP2 := MAXITEMP2
				
			Else
				// Seta o máximo de itens para o MAXITEMP2F
				nMaxItemP2 := MAXITEMP2F
			EndIF
		Endif		
	Endif
	
	// INICIANDO INFORMAÇÕES PARA O CABEÇALHO DA PAGINA 3 E DIANTE	
	If	nL > nMaxItemP2	//Iif( (nfolha-1)%2==0 .And. MV_PAR05==1,MAXITEMP3,nMaxItemP2)
		oDanfe:EndPage()
		oDanfe:StartPage()
		nLenMensagens:= Len(aMensagem)							
		nColLim		:=	Iif(nMensagem <= nLenMensagens, 680, 865)	//Iif(!(nfolha-1)%2==0 .And. MV_PAR05==1,435,Iif(nMensagem <= nLenMensagens,680,865))
		lFimpar		:=  ((nfolha-1)%2==0)
		nLinha    	:=	181      
		If nfolha >= 3
			nLinhavers := 0
		EndIf

		oDanfe:Say(005,005, "AVISO DE RECEBIMENTO Nro " + SZG->ZG_NUMERO, oFont18N:oFont)
		
		oDanfe:Box(000,000,095,250)
		oDanfe:Say(015,010, "Identificação do emitente",oFont12N:oFont)
		nLinCalc	:=	028
		
		cStrAux		:=	AllTrim(NoChar(SA1->A1_NOME, lConverte))
		for nX := 1 to MlCount(cStrAux, 60)
			oDanfe:Say(nLinCalc,010, MemoLine(cStrAux, 60, nX), oFont11N:oFont)
			nLinCalc += 10
		next
		
		cStrAux		:=	AllTrim(NoChar(SA1->A1_END))
		for nX := 1 to MlCount(cStrAux, 100)
			oDanfe:Say(nLinCalc,010, MemoLine(cStrAux, 100, nX), oFont08N:oFont)
			nLinCalc += 10
		next

		oDanfe:Box(000,248,095,351)
		oDanfe:Say(013,255, "MODELO DE NOTA FISCAL ELETRONICA (DANFE)",oFont18N:oFont)
//		oDanfe:Say(023,255, "DOCUMENTO AUXILIAR DA",oFont07:oFont)
//		oDanfe:Say(033,255, "NOTA FISCAL ELETRÔNICA",oFont07:oFont)
		oDanfe:Say(043,255, "0-ENTRADA",oFont08:oFont)
		oDanfe:Say(053,255, "1-SAÍDA"  ,oFont08:oFont)
		oDanfe:Box(037,305,047,315)
		oDanfe:Say(045,307, "1", oFont08N:oFont)
		oDanfe:Say(062,255,"N. XXXXXXXXX",oFont10N:oFont)
		oDanfe:Say(072,255,"SÉRIE XXX",oFont10N:oFont)
		oDanfe:Say(082,255,"FOLHA "+StrZero(nFolha,2),oFont10N:oFont)	//+"/"+StrZero(nFolhas,2)
		
		oDanfe:Box(000,350,095,603)
		oDanfe:Box(000,350,040,603)
		oDanfe:Box(040,350,062,603)
		oDanfe:Box(063,350,095,603)
//		oDanfe:Say(058,355,TransForm(SubStr(oNF:_InfNfe:_ID:Text,4),"@r 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999 9999"),oFont12N:oFont)
		
//		oDanfe:Say(048,355,"CHAVE DE ACESSO DA NF-E",oFont12N:oFont)
//		nFontSize := 28
//		oDanfe:Code128C(036,370,SubStr(oNF:_InfNfe:_ID:Text,4), nFontSize )
		
//			oDanfe:SayBitmap(002+nLinhavers,002,cLogo,085,040)  //especifico

		
		oDanfe:Box(100,000,123,603)
		oDanfe:Box(100,000,123,300)
		oDanfe:Say(109,002, "NATUREZA DA OPERAÇÃO", oFont08N:oFont)
		oDanfe:Say(119,002, cTipoDev, oFont08:oFont)

		nFolha++
		
		oDanfe:Box(126,000,153,603)
		oDanfe:Box(126,000,153,200)
		oDanfe:Box(126,200,153,400)
		oDanfe:Box(126,400,153,603)
		oDanfe:Say(135,002,"INSCRIÇÃO ESTADUAL",oFont08N:oFont)
		oDanfe:Say(143,002,"INSC.EST",oFont08:oFont)
//		oDanfe:Say(135,205,"INSC.ESTADUAL DO SUBST.TRIB.",oFont08N:oFont)
//		oDanfe:Say(143,205,IIf(Type("oEmitente:_IEST:TEXT")<>"U",oEmitente:_IEST:TEXT,""),oFont08:oFont)
		oDanfe:Say(135,405,"CNPJ",oFont08N:oFont)
		oDanfe:Say(143,405,"CNPJ",oFont08:oFont)
		
		oDanfe:Say(161,002,"DADOS DO PRODUTO / SERVIÇO",oFont08N:oFont)
		oDanfe:Box(163,000,nColLim,603)
		
		nAuxH := 0
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[1])
		oDanfe:Say(171, nAuxH + 2, "COD. PROD",oFont08N:oFont)
		nAuxH += aTamCol[1]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[2])
		oDanfe:Say(171, nAuxH + 2, "DESCRIÇÃO DO PROD./SERV.", oFont08N:oFont)
		nAuxH += aTamCol[2]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[3])
		oDanfe:Say(171, nAuxH + 2, "NCM/SH", oFont08N:oFont)
		nAuxH += aTamCol[3]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[4])
		oDanfe:Say(171, nAuxH + 2, "CST", oFont08N:oFont)
		nAuxH += aTamCol[4]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[5])
		oDanfe:Say(171, nAuxH + 2, "CFOP", oFont08N:oFont)
		nAuxH += aTamCol[5]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[6])
		oDanfe:Say(171, nAuxH + 2, "UN", oFont08N:oFont)
		nAuxH += aTamCol[6]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[7])
		oDanfe:Say(171, nAuxH + 2, "QUANT.", oFont08N:oFont)
		nAuxH += aTamCol[7]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[8])
		oDanfe:Say(171, nAuxH + 2, "V.UNITARIO", oFont08N:oFont)
		nAuxH += aTamCol[8]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[9])
		oDanfe:Say(171, nAuxH + 2, "V.TOTAL", oFont08N:oFont)
		nAuxH += aTamCol[9]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[10])
		oDanfe:Say(171, nAuxH + 2, "BC.ICMS", oFont08N:oFont)
		nAuxH += aTamCol[10]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[11])
		oDanfe:Say(171, nAuxH + 2, "V.ICMS", oFont08N:oFont)
		nAuxH += aTamCol[11]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[12])
		oDanfe:Say(171, nAuxH + 2, "V.IPI", oFont08N:oFont)
		nAuxH += aTamCol[12]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[13])
		oDanfe:Say(171, nAuxH + 2, "A.ICMS", oFont08N:oFont)
		nAuxH += aTamCol[13]
		oDanfe:Box(163, nAuxH, nColLim, nAuxH + aTamCol[14])
		oDanfe:Say(171, nAuxH + 2, "A.IPI", oFont08N:oFont)
		
		//Verifico se ainda existem Dados Adicionais a serem impressos
		nLenMensagens:= Len(aMensagem)			
		if nMensagem <= nLenMensagens		//IF (MV_PAR05 <> 1 .Or. (MV_PAR05 == 1 .And. lFimpar )).And. nMensagem <= nLenMensagens
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Dados Adicionais                                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oDanfe:Say(719,000,"DADOS ADICIONAIS",oFont08N:oFont)
			oDanfe:Box(721,000,865,603)
			oDanfe:Say(729,002,"INFORMAÇÕES COMPLEMENTARES",oFont08N:oFont)				
			
			nLin:= 741
			nLenMensagens:= Len(aMensagem)
			--nMensagem
			For nX := 1 To Min(nLenMensagens - nMensagem, MAXMSG)				
				oDanfe:Say(nLin,002,aMensagem[nMensagem+nX],oFont08:oFont)
				nLin:= nLin+10
			Next nX
			nMensagem := nMensagem+nX
			
//			oDanfe:Box(721+nLinhavers,350,865+nLinhavers,603)
//			oDanfe:Say(729+nLinhavers,352,"RESERVADO AO FISCO",oFont08N:oFont)
			
			// Seta o máximo de itens para o MAXITEMP2
			nMaxItemP2 := MAXITEMP2
		Else
			// Seta o máximo de itens para o MAXITEMP2F
			nMaxItemP2 := MAXITEMP2F
		EndIF	
//		If (!(nfolha-1)%2==0) .And. MV_PAR05==1
//			If nY+69<nLenItens
//				oDanfe:Say(875+nLinhavers,497,"CONTINUA NO VERSO")
//			Endif
//		End
		
		nL := 1
	EndIf
	
	nAuxH := 0
	
	If aAux[1][1][nY] == "-"
		oDanfe:Say(nLinha, nAuxH, Replicate("- ", 150), oFont08:oFont)
	Else
		oDanfe:Say(nLinha, nAuxH + 2, aAux[1][1][nY], oFont08:oFont )
		nAuxH += aTamCol[1]
		oDanfe:Say(nLinha, nAuxH + 2, aAux[1][2][nY], oFont08:oFont) // DESCRICAO DO PRODUTO
		nAuxH += aTamCol[2]
		oDanfe:Say(nLinha, nAuxH + 2, aAux[1][3][nY], oFont08:oFont) // NCM
		nAuxH += aTamCol[3]
		oDanfe:Say(nLinha, nAuxH + 2, aAux[1][4][nY], oFont08:oFont) // CST
		nAuxH += aTamCol[4]
		oDanfe:Say(nLinha, nAuxH + 2, aAux[1][5][nY], oFont08:oFont) // CFOP
		nAuxH += aTamCol[5]
		oDanfe:Say(nLinha, nAuxH + 2, aAux[1][6][nY], oFont08:oFont) // UN
		nAuxH += aTamCol[6]
		// Workaround para falha no FWMSPrinter:GetTextWidth()
		If Empty(aAux[1][6][nY]) // UN
			nAuxH2 := nAuxH + ((aTamCol[7] - 2) - RetTamTex(aAux[1][7][nY], oFont08:oFont, oDanfe)) + 2 //- RetTamTex("0", oFont08:oFont, oDanfe)
		Else
			nAuxH2 := nAuxH + ((aTamCol[7] - 2) - RetTamTex(aAux[1][7][nY], oFont08:oFont, oDanfe)) + 2
		EndIf
		oDanfe:Say(nLinha, nAuxH2 + 2, aAux[1][7][nY], oFont08:oFont) // QUANT
		nAuxH += aTamCol[7]
		If Empty(aAux[1][6][nY]) // UN
			nAuxH2 := nAuxH + ((aTamCol[8] - 2) - RetTamTex(aAux[1][8][nY], oFont08:oFont, oDanfe)) + 2 //- RetTamTex("0", oFont08:oFont, oDanfe)
		Else
			nAuxH2 := nAuxH + ((aTamCol[8] - 2) - RetTamTex(aAux[1][8][nY], oFont08:oFont, oDanfe)) + 2
		EndIf
		oDanfe:Say(nLinha, nAuxH2 + 2, aAux[1][8][nY], oFont08:oFont) // V UNITARIO
		nAuxH += aTamCol[8]
		If Empty(aAux[1][6][nY]) // UN
			nAuxH2 := nAuxH + ((aTamCol[9] - 2) - RetTamTex(aAux[1][9][nY], oFont08:oFont, oDanfe)) + 2 //- RetTamTex("0", oFont08:oFont, oDanfe)
		Else
			nAuxH2 := nAuxH + ((aTamCol[9] - 2) - RetTamTex(aAux[1][9][nY], oFont08:oFont, oDanfe)) + 2
		EndIf
		oDanfe:Say(nLinha, nAuxH2 + 2, aAux[1][9][nY], oFont08:oFont) // V. TOTAL
		nAuxH += aTamCol[9]
		If Empty(aAux[1][6][nY]) // UN
			nAuxH2 := nAuxH + ((aTamCol[10] - 2) - RetTamTex(aAux[1][10][nY], oFont08:oFont, oDanfe)) + 2 //- RetTamTex("0", oFont08:oFont, oDanfe)
		Else
			nAuxH2 := nAuxH + ((aTamCol[10] - 2) - RetTamTex(aAux[1][10][nY], oFont08:oFont, oDanfe)) + 2
		EndIf
		oDanfe:Say(nLinha, nAuxH2 + 2, aAux[1][10][nY], oFont08:oFont) // BC. ICMS
		nAuxH += aTamCol[10]
		If Empty(aAux[1][6][nY]) // UN
			nAuxH2 := nAuxH + ((aTamCol[11] - 2) - RetTamTex(aAux[1][11][nY], oFont08:oFont, oDanfe)) + 2 //- RetTamTex("0", oFont08:oFont, oDanfe)
		Else
			nAuxH2 := nAuxH + ((aTamCol[11] - 2) - RetTamTex(aAux[1][11][nY], oFont08:oFont, oDanfe)) + 2
		EndIf
		oDanfe:Say(nLinha, nAuxH2 + 2, aAux[1][11][nY], oFont08:oFont) // V. ICMS
		nAuxH += aTamCol[11]
		If Empty(aAux[1][6][nY]) // UN
			nAuxH2 := nAuxH + ((aTamCol[12] - 2) - RetTamTex(aAux[1][12][nY], oFont08:oFont, oDanfe)) + 2 //- RetTamTex("0", oFont08:oFont, oDanfe)
		Else
			nAuxH2 := nAuxH + ((aTamCol[12] - 2) - RetTamTex(aAux[1][12][nY], oFont08:oFont, oDanfe)) + 2
		EndIf
		oDanfe:Say(nLinha, nAuxH2 + 2, aAux[1][12][nY], oFont08:oFont) // V.IPI
		nAuxH += aTamCol[12]
		nAuxH2 := nAuxH + ((aTamCol[13] - 2) - RetTamTex(aAux[1][13][nY], oFont08:oFont, oDanfe)) + 2
		oDanfe:Say(nLinha, nAuxH2 + 2, aAux[1][13][nY], oFont08:oFont) // A.ICMS
		nAuxH += aTamCol[13]
		nAuxH2 := nAuxH + ((aTamCol[14] - 2) - RetTamTex(aAux[1][14][nY], oFont08:oFont, oDanfe)) + 2
		oDanfe:Say(nLinha, nAuxH2 + 2, aAux[1][14][nY], oFont08:oFont) // A.IPI
	EndIf
	
	nLinha :=nLinha + 10
Next nY

/*
nLenMensagens := Len(aMensagem)
While nMensagem <= nLenMensagens
	DanfeCpl(oDanfe,aItens,aMensagem,@nItem,@nMensagem,oNFe,oIdent,oEmitente,@nFolha,nFolhas,cCodAutSef,oNfeDPEC,cCodAutDPEC,cDtHrRecCab, cLogoD)
EndDo
/*/

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Finaliza a Impressão                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPreview
	//	oDanfe:Preview()
EndIf

oDanfe:EndPage()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para nao imprimir DANFEs diferentes na mesma folha, uma na FRENTE e outra no VERSO.  |
//|   Isso quando a impressora estiver configurada para frente e verso                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
If MV_PAR05==1 .And. MV_PAR01 <> MV_PAR02 .And. (--nFolha)%2<>0
	oDanfe:StartPage()
	oDanfe:EndPage()
EndIf
/*/

Return(.T.)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DANFE     ºAutor  ³Fabio Santana	     º Data ³  04/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Converte caracteres espceiais						          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
STATIC FUNCTION NoChar(cString,lConverte)

Default lConverte := .F.

If lConverte
	cString := (StrTran(cString,"&lt;","<"))
	cString := (StrTran(cString,"&gt;",">"))
	cString := (StrTran(cString,"&amp;","&"))
	cString := (StrTran(cString,"&quot;",'"'))
	cString := (StrTran(cString,"&#39;","'"))
EndIf

Return(cString)


//-----------------------------------------------------------------------
/*/{Protheus.doc} RetTamCol
Retorna um array do mesmo tamanho do array de entrada, contendo as
medidas dos maiores textos para cálculo de colunas.

@author Marcos Taranta
@since 24/05/2011
@version 1.0 

@param  aCabec     Array contendo as strings de cabeçalho das colunas
        aValores   Array contendo os valores que serão populados nas
                   colunas.
        oPrinter   Objeto de impressão instanciado para utilizar o método
                   nativo de cálculo de tamanho de texto.
        oFontCabec Objeto da fonte que será utilizada no cabeçalho.
        oFont      Objeto da fonte que será utilizada na impressão.

@return aTamCol  Array contendo os tamanhos das colunas baseados nos
                 valores.
/*/
//-----------------------------------------------------------------------
Static Function RetTamCol(aCabec, aValores, oPrinter, oFontCabec, oFont)
	
	Local aTamCol    := {}
	Local nAux       := 0

	Local nX         := 0
	Local nY         := 0
	                          
	Local oFontSize	 := FWFontSize():new()
	
	For nX := 1 To Len(aCabec)
		
		aAdd(aTamCol, {})
		//aTamCol[nX] := Round(oPrinter:GetTextWidth(aCabec[nX], oFontCabec) * nConsNeg + 4, 0)
		aTamCol[nX] := oFontSize:getTextWidth( alltrim(aCabec[nX]), oFontCabec:Name, oFontCabec:nWidth, oFontCabec:Bold, oFontCabec:Italic )
		
	Next nX
	
	For nX := 1 To Len(aValores[1])
		
		nAux := 0
		
		For nY := 1 To Len(aValores[1][nX])
			
			If (oPrinter:GetTextWidth(aValores[1][nX][nY], oFont) * nConsTex) > nAux
				//nAux := Round(oPrinter:GetTextWidth(aValores[1][nX][nY], oFont) * nConsTex + 4, 0)
				nAux := oFontSize:getTextWidth( Alltrim(aValores[1][nX][nY]), oFontCabec:Name, oFontCabec:nWidth, oFontCabec:Bold, oFontCabec:Italic )
			EndIf
			
		Next nY
		
		If aTamCol[nX] < nAux
			aTamCol[nX] := nAux
		EndIf
		
	Next nX
	
	// Checa se os campos completam a página, senão joga o resto na coluna da
	//   descrição de produtos/serviços
	nAux := 0
	For nX := 1 To Len(aTamCol)
		
		nAux += aTamCol[nX]
		
	Next nX
	If nAux < 603
		aTamCol[2] += 603 - nAux
	EndIf                       
	If nAux > 603               
		aTamCol[2] -= nAux - 603 
	EndIf
	
Return aTamCol

//-----------------------------------------------------------------------
/*/{Protheus.doc} RetTamTex
Retorna o tamanho em pixels de uma string. (Workaround para o GetTextWidth)

@author Marcos Taranta
@since 24/05/2011
@version 1.0 

@param  cTexto   Texto a ser medido.
        oFont    Objeto instanciado da fonte a ser utilizada.
        oPrinter Objeto de impressão instanciado.

@return nTamanho Tamanho em pixels da string.
/*/
//-----------------------------------------------------------------------
Static Function RetTamTex(cTexto, oFont, oPrinter)
	
	Local nTamanho := 0
	Local oFontSize:= FWFontSize():new() 
	
	//nTamanho := oPrinter:GetTextWidth(cTexto, oFont)
	nTamanho := oFontSize:getTextWidth( cTexto, oFont:Name, oFont:nWidth, oFont:Bold, oFont:Italic )
	
  	nTamanho := Round(nTamanho, 0)
	
Return nTamanho
