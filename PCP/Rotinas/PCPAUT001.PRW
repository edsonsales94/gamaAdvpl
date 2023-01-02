#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TOTVS.CH"


user function pcpaut001()

	Local bOk := {|| Fechar() }
	Local bCancel:= {|| Fechar() }
	Local aArea := GetArea()
	Local aButtons := {}
                                                  
	Private cCod, nQtd1, nQtd2,cOp,cTitle,cDoc,cDesc,cLm,cBarras,cEan,cCod2,cLote,cLinha,cOPC,cProc
	Private oTurno,oCod,oQtd1,oQtd2,oOP,oDlg,oDoc, oSay_desc, oSay_crit,oPes
	Private nimpress,lHtml,nEtq,nQtdpc,npessoas,hratu
	Private aHrs,aHrst,dDia,cLtAnt
	Private nVerao:=1  //DIFERENÇA DE HORARIO DE VERAO
	Private nPadrao := 4 // Quantidade padrao da etiqueta
    
    cProc:=GETMV("MV_LOCPROC")  //PARAMETRO PARA UTILIZAÇÃO DO ALMOX DE PRODUÇÃO
	aHrs:={0,0,0,0,0,0,0,0,0,0}
	aHrst:={}
	cTurno:= SPACE(5)
	cTurno:=turno()
	
	aadd(aHrst,{"07 Hrs","08 Hrs","09 Hrs","10 Hrs","11 Hrs","12 Hrs","13 Hrs","14 Hrs","15 Hrs","16 Hrs"})
	aadd(aHrst,{"17 Hrs","18 Hrs","19 Hrs","20 Hrs","21 Hrs","22 Hrs","23 Hrs","00 Hrs","01 Hrs","02 Hrs"})
	aadd(aHrst,{"03 Hrs","04 Hrs","05 Hrs","06 Hrs"," Hrs"," Hrs"," Hrs"," Hrs"," Hrs"," Hrs"})
	
	lHtml:=.T.
	
	aSize := MsAdvSize(.F.)
	nimpress:=2   // impressora TLP 2844

	aadd(aButtons,{'HISTORIC',{|| ETQDM01A() }, "Reimprimir Etiqueta", "Reimp. Etq" , {|| .T.}} )

	cTitle:="Apontamento de Produção"
	// Cria Fonte para visualização
	oFont1 := TFont():New('Courier new',,-14,.T.,.T.)
	oFont2 := TFont():New('Arial',,-20,.T.,.T.)

	Define MsDialog oDlg TITLE cTitle STYLE DS_MODALFRAME From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL
    nMilissegundos := 2000 // Disparo será de 2 em 2 segundos
	oSay_tn:= TSay():New(05+40,05,{|| 'Meta Hora :'},oDlg,,oFont1,,,,.T.,CLR_BLUE,CLR_RED,200,20)
	oSay_prd:= TSay():New(25+40,05,{||'Ord.Produção:'},oDlg,,oFont1,,,,.T.,CLR_BLUE,CLR_RED,200,20)
	oSay_cod:= TSay():New(45+40,05,{||'Codigo:'},oDlg,,oFont1,,,,.T.,CLR_BLUE,CLR_RED,200,20)
	oSay_Desc:= TSay():New(10+40,170,{||'PRODUTO EM LINHA'},oDlg,,oFont2,,,,.T.,CLR_BLUE,CLR_WHITE,470,250,,,,,,lHtml)
	oSay_crit:= TSay():New(60+40,05,{||''},oDlg,,oFont1,,,,.T.,CLR_BLUE,CLR_WHITE,100,250,,,,,,lHtml)
	oSay_hrs:= TSay():New(05+30,580,{||''},oDlg,,oFont1,,,,.T.,CLR_BLUE,CLR_WHITE,100,050,,,,,,lHtml)
    oTimer := TTimer():New(nMilissegundos, {|| atuhora() }, oDlg ) 
    oTimer:Activate()
	cDesc:=""
	cLm:=""
	cBarras:=""
	cEan:=""
	cOPC:=""
	cCod:=SPACE(15)     
	cCod2:=""
	cLinha:=""
	cOP:=SPACE(12)
	nQtd1:= 0
	nQtd2:= 0
	nEtq := 0
	npessoas:=0
	mes:={"A","B","C","D","E","F","G","H","I","J","K","L"}
	cLote:=""
	
	
		
	@05+40,65  GET oPes VAR npessoas SIZE 030,09 OF oDlg PIXEL PICTURE "@E 999"
	@25+40,65 GET oOP    Var cOP  Valid ( ValOP()  ) SIZE 060,09 OF oDlg PIXEL
	@45+40,65 GET oCod    Var cCod  Valid ( ValCod() )  SIZE 060,09 OF oDlg PIXEL

	//ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg,{||lOk:=.T.,oDlg:End()},{||oDlg:End()},,@aButtons))
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar  (oDlg, bOk                   , bCancel      ,,@aButtons)) CENTERED
	RestArea(aArea)

return

Static Function Fechar() 
	oDlg:End()
Return


Static Function atuhora()
    Local cRet:=""
    Local cHora:= strzero(HoraAtual(),2)+substring(Time(),3,6)
    cRet+='<font size="4" color="red">'+cHora+'</font>'
	oSay_hrs:SetText(cRet)
	oSay_hrs:CtrlRefresh()
Return

Static Function ValOP()
	Local lRet:=.F.
	Local x
	dbselectarea("SC2")
	dbsetorder(1)
	dbseek(xfilial("SC2")+alltrim(cOP))
	if !eof()
		if (!GetMv("MV_ULMES") < SC2->C2_EMISSAO .AND. !GetMv("MV_ULMES") < SC2->C2_DATRF )
			ALERT("Op fora do Periodo do Ultimo Fechamento!!")
		else
			if LEN(ALLTRIM(DTOS(C2_DATRF)))==0
				lRet:=.T.
				cOP:=C2_NUM+C2_ITEM+C2_SEQUEN
				nQtd2:= prodOp()   //PRODUZIDO  SOMENTE O QUE PASSOU NA LINHA
				nQtd1:=SC2->C2_QUANT  //PLANEJADO
				cDesc:=Posicione("SB1",1,XFILIAL("SB1")+SC2->C2_PRODUTO,"B1_DESC")
				cEan:=Posicione("SB1",1,XFILIAL("SB1")+SC2->C2_PRODUTO,"B1_CODBAR")
				cBarras:=Posicione("SB1",1,XFILIAL("SB1")+SC2->C2_PRODUTO,"B1_DUN14")
				cCod2:=SC2->C2_PRODUTO
				cLinha:=SC2->C2_XEND
				cOPC:=SC2->C2_OPC
				IF SC2->C2_XEND="LINHA1"
					cLm:='01'
				ELSEIF SC2->C2_XEND="LINHA2"
					cLm:='02'
				ELSEIF SC2->C2_XEND="LINHA3"
					cLm:='03'
				ELSEIF SC2->C2_XEND="LINHA4"
					cLm:='04'
				ELSEIF SC2->C2_XEND="LINHA5"
					cLm:='05'
				ENDIF
				nQtdpc:= CalcPRev()
				hratual := HoraAtual()   //diminuir uma hora devido ao fusohorario do servidor 
				//preenche as produções do turno

	            for x:=1 to len(aHrs)    
             if val(cTurno)==2 .and. x<=7 .and. hratual<=2
	               dDia2:=dDia - 1
	             else
	               dDia2:=dDia
	             endif  
	             aHrs[x] := prodhora(left(aHrst[val(cTurno),x],2),dDia2)
	             if hratual==val( left(aHrst[val(cTurno),x],2)) .and. x>1
	               if aHrs[x]>0  
	                nEtq:=MOD(aHrs[x],nPadrao)
	               else
	                nEtq:=MOD(aHrs[x-1],nPadrao)
	               endif 
	             endif
	            next 
				oSay_desc:SetText(fazhtml(cDesc,cLm,SC2->C2_QUANT,nQtd2))
				oSay_desc:CtrlRefresh()
				oSay_crit:SetText(LoteOP())
		      oSay_crit:CtrlRefresh() 
		      if nEtq==0
				 cLtAnt:=geraLote()
				else
				 cLtAnt:=""
				endif 
			else
				ALERT("Ordem de Produção ja foi encerrada!!")
			endif
		endif                                 
		
	Else
		alert("Ordem de Produção Invalida !!! Tente novamente.")
	Endif

Return lRet

Static Function ValCod()
	local lRet,cTurno_ant,x
	lRet:=.F.
	if nQtd2>=nQtd1
		alert("Ordem de prucao já produziu o planejado!!!")
		Return lRet
	endif
	if alltrim(LEFT(cCod,13))==alltrim(LEFT(cEan,13))   
		nQtd2++
		lRet:=.T.
		cTurno_ant:=cTurno
		cTurno:=turno()                                                                                                       
		hratual := HoraAtual()   //diminuir uma hora devido ao fusohorario do servidor 
		//preenche as produções do turno qdo houver mudança de turno
		dDia2:=dDia
		if cTurno<>cTurno_ant
	     for x:=1 to len(aHrs)                                  
	      if val(cTurno)==2 .and. x<=7  .and. hratual<=2
	       dDia2:=dDia - 1
	      else
	       dDia2:=dDia
	      endif  
	      aHrs[x] := prodhora(left(aHrst[val(cTurno),x],2),dDia2)
	     next 
		endif
		SetFocus(oCod:HWND)
		//atualiza produção hora
		hratu := strzero(hratual,2)+" Hrs"
		poshra:=aScan( aHrst[val(cTurno)] , { |x| Upper( Alltrim( x ) ) == Upper(hratu)  })
		cLote:=geraLote()
		dDia2:=dDia
		if cLtAnt<>cLote .and. poshra>1
		  if val(cTurno)==2 .and. hratual==0
		     dDia2:=dDia-1
		  endif
		  aHrs[poshra-1] := prodhora(left(aHrst[val(cTurno),poshra-1],2),dDia2)
	      if aHrs[poshra-1]>0  .and. aHrs[poshra]<=3
	        ntop:= MOD(aHrs[poshra-1],nPadrao)
	        aHrs[poshra-1]:=aHrs[poshra-1]-(ntop)
	        aHrs[poshra]:=aHrs[poshra]+(ntop)
	        atuZ04(ntop,cLtAnt,cLote,strzero(hratual,2)+":00:00")  //caso as utimas pertencam ao lote atual atualizar o lote
	      endif 
	      oSay_crit:SetText(LoteOP())
		   oSay_crit:CtrlRefresh()
		   cLtAnt:=cLote
	   endif 
	    
		aHrs[poshra]:=aHrs[poshra] + 1
		//-------------------------------------------------------------
		oSay_desc:SetText(fazhtml(cDesc,cLm,nQtd1,nQtd2))
		oSay_desc:CtrlRefresh()
		//oSay_crit:SetText(CalcCrit())
		oSay_crit:CtrlRefresh()
		Z04inc()
		
		nEtq++
	   if nEtq==nPadrao
	        //dbselectarea("SC2")
	        //dbsetorder(1)
	        //dbseek(xfilial("SC2")+alltrim(cOP))
	        //nQtd2 := prodOp()   //PRODUZIDO  SOMENTE O QUE PASSOU NA LINHA  
			ETQDM01A()
			nEtq:=0
		endif
		cCod:=space(15)
		oCod:Refresh()
	else
		alert("Codigo nao pertence a esta OP!!!")
	endif
	if len(alltrim(cCod))==0
		lRet:=.T.
		SetFocus(oCod:HWND)
	endif

Return lRet
                

Static Function fazhtml(cDesc,lin,prev,real)
	local lRet,poshra
	hratu := strzero(HoraAtual(),2) +" HRS"  
	poshra:=aScan( aHrst[val(cTurno)] , { |x| Upper( Alltrim( x ) ) == Upper(hratu)  })
	lRet:=""
	perc:=100 - int((real/prev)*100)
	sperc:=alltrim(strzero(perc,iif(perc<100,2,3)))
	cFonte:="blue"
	lRet+='<h2 align="center">Monitor de Produção</h2>'
	lRet+='<font size="4" color="blue">'+alltrim(cCod2)+" - "+cDesc+'</font><br/>'
	lRet+='<table border="1" cellpadding="1" cellspacing="0">'+;
	'<tr>'+;
	'<td align="center" width="100" bgcolor="#FFFF87">Turno</td>'+;
	'<td align="center" width="100" bgcolor="#FFFF87">Linha</td>'+;
	'<td align="center" width="100" bgcolor="#FFFF87">Previsto</td>'+;
	'<td align="center" width="200" bgcolor="#FFFF87">Produzido</td>'+;
	'<td align="center" width="200" bgcolor="#FFFF87">A Produzir</td>'+;
	'</tr>'+;
	'<tr>'+;
	'<td align="center">'+cTurno+'</td>'+;
	'<td align="center">'+lin+'</td>'+;
	'<td align="center">'+alltrim(str(prev))+'</td>'+;
	'<td align="center">'+alltrim(str(real))+'</td>'+;
	'<td align="center">'+alltrim(str(prev-real))+'</td>'+;
	'</tr>'+;
	'</table>'+;
	'<br/><img  src="C:\Temp\imgs\prod'+sperc+'.png" width=450 height=200>'+;
	'<p>Meta Hora : '+str(nQtdpc,4)+' pcs</p>'+;
	'<tr>'+;
	'<td align="center" width="10%" bgcolor="#FFFF87">'+aHrst[val(cTurno),1]+'</td>'+;
	'<td align="center" width="10%" bgcolor="#FFFF87">'+aHrst[val(cTurno),2]+'</td>'+;
	'<td align="center" width="10%" bgcolor="#FFFF87">'+aHrst[val(cTurno),3]+'</td>'+;
	'<td align="center" width="10%" bgcolor="#FFFF87">'+aHrst[val(cTurno),4]+'</td>'+;
	'<td align="center" width="10%" bgcolor="#FFFF87">'+aHrst[val(cTurno),5]+'</td>'+;
	'<td align="center" width="10%" bgcolor="#FFFF87">'+aHrst[val(cTurno),6]+'</td>'+;
	'<td align="center" width="10%" bgcolor="#FFFF87">'+aHrst[val(cTurno),7]+'</td>'+;
	'<td align="center" width="10%" bgcolor="#FFFF87">'+aHrst[val(cTurno),8]+'</td>'+;
	'<td align="center" width="10%" bgcolor="#FFFF87">'+aHrst[val(cTurno),9]+'</td>'+;
	'<td align="center" width="10%" bgcolor="#FFFF87">'+aHrst[val(cTurno),10]+'</td>'+;
	'</tr>'+; 
	'<tr>'
	lRet+='<td align="center"><font color="'+iif(aHrs[1]>=nQtdpc,"blue",iif(poshra<=1,"blue","red"))+'">'+str(aHrs[1],3)+'</font></td>'
	lRet+='<td align="center"><font color="'+iif(aHrs[2]>=nQtdpc,"blue",iif(poshra<=2,"blue","red"))+'">'+str(aHrs[2],3)+'</font></td>'
	lRet+='<td align="center"><font color="'+iif(aHrs[3]>=nQtdpc,"blue",iif(poshra<=3,"blue","red"))+'">'+str(aHrs[3],3)+'</font></td>'
	lRet+='<td align="center"><font color="'+iif(aHrs[4]>=nQtdpc,"blue",iif(poshra<=4,"blue","red"))+'">'+str(aHrs[4],3)+'</font></td>'
	lRet+='<td align="center"><font color="'+iif(aHrs[5]>=nQtdpc,"blue",iif(poshra<=5,"blue","red"))+'">'+str(aHrs[5],3)+'</font></td>'
	lRet+='<td align="center"><font color="'+iif(aHrs[6]>=nQtdpc,"blue",iif(poshra<=6,"blue","red"))+'">'+str(aHrs[6],3)+'</font></td>'
	lRet+='<td align="center"><font color="'+iif(aHrs[7]>=nQtdpc,"blue",iif(poshra<=7,"blue","red"))+'">'+str(aHrs[7],3)+'</font></td>'
	lRet+='<td align="center"><font color="'+iif(aHrs[8]>=nQtdpc,"blue",iif(poshra<=8,"blue","red"))+'">'+str(aHrs[8],3)+'</font></td>'
	lRet+='<td align="center"><font color="'+iif(aHrs[9]>=nQtdpc,"blue",iif(poshra<=8,"blue","red"))+'">'+str(aHrs[9],3)+'</font></td>'
	lRet+='<td align="center"><font color="'+iif(aHrs[10]>=nQtdpc,"blue",iif(poshra<=8,"blue","red"))+'">'+str(aHrs[10],3)+'</font></td>'
	lRet+='</tr></table>'
Return lRet

Static Function HoraAtual()
 Local nHora:= val(substring(Time(),1,2))-nVerao
 if nHora<0
  nHora := 24 + nHora 
  dDia := date()-1
 else
  dDia := date() 
 endif     
Return(nHora)


static Function turno()
	Local cTime ,nHour,nMin,cRet
   cRet:='02'	
	nHour := HoraAtual()               
	//nMin  := val(SubStr( cTime, 4, 2 ))
	if nHour>=3 .and. nHour<=6
		cRet:='03'
	endif
	if nHour>=7 .and. nHour<=16
		cRet:='01'
	endif
Return(cRet)

Static Function geraLote()
 Local cTemp,nHrat
 cTemp:=SUBSTR(DTOS(dDia),3,2)
 cTemp:=cTemp+mes[month(dDia)]+strzero(day(dDia),2)
 nHrat:= horaAtual()
 cTemp+=strzero(nHrat,2)
Return(cTemp)

Static Function atuZ04(ult,lte,ltatual,chora)
Local cAliasZ04:= GetNextAlias()
 BeginSql Alias cAliasZ04
   SELECT TOP %Exp:ult%  R_E_C_N_O_  REG FROM %table:Z04% Z04 
   WHERE Z04_FILIAL=%xFilial:Z04% AND Z04_OP=%Exp:ALLTRIM(cOP)% AND Z04_LOTE=%Exp:lte%
   AND Z04.%NotDel%
 EndSql                                          
dbSelectArea(cAliasZ04)  
DbGoTop()
Do while !eof()
 dbSelectArea("Z04")
 Z04->(DBGOTO((cAliasZ04)->REG ))
 Z04->(RecLock("Z04",.F.))
 Z04->Z04_LOTE:=ltatual 
 Z04->Z04_HORA:=chora
 Z04->(MsUnlock())
 dbSelectArea(cAliasZ04)
 DBSKIP() 
enddo
dbSelectArea(cAliasZ04)
dbcloseArea(cAliasZ04)
Return


Static Function PEGACOD()
Local cRet 
Local cAliasCB0:= GetNextAlias()
 BeginSql Alias cAliasCB0
   SELECT ISNULL(MAX(CB0_CODETI),"0") NUMETQ FROM %table:CB0% CB0 
   WHERE CB0_FILIAL=%xFilial:CB0% AND CB0_CODETI<>''
   AND CB0.%NotDel%
 EndSql                                          
dbSelectArea(cAliasCB0)  

DbGoTop()
cRet := STRZERO( VAL((cAliasCB0)->NUMETQ)+1 , 10)
dbSelectArea(cAliasCB0)
dbcloseArea(cAliasCB0)
Return cRet



Static Function ETQDM01A()
	Local cCodEtq:= PEGACOD()
	Local aEtq:={}
	CB0->(RecLock("CB0",.T.))
	CB0->CB0_FILIAL:=XFILIAL("CB0")
  	CB0->CB0_CODETI:=cCodEtq
  	CB0->CB0_OP:=ALLTRIM(cOP)
  	CB0->CB0_TIPO:="PA"
  	CB0->CB0_LOCAL:="01"  
  	CB0->CB0_DTNASC:=dDia
  	CB0->CB0_CODPRO:=ALLTRIM(cCod2)
  	CB0->CB0_LOCALI:=cLinha
  	CB0->CB0_LOTE:=cLote
  	CB0->CB0_QTDE:=nPadrao
  	CB0->CB0_USUARI:=cUserName
  	CB0->(MsUnlock())
   	ImpEtq(cCodEtq,.F.)
   	SetFocus(oCod:HWND)
Return

Static Function ImpEtq(cEtq,lUlt)
    Local cModPrint:="ZM400"
    Local cCodEtq:= cEtq
    if lUlt
      cCodEtq:=PEGACOD()
    endif    	
	if nimpress==2
		cModPrint:="TLP 2844"
		MSCBPRINTER(cModPrint,"LPT1",,,.F.,,,,,,.T.)
		MSCBCHKStatus(.F.)
		MSCBBEGIN(1,3)  //TAMANH 52 MM
		// Box da Etiqueta -------------------------------------------------------
		MSCBBOX(04,01,101,47,2)
		// Dados da Etiqueta -------------------------------------------------------
		 if val(cLm)==2
		  MSCBBOX(04,01,101,07,2,"W")
 		  MSCBSAY(05,01,"__"+SPACE(2)+PADR(cDesc,54,"_")            ,"N","3" ,"1,2",.T.)
 		else
    	  MSCBSAY(07,02,cDesc,"N","3" ,"1,2")
    	endif	
		MSCBSAY(07,09,"Nr.O.P: "+ALLTRIM(cOP),"N","3" ,"1,2")
		MSCBSAY(07,15,"Cod.: "+ALLTRIM(cCod2),"N","3" ,"1,2")
		MSCBSAY(47,15,"Nr.Lote: "+cLote,"N","3" ,"1,2")
		MSCBSAY(78,15,"Qtde: "+alltrim(strzero(nPadrao,2)),"N","3" ,"1,2")
		MSCBSAY(07,21,"Data: "+alltrim(Dtoc(dDia)),"N","3" ,"1,2")
		MSCBSAY(41,21,"Turno: "+alltrim(cTurno),"N","3" ,"1,2")
		MSCBSAY(71,21,"LM: "+cLm ,"N","3" ,"1,2")
		MSCBSAY(15,40, cBarras ,"N","3" ,"3,3")

		// codigos de barras da Etiqueta -------------------------------------------------------
		MSCBSAYBAR ( 66 , 08 , ALLTRIM(cCodEtq) , "N","MB07",6,.F.,.F.,.F.,"C",2,2,.F.)
		MSCBSAYBAR ( 16 , 27 , cBarras , "N","MB07",12,.F.,.F.,.F.,"C",5,2,.F.)
	Else
		MSCBPRINTER(cModPrint,"LPT1",,)
		MSCBCHKStatus(.F.)
		MSCBBEGIN(1,3)
		// Box da Etiqueta -------------------------------------------------------
		MSCBBOX(04,01,101,47,2)
		// Dados da Etiqueta -------------------------------------------------------
		MSCBSAY(07,03,cDesc                 ,"N","1","030,040")
		MSCBSAY(07,09,"Nr.O.P: "+ALLTRIM(cOP),"N","1","030,040")
		MSCBSAY(07,15,"Cod.: "+ALLTRIM(cCod),"N","1","030,040")
		MSCBSAY(47,15,"Nr.Lote: "+cLote,"N","1","030,040")
		MSCBSAY(78,15,"Qtde: "+alltrim(strzero(nPadrao,2)),"N","1","030,040")
		MSCBSAY(07,21,"Data: "+alltrim(Dtoc(dDia)),"N","1","030,040")
		MSCBSAY(41,21,"Turno: "+alltrim(cTurno),"N","1","030,040")
		MSCBSAY(71,21,"LM: "+cLm ,"N","1","030,040")
		MSCBSAY(15,42, cBarras ,"N","1","030,040")
		// codigos de barras da Etiqueta -------------------------------------------------------
		MSCBSAYBAR ( 66 , 07 , ALLTRIM(cCodEtq) , "N","MB07",6,.F.,.F.,.F.,"C",2,2,.F.)
		MSCBSAYBAR ( 16 , 27 , cBarras , "N","MB07",12,.F.,.F.,.F.,"C",5,2,.F.)

	Endif

	MSCBEND()
	MSCBCLOSEPRINTER()

Return

//Calcular os itens criticos da produção
Static Function CalcCrit()
	Local nQuantItem,nQuanttemp
	Local cText,cRev,cDesc,nNeces
	Local nSaldo,cEmpenho,poshra
	hratu := strzero(HoraAtual(),2) +" HRS"   //diminuir uma hora devido ao fusohorario do servidor
	poshra:=aScan( aHrst[val(cTurno)] , { |x| Upper( Alltrim( x ) ) == Upper(hratu)  })
	cText:='<p>Itens Criticos</p>'+;
			'<table>'+;
			'<tr>'+;
			'<td align="left" width="75%" bgcolor="#FFFF87">Produto</td>'+;
			'<td align="center" width="10%" bgcolor="#FFFF87">Neces.</td>'+;
			'<td align="center" width="10%" bgcolor="#FFFF87">Saldo</td>'+;
			'</tr>'
	cRev:=Posicione("SB1",1,XFILIAL("SB1")+cCod2,"B1_REVATU")
	dbSelectArea("SG1")
	dbSetOrder(1)
	MsSeek(xFilial('SG1')+cCod2,.T.)
	While !Eof() .And. SG1->G1_FILIAL+SG1->G1_COD <= xFilial('SG1')+cCod2
	    cEmpenho:= ""
	    cFantasm:=Posicione("SB1",1,XFILIAL("SB1")+SG1->G1_COMP,"B1_FANTASM")
	    cLocaliz:=Posicione("SB1",1,XFILIAL("SB1")+SG1->G1_COMP,"B1_LOCALIZ") 
	    cEmpenho := Posicione("SD4",2,XFILIAL("SD4")+padr(cOP,13)+SG1->G1_COMP+cProc,"D4_COD") //VERIFICA SE ESTA EMPENHADO   
		IF LEFT(G1_COMP,3)=="MOD" .OR. cFantasm=="S"  
			dbskip()
			LOOP
		endif
		nQuanttemp := aHrs[poshra]
		nNeces := nQtdpc - aHrs[poshra] 
		nQuantItem := ExplEstr(nNeces,,cOPC,cRev)
		dbSelectArea("SG1")
		nQuanttemp := ExplEstr(nQuanttemp,,cOPC,cRev)
		IF cLocaliz=="S"
		 nSaldo:= posicione("SBF",5,XFILIAL("SBF")+SG1->G1_COMP+space(6)+cLinha,"BF_QUANT")
		ELSE
		 nSaldo:= posicione("SB2",1,XFILIAL("SB2")+SG1->G1_COMP+cProc,"B2_QATU")
		ENDIF 
		nSaldo:= nSaldo - nQuanttemp  
		if nSaldo-nQuantItem<0    
		    cDesc := ALLTRIM(G1_COMP)+'-'+ALLTRIM(Posicione("SB1",1,XFILIAL("SB1")+SG1->G1_COMP ,"B1_DESC"))
		    cDesc := left(cDesc,25)
		    IF ALLTRIM(cEmpenho)<>alltrim(SG1->G1_COMP)
		      cDesc := alltrim(SG1->G1_COMP)+"- Nao foi empenhado" 
		      nQuantItem := 0
		    Endif
			cText+='<tr>'+;
			'<td align="left"><font color="blue">'+cDesc+'</font></td>'+;
			'<td align="center"><font color="blue">'+STR(nQuantItem,4)+'</font></td>'+;
			'<td align="center"><font color="blue">'+STR(nSaldo,4)+'</font></td>'+;
			'</tr>'
		endif
		dbskip()
	Enddo
	cText+='</table>'
Return(cText)

Static Function LoteOP()
Local cText
Local nlotes:=0
cText:='<p>Acompanhamento de Lotes</p>'+;
			'<table>'+;
			'<tr>'+;
			'<td align="left" width="75%" bgcolor="#FFFF87">Lote</td>'+;
			'<td align="center" width="10%" bgcolor="#FFFF87">Produzido</td>'+;
			'</tr>'
cAliasZ04:= GetNextAlias()
 BeginSql Alias cAliasZ04 
  SELECT Z04_LOTE,isnull(sum(Z04_QUANT),0) AS Z04_QUANT FROM %Table:Z04% WHERE Z04_FILIAL=%xFilial:Z04% 
  AND Z04_OP=%exp:cOP%  
  AND R_E_C_N_O_>0 AND D_E_L_E_T_<>'*'
  GROUP BY Z04_LOTE
  ORDER BY Z04_LOTE
 EndSql 
dbSelectArea(cAliasZ04)  
COUNT TO nlotes
dbgotop()                
Do While !eof()
 cText+='<tr>'+;
'<td align="left"><font color="blue">'+(cAliasZ04)->Z04_LOTE+'</font></td>'+;
'<td align="center"><font color="blue">'+str((cAliasZ04)->Z04_QUANT,4)+'</font></td>'+;
'</tr>'
 dbskip()
Enddo           
cText+='<tr>'+;
		'<td align="left" width="75%" bgcolor="#FFFF87">Qtd. Lotes</td>'+;
		'<td align="center" width="10%" bgcolor="#FFFF87">'+str(nlotes,4)+'</td>'+;
		'</tr>'
dbSelectArea(cAliasZ04) 
dbclosearea() 
Return(cText)

//Calcular a previsao de peças por hora prevista
Static Function CalcPRev()
    Local cmod 
	Local nRet   := 0
	Local ntempo       
	//cmod:=iif(left(cCod2,3)=="APP","MOD7902","MOD7903")
	//ntempo:=posicione("SG1",2,XFILIAL("SG1")+PADR(cmod,15)+cCod2  ,"G1_QUANT")  //TEMPO EM HORAS
	//npessoas :=iif(npessoas==0,posicione("SH1",1,XFILIAL("SH1")+strzero(val(cLm),6)  ,"H1_MAOOBRA"),npessoas)  //Quantidade de pessoas
	//nRet := ntempo/npessoas   
	//nRet := 1 / nRet  // 1 hora dividida pelo qtd de peças por minuto
	//nRet := int(nRet)    
   nRet := npessoas  //alterado para digitar a meta hora na linha 	
Return(nRet)


Static Function Z04inc()
Local cTime,cHour,cMin,cSecs 
cTime := Time() // Resultado: 10:37:17
cHour := strzero(HoraAtual(), 2 ) // Resultado: 10
cMin  := SubStr( cTime, 4, 2 ) // Resultado: 37
cSecs := SubStr( cTime, 7, 2 ) // Resultado: 17
cTime := cHour+":"+cMin+":"+cSecs
cDoc := IIF(nEtq==0 .or. len(alltrim(cDoc))==0,DocZ04(),cDoc)
 Begin Transaction
  dbSelectArea("Z04")
  RecLock("Z04",.T.)
  Z04->Z04_FILIAL=XFILIAL("Z04")
  Z04->Z04_DOC := cDoc
  Z04->Z04_OP := cOp
  Z04->Z04_LOTE := cLote  
  Z04->Z04_QUANT := 1
  Z04->Z04_DATA := dDia
  Z04->Z04_HORA := cTime
  Z04->Z04_STATUS :=.F.
  Z04->Z04_DOCD3 :=LEFT(cOp,6)+"0"+cHour   //SUGERINDO DOC PARA SD3 OP+HORA
  Z04->Z04_MOD := npessoas   
  MsUnlock()
 End Transaction
Return




Static Function DocZ04()
 Local nDc:=1
 Local cDocs
 cAliasZ04:= GetNextAlias()
 BeginSql Alias cAliasZ04 
  SELECT isnull(MAX(Z04_DOC),'000000000') AS Z04_DOC FROM %Table:Z04% WHERE Z04_FILIAL=%xFilial:Z04% 
  AND R_E_C_N_O_>0 AND D_E_L_E_T_<>'*' 
 EndSql 
dbSelectArea(cAliasZ04)  
dbgotop()
nDc+=VAL(SUBSTR((cAliasZ04)->Z04_DOC,1,9))
dbSelectArea(cAliasZ04) 
dbclosearea() 
cDocs:=STRZERO(nDc,9) 
Return(cDocs)


Static function prodhora(hora,dia)
Local nRet
nRet:=0
cAliasZ04:= GetNextAlias()
 BeginSql Alias cAliasZ04 
  SELECT isnull(sum(Z04_QUANT),0) AS Z04_QUANT FROM %Table:Z04% WHERE Z04_FILIAL=%xFilial:Z04% 
  AND Z04_OP=%exp:cOp% AND Z04_DATA=%exp:dtos(dia)% AND left(Z04_HORA,2)=%exp:hora% 
  AND R_E_C_N_O_>0 AND D_E_L_E_T_<>'*'
 EndSql 
dbSelectArea(cAliasZ04)  
dbgotop()
nRet:=(cAliasZ04)->Z04_QUANT
dbSelectArea(cAliasZ04) 
dbclosearea() 
Return(nRet)

Static function prodOp()
Local nRet
nRet:=0                                                                                   ¸
cAliasZ04:= GetNextAlias()
 BeginSql Alias cAliasZ04 
  SELECT isnull(sum(Z04_QUANT),0) AS Z04_QUANT FROM %Table:Z04% WHERE Z04_FILIAL=%xFilial:Z04% 
  AND Z04_OP=%exp:cOp%  
  AND R_E_C_N_O_>0 AND D_E_L_E_T_<>'*'
 EndSql 
dbSelectArea(cAliasZ04)  
dbgotop()
nRet:=(cAliasZ04)->Z04_QUANT
dbSelectArea(cAliasZ04) 
dbclosearea() 
Return(nRet)