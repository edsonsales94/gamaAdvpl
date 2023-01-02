#include "protheus.ch"
#include "parmtype.ch"
#include "RWMAKE.CH"

user function ARQTXT()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Private cPerg       := "SCOA"
	Private oGeraTxt,mes

	Private cString := "SB9"

	//ValidPerg(cPerg)
	//Pergunte(cPerg,.T.)

	dbSelectArea("SB9")
	dbSetOrder(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da tela de processamento.                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	@ 200,1 TO 380,480 DIALOG oGeraTxt TITLE OemToAnsi("Gera‡„o de Arquivo Texto")
	@ 02,10 TO 085,240
	@ 10,018 Say " Este programa ira gerar um arquivo texto, conforme os parame- "
	@ 18,018 Say " tros definidos  pelo usuario,  com os registros do arquivo de "
	@ 26,018 Say " SB6 .Para isso crie um diretorio C:TEMP com permissao de gravação."

	@ 50,15  BUTTON "Gera REGESTI"  SIZE 040,010  PIXEL OF oGeraTxt Action OkGeraTXT(5)
	@ 50,60  BUTTON "Gera REGPJF"  SIZE 040,010  PIXEL OF oGeraTxt Action OkGeraTXT(4)
	@ 70,15  BUTTON "Gera REGMERC"  SIZE 032,010  PIXEL OF oGeraTxt Action OkGeraTXT(1)
	@ 70,60  BUTTON "Gera REGINV"  SIZE 032,010  PIXEL OF oGeraTxt Action OkGeraTXT(2)
	@ 70,105 BUTTON "Gera REGINS"  SIZE 032,010  PIXEL OF oGeraTxt Action OkGeraTXT(3)
	@ 70,150 BUTTON "Parametros" SIZE 032,010  PIXEL OF oGeraTxt Action Pergunte(cPerg,.T.)
	@ 70,200 BUTTON "SAIR"      SIZE 032,010  PIXEL OF oGeraTxt Action Close(oGeraTxt)

	Activate Dialog oGeraTxt Centered

return

Static Function OkGeraTxt(opc)
	Private cArq    
	If opc=1
		cArq    := "c:\temp\REGMERC.txt"
	Elseif opc=2
		cArq    := "c:\temp\REGINV.txt"
	Elseif opc=3
		cArq    := "c:\temp\REGINS.txt"
	Elseif opc=4
		cArq    := "c:\temp\REGPJF.txt"
	Elseif opc=5
		cArq    := "c:\temp\REGESTI.txt"	
	Endif

	If File( cArq )

		Erase(cArq)
		nHdl := FCreate( cArq )
		//FClose( nHdl )

	ELSE
		nHdl := FCreate( cArq )
		//FClose( nHdl )
	Endif

	Private cEOL    := "CHR(13)+CHR(10)"
	If Empty(cEOL)
		cEOL := CHR(13)+CHR(10)
	Else
		cEOL := Trim(cEOL)
		cEOL := &cEOL
	Endif

	If nHdl == -1
		MsgAlert("O arquivo de nome "+cArq+" nao pode ser executado! Verifique os parametros.","Atencao!")
		Return
	Endif
	IF opc==1
		Processa({|| RunSB1() },"Processando...")
	elseif opc==2
		Processa({|| RunSB9() },"Processando...")
	elseif opc==3
		Processa({|| RunSG1() },"Processando...")
	elseif opc==4
		Processa({|| RunSM0() },"Processando...")
	elseif opc==5
		Processa({|| RunSHC() },"Processando...")
	endif
	fClose(nHdl)
Return

Static Function RunSM0
	Local cData := DTOS(SM0->M0_DTRE)
	Local cLin :=""
	Local (cAliasSA1):= GetNextAlias()
	BeginSql Alias cAliasSA1
	 SELECT * FROM %table:SA1% SA1 WHERE SA1.%NotDel% AND A1_EST<>'EX'
	EndSql
	dbSelectArea(cAliasSA1)
	dbgotop()
	Count to regSB9
	ProcRegua(regSB9) // Numero de registros a processar
	npos:=1
	dbgotop()
	While !EOF()
		IncProc("Montando os Clientes...")
		if vldCliente((cAliasSA1)->A1_CGC)
	     cData :=  substr(cData,7,2)+substr(cData,5,2)+substr(cData,1,4)
		 cLin := cData+PADR((cAliasSA1)->A1_COD,14)+ALLTRIM((cAliasSA1)->A1_CGC)+PADR((cAliasSA1)->A1_INSCR,14)+PADR((cAliasSA1)->A1_INSCRM,14)
		 cLin := cLin + PADR(ALLTRIM(left((cAliasSA1)->A1_NOME,70)),70)+ PADR(ALLTRIM(left((cAliasSA1)->A1_END,60)),60)
		 cLin := cLin + PADR(ALLTRIM((cAliasSA1)->A1_BAIRRO),20)+ PADR(ALLTRIM((cAliasSA1)->A1_MUN),20)
		 cLin := cLin + ALLTRIM((cAliasSA1)->A1_EST)+PADR(ALLTRIM("BRASIL"),20)+ALLTRIM((cAliasSA1)->A1_CEP)+"C"+cEOL
		 If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Return
			Endif
		 Endif
		endif 
		dbSelectArea(cAliasSA1)
		(cAliasSA1)->(dbskip())
	Enddo
	alert("Arquivo de REGPJF Gerado com sucesso!!")
	dbSelectArea(cAliasSA1)
	dbclosearea()
Return


Static Function vldCliente(cliente)
Local lRet:= .F. 
Local cnpjs:= "00063960002730/00063960008266/00094907002615/00310506000105/00436042000170/00562786000130"
cnpjs+="01008713003775/01008713004909/01008713006367/01008713009544/01262108000115/01534080009770/02125266000277"
cnpjs+="02158816000254/02764205000179/02847209000463/02869763007705/03002339004102/03249438000791/03276518000140"
cnpjs+="03341024000100/03379027000125/03656804000727/03772229000213/03785066000122/03880277000730/04112118000162"
cnpjs+="04415928011122/04415928021195/04561957001130/04565289000570/04565289001623/04565289003243/04569071000241"
cnpjs+="04741235000861/05054671001554/05076320000149/05399929000159/05566250000107/05566250000298/05889907000177"
cnpjs+="06237330000505/06837645001050/06862627010010/07170938001413/07170938014078/07216054000219/07280961000812"
cnpjs+="08326720000153/08718972000128/08995631000280/08995631006211/09055134000265/09313141002182/09339936000973"
cnpjs+="09376561000164/10228674000100/10464223000597/10548256000191/10731966000152/11114284011106/11869763000190"
cnpjs+="12303616000200/13004510025840/13481309015629/13481309019535/13850516002200/16233389004819/16979942000284"
cnpjs+="17100498000167/17318168000142/17359233000188/17823155000120/17871449001523/17909628000107/18900446000138"
cnpjs+="19485797000192/20217798000135/21545371000129/22164990006177/22962737000128/23389397000231/23439441000785"
cnpjs+="23439441001757/23439441002133/23797376000174/26404731000196/26910194000156/28246084000167/30689848000130"
cnpjs+="31743818002252/32951535000134/33014556017919/33014556018133/33014556019962/33014556088425/33041260076063"
cnpjs+="33041260078007/33041260080338/33041260094711/33041260095602/33041260113015/33041260121891/33041260139405"
cnpjs+="33041260146371/33041260158701/33041260159430/33041260160447/33041260162148/35570969000263/39346861000161"
cnpjs+="39346861037910/40841728000594/41005190000117/41426966000334/41560319000159/43214055000107/43214055001189"
cnpjs+="43214055001693/43214055004013/43708379006485/45543915007518/45543915022827/45543915027977/45543915056489"
cnpjs+="47508411226553/47960950003902/47960950010194/47960950034450/47960950041901/47960950044927/47960950058804"
cnpjs+="47960950075482/47960950075725/49975923000310/54289996001017/54801535001081/56642960000100/56991441000823"
cnpjs+="57508426004750/61099834065560/63864771001623/70051305000108/72456809000133/76189406000126/76517267000112"
cnpjs+="77500049000308/77941490000155/77941490003685/77941490012757/77941490015349/77941490026626/79430682025540"
cnpjs+="82647165000629/82956160000173/83240333000115/83646984006906/83733337001379/86184074006181/86184074014109"
cnpjs+="89237911000140/89848543021336/89848543937080/91362590006270/92665611032290/93015006001438/93209765000621"
cnpjs+="93209765023672/96662168016992/97422620000150/98102924001680"
if cliente$cnpjs
 lRet:= .T.
endif 
Return(lRet) 

Static Function RunSHC
	Local  cCod,cQtde,cPreco
	Local cAliasSHC:= GetNextAlias()
	LOCAL cprev :=dtos(ddatabase+360)  //previsao para 6 merses
	BeginSql Alias cAliasSHC 
/*	
	SELECT HC_PRODUTO,SUM(HC_QUANT)QUANT,
	ISNULL((select MAX(DA1_PRCVEN) from DA1010  WHERE DA1_CODPRO=HC_PRODUTO AND D_E_L_E_T_<>'*'),0) PRECO 
	FROM %table:SHC% SHC
	WHERE HC_FILIAL=%exp:XFILIAL("SHC")%
	AND HC_DATA>=%exp:DTOS(DDATABASE)% AND HC_DATA<=%exp:cprev%
	AND SHC.%NotDel%
	GROUP BY HC_PRODUTO
	ORDER BY HC_PRODUTO
*/	
	SELECT * FROM VW_SHC
	ORDER BY HC_PRODUTO
	
	
	EndSql
	dbSelectArea(cAliasSHC)
	dbgotop()
	Count to regSB9
	ProcRegua(regSB9) // Numero de registros a processar
	npos:=1
	dbgotop()
	While !EOF()
	    cLin:=""
		IncProc("Montando a Previsao SHC..."+(cAliasSHC)->HC_PRODUTO)
		cCod   := padr((cAliasSHC)->HC_PRODUTO,20)
		cQtde := STR( NOROUND((cAliasSHC)->(QUANT), 2) ,17,2)
		cQtde  := StrTran( cQtde, ",", "" )   //ELIMINA AS VIRGULAS
		cQtde  := StrTran( cQtde, ".", "" )
		cQtde  := replicate("0",17-len(alltrim(cQtde)))+alltrim(cQtde)
		cPreco := STR( NOROUND((cAliasSHC)->PRECO , 2) ,17,2)
		cPreco := StrTran( cPreco, ",", "" )   //ELIMINA AS VIRGULAS
		cPreco := StrTran( cPreco, ".", "" )
		cPreco := replicate("0",17-len(alltrim(cPreco)))+alltrim(cPreco)
		cLin:=cLin+cCod+cQtde+cPreco+"PA "+cEOL
		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
			Endif
		Endif
		dbSelectArea(cAliasSHC)
		(cAliasSHC)->(dbskip())
	Enddo
	alert("Arquivo de REGESTI Gerado com sucesso!!")
	dbSelectArea(cAliasSHC)
	dbclosearea()
Return

Static Function RunSB1
	Local cAliasSB9:= GetNextAlias()
	Local nTamLin, cLin, cCpo
	Local cData
	BeginSql Alias cAliasSB9
/*
	SELECT B9_COD,B1_DESC,B1_UM,SUM(B9_QINI) QINI,SUM(B9_VINI1) VINI1
	FROM %table:SB9% SB9 ,%table:SB1% SB1
	WHERE B9_FILIAL=%exp:XFILIAL("SB9")%
	AND B9_DATA=%exp:DTOS(MV_PAR01)% AND B9_QINI>0
	AND SB9.%NotDel% AND B1_COD=B9_COD
	GROUP BY B9_COD,B1_DESC,B1_UM
*/

	SELECT B1_COD,B1_DESC,B1_UM,B1_POSIPI
	FROM %table:SB1% SB1
	WHERE SB1.%NotDel% AND B1_MSBLQL='2' AND B1_POSIPI NOT IN('','00000000') 
	GROUP BY B1_COD,B1_DESC,B1_UM,B1_POSIPI

	
	EndSql
	dbSelectArea(cAliasSB9)
	dbgotop()
	Count to regSB9
	ProcRegua(regSB9) // Numero de registros a processar
	npos:=1
	dbgotop()
	While !EOF()
		IncProc("Relação dos Produtos")
		cUltCompra:=DTOS(POSICIONE("SB1",1,XFILIAL("SB1")+(cAliasSB9)->B1_COD,"B1_UCOM"))
		cNCM:=padr(POSICIONE("SB1",1,XFILIAL("SB1")+(cAliasSB9)->B1_COD,"B1_POSIPI"),8)
		cData  :=  IIF(LEN(ALLTRIM(cUltCompra))==0,'20120101',cUltCompra)
		cData  := substr(cData,7,2)+substr(cData,5,2)+substr(cData,1,4)
		cLin   := cData // Variavel para criacao da linha do registros para gravacao
		cCod   := padr((cAliasSB9)->B1_COD,20)
		cDesc  := padr((cAliasSB9)->B1_DESC,45)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Substitui nas respectivas posicioes na variavel cLin pelo conteudo  ³
		//³ dos campos segundo o Lay-Out. Utiliza a funcao STUFF insere uma     ³
		//³ string dentro de outra string.                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//FORMAÇÃO DAS LINHAS DO REGISTRO

		cLin := cLin+cCod+cDesc+cNCM+cEOL
		//getObjXML(1,PADR((cAliasSB9)->COD,15),PADR(ALLTRIM(cDesc),80),PADR(alltrim(MV_PAR06),5),STRZERO((cAliasSB9)->QINI,8),"PC",cPreco,"","","","","",npos,0)
		npos++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravacao no arquivo texto. Testa por erros durante a gravacao da    ³
		//³ linha montada.                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
			Endif
		Endif
		dbskip()
	Enddo
	alert("Arquivo de REGMERC Gerado com sucesso!!")
	dbSelectArea(cAliasSB9)
	dbclosearea()
Return

Static Function RunSB9
	Local cAliasSB9:= GetNextAlias()
	Local nTamLin, cLin, cCpo
	Local cData
	BeginSql Alias cAliasSB9
	SELECT B9_COD,B1_DESC,B1_UM,SUM(B9_QINI) QINI,SUM(B9_VINI1) VINI1
	FROM %table:SB9% SB9 ,%table:SB1% SB1
	WHERE B9_FILIAL=%exp:XFILIAL("SB9")%
	AND B9_DATA='20181231' AND B9_QINI>0
	AND B1_MSBLQL='2' AND B1_POSIPI NOT IN('','00000000')  
	AND SB9.%NotDel% AND B1_COD=B9_COD
	GROUP BY B9_COD,B1_DESC,B1_UM
	EndSql
	dbSelectArea(cAliasSB9)
	dbgotop()
	Count to regSB9
	ProcRegua(regSB9) // Numero de registros a processar
	npos:=1
	dbgotop()
	While !EOF()
		IncProc("Itens dos saldos iniciais")
		cData  := DTOS(MV_PAR01)
		cData  := substr(cData,7,2)+substr(cData,5,2)+substr(cData,1,4)
		cLin   := cData+"1" // Variavel para criacao da linha do registros para gravacao
		cCod   := padr((cAliasSB9)->B9_COD,20)
		cUm    := padr((cAliasSB9)->B1_UM,3)
		cQtde  := STR( NOROUND((cAliasSB9)->(QINI), 3) ,17,3)
		cQtde  := StrTran( cQtde, ",", "" )   //ELIMINA AS VIRGULAS
		cQtde  := StrTran( cQtde, ".", "" )
		cQtde  := replicate("0",17-len(alltrim(cQtde)))+alltrim(cQtde)
		cPreco := STR( NOROUND((cAliasSB9)->(VINI1), 2) ,17,2)
		cPreco := StrTran( cPreco, ",", "" )   //ELIMINA AS VIRGULAS
		cPreco := StrTran( cPreco, ".", "" )
		cPreco := replicate("0",17-len(alltrim(cPreco)))+alltrim(cPreco)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Substitui nas respectivas posicioes na variavel cLin pelo conteudo  ³
		//³ dos campos segundo o Lay-Out. Utiliza a funcao STUFF insere uma     ³
		//³ string dentro de outra string.                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//FORMAÇÃO DAS LINHAS DO REGISTRO

		cLin := cLin+cCod+cUm+cQtde+cPreco+cEOL
		//getObjXML(1,PADR((cAliasSB9)->COD,15),PADR(ALLTRIM(cDesc),80),PADR(alltrim(MV_PAR06),5),STRZERO((cAliasSB9)->QINI,8),"PC",cPreco,"","","","","",npos,0)
		npos++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gravacao no arquivo texto. Testa por erros durante a gravacao da    ³
		//³ linha montada.                                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
				Exit
			Endif
		Endif
		dbskip()
	Enddo
	alert("Arquivo de REGINV Gerado com sucesso!!")
	dbSelectArea(cAliasSB9)
	dbclosearea()
Return

Static Function RunSG1
	Local cAliasSB9:= GetNextAlias()
	Local cAliasSG1:= GetNextAlias()
	Local nTamLin, cLin, cCpo
	Local cData

	BeginSql Alias cAliasSB9
   /*
	SELECT DISTINCT B9_COD,B1_UM
	FROM %table:SB9% SB9 ,%table:SB1% SB1
	WHERE B9_FILIAL=%exp:XFILIAL("SB9")%
	AND B9_DATA=%exp:DTOS(MV_PAR01)% AND B9_QINI>0 AND B1_TIPO IN ('PA','PI')
	AND SB9.%NotDel% AND B1_COD=B9_COD
	*/ 
		SELECT CODIGO,COD_COMP,QTD,
		substring(DT_INI,7,2)+substring(DT_INI,5,2)+substring(DT_INI,1,4) INI,
		substring(DT_FIM,7,2)+substring(DT_FIM,5,2)+substring(DT_FIM,1,4)  FIM 
		FROM VW_SG1 
		WHERE CODIGO IN(
		SELECT DISTINCT HC_PRODUTO
		FROM VW_SHC	)
	
	
	EndSql
	dbSelectArea(cAliasSB9)
	dbgotop()
	Count to regSB9
	ProcRegua(regSB9) // Numero de registros a processar
	dbgotop()
	While !EOF()
		IncProc("Relação dos insumos ")
		cCod   := padr((cAliasSB9)->CODIGO,20)
		cUm    := padr(POSICIONE("SB1",1,XFILIAL("SB1")+(cAliasSB9)->CODIGO,"B1_UM"),3)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Substitui nas respectivas posicioes na variavel cLin pelo conteudo  ³
		//³ dos campos segundo o Lay-Out. Utiliza a funcao STUFF insere uma     ³
		//³ string dentro de outra string.                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//FORMAÇÃO DAS LINHAS DO REGISTRO
      /*
		cRevAtu:=POSICIONE("SB1",1,XFILIAL("SB1")+(cAliasSB9)->B9_COD,"B1_REVATU")
		BeginSql Alias cAliasSG1
		SELECT G1_COMP,G1_QUANT,B1_UM,substring(G1_INI,7,2)+substring(G1_INI,5,2)+substring(G1_INI,1,4) INI,
		substring(G1_FIM,7,2)+substring(G1_FIM,5,2)+substring(G1_FIM,1,4)  FIM 
		FROM SG1010 SG1,SB1010 SB1
		WHERE G1_FILIAL='' AND G1_COD=%exp:(cAliasSB9)->B9_COD%
		AND (G1_REVFIM=%exp:cRevAtu% OR  G1_REVFIM='ZZZ')
		AND B1_COD=G1_COMP AND SG1.%NotDel% AND SB1.%NotDel%
			
		EndSql
		dbSelectArea(cAliasSG1)
		dbgotop()
		Count to regSG1
		ProcRegua(regSG1) // Numero de registros a processar
		dbgotop()
		While !EOF()
			IncProc("Percorrendo SG1")
			cInsumo:= padr((cAliasSG1)->G1_COMP,20)
			cQtde := STR( NOROUND((cAliasSG1)->(G1_QUANT), 3) ,17,3)
			cQtde : IIF(LEN(ALLTRIM(cQtde))==0,0.001,cQtde)
			cQtde := StrTran( cQtde, ",", "" )   //ELIMINA AS VIRGULAS
			cQtde := StrTran( cQtde, ".", "" )
			cQtde  := replicate("0",17-len(alltrim(cQtde)))+alltrim(cQtde)
			cPerda:="00000"
			cUmInsumo := padr((cAliasSG1)->B1_UM,3)
			cDataini := ALLTRIM((cAliasSG1)->INI)
			cDataFim := ALLTRIM((cAliasSG1)->FIM)
			cLin := cCod+cUm+cInsumo+cQtde+cPerda+cUmInsumo+cDataini+cDataFim+cEOL

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravacao no arquivo texto. Testa por erros durante a gravacao da    ³
			//³ linha montada.                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
					Exit
				Endif
			Endif
			(cAliasSG1)->(dbskip())
		Enddo
		dbSelectArea(cAliasSG1)
		dbclosearea()
		*/
		
		
			cInsumo:= padr((cAliasSB9)->COD_COMP,20)
//			cQtde := STR( NOROUND((IIF(LEN(ALLTRIM((cAliasSB9)->(QTD)))==0,0.001,(cAliasSB9)->(QTD))), 3) ,17,3)
			cQtde := STR( NOROUND(IIF((cAliasSB9)->(QTD)<=0.001,0.001,(cAliasSB9)->(QTD)), 3) ,17,3)
			cQtde := StrTran( cQtde, ",", "" )   //ELIMINA AS VIRGULAS
			cQtde := StrTran( cQtde, ".", "" )
			cQtde  := replicate("0",17-len(alltrim(cQtde)))+alltrim(cQtde)
			cPerda:="00000"
			cUmInsumo := padr(POSICIONE("SB1",1,XFILIAL("SB1")+(cAliasSB9)->COD_COMP,"B1_UM"),3)
			cDataini := ALLTRIM((cAliasSB9)->INI)
			cDataFim := ALLTRIM((cAliasSB9)->FIM)
			cLin := cCod+cUm+cInsumo+cQtde+cPerda+cUmInsumo+cDataini+cDataFim+cEOL

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravacao no arquivo texto. Testa por erros durante a gravacao da    ³
			//³ linha montada.                                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				If !MsgAlert("Ocorreu um erro na gravacao do arquivo. Continua?","Atencao!")
					Exit
				Endif
			Endif
		
		dbSelectArea(cAliasSB9)
		(cAliasSB9)->(dbskip())
	Enddo
	alert("Arquivo de REGINS Gerado com sucesso!!")
	dbSelectArea(cAliasSB9)
	dbclosearea()
Return