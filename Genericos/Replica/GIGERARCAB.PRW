#include "protheus.ch"
#include "tbiconn.ch"
#include "rwmake.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGIGERARCABบAutor  ณDenis Polastri      บ Data ณ  18/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera replica de base via workflow                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGama Italy                    						      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function GIGERARCAB( _aParam )

Private lWorkFlow := IIF( _aParam = Nil , .F. , .T. )
Private lGeraArq  := .F.
Private cArqMail  := ""

If lWorkFlow
	PREPARE ENVIRONMENT EMPRESA _aParam[1] FILIAL _aParam[2]
	Private ARQLOG    := "\AUTOCOM\TEF" + _aParam[1] + _aParam[2] + "\GIGERARCAB.LOG"
	LjWriteLog( ARQLOG, Replicate("-",100) )
	LjWriteLog( ARQLOG, "Inicio da fun็๕ao GIGERARCAB()" )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ  Verifica se existe arquivo HTML em \system\workflow\WFArqBranco.htm  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ArqHTML()
	If lGeraArq
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ  Executa a gera็ใo do arquivo  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		RUNCONT()
	EndIf
Else
	Private ARQLOG    := "\AUTOCOM\TEF" + cEmpAnt + cFilAnt + "\GIGERARCAB.LOG"
	LjWriteLog( ARQLOG, Replicate("-",100) )
	LjWriteLog( ARQLOG, "Inicio da fun็๕ao GIGERARCAB()" )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ  Verifica se existe arquivo HTML em \system\workflow\WFArqBranco.htm  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	ArqHTML()
	If lGeraArq
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ  Executa a gera็ใo do arquivo  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		Processa( {|| RUNCONT() },"Processando Envio de Arquivos ..." )
	EndIf
Endif

If lGeraArq
	LjWriteLog( ARQLOG, "Chama fun็ใo para enviar o arquivo "+cArqMail )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ  Chama funcao que envia o arquivo *.CAB  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	U_GIENVIACAB(1,cArqMail)
EndIf

LjWriteLog( ARQLOG, "Fim de execu็ใo da fun็ใo GIGERARCAB()" )
LjWriteLog( ARQLOG, Replicate("-",100) )

If lWorkFlow
	RESET ENVIRONMENT
EndIf
	
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRunCont() บAutor  ณDenis Polastri      บ Data ณ  18/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExecuta reracao da replica de base via workflow.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGama Italy                    						      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function RUNCONT()

	Local _cArqObr     := ""
	Local nContTab     := 0
	Local nTabDel      := 0
	Local _xCampo,_xCnt, x
	
	Private _cModo     := Alltrim(GetMv("MV_WFMODMF",,"M"))
	Private _cNomencl  := ""
	Private _nDiaDelet := 0
	Private _cLista	   := {}
	Private cStatusWF  := AllTrim(GetMv("MV_STATUWF",,"IMPORTADO"))

	LjWriteLog( ARQLOG, "Verifica a fun็ใo estแ rodando na [M]atriz ou [F]ilial: ["+_cModo+"]" )
	LjWriteLog( ARQLOG, "Verifica parโmetro de Status para proceguir ou nใo a gera็ใo dos arquivos." )
	LjWriteLog( ARQLOG, "Conte๚do do parโmetro MV_STATUWF: "+If(Empty(cStatusWF),"vazio",cStatusWF) )
	
	If cStatusWF == "GERADO"
		LjWriteLog( ARQLOG, "Erro na sequencia de envio/recebimento, verifique o parโmetro de status MV_STATUWF e o parโmetro de sequencia MV_SEQENV" )
		LjWriteLog( ARQLOG, "* * * PROCESSAMENTO BLOQUEADO * * *" )
		lGeraArq := .F.
		U_GIENVIACAB( 4,"","Erro na sequencia, verifique MV_STATUWF e MV_SEQENV" )
		Return
	Endif

	_cCaminho := Alltrim(GetMv("MV_GIFWENV",,"\SYSTEM\WF"+cEmpAnt+"\ENVIA\"))
	If Substr(_cCaminho,Len(_cCaminho),1) != "\"
		_cCaminho := _cCaminho +"\"
	Endif
	U_GiCriaDir(_cCaminho)
	
	_cCaminhoBk:= Alltrim(GetMv("MV_GIFWENB",,"\SYSTEM\WF"+cEmpAnt+"\ENVBKP\"))
	If Substr(_cCaminhoBk,Len(_cCaminhoBk),1) != "\"
		_cCaminhoBk := _cCaminhoBk + "\"
	EndIF
	U_GiCriaDir(_cCaminhoBk)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ  Monta a nomenclatura  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	_cNomencl := PegaNome()
	LjWriteLog( ARQLOG, "Ultimo Envio " + GetMv("MV_SEQENV",,"000000") )
	LjWriteLog( ARQLOG, "Arquivo temporario: " + _cNomencl )
	LjWriteLog( ARQLOG, "Iniciando envio de dados ..." )
	LjWriteLog( ARQLOG, "Caminho: "+_cCaminho )
	LjWriteLog( ARQLOG, "[L]oja ou [M]atriz : "+_cModo )

	_cLista := Directory( _cCaminho + "*.*" )
	_cAtrib := "Attrib -r "+_cCaminho+"*.*"
	If !lWorkFlow 
		WaitRun(_cAtrib,0)
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Limpa a pasta antes de inicar a execucao da transmissao ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	LjWriteLog( ARQLOG, "Limpando pasta de envio ... " )
    
	If Len(_cLista) > 0
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ  Faz backup dos aqquivos ja enviados e limpa pasta para novos arquivos  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !U_BkpFiles(1,.T.,.F.)
			lGeraArq := .F.
			U_GIENVIACAB( 4,"","Existem arquivos na pasta ENVBKP." )
			Return
		Endif
	EndIf
	
	LjWriteLog( ARQLOG, "Verifica quantidade de tabelas a serem copiadas" )
	cQuery := "SELECT COUNT(X5_CHAVE) TOTAL FROM " + RetSQLName("SX5") + " WHERE X5_FILIAL = '" + xFilial("SX5") + "'"
	cQuery += " AND X5_TABELA   = 'X1' AND D_E_L_E_T_ <> '*'"
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB", .F., .T.)
	_nTotal:= TRB->TOTAL
	DbCloseArea()
    
	LjWriteLog( ARQLOG, "Serใo copiadas "+CValToChar(_nTotal)+" tabelas." )
	DbSelectArea("SX5")
	If !lWorkFlow
		ProcRegua(_nTotal)
	EndIf

	DbSetOrder(1)
	MsSeek( xFilial("SX5") + "X1" )

	_aTabAlias 	:= {}
	_cTabEnv	:= ""

	LjWriteLog( ARQLOG, "Armazenando tabelas a serem enviadas." )
	While !Eof() .And. SX5->X5_FILIAL == xFilial("SX5") .And. SX5->X5_TABELA == "X1"
		If !lWorkFlow
			IncProc("Armazenando tabelas a serem enviadas ...")
		EndIf
		If !Empty(SX5->X5_CHAVE)            
			SX2->( DbSetOrder(1) )
			SX2->( DbSeek(Alltrim(SX5->X5_CHAVE)) )
			AAdd( _aTabAlias,{ Alltrim(SX5->X5_CHAVE),Capital(RTrim(SX2->X2_NOME)) } )
			_cTabEnv += SX5->X5_CHAVE
			nContTab++
		Endif 
		DbSelectArea("SX5")    
		DbSkip()
	EndDo

	LjWriteLog( ARQLOG, "Tabelas a serem enviadas: "+_cTabEnv )
	If Len(_aTabAlias) <=0
		If !lWorkFlow
			MsgBox("Nao ha dados a serem processados, verificar tabelas no SX5.","Atencao","Info")
		EndIf
		LjWriteLog( ARQLOG, "Nao ha dados a serem processados, verificar tabelas no SX5." )
		lGeraArq := .F.
		U_GIENVIACAB( 4,"","Nao ha dados a serem processados, verifiquear tabelas no SX5." )
		Return
	Endif
	
	LjWriteLog( ARQLOG, "Carregando tabelas para serem exportadas." )
	For _xCnt := 1 to Len(_aTabAlias)

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Inicializacao das variaveis e tratamento do campo de controle _MSEXP e FILIAL ณ
		//ณ  Verificar qual o codigo da empresa da Gama Italy                             ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		_EControle := ".0" + cFilAnt

		_Msg        := _aTabAlias[_xCnt,1]+" - "+AllTrim(Upper(_aTabAlias[_xCnt,2]))
		_xAliasSiga := _aTabAlias[_xCnt,1]
		CHKFILE(_xAliasSiga)
		_cArqDbfTmp := _xAliasSiga + _cNomencl + _EControle
		_xAliasDBF	:= "X" + Substr(_xAliasSiga,2,2)
		_cArqNtxTmp := CriaTrab(Nil,.F.)
		_cPath      := _cCaminho

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ  Carrega tabelas de cadastro no SX5  ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		_cArqObr := ""
		SX5->( DbSetOrder(1) )
		SX5->( MsSeek( xFilial("SX5") + "X1" ) )
		While SX5->( !Eof() .And. X5_TABELA == "X1" )
			_cArqObr += AllTrim(SX5->X5_CHAVE) + "/"
			SX5->( DbSkip() )
		EndDo

		If "S" == Substr(_xAliasSiga,1,1)
			_cCpoExp  := Substr(_xAliasSiga,2,2) + "_MSEXP"
			_cIndCond := Substr(_xAliasSiga,2,2) + "_FILIAL"
		Else
			_cCpoExp  := _xAliasSiga + "_MSEXP" 
			_cIndCond := _xAliasSiga + "_FILIAL"
		Endif
          
		Delete File &(_cPath+_cArqDbfTmp)
		DbSelectArea(_xAliasSiga)
       
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Cria campo para identificar os registros deletados ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		_aStruct := DbStruct()
		AAdd(_aStruct,{"SEQRECNO","N",15,0})
		AAdd(_aStruct,{"DELETADO","C",1,0})

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Avalia se o Arquivo em questao tem os campos de controle de Inclusao e Alteracao ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		_xOkMsExp := aScan( _aStruct,{ |x| Alltrim(x[1]) == Alltrim(_cCpoExp) } ) 
       
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ So processa os Arquivos caso o mesmo tenha os campos de controle ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If _xOkMsExp != 0 
                
			DbCreate(_cPath+_cArqDbfTmp,_aStruct)
       		DbUseArea(.T.,,_cPath+_cArqDbfTmp,_xAliasDBF,.T.,.F.)
               
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Permite visualizar inclusive os registros deletados do Arquivo ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			DbSelectArea(_xAliasSiga)
	        Set(11,"OFF")

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Filtra os registros para exportacao.                             ณ
			//ณ Somente os registros alterados ou incluidos XX_MSEXP = dDataBase ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			If ( Alltrim(_xAliasSiga) $ _cArqObr )
				cQuery := "SELECT * FROM " + RetSqlName(_xAliasSiga)
				cQuery += " WHERE R_E_C_N_O_ > 0 "
				cQuery += "   AND "+ _cCpoExp +" = '        ' "
				//cQuery += "   OR  "+ _cCpoExp +" = '"+DtoS(dDataBase)+"' "
			    If Alltrim(_xAliasSiga) != "SM2"
				    cQuery += "ORDER BY "+_cIndCond
				Else
					cQuery += "ORDER BY M2_DATA"
				EndIf
			    cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TEMP", .F., .T.)			     			
			Endif
            
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ  Verifica quantidade de registros, se for ZERO, nao faz nada e pula pro proximo  ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
            nReg    := 0
			Count To nReg
			If nReg == 0
				TEMP->( DbCloseArea() )
				LjWriteLog( ARQLOG, "A tabela: "+_xAliasSiga+" nใo tem movimentos para exportar, verifique a data no campo XX_MSEXP." )
				If Select(_xAliasDBF) > 0
					(_xAliasDBF)->( DbCloseArea() )
				EndIf
				If File(_cPath+_cArqDbfTmp)
					FErase(_cPath+_cArqDbfTmp)
					nTabDel++
				EndIf
				Loop
			EndIf
			If !lWorkFlow
				ProcRegua( nReg )
			EndIf
						
			TEMP->( DbGoTop() )
			While TEMP->( !Eof() )

				If !lWorkFlow
					IncProc(_Msg)
				EndIf
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Marca a data que identifica que os registros foram enviados ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				&(_xAliasSiga)->( dbGoto(TEMP->R_E_C_N_O_) )

				RecLock(_xAliasSiga,.F.)
    	        FieldPut(FieldPos(_cCpoExp),Dtos(dDataBase))
    			MsUnLock()

				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณIdentifica que o registro em questao esta deletado ou nao ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
        	    _xRegDel := IIf(Deleted(),"S","") 
                    
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Abre Arquivo Temporario e inclui os registros inclusive os deletados ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
    	        DbSelectArea(_xAliasDBF)
				RecLock(_xAliasDBF,.T.)

				For _xCampo := 1 to ( Len(_aStruct) -2 )

    	        	DbSelectArea(_xAliasSiga)
	    	        _xConteudo := FieldGet(_xCampo)

    	    	    DbSelectArea(_xAliasDBF)
        	    	FieldPut(FieldPos(_aStruct[_xCampo][1]),_xConteudo )

    	        Next _xCampo
				          	  
				FieldPut(FieldPos(_aStruct[Len(_aStruct)][1]),_xRegDel)
			
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณ Obtem o numero do recno para comparacao na matriz ณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				_xArea := GetArea()
				DbSelectArea(_xAliasSiga)
				_nRecno := Recno()
				RestArea( _xArea )		
				
				FieldPut(FieldPos("SEQRECNO"),_nRecno)						
				//FieldPut(FieldPos(_cCpoExp),"ENV"+SM0->M0_CODFIL)
				FieldPut(FieldPos(_cCpoExp), StrTran(DToC(MsDate()),"/","")+SubStr(Time(),1,2) )

	            MsUnLock()                                         
				ProcessMessages()
				
				TEMP->( DbSkip() )
                     
			Enddo
        
			DbSelectArea(_xAliasDBF)
			DbCloseArea()

			TEMP->( dbCloseArea() )

		Else
			LjWriteLog( ARQLOG, "Nao existe os campos de controle da tabela, " + _Msg )
			If !lWorkFlow
    	    	MsgInfo("Nao existe os campos de controle da tabela, " + _Msg , "Atencao" , "Info" )
    	    EndIf
		Endif

		FErase(_cArqNtxTmp+OrdBagExt())

	Next _xCnt
    
	If nContTab == nTabDel
		LjWriteLog( ARQLOG, "Nใo existem movimentos para serem exportados, verifique os campos XX_MSEXP das tabelas." )	
		lGeraArq := .F.
		If !lWorkFlow
   	    	MsgInfo("Nใo existem movimentos para serem exportados, verifique os campos XX_MSEXP das tabelas." , "Atencao" , "Info" )
   	    EndIf
		U_GIENVIACAB( 4,"","Nใo existem movimentos para serem importados." )
		Return
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Compacta os Arquivos gerados para envio ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	LjWriteLog( ARQLOG, "Compacta os arquivos gerados para envio." )
	SX6->( DbSetOrder(1) )
	SX6->( MsSeek( xFilial("SX6") + "MV_SEQENV" ) )
	_cNumSeq := If( Empty(SX6->X6_CONTEUD),"000000",SX6->X6_CONTEUD )
    _cNumSeq := StrZero((Val(GetMv("MV_SEQENV",,_cNumSeq))+1),6)
	_cLista  := Directory( _cCaminho +"???"+_cNumSeq+".*" )
	_nTotArq := Len(_cLista)
	_cZIP 	 := _cCaminho + Upper(_cModo)+"-"+ cFilAnt + _cNumSeq + ".CAB"
	cArqMail := Upper(_cModo)+"-"+ cFilAnt + _cNumSeq
	_lTudoOK := .T.		
	_aFiles	 := {}
	
	For x := 1 to Len(_cLista)
		aAdd( _aFiles , RTrim(_cCaminho+_cLista[x,1]) )
	Next
   
	_lZipou := MSCompress( _aFiles , _cZIP )
	
	If _lZipou == ""
		_lTudoOK := .F.
		lGeraArq := .F.
		_cMsg1 	 := "Ocorreram problemas na compactacao do arquivo de envio. Por medida de seguranca a sequencia nใo serแ avan็ada."
		_cMsg1   += "Favor entrar em contato com o suporte e informe que o arquivo nใo pode ser compactado."
		LjWriteLog( ARQLOG , _cMsg1 )
		If !lWorkFlow
			MsgStop( _cMsg1 , "Problemas na compactacao ..." , "ALERT" )
		EndIf
		U_GIENVIACAB( 4,"","Erro na compactacao do arquivo CAB." )
		Return
	Endif
	LjWriteLog( ARQLOG , "Arquivo Compactado: " + _cZIP )

	PutMv( "MV_SEQENV" , StrZero(Val(_cNumSeq),6) )

	LjWriteLog( ARQLOG, "Ajustando Sequencia para : " + _cNumSeq )
	LjWriteLog( ARQLOG, "Foi gerado o arquivo " + cArqMail + " com sucesso !")
	lGeraArq := .T.

	Set(11,"ON")	

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCAO    ณPegaNome()บAutor  ณDenis Polastri      บ Data ณ  18/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณObtem o nome do arquivo CAB                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function PegaNome()

	SX6->( DbSetOrder(1) )
	SX6->( MsSeek( xFilial("SX6") + "MV_SEQENV" ) )
	_cNumSeq  := If( Empty(SX6->X6_CONTEUD),"000000",SX6->X6_CONTEUD )
    _cNumSeq  := StrZero((Val(GetMv("MV_SEQENV",,_cNumSeq))+1),6)
	_Controle := IIf(_cNumSeq == "999999","000000",_cNumSeq)
                                           
Return( _Controle )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCRIADIR   บAutor  ณDenis Polastri      บ Data ณ  31/01/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria um diretorio apartir do diretorio recebido             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gama Italy                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function GiCriaDir(_cDir)
If !ExistDir("\SYSTEM\WF"+cEmpAnt)
	MakeDir("\SYSTEM\WF"+cEmpAnt)
EndIf
If !ExistDir(_cDir)
	MakeDir(_cDir)
EndIf
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณArqHTML   บAutor  ณDenis Polastri      บ Data ณ  03/02/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se existe arquivo html para envio de email         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGama Italy                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ArqHTML()
Local cArqHTML := "\workflow\WFArqBranco.htm"
	If !File(cArqHTML)
		LjWriteLog( ARQLOG, "Nao existe o arquivo "+cArqHTML )
		LjWriteLog( ARQLOG, "Gera็ใo abortada!" )
		lGeraArq := .F.
	Else
		lGeraArq := .T.
	EndIF
Return