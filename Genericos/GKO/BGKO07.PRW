//+------------+---------------+-------+------------------------+------+------------+
//| Função:    | BGKO07()     | Autor | Jose Mendes            |Data: 10/06/2018   | 
//+------------+---------------+-------+------------------------+------+------------+
//| Descrição: | Exportação de Notas Gko para a arquivo texto em diretorio especificado
//|
//+------------+--------------------------------------------------------------------+
//|Chamado: 9360  
//+---------------------------------------------------------------------------------+                                                                                               
#include "rwmake.ch"
#include "tbiconn.ch"

User Function BGKO07()
Local _cPerg		:= PadR("BRAGKO07",Len(SX1->X1_GRUPO))
Local _aRegs    	:= {}
Local _aCabSX1		:= {"X1_GRUPO","X1_ORDEM","X1_PERGUNT","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_GSC","X1_VAR01","X1_F3"}
Local aSay			:= {}
Local aButton		:= {}
Local nOpc			:= 0
Local cCadastro		:= "Integração GKO"
Local cDTEmb		:= ""
Local aArea			:= GetArea()
Local aAreaSF2		:= SF2->(GetArea())
Local aAreaSD2		:= SD2->(GetArea())
Local aAreaSB1		:= SB1->(GetArea())
Local aAreaSA1		:= SA1->(GetArea())

//parametros para o processamento
aAdd(_aRegs,{_cPerg,"01", "Exportar p/ o diretorio:",	"mv_ch1","C",40,0,"G","mv_par01",""})
aAdd(_aRegs,{_cPerg,"04", "Da Nota:",					"mv_ch2","C",09,0,"G","mv_par02",""})



U_BRASX1(_aRegs,_aCabSX1)

Pergunte(_cPerg,.F.)


aAdd ( aSay , "Exportação de Notas Gko para a arquivo texto," )
aAdd ( aSay , "Informar o drive e caminho para a gravação do arquivo. O nome será padronizado com" )
aAdd ( aSay , "FRDNE_????.TXT, onde ???? será um número sequêncial." )

aAdd ( aButton , { 1 , .T. , { || nOpc := 1,	FechaBatch()	}} )
aAdd ( aButton , { 2 , .T. , { || FechaBatch()					}} )
aAdd ( aButton , { 5 , .T. , { || Pergunte( _cPerg , .T. )		}} )

FormBatch( cCadastro , aSay , aButton )

If nOpc == 1

	ProcRegua(2) 

	IncProc("Exportando registros......")		//1o.

	SET CENTURY ON
	Processa( { |lEnd| Expfigko() } , "Gerar Nfs GKO" , "Exportando registros ..." , .T. )
	SET CENTURY OFF

	IncProc("Finalizando processo...")	//2o.
	
Endif   

RestArea( aAreaSF2 )
RestArea( aAreaSD2 )
RestArea( aAreaSB1 )
RestArea( aAreaSA1 )
RestArea( aArea )
Return()

//+------------+---------------+-------+------------------------+------+------------+
//| Função:    | expfigko     | Autor | Jose Mendes            |Data: 10/06/2018   | 
//+------------+---------------+-------+------------------------+------+------------+
//| Descrição: | Exportação de Notas Gko para a arquivo texto em diretorio especificado
//|
//+------------+--------------------------------------------------------------------+
//|Chamado:   9360
//+---------------------------------------------------------------------------------+           
Static Function Expfigko()
Local cDetalhe
Local cEol		:= chr(13) + chr(10)
Local nSeq		:= GetMV("BR_GKOSEQ", .F., 1)
Local cRedesp	:= StrZero( Val( GetMV("BR_GKOREDE", .F., "") ), 15)
Local cArquivo	:= AllTrim(mv_par01) + iif( Right( AllTrim( mv_par01 ), 1 )= "\", "FRDNE_", "\FRDNE_" ) + StrZero(nSeq,6) + ".TXT"
Local lOK		:= .T.
Local nTPesoB, nPesoB, nValor, cPedCli
Local nOcorr	:= 0
Local dDtOcorr	:= ""

nHdl := Fcreate(cArquivo)

If nHdl == -1
    MsgBox("O arquivo " + cArquivo + " não pode ser criado! Verifique os parâmetros.","Atenção!","ERRO")
    Return()
Endif


PutMV("BR_GKOSEQ",++nSeq)

SA1->(dbSetOrder(1))
SB1->(dbSetOrder(1))
SC5->(dbSetOrder(1))
SD2->(dbSetOrder(3))
CC2->(dbSetOrder(1))
SC6->(dbSetOrder(2))


cQuery := 	"SELECT DISTINCT *, SA4.A4_XPEDCLI,SA4.A4_VIA "
cQuery += 	"FROM " + RetSQLName("SF2") + " SF2, " + RetSQLName("SA4") + " SA4, " + RetSQLName("SD2") + " SD2, "
cQuery += 	"WHERE SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND SF2.F2_TIPO IN ('N','B') "
cQuery +=	"AND SF2.F2_DOC = '" + mv_par02 + "' "
cQuery +=	"AND SF2.F2_TRANSP != '      ' "
cQuery +=	"AND SF2.D_E_L_E_T_ = ' ' "
cQuery +=	"AND SA4.A4_FILIAL = '" + xFilial("SA4") + "' "
cQuery +=	"AND SA4.A4_COD = SF2.F2_TRANSP " 
cQuery +=	"AND SA4.D_E_L_E_T_=' ' "
cQuery +=	"AND SF2.F2_DOC = SD2.D2_DOC "
cQuery +=	"AND SF2.F2_SERIE = SD2.D2_SERIE "
cQuery +=	"AND SF2.F2_FILIAL = SD2.D2_FILIAL "
cQuery += 	"ORDER BY F2_SERIE, F2_DOC"

if Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea()
endif
	
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB", .F., .T.)
tcSetField("TRB", "F2_EMISSAO", "D")

Memowrite("BGKO07.Sql" , cQuery )

dbSelectArea("TRB")
dbGotop()
if !eof()
  
   //³ Gera cabecalho Identificacao       
  
	cDetalhe := "000"
	cDetalhe += PadR("INTDNE",10)
	cDetalhe += PadR("5.81a",6)
	cDetalhe += PadR(SM0->M0_NOMECOM,40)
	cDetalhe += PadR("GKO",40)
	cDetalhe += "101"
	cDetalhe += cEol

    If fWrite(nHdl,cDetalhe,Len(cDetalhe)) != Len(cDetalhe)
        If !MsgBox("Ocorreu um erro na gravacao do arquivo. Continua?","Pergunta","YESNO")
        	lOk := .F.
        Endif
    Endif

	Do While !Eof() .and. lOk

		
		//³ Posiciona areas                                   
		
		SA1->( dbSeek(xFilial("SA1") + TRB->F2_CLIENTE + TRB->F2_LOJA ) )
		SD2->( dbSeek(xFilial("SD2") + TRB->F2_DOC + TRB->F2_SERIE + TRB->F2_CLIENTE + TRB->F2_LOJA ) )
		CC2->( dbSeek(xFilial("CC2") + SA1->A1_EST + SA1->A1_COD_MUN ) )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calculando o peso bruto total, pois a Brasitech    ³
		//³ utiliza 4 casas decimais e o GKO aceita somente 2  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nTPesoB := 0
		cPedCli	:= Space(10)
		do while SD2->(!eof() .and. D2_FILIAL = TRB->F2_FILIAL .and. D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA = TRB->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA) ) .and. lOk
			SB1->(dbSeek(xFilial("SB1")+SD2->D2_COD))
			SC6->(dbSeek(xFilial("SC6")+SD2->D2_COD+SD2->D2_PEDIDO+SD2->D2_ITEMPV))
			nTPesoB += Round(SB1->B1_PESBRU * SD2->D2_QUANT, 2)
			cPedCli := SC6->C6_PEDCLI
			SD2->(dbSkip())
		Enddo
		
		do while SD2->(!eof() .and. D2_FILIAL = TRB->F2_FILIAL .and. D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA = TRB->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA) ) .and. lOk
			SB1->(dbSeek(xFilial("SB1")+SD2->D2_COD))
			nTPesoB += Round(SB1->B1_PESBRU * SD2->D2_QUANT, 2)
			SD2->(dbSkip())
		Enddo		
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera Detalhe - Registro 100 Parceiros              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cDetalhe := "100"											//01-tipo registro. fixo 100
		cDetalhe += "A"												//02-tipo operacao A-inclui se nao existir ou alterase existir
		cDetalhe += PadR(SA1->A1_CGC,15)							//03-numero CNPJ se PJ ou CPF se PF
		cDetalhe += "2"												//04-tipo de parceiro comercial 2-cliente
		cDetalhe += PadR(SA1->A1_COD + SA1->A1_LOJA,14)			//05-codigo do parceiro comercial
		cDetalhe += PadR(SA1->A1_NOME,40)							//06-razao social
		cDetalhe += PadR(SA1->A1_END,50)							//07-endereco
		cDetalhe += PadR(SA1->A1_BAIRRO,20)							//08-bairro
		cDetalhe += PadR(CC2->CC2_MUN,30)							//09-municipio	PadR(SA1->A1_MUN,30)
		cDetalhe += SA1->A1_EST										//10-UF
		cDetalhe += SA1->A1_CEP										//11-CEP
		cDetalhe += Space(10)										//12-zona de transporte
		cDetalhe += iif(Len(AllTrim(SA1->A1_CGC))=14,"2","1")		//13-tipo de pessoa, 1-fisica, 2-juridica
		cDetalhe += PadR(SA1->A1_INSCRM,15)							//14-inscricao municipal
		cDetalhe += PadR(SA1->A1_INSCR,15)							//15-inscricao estadual
		cDetalhe += iif(Empty(SA1->A1_INSCR),"0","1")				//16-indica se parceiro eh contribuinte do ICMS
		cDetalhe += "0"									//PERGUNTAR	//17-sttus se o fornecedor emitente da NF eh optante pelo regime de credito de ICMS
		cDetalhe += "0"												//18-status indicando que devera excluir as referencias externas
		cDetalhe += cEol
		
	    If fWrite(nHdl,cDetalhe,Len(cDetalhe)) != Len(cDetalhe)
	        If !MsgBox("Ocorreu um erro na gravacao do arquivo. Continua?","Pergunta","YESNO")
	        	lOk	:= .F.
	            Exit
	        Endif
	    Endif
		
		IF Empty(TRB->F2_X_COLET)
			cDtEmb	:= PadR(iif(TRB->F2_X_OPLOG = 'ON',DTOC(dDataBase),""),10)
			ELSE
			cDTEmb	:= PadR(SUBSTR(TRB->F2_X_COLET,7,2)+"/"+SUBSTR(TRB->F2_X_COLET,5,2)+"/"+SUBSTR(TRB->F2_X_COLET,1,4),10)
		ENDIF
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera Detalhe - Registro 140 Cabecalho de Doc (NF)    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cDetalhe := "140"																			//01-tipo registro. fixo 140
		cDetalhe += "A"																				//02-tipo operacao A-inclui se nao existir ou alterase existir
		cDetalhe += "1"																				//03-tipo de docto 1-nota fiscal
		cDetalhe += "0" + PadR(SM0->M0_CGC,14)														//04-Parceiro comercial
		cDetalhe += PadR(TRB->F2_DOC,12)															//05-codigo do documento
		cDetalhe += PadR(TRB->F2_SERIE,3)															//06-serie do documento
		cDetalhe += PadR(dTOc(TRB->F2_EMISSAO),10)													//07-data de emissao
//		cDetalhe += PadR(dTOc(TRB->F2_EMISSAO),10)										//PERGUNTAR	//08-data de embarque
		//cDetalhe += PadR(iif(Empty(TRB->F2_X_COLET),"",SUBSTR(TRB->F2_X_COLET,7,2)+"/"+SUBSTR(TRB->F2_X_COLET,5,2)+"/"+SUBSTR(TRB->F2_X_COLET,1,4)),10) 	//08-data de embarque
		cDetalhe += cDTEmb
		cDetalhe += "2"												//09-para nota de saida (2)
		cDetalhe += PadR(SA1->A1_CGC,15)							//10-identificacao do destinatario
		cDetalhe += PadR(SA1->A1_END,50)							//11-dados destinatario
		cDetalhe += PadR(SA1->A1_BAIRRO,20)							//12-dados destinatario
		cDetalhe += PadR(CC2->CC2_MUN,30)							//13-dados destinatario PadR(SA1->A1_MUN,30)
		cDetalhe += SA1->A1_EST										//14-dados destinatario
		cDetalhe += SA1->A1_CEP										//15-dados destinatario
		cDetalhe += Space(10)										//16-codigo zona de transporte
		cDetalhe += Space(12)							//PERGUNTAR	//17-codigo identif.docto negociacao frete
		cDetalhe += PadR("VEND",4) 						//PERGUNTAR	//18-codigo do tipo da nota
		cDetalhe += Space(10) 							//PERGUNTAR	//19-codigo equipamento (truck, bau, container)
		cDetalhe += Space(4)							//PERGUNTAR	//20-codigo embalagem
		cDetalhe += Padr(TRB->A4_VIA,4)								//21-codigo meio de transporte
		cDetalhe += Space(10)										//22-territorio
		cDetalhe += iif(TRB->A4_XPEDCLI = 'S',PadR(cPedCli,10),space(10))	//23-Separador Conhecimento
		cDetalhe += Space(20)										//24-codigo lote
		cDetalhe += Space(10)										//25-romaneio
		//cDetalhe += PadR(TRB->F2_TRANSP,15)							//26-codigo transportadora
		cDetalhe += iif(!Empty(SF2->F2_XGKOTRA), PadR(SF2->F2_XGKOTRA,15), PadR(SF2->F2_TRANSP,15))				//26-codigo transportadora
		cDetalhe += "1"									//PERGUNTAR	//27-tipo de frete 1-CIF, 2-FOB
		cDetalhe += PadR(TRB->F2_DOC,12)							//28-Numero ordem de embarque qdo (03-) for igual a 1
		cDetalhe += PadR(TRB->F2_SERIE,3)							//29-serie documento vinculado
		cDetalhe += PadR(SD2->D2_CF,6)								//30-natureza da operacao
		cDetalhe += "0"												//31-isento de ICMS 1-SIM OU 0-NAO ISENTO DE ICMS
		cDetalhe += "0"												//32-possui credito de ICMS 1-SIM OU 0-NAO POSSUI CREDITO DE ICMS
		cDetalhe += "0"												//33-teve substituicao tributaria 1-SIM OU 0-NAO POSSUIU ICMS ST NA ENTRADA
		cDetalhe += "3"												//34-finalidade do produto 1-CONSUMO FNAL, 2-INDUSTRIALIZACAO, 3-COMERCIALIZACAO, 5-REVENDA
		cDetalhe += StrZero(nTPesoB * 100,15)						//35-peso bruto  StrZero(TRB->F2_PBRUTO*100,15)
		cDetalhe += Space(15)										//36-peso cubado
		cDetalhe += StrZero(0,15)									//37-peso liquido StrZero(TRB->F2_PLIQUI*100,15)
		cDetalhe += StrZero(TRB->F2_VOLUME1,6)						//38-qtde volume
		cDetalhe += StrZero(0,15)									//39-outros valores nao inclusos nos itens do documento
		cDetalhe += PadR(" ",10)									//40-codigo indicador financeiro qdo NF estiver em US$
		cDetalhe += "0"												//41-Entrega urgente
		cDetalhe += " "												//42-indica se DNE possui frete diferenciado
		cDetalhe += PadR(" ",10)									//43-data de entrega
		cDetalhe += PadR(" ",15)									//44-responsavel pelo frete do documento
		cDetalhe += PadR(" ",10)									//45-data de referencia para calculodo frete
		cDetalhe += PadR(" ",10)									//46-data de previsao de entrega
		cDetalhe += StrZero(0,15)									//47-valor do frete pago pelo cliente
		cDetalhe += "1"												//48-Status da DNE 1-normal 2-cancelado
		cDetalhe += " "												//49-Status
		cDetalhe += "1"												//50-Status
		cDetalhe += PadR(TRB->ZG_CHVNFE,44)			                //51-Chave da Nfe
		cDetalhe += cEol

	    If fWrite(nHdl,cDetalhe,Len(cDetalhe)) != Len(cDetalhe)
	        If !MsgBox("Ocorreu um erro na gravacao do arquivo. Continua?","Pergunta","YESNO")
		        lOk	:= .F.
	            Exit
	        Endif
	    Endif

		//Ocorrencia de bloqueios das notas fiscais. 104 = Bloqueio comercial / 105 = Bloqueio logistico
		If substring(TRB->F2_X_OPLOG,2,1) = 'S' 
			nOcorr	:= 104
			dDtOcorr	:= TRB->F2_EMISSAO
		ElseIf substring(TRB->F2_X_OPLOG,1,1) = 'S'
			nOcorr   := 105
			dDtOcorr := Iif(!empty(TRB->F2_X_DBLQ2),stod(substring(TRB->F2_X_DBLQ2,1,8)) ,TRB->F2_EMISSAO)
		ElseIf (TRB->F2_X_OPLOG) = 'NN' .and. (!empty(TRB->F2_X_DBLQ1) .or. !empty(TRB->F2_X_DBLQ2))
			nOcorr   	:= 107
			dDtOcorr 	:= Iif(stod(substring(TRB->F2_X_DBLQ1,1,8)) > stod(substring(TRB->F2_X_DBLQ2,1,8)) ,stod(substring(TRB->F2_X_DBLQ1,1,8)) ,stod(substring(TRB->F2_X_DBLQ2,1,8)))
		Else
			nOcorr := 0
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Dados de Ocorrência - Registro 143                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nOcorr > 0 
			cDetalhe := "143"
			cDetalhe += "A"		
			cDetalhe += strzero(nOcorr,5)
			cDetalhe += dtoc(dDtOcorr)
			cDetalhe += cEol
		
		    If fWrite(nHdl,cDetalhe,Len(cDetalhe)) != Len(cDetalhe)
				lOk	:= .F.
		        Exit
		    Endif
		    
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera registro de Redespacho - 147                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cDetalhe := "147"											//tipo registro. fixo 147
		cDetalhe += "A"												//01-(OBR) tipo operacao A-inclui se nao existir ou alterase existir
		cDetalhe += StrZero( Val(SM0->M0_CGC),15)					//02-(OBR) parceiro comercial
		cDetalhe += PadR(TRB->F2_DOC,12)							//03-(OBR) codigo do documento
		cDetalhe += PadR(TRB->F2_SERIE,3)							//04-serie do documento
		cDetalhe += "00"											//05-(OBR) Numero de ordem do redespacho
		cDetalhe += StrZero( Val(cRedesp),15)						//06-(OBR) identificacao do local de redespacho
		//cDetalhe +=	PadR(TRB->F2_TRANSP,15)							//07-codigo da transportadora de redespacho
		cDetalhe += iif(!Empty(SF2->F2_XGKOTRA), PadR(SF2->F2_XGKOTRA,15), PadR(SF2->F2_TRANSP,15)) //07-codigo da transportadora de redespacho
		cDetalhe += "1" 											//08-tipo de frete do redespacho do segundo trecho
		cDetalhe += Padr(TRB->A4_VIA,4)								//09-codigo do meio de transporte
		cDetalhe += iif(TRB->A4_XPEDCLI = 'S',PadR(cPedCli,10),space(10))	//10-Separador Conhecimento
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
	        If !MsgBox("Ocorreu um erro na gravacao do arquivo. Continua?","Pergunta","YESNO")
		        lOk	:= .F.
	            Exit
	        Endif
	    Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Dados para Registro 150 e 160 - Itens da Nf (SD2)    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SD2->( dbSeek(xFilial("SD2") + TRB->F2_DOC + TRB->F2_SERIE + TRB->F2_CLIENTE + TRB->F2_LOJA ) )
		do while SD2->(!eof() .and. D2_FILIAL = TRB->F2_FILIAL .and. D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA = TRB->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA) ) .and. lOk

			SB1->(dbSeek(xFilial("SB1")+SD2->D2_COD))
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera Detalhe - Registro 150 Materiais                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cDetalhe := "150"							//01-fixo 150
			cDetalhe += "A"								//02-A-inclui se nao existir ou atualiza se existir
			cDetalhe += Padr(SB1->B1_DESC,40)			//03-descricao do item
			cDetalhe += Padr(SD2->D2_COD,20)			//04-codigo do item
			cDetalhe += Padr(SD2->D2_GRUPO,10)			//05-codigo da categoria
			cDetalhe += Padr(" ",10)					//06-codigo da categoria
			cDetalhe += Padr(SD2->D2_UM,3)				//07-codigo 1a. UM
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
		        If !MsgBox("Ocorreu um erro na gravacao do arquivo. Continua?","Pergunta","YESNO")
		        	lOk	:= .F.
		            Exit
		        Endif
		    Endif
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera Detalhe - Registro 160 Itens NF                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPesoB	:= Round(SB1->B1_PESBRU * SD2->D2_QUANT, 2)
			//nValor	:= SD2->D2_TOTAL + SD2->D2_VALIPI + SD2->D2_ICMSRET
			nValor	:= SD2->D2_VALBRUT
			
			cDetalhe := "160"											//01-fixo 160
			cDetalhe += "A"												//02-A-inclui se nao existir ou atualiza se existir
			cDetalhe += "0" + PadR(SM0->M0_CGC,14)						//03-identificacao do emitente
			cDetalhe += PadR(TRB->F2_DOC,12)							//04-codigo do documento
			cDetalhe += PadR(TRB->F2_SERIE,3)							//05-serie do documento
			cDetalhe += PadR(SD2->D2_ITEM,3)							//06-item do documento
			cDetalhe += Padr(SD2->D2_COD,20)							//07-codigo do item
			cDetalhe += StrZero(nValor * 100,12)						//08-valor do item
			cDetalhe += StrZero(nPesoB * 100,15)						//09-peso bruto
			cDetalhe += StrZero(0,15)									//10-peso cubado
			cDetalhe += StrZero(0,15)									//11-peso liquido   StrZero((SD2->D2_PESO*SD2->D2_QUANT)*100,15)
			cDetalhe += StrZero(0,4)									//12-volume
			cDetalhe += StrZero(0,10)									//13-valor cubagem
			cDetalhe += Padr(SD2->D2_CONTA,15)							//14-codigo conta contabil
			cDetalhe += Padr(SD2->D2_CCUSTO,10)							//15-codigo centro de custo
			cDetalhe += StrZero(SD2->D2_QUANT * 100,15)				//16-quantidade da nota fiscal
			cDetalhe += Padr(SD2->D2_UM,3)								//17-UM do item
			cDetalhe += StrZero(0,15)									//18-valor do frete da tabela
			cDetalhe += StrZero(0,15)									//13-valor do frete pago
			cDetalhe += cEol

		    If fWrite(nHdl,cDetalhe,Len(cDetalhe)) != Len(cDetalhe)
		        If !MsgBox("Ocorreu um erro na gravacao do arquivo. Continua?","Pergunta","YESNO")
		        	lOk	:= .F.
		            Exit
		        Endif
		    Endif

			SD2->(dbSkip())

		Enddo
		
		TRB->(DbSkip())

	enddo

else

	lOk	:= .F.
	
Endif

FClose(nHdl)

if Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea()
endif

if lOk

	MsgBox("O arquivo " + cArquivo + " foi criado com sucesso!","Informação","INFO")
	
else

	MsgBox("Não foi encontrado registros dentro dos parâmetros informados.","Informação","INFO")
//	fErase(cArquivo)
endif

Return()
