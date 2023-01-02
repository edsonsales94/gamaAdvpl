#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RWMAKE.CH"

#DEFINE FBLOCK 1024
#DEFINE CRLF CHR(13)+CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIMPPROD บAutor  ณHernan Mu๑oz          บFecha ณ  11/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Importacion de Maestros de productos                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function ImpProd3()                              

Local cEdit1 := Space(255)
Local oEdit1
//Local cTabla := '001'
//Local oTabla
Local aButtons	:= {}
Private _oDlg
Private oGroup
Private lCrea := .F.   

Aadd( aButtons, {"GENERA",{|| U_IPROD2("",.T.) }, "Formato *.CSV.","Formato *.CSV"} ) 

DEFINE MSDIALOG _oDlg TITLE "Importar Productos" FROM 470,115 TO 600,550 PIXEL //464,196 TO 600,550 PIXEL

oGroup:= tGroup():New(2,3,51,216,,_oDlg,,,(.T.)) 

@ 008,010 Say "Este programa tiene como objetivo importar uno o mas Productos desde un " Size 200, 008 COLOR CLR_BLACK PIXEL OF _oDlg 
@ 016,010 Say "archivo *.csv" Size 200, 008 COLOR CLR_BLACK PIXEL OF _oDlg
@ 030,010 Say "Path de archivo a importar:" Size 065, 008 COLOR CLR_BLACK PIXEL OF _oDlg
@ 030,080 MsGet oEdit1 Var cEdit1 Size 104,008 COLOR CLR_BLACK PIXEL OF _oDlg
@ 031,190 Button "..." Size 016,012 PIXEL OF _oDlg Action {cEdit1 := cGetFile("Archivos CSV|*.CSV","Seleccione el archivo ",1,"",.T.,GETF_LOCALHARD)}
//@ 038,005 Say "Lista de precio :" Size 065, 008 COLOR CLR_BLACK PIXEL OF _oDlg
//@ 038,64 MsGet oTabla Var cTabla Size 024,008 F3 'DA0' COLOR CLR_BLACK PIXEL OF _oDlg

ACTIVATE MSDIALOG _oDlg CENTERED ON INIT EnchoiceBar(_oDlg, {|| U_IPROD2(cEdit1,.F.),_oDlg:End()},{||_oDlg:End()},,aButtons)

return(.T.)

User Function IProd2(cPathFile,lCrea)
Local aLog 		:= {}
Local aDados    := {}
Local cNomeArq 	:= Substr(cPathfile,Rat('\',cPathFile)+1)
Local cPathLog	:= Substr(cPathFile,1, Rat('\',cPathFile))
Local cNomeLog	:= ""
Local cBuffer	:= ""
//Local aArch	:= {}
Local aReg		:= {}
Local aArea		:=getarea()
Local nx		:=0
Local ny		:=0
Local nOpc      := 3
Local cLog		:=""
Local cQuery1	:=""
Local aCampos	:= {}
Local cAlias	:="QryZR2"
Local _lP10		:= "P10"  $ oApp:cVersion   // indica si es protheus 10  
Local cCodProv, cCodEfet, cClvGen, cAduBran , cDescProd, cXidws, cXingen2

Private lMsHelpAuto := .T.
Private lMsErroAuto := .f. 
Private cMsjError 
Private cLog

IF !lCrea
	ConOut("IMPPROD: Usuario procesando: " + cuserName)
	cNomeArq := Substr(cNomeArq,1,Rat('.',cNomeArq)-1)
	cNomeLog := cNomeArq +".log"
	cLog	:= cPathlog + cNomeLog    
	

	If !File( cPathFile )
		ConOut ("IMPPROD: 010 - No hay archivo del importacion - " + cPathFile)
		Return
	Else
		ConOut ("IMPPROD: Processando archivo - " + cPathFile)
	EndIf
	nHLog:=FCREATE(cLog, FC_NORMAL)
	If nHlog ==-1
		ConOut ("IMPPROD: 010 - No se puede crear el archivo de log " + str(ferror(),4), "Error")
		Return (.F.)
	Else
		ConOut ("IMPPROD: Creando archivo de Log - " + cLog)
	Endif
Endif

If _lp10
cQuery	:= "SELECT * FROM ZR2"+ GetNewPar("AR_EMPIMP","99")+"0 Where ZR2_CODEMP ='"+GetNewPar("AR_EMPIMP","99")+"' AND D_E_L_E_T_ <> '*' ORDER BY ZR2_ORDEN "   // traigo campos corporativos
Else                        

//entra a p11
cQuery    := "SELECT * FROM ZR2"+  cEmpAnt +"0 Where ZR2_CODEMP ='"+GetNewPar("AR_EMPIMP","99")+"' AND D_E_L_E_T_ <> '*' ORDER BY ZR2_ORDEN "   // traigo campos corporativos
EndIf
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), calias, .F., .T.)
ni	:= 0       

While !(cAlias)->(EOF())
	ni	++
 //	alert((calias)->ZR2_CAMPO) 
	AADD(aCampos,{(calias)->ZR2_CAMPO, ni})  //agrego nombre de  campo  y orden
	(cAlias)->(dbskip())
EndDo
(calias)->(dbclosearea())
If _lp10
cQuery	:= "SELECT * FROM  ZR2"+ GetNewPar("AR_EMPIMP","99")+"0  Where ZR2_CODEMP ='"+cEmpAnt+"' AND D_E_L_E_T_ <> '*' ORDER BY ZR2_ORDEN "   // traigo campos corporativos
Else 

cQuery	:= "SELECT * FROM  ZR2"+  cEmpAnt +"0  Where ZR2_CODEMP IN('01') AND D_E_L_E_T_ <> '*'  ORDER BY ZR2_ORDEN "   // traigo campos corporativos
EndIf                                     //   Where ZR2_CODEMP ='"+cEmpAnt+"' AND D_E_L_E_T_ <> '*'  ORDER BY ZR2_ORDEN "
cQuery := ChangeQuery(cQuery)

dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), calias, .F., .T.)
//ni	:= 0  

While !(cAlias)->(EOF())
	ni	++             
	 //alert((calias)->ZR2_CAMPO)
	AADD(aCampos,{(calias)->ZR2_CAMPO, ni})  //agrego nombre de  campo  y orden
	(cAlias)->(dbskip())
EndDo
(calias)->(dbclosearea())  

IF lCrea
	GeneraFormat(aCampos)
     Return
Endif

FT_FUSE(cPathFile )
FT_FGOTOP()
//FT_FSkip(1)

//Begin Transaction
	
	dbSelectArea("SB1")
	dbSetOrder(1) //Filial+codigo de producto
	While !FT_FEOF()
		cCodProv	:= ""
		cB1Cod	:= ""
		cBuffer	:= FT_FREADLN()
	//	aReg	:= STRTOKARR(cBuffer, ";") 
		aReg 	:= U_TXTTOARR(cBuffer, ";")
		aDados 	:= {} 
		
		 //MODIFCACIำN CHILE 16 - 10 - 2013
		IF len(aReg) <> len(aCampos) 
		        
			//MSGALERT("El Producto "+Alltrim(aReg[1])+" Tiene Error de Formato.","Error en Formato de CSV") 
			cMsjError:="El Producto "+Alltrim(aReg[1])+" Tiene Errores de Formato." 
			lMsErroAuto := .T.
									
		else
			for nx := 1 to len(aCampos)
				_aAreaSx3	:= SX3->(GetArea())
				SX3->(DBSETORDER(2))
				IF SX3->(DBSEEK(aCAmpos[nx][1]))
					If SX3->X3_TIPO == 'N'
						_xDato	:= val(aReg[aCAmpos[nx][2]])
					ElseIf SX3->X3_TIPO == 'D'
						_xDato	:= CTOD(aReg[aCAmpos[nx][2]])
					ElseIf SX3->X3_TIPO == 'C'
						_xDato	:= IIf(Empty(aReg[aCAmpos[nx][2]]),Space(1),alltrim(aReg[aCAmpos[nx][2]]))
					ElseIf SX3->X3_TIPO == 'L'
						_xDato	:= (If(aReg[aCAmpos[nx][2]] = ".T.",.T.,.F.))
					Endif
					
					SX3->(Restarea(_aAreaSX3))
					AADD(aDados,{aCAmpos[nx][1],_xDato,Nil})
					
					//———————————————————————————————————————————————————————————————————————————————
					// Alimento a variaveis para atualiza็ใo do cadastro
					//———————————————————————————————————————————————————————————————————————————————
					cCodEfet	:= iif(AllTrim(aCampos[nX,1]) == "B1_COD", _xDato, cCodEfet)
					cCodProv	:= iif(AllTrim(aCampos[nX,1]) == "B1_XCODPRV", _xDato, cCodProv)
					cClvGen		:= iif(AllTrim(aCampos[nX,1]) == "B1_XCLAGEN", _xDato, cClvGen)
					cAduBran	:= iif(AllTrim(aCampos[nX,1]) == "B1_XADUBR", _xDato, cAduBran)
					cDescProd	:= iif(AllTrim(aCampos[nX,1]) == "B1_DESC", _xDato, cDescProd)
					cXidws		:= iif(AllTrim(aCampos[nX,1]) == "B1_XIDWS", _xDato, cXidws)
					cXingen2	:= iif(AllTrim(aCampos[nX,1]) == "B1_XINGEN2", _xDato, cXingen2)
			
				eLSE
					MsgInfo("El CAMPO " +aCAmpos[nx][1] + " No se encuentra en el diccionario de datos se ha cancelado la importaci๓n")
					FINAL()
				EndIf
			Next
			
			//———————————————————————————————————————————————————————————————————————————————
			////MSExecAuto({|x,y|mata010(x,y)},aDados,nOpc)	
   		//MsAguarde({|| MSExecAuto({|x,y|mata010(x,y)},aDados,nOpc)},"AGUARDE","Generando Producto: "+aDados[1][2]  )
   		//
   		// Substitui็ใo do MSExecAuto para funcao de especifica de troca de codigo e 
   		// atualiza็ใo de dados.
   		// Por: Adalberto Moreno Batista (Op็ใo Um Consultoria) em 16/05/16
			//———————————————————————————————————————————————————————————————————————————————
			lMsErroAuto := .F.
			cMsjError	:= ""
			SB1->(dbSetOrder(1))								//B1_FILIAL, B1_COD
			if SB1->(dbSeek(xFilial("SB1") + cCodEfet))
				lMsErroAuto := .T.
				cMsjError	:= "C๓digo jแ existe na base " + cCodEfet
			else
				SB1->(dbOrderNickName("B1_XCODPRV"))	//B1_FILIAL, B1_XCODPRV
				if SB1->(dbSeek(xFilial("SB1") + cCodProv)) .and. SB1->B1_XSITUAC == "2"
					SB1->(RecLock("SB1",.F.))
					SB1->B1_COD		:= cCodEfet
					SB1->B1_DESC	:= cDescProd
					SB1->B1_XSITUAC	:= "3"
					SB1->B1_MSBLQL	:= "2"
					SB1->B1_XCLAGEN	:= cClvGen
					SB1->B1_XADUBR	:= cAduBran
					SB1->B1_XIDWS	:= cXidws
					SB1->B1_XINGEN2 := cXingen2
					SB1->B1_XFECHAL := date()
					SB1->B1_XUSER   := alltrim(cUserName)
					SB1->B1_XCODARI	:= cCodEfet
					SB1->(MsUnlock())
				else
					lMsErroAuto := .T.
					cMsjError	:= "C๓digo provis๓rio nใo localizado (B1_XCODPRV) ou produto nใo estแ aguardando retorno da Matriz (B1_XSITUAC)" + cCodProv
				endif
			endif
			
		endif  
		
		If lMsErroAuto 
			If Empty(cMsjError)
//				cMsjError:=Mostraerro() 
			Endif   
			nBytes := FWRITE(nHLog, "----------------------------------------------------------" + CRLF)
			nBytes := FWRITE(nHLog, "Producto " + Alltrim(aReg[1]) + " <-- CON ERRORES" + CRLF)
			nBytes := FWRITE(nHLog, "----------------------------------------------------------" + CRLF)
			nBytes := FWRITE(nHLog, cMsjError + CRLF) 
			nBytes := FWRITE(nHLog, "----------------------------------------------------------" + CRLF) 
			nBytes := FWRITE(nHLog, "NO SE HAN PODIDO CARGAR LOS PRODUCTOS" + CRLF) 
			DisarmTransaction() 
			FCLOSE(nHlog) 
			WinExec("NOTEPAD "+cLog)
			Return
//			lMsErroAuto :=.F.
		Else
			nBytes := FWRITE(nHLog,"Producto " + Alltrim(aReg[1]) + " <-- LISTO!" + CRLF)
		EndIf 
		
		FT_FSKIP()
	enddo

//end transaction
nBytes := FWRITE(nHLog, "----------------------------------------------------------" + CRLF)
nBytes := FWRITE(nHLog, "CARGA EXITOSA !!" + CRLF + CRLF)  

WinExec("NOTEPAD "+cLog)

FCLOSE(nHlog)
RestArea(aArea)  

Return (.T.)

Static function GeneraFormat(aCampos) 
private directorio :="C:\Formato_Carga_Productos" 

If !empty(aCampos)
    
	if ExistDir(directorio) =.F.
	    makedir(directorio)
	    MsgInfo("Se ha creado el Directorio :"+directorio)
		ctxt := directorio+"\CargaProductos.csv"
		nHdl:= fCreate(ctxt)
	
	   		If nHdl = -1	                                                                                         
	       		MsgInfo("No se pudo crear el archivo *.CSV ","Grave Error")	
	   		Endif
		fSeek(nHdl,0,0)
	else
		MsgInfo("El directorio" +directorio+ "ya existe, se omitira la creacion del directorio") 
		ctxt := directorio+"\CargaProductos.csv"
		nHdl:= fCreate(ctxt)   
	   		If nHdl = -1	
	   	   		MsgInfo("No se pudo crear el archivo *.CSV ","Grave Error")	
	   		Endif
		fSeek(nHdl,0,0)
	endif
	
	Processa({|| fGenForm(aCampos)}, "Espere...", "Creando Formato csv",.T.)  
	
endif 

Return .T.   

Static function fGenForm(aCampos)  
Local nLoop
			for nLoop := 1 to len(aCampos)
				_aAreaSx3	:= SX3->(GetArea())
				SX3->(DBSETORDER(2))
				IF SX3->(DBSEEK(aCampos[nLoop][1]))					
					SX3->(Restarea(_aAreaSX3)) 
					fwrite(nHdl,alltrim(POSICIONE("SX3",2,ALLTRIM(aCampos[nLoop][1]),"X3_TITSPA"))) 
						IF nLoop != len(aCampos) 
							fwrite(nHdl,';') 
						endif
				EndIf
			Next  

fClose(nHdl)   
cDrive	:= ""
cDir	:= ""					    
SplitPath(ctxt, @cDrive, @cDir )
cDir 	:= Alltrim(cDrive) + Alltrim(cDir)
ShellExecute("open",ctxt, "", cDir, 1 )    
		
Return .T.