/*/                 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BGKO03   ³ Por: Adalberto Moreno Batista ³ Data ³ 07/05/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina para importacao de lancamentos contabeis do software³±±
±±³          ³ GKO                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Brasitech                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

#include "rwmake.ch"
#include "tbiconn.ch"

User Function BGKO03()
Local aButton		:= {}
Local aSay			:= {}
Local nOpc			:= 0
Local cCadastro		:= "Integração GKO"
Local aArea			:= GetArea()
Local aAreaCT1		:= CT1->(GetArea())
Local aAreaCT2		:= CT2->(GetArea())
Local cEol			:= chr(13) + chr(10)
Local cTxtImp, cStrArq, nI
Local lImport		:= .T.
Private _cArqNF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Interface                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd ( aSay , "Importação de informações de Provisão de Frete e Autorização para Pagamento (PFAP)" )
aAdd ( aSay , "para a tabela de lançamentos contábeis do Protheus, conforme layout INTPFAP 5.80a")

aAdd ( aButton , { 1 , .T. , { || nOpc := 1,	FechaBatch()	}} )
aAdd ( aButton , { 2 , .T. , { || FechaBatch()					}} )

FormBatch( cCadastro , aSay , aButton )

If nOpc == 1

	_cArqNF 	:= cGetFile("Arquivos Texto|FRPFAP*.TXT|Todos os Arquivos|*.*",OemToAnsi("Selecione o arquivo")) //,0,,.T.,GETF_OVERWRITEPROMPT)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verificando se o processo ira ser continuado                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if !File(_cArqNF)

		MsgBox("O arquivo texto nao foi localizado. O PROCESSO NAO PODERA SER INICIADO.","ATENCAO","ERRO")
		
	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Analisando se o arquivo já foi importado                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cStrArq	:= ""
		for nI := Len( _cArqNF ) to 1 step -1
			if Substr( _cArqNF, nI, 1 ) = "\"
				exit
			endif
			cStrArq := Substr( _cArqNF, nI, 1 ) + cStrArq
		next
		
		if !File("GKOCTB.TXT")
		
			MemoWrite("GKOCTB.TXT","")
			
		endif

		cTxtImp	:= MemoRead("GKOCTB.TXT")

		if cStrArq $ cTxtImp
		
			lImport := .F.
			MsgBox("O arquivo " + cStrArq + " já foi processado.","ATENCAO","ERRO")
			
		endif
		
		if lImport
		
			MemoWrite( "GKOCTB.TXT", cStrArq + cEol )
			Processa( { |lEnd| GKOProc(_cArqNF) } , "Integração Protheus x GKO" , "Importando provisões contábeis" , .T. )
			
		else
		
			MsgBox("O processo de importação não será iniciado.","ATENCAO","ERRO")
			
		endif
	
	Endif   

Endif   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a posicao original das areas de trabalho ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea( aAreaCT1 )
RestArea( aAreaCT2 )
RestArea( aArea )
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ GKOProc            ³ Por: Adalberto Moreno Batista ³ Data ³11.05.2011³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
				{"CBUFFER"  	,"C",180,0}}
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
	MsgBox("O arquivo de nome "+AllTrim(_cArqNF)+" está vazio!","Atencao!")
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
	if Aviso("Informacao","Deseja ler o arquivo "+_cArqLog+" de log de operação?",{"Sim","Nao"}) = 1
		if file("C:\WINDOWS\NOTEPAD.EXE")
			WinExec("C:\WINDOWS\NOTEPAD.EXE "+_cArqLog,3)
		else
			WinExec("C:\WINNT\NOTEPAD.EXE "+_cArqLog,3)
		endif
	endif

endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ fechando as areas temporarias e excluindo os arquivos de trabalho            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TLOG")
dbCloseArea()
fErase(_cTLOG+".dbf")

dbSelectArea("TAUX")
dbCloseArea()
fErase(_cTAUX+".dbf")

Return()



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ ImpGKO             ³ Por: Adalberto Moreno Batista ³ Data ³11.05.2011³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpGKO()
Local _aItens, _lProv, _cIdDOC, _cCNPJ, _cDocProv, _lOk, aCab, aDet, _cInfLog
Local _cConta, _cDC, _nValor, _cCusto, _cHist, nI

Private lMsErroAuto	:= .F.

CT1->(dbSetOrder(1))
CTT->(dbSetOrder(1))

dbSelectArea("TAUX")
dbGoTop()
do While TAUX->(!eof())
	
	if TAUX->TPREGISTRO='070' .and. Substr(TAUX->CBUFFER,17,1) $ "1.3"		//somente para provisoes(1) e cancelamentos de provisoes(3)
	
		_lProv		:= (Substr(TAUX->CBUFFER,17,1)="1")
		_cIdDOC		:= AllTrim(Str(Val(Substr(TAUX->CBUFFER,1,16))))
		_cCNPJ		:= AllTrim(Substr(TAUX->CBUFFER,18,14))
	    _cDocProv	:= Substr(TAUX->CBUFFER,32,16)
		_lOk		:= .T.
		aCab 		:= {}
		aDet 		:= {}
		_aItens		:= {}
		_cInfLog	:= " "
	
		TAUX->(dbSkip())
		
		do while TAUX->(!eof() .and. TPREGISTRO='075')
	
	
			_cConta			:= AllTrim(Substr(TAUX->cBuffer,1,10))
			_cDC			:= Substr(TAUX->cBuffer,41,1)
			_nValor			:= Val(Substr(TAUX->cBuffer,42,10))/100
			_cCusto			:= AllTrim(Substr(TAUX->cBuffer,31,10))
			_cHist			:= iif(_lProv,"","CANCEL.")+"PROV.FRETE CF.DOC "+AllTrim(_cIdDoc)+" DE "+dtoc(dDataBase)
			_cInfLog		:= "Documento " + _cIdDoc + " do cod. " + _cCNPJ + " "
			aAdd(_aItens,{_cConta,_cDC,_nValor,_cCusto,_cHist})

			TAUX->(dbSkip())
			
    	enddo
    
	    
		//Identificando a existencia de lancamentos contabeis
		if Len(_aItens) > 0
			
			//Validando as informacoes dos lancamentos contabeis
			for nI:=1 to Len(_aItens)
			
				//validando a existencia da conta contabil
		 		if CT1->(!dbSeek(xFilial("CT1")+_aItens[nI,1]))
					_lOk := .F.
					GKOGrvLog(_cInfLog+"nao foi importado. Motivo: A Conta "+AllTrim(_aItens[nI,1])+" nao foi encontrada no sistema.")
		 		endif
		 		
				//validando a existencia do centro de custo
		 		if CTT->(!dbSeek(xFilial("CTT")+_aItens[nI,4]))
					_lOk := .F.
					GKOGrvLog(_cInfLog+"nao foi importado. Motivo: O centro de custo "+AllTrim(_aItens[nI,4])+" nao foi encontrada no sistema.")
		 		endif

				Aadd(aDet,	{	{"CT2_FILIAL"	,xFilial("CT2"),							NIL},;
								{"CT2_LINHA"	,StrZero(nI,3),								NIL},;
								{"CT2_MOEDLC"	,"01",										NIL},;
								{"CT2_DC"		,iif(_aItens[nI,2]="D","1","2"),			NIL},;
								{"CT2_DEBITO"	,iif(_aItens[nI,2]="D",_aItens[nI,1],""),	NIL},;
								{"CT2_CREDIT"	,iif(_aItens[nI,2]="C",_aItens[nI,1],""),	NIL},;
								{"CT2_VALOR"	,_aItens[nI,3],								NIL},;
								{"CT2_ORIGEM"	,"CTBA102",									NIL},;
								{"CT2_HP"		,"",										NIL},;
								{"CT2_CCD"		,iif(_aItens[nI,2]="D",_aItens[nI,4],""),	NIL},;
								{"CT2_CCC"		,iif(_aItens[nI,2]="C",_aItens[nI,4],""),	NIL},;
								{"CT2_HIST"		,_aItens[nI,5],								NIL}})

			next

			if _lOk

				aCab	:= {	{"dDataLanc"	,dDataBase,	NIL},;
								{"cLote"		,"005000",	NIL},;
								{"cSubLote"		,"001",		NIL}}

				//-- Chamada da rotina automatica     
				MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)},aCab,aDet,3)

				//-- Verifica se houve algum erro
				If lmsErroAuto
				
					MostraErro()
					
				else
				
					GKOGrvLog(_cInfLog + "IMPORTADO COM SUCESSO no Docto " + CT2->(CT2_LOTE + "/" + CT2_SBLOTE + "/" + CT2_DOC + " em " + dtoc(CT2_DATA)))
					
				endif


			endif
		else
		
			_lOk := .F.
			GKOGrvLog(_cInfLog + "nao foi importado. Motivo: Nao foram identicados lancamentos para este documento, registros tipo 075 conforme layout GKO")
			
		endif
	
	else
	
		TAUX->(dbSkip())
	
	endif

EndDo
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ GKOGrvLog          ³ Por: Adalberto Moreno Batista ³ Data ³11.05.2011³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GKOGrvLOG(_cLog)
TLOG->(RecLock("TLOG",.T.))
TLOG->LINHA	:= _cLog
TLOG->(MsUnlock())
Return()
