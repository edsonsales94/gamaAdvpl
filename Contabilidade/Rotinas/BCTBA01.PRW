#include "rwmake.ch"
#include "protheus.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		BCTBA01                                                       /@
@type				User function                                                 /@
@date				26/08/2011                                                    /@
@description	Fun鈬o para contabilizar movimentos VPC de creditos e debitos
					de forma aglutinada ou nao, por periodo de data               /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
Fun鈬o DETPROVA
Rotina de contabilizacao das linhas detalhes da tabela de Contra-Prova
Atualiza a tabela de contraprova com os dados gerados a partir das regras de 
contabilizacao.

Parametros	ExpN1: Handle do arquivo de Contra-Prova
				ExpC2: Codigo do lancamento padrao      
				ExpC3: Nome da rotina de origem         
				ExpC4: Numero do lote de contabilizacao 
				ExpN5:                                  
				ExpL6:                                  
				ExpC7:                                  
				ExpL8: Indica contabilizacao do rateio do ctas a pagar  (OPC)
				ExpC9: Otimizacao da chave de busca do relacionamento   (OPC)
				       Se informada evita a pesquisa da chave de integracao  
				       entre as tabelas contabilizadas e a tabela de contabilizacao
				ExpAA: Otimizacao dos lancamentos padronizados.         (OPC)
				       Array conteudo os dados da tabela de regras de contabilizacao
				       na seguinte estrutura:                        
				       [x][y][z]                                            
				       [x] Array com os codigos de lancamento padronizados  
				       [y] Array com as linhas detalhes da tabela de regras 
				           de contabilizacao                                
				       [z][1] Nome do campo da tabela de regras de contabilizacao 
				              (CT5).
				       [z][2] Conteudo do campo da tabela de regras de contabilizacao
				              (CT5).
				
Retorno		ExpN1: Valor contabilizado

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
Fun鈬o CA100INCL
Programa de inclus縊 de Lan軋mentos Cont畸eis.
Sintaxe		ExpL1 := cA100Incl(ExpC1, ExpN1, ExpN2, ExpC2, ExpL1, ExpL2)
Parametros	ExpC1 = Nome do arquivo
				ExpN1 = Numero do Header
				ExpN2 = Numero da Opcao escolhida
				ExpC2 = Numero do Lote
				ExpL1 = Se Mostra ou nao
				ExpL2 = Se Aglutina ou nao
				ExpC3 = Determina se sera On Line ou pelo cProva
				dData = Data para geracao dos lancamentos contabeis
				dReproc = Parametro que indica que lancamentos nao atualiza
				          saldos e apos gravacao executa reprocessamento   
				aFlagCTB    = Array com dados do Flag CTB                  
				aDadosProva = Array com dados para utilizacao multi-thread 

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
Tipos de movimentos VPC (SZK) - ZK_TPCHV
1 - CR - Venda, considerar a exclusao do registro pelo cancelamento da nota
2 - DB - Pedido de bonificacao VPC, considerar a exclusao do registro pelo 
         cancelamento do pedido bonificado
2 - CR - Eliminacao de residuo de pedido de bonificacao VPC
3 - DB - NCC, considerar a exclusao do titulo NCC
4 - DB - Devolucao de venda, considerar a exclusao da nota de devolucao de venda
4 - CR - Devolucao de produtos bonificados, considerar a exclusao de produtos 
         bonificados
6 - DB - Cta pagar, considerar a exclusao do titulo Cta Pagar
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/

User Function BCTBA01()
Local aRegs			:= {}
Local cPerg			:= PadR("BCTBA01", Len(SX1->X1_GRUPO))
Local aCabSX1		:= {"X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_GSC", "X1_VAR01", "X1_DEF01", "X1_DEF02"}
Local aHlp01		:= {"Data inicial do per?odo desejado", "do processamento"}
Local aHlp02		:= {"Data final do per?odo desejado", "do processamento"}
Local aHlp03		:= {"Informe se deseja visualizar a", "contabiliza鈬o"}
Local aHlp04		:= {"Informe se os lan軋mentos ser縊", "aglutinados ou n縊"}
Local aButton		:= {}
Local aSay			:= {}
Local nOpc			:= 0
Local cCadastro		:= "Contabiliza鈬o dos movimentos VPC"
Local aArea			:= GetArea()

if cEmpAnt == "01" .and. cFilAnt == "03"

	aAdd(aRegs, {cPerg, "01", "Data inicial?", 			"mv_ch1", "D", 08, 0, "G",	"mv_par01", "", ""})
	aAdd(aRegs, {cPerg, "02", "Data final?", 				"mv_ch2", "D", 08, 0, "G",	"mv_par02", "", ""})
	aAdd(aRegs, {cPerg, "03", "Visualiza contabil.?", 	"mv_ch3", "N", 01, 0, "C",	"mv_par03", "Sim", "N縊"})
	aAdd(aRegs, {cPerg, "04", "Aglutina lan軋mentos?", "mv_ch4", "N", 01, 0, "C",	"mv_par04", "Sim", "N縊"})
	
	U_BRASX1(aRegs, aCabSX1)
	
	PutSX1Help("P." + AllTrim(cPerg) + "01.", aHlp01, aHlp01, aHlp01)
	PutSX1Help("P." + AllTrim(cPerg) + "02.", aHlp02, aHlp02, aHlp02) 
	PutSX1Help("P." + AllTrim(cPerg) + "03.", aHlp03, aHlp03, aHlp03) 
	PutSX1Help("P." + AllTrim(cPerg) + "04.", aHlp04, aHlp04, aHlp04) 
	
	Pergunte(cPerg, .F.)
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Criacao da Interface 
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	aAdd(aSay, "Rotina espec?fica da Brasitech, para contabiliza鈬o off-line dos movimentos de")
	aAdd(aSay, "d饕itos e cr馘itos VPC")
	aAdd(aSay, "ATENﾇﾃO:")
	aAdd(aSay, "Antes de iniciar, certifique-se de que os par穃etros foram respondidos")
	aAdd(aSay, "corretamente.")
	
	aAdd(aButton, {1, .T., {|| nOpc := 1, FechaBatch()	}})
	aAdd(aButton, {2, .T., {|| FechaBatch()				}})
	aAdd(aButton, {5, .T., {|| Pergunte(cPerg, .T.)		}})
	
	FormBatch(cCadastro, aSay, aButton)
	
	if nOpc == 1
	
		Pergunte(cPerg, .F.)
	
		if empty(mv_par01) .or. empty(mv_par02)
			Help(" ", 1, "ATENﾇﾃO",, "ﾉ necess疵io preencher o per?odo para o processamento. O PROCESSO NﾃO SERﾁ INICIADO." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec?fico Brasitech)", 1)
			return()
		endif
	
		Processa({ |lEnd| ProcVPC() }, "Contabiliza鈬o de movimentos VPC", "Contabilizandos os movimentos...", .T.)
	
	endif   

else

	Help(" ", 1, "ATENﾇﾃO",, "Rotina v疝ida somente para a empresa Brasitech e filial S縊 Paulo(03)." + chr(13) + chr(10) + "(Espec?fico Brasitech)", 1)
	
endif

Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		ProcVPC                                                       /@
@type				Static function                                               /@
@date				26/08/2011                                                    /@
@description	Fun鈬o para contabilizar movimentos VPC de creditos e debitos
					de forma aglutinada ou nao, por periodo de data               /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function ProcVPC()
Local cQuery, dDtmov, cTpChv, cTipo, nValorCtb, nTotalCtb
Local cLP		 	:= "401"
Local cLote		 	:= "VPC001"
Local cArqCtb	 	:= ""
Local nHdlPrv	 	:= 0
Local lVisual	 	:= (mv_par03 == 1)
Local lAglutina 	:= (mv_par04 == 1)
Local dDtBasBKP	:= dDataBase

if !VerPadrao(cLP)
	Return()
endif

ProcRegua(RecCount())

if Select("TRB") > 0
	TRB->(dbCloseArea())
endif

cQuery :=	"SELECT *, R_E_C_N_O_ REGISTRO FROM " + RetSqlName("SZK") + " SZK " +;
				"WHERE D_E_L_E_T_ = ' ' " +;
						"AND ZK_FILIAL = '" + xFilial("SZK") + "' " +;
						"AND ZK_DATA BETWEEN '" + dTOs(mv_par01) + "' AND '" + dTOs(mv_par02) + "' " +;
						"AND ZK_DTCTB = '' " +;
				"ORDER BY ZK_DATA, ZK_TPCHV, ZK_TIPO"
				
dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRB", .F., .T.)
TcSetField("TRB", "ZK_DATA", "D")

dbSelectArea("TRB")
TRB->(dbGoTop())
if TRB->(!eof())

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Inicializa o arquivo de contabilizacao 
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	nHdlPrv := HeadProva(cLote, "BCTBA01", Substr(cUsuario,7,6), @cArqCtb)
	if nHdlPrv <= 0
	
		Help(" ",1,"SEM_LANC")
		
	else
	
		do while TRB->(!eof())
		
			dDtMov 		:= TRB->ZK_DATA
			dDataBase	:= dDtMov
			
			do while TRB->(!eof() .and. ZK_DATA == dDtMov)

				cTpChv		:= TRB->ZK_TPCHV
				cTipo			:= TRB->ZK_TIPO
				nTotalCtb	:= 0
				nHdlPrv 		:= HeadProva(cLote, "BCTBA01", substr(cUsuario,7,6), @cArqCtb)

				if nHdlPrv > 0
				
					Begin Transaction
				
						do while TRB->(!eof() .and. ZK_DATA == dDtMov .and. ZK_TPCHV == cTpChv .and. ZK_TIPO == cTipo)
				
							SZK->(dbGoTo(TRB->REGISTRO))

							//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
							// Grava鈬o de custo de bonifica鈬o e custo de devolu鈬o 
							//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
							if SZK->ZK_TPCHV == "2" .and. SZK->(FieldPos("ZK_CUSBONI")) > 0 .and. SZK->(FieldPos("ZK_CUSDEV")) > 0
								SZK->(RecLock("SZK", .F.))
								SZK->ZK_CUSBONI	:= U_VPCCUSBONI(SZK->ZK_TIPO == "CR")
								SZK->ZK_CUSDEV		:= U_VPCCUSDEV()
								SZK->(MsUnlock())
							endif
							
							//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
							// Grava contabiliza鈬o
							//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
							nValorCtb 	:= DetProva(nHdlPrv, cLP, "BCTBA01", cLote)

							//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
							// Atualiza data de contabiliza鈬o 
							//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
//							if nValorCtb > 0
								nTotalCtb 	+= nValorCtb
								SZK->(RecLock("SZK", .F.))
								SZK->ZK_DTCTB := dDataBase
								SZK->(MsUnlock())
//							endif							
						
							TRB->(dbSkip())
							
						enddo
					
 				   End Transaction
 				   
					if nTotalCtb > 0
					
						RodaProva(nHdlPrv,nTotalCtb)
						cA100Incl(cArqCtb, nHdlPrv, 1, cLote, lVisual, lAglutina)
						
					endif
				
				else
	
					Help(" ",1,"SEM_LANC")
					exit

				endif

			enddo

		enddo
		
		dDataBase := dDtBasBKP
			
	endif
	
endif
Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		VPCCC                                                         /@
@type				User Function                                                 /@
@date				22/10/2015                                                    /@
@description	Busca o centro de custo do respectivo cliente ou grupo de 
					cliente de acordo com a estrutura comercial.                  /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Clientes Op鈬o Um Consultoria                                 /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function VPCCC()
Local aArea		:= GetArea()
Local cRet		:= ""
Local cCliente	:= SZK->ZK_CLIENTE
Local cLoja		:= SZK->ZK_LOJA
Local cQuery

cQuery	:= "SELECT DISTINCT(ZB_CCUSTO) ZB_CCUSTO "
cQuery	+= "FROM " + RetSQLName("SA1") + " SA1, " + RetSQLName("SA3") + " SA3, " + RetSQLName("SZB") + " SZB "
cQuery	+= "WHERE SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
cQuery	+= 		"AND SA1.A1_COD = '" + cCliente + "' "
if !empty(cLoja)
	cQuery	+= 	"AND SA1.A1_LOJA = '" + cLoja + "' "
else
	cQuery	+= 	"AND SA1.A1_MSBLQL != '1' "
endif
cQuery	+= 		"AND SA1.D_E_L_E_T_ = '' "
cQuery	+= 		"AND SA3.A3_FILIAL = '" + xFilial("SA3") + "' "
cQuery	+= 		"AND SA3.A3_COD = SA1.A1_VEND "
cQuery	+= 		"AND SA3.D_E_L_E_T_ = '' "
cQuery	+= 		"AND SZB.ZB_FILIAL = '" + xFilial("SZB") + "' "
cQuery	+= 		"AND SZB.ZB_COD = SA3.A3_XCANAL "
cQuery	+= 		"AND SZB.D_E_L_E_T_ = '' "
cQuery	+= "GROUP BY ZB_CCUSTO "
cQuery	+= "ORDER BY ZB_CCUSTO DESC"

if Select("VPCCC") > 0
	VPCCC->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "VPCCC", .F., .T.)

dbSelectArea("VPCCC")
dbGoTop()
if VPCCC->(!eof())
	cRet := VPCCC->ZB_CCUSTO
endif

if Select("VPCCC") > 0
	VPCCC->(dbCloseArea())
endif
 
RestArea(aArea)
Return(cRet)


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		VPCCUSBONI                                                    /@
@type				User Function                                                 /@
@date				26/10/2015                                                    /@
@description	Busca custo dos produtos de um respectivo pedido bonificado
					para a contabiliza鈬o dos tipos ZK_TIPO='2'.                  /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Clientes Op鈬o Um Consultoria                                 /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function VPCCUSBONI(lEstorno)
Local nRet		:= 0
Local aArea		:= GetArea()
Local cVPCFil	:= Substr(SZK->ZK_CHAVE, 1, 2)
Local cVPCPed	:= Substr(SZK->ZK_CHAVE, 3, 6)
Local cQuery
Default lEstorno := .F.

cQuery	:= "SELECT B9_FILIAL, B9_COD, case SUM(B9_QINI) WHEN 0 THEN 0 ELSE (ROUND(SUM(B9_VINI1)/SUM(B9_QINI),2) * (C6_QTDVEN - " + iif(lEstorno, "C6_QTDENT", "0") + ")) END AS CUSTOTOTAL " +;
				"FROM " + RetSQLName("SB9") + " SB9, " +;
							 RetSQLName("SC6") + " SC6, " +;
							 RetSQLName("SF4") + " SF4 " +;
				"WHERE SB9.B9_FILIAL = '" + cVPCFil + "' " +;
						"AND SB9.D_E_L_E_T_ = '' " +;
						"AND SB9.B9_COD = SC6.C6_PRODUTO " +;
						"AND B9_DATA = (SELECT MAX(B9_DATA) " +;
											"FROM " + RetSQLName("SB9") + " SB9 " +;
											"WHERE B9_FILIAL='" + cVPCFil + "' " +;
													"AND SB9.B9_COD = SC6.C6_PRODUTO " +;
													"AND SB9.D_E_L_E_T_ = '') " +;
						"AND SC6.C6_FILIAL = '" + cVPCFil + "' " +;
						"AND SC6.C6_NUM = '" + cVPCPed + "' " +;
						"AND SC6.C6_PRODUTO = SB9.B9_COD " +;
						"AND SC6.D_E_L_E_T_ = '' " +;
						"AND SF4.F4_FILIAL = '" + xFilial("SF4") + "' " +;
						"AND SF4.F4_CODIGO = SC6.C6_TES " +;
						"AND SF4.F4_DUPLIC = 'N' " +;
						"AND SF4.D_E_L_E_T_ = '' " +;
						"GROUP BY SB9.B9_FILIAL, SB9.B9_COD, SC6.C6_QTDVEN " + iif(lEstorno, ", SC6.C6_QTDENT", "")

if Select("CUSBONI") > 0
	CUSBONI->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "CUSBONI", .F., .T.)

dbSelectArea("CUSBONI")
dbGoTop()
do while CUSBONI->(!eof())
	nRet += CUSBONI->CUSTOTOTAL
	CUSBONI->(dbSkip())
enddo

if Select("CUSBONI") > 0
	CUSBONI->(dbCloseArea())
endif

RestArea(aArea)
Return(nRet)


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		VPCCUSDEV                                                     /@
@type				User Function                                                 /@
@date				26/10/2015                                                    /@
@description	Busca custo dos produtos de um respectivo pedido bonificado
					para a contabiliza鈬o dos tipos ZK_TIPO='2'.                  /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Clientes Op鈬o Um Consultoria                                 /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function VPCCUSDEV()
Local nRet		:= 0
Local aArea		:= GetArea()
Local cVPCFil	:= Substr(SZK->ZK_CHAVE, 1, 2)
Local cVPCDoc	:= Substr(SZK->ZK_CHAVE, 3, 9)
Local cVPCSer	:= Substr(SZK->ZK_CHAVE, 12, 3)
Local cVPCCli	:= Substr(SZK->ZK_CHAVE, 15, 8)
Local cVPCLoj	:= Substr(SZK->ZK_CHAVE, 23, 2)
Local cQuery

cQuery	:= "SELECT SUM(D1_CUSTO) CUSTODEV " +;
				"FROM " + RetSQLName("SD1") + " SD1 " +;
				"WHERE SD1.D1_FILIAL = '" + cVPCFil + "' " +;
						"AND SD1.D1_DOC = '" + cVPCDoc + "' " +;
						"AND SD1.D1_SERIE = '" + cVPCSer + "' " +;
						"AND SD1.D1_FORNECE = '" + cVPCCli + "' " +;
						"AND SD1.D1_LOJA = '" + cVPCLoj + "' " +;
						"AND SD1.D_E_L_E_T_ = ''"

if Select("CUSDEV") > 0
	CUSBONI->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "CUSDEV", .F., .T.)

dbSelectArea("CUSDEV")
dbGoTop()
if CUSDEV->(!eof())
	nRet += CUSDEV->CUSTODEV
endif

if Select("CUSDEV") > 0
	CUSDEV->(dbCloseArea())
endif

RestArea(aArea)
Return(nRet)
