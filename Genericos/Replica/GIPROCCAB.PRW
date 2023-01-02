#include "rwmake.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "tbicode.ch"
#include "colors.ch"
//#include "color.ch"
#include "font.ch"
#include "ap5mail.ch"  
#DEFINE  ARQLOG "\AUTOCOM\TEF" + cEmpAnt + cFilAnt + "\GIPROCCAB.LOG"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GiProcCab ºAutor  ³Denis Polastri      º Data ³  18/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Recepcao dos arquivos de movimento via WorkFlow Gama Italy  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function GIPROCCAB (cAssunto)    
	Private cLck2		:= "\system\WFGMMAIL"+cEmpAnt+".LCK"
	Private cLck		:= "\system\WFLJPROC"+cEmpAnt+".LCK"
	LjWriteLog( ARQLOG, Replicate("-",100) )
	LjWriteLog( ARQLOG, "Inicio da função de processamento de arquivos CAB - GIPROCCAB()" )
	If !File(cLck) .And. !File(cLck2)
	    Private _aAreaM0 	:= GetArea()  
		DbSelectArea("SM0")
		LjWriteLog( ARQLOG, "Processa via workflow." )
		RUNCONT(cAssunto)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ *** SEMAFORO *** ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Delete File &(cLck)
		If File(cLck)
			_nTry := 1
			While File(cLck) .And. _nTry < 30
				Delete File &(cLck)
				_nTry := _nTry + 1
			End
			If _nTry >= 30
				_lDeleta := .F.
				LjWriteLog( ARQLOG, "Erro ao deletar arquivo de controle LCK" )
			Endif					
		Endif	
		DbSelectArea("SM0")
		RestArea( _aAreaM0 )
	Else
		LjWriteLog( ARQLOG, "Aguardando liberacao do SEMAFORO." )
		U_GIENVIACAB( 4 ,"", "Aguardando liberacao, arquivo *.LCK esta bloqueando sequencia." )
	Endif
	LjWriteLog( ARQLOG, "Final de execução da função de processamento de arquivos CAB" )
	LjWriteLog( ARQLOG, Replicate("-",100) )
Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GIPROCCAB ºAutor  ³Microsiga           º Data ³  03/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Executa a atualizacao da base de dados, atraves dos        º±±
±±º          ³ arquivos contidos no arquivo CAB                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RUNCONT(cAssunto)
	Local x,_xCont,_nLidos
	Local   _nPos        := 0
	Private _lAtuNSQ     := .F.
	Private _aArq        := {}
	Private _aTabAlias   := {}
	Private _aCodADM     := {}
	Private _aRollBack   := {}
	Private _cPath       := ""
	Private _cLojMat     := ""
	Private _cNomencl    := ""
	Private _cCompactado := ""
	Private _cNome       := ""
	Private _cNumSeq     := ""
	Private _xAliasSiga  := ""
	Private _cCaminho	 := ""
	Private _cCaminhoBk	 := ""
	Private _cCaminhoErr := ""
	Private _cLista		 := {}
	Private _cModo       := AllTrim(GetMv("MV_WFMODMF"))
	Private _cArqCons    := ""
	Private _cArqCad     := ""
	Private cEOL         := CHR(13)+CHR(10)
	Private _lOk		 := .T.
	
	LjWriteLog( ARQLOG, "Processando... "+cAssunto )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configuracoes ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cCaminho := AllTrim(GetMv("MV_GWRECEB",,"\SYSTEM\WF"+cEmpAnt+"\RECEBE\"))
	If Substr(_cCaminho,Len(_cCaminho),1) != "\"
		_cCaminho := _cCaminho+"\"
	Endif
	U_GiCriaDir(_cCaminho)
    
	_cCaminhoBK:= AllTrim(GetMv("MV_GWRECBK",,"\SYSTEM\WF"+cEmpAnt+"\RECBKP\")) // MV_WFRECBK
	If Substr(_cCaminhoBK,Len(_cCaminhoBK),1) != "\"
		_cCaminhoBK := _cCaminhoBK+"\"
	Endif
	U_GiCriaDir(_cCaminhoBK)

	_cCaminhoErr:= AllTrim(GetMv("MV_GWPENDT",,"\SYSTEM\WF"+cEmpAnt+"\PENDENTE\"))
	If Substr(_cCaminhoErr,Len(_cCaminhoErr),1) != "\"
		_cCaminhoErr := _cCaminhoErr+"\"
	Endif
	U_GiCriaDir(_cCaminhoErr)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Arquivos a Processar salvos no diretorio³
	//³ Caminho = "\TRF\RECEBE"                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_Dir := _cCaminho + "*.CAB"
	_cLista := Directory( _Dir )
	LjWriteLog( ARQLOG, "Lista arquivos no diretório de recebimento." )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Controle sequencial de importacao dos registros ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SX6->( DbSetOrder(1) )
	SX6->( MsSeek( xFilial("SX6") + "MV_SEQREC" ) )
	_cNumSeq := If( Empty(SX6->X6_CONTEUD),"000000",AllTrim(SX6->X6_CONTEUD) )
	LjWriteLog( ARQLOG, "Obtem sequencia de importação de registros que serão importados - MV_SEQREC: "+_cNumSeq )
	
	If Len( _cLista ) > 0
		_cSingular := " arquivo "
		_cPlural   := " arquivos "
		LjWriteLog( ARQLOG, _cNumSeq + " Iniciando Recepcao de Arquivos ..." )
		LjWriteLog( ARQLOG, _cNumSeq + " Existe(m) " + Alltrim(Str(Len(_cLista))) + IIF( Len(_cLista) > 1 , _cPlural , _cSingular ) + " a processar ..." )
	Else
		LjWriteLog( ARQLOG, "Não existem arquivos a importar." )
		U_GIENVIACAB( 4 ,"", "Não existem arquivos a importar." )
		Return
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe a configuracao das tabelas do recebimento para ³
	//³ nao interromper processo caso nao exista apos a descompactacao.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LjWriteLog( ARQLOG, "Verifica tabelas no SX5." )
	cCFG := " SELECT COUNT(X5_CHAVE) TOTAL FROM " + RetSQLName("SX5") + " WHERE X5_FILIAL = '" + xFilial("SX5") + "'"
	cCFG += " AND X5_TABELA   = 'X2' AND D_E_L_E_T_ = ' '"
	DbUseArea( .T.,"TOPCONN", TCGenQry(,,cCFG),"XXX", .F., .T.)
	
	DbSelectArea("XXX")
	DbGoTop()

	IF XXX->Total == 0
		LjWriteLog( ARQLOG, "Erro de configuracao. Tabela SX5-> X2 ou X1 esta vazia. O processamento sera interrompido." )
		DbSelectArea("XXX")
		DbCloseArea()
		U_GIENVIACAB( 4 ,"", "Processo interrompido, tabela SX5-> X2 ou X1 esta vazia." )
		Return
	Endif
	
	DbSelectArea("XXX")
	DbCloseArea()

	If Len(_cLista) > 0
		_cSeqANT := ""
		For _xCont := 1 to Len(_cLista)
			_cNome := AllTrim(_cLista[_xCont][1])
			_lOK   := .T.

			If Upper( Substr(_cNome,Len(_cNome)-2,3)) == "CAB"
				_cCompactado := _cNome

				If Upper(Substr(_cNome,1,3)) != "TMB"

					_cFilEnv := Substr(_cNome,3,2)
					_cSeqEnv := Substr(_cNome,5,6)
					_lAchou  := .F.

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³  Obtem a sequencia de recebimento esperada  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SX6->( DbSetOrder(1) )
					SX6->( MsSeek( xFilial("SX6") + "MV_SEQREC" ) )
					_cSeqANT := If( Empty(SX6->X6_CONTEUD),"000000",AllTrim(SX6->X6_CONTEUD) )
					_cSeqRec := StrZero(Val(_cSeqANT)+1,6)
					LjWriteLog( ARQLOG, "Sequencia de recebimento anterior........: "+_cSeqANT )
					LjWriteLog( ARQLOG, "Obtem a sequencia de recebimento esperada: "+_cSeqRec )
					
					_cArqCorr := _cFilEnv+_cSeqRec+".CAB"

					If Len(_aRollBack) = 0
						AAdd(_aRollBack,{_cFilEnv,_cSeqANT})
					Else
						For x:= 1 to Len(_aRollBack)
							If _aRollBack[x,1] == _cFilEnv
								_lAchou := .T.
								Exit
							Endif
						Next x
						If !_lAchou
							AAdd(_aRollBack,{_cFilEnv,_cSeqANT})
						Endif
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Consiste a sequencia do arquivo enviado com o arquivo ³
					//³ enviado pela Loja.                                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					LjWriteLog( ARQLOG, "Consiste a sequencia do arquivo enviado com o arquivo recebido." )
					If _cSeqEnv != _cSeqRec
						If !Empty(_cSeqRec)
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Move para uma pasta transitoria o arquivo com erro de ³
							//³ sequencia.                                            ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							LjWriteLog( ARQLOG, "Envia EMail informando erro na sequencia." )
							LjWriteLog( ARQLOG, "Erro de Sequencia! Arquivo Esperado ("+_cSeqRec+") - Arquivo Enviado ("+_cSeqEnv+") "+_cCompactado )
							LjWriteLog( ARQLOG, "O Arquivo "+_cCompactado+" sera movido para a pasta "+_cCaminhoErr )

							U_GIENVIACAB(3,SubStr(_cCompactado,1,10))

							U_BkpFiles(2,.F.,.T.,_cCompactado)
							_lOk := .F.
						Endif
						For x:= 1 to Len(_aRollBack)
							If _aRollBack[x,1] == _cFilEnv
								PutMv( "MV_SEQREC" , _aRollBack[x,2] )
								LjWriteLog( ARQLOG, "Rollback da sequencia executado corretamente para filial " + _cFilEnv )
							Else
								LjWriteLog( ARQLOG, "Nao foi possivel executar Rollback na sequencia da filial " + _cFilEnv )
							Endif
						Next x
					Else
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Avancar a sequencia de recebimento ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						PutMv( "MV_SEQREC" , _cSeqRec )
						LjWriteLog( ARQLOG, "Avancando sequencia da filial " + _cFilEnv + " para " + _cSeqRec )
					Endif					
				Endif
				
				If _lOk
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Descompactacao do arquivo de recebimento . Utilizado novo      ³
					//³ metodo de compactacao proprietario Microsiga. Faz Timeout caso ³
					//³ nao consiga descompactar o arquivo.                            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ				
					_CabFile := _cCaminho + _cCompactado
					_cTarget := _cCaminho
					_lSucess := MSDecomp( _CabFile , _cTarget )
				
					If _lSucess
						LjWriteLog( ARQLOG, "O Arquivo "+_cCompactado+" descompactado com sucesso" )
					Else								
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Erro na descompactacao ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						_nTry := 1
						While !(_lSucess) .And. _nTry < 30
							LjWriteLog( ARQLOG, "Tempo antes da descompactação: "+Time() )
							_lSucess := MSDecomp( _CabFile , _cTarget )
							LjWriteLog( ARQLOG, "Tempo depois da descompactação: "+Time() )
							_nTry := _nTry + 1
						End
						
						If _nTry >= 30
							LjWriteLog( ARQLOG,  "O Arquivo " + _cCompactado + " nao pode ser descompactado" )
							LjWriteLog( ARQLOG,  "O Arquivo " + _cCompactado + " sera movido para a pasta de PENDENCIAS" )
							U_GIENVIACAB(3,SubStr(_cCompactado,1,10))
							U_BkpFiles(2,.F.,.T.,_cCompactado)
						Endif
					Endif				
				Endif
				
			Endif
		Next _xCont

	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Nao existem arquivos no diretorio de recepcao a serem processados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		LjWriteLog( ARQLOG,  "Nao existem arquivos no diretorio de recepcao a serem processados" )
		U_GIENVIACAB( 4 ,"", "Nao existem arquivos no diretorio de recepcao a serem processados." )
		Return

	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Arquivos a Processar salvos no diretorio³
	//³ \WF\PENDENTE\                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_Dir := _cCaminho + "*.*"
	_cRestante := Directory( _Dir )

	If Len(_cRestante) == 0	
		LjWriteLog( ARQLOG,  "Todos os arquivos com erro foram movidos para a pasta PENDENTE" )
		LjWriteLog( ARQLOG,  "Nao ha mais arquivos a processar." )
		U_GIENVIACAB( 4 ,"", "Nao ha mais arquivos a processar na pasta \RECEBE\." )
		Return	
	Endif

	DbSelectArea("SX5")
	DbSetOrder(1)
	DbGoTop()
	DbSeek( xFilial("SX5") + "X2" )

	LjWriteLog( ARQLOG,  "Obtendo indice das tabelas a serem recebidas" )
	
	While !Eof() .And. SX5->X5_FILIAL == xFilial("SX5") .And.  SX5->X5_TABELA == "X2" //If(_cModo=="M","X1","X2")

		SX2->( DbSetOrder(1) )
		SX2->( MsSeek(AllTrim(SX5->X5_CHAVE)) )
		SIX->( DbSetOrder(1) )
		If SIX->( MsSeek(AllTrim(SX5->X5_CHAVE) + AllTrim(SX5->X5_DESCRI)) )
			AAdd( _aTabAlias,{ AllTrim(SX5->X5_CHAVE), RTrim(SX2->X2_NOME), AllTrim(SIX->ORDEM), AllTrim(SIX->CHAVE), AllTrim(SX2->X2_MODO) } )
		Else
			LjWriteLog( ARQLOG, "Indice da tabela " + RTrim(SX5->X5_CHAVE) + " especificado na Tabela X2 nao encontrado no SINDEX")
		Endif

		SX5->( DbSkip() )

	Enddo
	
	If Len(_aTabAlias) <=0
		LjWriteLog( ARQLOG, "Erro de configuracao. Tabela X2 esta vazia. O processamento interrompido." )
		U_GIENVIACAB( 4 ,"", "Processamento interrompido, tabela SX5 -> X2 esta vazia." )
		Return
	Endif
	
	_aTabAlias := aSort( _aTabAlias,,, { |x,y| x[1] < y[1] } ) // do menor para o maior

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa o processamento por filial ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cPath	:= AllTrim(GetMv("MV_GWRECEB",,"\SYSTEM\WF"+cEmpAnt+"\RECEBE\"))
	_aArq	:= Directory( _cPath + "*.0"+cFilAnt)

	_aArq := aSort( _aArq,,, { |x,y| x[1] < y[1] } ) // do menor para o maior

	SM0->( DbGoTop() )
	SM0->( DbSeek( SM0->M0_CODIGO ) )
	_cLojMat := SM0->M0_CODFIL
	RecebeLj()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Lista de arquivos processados para emitir ³
	//³ recibo e E-Mail de confirmacao de leitura ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LjWriteLog( ARQLOG, "Gravou todos os registros." )

	_Dir 	:= _cCaminhoErr + "*.CAB"
	_aLidos := Directory( _Dir )
	_aProcess := {}
		
	If Len(_aLidos) > 0
		LjWriteLog( ARQLOG, "Atenção! Existem arquivos na pasta \PENDENTE\ que estão fora de sequencia, favor verificar." )
		U_GIENVIACAB( 4 ,"", "Existem arquivos na pasta \PENDENTE\ que estão fora de sequencia." )
		Return
	EndIf

	For _nLidos := 1 To Len(_aLidos)
		SM0->( DbSeek( cEmpAnt + Substr(_aLidos[_nLidos][1],1,2) ) )
		_cFilial := Substr(_aLidos[_nLidos][1],1,2)
		_cNome	 := Capital(RTrim(SM0->M0_FILIAL))
		_cArquivo:= _aLidos[_nLidos][1]
		_cTamanho:= _aLidos[_nLidos][2]
		_dData	 := _aLidos[_nLidos][3]
				
		aAdd( _aProcess , {  _cFilial , _cNome , _cArquivo , Alltrim(Str(_cTamanho,10)) + " Bytes" , dToc(_dData) , "" } )
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia E-Mail de Confirmacao de Processamento.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LjWriteLog( ARQLOG, "Chama a função para envio do e-mail." )
	U_GIENVIACAB(2,SubStr(_cCompactado,1,10))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Grava log na Z01 de recebimento  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LjWriteLog( ARQLOG, "Chama a função para gravar log de envio." )
	U_GIGRLOGZ01(cAssunto)

	DbSelectArea("SM0")
	DbSeek( cEmpAnt + cFilAnt )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Move todos os arquivos processados para a pasta de backup.       ³
	//³ Tambem pode ser utilizado um outro diretorio em um outro servidor³
	//³ alternativo se desejar por causa do volume de arquivos e indices ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	U_BkpFiles(2,.T.,.F.)

	LjWriteLog( ARQLOG, "Processamento de arquivos realizado com sucesso" )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RECEBELJ()ºAutor  ³Luis Brandini       º Data ³  08/24/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Processa a importacao dos dados contidos em _aTabAlias      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Exclusivo Cliente TMB                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RecebeLj()
Local _xCnt

For _xCnt := 1 to Len(_aArq)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  Procura na relacao de tabelas SX5 - X2 as tabelas que foram recebidas  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    nPos := 0
	nPos := aScan( _aTabAlias , { |x| x[1] == SubStr(_aArq[_xCnt,1],1,3) } )

	If nPos > 0	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Estrutura do Array _aTabAlias ³
		//³  [1] - Alias do Arquivo       ³
		//³  [2] - Descricao do Arquivo   ³
		//³  [3] - Indice do Arquivo      ³
		//³  [4] - Chave do Indice        ³
		//³  [5] - Compartilh. / Exclusivo³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_Msg        := _aTabAlias[nPos,1]+" - "+AllTrim(Upper(_aTabAlias[nPos,2]))+"  Filial: "+ SM0->M0_CODFIL
		_xAliasSiga := _aTabAlias[nPos,1]
		CHKFILE(_xAliasSiga)
		_cArquivo   := Space(12)
		_cTmpAlias  := "TMP"+_xAliasSiga
		_xIndice    := _GetOrdem(AllTrim(_aTabAlias[nPos,3]))
		_xChave     := AllTrim( _aTabAlias[nPos,4] )
		_xModo      := AllTrim( _aTabAlias[nPos,5] )
		_xRegua     := 0
		
		If "S" == Substr(_xAliasSiga,1,1)
			_cCpoFilial := Substr(_xAliasSiga,2,2) + "_FILIAL"
		Else
			_cCpoFilial := _xAliasSiga + "_FILIAL"
		Endif

		If Substr(_aArq[_xCnt][1],1,3) == _xAliasSiga  .And. Substr(_aArq[_xCnt][1],12,2) == _cLojMat
			_cArquivo := Substr(_aArq[_xCnt][1],1,13)
			LjWriteLog( ARQLOG, "Processando Arquivo: " + _cArquivo + " - Empresa: " + SM0->M0_CODIGO + " Filial: " + SM0->M0_CODFIL )
			_Process( _cPath , _cArquivo )
	        Set(11,"ON")
		Endif

	EndIf
	
Next _xCnt	

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³_Process()ºAutor  ³Luis Brandini       º Data ³  08/24/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Processa o arquivo DBF Temporario passado no parametro      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Exclusivo Cliente TMB                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function _Process( xPath , xArquivo )
Local _xCampo
Local _cInd_SE1 := 0

If File(xPath+xArquivo)

	DbUseArea(.T.,,xPath+xArquivo,_cTmpAlias,.F.,.F.)
	_aStruct    := DbStruct()

	_cCpoSeq  := "SEQRECNO"
	_xOkMsSeq := aScan( _aStruct,{ |x| Alltrim(x[1]) == Alltrim(_cCpoSeq) } )
	
	LjWriteLog( ARQLOG, "Caso exista o campo SeqRecno Indexa")

	If _xOkMssEQ != 0 	
		_cIndice  := _cCaminho + Substr(xArquivo,1,9)+"A"
		_cChave	  := "SEQRECNO"
		IndRegua(_cTmpAlias,_cIndice,_cChave,,,, .F. )
		LjWriteLog( ARQLOG, "Tabela: "+_cTmpAlias+" - Indice: "+_cIndice)
		DbClearIndex()
		DbSetIndex(_cIndice+OrdBagExt())
	Endif

	_xPosFilial := aScan( _aStruct,{ |x| AllTrim(x[1]) == AllTrim(_cCpoFilial) } )
	_cFilImp    := SubStr(_cArquivo,12,2)
	DbGoTop()
	While !Eof()

		_xProcura := &_xChave

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Set Delete On                                                                ³
		//³ Alteracao feita para o tratamento dos registros marcados como deletados antes³
		//³ dos registros ativos, pois a rotina interpretava como registro excluido e nao³
		//³ lancava o registro ativo que estava no mesmo arquivo                         ³
		//³ Feita por Bruno Borges em 23/04/02                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_xRegDel  := FieldGet(Len(_aStruct))
		If _xRegDel == "S"
			Set(11,"OFF")
		Else
			Set(11,"ON")
		Endif
		_xInclui  := .T.
		_lGrava   := .T.       
		DbSelectArea(_xAliasSiga)  
		_cArqCons := PegaSX5("X2")
		_cArqCad  := GetMv("MV_GITABCP",,"")
		DbSetOrder(Val(_xIndice))
		If DbSeek(_xProcura)
			If AllTrim(_xRegDel) == "S" 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica Condicoes Especificas antes da Delecao³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				_lGrava := .T.						
				//_lGrava := _VerifGrv()
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Caso o resgitro veio deletado da loja atualiza o da matriz ³
				//³ mantendo somente as ultimas alteracoes                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If _lGrava		   
					RecLock(_xAliasSiga,.F.)
					For _xCampo := 1 to Len(_aStruct)					
						DbSelectArea(_cTmpAlias)
						_xConteudo := FieldGet(_xCampo)
						_xNome     := FieldName(_xCampo)
						DbSelectArea(_xAliasSiga)
						nPos := FieldPos(_aStruct[_xCampo,1])
						If nPos > 0
							FieldPut( nPos , _xConteudo )
						Endif
					Next _xCampo   	   
    	   			DbDelete()
					MsUnLock()
				Endif
				DbSelectArea(_cTmpAlias)
				DbSkip()
				Loop
			Else
				_xInclui := .F.
			Endif                                    
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica Condicoes Especificas antes da Gravacao  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//_lGrava := _VerifGrv()
		Else
			If AllTrim(_xRegDel) == "S"
				RecLock(_xAliasSiga,.T.)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³  Grava Nro Seq para Consistencia de Dados na Recepcao  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If _xAliasSiga $ (_cArqCons)
					nPos := FieldPos(Substr(_xAliasSiga,2,2)+"_XNUMSEQ")
					If nPos > 0
						FieldPut( nPos,_cNumSeq )
					Endif
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³  Grava Filial p/utilizacao na Consist. de Dados na Recepcao  ³
                //|  Apenas tabelas compartilhadas                               | 
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If _xAliasSiga $ _cArqCad //("SE1/SE2/SE5/SEF")
					nPos := FieldPos(Substr(_xAliasSiga,2,2)+"_XFILIAL")
					If nPos > 0
						FieldPut( nPos,_cFilImp )
					Endif
				Endif
				For _xCampo := 1 to Len(_aStruct)
					DbSelectArea(_cTmpAlias)
					_xConteudo := FieldGet(_xCampo)
					_xNome     := FieldName(_xCampo)
					DbSelectArea(_xAliasSiga)
					nPos := FieldPos(_aStruct[_xCampo,1])
					If nPos > 0
						FieldPut( nPos , _xConteudo )
					Endif					
				Next _xCampo
				DbDelete()
				MsUnLock()
				/*-------- Fim da Alteracao -----------------------------*/
				DbSelectArea(_cTmpAlias)
				DbSkip()
				Loop
			Endif
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inclui os registros no Arquivo oficial³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If _lGrava
			RecLock(_xAliasSiga,_xInclui)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Grava Numero Sequencial para Consistencia de Dados na Recepcao  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If _xAliasSiga $(_cArqCons)
				nPos := FieldPos(Substr(_xAliasSiga,2,2)+"_XNUMSEQ")
				If nPos > 0
					FieldPut( nPos , _cNumSeq )
				Endif
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³  Grava Filial para utilizacao na Consistencia de Dados na Recepcao  ³
			//³  * Somente Arquivos Compartilhados                                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If _xAliasSiga $ _cArqCad
				nPos := FieldPos(Substr(_xAliasSiga,2,2)+"_XFILIAL")
				If nPos > 0
					FieldPut( nPos , _cFilImp )
				Endif
			Endif   
			For _xCampo := 1 to Len(_aStruct)
				DbSelectArea(_cTmpAlias)
				_xConteudo := FieldGet(_xCampo)
				_xNome     := FieldName(_xCampo)

				DbSelectArea(_xAliasSiga)
				nPos := FieldPos(_aStruct[_xCampo,1])
				If nPos > 0
					FieldPut( nPos , _xConteudo )
				Endif
			Next _xCampo
			MsUnLock()
		Endif
		ProcessMessages()
		DbSelectArea(_cTmpAlias)
		DbSkip()
	Enddo
	DbSelectArea(_cTmpAlias)
	DbCloseArea()
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PegaSX5   ºAutor  ³Denis Polastri      º Data ³  19/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a descricao das tabelas cadastradas no SX5, recebe  º±±
±±º          ³uma chave e retorna as tabelas cadastradas.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Gama Italy                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PegaSX5(nOpc)
Local cTabelas := ""
SX5->( DbSetOrder(1) )
SX5->( MsSeek( xFilial("SX5") + nOpc ) )
While SX5->( !Eof() .And. X5_TABELA == nOpc )
	cTabelas += AllTrim(SX5->X5_CHAVE) + "/"
	SX5->( DbSkip() )
EndDo
Return(cTabelas)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³_GetOrdem ºAutor  ³Denis Polastri      º Data ³  18/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Obtem a Ordem do Sindex para indices alfanumericos          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³GIPROCCAB                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function _GetOrdem(wIndice)

Local xRetorno := wIndice

Do Case
	Case (wIndice=="A")
		xRetorno := "10"
	Case (wIndice=="B")
		xRetorno := "11"
	Case (wIndice=="C")
		xRetorno := "12"
	Case (wIndice=="D")
		xRetorno := "13"
	Case (wIndice=="E")
		xRetorno := "14"
	Case (wIndice=="F")
		xRetorno := "15"
	Case (wIndice=="G")
		xRetorno := "16"
	Case (wIndice=="H")
		xRetorno := "17"
	Case (wIndice=="I")
		xRetorno := "18"
	Case (wIndice=="J")
		xRetorno := "19"
	Case (wIndice=="K")
		xRetorno := "20"
	Case (wIndice=="L")
		xRetorno := "21"
	Case (wIndice=="M")
		xRetorno := "22"
	Case (wIndice=="N")
		xRetorno := "23"
	Case (wIndice=="O")
		xRetorno := "24"
	Case (wIndice=="P")
		xRetorno := "25"
	Case (wIndice=="Q")
		xRetorno := "26"
	Case (wIndice=="R")
		xRetorno := "27"
	Case (wIndice=="S")
		xRetorno := "28"
	Case (wIndice=="T")
		xRetorno := "29"
	Case (wIndice=="U")
		xRetorno := "30"
	Case (wIndice=="V")
		xRetorno := "31"
	Case (wIndice=="W")
		xRetorno := "32"
	Case (wIndice=="X")
		xRetorno := "33"
	Case (wIndice=="Y")
		xRetorno := "34"
	Case (wIndice=="Z")
		xRetorno := "35"
EndCase

Return(xRetorno)

/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+----------Ğ------------------Ğ---------------------------Ğ-------------+¦¦
¦¦¦Funcao    ¦ _VerifGrv ¦ Autor ¦ Luis Brandini     ¦ Data ¦  26/11/01	  ¦¦¦
¦¦¦----------Ï------------------¤---------------------------¤-------------¦¦¦
¦¦¦Descriçäo ¦ Condicoes especificas para sobreposicao de registros.	  ¦¦¦
¦¦¦----------Ï------------------------------------------------------------¦¦¦
¦¦¦Uso		 ¦ Exclusivo Cliente TMB             					      ¦¦¦
¦¦+----------¤------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Static Function _VerifGrv()

Local _lRetorno := .T.

If _xAliasSiga = "SC7"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Pedidos de Compra Liberados  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SC7->C7_CONAPRO = "L" .And. (_cTmpAlias)->C7_CONAPRO != "L"
		_lRetorno := .F.
	Endif
Endif

// Titulos ja movimentados a Receber
If _xAliasSiga == "SE1"
	If (SE1->E1_VALOR != SE1->E1_SALDO) .Or. (SE1->E1_VENCTO != (_cTmpAlias)->E1_VENCTO)
		_lRetorno := .F.
	Endif
Endif

// Titulos ja movimentados a Pagar
If _xAliasSiga == "SE2"
	If (SE2->E2_VALOR != SE2->E2_SALDO) .Or. (SE2->E2_VENCTO != (_cTmpAlias)->E2_VENCTO)
		_lRetorno := .F.
	Endif
Endif

// Saldos do estoque com data anterior a ultima atualizacao na matriz
If _xAliasSiga == "SB2"
    // If SB2->B2_USAI >= (_cTmpAlias)->B2_USAI
    // Alterado em 27.02.2002 conforme autorizacao do Sr. Vitor
    If SB2->B2_USAI > (_cTmpAlias)->B2_USAI
		_lRetorno := .F.
	EndIf
EndIf

Return(_lRetorno)

*/