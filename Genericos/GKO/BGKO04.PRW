#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"

/*/

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		BGKO04                                                       /@
@type			User function                                                /@
@date			13/03/2014                                                   /@
@description	Rotina para importa鈬o de faturas a pagar, referentes aos 
				conhecimentos de frete emitidos pelas transportadoras.
				Exportado pelo software GKO, layout INTFAT - EXPORTAﾇﾃO DE 
				FATURAS - FRFA#.TXT                                          /@
@author			Adalberto Moreno Batista (Op鈬o Um Consultoria)              /@
@use			Espec?fico Brasitech                                         /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

/*/
User Function BGKO04()
Local aButton		:= {}
Local aSay			:= {}
Local nOpc			:= 0
Local cCadastro		:= "Integra鈬o GKO"
Local aArea			:= GetArea()
Local aAreaSA2		:= SA2->(GetArea())
Local aAreaSE2		:= SE2->(GetArea())
Private _cArqNF, _cNewArqNF

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Criacao da Interface
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
aAdd (aSay , "Importa鈬o de faturas referentes ? cobran軋 de valores das entregas. Inclus縊 de t?tulos ? pagar,")
aAdd (aSay , "conforme layout INTFAT")

aAdd (aButton , { 1 , .T. , {|| nOpc := 1,	FechaBatch()	}})
aAdd (aButton , { 2 , .T. , {|| FechaBatch()				}})

FormBatch(cCadastro , aSay , aButton)

If nOpc == 1
	
	_cArqNF 	:= cGetFile("Arquivos Texto|FRFA*.TXT|Todos os Arquivos|*.*", OemToAnsi("Selecione o arquivo"))
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Verificando se o processo ira ser continuado
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	if !File(_cArqNF)
		
		MsgBox("O arquivo texto n縊 foi localizado. O PROCESSO NﾃO PODERﾁ SER INICIADO.", "ATENﾇﾃO", "ERRO")
		
	Else
		
		Processa({|lEnd| GKOProc(_cArqNF)} , "Integra鈬o Protheus x GKO" , "Importando faturas de cobran軋 de frete" , .T.)
		
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// renomeando o arquivo lido
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		fClose(_cArqNF)
		nDotPos := At(".", _cArqNF)
		if nDotPos > 0
			_cNewArqNF := Substr(_cArqNF, 1, nDotPos) + "ok"
			__CopyFile(_cArqNF, _cNewArqNF)
		endif
		fErase(_cArqNF)
		
	Endif
	
Endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Restaura a posicao original das areas de trabalho 
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
RestArea(aAreaSE2)
RestArea(aAreaSA2)
RestArea(aArea)
Return()


/*/

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		GKOProc                                                      /@
@type			Static function                                              /@
@date			26/07/2014                                                   /@
@description	Rotina para importa鈬o de informa鋏es do arquivo txt GKO e 
				in?cio do processamento                                      /@
@author			Adalberto Moreno Batista (Op鈬o Um Consultoria)              /@
@use			Espec?fico Brasitech                                         /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

/*/
Static Function GKOProc(cArqNF)
Local aStru, cTLOG, aStru2, cTAUX, cArqLog, cSeq

MakeDir("C:\TEMP")

ProcRegua(3) // Numero de processos/sub-processos

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// 1- Criacao das estruturas temporarias para LOG de operacoes e tabela   
//    auxiliar para importacao de registros								  
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
IncProc("Criando estruturas temporarias...")	//1o.

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Tabela de log
// 覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
aStru := {{"LINHA", "C", 200, 0}}
cTLOG := CriaTrab(aStru, .T.)
dbUseArea(.T., "DBFCDX", cTLOG, "TLOG", .T.)

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Tabela auxiliar para importacao
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
aStru2 := {{"DETALHE", "C", 180, 0}}
cTAUX := CriaTrab(aStru2, .T.)
dbUseArea(.T., "DBFCDX", cTAUX, "TAUX", .T.)

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// 2- Importacao arquivo texto em tabela auxiliar                            
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
IncProc("Importando registros em tabela temporaria...")		//2o.

dbSelectArea("TAUX")
Append From &cArqNF SDF
dbGoTop()

If Eof()
	MsgBox("O arquivo de nome " + AllTrim(cArqNF) + " est? vazio!", "Aten鈬o!")
Else
	ImpGKO()
Endif

IncProc("Finalizando processo...")	//3o.

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Gerando log de ocorrencias da importacao                                     
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
dbSelectArea("TLOG")
dbGoTop()
if !eof()
	cSeq	:= "001"
	cArqLog := "C:\TEMP\IMPFAT_" + dtos(dDataBase) + "_" + cSeq + ".LOG"
	do while File(cArqLog)
		cSeq := Soma1(cSeq)
		cArqLog := "C:\TEMP\IMPFAT_" + dtos(dDataBase) + "_" + cSeq + ".LOG"
	enddo
	copy to &cArqLog SDF
	if Aviso("Informacao","Deseja ler o arquivo " + cArqLog + " de log de opera鈬o?",{"Sim","Nao"}) == 1
		if file("C:\WINDOWS\NOTEPAD.EXE")
			WinExec("C:\WINDOWS\NOTEPAD.EXE " + cArqLog, 3)
		else
			WinExec("C:\WINNT\NOTEPAD.EXE " + cArqLog, 3)
		endif
	endif
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// fechando as areas temporarias e excluindo os arquivos de trabalho            
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
dbSelectArea("TLOG")
dbCloseArea()
fErase(cTLOG + ".dbf")

dbSelectArea("TAUX")
dbCloseArea()
fErase(cTAUX + ".dbf")

Return()


/*/

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		ImpGKO                                                       /@
@type			Static function                                              /@
@date			26/07/2014                                                   /@
@description	Importa as informa鋏es do GKO                                /@
@author			Adalberto Moreno Batista (Op鈬o Um Consultoria)              /@
@use			Espec?fico Brasitech                                         /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

/*/
Static Function ImpGKO()
Local aTitulo, cCNPJ, cFatura, cPrefixo, dEmissao, nValor, nDesconto, dVencto,;
	  cInfLog, cCodBar, cAuxCB, nX, cMsgErro, nVlCodBar, dDtVctoBar, lGrvCB
Private lMsErroAuto	:= .F.

dbSelectArea("TAUX")
dbGoTop()
do while TAUX->(!eof())

	cCNPJ		:= Substr(TAUX->DETALHE, 18, 14)
	cFatura		:= Substr(TAUX->DETALHE, 33, 09)
	cPrefixo	:= Substr(TAUX->DETALHE, 44, 03)
	dEmissao	:= cTOd(Substr(TAUX->DETALHE, 47, 10))
	nValor		:= Val(Substr(TAUX->DETALHE, 57, 15)) / 100
	nDesconto	:= Val(Substr(TAUX->DETALHE, 72, 15)) / 100
	dVencto		:= cTOd(Substr(TAUX->DETALHE, 87, 10))
	cAuxCB		:= Substr(TAUX->DETALHE, 112, 54)
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Montagem do c?digo de barras do t?tulo
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	cCodBar	 := ""
	for nX := 1 to Len(AllTrim(cAuxCB))
		cCodBar += iif(IsDigit(Substr(cAuxCB, nX, 1)), Substr(cAuxCB, nX, 1), "")
	next

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// 1-Verifico se o c?digo de barras ? v疝ido, comparando 47 e 44 posi鋏es.
	// 2-Fun鈬o VLCODBAR encontrada no fonte PAGFOR.PRW
	// 3-Analiso o valor do c?digo de barras e comparo com o valor da fatura e caso 
	//   estes valores n縊 baterem, n縊 gravo o codigo de barras
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	if !Empty(cCodBar)
	
		cCodBar	:= Left(cCodBar, 47)
		cCodBar	:= PadR(cCodBar, 47)
		lGrvCB	:= .T.	//Gravo o codigo de barras

		if !U_VLCODBAR(Left(cCodBar,47), .F., @cMsgErro)
			if !U_VLCODBAR(Left(cCodBar,44), .F., @cMsgErro)
				lGrvCB := .F.
			endif
		endif
	
		if lGrvCB
			nVlCodBar 	:= 0
			dDtVctoBar 	:= cTOd("")
			if Len(AllTrim(cCodBar)) == 44					//codigo de barras lido pelo leitor
				nVlCodBar	:= Val(Substr(cCodBar, 10, 10)) / 100
				dDtVctoBar	:= cTOd("07/10/97") + Val(Substr(cCodBar, 06, 04))
			elseif Len(AllTrim(SE2->E2_CODBAR)) == 47		//linha digitavel para boletos registrados
				nVlCodBar	:= Val(Substr(cCodBar, 38, 10)) / 100
				dDtVctoBar 	:= cTOd("07/10/97") + Val(Substr(cCodBar, 34, 04))
			endif

			if nVlCodBar != nValor .or. dDtVctoBar != dVencto
				lGrvCB := .F.
				cMsgErro := "O c?digo de barras n縊 ser? gravado, pois o valor do t?tulo ou a data de vencimento n縊 batem com o valor e data de vencimento encontrado no c?digo de barras."
			endif
		endif
	
		if !lGrvCB
			cCodBar := ""
		endif
		
	endif
			
	cInfLog		:`= "Fatura " + AllTrim(cFatura) + ", s駻ie " + AllTrim(cPrefixo) + " do CNPJ " + Transf(cCNPJ,"@R 99.999.999/9999-99")+" "
    
	SA2->(dbSetOrder(3))
	if SA2->(dbSeek(xFilial("SA2") + cCNPJ))
	
		if SE2->(!dbSeek(xFilial("SE2") + cPrefixo + cFatura + " FT " + SA2->(A2_COD + A2_LOJA)))

			aTitulo 	:= {	{"E2_PREFIXO",	cPrefixo,				Nil},;
								{"E2_NUM",		cFatura,				Nil},;
								{"E2_PARCELA",	" ",					Nil},;
								{"E2_TIPO",		"FT ",					Nil},;
								{"E2_FORNECE",	SA2->A2_COD,			Nil},;
								{"E2_LOJA",		SA2->A2_LOJA,			Nil},;
								{"E2_NOMFOR" ,	SA2->A2_NREDUZ, 		Nil},;
								{"E2_NATUREZ",	SA2->A2_NATUREZ,		Nil},;
								{"E2_EMISSAO",	dEmissao,				Nil},;
								{"E2_VENCTO",	dVencto,			   	Nil},;
								{"E2_VENCREA",	DataValida(dVencto),	Nil},;
								{"E2_VALOR",	nValor,					Nil},;
								{"E2_DECRESC",	nDesconto,				Nil},;
								{"E2_HIST",		"Fatura GKO",			Nil},;
								{"E2_CODBAR",	cCodBar,				Nil}}
		
			SA2->(dbSetOrder(1))
			SE2->(dbSetOrder(1))
			lMsErroAuto := .F.
			
			MsExecAuto({ |x,y,z| FINA050(x,y,z) }, aTitulo,, 3)
					
			if lMsErroAuto
				
				DisarmTransaction()
				GKOGrvLog(cInfLog + "n縊 ser? importado. Motivo: Ocorr麩cia de erro no msexecauto. Verifique!", NomeAutoLog())
				
			else
			
				GKOGrvLog(cInfLog + "IMPORTADO COM SUCESSO. Localizador no contas a pagar (Prefixo/Numero/Parcela/Tipo/Fornecedor/Loja) '" +;
						  SE2->(E2_PREFIXO + "/" + E2_NUM + "/" + E2_PARCELA + "/" + E2_TIPO + "/" + E2_FORNECE + "/" + E2_LOJA) +;
						  iif(!Empty(cMsgErro), "' O c?digo de barras n縊 foi gravado. Motivo: " + cMsgErro, "'"))
					
			endif
			
		else
		
			GKOGrvLog(cInfLog + "n縊 ser? importado. Motivo: T?tulo (Prefixo/Numero/Parcela/Tipo/Fornecedor/Loja) '" +;
					  SE2->(E2_PREFIXO + "/" + E2_NUM + "/" + E2_PARCELA + "/" + E2_TIPO + "/" + E2_FORNECE + "/" + E2_LOJA) +;
					  "' j? cadastrado. Verifique!")
			
		endif
		
    else
    
	    GKOGrvLog(cInfLog + "n縊 ser? importado. Motivo: N縊 encontrado fornecedor para o respectivo CNPJ. Verifique!")
	    
    endif

	TAUX->(dbSkip())
			
enddo
		
Return()


/*/

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		GKOGrvLog                                                    /@
@type			Static function                                              /@
@date			07/05/2011                                                   /@
@description	Grava informa鋏es no log de processamento.                   /@
@author			Adalberto Moreno Batista (Op鈬o Um Consultoria)              /@
@use			Espec?fico Brasitech                                         /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

/*/
Static Function GKOGrvLog(cErro, cArqErro)
Local aArea		:= GetArea()

dbSelectArea("TLOG")
TLOG->(RecLock("TLOG",.T.))
TLOG->LINHA	:= cErro
TLOG->(MsUnlock())

if cArqErro<>NIL
	Append From &cArqErro SDF
	fErase(cArqErro)
endif

RestArea(aArea)

Return()
