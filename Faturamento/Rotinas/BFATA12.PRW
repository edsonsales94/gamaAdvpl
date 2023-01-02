/*/                 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BFATA12  ³ Por: Luiz Fernando Nogueira ³  Data  ³ 29/01/15³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina para importacao de Meta Comercial em Planilha		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Brasitech                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

#include "rwmake.ch"
#include "tbiconn.ch"

User Function BFATA12()
Local aButton		:= {}
Local aSay			:= {}
Local nOpc			:= 0
Local cCadastro		:= "Importação de Metas Comerciais"
Local aArea			:= GetArea()
Local aAreaSZC		:= SZC->(GetArea())
Local aAreaSZY		:= SZY->(GetArea())


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Interface                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd ( aSay , "Importação de metas comerciais utilizando planilha excel como base" )
aAdd ( aSay , "Atenção: o formato do arquivo deve ser .CSV")

aAdd ( aButton , { 1 , .T. , { || nOpc := 1,	FechaBatch()	}} )
aAdd ( aButton , { 2 , .T. , { || FechaBatch()					}} )

FormBatch( cCadastro , aSay , aButton )

If nOpc == 1

	_cArqMeta 	:= cGetFile("Arquivos |*.CSV|Todos os Arquivos|*.*",OemToAnsi("Selecione o arquivo")) //,0,,.T.,GETF_OVERWRITEPROMPT)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verificando se o processo ira ser continuado                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if !File(_cArqMeta)

		MsgBox("O arquivo nao foi localizado. O PROCESSO NAO PODERA SER INICIADO.","ATENCAO","ERRO")
		
	ElseIf MsgBox("Confirma importação da planilha de metas de vendas?", "Importação de Metas Comerciais", "YESNO" )
		
		Processa( { |lEnd| impcsv(_cArqMeta) } , "Importação de Metas Comerciais" , "Importando metas" , .T. )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ renomeando o arquivo lido                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fClose( _cArqMeta )
		nDotPos := At( ".", _cArqMeta )
		if nDotPos > 0
			_cNewArqTab := Substr( _cArqMeta, 1, nDotPos ) + "ok"
 			__CopyFile( _cArqMeta, _cNewArqTab )
 		endif
		fErase( _cArqMeta )
	Else
		MsgBox("O arquivo nao foi localizado. O PROCESSO NAO PODERA SER INICIADO.","ATENCAO","ERRO")
	Endif   

Endif   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a posicao original das areas de trabalho ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea( aAreaSZY )
RestArea( aAreaSZC )
RestArea( aArea )
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ Impcsv      ³ Por: Adalberto Moreno Batista ³ Data ³15.05.2011³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function impcsv(_cArqMeta)

Local aCampos := {}
Local aDados := {}
Local lPrim	:= .T.

ProcRegua(3) // Numero de processos/sub-processos

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º 1- Carregando arrays  com os dados do arquivoº
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

IncProc("Realizando leitura do arquivo ...")		//1o.

FT_FUSE(_cArqMeta)
FT_FGOTOP()

If !FT_FEOF()
	While !FT_FEOF()
		cLinha := FT_FREADLN()
		If lPrim
			lPrim := .F.
		Else
			AADD(aDados,Separa(cLinha,";",.T.))
		EndIf
		FT_FSKIP()
	EndDo
	FT_FUSE()
	ImpCsv_A(aDados)		
Else
	MsgBox("O arquivo de nome " + AllTrim(_cArqMeta) + " está vazio!","Atencao!")
Endif

IncProc("Finalizando processo...")	//3o.
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ ImpCsv_A           ³ Por: Adalberto Moreno Batista ³ Data ³15.05.2011³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Posições do array aDados³													 ±±
±±³aDados[x][1] == ZY_CODREP													 ±±
±±³aDados[x][2] == ZY_XNEGOCI													 ±±
±±³aDados[x][3] == ZY_MIX													 	 ±±
±±³aDados[x][4] == ZY_MES													 	 ±±
±±³aDados[x][5] == ZY_ANO													 	 ±±
±±³aDados[x][6] == ZY_VALOR														 ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpCsv_A(aDados)
Local x
Local cLogMix	:= ""
Local cLogExist	:= ""
Local cLogVazio	:= ""	
Local cLog		:= ""
Local nMetaTotal := 0
Local cNomeLog	:= "C:\TEMP\IMPTAB_" + StrTran(dTOs(Date()) + "_" + time() + ".LOG", ":", "-")
Local cEol		:= chr(13) + chr(10)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criando o diretorio de log de processamento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeDir("C:\TEMP")

IncProc("Importando dados ...")		//2o.

SZC->(dbSetOrder(1))
SZY->(dbSetOrder(1))

For x:=1 to len(aDados)

	if SZC->(!dbSeek(xFilial("SZC")+aDados[x][1]))
		Reclock("SZC", .T.)
		SZC->ZC_CODREP 	:= aDados[x][1]
		SZC->(Msunlock())
	endif

	if !empty(aDados[x][1]) .and. !empty(aDados[x][2]) .and. !empty(aDados[x][3]) .and. !empty(aDados[x][4]) .and. !empty(aDados[x][5]) .and. !empty(aDados[x][6]) .and. aDados[x][6] > '0'
		if SBM->(dbSeek(xFilial("SBM")+PADL(aDados[x][3],2,"0")))	
			if SZY->(!dbSeek(xFilial("SZY")+PADR(aDados[x][1],6)+StrZero(val(aDados[x][2]),2)+padr(StrZero(val(aDados[x][3]),2),3) +StrZero(val(aDados[x][4]),2)+aDados[x][5]))
				Reclock("SZY",.T.)
				SZY->ZY_FILIAL 	:= xFilial("SZY")
				SZY->ZY_CODREP	:= aDados[x][1]
				SZY->ZY_XNEGOCI	:= PADL(aDados[x][2],2,"0")
				SZY->ZY_MIX		:= PADL(aDados[x][3],2,"0")
				SZY->ZY_MES		:= PADL(aDados[x][4],2,"0")
				SZY->ZY_ANO		:= aDados[x][5]
				SZY->ZY_VALOR	:= val(STRTRAN(aDados[x][6],",","."))
				SZY->(msunlock())
				
				nMetaTotal	+= val(STRTRAN(aDados[x][6],",","."))
			else
				cLogExist += "Meta não cadastrada pois já existe para Representante:" + aDados[x][1] +", Negocio: "+ PADL(aDados[x][2],2,"0") +", Mix: "+ PADL(aDados[x][3],2,"0")
				cLogExist += ", Mês/Ano: "+ PADL(aDados[x][4],2,"0")+"/"+aDados[x][5] + cEol
			endif
		else
			cLogMix += "Meta não cadastrada pois não existe o Mix para Representante:" + aDados[x][1] +", Negocio: "+ PADL(aDados[x][2],2,"0") +", Mix: "+ PADL(aDados[x][3],2,"0")
			cLogMix += ", Mês/Ano: "+ PADL(aDados[x][4],2,"0")+"/"+aDados[x][5] + cEol
		endif
	else
		cLogVazio += "Meta não cadastrada pois faltam informações para Representante:" + aDados[x][1] +", Negocio: "+ aDados[x][2] +", Mix: "+ aDados[x][3]
		cLogVazio += ", Mês/Ano: "+ aDados[x][4]+"/"+aDados[x][5] + ", Valor:"+ aDados[x][6] + cEol    	
	endif
Next

cLog += "Valor Total de Metas Importadas: R$ "+ Transform(nMetaTotal,"@E 999,999,999.99") + cEol
cLog += Replicate("-",130)+ cEol

if !empty(cLogMix)
	cLog += "Erros:" + cEol
	cLog += cLogMix 
	cLog += Replicate("-",130)+ cEol
endif

if !empty(cLogExist)
	cLog += "Erros:" + cEol
	cLog += cLogExist 
	cLog += Replicate("-",130)+ cEol
endif

if !empty(cLogVazio)
	cLog += "Erros:" + cEol
	cLog += cLogVazio 
	cLog += Replicate("-",130)+ cEol
endif

if !empty(cLog)
	MemoWrite(cNomeLog, cLog)
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre arquivo de log ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if File(cNomeLog)

	if MsgBox("Deseja ler o log de ocorrências do processamento ? (" + cNomeLog + ")", "Pergunta", "YESNO")

		if file("C:\WINDOWS\NOTEPAD.EXE")
			WinExec("C:\WINDOWS\NOTEPAD.EXE " + cNomeLog, 3)
		else
			WinExec("C:\WINNT\NOTEPAD.EXE " + cNomeLog,3)
		endif

	endif

endif
	

Return()