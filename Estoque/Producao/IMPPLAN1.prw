#include "totvs.ch"
#include "protheus.ch"
#include "rwmake.ch"

#IFNDEF CRLF
	#DEFINE CRLF ( chr(13)+chr(10) )
#ENDIF

User Function IMPPLAN1()
	Local aButton		:= {}
	Local aSay			:= {}
	Local nOpc			:= 0
	Local cCadastro		:= "Importação do Plano Mestre de Produção"
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criacao da Interface                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd ( aSay , "Importação do Plano Mestre de Produção diario utilizando planilha excel como base" )
	aAdd ( aSay , "Atenção: o formato do arquivo deve ser .CSV")
	aAdd ( aSay , "A primeira linha deve conter o cabecalho : Produto, Opcionais e as datas ")
	aAdd ( aSay , "com formato dd/mm/aaaa " )
	aAdd ( aSay , "As demais deverao conter os produtos ,opcionais e as quantidades nas datas conforme")
	aAdd ( aSay , "o cabecalho")
    
	aAdd ( aButton , { 1 , .T. , { || nOpc := 1,	FechaBatch()	}} )
	aAdd ( aButton , { 2 , .T. , { || FechaBatch()					}} )

	FormBatch( cCadastro , aSay , aButton )

	If nOpc == 1

		_cArqTab 	:= cGetFile("Arquivos |*.CSV|Todos os Arquivos|*.*",OemToAnsi("Selecione o arquivo")) //,0,,.T.,GETF_OVERWRITEPROMPT)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verificando se o processo ira ser continuado                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if !File(_cArqTab)

			MsgBox("O arquivo nao foi localizado. O PROCESSO NAO PODERA SER INICIADO.","ATENCAO","ERRO")

		ElseIf MsgBox("Confirma importação do Plano Mestre de Produção?", "Importação do Plano Mestre de Produção", "YESNO" )

			Processa( { |lEnd| impcsv(_cArqTab) } , "Importação do Plano Mestre de Produção" , "Importando Plano Mestre de Produção" , .T. )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ renomeando o arquivo lido                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			fClose( _cArqTab )
			nDotPos := At( ".", _cArqTab )
			if nDotPos > 0
				_cNewArqTab := Substr( _cArqTab, 1, nDotPos ) + "ok"
				__CopyFile( _cArqTab, _cNewArqTab )
			endif
			fErase( _cArqTab )
		Else
			MsgBox("O arquivo nao foi localizado. O PROCESSO NAO PODERA SER INICIADO.","ATENCAO","ERRO")
		Endif

	Endif

Return()

Static Function impcsv(_cArqTab)
	Local cLinha  := ""
	Local aDados  := {}
	Local aDias   := {}   //dias do plano mestre de produção
	Local lImp :=.T.
	Local i, j
	Private Itenschk := {}
	Private cTexto := ""
	Private opc :=""

	Private aErro := {}
	ProcRegua(3) // Numero de processos/sub-processos

	FT_FUSE(_cArqTab)
	//ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	IncProc("Realizando leitura do arquivo ...")		//1o.
	cLinha := FT_FREADLN()
	If !FT_FEOF()
		While !FT_FEOF()
			if lImp
				AADD(aDias ,Separa(cLinha,";",.T.))
				lImp :=.F.
			else
				cLinha := FT_FREADLN()
				AADD(aDados,Separa(cLinha,";",.T.))
			endif
			FT_FSKIP()
		EndDo
	Else
		MsgBox("O arquivo de nome " + AllTrim(_cArqTab) + " está vazio!","Atencao!")
	Endif
	IncProc("Importando dados ...")		//2o.
	//Begin Transaction
	ProcRegua(Len(aDados))
	cTexto+=analisaSB1()
	if len(alltrim(cTexto))==0
	 For i:=1 to Len(aDados)
		IncProc("Importando Produto ..."+ aDados[i,1])
		For j:=3 to Len(aDias[1])
			dbSelectArea("SHC")
			dbSetOrder(1)
			dbGoTop()
			dbSeek(xFilial("SHC")+dtos(ctod(aDias[1,j]))+aDados[i,1])
			hab := .T.
			if !(eof())
			  while ALLTRIM(aDados[i,1]) == ALLTRIM(SHC->HC_PRODUTO)
			    IF  ALLTRIM(SHC->HC_DOC)==aDados[i,2] //"PDR"+SubStr(dtos(ddatabase),1,6)
			     hab := .F.
			    ENDIF
			    SHC->( dbskip() )
			  enddo
			endif
			If (hab .and. val(aDados[i,j])>0 )
			    opc :="" 
			     dbSelectArea("SHC")
				 Reclock("SHC",.T.)
				 SHC->HC_FILIAL := xFilial("SHC")
				 SHC->HC_DOC    := aDados[i,2]//"PDR"+SubStr(dtos(ddatabase),1,6)
				 SHC->HC_PRODUTO:= aDados[i,1]
				// SHC->HC_OPC    := POSICIONE("SB1",1,xFilial("SB1")+aDados[i,1],"B1_OPC")//aDados[i,2]
				 SHC->HC_QUANT  := val(aDados[i,j])
				 SHC->HC_DATA   := ctod(aDias[1,j])
				 //SHC->HC_MOPC   := POSICIONE("SB1",1,xFilial("SB1")+aDados[i,1],"B1_OPC")//aDados[i,2]
				 SHC->(MsUnlock())
				 if(Ascan(Itenschk,aDados[i,1])==0)
				  aadd(Itenschk,aDados[i,1])
                  cTexto+=analisar(aDados[i,1])  				  
				 EndIf
				 dbSelectArea("SHC")
			EndIf
		Next j
	 Next i
	//End Transaction
	Else 
	 Alert("Erro de Desbalanceamento de cadastro !! Corrija antes de importar a Demanda") 
	Endif 
	FT_FUSE()
	IncProc("Finalizando processo...")	//3o.
	ApMsgInfo("Importação do plano foi concluida com sucesso!","[IMPPLAN1] - SUCESSO")

	If !Empty(cTexto)
		Aviso("Atencao","Existem itens que nao entrarao no MRP!",{"OK"})
		U_GRVTXT(CTEXTO)
		oFont:= TFont():New("COURIER NEW",07,15)
		@ 000,000 To 300,700 Dialog oDlgMemo Title "Produtos sem Saldo"
		@ 001,003 Get cTexto Size 340,130  MEMO Object oMemo When .F.
		oMemo:oFont:=oFont
		@ 140,170 BmpButton Type 1 Action CLOSE(oDLGMEMO) Object oConf
		Activate Dialog oDlgMemo CENTERED On Init (oMemo:SetFocus())
	EndIf

Return                       

static Function analisaSB1()
Local cret:=""
cAliasSG1:= GetNextAlias()
BeginSql Alias cAliasSG1
 SELECT B1_DESC,SG1.* FROM  %table:SG1%  SG1
 LEFT OUTER JOIN %table:SB1% SB1 ON B1_COD=G1_COMP AND SB1.%NotDel%
 WHERE B1_DESC IS NULL AND SG1.%NotDel% AND SG1.G1_INI>='20160101'
EndSql
dbSelectArea(cAliasSG1)
(cAliasSG1)->(dbgotop())
cDesbalanceados:=""
DO WHILE !EOF()
  if len(alltrim(cret))==0
    cret+="Existem itens Desbalanceados entre SG1 - ESTRUTURA e SB1 - CAD.PROD que impediram o processamento do MRP : "+CRLF
    cret+="Item Pai: _______________________     Comp s/cadastro: ________________________"+CRLF
  endif
  cret+= (cAliasSG1)->G1_COD+ space(10)+(cAliasSG1)->G1_COMP +CRLF
  dbskip()
Enddo
if len(alltrim(cret))>0
  cret+="Erro GRAVISSIMO !!! INFORMAR A AREA TI" +CRLF
  cret+="------------------------------------------------------------------"  +CRLF
endif
dbSelectArea(cAliasSG1)
dbclosearea()
Return(cret)

static Function analisar(prdto)
	Local cret:=""
	Local prod := prdto 
	Local x
	Private nEstru := 0
	aEstrutura  := {}
	aEstru  := Estrut(padr(prod,15),1,.F.)
	cret+="Analise Produto : "+prod+" - "+POSICIONE("SB1",1,xFilial("SB1")+prod,"B1_DESC")+REPL("-",20)+CRLF
	For x := 1 to Len(aEstru)
		nNivel     := aEstru[x,1]
		cFilho     := PADR(aEstru[x,3],15)
		cPaiTemp   := aEstru[x,2]
		cRev := POSICIONE("SB1",1,xFilial("SB1")+aEstru[x,2],"B1_REVATU") 
		cDescFilho := POSICIONE("SB1",1,xFilial("SB1")+cFilho,"B1_DESC")
		cUM        := POSICIONE("SB1",1,xFilial("SB1")+cFilho,"B1_UM")
		cTipo      := POSICIONE("SB1",1,xFilial("SB1")+cFilho,"B1_TIPO")
		cLocpad    := POSICIONE("SB1",1,xFilial("SB1")+cFilho,"B1_LOCPAD")
		cFantasma  := POSICIONE("SB1",1,xFilial("SB1")+cFilho,"B1_FANTASM")
		isMRP      := iif(POSICIONE("SB1",1,xFilial("SB1")+cFilho,"B1_MRP")=="S",.T.,.F.)
		dDataFim   := POSICIONE("SG1",1,xFilial("SG1")+cPaiTemp+cFilho,"G1_FIM")
		nrec := aEstru[x,8]
		//-- trata opcional 
		 SG1->(DBGOTO(NREC))
		 cRevAtu:=SG1->G1_REVFIM 
		 IF len(ALLTRIM(SG1->G1_GROPC))>0 .AND. aEstru[x,4]<>0
		    cret+="OPC Componente "+cFilho+"Esta como opcional "+SG1->G1_GROPC+"/"+SG1->G1_OPC+CRLF
		 ENDIF
		//-------------------------------------- 		
		//IF cFantasma=='S' .AND. dDataFim > ddatabase .and. cTipo$"PI/SA" .and. aEstru[x,4]>0
		//ENDIF
		IF  cTipo$"MP/EM" .and. cFantasma=="S"
		  IF ALLTRIM(cRev)==ALLTRIM(cRevAtu)
		  cret+="FAN Pai: "+cPaiTemp+" Componente: "+cFilho +" Item esta fantasma !"+CRLF
		  endif 
		Endif    
		IF !isMRP .and. cTipo$"MP/EM/PI/SA"
			if  cTipo$"PI/SA" .AND. ALLTRIM(cRev)==ALLTRIM(cRevAtu) 
			    cret+="MRPI Pai: "+cPaiTemp+" Componente: "+cFilho +" Item com cadastro MRP=N !  "
				cret+="Componentes do PI/SA Nao serão demandados -----;"+CRLF
				/*
 				 aEstruc  := Estrut(cFilho,1,.F.)
				 cRev := POSICIONE("SB1",1,xFilial("SB1")+aEstruc[x,2],"B1_REVATU") 
			     For x := 1 to Len(aEstruc)
				    SG1->(DBGOTO(NREC))
		            cRevAtu:=SG1->G1_REVFIM
		            IF ALLTRIM(cRev)==ALLTRIM(cRevAtu)
					 cret+="MRPI Cod: "+aEstruc[x,3]+" - "+ POSICIONE("SB1",1,xFilial("SB1")+aEstruc[x,3],"B1_DESC")+CRLF
					ENDIF 
				 Next
				*/ 
			ELSE 
			  IF ALLTRIM(cRev)==ALLTRIM(cRevAtu) 
			   cret+="MRP Pai: "+cPaiTemp+" Cod MRP=N: "+aEstru[x,3]+" - "+ POSICIONE("SB1",1,xFilial("SB1")+aEstru[x,3],"B1_DESC")+CRLF
			  ENDIF 	
			endif
		Endif
		If isMRP .and. cTipo$"MP/EM/PI/SA" .and. cFantasma=="N" .and. ALLTRIM(cRev)==ALLTRIM(cRevAtu) .and. aEstru[x,4]==0
		  cret+="VENC Pai: "+aEstru[x,2]+" Cod Vencido: "+aEstru[x,3]+" - "+ POSICIONE("SB1",1,xFilial("SB1")+aEstru[x,3],"B1_DESC")+CRLF
		Endif
		
	Next
    cret+="FIM Analise Produto : "+prod+REPL("-",40)+CRLF+CRLF
 Return(cret)
