/*/

————————————————————————————————————————————————————————————————————————————————————————————————————
@function		BGKO05                                                     	                    	/@
@type			User function                                      					   				/@
@date			26/01/2016						                                           			/@
@description	Rotina para Exportar Manualmente Documentos de entradas para o GKO.	                /@
				Será utilizado os dados das ARs como base das notas fiscais. 						/@
@				Tabelas (SZG, SZH, SF4, SB1)   														/@
@author			Felipe Varella - Brasitech          			                              			/@
@use			Específico Brasitech                                                          		/@	
————————————————————————————————————————————————————————————————————————————————————————————————————

/*/    
//+------------+---------------+-------+------------------------+------+------------+
//| Função:    | BGKO05      | Alterado por | Jose Mendes     |Data: 04/07/2018   | 
//+------------+---------------+-------+------------------------+------+------------+
//| Descrição: | Foi retirados and no select que impediao gerar notas  
//+------------+--------------------------------------------------------------------+
//|Empresa:    | Brasitech     | 	                           |
//+---------------------------------------------------------------------------------+
                                                                                           
#include "rwmake.ch"
#include "tbiconn.ch"

User Function BGKO05()
Local _cPerg		:= PadR("BRAGKO05",Len(SX1->X1_GRUPO))
Local _aRegs    	:= {}
Local _aCabSX1		:= {"X1_GRUPO","X1_ORDEM","X1_PERGUNT","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_GSC","X1_VAR01","X1_F3"}
Local aSay			:= {}
Local aButton		:= {}
Local nOpc			:= 0
Local cCadastro		:= "Exportação Documentos de Entrada (ARs) para o GKO"
Local aArea			:= GetArea()
Local aAreaSA1		:= SA1->(GetArea())
Local aAreaSB1		:= SB1->(GetArea())
Local aAreaSZG		:= SZG->(GetArea())
Local aAreaSZH		:= SZH->(GetArea())       


//parametros para o processamento
aAdd(_aRegs,{_cPerg,"01", "Exportar p/ o diretorio:",	"mv_ch1","C",40,0,"G","mv_par01",""})
aAdd(_aRegs,{_cPerg,"02", "Da Emissão:",				"mv_ch2","D",08,0,"G","mv_par02",""})
aAdd(_aRegs,{_cPerg,"03", "Até a Emissão:",				"mv_ch3","D",08,0,"G","mv_par03",""})
aAdd(_aRegs,{_cPerg,"04", "Da Nota:",					"mv_ch4","C",09,0,"G","mv_par04",""})
aAdd(_aRegs,{_cPerg,"05", "Até a Nota:",				"mv_ch5","C",09,0,"G","mv_par05",""})
aAdd(_aRegs,{_cPerg,"06", "Da Série:",					"mv_ch6","C",03,0,"G","mv_par06",""})
aAdd(_aRegs,{_cPerg,"07", "Até a Série:",				"mv_ch7","C",03,0,"G","mv_par07",""})
aAdd(_aRegs,{_cPerg,"08", "Da Transport.:",				"mv_ch8","C",06,0,"G","mv_par08","SA4"})
aAdd(_aRegs,{_cPerg,"09", "Até a Transport.:",			"mv_ch9","C",06,0,"G","mv_par09","SA4"})
aAdd(_aRegs,{_cPerg,"10", "Do Cliente:",				"mv_cha","C",Len(SA1->A1_COD),0,"G","mv_par10","SA1"})
aAdd(_aRegs,{_cPerg,"11", "Até o Cliente:",				"mv_chb","C",Len(SA1->A1_COD),0,"G","mv_par11","SA1"})


U_BRASX1(_aRegs,_aCabSX1)

Pergunte(_cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Interface                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd ( aSay , "Exportação de informações de Notificação de Embarque (DNE) para a arquivo texto," )
aAdd ( aSay , "conforme layout INTDNE 5.81b. Atualizado 04/07/2018")
aAdd ( aSay , "Informar o drive e caminho para a gravação do arquivo. O nome será padronizado com" )
aAdd ( aSay , "FRDNE_????.TXT, onde ???? será um número sequêncial." )

aAdd ( aButton , { 1 , .T. , { || nOpc := 1,	FechaBatch()	}} )
aAdd ( aButton , { 2 , .T. , { || FechaBatch()					}} )
aAdd ( aButton , { 5 , .T. , { || Pergunte( _cPerg , .T. )		}} )

FormBatch( cCadastro , aSay , aButton )

If nOpc == 1

	ProcRegua(2) // Numero de processos/sub-processos

	IncProc("Exportando registros para o arquivo texto...")		//1o.

	SET CENTURY ON
	Processa( { |lEnd| ExpGKO() } , "Integração Protheus x GKO" , "Exportando registros para o arquivo texto..." , .T. )
	SET CENTURY OFF

	IncProc("Finalizando processo...")	//2o.
	
Endif   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a posicao original das areas de trabalho ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea( aAreaSA1 )
RestArea( aAreaSB1 )
RestArea( aAreaSZG )
RestArea( aAreaSZH )
RestArea( aArea )
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ ExpGKO       ³ Por: Felipe Varella ³           Data ³26.01.2016³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ExpGKO()
Local cDetalhe
Local cDTEmb		:= ""  
Local cDTEnt		:= ""
Local cEol		:= chr(13) + chr(10)
Local nSeq		:= GetMV("BR_GKOSEQ", .F., 1)
Local cRedesp	:= StrZero( Val( GetMV("BR_GKOREDE", .F., "") ), 15)
Local cArquivo	:= AllTrim(mv_par01) + iif( Right( AllTrim( mv_par01 ), 1 )= "\", "FRDNE_", "\FRDNE_" ) + StrZero(nSeq,6) + ".TXT"
Local lOK		:= .T.
Local nTPesoB, nPesoB, nValor, cPedCli
Local nCubPad	:= getmv("MV_XCUBMAS")

nHdl := Fcreate(cArquivo)

If nHdl == -1
    MsgBox("O arquivo " + cArquivo + " não pode ser criado! Verifique os parâmetros.","Atenção!","ERRO")
    Return()
Endif


PutMV("BR_GKOSEQ",++nSeq)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Seta ordem das tabelas a serem pesquisadas                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA1->(dbSetOrder(1))
SB1->(dbSetOrder(1))
SZG->(dbSetOrder(1))
SZH->(dbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Selecionando registros                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cQuery := 	"SELECT DISTINCT SZG.ZG_NUMERO,SZG.ZG_EMISSAO,SZG.ZG_NFDEVOL, SZG.ZG_SERIENF, SZG.ZG_DTDEVOL, SZG.ZG_CLIENTE, SZG.ZG_LOJACLI,SZG.ZG_FILIAL, "
cQuery += 	"SZG.ZG_DTSOLIC,SZG.ZG_DTCOLE, SZG.ZG_TRANSP, SZG.ZG_VALOR, SZG.ZG_CFOP "
cQuery += 	"FROM " + RetSQLName("SZG") + " SZG , " + RetSQLName("SA4") + " SA4 "
cQuery += 	"WHERE SZG.ZG_FILIAL = '" + xFilial("SZG") + "' AND SZG.D_E_L_E_T_ = ' ' "
cQuery += 	"AND SA4.A4_FILIAL = '" + xFilial("SA4") + "' AND SA4.D_E_L_E_T_ = ' ' "
cQuery += 	"AND SZG.ZG_EMISSAO BETWEEN '" + dTOs(mv_par02) + "' AND '" + dTOs(mv_par03) + "' "
cQuery += 	"AND SZG.ZG_NFDEVOL BETWEEN '" + mv_par04 + "' AND '" + mv_par05 + "' "
cQuery +=	"AND SZG.ZG_SERIENF BETWEEN '" + mv_par06 + "' AND '" + mv_par07 + "' "
cQuery +=	"AND SZG.ZG_TRANSP BETWEEN '" + mv_par08 + "' AND '" + mv_par09 + "' "
cQuery +=	"AND SZG.ZG_CLIENTE BETWEEN '" + mv_par10 + "' AND '" + mv_par11 + "' "
// cQuery +=	"AND SZG.ZG_TRANSP != '' "
cQuery +=	"AND SA4.A4_COD = SZG.ZG_TRANSP "
// cQuery +=	"AND SA4.A4_X_GKO != 'N' "
//cQuery +=	"AND SZG.ZG_NFDEVOL != '' " 
// cQuery +=	"AND ISNUMERIC(ZG_NFDEVOL) = 1 "  //ISNUMERIC RETORNA 1 SE O CAMPO SÓ CONTIVER NUMEROS
cQuery += 	"ORDER BY ZG_NUMERO"


if Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea()
endif
	
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB", .F., .T.)

Memowrite("BGKO05.Sql" , cQuery )

dbSelectArea("TRB")
dbGotop()
if !eof()     

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Gera cabecalho - Registro 000 Identificacao        ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona areas                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SA1->( dbSeek(xFilial("SA1") + TRB->ZG_CLIENTE + TRB->ZG_LOJACLI ) )
		SZH->( dbSeek(xFilial("SZH") + TRB->ZG_NUMERO ) )
		CC2->( dbSeek(xFilial("CC2") + SA1->A1_EST + SA1->A1_COD_MUN ) )
       
		nTPesoB  := 0
		nInteiro := 0 
		nResto	 := 0
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calculando o peso bruto total, pois a Brasitech    ³
		//³ utiliza 4 casas decimais e o GKO aceita somente 2  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cPedCli	:= Space(10)
		do while SZH->(!eof() .and. ZH_FILIAL = TRB->ZG_FILIAL .and. ZH_NUMERO  = TRB->ZG_NUMERO ) .and. lOk
			SB1->(dbSeek(xFilial("SB1")+SZH->ZH_PRODUTO))
			nTPesoB += Round(SB1->B1_PESBRU * SZH->ZH_QTDDEVO, 2)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calculando a quantidade de volumes total
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera Detalhe - Registro 100 Parceiros              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cDetalhe := "100"											//01-tipo registro. fixo 100
		cDetalhe += "A"												//02-tipo operacao A-inclui se nao existir ou altera se existir
		cDetalhe += PadR(SA1->A1_CGC,15)							//03-CNPJ do emitente da nota fiscal
		cDetalhe += "2"												//04-tipo de parceiro comercial 2-cliente
		cDetalhe += PadR(SA1->A1_COD + SA1->A1_LOJA,14)				//05-codigo do parceiro comercial
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
		cDetalhe += "0"												//17-sttus se o fornecedor emitente da NF eh optante pelo regime de credito de ICMS
		cDetalhe += "0"												//18-status indicando que devera excluir as referencias externas
		cDetalhe += cEol
		
	    If fWrite(nHdl,cDetalhe,Len(cDetalhe)) != Len(cDetalhe)
	        If !MsgBox("Ocorreu um erro na gravacao do arquivo. Continua?","Pergunta","YESNO")
	        	lOk	:= .F.
	            Exit
	        Endif
	    Endif                     

		//cDTEnt	:= IIf(!empty(TRB->ZG_DTDEVOL),PadR(dTOc(TRB->ZG_DTDEVOL),10), PadR(SUBSTR(TRB->ZG_EMISSAO,7,2)+"/"+SUBSTR(TRB->ZG_EMISSAO,5,2)+"/"+SUBSTR(TRB->ZG_EMISSAO,1,4),10))
		//cDTEmb	:= IIf(!empty(TRB->ZG_DTCOLE),PadR(SUBSTR(TRB->ZG_DTCOLE,7,2)+"/"+SUBSTR(TRB->ZG_DTCOLE,5,2)+"/"+SUBSTR(TRB->ZG_DTCOLE,1,4),10),space(10))
		
		//MODIFICADO DIA 03/06 POR LUIZ FERNANDO A PEDIDO DO MARCELO 
		//cDTEnt	:= IIf(!empty(TRB->ZG_DTDEVOL),PadR(SUBSTR(TRB->ZG_DTDEVOL,7,2)+"/"+SUBSTR(TRB->ZG_DTDEVOL,5,2)+"/"+SUBSTR(TRB->ZG_DTDEVOL,1,4),10),; 
		//PadR(SUBSTR(TRB->ZG_EMISSAO,7,2)+"/"+SUBSTR(TRB->ZG_EMISSAO,5,2)+"/"+SUBSTR(TRB->ZG_EMISSAO,1,4),10))
		
		cDTEnt	:= IIf(!empty(TRB->ZG_DTSOLIC),PadR(SUBSTR(TRB->ZG_DTSOLIC,7,2)+"/"+SUBSTR(TRB->ZG_DTSOLIC,5,2)+"/"+SUBSTR(TRB->ZG_DTSOLIC,1,4),10),; 
		PadR(SUBSTR(TRB->ZG_DTDEVOL,7,2)+"/"+SUBSTR(TRB->ZG_DTDEVOL,5,2)+"/"+SUBSTR(TRB->ZG_DTDEVOL,1,4),10))
		
		cDTEmb	:= IIf(!empty(TRB->ZG_DTCOLE),PadR(SUBSTR(TRB->ZG_DTCOLE,7,2)+"/"+SUBSTR(TRB->ZG_DTCOLE,5,2)+"/"+SUBSTR(TRB->ZG_DTCOLE,1,4),10),;
		PadR(SUBSTR(dtos(ddatabase),7,2)+"/"+SUBSTR(dtos(ddatabase),5,2)+"/"+SUBSTR(dtos(ddatabase),1,4),10))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Gera Detalhe - Registro 140 Cabecalho de Doc (NF)    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cDetalhe := "140"									//01-tipo registro. fixo 140
		cDetalhe += "A"									//02-tipo operacao A-inclui se nao existir ou alterase existir
		cDetalhe += "1"									//03-tipo de docto 1-nota fiscal
		cDetalhe += "0" + PadR(SA1->A1_CGC,14)		//04-Parceiro comercial
		cDetalhe += PadR(TRB->ZG_NFDEVOL,12)		//05-codigo do documento
		cDetalhe += PadR(TRB->ZG_SERIENF,3)			//06-serie do documento
		cDetalhe += cDTEnt								//07-data de emissao
//		cDetalhe += cDTEmb								//08-data de embarque
		cDetalhe += cDTEnt								//08-data de embarque
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
		cDetalhe += cEol

	    If fWrite(nHdl,cDetalhe,Len(cDetalhe)) != Len(cDetalhe)
	        If !MsgBox("Ocorreu um erro na gravacao do arquivo. Continua?","Pergunta","YESNO")
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
		cDetalhe += PadR(TRB->ZG_NFDEVOL,12)						//03-(OBR) codigo do documento
		cDetalhe += PadR(TRB->ZG_SERIENF,3)							//04-serie do documento
		cDetalhe += "99"											//05-(OBR) Numero de ordem do redespacho
		cDetalhe += StrZero( Val(cRedesp),15)						//06-(OBR) identificacao do local de redespacho
		cDetalhe +=	PadR(TRB->ZG_TRANSP,15)							//07-codigo da transportadora de redespacho
		cDetalhe += "2" 											//08-tipo de frete do redespacho do segundo trecho
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
	        If !MsgBox("Ocorreu um erro na gravacao do arquivo. Continua?","Pergunta","YESNO")
		        lOk	:= .F.
	            Exit
	        Endif
	    Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Dados para Registro 150 e 160 - Itens da Nf (SZH)    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SZH->( dbSeek(xFilial("SZH") + TRB->ZG_NUMERO ) )
		do while SZH->(!eof() .and. ZH_FILIAL = TRB->ZG_FILIAL .and. ZH_NUMERO = TRB->ZG_NUMERO ) .and. lOk

			SB1->(dbSeek(xFilial("SB1")+SZH->ZH_PRODUTO))
						
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera Detalhe - Registro 150 Materiais                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cDetalhe := "150"							//01-fixo 150
			cDetalhe += "A"								//02-A-inclui se nao existir ou atualiza se existir
			cDetalhe += Padr(SB1->B1_DESC,40)			//03-descricao do item
			cDetalhe += Padr(SB1->B1_COD,20)			//04-codigo do item
			cDetalhe += Padr(SB1->B1_GRUPO,10)			//05-codigo da categoria
			cDetalhe += Padr(" ",10)					//06-codigo da categoria
			cDetalhe += Padr(SB1->B1_UM,3)				//07-codigo 1a. UM
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
			nPesoB	:= Round(SB1->B1_PESBRU * SZH->ZH_QTDDEVO, 2)
			nValor	:= SZH->ZH_PRECTOT + SZH->ZH_VLRIPI
			
			cDetalhe := "160"											//01-fixo 160
			cDetalhe += "A"												//02-A-inclui se nao existir ou atualiza se existir
			cDetalhe += "0" + PadR(SM0->M0_CGC,14)						//03-identificacao do emitente
			cDetalhe += PadR(TRB->ZG_NFDEVOL,12)						//04-codigo do documento
			cDetalhe += PadR(TRB->ZG_SERIENF,3)							//05-serie do documento
			cDetalhe += PadR(SZH->ZH_ITEM,3)							//06-item do documento
			cDetalhe += Padr(SZH->ZH_PRODUTO,20)						//07-codigo do item
			cDetalhe += StrZero(nValor * 100,12)						//08-valor do item
			cDetalhe += StrZero(nPesoB * 100,15)						//09-peso bruto
			cDetalhe += StrZero(0,15)									//10-peso cubado
			cDetalhe += StrZero(0,15)									//11-peso liquido   
			cDetalhe += StrZero(0,4)									//12-volume
			cDetalhe += StrZero(0,10)									//13-valor cubagem
			cDetalhe += Padr(SB1->B1_CONTA,15)							//14-codigo conta contabil
			cDetalhe += Padr("",10)										//15-codigo centro de custo
			cDetalhe += StrZero(SZH->ZH_QTDDEVO * 100,15)				//16-quantidade da nota fiscal
			cDetalhe += Padr(SB1->B1_UM,3)								//17-UM do item
			cDetalhe += StrZero(0,15)									//18-valor do frete da tabela
			cDetalhe += StrZero(0,15)									//13-valor do frete pago
			cDetalhe += cEol

		    If fWrite(nHdl,cDetalhe,Len(cDetalhe)) != Len(cDetalhe)
		        If !MsgBox("Ocorreu um erro na gravacao do arquivo. Continua?","Pergunta","YESNO")
		        	lOk	:= .F.
		            Exit
		        Endif
		    Endif

			SZH->(dbSkip())

		Enddo
		
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

	MsgBox("O arquivo " + cArquivo + " foi criado com sucesso!","Informação","INFO")

else

	MsgBox("Não foi encontrado registros dentro dos parâmetros informados.","Informação","INFO")
//	fErase(cArquivo)

endif

Return()