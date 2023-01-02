#include "rwmake.ch"
#include "protheus.ch"

/*/
�������������������������������������������������������������������������������
@function		BGPEA03                                                       /@
@type				User function                                                 /@
@date				14/07/2016                                                    /@
@description	Rotina para exporta��o de informa��es referentes ao resultado
					da importa��o do MOVIMENTO.
					Arquivo RETORNO integra��o empresa ZETRA                      /@
@author			Adalberto Moreno Batista (Op��o Um Consultoria)               /@
@use				Espec�fico Brasitech                                          /@
�������������������������������������������������������������������������������
/*/
User Function BGPEA03()
Local cPerg			:= PadR("BGPEA03", Len(SX1->X1_GRUPO))
Local aRegs    	:= {}
Local aCabSX1		:= {"X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_GSC", "X1_VAR01"}
Local aHlp01		:= {"Informe o caminho do diret�rio onde ser� ", " gravado o arquivo RETORNO_aaaamm.txt ", " para integra��o com a empresa ZETRA.     ", "Espec�fico Brasitech."}
Local aSay			:= {}
Local aButton		:= {}
Local nOpc			:= 0
Local cCadastro	:= "Arquivo RETORNO - Integra��o Zetra"
Local aArea			:= GetArea()

//parametros para o processamento
aAdd(aRegs, {cPerg, "01", "Exportar p/ o diretorio:", "mv_ch1", "C", 40, 0, "G", "mv_par01"})

U_BRASX1(aRegs, aCabSX1)

PutSX1Help("P." + AllTrim(cPerg) + "01.", aHlp01, aHlp01, aHlp01)

Pergunte(cPerg,.F.)

//�������������������������������������������������������������������������������
// Criacao da Interface
//�������������������������������������������������������������������������������
aAdd(aSay, "Exporta��o de registros ajustados pelo departamento pessoal, referente ao movimento")
aAdd(aSay, "Verifica conte�do do MV_FOLMES.")
aAdd(aSay, "Informar o drive e caminho para a grava��o do arquivo. O nome ser� padronizado com")
aAdd(aSay, "RETORNO_aaaamm.TXT, onde mm ser� o m�s e aaaa o ano do fechamento da folha.")

aAdd(aButton, {1, .T., {|| nOpc := 1,	FechaBatch()	}})
aAdd(aButton, {2, .T., {|| FechaBatch()					}})
aAdd(aButton, {5, .T., {|| Pergunte(cPerg, .T.)			}})

FormBatch(cCadastro, aSay, aButton)

if nOpc == 1

	ProcRegua(2) // Numero de processos/sub-processos

	IncProc("Exportando registros para o arquivo texto...")		//1o.

	Set Century On
	
	Processa({|lEnd| ExpZetra()}, "Integra��o Protheus x Zetra", "Exportando registros para o arquivo texto...", .T.)
	
	Set Century Off

	IncProc("Finalizando processo...")	//2o.
	
Endif   

//�������������������������������������������������������������������������������
// Restaura a posicao original das areas de trabalho
//�������������������������������������������������������������������������������
RestArea(aArea)
Return()


/*/
�������������������������������������������������������������������������������
@function		ExpZetra                                                      /@
@type				Static function                                               /@
@date				11/07/2016                                                    /@
@description	Gera arquivo texto com informa��es do layout MARGEM.          /@
@author			Adalberto Moreno Batista (Op��o Um Consultoria)               /@
@use				Espec�fico Brasitech                                          /@
�������������������������������������������������������������������������������
/*/
Static Function ExpZetra()
Local cDetalhe
Local cEol		:= chr(13) + chr(10)
Local cDtFolha	:= AllTrim(GetMV("MV_FOLMES"))
Local cArquivo	:= AllTrim(mv_par01) + iif(Right(AllTrim(mv_par01),1) == "\", "", "\") + "RETORNO_" + cDtFolha + ".TXT"
Local lOk		:= .T.

nHdl := fCreate(cArquivo)

if nHdl == -1
	Help(,, "ATEN��O",, "O arquivo " + cArquivo + " n�o pode ser criado! Verifique os par�metros." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec�fico Brasitech)", 1)
	Return()
endif

//�������������������������������������������������������������������������������
// Selecionando registros
//�������������������������������������������������������������������������������
cQuery := 	"SELECT ZZ4_FILIAL, ZZ4_PERIOD, ZZ4_MAT, ZZ4_PD, ZZ4_VALOR, ZZ4_VLREAL, ZZ4_HORAS, ZZ4_SITUAC, ZZ4_MOTIVO, RA_CIC, RA_NOME "
cQuery += 	"FROM " + RetSQLName("ZZ4") + " ZZ4, " + RetSQLName("SRA") + " SRA "
cQuery += 	"WHERE ZZ4.ZZ4_PERIOD = '" + cDtFolha + "' "
cQuery +=			"AND ZZ4.D_E_L_E_T_ = ' ' "
cQuery +=			"AND SRA.RA_FILIAL = ZZ4.ZZ4_FILIAL "
cQuery +=			"AND SRA.RA_MAT = ZZ4.ZZ4_MAT "
cQuery +=			"AND SRA.D_E_L_E_T_=' ' "

cQuery += 	"ORDER BY ZZ4_FILIAL, ZZ4_MAT, ZZ4_PD"

if Select("TRAB") > 0
	TRAB->(dbCloseArea())
endif
	
dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery),"TRAB", .F., .T.)

dbSelectArea("TRAB")
dbGotop()
if !eof()
	do while !eof()
	
		//�������������������������������������������������������������������������������
		// Gera Detalhe - Registro 100 Parceiros
		//�������������������������������������������������������������������������������
		cDetalhe := "0000" + TRAB->ZZ4_MAT												//Matr�cula
		cDetalhe += PadR(TRAB->RA_CIC,11)												//CPF
		cDetalhe += PadR(TRAB->RA_NOME,50)												//Nome do Servidor
		cDetalhe += "000"																		//Estabelecimento
		cDetalhe += PadR(TRAB->ZZ4_FILIAL,3)											//�rg�o
		cDetalhe += PadR(TRAB->ZZ4_PD,3)													//Verba
		cDetalhe += StrZero(TRAB->ZZ4_VALOR,10,2)										//Margem prevista
		cDetalhe += StrZero(TRAB->ZZ4_VLREAL,10,2)									//Margem realizada
		cDetalhe += PadR(TRAB->ZZ4_MOTIVO,100)											//Motivo
		cDetalhe += TRAB->ZZ4_SITUACA														//Situa��o
		cDetalhe += Right(TRAB->ZZ4_PERIOD,2) + Left(TRAB->ZZ4_PERIOD,4)		//Periodo MMAAAA
		cDetalhe += cEol
		
		if fWrite(nHdl,cDetalhe,Len(cDetalhe)) != Len(cDetalhe)
			if !MsgBox("Ocorreu um erro na gravacao do arquivo. Continua?", "Pergunta", "YESNO")
				lOk	:= .F.
				Exit
			endif
		endif
			
		TRAB->(dbSkip())
	
	enddo
	
else

	lOk	:= .F.
	
Endif

fClose(nHdl)

if Select("TRAB") > 0
	TRAB->(dbCloseArea())
endif

if lOk

	MsgBox("O arquivo " + cArquivo + " foi criado com sucesso!" + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec�fico Brasitech)", "Informa��o", "INFO")
	
else

	Help(,, "ATEN��O",, "N�o foi encontrado registros dentro dos par�metros informados." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec�fico Brasitech)", 1)
   
endif

Return()