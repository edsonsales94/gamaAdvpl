#include "Protheus.ch"
#include "Rwmake.ch"
#include "Topconn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RFATI02  ³ Autor ³ Wilson Cruz - Totvs    ³ Data ³ 24.02.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Programa para importacao de documentos de entrada           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Brasitech                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Data      ³ Programador   ³ Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 21.05.09 ³ Wilson Cruz   ³ Alteracao do Layout, inclusao de validacao  ³±±
±±³          ³               ³ de duplicidades de registros tipo "L".      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³ 1.) Alteracao do Layout, registro tipo "L"  ³±±
±±³          ³               ³     foi excluido do layout.                 ³±±
±±³          ³               ³ 2.) Inclusao de validacao se a nota ja      ³±±
±±³ 28.05.09 ³ Wilson Cruz   ³     existe, antes estava validando pela     ³±±
±±³          ³               ³     execauto.                               ³±±
±±³          ³               ³ 3.) Inclusao de do total da nota com o      ³±±
±±³          ³               ³     o valor informado no registro "R".      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function RFATI02()

Local cOperador := ""

If MsgBox("Confirma importacao de dados Op. Panalpina?","Atencao","YESNO")
	MsAguarde({|| RFATI02_A()},"Aguarde...","Processando...",.T.)
	Aviso("Aviso","Processamento Concluido",{"Ok"})
Else
	Aviso("Aviso","Processamento Cancelado",{"Ok"})
Endif


Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ RFATI02_A   ³ Autor ³ Wilson Cruz - Totvs   ³ Data ³ 24/02/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Seleciona arquivos a serem importados                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Brasitech 						        				     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static function RFATI02_A()

Local   _nY        := 0
Private _cArq
Private _cPathErro := Getmv("MV_X_PATED")+"LOGS\"
Private _cDirNImp  := Getmv("MV_X_PATED")
Private _cDirImp   := Getmv("MV_X_PATED")+"IMPORTADOS\
Private _cTesEDI   := Getmv("MV_X_TESED")
Private _aInclui   := {}

// Obtem todos os arquivo a serem importados
_aInclui := Directory(Alltrim(_cDirNImp)+"*.TXT")

For _nY := 1 to Len(_aInclui)
	// Obtem o proximo arquivo a ser importado.
	_cArq := _aInclui[_nY][1]
	// Se o tamanho do arquivo for maior que zero importa,
	// caso contrario somente transfere do diretorio de arquivos
	// a importar para o diretorio de arquivos ja importados.
	If _aInclui[_nY][2] > 0
		RFATI02_B(_cArq)
	Endif
	// Transfere o arquivo para o diretorio de arquivo
	// importados e importa o proximo se existir.
	If File(_cDirNImp+_aInclui[_nY][1])
		Copy File (_cDirNImp+_aInclui[_nY][1]) To (_cDirImp+_aInclui[_nY][1])
		FErase(_cDirNImp+_aInclui[_nY][1])
	EndIf
Next _nY
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ RFATI02_B   ³ Autor ³ Wilson Cruz - Totvs   ³ Data ³ 24/02/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Le as notas dos selecionados a serem importados               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Brasitech 						        				     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RFATI02_B(_carq)
Local _cBuff  			:= ""
Local _cDoc   			:= ""
Local _cSerie 			:= ""
Local _dEmis  			:= Ctod("")
Local _cReg   			:= ""
Local _cForn			:= GETMV("MV_XFOREDI")
Local _cLoja			:= GETMV("MV_XLOJEDI")
Local _nI 				:= 0
Local _nQtd				:= 0
Local _cProd			:= ""
Local _aProd			:= {}
Local _aCabNF			:= {}
Local _aItensNF			:= {}
Local _aItmNF			:= {}
Local _cItem			:= ""
Local _aOcor			:= {}
Local _nTotNf			:= 0
Local _nTotItem			:= 0
Local _nItem			:= 0
Local _aItens			:= {}
Local _cChaveNF			:= ""
Private lMsErroAuto		:= .F.
Private lMsHelpAuto		:= .T.
Private lAutoErrNoFile	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre arquivo com documentos de entrada a serem importados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ft_fuse(_cDirNImp+_cArq)
ft_fgotop()
While !ft_feof()

    // Volta a Data Base Original //

//    dDatabase := dDatOrig
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o registro eh tipo 'N'                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cBuff  := ft_freadln()
	_cReg   := Substr(_cBuff,001,001)
	If _cReg <> "N"
		ft_fskip()
		Loop
	Endif
	
	_cSerie := Substr(_cBuff,002,003)
	_cDoc   := Substr(_cBuff,005,006)
	_dEmis  := Ctod(Substr(_cBuff,021,002)+"/"+Substr(_cBuff,023,002)+"/"+Substr(_cBuff,025,004))
	_nTotNf	:= Val(Substr(_cBuff,041,008))+(Val(Substr(_cBuff,050,002))/100)
	_cChaveNF := Substr(_cBuff,052,044)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se a nota ja foi digitada                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SF1")
	dbSetOrder(1)
	If DbSeek(xFilial("SF1")+_cDoc+Space(9-Len(_cDoc))+_cSerie+_cForn+_cLoja)
		Aadd(_aOcor,{_cDoc,"Rejeitada - NF ja existe"})
		ft_fskip()
		Loop
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o registro eh tipo 'I'                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ft_fskip()	//	Posiciona no item do documento de saida
	_cBuff  := ft_freadln()
	_cReg   := Substr(_cBuff,001,001)
	If _cReg <> "I"
		ft_fskip()
		Loop
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa variaveis                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_nTotItem := 0
	_aItens	:= {}
	_aCabNF		:= {}
	_aItensNF	:= {}
	_aItmNF		:= {}
//	dDatabase   := _dEmis
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera o array de cabecalho da nota fiscal                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Aadd(_aCabNF, {"F1_TIPO"	,"B"	,Nil}) // Alterado por Cristiano em 18/03 devido as Remessas serem do Tipo Normal ( Cliente ) , Desta forma o Retorno deverá ser do Tipo B para que na entrada seja solicitado o Cliente e não o FOrnecedor
	Aadd(_aCabNF, {"F1_FORMUL"	,"N"	,Nil})
	Aadd(_aCabNF, {"F1_DOC"		,_cDoc	,Nil})
	Aadd(_aCabNF, {"F1_SERIE"	,_cSerie,Nil})
	Aadd(_aCabNF, {"F1_EMISSAO"	,_dEmis	,Nil})
	Aadd(_aCabNF, {"F1_FORNECE"	,_cForn	,Nil})
	Aadd(_aCabNF, {"F1_LOJA"	,_cLoja	,Nil})
	Aadd(_aCabNF, {"F1_ESPECIE"	,"SPED"	,Nil})
	Aadd(_aCabNF, {"F1_CHVNFE"	,_cChaveNF	,Nil})
	
	_nItem := 1
	While !ft_feof() .and. Substr(_cBuff,001,001) == "I"

//		_cItem   := Substr(_cBuff,011,004)
		_cProd   := Alltrim(Substr(_cBuff,015,025))
		_nQtd    := Val(Substr(_cBuff,045,009))
		_nPrUnit := Val(Substr(_cBuff,054,007)+Substr(_cBuff,062,003))/1000
		_cNfOri  := StrZero(Val(Substr(_cBuff,065,010)),9)
		_aOrigem := Aclone(RFATI02_C(_cProd,_cNfOri,_cForn,_cLoja))
		
		DbSelectArea("SB1")
		_aProd := GetAdvFVal("SB1",{"B1_LOCPAD","B1_UM"},xFilial("SB1")+_cProd,1)
//		Aadd(_aItens,{_cItem,_cProd,_nQtd,_nPrUnit,_nQtd*_nPrUnit,_aOrigem[1][1],_aOrigem[1][2],_aOrigem[1][3],_aOrigem[1][4],_aOrigem[1][6],_aProd[2]})
		Aadd(_aItens,{StrZero(_nItem,4),_cProd,_nQtd,_nPrUnit,_nQtd*_nPrUnit,_aOrigem[1][1],_aOrigem[1][2],_aOrigem[1][3],_aOrigem[1][4],_aOrigem[1][6],_aProd[2]})
		_nTotItem += _nQtd*_nPrUnit
		ft_fskip()
		_cBuff := ft_freadln()
		_nItem++
	End
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se total dos itens eh igual ao total da nota     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If _nTotItem == _nTotNf
		For _nI := 1 To Len(_aItens)
			Aadd(_aItmNF, {"D1_ITEM"	,_aItens[_nI,01]	,Nil})
			Aadd(_aItmNF, {"D1_COD"		,_aItens[_nI,02]	,Nil})
			Aadd(_aItmNF, {"D1_UM"		,_aItens[_nI,11]	,Nil})
			Aadd(_aItmNF, {"D1_LOCAL"	,_aItens[_nI,10]	,Nil})
			Aadd(_aItmNF, {"D1_QUANT"	,_aItens[_nI,03]	,Nil})
			Aadd(_aItmNF, {"D1_VUNIT" 	,_aItens[_nI,04]	,Nil})
			Aadd(_aItmNF, {"D1_TOTAL"	,_aItens[_nI,05]	,Nil})
			Aadd(_aItmNF, {"D1_TES"		,_cTesEDI			,Nil})
			Aadd(_aItmNF, {"D1_EMISSAO"	,_dEmis				,Nil})
			Aadd(_aItmNF, {"D1_NFORI"	,_aItens[_nI,06]	,Nil})
			Aadd(_aItmNF, {"D1_SERIORI"	,_aItens[_nI,07]	,Nil})
			Aadd(_aItmNF, {"D1_ITEMORI"	,_aItens[_nI,08]	,Nil})
			Aadd(_aItmNF, {"D1_IDENTB6"	,_aItens[_nI,09]	,Nil})
			aAdd(_aItensNF,_aItmNF)
			_aItmNf := {}
		Next _nI
		_aItens := {}
		Begin Transaction
		If Len(_aItensNF) > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava a nota fiscal de entrada                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lMsErroAuto := .F.
			MsgRun("Incluindo Nota de Entrada  "+_cDoc,"Aguarde...",{|| MSExecAuto({|x,y,z| MATA103(x,y,z)},_aCabNF,_aItensNF,3)})
			
			If lMsErroAuto
				DisarmTransaction()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava o log da ocorrencia                                              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				_nTime := Time()
				_nTime := Strtran(time(),":","")
				_nTime := SubStr(_nTime,1,6)
				_cFile := 'REJ_'+Dtos(dDatabase)+"_"+_nTime+".log"
				MostraErro(_cPathErro,_cFile)
				Aadd(_aOcor,{_cDoc,"Rejeitada"})
			Else
				Aadd(_aOcor,{_cDoc,"Importada"})
			Endif
		EndIf
		End Transaction
	Else
		If Ascan(_aOcor,{|X|X[1] == "Rejeitada - Total NF divergente do total dos itens "+STRZERO(_nTotItem)+" - Total NF"+StrZero(_nTotNf)}) = 0
			Aadd(_aOcor,{_cDoc,"Rejeitada - Total NF divergente do total dos itens"})
		Endif
	Endif
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apresenta log de importacao sintetico                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RFATI02_D(_aOcor)
ft_fuse()
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ RFATI02_C   ³ Autor ³ Wilson Cruz - Totvs   ³ Data ³ 24/02/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna dados origem que nao estao no arquivo texto           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Brasitech 						        				     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RFATI02_C(_cCodP,_cDoc,_cForn,_cLoja)
Local _cQuery := ""
Local _aRet := {}

_cArqQry:= GetNextAlias()
_cQuery := " SELECT D2_DOC,D2_SERIE,D2_ITEM,D2_IDENTB6,B6_SALDO,B6_LOCAL"
_cQuery += " FROM "+RetSqlName("SD2")+" D2 INNER JOIN "+RetSqlName("SB6")+" B6 ON B6_DOC = D2_DOC"
_cQuery += " AND B6_SERIE = D2_SERIE AND B6_PRODUTO = D2_COD AND B6_CLIFOR = D2_CLIENTE"
_cQuery += " AND B6_LOJA = D2_LOJA AND B6_IDENT = D2_IDENTB6"
_cQuery += " WHERE D2_FILIAL = '"+xFilial("SD2")+"'"
_cQuery += " AND D2_DOC = '"+_cDoc+"'"
_cQuery += " AND D2_COD = '"+_cCodP+"'"
_cQuery += " AND D2_CLIENTE = '"+_cForn+"'"
_cQuery += " AND D2_LOJA = '"+_cLoja+"'"
_cQuery += " AND B6_SALDO > 0"
_cQuery += " AND B6.D_E_L_E_T_ = ''"
_cQuery += " AND D2.D_E_L_E_T_ = ''"
_cQuery := ChangeQuery(_cQuery)
dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cArqQry,.F.,.T.)
DbSelectArea(_cArqQry)
If !Eof()
	While !Eof()
		Aadd(_aRet,{&(_cArqQry+"->D2_DOC"),&(_cArqQry+"->D2_SERIE"),&(_cArqQry+"->D2_ITEM"),&(_cArqQry+"->D2_IDENTB6"),&(_cArqQry+"->B6_SALDO"),&(_cArqQry+"->B6_LOCAL")})
		DbSkip()
	End
Else
//	Aadd(_aRet,{"","","","",0})
	Aadd(_aRet,{"","","","",0,""}) // Alterado por Cristiano em 02/06/09
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga arquivo temporario                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select(_cArqQry) > 0
	dbselectArea(_cArqQry)
	dbCloseArea()
EndIf

Return(_aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ RFATI02_D   ³ Autor ³ Wilson Cruz - Totvs   ³ Data ³ 25/02/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe Log de importacao                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Brasitech 						        				     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RFATI02_D(_cOcor)
Local _cFileLog := ""
Local _cPath := "" 
Local _nI

AutoGrLog("Importacao Notas Entrada")
AutoGrLog("-----------------------------")
AutoGrLog("Documento    Status")

For _nI := 1 To Len(_cOcor)
	AutoGrLog(_cOcor[_nI][1]+"          "+_cOcor[_nI][2])
Next _nI

AutoGrLog("")
AutoGrLog("Para maiores detalhes das notas")
AutoGrLog("rejeitadas, consulte arquivo de Log.")

_cFileLog := NomeAutoLog()

If _cFileLog <> ""
	MostraErro(_cPath,_cFileLog)
Endif

Return