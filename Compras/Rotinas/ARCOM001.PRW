#Include "Protheus.Ch"
#Include "Rwmake.Ch"
#Include "TBIconn.Ch"
#Include "FileIO.Ch"
#Define ENTER CHR(13)+CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณARCOM001  บAutor  ณAndres Demarziani   บFecha ณ  04/21/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Programa de importacion de Pedidos de compras.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ P10 - Arimex                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function ARCOM001
Local oCombo	:=''
Private cCombo := ""

Private oDlg
Private aCombo := { '1- Nacional','2- importacion'}
@ 000,000 TO 180,380 DIALOG oDlg TITLE OemToAnsi("Importacion de pedidos de compras")
@ 003,003 TO 088,188
@ 010,018 Say "Este programa tiene como objetivo importar uno o mas pedidos"
@ 025,018 Say "de compras desde un archivo *.csv"
@ 055,008 say Oemtoansi("Tipo de Pedido: ") size 050,020 of  oDlg PIXEL
@ 055,060 COMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 050, 010 PIXEL OF oDlg
@ 070,128 BMPBUTTON TYPE 01 ACTION MsAguarde({|| fImportaPedido(),"Procesando. Hora de inicio: " + Time()})
@ 070,158 BMPBUTTON TYPE 02 ACTION oDlg:End()

Activate Dialog oDlg Centered

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณARCOM001  บAutor  ณAndres Demarziani   บFecha ณ  04/21/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 10                                                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fImportaPedido()

Local cTabla		:= ""
Local cStrCpos		:= ""
Local nX			:= 1
Local cTitulo1  	:= "Seleccione Archivo"
Local cExtens   	:= "Archivo | "

Local aArchi		:= {}

Local cLinea		:= ""
Local cCampo		:= ""
Local cNumPed		:= ""
Local cNumAux		:= ""
Local cCposCab		:= "C7_NUM/C7_EMISSAO/C7_FORNECE/C7_LOJA/C7_COND/C7_CONTATO/C7_FILENT/C7_FILIAL/C7_MOEDA/C7_TXMOEDA"
Local lFirst		:= .T.
Local lGrabCab		:= .T.
Local aVals			:= {}
Local aCpos			:= {}

Local cHoraIni		:= Time()

Local nCantReg		:= 0
Local cProxReg		:= ""

Local cFileLog		:= ""
Local cDirLog		:= ""
Local cPath			:= ""

Local lError		:= .F.
Local nCantReg		:= 0
Local lFin			:= .F.
Local aCab			:= {}
Local aTotCabs		:= {}
Local aItem			:= {}
Local aItAux		:= {}
Local aTotItems		:= {}
Local xVal
Private _cTipo		:= Substr(cCombo,1,1)
private _aNumGer 	:= {}
Private cFile 		:= ""
Private lMSHelpAuto := .T. //.F. // para nao mostrar os erro na tela
Private lMSErroAuto := .F. //.F. // inicializa como falso, se voltar verdadeiro e' que deu erro

/***
* _________________________________________________________
* cGetFile(<ExpC1>,<ExpC2>,<ExpN1>,<ExpC3>,<ExpL1>,<ExpN2>)
* ฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏ
* <ExpC1> - Expressao de filtro
* <ExpC2> - Titulo da janela
* <ExpN1> - Numero de mascara default 1 para *.Exe
* <ExpC3> - Diret๓rio inicial se necessแrio
* <ExpL1> - .F. botใo salvar - .T. botใo abrir
* <ExpN2> - Mascara de bits para escolher as op็๕es de visualiza็ใo do objeto (prconst.ch)
*/
If _cTipo	== '2' // si es del exterior
	cCposCab		:= "C7_NUM/C7_EMISSAO/C7_FORNECE/C7_LOJA/C7_COND/C7_CONTATO/C7_FILENT/C7_FILIAL/C7_MOEDA/C7_TXMOEDA/C7_NATUREZ/C7_IMPORT/C7_COMPRA/C7_CONSIG/C7_EXPORTA/C7_DESP"
	cCposCab		+= "C7_AGENTE/C7_FORWARD/C7_TIPO_EM/C7_ORIGIMP/C7_DEST/C7_INCOTER/C7_CONTAIN/C7_PESO_B/C7_MT3/C7_CONTA20/C7_CONTA40/C7_CON40HC/C7_ARMAZEM/C7_DT_IMP"
EndIf
cExtens += "*.CSV"
cFile := cGetFile(cExtens,cTitulo1,,,.T.)

If _cTipo	== '2' // si es del exterior
	fImportaSI()
EndIf
If File( cFile )
	
	AutoGrLog( "Fecha Inicio.......: " + DToC(MsDate()) )
	AutoGrLog( "Hora Inicio........: " + Time() )
	AutoGrLog( "Environment........: " + GetEnvServer() )
	AutoGrLog( "Archivo............: " + Alltrim( Lower( cFile ) ) )
	AutoGrLog( " " )
	
	FT_FUse(cFile)
	FT_FGotop()
	
	cLinea	:= FT_FREADLN()
	aCpos	:= Str2Array(cLinea,';')
	
	FT_FSkip()
	
	While (!FT_FEof() .And. !lFin)
		
		cLinea	:= FT_FREADLN()
		aVals	:= Str2Array(cLinea,';')
		nCantReg++
		
		dbSelectArea("SX3")
		dbSetOrder(2)
		For nX := 1 To Len(aVals)
			cCampo := AllTrim(aCpos[nX])
			If  SX3->(dbSeek(Padr(cCampo,10)) )
				xVal 	:= UPPER(Alltrim(aVals[nX]))
				lError 	:= Len(xVal)>X3_TAMANHO
				
				If lError
					AutoGrLog( aVals[1] + " - Linea Nro: "+cValToChar(nCantReg)+". El valor del campo "+cCampo+" Excede el tamano del diccionario." )
					Exit
				Else
					If cCampo=="C7_NUM"
						If cNumAux != xVal
							cNumAux := xVal
							cNumPed	:= GetNumSC7()
							lGrabCab:= .T.
							If lFirst
								lFirst := .F.
							Else
								aAdd(aTotCabs,aCab)
								aAdd(aTotItems,aItem)
								aCab 	:= {}
								aItem 	:= {}
							EndIf
						Else
							lGrabCab:= .F.
						EndIf
					EndIf
					
					Do Case
						Case X3_TIPO == "N"
							xVal := Val(xVal)
						Case X3_TIPO == "D"
							xVal := CToD(xVal)
						Case X3_TIPO == "C"  // si es caracter
							xVal := padr(Alltrim(xVal),tamSX3(X3_CAMPO)[1])
					EndCase
					
					If cCampo $ cCposCab
						If lGrabCab
							If cCampo=="C7_NUM"
								aAdd(aCab,{cCampo,cNumPed,NIL})
							Else
								aAdd(aCab,{cCampo,xVal,NIL})
							EndIf
						EndIf
					Else
						aAdd(aItAux,{cCampo,xVal,NIL})
					EndIf
				EndIf
			Else
				lFin := .T.
				AutoGrLog( "El campo "+cCampo+" no se encuentra en el diccionario de datos." )
				Exit
			EndIf
		Next nX
		If _cTipo =='2'
		if len(_anumger) > 0
			aAdd(aItAux,{"C7_NUMSC",_anumger[aScan(_aNumGer,{|x| Trim(x[2])==cNumAux})][1],NIL})
			aAdd(aItAux,{"C7_ITEMSC",aItAux[1][2],NIL})
			aAdd(aItAux,{"C7_FISCORI",xFILIAL("SC1"),NIL})

		EndIf
		eNDiF
		aAdd(aItem,aClone(aItAux))
		aItAux := {}
		
		If lError
			aCab  := {}
			aItem := {}
			FT_FSkip()
			Loop
		EndIf
		
		If lFin
			Loop
		EndIf
		
		FT_FSkip()
	EndDo
	
	// Agrego el ultimo Pedido que no llegue a agregar
	If !lError
		aAdd(aTotCabs,aCab)
		aAdd(aTotItems,aItem)
		aCab 	:= {}
		aItem 	:= {}
		
		For nX := 1 To Len(aTotCabs)
			lMSErroAuto := .F.
			If _cTipo <> '2'
				MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},1,aTotCabs[nX],aTotItems[nX],3)
			Else
				MSExecAuto({|v,x,y,z| MATA123(v,x,y,z)},aTotCabs[nX],aTotItems[nX],3,.f.)
			EndIf
			If lMSErroAuto
				RollBackSx8()
				DisarmTransaction()
				MostraErro()
			Else
				ConfirmSX8()
				AutoGrLog( "Pedido generado Nro.: " + aTotCabs[nX][1][2] )
			EndIf
		Next
	EndIf
EndIf

AutoGrLog( "  " )
AutoGrLog( "Fecha Fin...........: " + Dtoc(MsDate()) )
AutoGrLog( "Hora Fin............: " + Time() )
AutoGrLog( "Registros Procesados: " + cValToChar(nCantReg) )

cFileLog := NomeAutoLog()

If cFileLog <> ""
	nX := 1
	While .T.
		If File( Lower( cDirLog + Dtos( MSDate() ) + StrZero( nX, 3 ) + '.log' ) ) // El directorio debe estar creado en el servidor bajo DATA
			nX++
			If nX == 999
				Exit
			EndIf
			Loop
		Else
			Exit
		EndIf
	EndDo
	__CopyFile( cPath + Alltrim( cFileLog ), Lower( cDirLog + Dtos( MSDate() ) + StrZero( nX, 3 ) + '.log' ) )
	MostraErro(cPath,cFileLog)
	FErase( cFileLog )
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunciขn     ณ          ณ Autor ณ                     ณ Data ณ          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescripciขn ณ                                                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso        ณ                                                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function Str2Array(cString,cSep)

Local aReturn := { },;
cAux    := cString,;
nPos    := 0

While At( cSep, cAux ) > 0
	nPos  := At( cSep, cAux )
	cVal  := SubStr( cAux, 1, nPos-1 )
	Aadd( aReturn,  cVal )
	cAux  := SubStr( cAux, nPos+1 )
EndDo

Aadd(aReturn,cAux)

Return(aReturn)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณARCOM002  บAutor  ณAndres Demarziani   บFecha ณ  04/21/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 10  - importa SI                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fImportaSI()

Local cTabla		:= ""
Local cStrCpos		:= ""
Local nX			:= 1
Local cTitulo1  	:= "Seleccione Archivo"
Local cExtens   	:= "Archivo | "
Local aArchi		:= {}

Local cLinea		:= ""
Local cCampo		:= ""
Local cNumPed		:= ""
Local cNumAux		:= ""
Local cCposCab		:= "C1_NUM/C1_EMISSAO/C1_SOLICIT/C1_EMISSAO/C1_UNIDREQ/C1_CODCOMP/C1_FILENT/C1_NATUREZ/C1_TIPO/C1_SIGLA/C1_MOEDA/C1_SOLICIT"
Local lFirst		:= .T.
Local lGrabCab		:= .T.
Local aVals			:= {}
Local aCpos			:= {}

Local cHoraIni		:= Time()

Local nCantReg		:= 0
Local cProxReg		:= ""

Local cFileLog		:= ""
Local cDirLog		:= ""
Local cPath			:= ""

Local lError		:= .F.
Local nCantReg		:= 0
Local lFin			:= .F.
Local aCab			:= {}
Local aTotCabs		:= {}
Local aItem			:= {}
Local aItAux		:= {}
Local aTotItems		:= {}
Local xVal

Private lMSHelpAuto := .T. //.F. // para nao mostrar os erro na tela
Private lMSErroAuto := .F. //.F. // inicializa como falso, se voltar verdadeiro e' que deu erro
PUBLIC L123DELETA := .f.
PUBLIC L120DELETA := .f.
PUBLIC L120altera := .f.
PUBLIC L120inclui := .t.


/***
* _________________________________________________________
* cGetFile(<ExpC1>,<ExpC2>,<ExpN1>,<ExpC3>,<ExpL1>,<ExpN2>)
* ฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏฏ
* <ExpC1> - Expressao de filtro
* <ExpC2> - Titulo da janela
* <ExpN1> - Numero de mascara default 1 para *.Exe
* <ExpC3> - Diret๓rio inicial se necessแrio
* <ExpL1> - .F. botใo salvar - .T. botใo abrir
* <ExpN2> - Mascara de bits para escolher as op็๕es de visualiza็ใo do objeto (prconst.ch)
*/

//cExtens += "*.CSV"
//cFile := cGetFile(cExtens,cTitulo1,,,.T.)

If File( cFile )
	
	AutoGrLog( "Fecha Inicio.......: " + DToC(MsDate()) )
	AutoGrLog( "Hora Inicio........: " + Time() )
	AutoGrLog( "Environment........: " + GetEnvServer() )
	AutoGrLog( "Archivo............: " + Alltrim( Lower( cFile ) ) )
	AutoGrLog( " " )
	
	FT_FUse(cFile)
	FT_FGotop()
	
	cLinea	:= FT_FREADLN()
	aCpos	:= Str2Array(cLinea,';')
	
	FT_FSkip()
	
	While (!FT_FEof() .And. !lFin)
		
		cLinea	:= FT_FREADLN()
		aVals	:= Str2Array(cLinea,';')
		nCantReg++
		
		dbSelectArea("SX3")
		dbSetOrder(2)
		For nX := 1 To Len(aVals)
			cCampo := "C1"+SubStr(AllTrim(aCpos[nX]),3,Len(aCpos[nx]))
			
			If  SX3->(dbSeek(Padr(cCampo,10)))  			.AND. cCampo <> "C1_IMPORT"
				xVal 	:= UPPER(Alltrim(aVals[nX]))
				
				/*
				If Posicione("SB1",1,Xfilial("SB1")+avals[6],"B1_IMPORT") == 'S' .and. avals[11] <> '2'
				lerror	:= .t.
				AutoGrLog( aVals[1] + " - Linea Nro: "+cValToChar(nCantReg)+". El Producto Ingresado es importado Pero El Tipo de solicitud no es de imporaction" )
				Exit
				EndIf
				*/
				NPosCod := aScan(acPOS,{|x| Alltrim(Substr(x,4,15))=="PRODUTO"})
				NPosSIG := aScan(acPOS,{|x| Alltrim(Substr(x,4,15))=="SIGLA"})
				NPosDBD := aScan(acPOS,{|x| Alltrim(Substr(x,4,15))=="DEST"})
				If ! SB1->(dbseek(xFILIAL("SB1")+avals[NPosCod]))
					lerror	:= .t.
					AutoGrLog( aVals[1] + " - Linea Nro: "+cValToChar(nCantReg)+". El Producto Ingresado no Existe" )
					Exit
				EndIf
				If NPosDBD <> 0 
				 dbd->(DBSETORDER(1))
					IF !DBD->(dbseek(xfilial("DBD") + padr(avals[NPosDBD],TAMSX3("DBD_COD")[1])) ) // SI NO EXSTA EN DBD
						lerror	:= .t.
					AutoGrLog( aVals[1] + " - Linea Nro: "+cValToChar(nCantReg)+". El destino Ingresado no Existe" )
				    eNDiF
				EndIf
				If Posicione("SB1",1,Xfilial("SB1")+avals[NPosCod],"B1_IMPORT") <> 'S' .and. _cTipo <> '1'
					lerror	:= .t.
					AutoGrLog( aVals[1] + " - Linea Nro: "+cValToChar(nCantReg)+". El Producto Ingresado no es importado Pero El Tipo de solicitud  es de imporaction" )
					Exit
				EndIf
				If Posicione("SB1",1,Xfilial("SB1")+avals[NPosCod],"B1_IMPORT") == 'S' .and. _cTipo == '2'
					if Empty(aVals[NPosSIG])
						lerror	:= .t.
						AutoGrLog( aVals[1] + " - Linea Nro: "+cValToChar(nCantReg)+". El Producto Ingresado es importado Pero El Campo Lugar de entrega esta vacio" )
						Exit
					ELSEiF !DB4->(dbseek(Xfilial("SB4")+padr(Avals[NPosSIG],2," ")))
						lerror	:= .t.
						AutoGrLog( aVals[1] + " - Linea Nro: "+cValToChar(nCantReg)+". El Campo Lugar de entrega no es valido ")
						Exit
						
					EndIf
				EndIf
				
				If !lError .AND. SX3->(dbSeek(Padr(cCampo,10)) )
					lError	:= Len(xVal)>X3_TAMANHO
					
					
					If lError
						AutoGrLog( aVals[1] + " - Linea Nro: "+cValToChar(nCantReg)+". El valor del campo "+cCampo+" Excede el tamano del diccionario." )
						Exit
					Else
						If cCampo=="C1_NUM"
							If cNumAux != xVal
								
								_CnUMA1	:= xVal
								
								cNumAux := xVal
								cNumPed	:= GetNumSC1()
								AADD(_aNumGer,{cNumPed,_CnUMA1})
								lGrabCab:= .T.
								If lFirst
									lFirst := .F.
								Else
									aAdd(aTotCabs,aCab)
									aAdd(aTotItems,aItem)
									aCab 	:= {}
									aItem 	:= {}
								EndIf
							Else
								lGrabCab:= .F.
							EndIf
						EndIf
						
						Do Case
							Case X3_TIPO == "N"
								xVal := Val(xVal)
							Case X3_TIPO == "D"
								xVal := CToD(xVal)
						EndCase
						
						If cCampo $ cCposCab
							If lGrabCab
								If cCampo=="C1_NUM"
									aAdd(aCab,{cCampo,cNumPed,NIL})
								Else
									aAdd(aCab,{cCampo,xVal,NIL})
								EndIf
							EndIf
						Else
							aAdd(aItAux,{cCampo,xVal,NIL})
						EndIf
					EndIf
				EndIF
			EndIf
			
		Next nX
		
		aAdd(aItem,aClone(aItAux))
		aItAux := {}
		
		If lError
			aCab  := {}
			aItem := {}
			FT_FSkip()
			Loop
		EndIf
		
		If lFin
			Loop
		EndIf
		
		FT_FSkip()
	EndDo
	
	// Agrego el ultimo Pedido que no llegue a agregar
	If !lError
		aAdd(aTotCabs,aCab)
		aAdd(aTotItems,aItem)
		aCab 	:= {}
		aItem 	:= {}
		
		For nX := 1 To Len(aTotCabs)
			lMSErroAuto := .F.
			MSExecAuto({|x,y| MATA113(x,y)},aTotCabs[nX],aTotItems[nX])
			
			If lMSErroAuto
				RollBackSx8()
				DisarmTransaction()
				MostraErro()
			Else
				//				ConfirmSX8()
				_cNumAnt	:= aTotCabs[nX][1][2]
				_aArea	:= Getarea()
				Dbselectarea("SC1")
				dbsetorder(1)
				
				dbseek(Xfilial("SC1")+aTotCabs[nX][1][2])
				RestArea(_aARea)
				AutoGrLog( "Solicitud generada Nro.: " + aTotCabs[nX][1][2] )
				//
			EndIf
		Next
	EndIf
EndIf

AutoGrLog( "  " )
AutoGrLog( "Fecha Fin...........: " + Dtoc(MsDate()) )
AutoGrLog( "Hora Fin............: " + Time() )
AutoGrLog( "Registros Procesados: " + cValToChar(nCantReg) )

cFileLog := NomeAutoLog()

If cFileLog <> ""
	nX := 1
	While .T.
		If File( Lower( cDirLog + Dtos( MSDate() ) + StrZero( nX, 3 ) + '.log' ) ) // El directorio debe estar creado en el servidor bajo DATA
			nX++
			If nX == 999
				Exit
			EndIf
			Loop
		Else
			Exit
		EndIf
	EndDo
	__CopyFile( cPath + Alltrim( cFileLog ), Lower( cDirLog + Dtos( MSDate() ) + StrZero( nX, 3 ) + '.log' ) )
	MostraErro(cPath,cFileLog)
	FErase( cFileLog )
EndIf

Return
