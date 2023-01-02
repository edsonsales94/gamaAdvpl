#include "protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		CT220REL                                                      /@
@date				05/03/2018                                                    /@
@type				Ponto de entrada                                              /@
@description	O PE CT220REL será executado no final do processamento. Poderá
					ser utilizado para emissão de relatórios ou gravação de dados
					no processamento                                              /@
@author			Adalberto Moreno Batista (Opção Um)                           /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function CT220REL()
Local dAntDataBase	:= dDataBase
Local aArea				:= GetArea()
Private lMsErroAuto	:= .F.

//———————————————————————————————————————————————————————————————————————————————
// Cria lançamento contábil para a transferência de valores da conta 4210202060
// para a 4210201002, após a conclusão do processo de consolidação contábil.
//———————————————————————————————————————————————————————————————————————————————
A_CT220REL()


//———————————————————————————————————————————————————————————————————————————————
// Cria lançamentos contábeis na conta 4210102021 e centro de custo 1124 e 1126,
// de acordo com os valores encontrados nas contas de 4210201001 à 4210201100 e
// centros de custo 1124 e 1126. Utilizar o mesmo histórico do lançamento origem 
// e com data do último dia do período contábil.
//———————————————————————————————————————————————————————————————————————————————
B_CT220REL()


//———————————————————————————————————————————————————————————————————————————————
// Restaurando data base e alias padrão
//———————————————————————————————————————————————————————————————————————————————
dDataBase := dAntDataBase
RestArea(aArea)

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		A_CT220REL                                                    /@
@date				05/03/2018                                                    /@
@type				Static Function                                               /@
@description	Chamada pelo PE CT220REL, cria lançamento contábil para a 
					transferência de valores da conta 4210202060 para a 4210201002,
					após a conclusão do processo de consolidação contábil.        /@
@author			Adalberto Moreno Batista (Opção Um)                           /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function A_CT220REL()
Local aCab, aItem, cDoc, cLinha, cConta, cCCusto, nValor, cHistor
Local cQuery := 	"SELECT CT2_DATA DTLANC, CT2_DEBITO CONTA, CT2_CCD CCUSTO, SUM(CT2_VALOR) VALOR " +;
						"FROM " + RetSQLName("CT2") + " CT2 " +;
						"WHERE CT2_FILIAL='" + xFilial("CT2") + "' " +;
							"AND CT2_DATA BETWEEN '" + dTOs(mv_par02) + "' AND '" + dTOs(mv_par03) + "' " +;
							"AND CT2_MOEDLC='01' " +;
							"AND CT2_DEBITO='4210202060' " +;
							"AND D_E_L_E_T_='' " +;
						"GROUP BY CT2_DATA, CT2_DEBITO, CT2_CCD " +;
						"UNION " +;
						"SELECT CT2_DATA DTLANC, CT2_CREDIT CONTA, CT2_CCC CCUSTO, SUM(CT2_VALOR)*-1 VALOR " +;
						"FROM " + RetSQLName("CT2") + " CT2 " +;
						"WHERE CT2_FILIAL='" + xFilial("CT2") + "' " +;
							"AND CT2_DATA BETWEEN '" + dTOs(mv_par02) + "' AND '" + dTOs(mv_par03) + "' " +;
							"AND CT2_MOEDLC='01' " +;
							"AND CT2_CREDIT='4210202060' " +;
							"AND D_E_L_E_T_='' " +;
						"GROUP BY CT2_DATA, CT2_CREDIT, CT2_CCC " +;
						"ORDER BY DTLANC, CONTA, CCUSTO"

//———————————————————————————————————————————————————————————————————————————————
// Cria tabela temporaria
//———————————————————————————————————————————————————————————————————————————————
if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQRY(,,cQuery), "TEMP", .F., .T.)
TcSetField("TEMP", "DTLANC", "D")

//———————————————————————————————————————————————————————————————————————————————
// Processa registros e cria lancamentos de estorno
//———————————————————————————————————————————————————————————————————————————————
dbSelectArea("CT2")

do while TEMP->(!eof())
                          
	dDataBase	:= TEMP->DTLANC
	aItem			:= {}
	cDoc			:= "000001"
	cLinha		:= "001"
	cHistor		:= "TRANSF. REFER. TITULO-SALARIOS " + Substr(dTOs(mv_par03), 5, 2) + "/" + Left(dTOs(mv_par03), 4)
	
	do while TEMP->(!eof() .and. DTLANC==dDataBase)

		cConta 	:= TEMP->CONTA
		cCCusto	:= TEMP->CCUSTO
		nValor	:= 0
			
		do while TEMP->(!eof() .and. DTLANC==dDataBase .and. CONTA==cConta .and. CCUSTO==cCCusto)
			nValor += TEMP->VALOR
			TEMP->(dbSkip())
		enddo
	
		if nValor != 0
			aAdd(aItem, {	{"CT2_DC",		"3",														NIL},;
								{"CT2_LINHA",	cLinha,													NIL},;
								{"CT2_DEBITO",	iif(nValor > 0, "4210201002", "4210202060"),	NIL},;
								{"CT2_CREDIT",	iif(nValor > 0, "4210202060", "4210201002"),	NIL},;
								{"CT2_CCD",		cCCusto,													NIL},;
								{"CT2_CCC",		cCCusto,													NIL},;
								{"CT2_VALOR",	Abs(nValor), 											NIL},;
								{"CT2_MOEDLC",	"01",														NIL},;
								{"CT2_TPSALD",	"1",														NIL},;
								{"CT2_HIST",	cHistor,													NIL}})
	
			cLinha	:= Soma1(cLinha)
		endif
	
	enddo
	
	if Len(aItem) > 0

		aCab := {	{"CT2_DATA",	dDataBase,	NIL},;
						{"CT2_LOTE",	"000001",	NIL},;
						{"CT2_SBLOTE",	"001",		NIL},;
						{"CT2_DOC",		cDoc,			NIL}}
				 
		MsExecAuto({|x,y,z| CTBA102(x,y,z)}, aCab, aItem, 3)
	
		if lMsErroAuto
//			if Aviso("Pergunta","Os lancamentos de contas interfiliais nao foram gerados. Deseja visualizar o log?",{"Sim","Nao"},1,"Atencao")=1
				MostraErro()
//			endif
		else
			cDoc	:= Soma1(cDoc)
		endif
	
	endif
	
enddo

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		B_CT220REL                                                    /@
@date				15/07/2019                                                    /@
@type				Static Function                                               /@
@description	Cria lançamentos contábeis na conta 4210102021 e centro de 
					custo 1124 e 1126, de acordo com os valores encontrados nas 
					contas de 4210201001 à 4210201100 e centros de custo 1124 e 
					1126. Utilizar o mesmo histórico do lançamento origem e com 
					data do último dia do período contábil.                       /@
@author			Adalberto Moreno Batista (Opção Um)                           /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function B_CT220REL()
Local aCab, aItem, nLinha, cConta, cCCusto, nValor, cHistor
Local cDoc		:= "000001"		//GetDocNum()
Local nMaxLin	:= GetMV("MV_NUMLIN")
Local cQuery 	:= "SELECT CT2_DATA DTLANC, CT2_DEBITO, CT2_CREDIT, CT2_CCD, CT2_CCC, CT2_VALOR, CT2_HIST " +;
						"FROM " + RetSQLName("CT2") + " CT2 " +;
						"WHERE CT2_FILIAL='" + xFilial("CT2") + "' " +;
							"AND CT2_DATA BETWEEN '" + dTOs(mv_par02) + "' AND '" + dTOs(mv_par03) + "' " +;
							"AND CT2_MOEDLC='01' " +;
							"AND CT2_DC IN ('1','2','3') " +;
							"AND CT2_VALOR > 0 " +;
							"AND ((CT2_DEBITO BETWEEN '4210201001' AND '4210201100' AND CT2_CCD IN ('1124','1126')) " +;
							"OR (CT2_CREDIT BETWEEN '4210201001' AND '4210201100' AND CT2_CCC IN ('1124','1126'))) " +;
							"AND D_E_L_E_T_='' " +;
						"ORDER BY DTLANC, CT2_DEBITO, CT2_CCD, CT2_CREDIT, CT2_CCC"

dDataBase	:= mv_par03

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQRY(,,cQuery), "TEMP", .F., .T.)
TcSetField("TEMP", "DTLANC", "D")

//———————————————————————————————————————————————————————————————————————————————
// Processa registros e cria lancamentos de estorno
//———————————————————————————————————————————————————————————————————————————————
dbSelectArea("CT2")

do while TEMP->(!eof())
                          
	aItem			:= {}
	nLinha		:= 1
	
	do while TEMP->(!eof() .and. nLinha <= nMaxLin)

		if nLinha + 2 <= nMaxLin 
			//———————————————————————————————————————————————————————————————————————————————
			// Anulando registros Débito
			//———————————————————————————————————————————————————————————————————————————————
			if TEMP->CT2_DEBITO >= "4210201001" .and. TEMP->CT2_DEBITO <= "4210201100"
				aAdd(aItem, {	{"CT2_DC",		"3",								NIL},;
									{"CT2_LINHA",	StrZero(nLinha++,3),			NIL},;
									{"CT2_DEBITO",	"4210102021",					NIL},;
									{"CT2_CREDIT",	TEMP->CT2_DEBITO,				NIL},;
									{"CT2_CCD",		TEMP->CT2_CCD,					NIL},;
									{"CT2_CCC",		TEMP->CT2_CCD,					NIL},;
									{"CT2_VALOR",	TEMP->CT2_VALOR, 				NIL},;
									{"CT2_MOEDLC",	"01",								NIL},;
									{"CT2_TPSALD",	"1",								NIL},;
									{"CT2_HIST",	TEMP->CT2_HIST,				NIL}})
		   endif
	
			//———————————————————————————————————————————————————————————————————————————————
			// Anulando registros Crédito
			//———————————————————————————————————————————————————————————————————————————————
			if TEMP->CT2_CREDIT >= "4210201001" .and. TEMP->CT2_CREDIT <= "4210201100"
				aAdd(aItem, {	{"CT2_DC",		"3",								NIL},;
									{"CT2_LINHA",	StrZero(nLinha++,3),			NIL},;
									{"CT2_DEBITO",	TEMP->CT2_CREDIT,				NIL},;
									{"CT2_CREDIT",	"4210102021",					NIL},;
									{"CT2_CCD",		TEMP->CT2_CCC,					NIL},;
									{"CT2_CCC",		TEMP->CT2_CCC,					NIL},;
									{"CT2_VALOR",	TEMP->CT2_VALOR, 				NIL},;
									{"CT2_MOEDLC",	"01",								NIL},;
									{"CT2_TPSALD",	"1",								NIL},;
									{"CT2_HIST",	TEMP->CT2_HIST,				NIL}})
		   endif
		   
		endif
	
		TEMP->(dbSkip())
	
	enddo

	//———————————————————————————————————————————————————————————————————————————————
	// Verificando se há itens a serem gravados
	//———————————————————————————————————————————————————————————————————————————————
	if Len(aItem) > 0

		aCab := {	{"CT2_DATA",	dDataBase,	NIL},;
						{"CT2_LOTE",	"000001",	NIL},;
						{"CT2_SBLOTE",	"001",		NIL},;
						{"CT2_DOC",		cDoc,			NIL}}
				 
		MsExecAuto({|x,y,z| CTBA102(x,y,z)}, aCab, aItem, 3)
	
		if lMsErroAuto
			MostraErro()
			//GravaLog(cProcess, cKey, cProblemInd, cText, cFileErr)
		else
			cDoc	:= Soma1(cDoc)
		endif
	
	endif

enddo

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

Return()
