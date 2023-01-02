#include "protheus.ch"
#include "ap5mail.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRAJOB01                                                     /@
@type			User function                                                /@
@date			19/03/2012                                                   /@
@description	Rotina para uso em schedule. Job para transformar orçamentos
				de vendas (SZL) em pedidos de vendas (SC5)                   /@
@author			Adalberto Moreno Batista - Opção Um Tecnologia               /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
15/10/19
- Criação de controle de semaforo para impedir sobreposição na execução da rotina
24/10/19
- Ajuste no indice SZL (3) DE ZL_NUM + ZL_ITEM para ZL_NUM + ZL_FILIAL + ZL_CBRFR + ZL_ITEM e
  consideração dos seeks e whiles para correção de consideração de cobrança ou não
  de frete.
14/11/19
- Reformulação do conceito de processamento dos pré pedidos web, agora realizado por
  pré pedido e não mais por filial
  Uso da tabela ZZ9 para armazenar log de processamento. Ao final do processamento,
  Exclusão dos dados do log.
23/03/20
- Implementação da reconfirmação da verificação se o pedido web já foi gravado. Ajuste no 
índice com nickname PEDWEB para: ZL_FILIAL + ZL_X_NUMZL + ZL_X_ITEZL
/*/
User Function BRAJOB01()
Local cSemaforo		:= "\system\pedidosweb.run"
Local aPedidosWeb, nK
Private cProcessKey	:= dTOs(Date()) + StrTran(Time(), ":", "")

//———————————————————————————————————————————————————————————————————————————————
// Controle para impedir sobreposição na execução da rotina
//———————————————————————————————————————————————————————————————————————————————
if !File(cSemaforo)

	MemoWrite(cSemaforo , "Execução iniciada em " + dTOc(Date()) + " as " + Time())

	//———————————————————————————————————————————————————————————————————————————————
	// Identifica os pedidos web aptos a serem importados
	// Status do orçamento de vendas web ZL_GRVPED.
	// ' '-Pendente de integração com o pedido de venda
	// 'A'-Pedido alterado na WEB. Pendente de nova integração com o pedido de venda.
	// '-'-Em processamento pela rotina de schedule de pedidos.
	// 'E'-Identifica erro na tentativa de integração com o pedido de vendas.
	// 'S'-Informa que o pré-pedido foi integrado com o pedido de vendas.
	// 'N'-Informa que o pedido de venda foi excluído.
	// 'F'-Informa que o orçamento foi totalmente faturado.
	// 'P'-Indica que o orçamento foi parcialmente faturado.
	// 'R'-Informa que houve eliminação de resíduos no pedido de vendas.
	//———————————————————————————————————————————————————————————————————————————————
	aPedidosWeb := A_BRAJOB01()

	//———————————————————————————————————————————————————————————————————————————————
	// Importa os pedidos web
	//———————————————————————————————————————————————————————————————————————————————
	For nK := 1 to Len(aPedidosWeb)
		B_BRAJOB01(aPedidosWeb[nK])
	Next

	fErase(cSemaforo)

	//———————————————————————————————————————————————————————————————————————————————
	// Envio log de eventos
	//———————————————————————————————————————————————————————————————————————————————
	C_BRAJOB01()

	ConOut(dTOc(Date()) + " as " + Time() + " - BRAJOB01 - Conclusao do processo de geracao de pedidos de venda a partir de registros WEB")

else

	ConOut(dTOc(Date()) + " as " + Time() + " - BRAJOB01 - Execução não iniciada por controle de semáforo. (arquivo " + cSemaforo + ")")	
	
endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		A_BRAJOB01                                                   /@
@type			Static function                                              /@
@date			14/11/2019                                                   /@
@description	Função chamada pela user function BRAJOB01. Lê e retorna os 
				números de pré pedidos web (SZL) aptos a serem transformados
				em pedidos de vendas.                                        /@
@author			Adalberto Moreno Batista - Opção Um Tecnologia               /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function A_BRAJOB01()
Local aPedidosWeb := {}
Local cQuery

//———————————————————————————————————————————————————————————————————————————————
// Abertura de ambiente
//———————————————————————————————————————————————————————————————————————————————
WfPrepEnv("01", "01", "U_BRAJOB01_Begin",, "FAT")

//————————————————————————————————————————————————————————————————————————————
// Definição da query de pesquisa e abertura da view temporária
//————————————————————————————————————————————————————————————————————————————
cQuery	:= "SELECT ZL_NUM, ZL_FILIAL FROM " + RetSqlName("SZL") + " SZL " +;
			"WHERE ZL_GRVPED IN (' ','A') AND ZL_OPER != '' AND D_E_L_E_T_= ' ' " +;
			"GROUP BY ZL_NUM, ZL_FILIAL " +;
			"ORDER BY ZL_NUM, ZL_FILIAL "

if Select("TSZL") > 0
	TSZL->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),"TSZL", .F., .T.)

//————————————————————————————————————————————————————————————————————————————
// Alimentação do array com os números dos pré-pedidos
//————————————————————————————————————————————————————————————————————————————
TSZL->(dbGoTop())
do while TSZL->(!eof())
	aAdd(aPedidosWeb, {TSZL->ZL_FILIAL, TSZL->ZL_NUM})
	TSZL->(dbSkip())
enddo

if Select("TSZL") > 0
	TSZL->(dbCloseArea())
endif

//———————————————————————————————————————————————————————————————————————————————
// Fechamento do ambiente
//———————————————————————————————————————————————————————————————————————————————
RpcClearEnv()

Return(aPedidosWeb)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		B_BRAJOB01                                                   /@
@type			Static function                                              /@
@date			26/03/2012                                                   /@
@description	Função chamada pela user function BRAJOB01. Seleciona os 
				orçamentos web (SZL) que deverão ser importados para pedido 
				de vendas                                                    /@
@author			Adalberto Moreno Batista - Opção Um Tecnologia               /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function B_BRAJOB01(aPrePed)
Local aFiles	:= {"SA1", "SA4", "SB1", "SB2", "SC5", "SC6", "SF4", "SZI", "SZJ", "SZL", "SZP"}
Local aCabPed, aItePed, aLinAux, cItem, cTransp, cArmazem, lVPCitem, nUsoVPC, nVlrIPI,;
		lLoja, cCliente, cLoja, lContinua, cContrato, cHistorico, cTES, nVlrIt, nBase,;
		nSumIPI, nVPCAvulso, nFatDesc, nTotItem, lIPI, cMsgErro, lGrvVPC, nK, nX,;
		nUsoVPCFil, cCobrFrete, cQuery, lReconfirm

//————————————————————————————————————————————————————————————————————————————
// Abertura ambiente 
//————————————————————————————————————————————————————————————————————————————
WfPrepEnv("01", aPrePed[1], "U_BRAJOB01",, "FAT")

for nK := 1 to Len(aFiles)
	if Empty(Select(aFiles[nK]))
		ChkFile(aFiles[nK])
	endif
next

//————————————————————————————————————————————————————————————————————————————
// Ordenando as tabelas
//————————————————————————————————————————————————————————————————————————————
SA1->(dbSetOrder(1))	//A1_FILIAL+A1_COD+A1_LOJA
SA4->(dbSetOrder(1))	//A4_FILIAL+A4_COD
SB1->(dbSetOrder(1))	//B1_FILIAL+B1_COD
SB2->(dbSetOrder(1))	//B2_FILIAL+B2_COD+B2_LOCAL
SC5->(dbSetOrder(1))	//C5_FILIAL+C5_NUM
SC6->(dbSetOrder(1))	//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
SF4->(dbSetOrder(1))	//F4_FILIAL+F4_CODIGO
SZI->(dbSetOrder(1))	//ZI_FILIAL+ZI_COD+ZI_DESCR
SZJ->(dbSetOrder(1))	//ZJ_FILIAL+ZJ_CONTRAT+ZJ_CLIENTE+ZJ_LOJA
SZL->(dbSetOrder(3))	//ZL_NUM+ZL_FILIAL+ZL_CBRFR+ZL_ITEM
SZP->(dbSetOrder(1))	//ZP_FILIAL+ZP_CONTRAT+ZP_TPVPC

//————————————————————————————————————————————————————————————————————————————
// Altera status do pré pedido para "em processamento"
//————————————————————————————————————————————————————————————————————————————
TcSQLExec("UPDATE " + RetSqlName("SZL") + " SET ZL_GRVPED = '-' WHERE ZL_FILIAL = '" + aPrePed[1] + "' AND D_E_L_E_T_= ' ' AND ZL_NUM = '" + aPrePed[2] + "' AND ZL_OPER != ''")

cQuery	:= "SELECT * " +;
				"FROM " + RetSqlName("SZL") + " SZL " +;
				"WHERE ZL_FILIAL = '" + aPrePed[1] + "' AND ZL_NUM = '" + aPrePed[2] + "' AND ZL_OPER != ' ' AND ZL_GRVPED = '-' AND D_E_L_E_T_= ' ' " +;
				"ORDER BY ZL_CBRFR+ZL_ITEM "

if Select("TSZL") > 0
	TSZL->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),"TSZL", .F., .T.)

//————————————————————————————————————————————————————————————————————————————
// Inicia o processamento das informações
//————————————————————————————————————————————————————————————————————————————
do while TSZL->(!Eof())

	aCabPed		:= {}
	aItePed		:= {}
	cItem		:= "01"
	lVPCitem 	:= .F.	//indica que há itens bonificados no pré-pedido
	lGrvVPC		:= .F.	//indica que uma movimentação de bonificação será gravada nos movimentos VPC
	lContinua	:= .T.
	nUsoVPC		:= 0	//Uso VPC total
	nUsoVPCFil	:= 0	//Uso VPC somente na filial
	nBase		:= 0
	nSumIPI		:= 0
	cMsgErro	:= ""
	cCobrFrete	:= TSZL->ZL_CBRFR

	do while TSZL->(!eof() .and. ZL_CBRFR == cCobrFrete)

		if SA1->(dbSeek(xFilial("SA1") + TSZL->ZL_CLIENTE + TSZL->ZL_LOJA))

			cTransp 	:= U_FindTraUF(SA1->A1_COD, SA1->A1_LOJA, SA1->A1_COD_MUN, SA1->A1_EST)

			//————————————————————————————————————————————————————————————————————————————
			// Verifico se a transportadora foi encontrada na tabela SZD
			//————————————————————————————————————————————————————————————————————————————
			if !Empty(cTransp)
			
				cCliente 	:= TSZL->ZL_CLIENTE
				cLoja	 	:= TSZL->ZL_LOJA
				cContrato	:= U_VPCFindCt_FT03(cCliente, cLoja)
				nVPCAvulso	:= TSZL->ZL_VPCPAV
				cArmazem 	:= iif(cFilAnt == "01", "61",iif(cFilAnt == "03", "63", "30"))
				lIPI			:= .T.
	
				if SZJ->(dbSeek(xFilial("SZJ") + cContrato))
					lIPI 	:= (SZJ->ZJ_IPI == "S")
				endif
	
				//————————————————————————————————————————————————————————————————————————————
				// Busco TES a partir do TES inteligente e posiciono o produto referente à
				// filial do pré-pedido. NAO ALTERAR ESTE BLOCO DE CÓDIGO.
				// Ver instruções nos comentários de cada uma das linhas codificadas.
				//————————————————————————————————————————————————————————————————————————————
	//				aArea		:= GetArea()														//Salvo a área antes de entrada na CallTES
	//				cFilBkp		:= cFilAnt															//Guardo a filial do processamento em uma variavel de apoio
	//				cFilAnt		:= TSZL->ZL_FILIAL													//Configuro a variavel cFilAnt com o conteudo do campo ZL_FILIAL
				cTES		:= U_CallTes(2, TSZL->ZL_OPER, cCliente, cLoja, "C", TSZL->ZL_PRODUTO)	//Entro na função CallTES com a configuração de filial ZL_FILIAL
	//				RestArea(aArea)																 	//Restauro a área vigente antes da CallTES
	//				cFilAnt		:= cFilBkp															//Restauro a variavel de sistema cFilAnt com o conteudo da variavel de apoio
				SB1->(dbSeek(xFilial("SB1") + TSZL->ZL_PRODUTO))									//Posicionar o cadastro de produtos da mesma filial do pré-pedido
				SF4->(dbSeek(xFilial("SF4") + cTES))												//Posicionar o TES da mesma filial do pré-pedido
	
	
				//————————————————————————————————————————————————————————————————————————————
				// Verifico se foi encontrado um TES no TES inteligente
				//————————————————————————————————————————————————————————————————————————————
				if Empty(cTES)
				
					lContinua 	:= .F.
					cMsgErro		:= "Sem regra TES inteligente: produto '" + AllTrim(TSZL->ZL_PRODUTO) + "', operacao '" + TSZL->ZL_OPER + "' e filial '" + TSZL->ZL_FILIAL + "'"
					Exit
					
				else
				
					nFatDesc	:= 1 - ((TSZL->ZL_DESC + TSZL->ZL_DESC2) / 100)		//Fator de desconto
					nTotItem	:= Round(TSZL->ZL_QTDE * TSZL->ZL_VUNIT * nFatDesc, 2)
					nVlrIPI 	:= iif(SF4->F4_IPI == "S" .and. lIPI, Round(nTotItem * (SB1->B1_IPI / 100), 2), 0)
					nVlrIt 	:= nTotItem
					
					//————————————————————————————————————————————————————————————————————————————
					// Somo valor para uso VPC ou da base de calculo dos créditos VPC para o 
					// respectivo pedido
					//————————————————————————————————————————————————————————————————————————————
					if TSZL->ZL_VPCIT == "S"
						lVPCitem 	:= .T.
						if SF4->F4_DUPLIC == "N"
							nUsoVPC 	+= nVlrIt + nVlrIPI
							if TSZL->ZL_FILIAL == cFilAnt
								nUsoVPCFil	+= nVlrIt + nVlrIPI
							endif
						endif
					else
						if SF4->F4_DUPLIC == "S"
							nBase		+= nVlrIt
							nSumIPI	+= nVlrIPI
						endif
					endif
	
					//————————————————————————————————————————————————————————————————————————————
					// Adiciono o item no array do cabecalho pedido de vendas
					//————————————————————————————————————————————————————————————————————————————
					if Len(aCabPed) == 0
					
						aCabPed	:= {	{"C5_TIPO",		"N",							NIL},;
										{"C5_CLIENTE",	TSZL->ZL_CLIENTE,				NIL},;
										{"C5_LOJACLI",	TSZL->ZL_LOJA,					NIL},;
										{"C5_CLIENT",	TSZL->ZL_CLIENTE,				NIL},;
										{"C5_LOJAENT",	TSZL->ZL_LOJA,					NIL},;
										{"C5_EMISSAO",	Date(),							NIL},;
										{"C5_CONDPAG",	TSZL->ZL_CONDPAG,				NIL},;
										{"C5_TRANSP",	cTransp,						NIL},;
										{"C5_VOLUME1",	1,								NIL},;
										{"C5_ESPECI1",	"CAIXA",						NIL},;
										{"C5_PEDCLI",	AllTrim(TSZL->ZL_PEDCLI),		NIL},;
										{"C5_X_ORIG" ,	"2",							NIL},;
										{"C5_TPFRETE",	"C",							NIL},;
										{"C5_XOBSER1",	TSZL->ZL_OBS1,					NIL},;
										{"C5_XOBSER2",	TSZL->ZL_OBS2,					NIL},;
										{"C5_X_VPCAV",	TSZL->ZL_VPCPAV,				NIL}}
	
						//————————————————————————————————————————————————————————————————————————————
						// Verifico se haverá cobrança de frete (operações de vendas)
						//————————————————————————————————————————————————————————————————————————————
						if TSZL->ZL_CBRFR == "S" .and. TSZL->ZL_OPER $ "01#02"
							aAdd(aCabPed, {"C5_FRETE",	TSZL->ZL_FRETEPR,			NIL})
						endif
	
						//————————————————————————————————————————————————————————————————————————————
						// Se há vendedor e comissão específico, os considero
						//————————————————————————————————————————————————————————————————————————————
						if !Empty(TSZL->ZL_VEND)
							aAdd(aCabPed, {"C5_VEND1",	TSZL->ZL_VEND,		NIL})
							aAdd(aCabPed, {"C5_COMIS1",	TSZL->ZL_COMIS,		NIL})
						endif
						
					endif
	
					//————————————————————————————————————————————————————————————————————————————
					// Adiciono array dos itens do pedido de vendas
					//————————————————————————————————————————————————————————————————————————————
					aLinAux  := {	{"C6_ITEM",		cItem,							NIL},;
									{"C6_PRODUTO",	TSZL->ZL_PRODUTO,				NIL},;
									{"C6_LOCAL",	cArmazem,						NIL},;
									{"C6_QTDVEN",	TSZL->ZL_QTDE,					NIL},;
									{"C6_PRUNIT",	TSZL->ZL_VUNIT,					NIL},;
									{"C6_PRCVEN",	TSZL->ZL_VUNIT,					NIL},;
									{"C6_VALOR",	TSZL->(ZL_QTDE*ZL_VUNIT),		NIL},;
									{"C6_OPER",		TSZL->ZL_OPER,					NIL},;
									{"C6_XOPER",	TSZL->ZL_OPER,					NIL},;
									{"C6_DESCONT",	TSZL->(ZL_DESC+ZL_DESC2),		NIL},;
									{"C6_QTDLIB",	0,								NIL},;
									{"C6_X_NUMZL",	TSZL->ZL_NUM,					NIL},;
									{"C6_X_ITEZL",	TSZL->ZL_ITEM,					NIL},;
									{"C6_X_OBS",	TSZL->ZL_OBSITEM,				NIL},;
									{"C6_PEDCLI",	AllTrim(TSZL->ZL_PEDCLI),		NIL},;
									{"C6_X_VPCIT",	TSZL->ZL_VPCIT,					NIL}	}
	
					//————————————————————————————————————————————————————————————————————————————
					// Se há vendedor e comissão específico, os considero
					//————————————————————————————————————————————————————————————————————————————
					if !Empty(TSZL->ZL_VEND)
						aAdd(aLinAux, {"C6_COMIS1",	TSZL->ZL_COMIS,			NIL})
					endif
				
					aAdd(aItePed, aLinAux)
					lGrvVPC		:= iif(TSZL->ZL_VPCIT == "S", .T., lGrvVPC)
					cItem		:= Soma1(cItem)
				
				endif
	
			else
	
			  	lContinua 	:= .F.
				cMsgErro		:= "Não encontrada transportadora para o cliente " + SA1->A1_COD + "/" + SA1->A1_LOJA + ", Estado " + SA1->A1_EST + " e Filial '" + TSZL->ZL_FILIAL
				Exit
	
			endif

		else
	
		  	lContinua 	:= .F.
			cMsgErro		:= "Cliente não encontrado " + AllTrim(TSZL->ZL_CLIENTE) + "/" + TSZL->ZL_LOJA + " na filial " + TSZL->ZL_FILIAL
			Exit
	
		endif
	        
		TSZL->(dbSkip())
			
	enddo
   
	//————————————————————————————————————————————————————————————————————————————
	// Verifico se o processo continuará
	//————————————————————————————————————————————————————————————————————————————
	if lContinua .and. Len(aCabPed) > 0 .and. Len(aItePed) > 0
	
		//————————————————————————————————————————————————————————————————————————————
		// Verifico se há saldo disponivel VPC nos movimentos VPC e também para o 
		// respectivo pedido de venda
		//————————————————————————————————————————————————————————————————————————————
		if lVPCitem
			lLoja	:= (SA1->A1_X_MDVPC == "L")
		endif


		//————————————————————————————————————————————————————————————————————————————
		// Reconfirmação da análise de verificação da existência do pedido web no
		// sistema, evitando assim a duplicidade de pedidos
		//————————————————————————————————————————————————————————————————————————————
		lReconfirm := .T.
		SC6->(dbOrderNickname("PEDWEB"))
		For nX := 1 to Len(aItePed)
			if SC6->(dbSeek(xFilial("SC6") + aItePed[nX,12,2] + aItePed[nX,13,2] ))
				lReconfirm := .F.
				Exit
			endif
		Next
		SC6->(dbSetOrder(1))

		//————————————————————————————————————————————————————————————————————————————
		// Inicio o controle de transação
		//————————————————————————————————————————————————————————————————————————————
		if lReconfirm

			Begin Transaction

				lMsErroAuto := .F. 
				MsExecAuto({ |x, y, z| MATA410(x, y, z) }, aCabPed, aItePed, 3)

				if lMsErroAuto
				
					cMsgErro := "Erro na gravação de pedido de venda - Filial " + SM0->M0_CODFIL
					ConOut(cMsgErro)

					TcSQLExec("UPDATE " + RetSqlName("SZL") + " SET ZL_GRVPED = 'E' WHERE ZL_FILIAL = '" + aPrePed[1] + "' AND ZL_NUM = '" + aPrePed[2] + "' AND ZL_CBRFR = '" + cCobrFrete + "' AND D_E_L_E_T_= ' '")
					/*
					SZL->(dbSeek(aPrePed[2] + aPrePed[1] + cCobrFrete))
					do while SZL->(!eof() .and. ZL_NUM == aPrePed[2] .and. ZL_FILIAL == aPrePed[1] .and. ZL_CBRFR == cCobrFrete)
						SZL->(RecLock("SZL",.F.))
						SZL->ZL_GRVPED		:= "E"
						SZL->(MsUnlock())

						SZL->(dbSkip())
					enddo
					*/
				
					U_GravaLog("Pedidos Web", cProcessKey, aPrePed[2], cMsgErro, NomeAutoLog())

				else

					aItePed	:= {}
					ConOut("Pedido " + SC5->C5_NUM + " foi gravado com sucesso a partir do Orçamento Web nro " + aPrePed[2] + " - Filial " + SM0->M0_CODFIL)

					//————————————————————————————————————————————————————————————————————————————
					// Atualizando os registros da SZL
					//————————————————————————————————————————————————————————————————————————————
					TcSQLExec("UPDATE " + RetSqlName("SZL") + " SET ZL_GRVPED = 'S', ZL_PEDIDO = '" + SC5->C5_NUM + "' WHERE ZL_FILIAL = '" + aPrePed[1] + "' AND ZL_NUM = '" + aPrePed[2] + "' AND ZL_CBRFR = '" + cCobrFrete + "' AND D_E_L_E_T_= ' '")
					/*
					do while SZL->(!eof() .and. ZL_NUM == aPrePed[2] .and. ZL_FILIAL == aPrePed[1] .and. ZL_CBRFR == cCobrFrete)
						SZL->(RecLock("SZL",.F.))
						SZL->ZL_GRVPED	:= "S"
						SZL->ZL_PEDIDO	:= SC5->C5_NUM
						SZL->(MsUnlock())

						SZL->(dbSkip())
					enddo
					*/

					//————————————————————————————————————————————————————————————————————————————
					// Atualizo o cadastro de clientes
					//————————————————————————————————————————————————————————————————————————————
					if SZL->(dbSeek(aPrePed[2] + aPrePed[1] + cCobrFrete)) .and.;
						AllTrim(SZL->ZL_TPACESS) == "TVEND"
						
						SA1->(RecLock("SA1", .F.))
						SA1->A1_XTVUSU		:= SZL->ZL_USUID
						SA1->A1_XTVUSUN	:= SZL->ZL_USUNOM
						SA1->(MsUnlock())

					endif

					//————————————————————————————————————————————————————————————————————————————
					// atualizando o código de contrato VPC
					//————————————————————————————————————————————————————————————————————————————
					if SC5->C5_X_CTVPC != cContrato
						SC5->(RecLock("SC5",.F.))
						SC5->C5_X_CTVPC 	:= cContrato
						SC5->(MsUnlock())
					endif

					//————————————————————————————————————————————————————————————————————————————
					// Atualizo a tabela SZK - movimentos VPC
					//————————————————————————————————————————————————————————————————————————————
					if lGrvVPC .and. nUsoVPCFil > 0
						
						SZI->(dbSeek(xFilial("SZI") + "AVU"))
						cHistorico := 	"Debito pedido bonificado: " + SC5->C5_NUM +	", TpVPC: " + "AVU" + "-" + AllTrim(SZI->ZI_DESCR)
						
						//———————————————————————————————————————————————————————————————————————————————
						// Atualizando a tabela SZK - movimentos VPC
						// Função do fonte BFATA03.PRW
						// Parâmetros da função U_VPCGrava_FT03
						//	[1]- Tipo do movimento "CR" para crédito e "DB" para débito
						//	[2]- Código do cliente
						//	[3]- Loja do cliente, qdo o contrato exigir. Somente p/ situações com contrato VPC
						//	[4]- Codigo do contrato VPC
						//	[5]- Tipo do percentual VPC
						//	[6]- Valor da base de cálculo
						//	[7]- Valor do débito ou crédito do movimento
						//	[8]- Campo descritivo com o histórico do lançamento 
						//	[9]- Origem do lançamento
						//	[10]- Chave do registro que originou o lançamento
						//	[11]- Uso da VPC S/N para: NCC / CtaPag / Ped.Bonificados
						//	[12]- Data do movimento
						//———————————————————————————————————————————————————————————————————————————————
						U_VPCGrava_FT03(	"DB",;
											cCliente,;
											iif(lLoja, cLoja, ""),;
											cContrato,;
											"AVU",;
											0,;
											nUsoVPCFil,;
											cHistorico,;
											"2",;
											SC5->C5_FILIAL + SC5->C5_NUM,;
											"SSS",;
											dDataBase)

					endif
						
				endif
		
			End Transaction

		endif

	Else

		//—————————————————————————————————————————————————————————————————————————————
		// Pergunto novamente se a operação prosseguirá, pois o lContinua é atualizado
		// também dentro do laço SZL para verificar itens do pedido
		//—————————————————————————————————————————————————————————————————————————————
		TcSQLExec("UPDATE " + RetSqlName("SZL") + " SET ZL_GRVPED = 'E' WHERE ZL_FILIAL = '" + aPrePed[1] + "' AND ZL_NUM = '" + aPrePed[2] + "' AND ZL_CBRFR = '" + cCobrFrete + "' AND D_E_L_E_T_= ' '")
		/*
		SZL->(dbSeek(aPrePed[2] + aPrePed[1]) + cCobrFrete)
		do while SZL->(!eof() .and. ZL_NUM == aPrePed[2] .and. ZL_FILIAL == aPrePed[1] .and. ZL_CBRFR == cCobrFrete)
			SZL->(RecLock("SZL",.F.))
			SZL->ZL_GRVPED	:= "E"
			SZL->(MsUnlock())
			SZL->(dbSkip())
		enddo
		*/
		U_GravaLog("Pedidos Web", cProcessKey, aPrePed[2], cMsgErro)
		ConOut(cMsgErro)
		exit
		
	Endif
      
Enddo

//——————————————————————————————————————————————————————————————————————————————
// Fecha a area temporaria e envia informacoes de log de erros no processamento 
//——————————————————————————————————————————————————————————————————————————————
if Select("TSZL") > 0
	TSZL->(dbCloseArea())
endif

RpcClearEnv()

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		C_BRAJOB01                                                   /@
@type			Static function                                              /@
@date			19/11/2019                                                   /@
@description	Função chamada pela user function BRAJOB01. Envia o log de 
				processamento.                                               /@
@author			Adalberto Moreno Batista - Opção Um Tecnologia               /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function C_BRAJOB01()
Local lEnvia	:= .F.
Local nSeq		:= 0
Local cEol		:= Chr(13) + Chr(10)
Local cQuery, cDestinat, cAssunto, cMensagem, cLogFile, cLogText

//———————————————————————————————————————————————————————————————————————————————
// Abertura de ambiente
//———————————————————————————————————————————————————————————————————————————————
WfPrepEnv("01", "01", "U_BRAJOB01_SendLog",, "FAT")

cDestinat	:= AllTrim(GetMV('BR_MAILPV', .F., "cassio.olimpio@gamaitaly.com.br"))
cAssunto	:= "Brasitech - Problemas na efetivação do pedido WEB - processo " + cProcessKey
cMensagem 	:= '<html><body>' +;
				'<font size="2" face="Arial">Informações de erros no processamento da efetivação de pedidos WEB para pedidos de venda no ERP Microsiga Protheus.' + cEol + 'Para detalhes dos problemas apresentados, abra o arquivo anexo.</font><br><br><br>' +;
				'<font size="1" face="Calibri">E-mail automático enviado pelo sistema Microsiga Protheus. Favor não respondê-lo.</font>' +;
				'</body></html>'

do while .T.
	cLogFile := "LOG\BRAJOB01_" + dTOs(date()) + "_" + StrZero(++nSeq, 3) + ".LOG"
	if !File(cLogFile)
		exit
	endif
enddo

MemoWrite(cLogFile, "")

//————————————————————————————————————————————————————————————————————————————
// Definição da query de pesquisa e abertura da view temporária
//————————————————————————————————————————————————————————————————————————————
cQuery	:= "SELECT ZZ9_INDPRO, ZZ9_RESUMO, ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), ZZ9_LOG)),'') ZZ9_LOG " +;
			"FROM " + RetSqlName("ZZ9") + " ZZ9 " +;
			"WHERE ZZ9_ROTINA = 'U_BRAJOB01' AND D_E_L_E_T_= ' ' AND ZZ9_CHAVE = '" + cProcessKey + "' " +;
			"ORDER BY R_E_C_N_O_ "

if Select("EVENTLOG") > 0
	EVENTLOG->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQRY(,,cQuery), "EVENTLOG", .F., .T.)

//————————————————————————————————————————————————————————————————————————————
// Alimentação do array com os números dos pré-pedidos
//————————————————————————————————————————————————————————————————————————————
EVENTLOG->(dbGoTop())
do while EVENTLOG->(!eof())

	lEnvia	:= .T.
	cLogText := MemoRead(cLogFile) + cEol
	cLogText += "Pre-pedido: " + EVENTLOG->ZZ9_INDPRO + cEol + "Problema: " + EVENTLOG->ZZ9_LOG + cEol

	MemoWrite(cLogFile, cLogText)
	EVENTLOG->(dbSkip())
	
enddo

if Select("EVENTLOG") > 0
	EVENTLOG->(dbCloseArea())
endif

//————————————————————————————————————————————————————————————————————————————
// Envia e-mail e Exclui de registros de log
//————————————————————————————————————————————————————————————————————————————
if lEnvia
	U_GISendMail(cDestinat,, cAssunto, cMensagem, cLogFile)
	TcSQLExec("DELETE " + RetSqlName("ZZ9") + " WHERE ZZ9_ROTINA = 'U_BRAJOB01' AND ZZ9_CHAVE = '" + cProcessKey + "'")
endif

//———————————————————————————————————————————————————————————————————————————————
// Fechamento do ambiente
//———————————————————————————————————————————————————————————————————————————————
RpcClearEnv()

Return()
