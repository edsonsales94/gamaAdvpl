#include "rwmake.ch"
#include "protheus.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		BGPEA01                                                       /@
@type				User function                                                 /@
@date				07/07/2016                                                    /@
@description	Rotina para exporta鈬o de informa鋏es referentes ao fechamento
					da folha de pagamento.
					Arquivo MARGEM integra鈬o empresa ZETRA                       /@
@author			Adalberto Moreno Batista (Op鈬o Um Consultoria)               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function BGPEA01()
Local cPerg			:= PadR("BGPEA01",Len(SX1->X1_GRUPO))
Local aRegs    	:= {}
Local aCabSX1		:= {"X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_GSC", "X1_VAR01"}
Local aHlp01		:= {"Informe o caminho do diret?rio onde ser? ", " gravado o arquivo MARGEM_aaaamm.txt ", " para integra鈬o com a empresa ZETRA.     ", "Espec?fico Brasitech."}
Local aSay			:= {}
Local aButton		:= {}
Local nOpc			:= 0
Local cCadastro	:= "Arquivo MARGEM - Integra鈬o Zetra"
Local aArea			:= GetArea()
Local aAreaSRA		:= SRA->(GetArea())
Local aAreaRGB		:= RGB->(GetArea())
Local aAreaSRV		:= SRV->(GetArea())

//parametros para o processamento
aAdd(aRegs, {cPerg, "01", "Exportar p/ o diretorio:", "mv_ch1", "C", 40, 0, "G", "mv_par01"})

U_BRASX1(aRegs, aCabSX1)

PutSX1Help("P." + AllTrim(cPerg) + "01.", aHlp01, aHlp01, aHlp01)

Pergunte(cPerg,.F.)

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Criacao da Interface
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
aAdd(aSay, "Exporta鈬o de informa鋏es referentes ao ?ltimo fechamento de folha de pagamento.")
aAdd(aSay, "Verifica conte?do do MV_FOLMES.")
aAdd(aSay, "Informar o drive e caminho para a grava鈬o do arquivo. O nome ser? padronizado com")
aAdd(aSay, "MARGEM_aaaamm.TXT, onde mm ser? o m黌 e aaaa o ano do fechamento da folha.")

aAdd(aButton, {1, .T., {|| nOpc := 1,	FechaBatch()	}})
aAdd(aButton, {2, .T., {|| FechaBatch()					}})
aAdd(aButton, {5, .T., {|| Pergunte(cPerg, .T.)			}})

FormBatch(cCadastro, aSay, aButton)

if nOpc == 1

	ProcRegua(2) // Numero de processos/sub-processos

	IncProc("Exportando registros para o arquivo texto...")		//1o.

	Set Century On
	
	Processa({|lEnd| ExpZetra()}, "Integra鈬o Protheus x Zetra", "Exportando registros para o arquivo texto...", .T.)
	
	Set Century Off

	IncProc("Finalizando processo...")	//2o.
	
Endif   

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Restaura a posicao original das areas de trabalho
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
RestArea(aAreaSRV)
RestArea(aAreaRGB)
RestArea(aAreaSRA)
RestArea(aArea)
Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		ExpZetra                                                      /@
@type				Static function                                               /@
@date				11/07/2016                                                    /@
@description	Gera arquivo texto com informa鋏es do layout MARGEM.          /@
@author			Adalberto Moreno Batista (Op鈬o Um Consultoria)               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function ExpZetra()
Local cDetalhe
Local cEol		:= chr(13) + chr(10)
Local cDtFolha	:= AllTrim(GetMV("MV_FOLMES"))
Local cArquivo	:= AllTrim(mv_par01) + iif(Right(AllTrim(mv_par01),1) == "\", "", "\") + "MARGEM_" + cDtFolha + ".TXT"
Local lOk		:= .T.

nHdl := fCreate(cArquivo)

if nHdl == -1
	Help(,, "ATENﾇﾃO",, "O arquivo " + cArquivo + " n縊 pode ser criado! Verifique os par穃etros." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec?fico Brasitech)", 1)
	Return()
endif


//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Selecionando registros
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
cQuery := 	"SELECT RA_FILIAL, RA_MAT, RA_CIC, RA_NOME, RA_NASC, RA_ADMISSA, RA_CC, RA_RG, RA_RGUF, RGB_VALOR, CTT_DESC01, RV_TIPOCOD "
cQuery += 	"FROM " + RetSQLName("SRA") + " SRA, " + RetSQLName("RGB") + " RGB, " + RetSQLName("SRV") + " SRV, " + RetSqlName("CTT") + " CTT "

cQuery += 	"WHERE SRA.RA_SITFOLH != 'D' "
cQuery +=			"AND SRA.RA_CATFUNC = 'M' "
cQuery +=			"AND SRA.D_E_L_E_T_ = ' ' "

cQuery +=			"AND RGB.RGB_FILIAL = SRA.RA_FILIAL "
cQuery +=			"AND RGB.RGB_MAT = SRA.RA_MAT " 
cQuery +=			"AND RGB.RGB_PERIOD = '" + cDtFolha + "' " 
cQuery +=			"AND RGB.D_E_L_E_T_=' ' "

cQuery +=			"AND SRV.RV_FILIAL = SRA.RA_FILIAL "
cQuery +=			"AND SRV.RV_COD = RGB.RGB_PD "
cQuery +=			"AND SRV.RV_XINTZET = '1' "
cQuery +=			"AND SRV.RV_TIPOCOD IN ('2','3') "
cQuery +=			"AND SRV.D_E_L_E_T_=' ' "

cQuery += 			"AND CTT.CTT_FILIAL = '" + xFilial("CTT") + "' "
cQuery += 			"AND CTT.CTT_CUSTO = SRA.RA_CC "
cQuery += 			"AND CTT.D_E_L_E_T_=' ' "

cQuery += 	"ORDER BY RA_FILIAL, RA_MAT, RGB_PD"

if Select("TRAB") > 0
	TRAB->(dbCloseArea())
endif
	
dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery),"TRAB", .F., .T.)
TcSetField("TRAB", "RA_NASC", "D")
TcSetField("TRAB", "RA_ADMISSA", "D")

dbSelectArea("TRAB")
dbGotop()
if !eof()
	do while !eof()
	
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		// Gera Detalhe - Registro 100 Parceiros
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
		cMat		:= TRAB->RA_MAT							//Matr?cula
		cCPF		:= TRAB->RA_CIC							//CPF
		cNome		:= TRAB->RA_NOME							//Nome do Servidor
		cGamaFil	:= TRAB->RA_FILIAL						//ﾓrg縊
		dNascim	:= TRAB->RA_NASC
		dAdmis	:= TRAB->RA_ADMISSA
		cLocTrab	:= TRAB->(RA_CC + CTT_DESC01)
		cRg		:= TRAB->(RA_RG + RA_RGUF)
		nMargem 	:= 0
		
		do while !eof() .and. RA_FILIAL == cGamaFil .and. RA_MAT == cMat
			if TRAB->RV_TIPOCOD == "3"
				nMargem += TRAB->RGB_VALOR
			else                        
				nMargem -= TRAB->RGB_VALOR
			endif
			TRAB->(dbSkip())
		enddo
		
		nMargem := iif(nMargem < 0, 0, nMargem)
		
		cDetalhe := PadR(cMat, 10)							//Matr?cula
		cDetalhe += PadR(cCPF, 11)							//CPF
		cDetalhe += PadR(cNome, 50)						//Nome do Servidor
		cDetalhe += "000"										//Estabelecimento
		cDetalhe += PadR(cGamaFil, 3)						//ﾓrg縊
		cDetalhe += StrZero(nMargem,10,2)				//Margem
		cDetalhe += StrTran(dTOc(dNascim), "/", "")	//Data de Nascimento
		cDetalhe += StrTran(dTOc(dAdmis), "/", "")	//Data da Admiss縊
		cDetalhe += PadR("", 8)								//Data Fim do Contrato
		cDetalhe += PadR("CLT", 40)						//Regime trabalho (v?nculo)
		cDetalhe += PadR(cLocTrab, 40)					//Local de Trabalho
		cDetalhe += PadR(cRg, 15)							//Carteira Identidade
		cDetalhe += cEol
		
		if fWrite(nHdl,cDetalhe,Len(cDetalhe)) != Len(cDetalhe)
			if !MsgBox("Ocorreu um erro na gravacao do arquivo. Continua?", "Pergunta", "YESNO")
				lOk	:= .F.
				Exit
			endif
		endif

	enddo
	
else

	lOk	:= .F.
	
endif

fClose(nHdl)

if Select("TRAB") > 0
	TRAB->(dbCloseArea())
endif

if lOk

	MsgBox("O arquivo " + cArquivo + " foi criado com sucesso!" + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec?fico Brasitech)", "Informa鈬o", "INFO")
	
else

	Help(,, "ATENﾇﾃO",, "N縊 foi encontrado registros dentro dos par穃etros informados." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec?fico Brasitech)", 1)
   
endif

Return()
