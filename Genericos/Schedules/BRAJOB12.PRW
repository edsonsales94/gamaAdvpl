#include "protheus.ch"
#include "ap5mail.ch"
#include "tbiconn.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		                                                      /@
@type				User function                                            	  /@
@date				09/03/2015                                                    /@
@description	Rotina para uso em schedule. Job para Exportar Documentos de 
					entradas para o GKO.
					Será utilizado os dados das ARs como base das notas fiscais.
					Tabelas (SZG, SZH, SF4, SB1)                                  /@
@author			Luiz Fernando - Brasitech          			                    /@
@use				Específico Brasitech                                          /@	
———————————————————————————————————————————————————————————————————————————————
/*/
User Function BRAJOB12()
Local aFiles	:= {"SZG", "SZH"}
Local cEmp		:= "01"					//Brasitech
Local aFil		:= {"03", "01"}		//Filiais 03-São Paulo e 01-Manaus
Local nK, nX

//———————————————————————————————————————————————————————————————————————————————
// Abertura do ambiente
//———————————————————————————————————————————————————————————————————————————————
for nX := 1 to Len(aFil)

	//———————————————————————————————————————————————————————————————————————————————
	// Abertura do ambiente
	//———————————————————————————————————————————————————————————————————————————————
	WfPrepEnv(cEmp, aFil[nX], "U_BRAJOB12",, "FAT")
	
	for nK := 1 to Len(aFiles)
	
		if Select(aFiles[nK]) = 0
			ChkFile(aFiles[nK])
		endif
		
	next
	
	A_BRAJOB12()
	
	//———————————————————————————————————————————————————————————————————————————————
	// Encerramento do ambiente                                                     
	//———————————————————————————————————————————————————————————————————————————————
	RpcClearEnv()

	Sleep(2000)
	
next
	
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		A_BRAJOB12                                                    /@
@type				Static function                                           	  /@
@date				09/03/2015                                                    /@
@description	Função chamada pela user function BRAJOB12. Seleciona as 
					Notas de saída referente ao dia anterior que serão 
					enviadas para o GKO                                           /@
@author			Felipe Varella - Brasitech                                    /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function A_BRAJOB12()
Local aArea			:= GetArea()
Local aAreaSZG		:= SZG->(GetArea())
Local aAreaSZH		:= SZH->(GetArea()) 
Local aAreaSA1		:= SA1->(GetArea())
Local aAreaSB1		:= SB1->(GetArea()) 
Local cDetalhe		:= ""
Local cDTEmb		:= ""  
Local cDTEnt		:= "" 
Local cEol			:= chr(13) + chr(10)
Local cPathGKO		:= GetMV("BR_PATHGKO")	
Local nSeq			:= GetMV("BR_GKOSEQ", .F., 1)
Local cRedesp		:= StrZero( Val( GetMV("BR_GKOREDE", .F., "") ), 15)
Local cArquivo		:= cPathGKO + "FRDNE_"  + StrZero(nSeq,6) + ".TXT"
Local lOk			:= .T.
Local nCubPad		:= getmv("MV_XCUBMAS")
Local nVolume		:= 0
Local nInteiro		:= 0
Local nResto		:= 0
Local nTPesoB, nPesoB, nValor, cPedCli, cEmisNF

//MakeDir("\edi01\gko\exportacaoNF")

//———————————————————————————————————————————————————————————————————————————————
// Seta ordem das tabelas a serem pesquisadas
//———————————————————————————————————————————————————————————————————————————————
SA1->(dbSetOrder(1))
SB1->(dbSetOrder(1))
SZG->(dbSetOrder(1))
SZH->(dbSetOrder(1))

//———————————————————————————————————————————————————————————————————————————————
// Selecionando registros
//———————————————————————————————————————————————————————————————————————————————
cQuery := 	"SELECT DISTINCT SZG.ZG_NUMERO,SZG.ZG_EMISSAO,SZG.ZG_NFDEVOL, SZG.ZG_SERIENF, "
cQuery += 			 "SZG.ZG_DTDEVOL, SZG.ZG_CLIENTE, SZG.ZG_LOJACLI,SZG.ZG_FILIAL, SZG.ZG_DTCOLE, "
cQuery += 			 "SZG.ZG_TRANSP, SZG.ZG_VALOR, SZG.ZG_CFOP,SZG.ZG_DTSOLIC,SZG.ZG_ESTCOLE "
cQuery += 	"FROM " + RetSQLName("SZG") + " SZG , " + RetSQLName("SA4") + " SA4 "
cQuery += 	"WHERE SZG.ZG_FILIAL = '" + xFilial("SZG") + "' AND SZG.D_E_L_E_T_ = ' ' "
cQuery +=		 	"AND SA4.A4_FILIAL = '" + xFilial("SA4") + "' AND SA4.D_E_L_E_T_ = ' ' "
cQuery +=			"AND SZG.ZG_TRANSP != '' "
cQuery +=			"AND SA4.A4_COD = SZG.ZG_TRANSP "
cQuery +=			"AND SA4.A4_X_GKO != 'N' "
cQuery +=			"AND SZG.ZG_NFDEVOL != '' " 
cQuery +=			"AND ZG_X_EXPGK = '' "
cQuery +=			"AND ISNUMERIC(ZG_NFDEVOL) = 1 "  //ISNUMERIC RETORNA 1 SE O CAMPO SÓ CONTIVER NUMEROS
cQuery += 	"ORDER BY ZG_NUMERO"
              
if Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea()
endif
	
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB", .F., .T.)

//Memowrite("BRAJOB12.Sql" , cQuery )

dbSelectArea("TRB")
dbGotop()
if TRB->(!eof())

	nHdl := Fcreate(cArquivo)
	If nHdl == -1
	    ConOut("BRAJOB12 Erro " + cArquivo + " não pode ser criado! Verifique os parâmetros.")
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
		lOk := .F.
    Endif

	Do While TRB->(!Eof()) .and. lOk

		//———————————————————————————————————————————————————————————————————————————————
		// Posiciona areas
		//———————————————————————————————————————————————————————————————————————————————
		SA1->(dbSeek(xFilial("SA1") + TRB->ZG_CLIENTE + TRB->ZG_LOJACLI))
		SZH->(dbSeek(xFilial("SZH") + TRB->ZG_NUMERO))
		CC2->(dbSeek(xFilial("CC2") + SA1->A1_EST + SA1->A1_COD_MUN))
		
		nTPesoB  := 0
		nInteiro := 0 
		nResto	:= 0
		
		//———————————————————————————————————————————————————————————————————————————————
		// Calculando o peso bruto total, pois a Brasitech utiliza 4 casas decimais e o
		// GKO aceita somente 2
		//———————————————————————————————————————————————————————————————————————————————
		cPedCli	:= Space(10)
		do while SZH->(!eof() .and. ZH_FILIAL = TRB->ZG_FILIAL .and. ZH_NUMERO  = TRB->ZG_NUMERO ) .and. lOk
			SB1->(dbSeek(xFilial("SB1")+SZH->ZH_PRODUTO))
			nTPesoB += Round(SB1->B1_PESBRU * SZH->ZH_QTDDEVO, 2)
			//———————————————————————————————————————————————————————————————————————————————
			// Calculando a quantidade de volumes total
			//———————————————————————————————————————————————————————————————————————————————
			if SB1->B1_X_QTCXM > 0 .and. SB1->B1_XMETCUB > 0
				nInteiro	+= Int(SZH->ZH_QTDDEVO / SB1->B1_X_QTCXM)
				nResto		+= (SZH->ZH_QTDDEVO % SB1->B1_X_QTCXM) * SB1->B1_XMETCUB
			endif
			SZH->(dbSkip())
		Enddo
		
		//———————————————————————————————————————————————————————————————————————————————
		// VOLUME = inteiros_acumulados + inteiro(resto_acumulado/6) + se houver resto da 
		// operacao anterior, somo 1, senao somo zero
		//———————————————————————————————————————————————————————————————————————————————
		nVolume := nInteiro + Int(nResto / nCubPad) + iif(nResto % nCubPad > 0, 1, 0)		
		
		//———————————————————————————————————————————————————————————————————————————————
		// Gera Detalhe - Registro 100 Parceiros
		//———————————————————————————————————————————————————————————————————————————————
		cDetalhe := "100"													//01-tipo registro. fixo 100
		cDetalhe += "A"													//02-tipo operacao A-inclui se nao existir ou altera se existir
		cDetalhe += PadR(SA1->A1_CGC,15)								//03-CNPJ do emitente da nota fiscal
		cDetalhe += "2"													//04-tipo de parceiro comercial 2-cliente
		cDetalhe += PadR(SA1->A1_COD + SA1->A1_LOJA,14)			//05-codigo do parceiro comercial
		cDetalhe += PadR(SA1->A1_NOME,40)							//06-razao social
		cDetalhe += PadR(SA1->A1_END,50)								//07-endereco
		cDetalhe += PadR(SA1->A1_BAIRRO,20)							//08-bairro
		cDetalhe += PadR(CC2->CC2_MUN,30)							//09-municipio	PadR(SA1->A1_MUN,30)
		cDetalhe += SA1->A1_EST											//10-UF
		cDetalhe += SA1->A1_CEP											//11-CEP
		cDetalhe += Space(10)											//12-zona de transporte
		cDetalhe += iif(Len(AllTrim(SA1->A1_CGC))=14,"2","1")	//13-tipo de pessoa, 1-fisica, 2-juridica
		cDetalhe += PadR(SA1->A1_INSCRM,15)							//14-inscricao municipal
		cDetalhe += PadR(SA1->A1_INSCR,15)							//15-inscricao estadual
		cDetalhe += iif(Empty(SA1->A1_INSCR),"0","1")			//16-indica se parceiro eh contribuinte do ICMS
		cDetalhe += "0"													//17-sttus se o fornecedor emitente da NF eh optante pelo regime de credito de ICMS
		cDetalhe += "0"													//18-status indicando que devera excluir as referencias externas
		cDetalhe += cEol
		
	    If fWrite(nHdl,cDetalhe,Len(cDetalhe)) != Len(cDetalhe)
	       	lOk	:= .F.
	    	Exit
	    Endif
		
		cDTEnt	:= IIf(!empty(TRB->ZG_DTSOLIC),PadR(SUBSTR(TRB->ZG_DTSOLIC,7,2)+"/"+SUBSTR(TRB->ZG_DTSOLIC,5,2)+"/"+SUBSTR(TRB->ZG_DTSOLIC,1,4),10),; 
  						PadR(SUBSTR(TRB->ZG_DTDEVOL,7,2)+"/"+SUBSTR(TRB->ZG_DTDEVOL,5,2)+"/"+SUBSTR(TRB->ZG_DTDEVOL,1,4),10))
		cDTEmb	:= IIf(!empty(TRB->ZG_DTCOLE),PadR(SUBSTR(TRB->ZG_DTCOLE,7,2)+"/"+SUBSTR(TRB->ZG_DTCOLE,5,2)+"/"+SUBSTR(TRB->ZG_DTCOLE,1,4),10),;
						PadR(SUBSTR(dtos(ddatabase),7,2)+"/"+SUBSTR(dtos(ddatabase),5,2)+"/"+SUBSTR(dtos(ddatabase),1,4),10))
		cEmisNF	:= TRB->(Substr(ZG_DTDEVOL,7,2) + "/" + Substr(ZG_DTDEVOL,5,2) + "/" + Substr(ZG_DTDEVOL,1,4))
						
		//———————————————————————————————————————————————————————————————————————————————
		// Gera Detalhe - Registro 140 Cabecalho de Doc (NF)
		//alteração Jose Mendes 12/06/2018 chamado 9403 inversão de data (*jm) foi analisado junto com os
		//envolvido e não tem outra aplicação da empresa que precisa destas informações de troca de data
		//
		//———————————————————————————————————————————————————————————————————————————————
		cDetalhe := "140"									//01-tipo registro. fixo 140
		cDetalhe += "A"									//02-tipo operacao A-inclui se nao existir ou alterase existir
		cDetalhe += "1"									//03-tipo de docto 1-nota fiscal
		cDetalhe += "0" + PadR(SA1->A1_CGC,14)		//04-Parceiro comercial
		cDetalhe += PadR(TRB->ZG_NFDEVOL,12)		//05-codigo do documento
		cDetalhe += PadR(TRB->ZG_SERIENF,3)			//06-serie do documento
		cDetalhe +=  cEmisNF                   //07-data de emissao
		cDetalhe += cDTEnt               			//08-data de embarque
		cDetalhe += "1"									//09-para nota de entrada (1)
		cDetalhe += PadR(SM0->M0_CGC,15)				//10-identificacao do destinatario
		cDetalhe += space(50)							//11-dados destinatario
		cDetalhe += space(20)							//12-dados destinatario
		cDetalhe += space(30)							//13-dados destinatario PadR(SA1->A1_MUN,30)
		cDetalhe += space(2)								//14-dados destinatario
		cDetalhe += space(8)								//15-dados destinatario
		cDetalhe += Space(10)							//16-codigo zona de transporte
		cDetalhe += Space(12)							//17-codigo identif.docto negociacao frete
		cDetalhe += PadR("DEV",4) 						//18-codigo do tipo da nota
		cDetalhe += Space(10) 							//19-codigo equipamento (truck, bau, container)
		cDetalhe += Space(4)								//20-codigo embalagem
		cDetalhe += "RODO"								//21-codigo meio de transporte
		cDetalhe += Space(10)							//22-territorio
		cDetalhe += space(10)							//23-Separador Conhecimento
		cDetalhe += Space(20)							//24-codigo lote
		cDetalhe += Space(10)							//25-romaneio
		cDetalhe += PadR(TRB->ZG_TRANSP,15)			//26-codigo transportadora
		cDetalhe += "2"									//27-tipo de frete 1-CIF, 2-FOB
		cDetalhe += PadR(TRB->ZG_NUMERO,12)			//28-Numero ordem de embarque qdo (03-) for igual a 1
		cDetalhe += PadR(TRB->ZG_FILIAL,3)			//29-serie documento vinculado
		cDetalhe += PadR(TRB->ZG_CFOP,6)				//30-natureza da operacao
		cDetalhe += "0"									//31-isento de ICMS 1-SIM OU 0-NAO ISENTO DE ICMS
		cDetalhe += "0"									//32-possui credito de ICMS 1-SIM OU 0-NAO POSSUI CREDITO DE ICMS
		cDetalhe += "0"									//33-teve substituicao tributaria 1-SIM OU 0-NAO POSSUIU ICMS ST NA ENTRADA
		cDetalhe += "3"									//34-finalidade do produto 1-CONSUMO FNAL, 2-INDUSTRIALIZACAO, 3-COMERCIALIZACAO, 5-REVENDA
		cDetalhe += StrZero(nTPesoB * 100,15)		//35-peso bruto  StrZero(TRB->F2_PBRUTO*100,15)
		cDetalhe += Space(15)							//36-peso cubado
		cDetalhe += StrZero(0,15)						//37-peso liquido StrZero(TRB->F2_PLIQUI*100,15)
		cDetalhe += StrZero(nVolume,6)				//38-qtde volume
		cDetalhe += StrZero(0,15)						//39-outros valores nao inclusos nos itens do documento
		cDetalhe += PadR(" ",10)						//40-codigo indicador financeiro qdo NF estiver em US$
		cDetalhe += "0"									//41-Entrega urgente
		cDetalhe += " "									//42-indica se DNE possui frete diferenciado
		cDetalhe += cDTEmb								//43-data de entrega
		cDetalhe += PadR(SM0->M0_CGC,15)				//44-responsavel pelo frete do documento
		cDetalhe += space(10)							//45-data de referencia para calculodo frete
		cDetalhe += PadR(" ",10)						//46-data de previsao de entrega
		cDetalhe += StrZero(0,15)						//47-valor do frete pago pelo cliente
		cDetalhe += "1"									//48-Status da DNE 1-normal 2-cancelado
		cDetalhe += " "									//49-Status
		cDetalhe += "1"									//50-Status
		cDetalhe += PadR(" ",100)						//51-ESPAÇO
		cDetalhe += PadR(SZG->ZG_CHVNFE,44)			    //51-Chave da Nfe
		cDetalhe += cEol
		
	    If fWrite(nHdl,cDetalhe,Len(cDetalhe)) != Len(cDetalhe)
			lOk	:= .F.
	        Exit
	    Endif
		
		//———————————————————————————————————————————————————————————————————————————————
		// Gera registro de Redespacho - 147
		//———————————————————————————————————————————————————————————————————————————————
		cDetalhe := "147"												//tipo registro. fixo 147
		cDetalhe += "A"												//01-(OBR) tipo operacao A-inclui se nao existir ou alterase existir
		cDetalhe += StrZero( Val(SM0->M0_CGC),15)				//02-(OBR) parceiro comercial
		cDetalhe += PadR(TRB->ZG_NFDEVOL,12)					//03-(OBR) codigo do documento
		cDetalhe += PadR(TRB->ZG_SERIENF,3)						//04-serie do documento
		cDetalhe += "99"												//05-(OBR) Numero de ordem do redespacho
		cDetalhe += StrZero( Val(cRedesp),15)					//06-(OBR) identificacao do local de redespacho
		cDetalhe +=	PadR(TRB->ZG_TRANSP,15)						//07-codigo da transportadora de redespacho
		cDetalhe += "2" 												//08-tipo de frete do redespacho do segundo trecho
		cDetalhe += "RODO"	 										//09-codigo do meio de transporte
		cDetalhe += space(10)										//10-Separador Conhecimento
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
			lOk	:= .F.
	        Exit
	    Endif
		
		//———————————————————————————————————————————————————————————————————————————————
		// Dados para Registro 150 e 160 - Itens da Nf (SZH)
		//———————————————————————————————————————————————————————————————————————————————
		SZH->( dbSeek(xFilial("SZH") + TRB->ZG_NUMERO ) )
		do while SZH->(!eof() .and. ZH_FILIAL = TRB->ZG_FILIAL .and. ZH_NUMERO = TRB->ZG_NUMERO ) .and. lOk

			SB1->(dbSeek(xFilial("SB1")+SZH->ZH_PRODUTO))
			
			//———————————————————————————————————————————————————————————————————————————————
			// Gera Detalhe - Registro 150 Materiais
			//———————————————————————————————————————————————————————————————————————————————
			cDetalhe := "150"								//01-fixo 150
			cDetalhe += "A"								//02-A-inclui se nao existir ou atualiza se existir
			cDetalhe += Padr(SB1->B1_DESC,40)		//03-descricao do item
			cDetalhe += Padr(SB1->B1_COD,20)			//04-codigo do item
			cDetalhe += Padr(SB1->B1_GRUPO,10)		//05-codigo da categoria
			cDetalhe += Padr(" ",10)					//06-codigo da categoria
			cDetalhe += Padr(SB1->B1_UM,3)			//07-codigo 1a. UM
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
		    	lOk	:= .F.
		        Exit
		    Endif
		
			//———————————————————————————————————————————————————————————————————————————————
			// Gera Detalhe - Registro 160 Itens NF
			//———————————————————————————————————————————————————————————————————————————————
			nPesoB	:= Round(SB1->B1_PESBRU * SZH->ZH_QTDDEVO, 2)
			//nValor	:= SZH->ZH_PRECTOT + SZH->ZH_VLRIPI
			nValor	:= iif(AllTrim(TRB->ZG_ESTCOLE)="RS",SZH->ZH_PRECTOT + SZH->ZH_VLRIPI + SZH->ZH_VALST,SZH->ZH_PRECTOT + SZH->ZH_VLRIPI)//ALTERADO POR EVANDRO- 20/09/2022
			
			cDetalhe := "160"										  		//01-fixo 160
			cDetalhe += "A"												//02-A-inclui se nao existir ou atualiza se existir
			cDetalhe += "0" + PadR(SM0->M0_CGC,14)					//03-identificacao do emitente
			cDetalhe += PadR(TRB->ZG_NFDEVOL,12)					//04-codigo do documento
			cDetalhe += PadR(TRB->ZG_SERIENF,3)						//05-serie do documento
			cDetalhe += PadR(SZH->ZH_ITEM,3)							//06-item do documento
			cDetalhe += Padr(SZH->ZH_PRODUTO,20)					//07-codigo do item
			cDetalhe += StrZero(nValor * 100,12)					//08-valor do item
			cDetalhe += StrZero(nPesoB * 100,15)					//09-peso bruto
			cDetalhe += StrZero(0,15)									//10-peso cubado
			cDetalhe += StrZero(0,15)									//11-peso liquido   
			cDetalhe += StrZero(0,4)									//12-volume
			cDetalhe += StrZero(0,10)									//13-valor cubagem
			cDetalhe += Padr(SB1->B1_CONTA,15)						//14-codigo conta contabil
			cDetalhe += Padr("",10)										//15-codigo centro de custo
			cDetalhe += StrZero(SZH->ZH_QTDDEVO * 100,15)		//16-quantidade da nota fiscal
			cDetalhe += Padr(SB1->B1_UM,3)							//17-UM do item
			cDetalhe += StrZero(0,15)									//18-valor do frete da tabela
			cDetalhe += StrZero(0,15)									//13-valor do frete pago
			cDetalhe += cEol

		    If fWrite(nHdl,cDetalhe,Len(cDetalhe)) != Len(cDetalhe)
		        	lOk	:= .F.
		            Exit
		    Endif

			SZH->(dbSkip())

		Enddo 
		
		If SZG->( dbSeek(xFilial("SZG") + TRB->ZG_NUMERO + TRB->ZG_EMISSAO + TRB->ZG_CLIENTE + TRB->ZG_LOJACLI ) )
			If SZG->( RecLock("SZG",.F.) )
				SZG->ZG_X_EXPGK := "N"
			endif
		endif
		
		TRB->(DbSkip())

	enddo

	FClose(nHdl)

else

	lOk	:= .F.
	
Endif

if Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea()
endif

if lOk

	ConOut(dTOc(Date()) + " as " + Time() + " - BRAJOB12 - Arquivo Gerado com Sucesso! ")

endif

RestArea(aAreaSZG)
RestArea(aAreaSZH)
RestArea(aAreaSB1)
RestArea(aAreaSA1)
RestArea(aArea)

Return() 
