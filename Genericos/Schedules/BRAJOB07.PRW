#include "protheus.ch"
#include "ap5mail.ch"
#include "tbiconn.ch"

/*/
————————————————————————————————————————————————————————————————————————————————————————————————————
@function		BRAJOB07                                 	              	                      /@
@type			User function                                      					   			  /@
@date			09/03/2015                                                                 		  /@
@description	Schedule para exportação de NFS para o software GKO, tabelas lidas (SF2, SD2, SF4)/@
@author			Felipe Varella                                                                    /@
@use			Brasitech                                                                         /@
@ajuste			Rotina para gravar log e envio de e-mail de exportação - Ronaldo Silva - 08/9/21  /@
————————————————————————————————————————————————————————————————————————————————————————————————————
/*/
User Function BRAJOB07()
Local aFiles	:= {"SF2", "SD2", "SF4", "SA4"}
Local nK, nX
Local cEmp		:= "01"				//Brasitech
Local aFil		:= {"03", "01", "09"}		//Filiais 03-São Paulo  01-Manaus  09-Santa Catarina
Private dDtProc	:= Date()
Private cHrProc	:= Time()
Private cProc := "GKO-FRDNE"
Private cQualArq

//———————————————————————————————————————————————————————————————————————————————
// Abertura do ambiente
//———————————————————————————————————————————————————————————————————————————————
for nX := 1 to Len(aFil)

	//———————————————————————————————————————————————————————————————————————————————
	// Abertura do ambiente
	//———————————————————————————————————————————————————————————————————————————————
	WfPrepEnv(cEmp, aFil[nX], "U_BRAJOB07",, "FAT")
	
	for nK := 1 to Len(aFiles)
	
		if Select(aFiles[nK]) = 0
			ChkFile(aFiles[nK])
		endif
		cQualArq:= aFiles[nK] //aFiles[nK,1]
	next
	
	A_BRAJOB07()
	
	//———————————————————————————————————————————————————————————————————————————————
	// Fecha o arquivo de log do processamento e o envia por e-mail
	//———————————————————————————————————————————————————————————————————————————————
	//fClose(nHdl)
		
	BRAJOB07B()

	//———————————————————————————————————————————————————————————————————————————————
	// Encerramento do ambiente                                                     
	//———————————————————————————————————————————————————————————————————————————————
	ConOut(dTOc(Date()) + " as " + Time() + " - BRAJOB07 - Conclusão do processo de NFS para o GKO (INTDNE 5.81b) - Empresa / Filial " + cEmp + "/" + aFil[nX])
	
	RpcClearEnv()

	Sleep(2000)
	
next

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		A_BRAJOB                                                      /@
@type			Static function                                               /@
@date			09/03/2015                                                    /@
@description	Função chamada pela user function BRAJOB07. Seleciona as notas
				de saída que ainda não foram exportadas e gera arquivo para
				ser importado pelo software GKO.                              /@
@author			Felipe Varella                                                /@
@use			Brasitech                                                     /@
———————————————————————————————————————————————————————————————————————————————
Ajustes realizados
- 29/06/2018 por Jose Mendes, chamado 9523
Foi adicionado a verificação com parametros na tab. transportadora a opção de
ignorar as CFOPs que fazem parte do não envio ao GKO
Modificada a estrutura da query

- 25/07/2019 por Adalberto Moreno Batista, chamado 10674
Em conversa com o Marcelo Silva, foi informado que os CFOPs  de consignacao
6113/6114 nunca devem ser exportados. chamado 10674.
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function A_BRAJOB07()
Local aArea			:= GetArea()
Local cDetalhe		:= ""
Local cDtEmb		:= "" 
Local nOcorr		:= 0
Local cInfLog 	    := ""
Local cEol			:= chr(13) + chr(10)
Local cPathGKO		:= GetMV("BR_PATHGKO")				//"\\172.16.10.11\ARQUIVOSGKO\ARQENTRADA\"
Local nSeq			:= GetMV("BR_GKOSEQ", .F., 1)
Local cRedesp		:= StrZero( Val( GetMV("BR_GKOREDE", .F., "") ), 15)
Local cArquivo		:= cPathGKO + "FRDNE_"  + StrZero(nSeq,6) + ".TXT"
Local lOK			:= .T.
Local cCFOPs		:= "5905,6905,5934,6934"
Local nTPesoB, nPesoB, nValor, cPedCli, lContinua, dDtOcorr

//MakeDir("\edi01\gko\exportacaoNF")

Set(_SET_DATEFORMAT, 'dd/mm/yyyy') // Data com QUATRO digitos para Ano

//———————————————————————————————————————————————————————————————————————————————
// Seta ordem das tabelas a serem pesquisadas
//———————————————————————————————————————————————————————————————————————————————
SA1->(dbSetOrder(1))		//A1_FILIAL, A1_COD, A1_LOJA
SB1->(dbSetOrder(1))		//B1_FILIAL, B1_COD
SD2->(dbSetOrder(3))		//D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM
SF2->(dbSetOrder(1))		//F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO
CC2->(dbSetOrder(1))		//CC2_FILIAL, CC2_EST, CC2_CODMUN
SC6->(dbSetOrder(2))		//C6_FILIAL, C6_PRODUTO, C6_NUM, C6_ITEM

//———————————————————————————————————————————————————————————————————————————————
// Selecionando registros
//———————————————————————————————————————————————————————————————————————————————
cQuery := 	"SELECT DISTINCT SF2.R_E_C_N_O_ REGISTRO "		//F2_FILIAL, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA "
cQuery += 	"FROM " + RetSQLName("SF2") + " SF2, "
cQuery += 				 RetSQLName("SA4") + " SA4, "
cQuery += 				 RetSQLName("SD2") + " SD2, "
cQuery += 				 RetSQLName("SF4") + " SF4 "
cQuery += 	"WHERE SF2.F2_FILIAL = '" + xFilial("SF2") + "' "
cQuery +=			"AND SF2.F2_TIPO IN ('N','B') "
cQuery += 			"AND SF2.F2_EMISSAO >='20180711' "
cQuery +=			"AND SF2.F2_TRANSP != '      ' "
cQuery += 			"AND SF2.F2_X_EXPGK = ' ' "
cQuery +=			"AND SF2.D_E_L_E_T_ = ' ' "

cQuery += 			"AND SA4.A4_FILIAL = '" + xFilial("SA4") + "' "
cQuery +=			"AND SA4.A4_COD = SF2.F2_TRANSP "
cQuery +=			"AND SA4.A4_X_GKO != 'N' "
cQuery +=			"AND SA4.D_E_L_E_T_ = ' ' "

cQuery +=			"AND SD2.D2_FILIAL = '" + xFilial("SD2") + "' "
cQuery +=			"AND SD2.D2_DOC = SF2.F2_DOC "
cQuery +=			"AND SD2.D2_SERIE = SF2.F2_SERIE "
cQuery +=			"AND SD2.D2_FILIAL = SF2.F2_FILIAL "
cQuery +=			"AND SD2.D2_CLIENTE = SF2.F2_CLIENTE "
cQuery +=			"AND SD2.D2_LOJA = SF2.F2_LOJA "
cQuery +=			"AND SD2.D2_CF NOT IN ('5113','6113','5114','6114') "
cQuery +=			"AND SD2.D_E_L_E_T_ = ' ' "

cQuery += 			"AND SF4.F4_FILIAL = '" + xFilial("SF4") + "' "
cQuery +=			"AND SF4.F4_CODIGO = SD2.D2_TES "
cQuery +=			"AND SF4.F4_ESTOQUE = 'S' "
cQuery +=			"AND SF4.D_E_L_E_T_ = ' ' "

cQuery += 	"ORDER BY REGISTRO"

if Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea()
endif
	
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB", .F., .T.)

dbSelectArea("TRB")
dbGotop()
if TRB->(!eof())
	
	nHdl := Fcreate(cArquivo)
	If nHdl == -1
		ConOut("BRAJOB07 Erro " + cArquivo + " não pode ser criado! Verifique os parâmetros.")
		Return()
	Endif
	PutMV("BR_GKOSEQ",++nSeq)

   //———————————————————————————————————————————————————————————————————————————————
   // Gera cabecalho - Registro 000 Identificacao
   //———————————————————————————————————————————————————————————————————————————————
	cDetalhe := "000"
	cDetalhe += PadR("INTDNE",10)
	cDetalhe += PadR("5.81a",6)
	cDetalhe += PadR(SM0->M0_NOMECOM,40)
	cDetalhe += PadR("GKO",40)
	cDetalhe += "101"
	cDetalhe += cEol

	If fWrite(nHdl,cDetalhe,Len(cDetalhe)) != Len(cDetalhe)
		lOK := .F.
	Endif

	Do While TRB->(!Eof()) .and. lOK

		//———————————————————————————————————————————————————————————————————————————————
		// Posiciona areas
		//———————————————————————————————————————————————————————————————————————————————
		SF2->(dbGoTo(TRB->REGISTRO))
		If !SA1->(dbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA))
		   U_GrvLog("2", SF2->F2_CLIENTE + SF2->F2_LOJA, "Impossível continuar. Cliente '" + SF2->F2_CLIENTE + SF2->F2_LOJA + "' não encontrado!",cProc)
		   lContinua := .F.
		else
			lContinua	:= .T.
		Endif
		If !SA4->(dbSeek(xFilial("SA4") + SF2->F2_TRANSP))
			U_GrvLog("2", SF2->F2_TRANSP, "Impossível continuar. Transportadora '" + SF2->F2_TRANSP + "' não encontrado!")
		   	lContinua := .F.
		Else   
		   lContinua	:= .T.
		Endif
		If !SD2->(dbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA))
			U_GrvLog("2", SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA, "Impossível continuar. Item da NF '" + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA + "' não encontrado!",cProc)
		   	lContinua := .F.
		Else   
		   lContinua	:= .T.
		Endif
		If !CC2->(dbSeek(xFilial("CC2") + SA1->A1_EST + SA1->A1_COD_MUN))
		   U_GrvLog("2", SA1->A1_EST + SA1->A1_COD_MUN, "Impossível continuar. Municipio '" + SA1->A1_EST + SA1->A1_COD_MUN + "' não encontrado!",cProc)
		   lContinua := .F.
		Else   
		   lContinua	:= .T.
		Endif
		//———————————————————————————————————————————————————————————————————————————————
		// Calculando o peso bruto total, pois a Brasitech utiliza 4 casas decimais e o
		// GKO aceita somente 2
		// Verifica se transportadora segue criterio de CFOP, chamado 9523
		//———————————————————————————————————————————————————————————————————————————————
		//lContinua	:= .T.
		nTPesoB		:= 0
		cPedCli		:= Space(10)
		
		do while SD2->(!eof() .and. D2_FILIAL == SF2->F2_FILIAL .and. D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA == SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA) ) .and. lOK
			cInfLog		:= "NF " +AllTrim(SD2->D2_DOC) + "/" + AllTrim(SD2->D2_SERIE) + ", CLIENTE: " + SF2->(F2_CLIENTE) + "-"+SF2->F2_LOJA//Transform(SA1->A1_CCG, "@R 99.999.999/9999-99")
			
			if SA4->A4_X_PCFOP=="N" .and. AllTrim(SD2->D2_CF) $ cCFOPs
				U_GrvLog("2", SA4->A4_COD + SD2->D2_CF, "Impossível continuar. Transportadora /CFOP '" + SA4->A4_COD + "/"+SD2->D2_CF + "' não segue criterio!",cProc)
		  		lContinua := .F.
				exit
			else
				lContinua := .T.
			endif

			SB1->(dbSeek(xFilial("SB1") + SD2->D2_COD))
			SC6->(dbSeek(xFilial("SC6") + SD2->D2_COD + SD2->D2_PEDIDO + SD2->D2_ITEMPV))
			nTPesoB	+= Round(SB1->B1_PESBRU * SD2->D2_QUANT, 2)
			cPedCli	:= SC6->C6_PEDCLI
						
			SD2->(dbSkip())
		enddo

		//———————————————————————————————————————————————————————————————————————————————
		// verifica se continua com a gravação dos dados
		//———————————————————————————————————————————————————————————————————————————————
		if lContinua
					
			//———————————————————————————————————————————————————————————————————————————————
			// Gera Detalhe - Registro 100 Parceiros
			//———————————————————————————————————————————————————————————————————————————————
			cDetalhe := "100"														//01-tipo registro. fixo 100
			cDetalhe += "A"														//02-tipo operacao A-inclui se nao existir ou alterase existir
			cDetalhe += PadR(SA1->A1_CGC,15)									//03-numero CNPJ se PJ ou CPF se PF
			cDetalhe += "2"														//04-tipo de parceiro comercial 2-cliente
			cDetalhe += PadR(SA1->A1_COD + SA1->A1_LOJA,14)				//05-codigo do parceiro comercial
			cDetalhe += PadR(SA1->A1_NOME,40)								//06-razao social
			cDetalhe += PadR(SA1->A1_END,50)									//07-endereco
			cDetalhe += PadR(SA1->A1_BAIRRO,20)								//08-bairro
			cDetalhe += PadR(CC2->CC2_MUN,30)								//09-municipio	PadR(SA1->A1_MUN,30)
			cDetalhe += SA1->A1_EST												//10-UF
			cDetalhe += SA1->A1_CEP												//11-CEP
			cDetalhe += Space(10)												//12-zona de transporte
			cDetalhe += iif(Len(AllTrim(SA1->A1_CGC))=14,"2","1")		//13-tipo de pessoa, 1-fisica, 2-juridica
			cDetalhe += PadR(SA1->A1_INSCRM,15)								//14-inscricao municipal
			cDetalhe += PadR(SA1->A1_INSCR,15)								//15-inscricao estadual
			cDetalhe += iif(Empty(SA1->A1_INSCR),"0","1")				//16-indica se parceiro eh contribuinte do ICMS
			cDetalhe += "0"														//PERGUNTAR	//17-sttus se o fornecedor emitente da NF eh optante pelo regime de credito de ICMS
			cDetalhe += "0"														//18-status indicando que devera excluir as referencias externas
			cDetalhe += cEol
			
			If fWrite(nHdl,cDetalhe,Len(cDetalhe)) != Len(cDetalhe)
				lOK	:= .F.
				Exit
			Endif
			
			if Empty(SF2->F2_X_COLET)
				cDtEmb	:= PadR(iif(SF2->F2_X_OPLOG == 'ON', dTOc(dDataBase), ""), 10)
			else
				cDtEmb	:= PadR(dTOc(SF2->F2_X_COLET),10)	//PadR(Substr(SF2->F2_X_COLET,7,2) + "/" + Substr(SF2->F2_X_COLET,5,2) + "/" + Substr(SF2->F2_X_COLET,1,4), 10)
			endif
			
			//———————————————————————————————————————————————————————————————————————————————
			// Gera Detalhe - Registro 140 Cabecalho de Doc (NF)
			//———————————————————————————————————————————————————————————————————————————————
			cDetalhe := "140"										//01-tipo registro. fixo 140
			cDetalhe += "A"										//02-tipo operacao A-inclui se nao existir ou alterase existir
			cDetalhe += "1"										//03-tipo de docto 1-nota fiscal
			cDetalhe += "0" + PadR(SM0->M0_CGC,14)			//04-Parceiro comercial
			cDetalhe += PadR(SF2->F2_DOC,12)					//05-codigo do documento
			cDetalhe += PadR(SF2->F2_SERIE,3)				//06-serie do documento
			cDetalhe += PadR(dTOc(SF2->F2_EMISSAO),10)	//07-data de emissao
			cDetalhe += cDtEmb 									//08-data de embarque
			cDetalhe += "2"										//09-para nota de saida (2)
			cDetalhe += PadR(SA1->A1_CGC,15)					//10-identificacao do destinatario
			cDetalhe += PadR(SA1->A1_END,50)					//11-dados destinatario
			cDetalhe += PadR(SA1->A1_BAIRRO,20)				//12-dados destinatario
			cDetalhe += PadR(CC2->CC2_MUN,30)				//13-dados destinatario PadR(SA1->A1_MUN,30)
			cDetalhe += SA1->A1_EST								//14-dados destinatario
			cDetalhe += SA1->A1_CEP								//15-dados destinatario
			cDetalhe += Space(10)								//16-codigo zona de transporte
			cDetalhe += Space(12)								//PERGUNTAR		//17-codigo identif.docto negociacao frete
			cDetalhe += PadR("VEND",4) 						//PERGUNTAR		//18-codigo do tipo da nota
			cDetalhe += Space(10) 								//PERGUNTAR		//19-codigo equipamento (truck, bau, container)
			cDetalhe += Space(4)									//PERGUNTAR		//20-codigo embalagem
			cDetalhe += Padr(SA4->A4_VIA,4)					//21-codigo meio de transporte
			cDetalhe += Space(10)								//22-territorio
			cDetalhe += iif(SA4->A4_XPEDCLI=="S", PadR(cPedCli,10), Space(10))	//23-Separador Conhecimento
			cDetalhe += Space(20)								//24-codigo lote
			cDetalhe += Space(10)								//25-romaneio
			cDetalhe += PadR(SF2->F2_TRANSP,15)				//26-codigo transportadora
			cDetalhe += "1"										//PERGUNTAR		//27-tipo de frete 1-CIF, 2-FOB
			cDetalhe += PadR(SF2->F2_DOC,12)					//28-Numero ordem de embarque qdo (03-) for igual a 1
			cDetalhe += PadR(SF2->F2_SERIE,3)				//29-serie documento vinculado
			cDetalhe += PadR(SD2->D2_CF,6)					//30-natureza da operacao
			cDetalhe += "0"										//31-isento de ICMS 1-SIM OU 0-NAO ISENTO DE ICMS
			cDetalhe += "0"										//32-possui credito de ICMS 1-SIM OU 0-NAO POSSUI CREDITO DE ICMS
			cDetalhe += "0"										//33-teve substituicao tributaria 1-SIM OU 0-NAO POSSUIU ICMS ST NA ENTRADA
			cDetalhe += "3"										//34-finalidade do produto 1-CONSUMO FNAL, 2-INDUSTRIALIZACAO, 3-COMERCIALIZACAO, 5-REVENDA
			cDetalhe += StrZero(nTPesoB * 100,15)			//35-peso bruto  StrZero(SF2->F2_PBRUTO*100,15)
			cDetalhe += Space(15)								//36-peso cubado
			cDetalhe += StrZero(0,15)							//37-peso liquido StrZero(SF2->F2_PLIQUI*100,15)
			cDetalhe += StrZero(SF2->F2_VOLUME1,6)			//38-qtde volume
			cDetalhe += StrZero(0,15)							//39-outros valores nao inclusos nos itens do documento
			cDetalhe += PadR(" ",10)							//40-codigo indicador financeiro qdo NF estiver em US$
			cDetalhe += "0"										//41-Entrega urgente
			cDetalhe += " "										//42-indica se DNE possui frete diferenciado
			cDetalhe += PadR(" ",10)							//43-data de entrega
			cDetalhe += PadR(" ",15)							//44-responsavel pelo frete do documento
			cDetalhe += PadR(" ",10)							//45-data de referencia para calculodo frete
			cDetalhe += PadR(" ",10)							//46-data de previsao de entrega
			cDetalhe += StrZero(0,15)							//47-valor do frete pago pelo cliente
			cDetalhe += "1"										//48-Status da DNE 1-normal 2-cancelado
			cDetalhe += " "										//49-Status
			cDetalhe += "1"										//50-Status
			cDetalhe += cEol
			
			If fWrite(nHdl,cDetalhe,Len(cDetalhe)) != Len(cDetalhe)
				lOK	:= .F.
				Exit
			Endif
			
			//Ocorrencia de bloqueios das notas fiscais. 104 = Bloqueio comercial / 105 = Bloqueio logistico
			
			If substring(SF2->F2_X_OPLOG,2,1) = 'S' 
				nOcorr	:= 104
				dDtOcorr	:= SF2->F2_EMISSAO
			ElseIf substring(SF2->F2_X_OPLOG,1,1) = 'S'
				nOcorr	:= 105
				dDtOcorr := iif(!Empty(SF2->F2_X_DBLQ2), sTOd(Left(SF2->F2_X_DBLQ2,8)), SF2->F2_EMISSAO)
			ElseIf (SF2->F2_X_OPLOG) = 'NN' .and. (!empty(SF2->F2_X_DBLQ1) .or. !empty(SF2->F2_X_DBLQ2))
				nOcorr   := 107
				dDtOcorr := iif(sTOd(Left(SF2->F2_X_DBLQ1,8))  > sTOd(Left(SF2->F2_X_DBLQ2,8)), sTOd(Left(SF2->F2_X_DBLQ1,8)), sTOd(Left(SF2->F2_X_DBLQ2,8)))
			Else
				dDtOcorr	:= cTOd("")
				nOcorr 	:= 0
			Endif
			
			//———————————————————————————————————————————————————————————————————————————————
			// Dados de Ocorrência - Registro 143
			//———————————————————————————————————————————————————————————————————————————————
			If nOcorr > 0 
				cDetalhe := "143"
				cDetalhe += "A"		
				cDetalhe += strzero(nOcorr,5)
				cDetalhe += dTOc(dDtOcorr)
				cDetalhe += cEol
			
				If fWrite(nHdl,cDetalhe,Len(cDetalhe)) != Len(cDetalhe)
					lOK	:= .F.
					Exit
				Endif
			    
			Endif
			
			//———————————————————————————————————————————————————————————————————————————————
			// Gera registro de Redespacho - 147
			//———————————————————————————————————————————————————————————————————————————————
			cDetalhe := "147"												//tipo registro. fixo 147
			cDetalhe += "A"												//01-(OBR) tipo operacao A-inclui se nao existir ou alterase existir
			cDetalhe += StrZero( Val(SM0->M0_CGC),15)				//02-(OBR) parceiro comercial
			cDetalhe += PadR(SF2->F2_DOC,12)							//03-(OBR) codigo do documento
			cDetalhe += PadR(SF2->F2_SERIE,3)						//04-serie do documento
			cDetalhe += "00"												//05-(OBR) Numero de ordem do redespacho
			cDetalhe += StrZero( Val(cRedesp),15)					//06-(OBR) identificacao do local de redespacho
			cDetalhe +=	PadR(SF2->F2_TRANSP,15)						//07-codigo da transportadora de redespacho
			cDetalhe += "1" 												//08-tipo de frete do redespacho do segundo trecho
			cDetalhe += Padr(SA4->A4_VIA,4)							//09-codigo do meio de transporte
			cDetalhe += iif(SA4->A4_XPEDCLI=="S", PadR(cPedCli,10), Space(10))	//10-Separador Conhecimento
			cDetalhe += Space(20)										//11-codigo lote
			cDetalhe += Space(10)										//12-codigo do equipamento
			cDetalhe += "0"												//13-indica se o DNE possui frete diferenciado
			/*
			cDetalhe += Space(15)										//07-codigo da transportadora de redespacho
			cDetalhe += Space(01)										//08-tipo de frete do redespacho do segundo trecho
			cDetalhe += Space(04) 										//09-codigo do meio de transporte
			cDetalhe += Space(10)										//10-identificador de embarque
			cDetalhe += Space(20)										//11-codigo lote
			cDetalhe += Space(10)										//12-codigo do equipamento
			cDetalhe += Space(01)										//13-indica se o DNE possui frete diferenciado
			*/
			cDetalhe += "1"												//14-(OBR) Status do trecho 1=normal; 2=cancelado
			cDetalhe += cEol
	
			If fWrite(nHdl,cDetalhe,Len(cDetalhe)) != Len(cDetalhe)
				lOK	:= .F.
				Exit
			Endif
			
			//———————————————————————————————————————————————————————————————————————————————
			// Dados para Registro 150 e 160 - Itens da Nf (SD2)
			//———————————————————————————————————————————————————————————————————————————————
			SD2->( dbSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA ) )
			do while SD2->(!eof() .and. D2_FILIAL = SF2->F2_FILIAL .and. D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA = SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA) ) .and. lOK
	
				SB1->(dbSeek(xFilial("SB1")+SD2->D2_COD))
				
				//———————————————————————————————————————————————————————————————————————————————
				// Gera Detalhe - Registro 150 Materiais
				//———————————————————————————————————————————————————————————————————————————————
				cDetalhe := "150"								//01-fixo 150
				cDetalhe += "A"								//02-A-inclui se nao existir ou atualiza se existir
				cDetalhe += Padr(SB1->B1_DESC,40)		//03-descricao do item
				cDetalhe += Padr(SD2->D2_COD,20)			//04-codigo do item
				cDetalhe += Padr(SD2->D2_GRUPO,10)		//05-codigo da categoria
				cDetalhe += Padr(" ",10)					//06-codigo da categoria
				cDetalhe += Padr(SD2->D2_UM,3)			//07-codigo 1a. UM
				cDetalhe += StrZero(100,7)					//08-qtd referencial na 1a UM
				cDetalhe += StrZero(0,7)					//09-Peso em KG equivalente a 1a UM  StrZero(SB1->B1_PESBRU*100,7)
				cDetalhe += Padr(" ",3)						//10-codigo 2a. UM
				cDetalhe += StrZero(0,7)					//11-qtd referencial na 2a UM
				cDetalhe += StrZero(0,7)					//12-Peso em KG equivalente a 2a UM
				cDetalhe += Padr(" ",3)						//13-codigo 3a. UM
				cDetalhe += StrZero(0,7)					//14-qtd referencial na 3a UM
				cDetalhe += StrZero(0,7)					//15-Peso em KG equivalente a 3a UM
				cDetalhe += Padr(" ",3)						//16-codigo 4a. UM
				cDetalhe += StrZero(0,7)					//17-qtd referencial na 4a UM
				cDetalhe += StrZero(0,7)					//18-Peso em KG equivalente a 4a UM
				cDetalhe += cEol
	
			    If fWrite(nHdl,cDetalhe,Len(cDetalhe)) != Len(cDetalhe)
			    	lOK	:= .F.
			        Exit
			    Endif
			
				//———————————————————————————————————————————————————————————————————————————————
				// Gera Detalhe - Registro 160 Itens NF
				//———————————————————————————————————————————————————————————————————————————————
				nPesoB	:= Round(SB1->B1_PESBRU * SD2->D2_QUANT, 2)
				//nValor	:= SD2->D2_TOTAL + SD2->D2_VALIPI + SD2->D2_ICMSRET
				nValor	:= SD2->D2_VALBRUT
				
				cDetalhe := "160"											//01-fixo 160
				cDetalhe += "A"											//02-A-inclui se nao existir ou atualiza se existir
				cDetalhe += "0" + PadR(SM0->M0_CGC,14)				//03-identificacao do emitente
				cDetalhe += PadR(SF2->F2_DOC,12)						//04-codigo do documento
				cDetalhe += PadR(SF2->F2_SERIE,3)					//05-serie do documento
				cDetalhe += PadR(SD2->D2_ITEM,3)						//06-item do documento
				cDetalhe += Padr(SD2->D2_COD,20)						//07-codigo do item
				cDetalhe += StrZero(nValor * 100,12)				//08-valor do item
				cDetalhe += StrZero(nPesoB * 100,15)				//09-peso bruto
				cDetalhe += StrZero(0,15)								//10-peso cubado
				cDetalhe += StrZero(0,15)								//11-peso liquido   StrZero((SD2->D2_PESO*SD2->D2_QUANT)*100,15)
				cDetalhe += StrZero(0,4)								//12-volume
				cDetalhe += StrZero(0,10)								//13-valor cubagem
				cDetalhe += Padr(SD2->D2_CONTA,15)					//14-codigo conta contabil
				cDetalhe += Padr(SD2->D2_CCUSTO,10)					//15-codigo centro de custo
				cDetalhe += StrZero(SD2->D2_QUANT * 100,15)		//16-quantidade da nota fiscal
				cDetalhe += Padr(SD2->D2_UM,3)						//17-UM do item
				cDetalhe += StrZero(0,15)								//18-valor do frete da tabela
				cDetalhe += StrZero(0,15)								//13-valor do frete pago
				cDetalhe += cEol
	
				If fWrite(nHdl,cDetalhe,Len(cDetalhe)) != Len(cDetalhe)
					lOK	:= .F.
			   	Exit
				Endif
	
				SD2->(dbSkip())
	
			Enddo 

			//if SF2->(dbSeek(xFilial("SF2") + TRB->F2_DOC + TRB->F2_SERIE + TRB->F2_CLIENTE + TRB->F2_LOJA))
			SF2->(RecLock("SF2", .F.))
			SF2->F2_X_EXPGK := "N"
			SF2->(MsUnLock())
	  
		endif
		
		TRB->(DbSkip())

	enddo
	FClose(nHdl)

else

	lOK	:= .F.
	
Endif

if Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea()
endif

if lOK
	ConOut(dTOc(Date()) + " as " + Time() + " - BRAJOB07 - Arquivo Gerado com Sucesso! " + cArquivo)
	U_GrvLog("0", cInfLog, "Arquivo Gerado com sucesso!" + cArquivo,cProc)
else
	U_GrvLog("2", cInfLog, "Arquivo sem dados para exportação" + cArquivo,cProc)
endif

RestArea(aArea)

Return() 

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRAJOB07B                                                    /@
@type			Static function                                              /@
@date			05/09/2014                                                   /@
@description	Função chamada pela user function BRAJOB07. Envia o log de
				processamento para e-mails previamente cadastrados no parame-
				tro BR_MAILGKO                                               /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function BRAJOB07B()
Local cPathGKO		:= GetMV("BR_PATHGKO")
Local cDestinat	:= AllTrim(GetMV("BR_MAILGKO", .F., "equipe.ti@gamaitaly.com.br"))
Local cLinkLogo	:= AllTrim(GetMV("BR_LNKLOGO", .F., "https://sweb.gamaitaly.com.br/images/LogoGamaPeq.jpg"))
Local cAssunto	:= "Brasitech/" + Lower(AllTrim(SM0->M0_FILIAL)) + " - Log de exportação de NFS, processo GKO FRDNE em " + dTOc(dDtProc) + " às " + cHrProc
Local cQuery	:=	"SELECT R_E_C_N_O_ REGISTRO " +;
						"FROM " + RetSqlName("ZZ9") + " ZZ9 " +;
						"WHERE ZZ9.ZZ9_FILIAL = '" + xFilial("ZZ9") + "' " +;
								"AND ZZ9.ZZ9_TIPO = '2' " +;
								"AND ZZ9.ZZ9_DATA = '" + dTOs(dDtProc) + "' " +;
								"AND ZZ9_PROC = '" + cProc + "' " +;
								"AND ZZ9.D_E_L_E_T_= ' ' " +;
						"ORDER BY ZZ9_INDPRO "
Local cHtml, lInverte


//————————————————————————————————————————————————————————————————————————————
// Iniciando a criação do formato html
//————————————————————————————————————————————————————————————————————————————
cHtml := '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">' +;
		'<html xmlns="http://www.w3.org/1999/xhtml">' +;
		'<head> ' +;
		'<meta content="en-us" http-equiv="Content-Language" />' +;
		'<meta content="text/html; charset=utf-8" http-equiv="Content-Type" />' +;
		'<style type="text/css">' +;
		'.style1 {' +;
		'	font-family: Calibri;' +;
		'	font-size: small;' +;
		'	color: #050538;' +;
		'}' +;
		'.style2 {' +;
		'	font-size: x-small;' +;
		'	background-color: #E9E9E9;' +;
		'	font-family: Calibri;' +;
		'}' +;
		'.style3 {' +;
		'	font-size: x-small;' +;
		'	font-family: Calibri;' +;
		'}' +;
		'.style4 {' +;
		'	font-size: x-small;' +;
		'	font-family: Calibri;' +;
		'	color: #FFFFFF;' +;
		'	background-color: #5B5B5B;' +;
		'}' +;
		'.style5 {' +;
		'	font-size: x-small;' +;
		'	background-color: #E9E9E9;' +;
		'	font-family: Calibri;' +;
		'	text-align: right;' +;
		'}' +;
		'.style6 {' +;
		'	font-size: x-small;' +;
		'	font-family: Calibri;' +;
		'	text-align: right;' +;
		'}' +;
		'.style7 {' +;
		'	font-size: x-small;' +;
		'	font-family: Calibri;' +;
		'	color: #FFFFFF;' +;
		'	background-color: #5B5B5B;' +;
		'	text-align: right;' +;
		'}' +;
		'.style8 {' +;
		'	font-family: Arial, Helvetica, sans-serif;' +;
		'	font-size: x-small;' +;
		'}' +;
		'</style>' +;
		'</head>' +;
		'<body>' +;
		'<p class="style8">' +;
		'<img src="' + cLinkLogo + '"></p><br>' +;
		'<p class="style1" style="mso-fareast-font-family: Calibri; mso-fareast-theme-font: minor-latin; mso-ansi-language: PT-BR; mso-fareast-language: EN-US; mso-bidi-language: AR-SA">'

//———————————————————————————————————————————————————————————————————————————————
// Verificando a existencia da area Temporaria
//———————————————————————————————————————————————————————————————————————————————
if Select("TMPLOG") > 0
	TMPLOG->(dbCloseArea())
endif

//———————————————————————————————————————————————————————————————————————————————
// Criando a tabela temporaria
//———————————————————————————————————————————————————————————————————————————————
dbUseArea(.T., "TOPCONN", TcGenQRY(,,cQuery), "TMPLOG", .F., .T.)

dbSelectArea("TMPLOG")
TMPLOG->(dbGoTop())
if TMPLOG->(!eof())

	cHtml += 'Inconsistências no processo de exportação de NFS, processo '+cProc+' executado pela rotina '+Alltrim(FunName())+'. <br>Filial '+AllTrim(SM0->M0_FILIAL)+'.<br>Leitura de arquivos'+cPathGKO+'"FRDNE*.TXT".</p>'
		
	cHtml += '<table style="width: 100%">'
	cHtml += '	<tr>'
	cHtml += '		<td class="style4" style="width: 21%">Chave</td>'
	cHtml += '		<td class="style4" style="width: 14%">Arquivo</td>'
	cHtml += '		<td class="style4" style="width: 65%">Inconsistência</td>'
	cHtml += '	</tr>'
	
	lInverte := .T.

	do while TMPLOG->(!eof())
		
		ZZ9->(dbGoTo(TMPLOG->REGISTRO))

		lInverte := !lInverte
			
		cHtml += '	<tr>'
		cHtml += '		<td class="' + iif(lInverte, 'style3', 'style2') + '" style="width: 21%">' + AllTrim(ZZ9->ZZ9_CHAVE) + '</td>'
		cHtml += '		<td class="' + iif(lInverte, 'style3', 'style2') + '" style="width: 14%">' + AllTrim(ZZ9->ZZ9_INDPRO) + '</td>'
		cHtml += '		<td class="' + iif(lInverte, 'style3', 'style2') + '" style="width: 65%">' + ZZ9->ZZ9_LOG + '</td>'
		cHtml += '	</tr>'

		TMPLOG->(dbSkip())

	enddo

	cHtml += '</table>'
	
else

	cHtml += 'Não foram encontradas inconsistências no processo de exportação de NFS, processo '+cProc+' executado pela rotina '+Alltrim(FunName())+'.<br>Filial '+AllTrim(SM0->M0_FILIAL)+'.<br>Leitura de arquivos '+cPathGKO+'"FRDNE*.TXT".</p>'

endif

cHtml += '</body>'
cHtml += '</html>'

U_GISendMail(cDestinat,, cAssunto, cHtml)
	
if Select("TMPLOG") > 0
	TMPLOG->(dbCloseArea())
endif

Return()
