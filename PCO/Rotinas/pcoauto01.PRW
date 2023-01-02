#include "totvs.ch"
#include "protheus.ch"
#include "rwmake.ch"

#IFNDEF CRLF
#DEFINE CRLF ( chr(13)+chr(10) )
#ENDIF

user function pcoauto01()

	Local aButton		:= {}
	Local aSay			:= {}
	Local nOpc			:= 0
	Local cCadastro		:= "Importação do Plano Mestre de Produção"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criacao da Interface                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd ( aSay , "Importação do Orcamento utilizando planilha excel como base" )
	aAdd ( aSay , "Atenção: o formato do arquivo deve ser .CSV")
	aAdd ( aSay , "A primeira linha deve conter o cabecalho :")
	aAdd ( aSay , " ORCAMENTO,VERSAO,CONTA,PERIODO,DATAFIM,DATAINI,CC,VALOR")
	aAdd ( aSay , "as data com formato aaaammdd Ex: 02/01/17-20170102" )

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

		ElseIf MsgBox("Confirma importação do Orcamento?", "Importação do Orcamento", "YESNO" )

			Processa( { |lEnd| impcsv(_cArqTab) } , "Importação do Orcamento" , "Importando do Orcamento" , .T. )

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

return

Static Function impcsv(_cArqTab)
	Local cLinha  := ""
	Local aCampos := {}
	Local aDados  := {}
	Local aCab   := {}   //dias do plano mestre de produção
	Local aAutoCab, aAutoItens,i
	Local lImp :=.T.
	Private Itenschk := {}
	Private cTexto := ""
	Private opc :=""
	Private lMsHelpAuto := .T.
	Private lMsErroAuto := .F.
	Private aErro := {}
	Private contaant,ccant
	ProcRegua(3) // Numero de processos/sub-processos

	FT_FUSE(_cArqTab)
	//ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	IncProc("Realizando leitura do arquivo ...")		//1o.
	cLinha := FT_FREADLN()
	If !FT_FEOF()
		While !FT_FEOF()
			if lImp
				AADD(aCab ,Separa(cLinha,";",.T.))
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
	aDados:=Asort(aDados,,,{|x,y|x[3]+x[5]<y[3]+y[5]})  //organiza por conta e centro de custos
	IncProc("Importando dados ...")		//2o.

	ProcRegua(0)
	For i:=1 to Len(aDados)
		IncProc("Importando Produto ..."+ aDados[i,1])
		aAutoCab :={{"AK2_ORCAME",aDados[i,1],nil},;
		{"AK2_VERSAO",strzero(val(aDados[i,2]),4),nil}, ;
		{"AK2_CO",aDados[i,3],nil};
		}
		aAutoItens :={}
		p01:=p02:=p03:=p04:=p05:=p06:=p07:=p08:=p09:=p10:=p11:=p12:=0
		IF i<Len(aDados)
		    contaant := aDados[i,3]
		    ccant := aDados[i,5]
		    i_ant := i
			do while contaant+ccant==aDados[i,3]+aDados[i,5] .and. i<=Len(aDados)
			    nVal := val(StrTran(aDados[i,6] ,",","."))
			    IncProc("Importando Produto ..."+ aDados[i,1])
				mes := val(substr(aDados[i,4],5,2))
				if mes== 1
					p01 := nVal ; elseif mes== 2 ; p02 := nVal ; elseif mes== 3 ; p03 := nVal
				elseif mes== 4 ; p04 := nVal ; elseif mes== 5 ; p05 := nVal ; elseif mes== 6 ; p06:= nVal
				elseif mes== 7 ; p07 := nVal ; elseif mes== 8 ; p08 := nVal ; elseif mes== 9 ; p09:= nVal
				elseif mes==10 ; p10 := nVal ; elseif mes==11 ; p11 := nVal ; elseif mes==12 ; p12:= nVal
				endif
				i:=i+1
				if i>Len(aDados)
					exit
				endif
			enddo

			aAdd(aAutoItens,{ {'AK2_ORCAME' ,aDados[i_ant,1] , NIL},;
			{'AK2_VERSAO' ,strzero(val(aDados[i_ant,2]),4), NIL},;
			{'AK2_CO' ,aDados[i_ant,3] , NIL},;
			{'AK2_ID' ,'*', NIL},;
			{'AK2_CLASSE' ,'000001' , NIL},;
			{'AK2_CC' ,aDados[i_ant,5] , NIL},;
			{'P01' ,p01 , NIL},; //primeiro período
			{'P02' ,p02 , NIL},; //segundo período
			{'P03' ,p03 , NIL},;
			{'P04' ,p04 , NIL},;
			{'P05' ,p05 , NIL},;
			{'P06' ,p06 , NIL},;
			{'P07' ,p07 , NIL},;
			{'P08' ,p08 , NIL},;
			{'P09' ,p09 , NIL},;
			{'P10' ,p10 , NIL},;
			{'P11' ,p11 , NIL},;
			{'P12' ,p12 , NIL};
			} )

			MSExecAuto( {|x,y,z,a,b,c| PCOA100(x,y,z, a, b, c)}, 4/*nCallOpcx*/,/*cRevisa*/, /*lRev*/, /*lSim*/,aAutoCab, aAutoItens) //4=alteração para manipular itens da planilha
			
			If lMsErroAuto
				msgalert("Erro na inclusao da Conta :"+contaant+" C.C: "+ccant +" !")
				MostraErro()
			EndIf
			lMsErroAuto := .F.
		endif
	Next

	FT_FUSE()
	IncProc("Finalizando processo...")	//3o.
	ApMsgInfo("Importação do plano foi concluida com sucesso!","[PCOAUTO01] - SUCESSO")

Return