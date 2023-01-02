#include "rwmake.ch"
#include "protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BGPEA01                                                       /@
@type				User function                                                 /@
@date				07/07/2016                                                    /@
@description	Rotina para exportação de informações referentes ao fechamento
					da folha de pagamento.
					Arquivo MARGEM integração empresa ZETRA                       /@
@author			Adalberto Moreno Batista (Opção Um Consultoria)               /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function BGPEA01()
Local cPerg			:= PadR("BGPEA01",Len(SX1->X1_GRUPO))
Local aRegs    	:= {}
Local aCabSX1		:= {"X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_GSC", "X1_VAR01"}
Local aHlp01		:= {"Informe o caminho do diretório onde será ", " gravado o arquivo MARGEM_aaaamm.txt ", " para integração com a empresa ZETRA.     ", "Específico Brasitech."}
Local aSay			:= {}
Local aButton		:= {}
Local nOpc			:= 0
Local cCadastro	:= "Arquivo MARGEM - Integração Zetra"
Local aArea			:= GetArea()
Local aAreaSRA		:= SRA->(GetArea())
Local aAreaRGB		:= RGB->(GetArea())
Local aAreaSRV		:= SRV->(GetArea())

//parametros para o processamento
aAdd(aRegs, {cPerg, "01", "Exportar p/ o diretorio:", "mv_ch1", "C", 40, 0, "G", "mv_par01"})

U_BRASX1(aRegs, aCabSX1)

PutSX1Help("P." + AllTrim(cPerg) + "01.", aHlp01, aHlp01, aHlp01)

Pergunte(cPerg,.F.)

//———————————————————————————————————————————————————————————————————————————————
// Criacao da Interface
//———————————————————————————————————————————————————————————————————————————————
aAdd(aSay, "Exportação de informações referentes ao último fechamento de folha de pagamento.")
aAdd(aSay, "Verifica conteúdo do MV_FOLMES.")
aAdd(aSay, "Informar o drive e caminho para a gravação do arquivo. O nome será padronizado com")
aAdd(aSay, "MARGEM_aaaamm.TXT, onde mm será o mês e aaaa o ano do fechamento da folha.")

aAdd(aButton, {1, .T., {|| nOpc := 1,	FechaBatch()	}})
aAdd(aButton, {2, .T., {|| FechaBatch()					}})
aAdd(aButton, {5, .T., {|| Pergunte(cPerg, .T.)			}})

FormBatch(cCadastro, aSay, aButton)

if nOpc == 1

	ProcRegua(2) // Numero de processos/sub-processos

	IncProc("Exportando registros para o arquivo texto...")		//1o.

	Set Century On
	
	Processa({|lEnd| ExpZetra()}, "Integração Protheus x Zetra", "Exportando registros para o arquivo texto...", .T.)
	
	Set Century Off

	IncProc("Finalizando processo...")	//2o.
	
Endif   

//———————————————————————————————————————————————————————————————————————————————
// Restaura a posicao original das areas de trabalho
//———————————————————————————————————————————————————————————————————————————————
RestArea(aAreaSRV)
RestArea(aAreaRGB)
RestArea(aAreaSRA)
RestArea(aArea)
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		ExpZetra                                                      /@
@type				Static function                                               /@
@date				11/07/2016                                                    /@
@description	Gera arquivo texto com informações do layout MARGEM.          /@
@author			Adalberto Moreno Batista (Opção Um Consultoria)               /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function ExpZetra()
Local cDetalhe
Local cEol		:= chr(13) + chr(10)
Local cDtFolha	:= AllTrim(GetMV("MV_FOLMES"))
Local cArquivo	:= AllTrim(mv_par01) + iif(Right(AllTrim(mv_par01),1) == "\", "", "\") + "MARGEM_" + cDtFolha + ".TXT"
Local lOk		:= .T.

nHdl := fCreate(cArquivo)

if nHdl == -1
	Help(,, "ATENÇÃO",, "O arquivo " + cArquivo + " não pode ser criado! Verifique os parâmetros." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech)", 1)
	Return()
endif


//———————————————————————————————————————————————————————————————————————————————
// Selecionando registros
//———————————————————————————————————————————————————————————————————————————————
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
	
		//———————————————————————————————————————————————————————————————————————————————
		// Gera Detalhe - Registro 100 Parceiros
		//———————————————————————————————————————————————————————————————————————————————
		cMat		:= TRAB->RA_MAT							//Matrícula
		cCPF		:= TRAB->RA_CIC							//CPF
		cNome		:= TRAB->RA_NOME							//Nome do Servidor
		cGamaFil	:= TRAB->RA_FILIAL						//Órgão
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
		
		cDetalhe := PadR(cMat, 10)							//Matrícula
		cDetalhe += PadR(cCPF, 11)							//CPF
		cDetalhe += PadR(cNome, 50)						//Nome do Servidor
		cDetalhe += "000"										//Estabelecimento
		cDetalhe += PadR(cGamaFil, 3)						//Órgão
		cDetalhe += StrZero(nMargem,10,2)				//Margem
		cDetalhe += StrTran(dTOc(dNascim), "/", "")	//Data de Nascimento
		cDetalhe += StrTran(dTOc(dAdmis), "/", "")	//Data da Admissão
		cDetalhe += PadR("", 8)								//Data Fim do Contrato
		cDetalhe += PadR("CLT", 40)						//Regime trabalho (vínculo)
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

	MsgBox("O arquivo " + cArquivo + " foi criado com sucesso!" + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech)", "Informação", "INFO")
	
else

	Help(,, "ATENÇÃO",, "Não foi encontrado registros dentro dos parâmetros informados." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech)", 1)
   
endif

Return()
