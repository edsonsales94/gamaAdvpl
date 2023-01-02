/*/                 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BGKO02   ³ Por: Adalberto Moreno Batista ³ Data ³ 07/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina para importacao de notas de conhecimento de trans-  ³±±
±±³          ³ porte do software GKO                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Brasitech                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

#include "rwmake.ch"
#include "tbiconn.ch"

User Function BGKO02()
Local aButton		:= {}
Local aSay			:= {}
Local nOpc			:= 0
Local cCadastro		:= "Integração GKO"
Local aArea			:= GetArea()
Local aAreaSF1		:= SF1->(GetArea())
Local aAreaSD1		:= SD1->(GetArea())
Local aAreaSB1		:= SB1->(GetArea())
Local aAreaSA2		:= SA2->(GetArea())
Private _cArqNF, _cNewArqNF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Interface                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd ( aSay , "Importação de informações do Conhecimento (NC) para a tabela de notas fiscais de" )
aAdd ( aSay , "entrada do Protheus, conforme layout INTNC 5.71a")

aAdd ( aButton , { 1 , .T. , { || nOpc := 1,	FechaBatch()	}} )
aAdd ( aButton , { 2 , .T. , { || FechaBatch()					}} )

FormBatch( cCadastro , aSay , aButton )

If nOpc == 1

	_cArqNF 	:= cGetFile("Arquivos Texto|FRNC*.TXT|Todos os Arquivos|*.*",OemToAnsi("Selecione o arquivo")) //,0,,.T.,GETF_OVERWRITEPROMPT)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verificando se o processo ira ser continuado                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if !File(_cArqNF)

		MsgBox("O arquivo texto nao foi localizado. O PROCESSO NAO PODERA SER INICIADO.","ATENCAO","ERRO")
		
	Else
		
		Processa( { |lEnd| GKOProc(_cArqNF) } , "Integração Protheus x GKO" , "Importando conhecimentos de frete" , .T. )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ renomeando o arquivo lido                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fClose( _cArqNF )
		nDotPos := At( ".", _cArqNF )
		if nDotPos > 0
			_cNewArqNF := Substr( _cArqNF, 1, nDotPos ) + "ok"
 			__CopyFile( _cArqNF, _cNewArqNF )
 		endif
		fErase( _cArqNF )

	Endif   

Endif   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a posicao original das areas de trabalho ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea( aAreaSF1 )
RestArea( aAreaSD1 )
RestArea( aAreaSB1 )
RestArea( aAreaSA2 )
RestArea( aArea )
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ GKOProc      ³ Por: Adalberto Moreno Batista ³ Data ³15.05.2011³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GKOProc(_cArqNF)
Local _aStru, _cTLOG, _aStru2, _cTAUX
Local _cArqLog := 'C:\TEMP\' + CriaTrab(,.F.) + '.LOG'
Local cRecebe, cSubject, cMensagem

MakeDir("C:\TEMP")

ProcRegua(3) // Numero de processos/sub-processos

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º 1- Criacao das estruturas temporarias para LOG de operacoes e tabela      º
//º    auxiliar para importacao de registros								  º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
IncProc("Criando estruturas temporarias...")	//1o.

//Tabela de log
_aStru := {{"LINHA"  ,"C",200,0}}
_cTLOG := CriaTrab(_aStru,.T.)
dbUseArea(.T.,,_cTLOG,"TLOG",.T.)

//Tabela auxiliar para importacao
_aStru2 := {	{"TPREGISTRO"  	,"C",3,0},;
				{"IDNC"  		,"C",15,0},;
				{"CBUFFER"  	,"C",230,0}}
_cTAUX := CriaTrab(_aStru2,.T.)
dbUseArea(.T.,,_cTAUX,"TAUX",.T.)

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º 2- Importacao arquivo texto em tabela auxiliar                            º
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
IncProc("Importando registros em tabela temporaria...")		//2o.

dbSelectArea("TAUX")
Append From &_cArqNF SDF
dbGoTop()

If Eof()
	MsgBox("O arquivo de nome " + AllTrim(_cArqNF) + " está vazio!","Atencao!")
Else
	ImpGKO()
Endif

IncProc("Finalizando processo...")	//3o.

dbSelectArea("TLOG")
dbGoTop()
if !eof()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gerando log de ocorrencias da importacao                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	copy to &_cArqLog SDF
	if MsgBox("Deseja ler o arquivo " + _cArqLog + " de log de operação?","Pergunta","YESNO")
		if file("C:\WINDOWS\NOTEPAD.EXE")
			WinExec("C:\WINDOWS\NOTEPAD.EXE " + _cArqLog,3)
		else
			WinExec("C:\WINNT\NOTEPAD.EXE " + _cArqLog,3)
		endif
	endif
endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ fechando as areas temporarias e excluindo os arquivos de trabalho            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TLOG")
dbCloseArea()
fErase(_cTLOG + ".dbf")

dbSelectArea("TAUX")
dbCloseArea()
fErase(_cTAUX + ".dbf")

Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ ImpGKO             ³ Por: Adalberto Moreno Batista ³ Data ³15.05.2011³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpGKO()
Local _aCab 		:= {}
Local _aDet 		:= {}
Local _cProd		:= GetMV('BR_GKOPROD',.F.,' ')
Local _cCodSrv		:= GetMV("BR_GKOSRV",.F.," ")
Local _cCdPagPar	:= GetMV('BR_GKOCP',.F.,' ')
Local lContinua		:= .T.
Local _cCNPJEmp		:= SM0->M0_CGC
Local _cDoc, _cSerie, _dEmissao, _cCNPJ, _lNFOk, _aCodFor, _nBICMS, _nVICMS, _nAICMS, ;
	  _nBICMSST, _nVICMSST, _nAICMSST, _nValor, _cInfLog, nI, _cCdPag, _cCNPJReg, ;
	  _nBISS, _nVISS, _nAISS ,_cProduto, _cEspecie, _cNaturez, _cChvNfe

Private lMsErroAuto	:= .F.

//Setando a ordem das tabelas
SB1->(dbSetOrder(1))
SF1->(dbSetOrder(1))
SF2->(dbSetOrder(1))
SF4->(dbSetOrder(1))

dbSelectArea("TAUX")
dbGoTop()
do While TAUX->(!eof())

	_cProduto := IIf( !(Substr(cBuffer, 01, 02) == "07"),_cProd,_cCodSrv)
	
	if !SB1->(dbSeek(xFilial("SB1") + _cProduto)) .or. Empty(_cProduto)
	
		GKOGrvLog("Impossível continuar. Produto '" + _cProduto + "' cadastrado no parâmetro BR_GKOPROD não encontrado!")
		lContinua := .F.
	
	else
	
		if !SF4->(dbSeek(xFilial("SF4") + SB1->B1_TE)) .or. Empty(SB1->B1_TE)
		
			GKOGrvLog("Impossível continuar. O TES de entrada padrão para o produto '" + _cProduto + "' não está cadastrado!")
			lContinua := .F.
		
		endif
	
	endif
		
	if lContinua

	
		_aCab 		:= {}		//Variavel para o cabecalho da nota fiscal
		_aDet 		:= {}		//Variavel para o item da nota fiscal
		_aCodFor	:= {}		//Variavel para os dados do fornecedor
		_cCdPag		:= ""
		_nValor		:= 0		//armazena o valor total da nota de frete
		_aNFS		:= {}		//armazena os numeros das notas fiscais de saida
		_cDoc		:= ""
		_cSerie		:= ""
		_cFatura	:= ""
		_cMenNota 	:= ""
	
		//variaveis auxiliares de impostos
		_nBICMS		:= 0
		_nVICMS		:= 0
		_nAICMS		:= 0
		_nVICMSST	:= 0
		_nBICMSST	:= 0
		_nAICMSST	:= 0
		_nBISS		:= 0
		_nVISS		:= 0
		_nAISS		:= 0
	    _cNaturez	:= ""
	    
		_cInfLog	:= " "		//variavel auxiliar para informacoes da nota de frete a ser importada
		_cIdGKO		:= TAUX->IDNC
		_lNFOk		:= .T.
		
		do while TAUX->(!eof() .and. IDNC = _cIDGKO)
		
			if TAUX->TPREGISTRO = '700'		//informacoes do conhecimento (NC), segundo layout GKO exportacao em arquivo
		
				_cEspecie	:= IIf((Substr(cBuffer, 01, 02) == "07"),"NFS",IIf((Substr(cBuffer, 01, 02) == "57"),"CTE","CTRC"))
				_cDoc		:= StrZero(Val(Substr(cBuffer,5,12)),9)
				_cSerie		:= PadR(Substr(cBuffer,17,5),3)
				_dEmissao	:= cTOd(Substr(cBuffer,90,10))
				_cCNPJ		:= Substr(cBuffer,23,14)
				_nValor		:= Val(Substr(cBuffer,106,15))/100
				_aCodFor	:= GetAdvFVal("SA2",{"A2_COD", "A2_LOJA", "A2_COND", "A2_EST"}, xFilial("SA2") + _cCNPJ, 3)
				_cInfLog	:= "Conhecimento " + AllTrim(_cDoc) + ", serie " + AllTrim(_cSerie) + " do CNPJ " + Transf(_cCNPJ,"@R 99.999.999/9999-99")+" "
				_cCNPJReg	:= Substr(cBuffer,66,14)
				_cFatura	:= cValtoChar(Val(Substr(cBuffer,141,12)))
				_cChvNfe := Substr(cBuffer, 184, 44)
	
			elseif TAUX->TPREGISTRO = '720'		//informacoes dos impostos (NC), segundo layout GKO exportacao em arquivo

				if Substr(TAUX->CBUFFER,1,3)='001'		//ICMS
					_nBICMS		:= Val(Substr(TAUX->CBUFFER,04,15)) / 100
					_nVICMS		:= Val(Substr(TAUX->CBUFFER,27,15)) / 100
					_nAICMS		:= Val(Substr(TAUX->CBUFFER,19,8)) / 100
					_cTrib		:= Substr(TAUX->CBUFFER,31,2)
				
				elseif Substr(TAUX->CBUFFER,1,3)='003'		//ICMS-ST
					_nBICMSST	:= Val(Substr(TAUX->CBUFFER,04,15)) / 100
					_nVICMSST	:= Val(Substr(TAUX->CBUFFER,27,15)) / 100
					_nAICMSST	:= Val(Substr(TAUX->CBUFFER,19,8)) 	/ 100
					if _nVICMSST=0
						_nBICMSST := 0
					endif
				
				elseif Substr(TAUX->CBUFFER,1,3)='004'		//diferencial de aliquota
					_nBICMSST	:= Val(Substr(TAUX->CBUFFER,4,15)) 	/ 100
					_nVICMSST	:= Val(Substr(TAUX->CBUFFER,27,15)) / 100
					_nAICMSST	:= Val(Substr(TAUX->CBUFFER,19,8)) 	/ 100
				
				elseif Substr(TAUX->CBUFFER,1,3)='008'		//ISS
					_nVISS	:= Val(Substr(TAUX->CBUFFER, 27, 15)) 	/ 100
					if _nVISS > 0
						_nBISS  := Val(Substr(TAUX->CBUFFER, 4, 15)) 	/ 100
						_nAISS  := Val(Substr(TAUX->CBUFFER, 19, 8)) 	/ 100
						_cNaturez	:= "40100206"
					endif
				endif
	
			elseif TAUX->TPREGISTRO = '740'		//informacoes das NF associadas `a NC, segundo layout GKO exportacao em arquivo
				
				aAdd(_aNFS,{ strzero(val(AllTrim(Substr(TAUX->CBUFFER, 15, 12))),9), Substr(TAUX->CBUFFER,27,3) })
				
			endif
	
			TAUX->(dbSkip())
				
		enddo

		if Len(_aCodFor) > 0
			
	      //comparo o CNPJ do registro 700 com o CNPJ do sigamat.emp
			if _cCNPJEmp == _cCNPJReg
		
			   //verificando se encontrou o fornecedor
				if !Empty(_aCodFor[1] + _aCodFor[2])
					    
				    //Identificando a condicao de pagamento a ser utilizada no conhecimento de frete
					_cCdPag 	:= iif( Empty(_aCodFor[3]), _cCdPagPar, _aCodFor[3] )

					//Verificando se a nota de conhecimento ja esta gravada
					if !SF1->( dbSeek(xFilial("SF1") + _cDoc + _cSerie + _aCodFor[1] + _aCodFor[2]) )
					
						if Len(_aNFS) > 0
			
							// Crio Mensagem para dados adicionas da NFE
							for nI:=1 to Len(_aNFS)	
								_cMenNota := "NF ORI:"+_aNFS[nI][1]+"-"+AllTrim(_aNFS[nI][2])+"/FT:"+_cFatura
							Next
							//Pesquisando a NFS para identificar se a mesma ja possui vinculo
							/*for nI:=1 to Len(_aNFS)
								
								if SF2->( dbSeek(xFilial("SF2") + _aNFS[nI,1] + _aNFS[nI,2] ) )
											   Luiz 						
									if !empty(SF2->(F2_X_GKONC + F2_X_GKOSR)) .and. SF2->(F2_X_GKONC + F2_X_GKOSR) != _cDoc + _cSerie
										_lNFOk := .F.
										GKOGrvLog(_cInfLog + "nao sera importado. Motivo: A NFS " + AllTrim(_aNFS[nI,1]) + ", serie " + AllTrim(_aNFS[nI,2]) + " já foi vinculada ao NC " + SF2->F2_X_GKONC + " e esta sendo vinculada novamente na NC " + _cDoc +". Verifique!")
									endif
									
								else
		
	//								_lNFOk := .F.
	//								GKOGrvLog(_cInfLog + "nao foi importado. Motivo: A NFS " + AllTrim(_aNFS[nI,1]) + ", serie " + AllTrim(_aNFS[nI,2]) + " ref. ao conhecimento nao foi encontrada no Protheus")
		
								endif
								
							next*/
							
							if _lNFOk
							
								_aCab := {	{'F1_TIPO',		'N',			NIL},;
											{'F1_FORMUL',	'N',			NIL},;
											{'F1_DOC',		_cDoc,			.T.},;
											{'F1_SERIE',	_cSerie,		NIL},;
											{'F1_EMISSAO',	_dEmissao,		NIL},;
											{'F1_FORNECE',	_aCodFor[1],	NIL},;
											{'F1_LOJA',		_aCodFor[2],	NIL},;
											{'F1_ESPECIE',	_cEspecie,		NIL},;
											{'F1_EST',		_aCodFor[4],	NIL},;
											{"F1_CHVNFE",	_cChvNfe,		NIL},;
											{'F1_COND',		_cCdPag,		NIL}}
								
								
								If _cEspecie == "CTE"
									aadd(aCab,{"F1_TPCTE",	"N",				NIL})
								endif
								
								If !Empty(_cNaturez)
									aadd(_aCab,{"E2_NATUREZ",	_cNaturez,	NIL})
								Endif
		
								aAdd(_aDet, {	{'D1_ITEM',		StrZero( Len(_aDet) + 1, 2, 0),		NIL},;
												{'D1_COD',		_cProduto,							NIL},;
												{'D1_CONTA',	SB1->B1_CONTA,						NIL},;
												{'D1_QUANT',	1,		 							NIL},;
												{'D1_VUNIT',	_nValor,							NIL},;
												{'D1_TOTAL',	_nValor,							NIL},;
												{'D1_TES',		SB1->B1_TE,							NIL},;
												{'D1_BASEICM',	_nBICMS,							NIL},;
												{'D1_PICM',		_nAICMS,							NIL},;
												{'D1_VALICM',	_nVICMS,							NIL},;
												{"D1_BASEISS",	_nBISS,								NIL},;
												{"D1_ALIQISS",	_nAISS,								NIL},;
												{"D1_VALISS",	_nVISS,								NIL},;
												{'D1_ICMSRET',	_nVICMSST,							NIL},;
												{'D1_BRICMS',	_nBICMSST,							NIL},;
												{'D1_X_MNOT',	_cMenNota,							NIL},;
												{'D1_CLASFIS',	SB1->B1_ORIGEM + SF4->F4_SITTRIB,	NIL}})			
							endif
			
						else
						
							_lNFOk := .F.
							if !empty(_cInfLog)
								GKOGrvLog(_cInfLog + "nao foi importado. Motivo: Sem registros tipo 740 no arquivo texto, conforme layout GKO")
					 										endif
							
						endif
				
					else
				
						_lNFOk := .F.
						if !empty(_cInfLog)
							GKOGrvLog(_cInfLog + "nao foi importado. Motivo: Conhecimento ja esta gravado no Protheus")
						endif
						
					endif
			
				else
				    
					_lNFOk := .F.
					if !empty(_cInfLog)
						GKOGrvLog(_cInfLog + "nao foi importado. Motivo: Fornecedor nao esta cadastrado.")
					endif
					
				endif
		
			else
	
				_lNFOk := .F.
				if !empty(_cInfLog)
					GKOGrvLog(_cInfLog + "nao foi importado. Motivo: movimento processado pertence a filial " + Transf(_cCNPJReg,"@R 99.999.999/9999-99"))
				endif
			
			endif

		else
		    
			_lNFOk := .F.
								
		endif

				
		if _lNFOk    

			dbSelectArea("SF1")
	
			//-- Chamada da rotina automatica
			MsExecAuto( { |x,y,z| MATA103(x,y,z) }, _aCab, _aDet, 3 )
	
			//-- Verifica se houve algum erro
			If lmsErroAuto
			
				MostraErro()
				
			else

				//Gravando log de processamento
				GKOGrvLog(_cInfLog + "IMPORTADO COM SUCESSO")
				
				//gravo o numero NC nas notas de saida para posterior validacao
				/*for nI:=1 to Len(_aNFS)
						
					if SF2->( dbSeek(xFilial("SF2") + _aNFS[nI,1] + _aNFS[nI,2] ) )
						SF2->( RecLock("SF2",.F.) )
						SF2->F2_X_GKONC		:= _cDoc
						SF2->F2_X_GKOSR		:= _cSerie
						SF2->( MsUnlock() )
						
					endif
							
				next*/
				
			endif
	
		endif
	
		dbSelectArea("TAUX")
	
	endif
EndDo
	

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ GKOGrvLog          ³ Por: Adalberto Moreno Batista ³ Data ³07.05.2011³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GKOGrvLOG(_cLog)
TLOG->(RecLock("TLOG",.T.))
TLOG->LINHA	:= _cLog
TLOG->(MsUnlock())
Return()
