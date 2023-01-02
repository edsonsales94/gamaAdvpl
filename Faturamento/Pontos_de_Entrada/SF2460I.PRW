#Include "RwMake.ch"
#include "protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		                                                      /@
@type			Ponto de entrada                                             /@
@date			10/12/2009                                                   /@
@description	Executado após a gravação da nota fiscal de saída.           /@
@author			Cristiano Figueiroa                                          /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function SF2460I()
Local aArea		:= GetArea()
Local cCliArm 	:= getmv("MV_XFOREDI")
Local cLojArm 	:= getmv("MV_XLOJEDI")

//———————————————————————————————————————————————————————————————————————————————
// Procedimentos diversos
//———————————————————————————————————————————————————————————————————————————————
J_()		//Primeiro processo. Não alterar a ordem de execucao

//———————————————————————————————————————————————————————————————————————————————
// Gravar informacoes sobre exportacoes na tabela CDL para o preenchimento da TAG 
// referente a exportacoes na SPED NFe.                              
// por SI8401 Adalberto Moreno em 12/12/10                           
//———————————————————————————————————————————————————————————————————————————————
if SF2->F2_EST = "EX" .and. !SF2->F2_TIPO $ "DB"

	A_()

endif

//———————————————————————————————————————————————————————————————————————————————
// Bloqueia nota fiscal (campo especifico F2_X_OPLOG), a partir de informacoes de
// agendamento com o cliente e motivos  diversos (que sera informado no pedido de
// venda)                                            
// F2_X_OPLOG = XX                                     
//              |+-> indica bloqueios diversos pelo pedido (S/N)            
//              +--> indica bloqueio por agendamento (S/N)                  
// por Adalberto Moreno Batista em 05/12/12                                 
//———————————————————————————————————————————————————————————————————————————————
if SF2->F2_TIPO $ "NB" .and.;
	SF2->(FieldPos("F2_X_OPLOG")) > 0 .and.;
	SA1->(FieldPos("A1_X_AGEND")) > 0 .and.;
	SC5->(FieldPos("C5_X_BLARQ")) > 0

	B_()
endif

//———————————————————————————————————————————————————————————————————————————————
// Grava os campos F2_VOLUME1 e F2_ESPECI1 de acordo com o calculo de unidades 
// por caixa master, e os fracionados de acordo com a cubagem de cada item.
// Campos especificos no cadastro de produtos: B1_X_QTCXM, B1_XMETCUB
// por Adalberto Moreno Batista em 07/11/12
//———————————————————————————————————————————————————————————————————————————————
if SF2->F2_TIPO $ "NDB" .and.;
	SB1->(FieldPos("B1_X_QTCXM")) > 0 .and.;
	SB1->(FieldPos("B1_XMETCUB")) > 0

	C_()
endif

//———————————————————————————————————————————————————————————————————————————————
// Grava a informacao de unidade de negocio (GAMA/BRAUN), definido no cadastro 
// de produtos, em campos especificos no cabecalho da nota (SF2)e nos titulos a
// receber (SE1)                                              
// por Adalberto Moreno Batista em 10/06/13                   
//———————————————————————————————————————————————————————————————————————————————
if SB1->(FieldPos("B1_XNEGOCI")) > 0
	D_()
endif

//———————————————————————————————————————————————————————————————————————————————
// Gravar informacoes sobre VPC a partir de indicacoes no pedido de vendas  
// por SI8401 Adalberto Moreno em 07/01/12                                  
//———————————————————————————————————————————————————————————————————————————————
if	SF2->F2_TIPO $ "NCIP" .and.;
	SC5->(FieldPos("C5_X_CTVPC")) > 0 .and.;
	SC5->(FieldPos("C5_X_VPCAV")) > 0

	E_()
endif

//———————————————————————————————————————————————————————————————————————————————
// Gravar informacoes do pré-pedido nos itens da nota fiscal                
// por Adalberto Moreno Batista em 15/07/13                                 
//———————————————————————————————————————————————————————————————————————————————
if	SF2->F2_TIPO $ "NCIP" .and.;
	SD2->(FieldPos("D2_X_NUMZL")) > 0 .and.;
	SD2->(FieldPos("D2_X_ITEZL")) > 0

	F_()
endif

//———————————————————————————————————————————————————————————————————————————————
// Efetua transferência entre armazem caso seja nota de remessa dem
// MV_XFOREDI / MV_XLOJEDI -> Parâmetros com codigo e loja do Operador Logistico
// CFOP de remessa de  = 6905 
// por Luiz Fernando em 29/08/14                                 
//———————————————————————————————————————————————————————————————————————————————
if	SF2->F2_TIPO == "B" .and. SF2->F2_CLIENTE == cCliArm .and. SF2->F2_LOJA == cLojArm
	G_()
endif

//—————————————————————————————————————————————————————————————————————————————
// Realiza troca entre vendedor e vendedor alternativo no cadastro do cliente
// se tipo de venda ZL_ATTCLI = NORMAL e Tipo de usuário web ZL_TPACESS = TVEND
// se o ultimo pedido pro mesmo cliente que foi feito por representante 
// ZL_TPACESS <> TVEND
// por Luiz Fernando em 07/11/14                                 
//—————————————————————————————————————————————————————————————————————————————
if	SD2->(FieldPos("D2_X_NUMZL")) > 0
	H_()
endif

//———————————————————————————————————————————————————————————————————————————————
// Grava registro histórico de datas de vencimento de títulos a receber
// por Adalberto Moreno Batista em 15/07/13                                 
//———————————————————————————————————————————————————————————————————————————————
if	SE1->(FieldPos("E1_XVCTORI")) > 0 .and. !empty(SF2->F2_DUPL)
	I_()
endif

RestArea(aArea)
Return()

/*/
———————————————————————————————————————————————————————————————————————————————
@function		J_                                                    /@
@type			Static function                                              /@
@date			10/12/2009                                                   /@
@description	Função chamada pela user funct460I. 
				Procedimentos diversos                                       /@
@author			Diversos                                                     /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function J_()
Local aAreaSA1	:= SA1->(GetArea())
Local aAreaSA2	:= SA2->(GetArea())
Local aAreaSB1	:= SB1->(GetArea())
Local aAreaSD2	:= SD2->(GetArea())
Local aAreaSC5	:= SC5->(GetArea())
Local aAreaSC6	:= SC6->(GetArea())
Local aAreaSE1	:= SE1->(GetArea())
Local aAreaSF4	:= SF4->(GetArea())
local cNumNF	:= SF2->F2_DOC
local cSerieNF	:= SF2->F2_SERIE
//Local cEst, cMun


//———————————————————————————————————————————————————————————————————————————————
//                       Log de Pedido Faturado                         
//———————————————————————————————————————————————————————————————————————————————
u_GrvLogPed ( Funname() , "" , SC5->C5_NUM , "Pedido Faturado" )   

SA1->(dbSetOrder(1))
SA2->(dbSetOrder(1))
SB1->(dbSetOrder(1))
SD2->(dbSetOrder(3))
SC5->(dbSetOrder(1))		//C5_FILIAL + C5_NUM
SC6->(dbSetOrder(1))		//C6_FILIAL + C6_NUM + C6_ITEM
SE1->(dbSetOrder(2))		//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

if SD2->(dbSeek(xFilial("SD2") + cNumNF + cSerieNF))

	//———————————————————————————————————————————————————————————————————————————————
	// Gravar informacoes sobre a estrutura de vendas informado no SC5          
	// por SI8401 Adalberto Moreno em 18/04/11                                  
	//———————————————————————————————————————————————————————————————————————————————
	if	SF2->(FieldPos("F2_XREPRES")) > 0 .and.;
		SF2->(FieldPos("F2_XEXECUT")) > 0 .and.;
		SF2->(FieldPos("F2_XASSIST")) > 0 .and.;
		SF2->(FieldPos("F2_XCANAL")) > 0
		
		if SC5->(dbseek(xFilial("SC5") + SD2->D2_PEDIDO))

			SF2->(RecLock("SF2", .F.))
			SF2->F2_XREPRES := SC5->C5_XREPRES
			SF2->F2_XEXECUT := SC5->C5_XEXECUT
			SF2->F2_XASSIST := SC5->C5_XASSIST
			SF2->F2_XCANAL  := SC5->C5_XCANAL
			SF2->(MsUnlock())

		endif
		
	endif

	/*
	Retirado em 28/11/19, pois necessitei utilizar o campo A1_XREGESP para controle
	de regime especial na criacao de tag para FM Logistics.
	este campo é utilizado para a gravação do D2_XSEPLOG (separador logistico) que 
	não é utilizado em nenhum ponto do projeto
	Por Adalberto Moreno Batista
	
	if SM0->M0_CODIGO = '01'
	
	    if !SF2->F2_TIPO $ "DB"
	    	SA1->( dbSeek( xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA ) )
			cEst	:= SA1->A1_EST
			cMun	:= SA1->A1_COD_MUN
			lRegEsp := iif(SA1->A1_XREGESP="N",.F.,.T.)
		else
			SA2->( dbSeek( xFilial("SA2") + SF2->F2_CLIENTE + SF2->F2_LOJA ) )
			/*retirado em uso em 28/11/19, pois é utilizado somente para a gravacao do D2_XSEPLOG que não é utilizado em nenhum ponto do sistema
			cEst	:= SA2->A2_EST
			cMun	:= SA2->A2_COD_MUN
			lRegEsp := .T.
		endif

		//———————————————————————————————————————————————————————————————————————————————
		// Verifica PIN
		//———————————————————————————————————————————————————————————————————————————————
		lPIN := .F.
		if cEst $ "AM.AC.RO.RR" .or. (cEst = "AP" .and. cMun $ "00600.00303")		//SANTANA / MACAPA
			lPIN := .T.
		endif

		//———————————————————————————————————————————————————————————————————————————————
		// Verifica Protocolo ST                                                    
		//———————————————————————————————————————————————————————————————————————————————
		lProtocol := .F.
		if cEst $ "AL.PR.RS.PE.MS.MT.MG"
			lProtocol := .T.
		endif

	endif	
	*/
			
	Do While SD2->( !Eof() .And. xFilial("SD2") == D2_FILIAL .and. D2_DOC == cNumNF .AND. D2_SERIE == cSerieNF )

		/*
		Retirado em 28/11/19, pois necessitei utilizar o campo A1_XREGESP para controle
		de regime especial na criacao de tag para FM Logistics.
		este campo é utilizado para a gravação do D2_XSEPLOG (separador logistico) que 
		não é utilizado em nenhum ponto do projeto
		Por Adalberto Moreno Batista
		//———————————————————————————————————————————————————————————————————————————————
		// Grava bloqueio de impostos
		//———————————————————————————————————————————————————————————————————————————————
		if SM0->M0_CODIGO = '01'		
			SD2->( RecLock("SD2",.F.) )
			if lPIN
				SD2->D2_XSEPLOG := "PIN"
			elseif lProtocol .and. SD2->D2_ICMSRET > 0
				SD2->D2_XSEPLOG := "ST PROTOCOLO"
			elseif !lRegEsp
				SB1->( dbSeek(xFilial("SB1") + SD2->D2_COD) )
				if (cEst = "RJ" .and. AllTrim(SB1->B1_POSIPI) $ "85102000.85103000.85109011.85109019.85109090.85163100.85163200.85167990.94042100.94043000") .or. ;
					(cEst = "SC" .and. AllTrim(SB1->B1_POSIPI) $ "33049990.33051000.33052000.33059000.33079000.85102000.85103000.85163100.85163200")
					SD2->D2_XSEPLOG := "ANTECIPACAO"
				endif
			endif
			SD2->( MsUnlock() )
		endif
		//———————————————————————————————————————————————————————————————————————————————
		// Fim bloqueio de impostos
		//———————————————————————————————————————————————————————————————————————————————
		*/

		//———————————————————————————————————————————————————————————————————————————————
		// Grava preco padrao de tabela de preco de campo especifico no SC6 em  campo 
		// especifico no SD2.
		//	por Luiz Fernando                                                        
		//———————————————————————————————————————————————————————————————————————————————
		if SC6->( dbseek(xFilial("SC6") + SD2->D2_PEDIDO + SD2->D2_ITEMPV ))
			SD2->( RecLock("SD2",.F.) )
			SD2->D2_XPRCPAD := SC6->C6_XPRCPAD
			SD2->( MsUnlock() )
		endif
		
		SD2->(dbSkip())

	EndDo

endif

RestArea(aAreaSA1)
RestArea(aAreaSA2)
RestArea(aAreaSB1)
RestArea(aAreaSD2)
RestArea(aAreaSC5)
RestArea(aAreaSC6)
RestArea(aAreaSE1)
RestArea(aAreaSF4)
Return()

/*/
———————————————————————————————————————————————————————————————————————————————
@function		A_                                                    /@
@type			Static function                                              /@
@date			12/12/2010                                                   /@
@description	Função chamada pela user funct460I. 
				Mostra tela para a digitação de informações sobre exportações
				na tabela CDL para o preenchimento da TAG referente a expor-
				tações na SPED NFe.                                          /@
@author			SI8401 - Adalberto Moreno Batista                            /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function A_()
Local aAlter		:= {}
Local cChSF2		:= SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)
Local nUsed, nI, nL
Private aHeaderDE := {}
Private aColsDE   := {}
Private oA_SF2460

//———————————————————————————————————————————————————————————————————————————————
// Criando o aHeader da tabela CDL                                       
//———————————————————————————————————————————————————————————————————————————————
SX3->(dbSetOrder(2))
if SX3->(dbSeek("CDL_ITEMNF"))
	aAdd(aHeaderDE, {AllTrim(SX3->X3_TITULO), AllTrim(SX3->X3_CAMPO), AllTrim(SX3->X3_PICTURE), SX3->X3_TAMANHO, SX3->X3_DECIMAL,,, SX3->X3_TIPO,})
endif
if SX3->(dbSeek("CDL_PRODNF"))
	aAdd(aHeaderDE, {AllTrim(SX3->X3_TITULO), AllTrim(SX3->X3_CAMPO), AllTrim(SX3->X3_PICTURE), SX3->X3_TAMANHO, SX3->X3_DECIMAL,,, SX3->X3_TIPO,})
endif

SX3->(dbSetOrder(1))
SX3->(dbSeek("CDL"))
do while SX3->(!eof() .and. X3_ARQUIVO == "CDL")
    if !AllTrim(SX3->X3_CAMPO) $ "CDL_FILIAL.CDL_DOC.CDL_SERIE.CDL_ESPEC.CDL_CLIENT.CDL_LOJA.CDL_ITEMNF.CDL_PRODNF" .and. X3Uso(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL
		aAdd(aHeaderDE, {AllTrim(SX3->X3_TITULO), AllTrim(SX3->X3_CAMPO), AllTrim(SX3->X3_PICTURE), SX3->X3_TAMANHO, SX3->X3_DECIMAL,,, SX3->X3_TIPO,})
		aAdd(aAlter, SX3->X3_CAMPO)
	endif
	
	SX3->(dbSkip())
enddo

nUsed		:= Len(aHeaderDE)

//———————————————————————————————————————————————————————————————————————————————
// Iniciando os elementos do aCols com base nos itens da nota
//———————————————————————————————————————————————————————————————————————————————
SD2->(dbSetOrder(3))
SD2->(dbSeek(xFilial("SD2") + cChSF2))

do while SD2->(!eof() .and. D2_FILIAL == xFilial("SD2") .and. D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA == cChSF2)
	aAdd(aColsDE, Array(nUsed + 1))
	nL := Len(aColsDE)
	For nI := 1 To nUsed
		if AllTrim(aHeaderDE[nI, 2]) == "CDL_ITEMNF"
			aColsDE[nL, nI] := SD2->D2_ITEM
		elseif AllTrim(aHeaderDE[nI, 2]) == "CDL_PRODNF"
			aColsDE[nL, nI] := SD2->D2_COD
		else
			aColsDE[nL, nI] := CriaVar(aHeaderDE[nI, 2], .T.)
		endif
	Next
	aColsDE[nL, nUsed + 1] := .F.

	SD2->(dbSkip())
enddo

//———————————————————————————————————————————————————————————————————————————————
// Monta a tela para alimentar a observacao e os dados da importacao       
//———————————————————————————————————————————————————————————————————————————————
@ 114,22 To 469,914 Dialog oA_ Title OemToAnsi( "Informacoes Complementares" )
@ 10,05 To 140,435 Title OemToAnsi("SPED NFe - Complemento de Exportação da Nota Fiscal" + AllTrim(SF2->F2_DOC) + ", Série " + AllTrim(SF2->F2_SERIE) + " para " + AllTrim(SA1->A1_NOME))
oGetDE 	:= MsNewGetDados():New(20, 10, 135, 430, 3,,,, aAlter,, 999,,,, oA_, aHeaderDE, aColsDE)

@ 150,360 Button OemToAnsi("_Gravar Complemento") Size 60,16 Action DA_() Pixel of oA_

Activate Dialog oA_ Centered

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		DA_                                                   /@
@type			Static function                                              /@
@date			12/12/2010                                                   /@
@description	Sub-função da static functio460I 
				Grava informaçõess digitadas sobre exportações               /@
@author			SI8401 - Adalberto Moreno Batista                            /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function DA_()
Local nX, nK, cMens, lObrigat
Local _lGrava 	:= .T.

aColsDE		:= oGetDE:aCols
aHeaderDE	:= oGetDE:aHeader

SX3->(dbSetOrder(2))

//———————————————————————————————————————————————————————————————————————————————
// Valida as informacoes obrigatorias do aColsDE                             
//———————————————————————————————————————————————————————————————————————————————
if Len(aColsDE) > 0

	for nX := 1 to Len(aColsDE)

		if !aColsDE[nX, Len(aHeaderDE) + 1]		//testando se o array esta apagado

			cMens := ''
			for nK := 1 to Len(aHeaderDE)

				if !aHeaderDE[nK,2] $ "CDL_FILIAL.CDL_DOC.CDL_SERIE.CDL_ESPEC.CDL_CLIENT.CDL_LOJA"

					lObrigat := .F.
					if SX3->(dbSeek(aHeaderDE[nK,2]))
						if SX3->X3_OBRIGAT == "€"
							lObrigat := .T.
						endif
					endif
					
					if Empty(aColsDE[nX,nK]) .and. lObrigat
						cMens += aHeaderDE[nK,1] + ", "
					endif
				
				endif
				
			next

			If !empty(cMens)
				cMens += "não foi(ram) informado(s)." + chr(13)
				cMens += "Inclusão das informações complementares não poderá ser confirmada."
				Help(" ", 1, "ATENÇÃ460I", , cMens + chr(13) + chr(10) + "(Específico Brasitech). ", 1)
				_lGrava := .F.
				exit
			endif

		endif
		
	Next

endif


//———————————————————————————————————————————————————————————————————————————————
// Verifica se as informacoes serao gravadas                                   
//———————————————————————————————————————————————————————————————————————————————
If _lGrava
	
	//———————————————————————————————————————————————————————————————————————————————
	// Grava as informacoes da exportacao                                      
	//———————————————————————————————————————————————————————————————————————————————
	if Len(aColsDE) > 0

		CDL->(dbSetOrder(1))	//CDL_FILIAL, CDL_DOC, CDL_SERIE, CDL_CLIENT, CDL_LOJA, CDL_NUMDE, CDL_DOCORI, CDL_SERORI, CDL_FORNEC, CDL_LOJFOR, CDL_NRREG, CDL_ITEMNF, CDL_NRMEMO, R_E_C_N_O_, D_E_L_E_T_

		For nX := 1 to Len(aColsDE)

			if !aColsDE[nX, Len(aHeaderDE) + 1]		//Testando linhas excluidas

				CDL->(RecLock("CDL",.T.))
				CDL->CDL_FILIAL	:= xFilial("CDL")
				CDL->CDL_DOC		:= SF2->F2_DOC
				CDL->CDL_SERIE		:= SF2->F2_SERIE
				CDL->CDL_ESPEC		:= SF2->F2_ESPECIE
				CDL->CDL_CLIENT	:= SF2->F2_CLIENTE
				CDL->CDL_LOJA		:= SF2->F2_LOJA
					
				for nK := 1 to Len(aHeaderDE)
					if !aHeaderDE[nK,2] $ "CDL_FILIAL.CDL_DOC.CDL_SERIE.CDL_ESPEC.CDL_CLIENT.CDL_LOJA"		//.CDL_NUMDE"
				    	CDL->(FieldPut(FieldPos(aHeaderDE[ nK, 2 ]), aColsDE[ nX, nK ]))
					endif
				next
				CDL->(MsUnlock())
	
	 		endif
	 		
		Next
		
	endif

	Close(oA_)
	
endif

Return(_lGrava)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		B_                                                    /@
@type			Static function                                              /@
@date			05/12/2012                                                   /@
@description	Função chamada pela user funct460I. 
				Bloqueia nota fiscal (campo especifico F2_X_OPLOG), a partir 
				de informacoes de agendamento com o cliente e motivos  diver-
				sos (que sera informado no pedido de venda) 
				F2_X_OPLOG = XX                                     
                            +-> indica bloqueios diversos pelo pedido (S/N)            
				            +--> indica bloqueio por agendamento (S/N)       /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function B_()
Local aArea		:= GetArea()
Local aAreaSC5	:= SC5->(GetArea())
Local aAreaSD2	:= SD2->(GetArea())
Local aAreaSF4	:= SF4->(GetArea())
Local cArmazem	:= GetMV("BR_OPLOG", .F., "NAO ENCONTRADO")		//"06/13"
Local cEol		:= chr(13) + chr(10)
Local lGrava	:= .F.
Local cOpLog1	:= "N"
Local cOpLog2	:= "N"

//———————————————————————————————————————————————————————————————————————————————
// Verifica se o cliente possui tratativa especial de agendamento na entrega da 
// mercadoria e bloqueia a posicao 2 do campo especifico F2_X_OPLOG 
//———————————————————————————————————————————————————————————————————————————————
if SA1->A1_X_AGEND = "S"
	cOpLog1 = "S"
Elseif SA1->A1_X_AGEND = "O"
	cOpLog1 = "O"
endif

SC5->(dbSetOrder(1))
SF4->(dbSetOrder(1))
SD2->(dbSetOrder(3))
SD2->(dbSeek( xFilial("SD2") + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)))
do while SD2->(!eof() .and. D2_FILIAL = xFilial("SD2") .and. D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA = SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA))

	SC5->(dbSeek(xFilial("SC5") + SD2->D2_PEDIDO))
	SF4->(dbSeek(xFilial("SF4") + SD2->D2_TES))
	if SC5->C5_X_BLARQ = "S"
		cOpLog2 := "S"
	endif

	//———————————————————————————————————————————————————————————————————————————————
	// Verifica se o parametro ES_OPLOG foi configurado                        
	//———————————————————————————————————————————————————————————————————————————————
	if cArmazem = "NAO ENCONTRADO"
		//caso nao tenha necessidade de configuracao do parametro BR_LOCAL, o campo F2_X_OPLOG nao pode existir.
		Help(" ", 1, "ATENÇÃO", , "Crie o parâmetro BR_OPLOG, responsavel pelo tratamento de geração de arquivo para o operador logístico. Este parametro trabalha em conjunto com o campo F2_X_OPLOG." + cEol + "(Específico Brasitech). ", 1)
	Elseif (SD2->D2_LOCAL $ cArmazem .and. SF4->F4_ESTOQUE = "S") .or. (SD2->D2_LOCAL $ cArmazem .and. SA1->A1_X_AGEND = "O" .and. SF4->F4_ESTOQUE = "N")
		lGrava := .T.
	endif

	SD2->( dbSkip() )

enddo

if lGrava
	SF2->(RecLock("SF2", .F.))
	SF2->F2_X_OPLOG := cOpLog1 + cOpLog2
	SF2->(MsUnlock())
endif

RestArea(aAreaSC5)
RestArea(aAreaSD2)
RestArea(aAreaSF4)
RestArea(aArea)
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		C_                                                    /@
@type			Static function                                              /@
@date			07/11/2012                                                   /@
@description	Função chamada pela user funct460I. 
				Grava os campos F2_VOLUME1 e F2_ESPECI1 de acordo com o 
				cálculo de unidades por caixa master, campo especifico 
				B1_X_QTCXM, no cadastro de produtos                          /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function C_()
Local aArea		:= GetArea()
Local aAreaSB1	:= SB1->(GetArea())
Local aAreaSD2	:= SD2->(GetArea())
Local nCubPad	:= getmv("MV_XCUBMAS")
Local nVolume	:= 0
Local nInteiro	:= 0
Local nResto	:= 0
Local lGrava	:= .T.

//———————————————————————————————————————————————————————————————————————————————
// Calculo do volume total =                                         
// Somatoria dos valores inteiros da operacao D2_QUANT / B1_X_QTCXM +
// Somatoria dos volumes das sobras / volume da caixa master padrão +
//Se houver resto, somo 1                 
//———————————————————————————————————————————————————————————————————————————————
SB1->(dbSetOrder(1))
SD2->(dbSetOrder(3))
SD2->(dbSeek(xFilial("SD2") + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)))
do while SD2->(!eof() .and. D2_FILIAL = xFilial("SD2") .and. D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA = SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA))
	SB1->( dbSeek(xFilial("SB1") + SD2->D2_COD) )

   if SB1->B1_X_QTCXM > 0 .and. SB1->B1_XMETCUB > 0
		nInteiro	+= Int(SD2->D2_QUANT / SB1->B1_X_QTCXM)
		nResto		+= (SD2->D2_QUANT % SB1->B1_X_QTCXM) * SB1->B1_XMETCUB
	else
		ConOut(" - O produto:"+alltrim(SD2->D2_COD)+" faturado na Nota Fiscal:"+SD2->D2_DOC+"-"+SD2->D2_SERIE+" não possui cadastro de B1_X_QTCXM:"+cvaltochar(SB1->B1_X_QTCXM)+" ou de B1_XMETCUB:"+cvaltochar(SB1->B1_XMETCUB))
//		lGrava	:= .F.
//		exit
	endif

	SD2->(dbSkip())
enddo

//———————————————————————————————————————————————————————————————————————————————
// VOLUME = inteiros_acumulados + inteiro(resto_acumulado/6) + se houver resto da 
// operacao anterior, somo 1, senao somo zero
//———————————————————————————————————————————————————————————————————————————————
nVolume := nInteiro + Int(nResto / nCubPad) + iif(nResto % nCubPad > 0, 1, 0)

if nVolume > 0 .and. lGrava
	SF2->(RecLock("SF2", .F.))
	SF2->F2_VOLUME1 := nVolume
	SF2->F2_ESPECI1 := iif(nVolume > 1, "CAIXAS", "CAIXA")
	SF2->(MsUnlock())
endif

RestArea(aAreaSB1)
RestArea(aAreaSD2)
RestArea(aArea)
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		D_                                                    /@
@type			Static function                                              /@
@date			10/06/2013                                                   /@
@description	Função chamada pela user funct460I. 
				Grava a informacao de unidade de negocio (GAMA/BRAUN), defi-
				nido no cadastro de produtos, em campos especificos no cabe-
				calho da nota (SF2)e nos titulos receber (SE1)               /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function D_()

//———————————————————————————————————————————————————————————————————————————————
// Gravar o segmento de negocio dos produtos faturados, na nota fiscal e nos 
// titulos.
// Em uma nota fiscal havera somente produtos do mesmo segmento.
// Alterado MV_AGREG para B1_XNEGOCI
//———————————————————————————————————————————————————————————————————————————————
SD2->(dbseek(xFilial("SD2") + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)))
SB1->(dbseek(xFilial("SB1") + SD2->D2_COD))

if SF2->(FieldPos("F2_XNEGOCI")) > 0
	SF2->(RecLock("SF2", .F.))
	SF2->F2_XNEGOCI := SB1->B1_XNEGOCI
	SF2->(MsUnlock())
endif
	
if SE1->( FieldPos("E1_XNEGOCI") ) > 0 .and. !Empty(SF2->F2_DUPL)

	SE1->(dbSeek(xFilial("SE1") + SF2->(F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DOC)))
	do while SE1->(!eof() .and. E1_FILIAL == xFilial("SE1") .and. E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM == SF2->(F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DOC))
		SE1->(RecLock("SE1", .F.))
		SE1->E1_XNEGOCI := SB1->B1_XNEGOCI
		SE1->(MsUnlock())
		SE1->(dbSkip())
	enddo

endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		E_                                                    /@
@type			Static function                                              /@
@date			07/01/2012                                                   /@
@description	Função chamada pela user funct460I. 
				Gravar informacoes sobre VPC a partir de indicacoes no pedido
				de vendas                                                    /@
@author			SI8401- Adalberto Moreno Batista                             /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function E_()
Local aCredito		:= {}
Local lLoja			:= (SA1->A1_X_MDVPC == "L")
Local cVPCAvulsa	:= "AVU"		//"000" - troca de codigo de tipo avulso, de "000" para "AVU".
Local cVPCMarket	:= "MKT"
Local nPercVPCMkt	:= U_GetVPCMkt_FT15(dDataBase)
Local nK, nBase

//———————————————————————————————————————————————————————————————————————————————
// aCredito[1] - Contrato
// aCredito[2] - Tipo do percentual VPC
// aCredito[3] - Valor da Credito de cálculo
// aCredito[4] - Valor do crédito VPC
// aCredito[5] - Usado em NCC/CTAPAG/PEDBONIF
//———————————————————————————————————————————————————————————————————————————————
SC5->(dbSetOrder(1))
SZI->(dbSetOrder(1))
SZJ->(dbSetOrder(1))
SZP->(dbSetOrder(1))

SD2->(dbseek(xFilial("SD2") + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)))
do while SD2->(!eof() .and. D2_FILIAL +D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA == xFilial("SD2") + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA))
     
	if SC5->(dbSeek(xFilial("SC5") + SD2->D2_PEDIDO))
	
		if SF4->(dbseek(xFilial("SF4") + SD2->D2_TES))
		
			if SF4->F4_DUPLIC == "S"
			    
				//———————————————————————————————————————————————————————————————————————————————
				// Percentuais avulsos pagam somente qualquer tipo de uso de crédito VPC
				// Credito de Cálculo: mercadoria + IPI
				//———————————————————————————————————————————————————————————————————————————————
				if SC5->C5_X_VPCAV > 0

					nK := aScan(aCredito, {|x| empty(x[1]) .and. x[2] == cVPCAvulsa .and. x[5] == "SSS"})
					if nK == 0
						aAdd(aCredito, {	"",;
											cVPCAvulsa,;
											SD2->(D2_TOTAL + D2_VALIPI),;
											Round(SD2->(D2_TOTAL + D2_VALIPI) * (SC5->C5_X_VPCAV / 100), 2),;
											"SSS",;
											SC5->C5_X_VPCAV})
					else
						aCredito[nK, 3] += SD2->(D2_TOTAL + D2_VALIPI)
						aCredito[nK, 4] += Round(SD2->(D2_TOTAL + D2_VALIPI) * (SC5->C5_X_VPCAV / 100), 2)
					endif
					
				endif

				//———————————————————————————————————————————————————————————————————————————————
				// Percentuais de contrato, buscar Credito de calculo no SZJ incide IPI? ICMS ST?
				// os tipos VPC buscar na tabela SZP e identificar se pagará NCC, Contas a Pagar
				// e Pedidos bonificados
				//———————————————————————————————————————————————————————————————————————————————
				if !empty(SC5->C5_X_CTVPC)
					if SZJ->(dbSeek(xFilial("SZJ") + SC5->C5_X_CTVPC))
						
						SZP->(dbSeek(xFilial("SZP") + SC5->C5_X_CTVPC))
						do while SZP->(!eof() .and. ZP_FILIAL == xFilial("SZP") .and. ZP_CONTRAT == SC5->C5_X_CTVPC)
							nBase		:= 	SD2->D2_TOTAL +;
											iif(SZJ->ZJ_IPI == "S", SD2->D2_VALIPI, 0)
							nK 			:=	aScan(aCredito, {|x| x[1] == SC5->C5_X_CTVPC .and. x[2] == SZP->ZP_TPVPC .and. x[5] == SZP->(ZP_USANCC + ZP_USAPAG + ZP_USAPED) })
							
							if nK == 0
								aAdd(aCredito, {	SC5->C5_X_CTVPC,;
													SZP->ZP_TPVPC,;
													nBase,;
													Round(nBase * (SZP->ZP_PERC / 100), 2),;
													SZP->(ZP_USANCC + ZP_USAPAG + ZP_USAPED),;
													SZP->ZP_PERC } )
							else
								aCredito[nK, 3] += nBase
								aCredito[nK, 4] += Round(nBase * (SZP->ZP_PERC / 100), 2)
							endif
							SZP->(dbSkip())
						enddo
						
		         	endif
		    	endif
	
				//———————————————————————————————————————————————————————————————————————————————
				// Percentual para credito de VPC MKT (Marketing). Uso especifico para campanhas
				// de Marketing (mercadoria + IPI)
				// Gerado somente se houver VPC de contrato ou avulso
				//———————————————————————————————————————————————————————————————————————————————
				if nPercVPCMkt > 0 .and. Len(aCredito) > 0
				
					nK := aScan(aCredito, {|x| empty(x[1]) .and. x[2] == cVPCMarket .and. x[5] == "SSS"})
					if nK == 0
						aAdd(aCredito, {	"",;
											cVPCMarket,;
											SD2->(D2_TOTAL + D2_VALIPI),;
											Round(SD2->(D2_TOTAL + D2_VALIPI) * (nPercVPCMkt / 100), 2),;
											"SSS",;
											nPercVPCMkt})
					else
						aCredito[nK, 3] += SD2->(D2_TOTAL + D2_VALIPI)
						aCredito[nK, 4] += Round(SD2->(D2_TOTAL + D2_VALIPI) * (nPercVPCMkt / 100), 2)
					endif
					
				endif

			endif
			
		endif
		
    endif
    
	SD2->(dbSkip())
	
enddo

if Len(aCredito) > 0

	for nK := 1 to Len(aCredito)
		SZI->(dbSeek(xFilial("SZI") + aCredito[nK,2]))
		cHistorico := 	"Credito NF: " + SF2->(F2_DOC + "/" + AllTrim(F2_SERIE)) +;
						", TpVPC: " + aCredito[nK,2] + "-" + AllTrim(SZI->ZI_DESCR) +;
						iif(!empty(aCredito[nK,1]), ", Contrato: " + AllTrim(aCredito[nK,1]), "")

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
		//	[13]- Percentual VPC
		//	[14]- Número da solicitação do sistema WEB (tabela ZZV)
		//	[15]- Array {Número NF, Série NF}
		//———————————————————————————————————————————————————————————————————————————————
		U_VPCGrava_FT03(	"CR",;
							SF2->F2_CLIENTE,;
							iif(lLoja, SF2->F2_LOJA, ""),;
							aCredito[nK,1],;
							aCredito[nK,2],;
							aCredito[nK,3],;
							aCredito[nK,4],;
							cHistorico,;
							"1",;
							SF2->(F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA),;
							aCredito[nK,5],;
							SF2->F2_EMISSAO,;
							aCredito[nK,6],;
							,;
							{SF2->F2_DOC, SF2->F2_SERIE}		)
	next
	
endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		F_                                                    /@
@type			Static function                                              /@
@date			15/07/2013                                                   /@
@description	Função chamada pela user funct460I. 
				Gravar informacoes do pré-pedido nos itens da nota fiscal    /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function F_()
SZL->(dbSetOrder(1))	//ZL_FILIAL + ZL_NUM + ZL_ITEM

//———————————————————————————————————————————————————————————————————————————————
// Grava informações do pré-pedido (SZL) nos itens da nota fiscal
// Status do orçamento de vendas web ZL_GRVPED.
// ' '-Pendente de integração com o pedido de venda
// 'A'-Pedido alterado na WEB. Pendente de nova integração com o pedido de venda.
// 'E'-Identifica erro na tentativa de integração com o pedido de vendas.
// 'S'-Informa que o pré-pedido foi integrado com o pedido de vendas.
// 'N'-Informa que o pedido de venda foi excluído.
// 'F'-Informa que o orçamento foi totalmente faturado.
// 'P'-Indica que o orçamento foi parcialmente faturado.
// 'R'-Informa que houve eliminação de resíduos no pedido de vendas.
//———————————————————————————————————————————————————————————————————————————————
SD2->(dbseek(xFilial("SD2") + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)))
do while SD2->(!eof() .and. D2_FILIAL == xFilial("SD2") .and. D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA == SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA))
	
	if SC6->(dbseek(xFilial("SC6") + SD2->(D2_PEDIDO + D2_ITEMPV)))
		SD2->(RecLock("SD2", .F.))
		SD2->D2_X_NUMZL	:= SC6->C6_X_NUMZL
		SD2->D2_X_ITEZL	:= SC6->C6_X_ITEZL
		SD2->D2_XATTCLI := SA1->A1_XATTCLI
		SD2->(MsUnlock())

		if SZL->(dbSeek(xFilial("SZL") + SC6->(C6_X_NUMZL + C6_X_ITEZL)))
			SZL->(RecLock("SZL", .F.))
			SZL->ZL_GRVPED 	:= "F"
			SZL->ZL_NF		:= AllTrim(SZL->ZL_NF) + SD2->D2_SERIE + SD2->D2_DOC + "#"	//armazena no máximo 6 notas fiscais
			if SZL->(FieldPos("ZL_QTDFAT")) > 0
				SZL->ZL_QTDFAT	:= SZL->ZL_QTDFAT + SD2->D2_QUANT
				SZL->ZL_GRVPED	:= iif(SZL->ZL_QTDFAT < SZL->ZL_QTDE, "P", "F")
			endif
			SZL->(MsUnlock())
		endif

	endif
	SD2->(dbSkip())
enddo

Return()

/*
———————————————————————————————————————————————————————————————————————————————
@function		G_                                                    /@
@date			29/08/2014                                                   /@
@description	Função chamada pela user funct460I. 
				Transferencia entre armazem								     /@
@author			Luiz Fernando									             /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
*/
Static Function G_()
Local aEstrut 	:= {}
Local cDocSD3 	:= SF2->F2_DOC     // GetSXENum("SD3") alterado por claudio em 26/05/2015 , solicitado por Ezequiel (custo) objetivo facilitar a leitura do kardex do PA

SD2->(dbsetorder(3))
SD2->(dbseek(xFilial("SD2") + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)))
do while SD2->(!eof()) .and. SD2->D2_FILIAL == xFilial("SD2") .and. SD2->(D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA) == SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)
	if SD2->D2_LOCAL == "01"
		AADD(aEstrut,{SD2->D2_COD,SD2->D2_QUANT,SD2->D2_LOCAL,SD2->D2_DOC,SD2->D2_SERIE} )
		SD2->(dbSkip())
	else
		return()
	endif                                     
	
enddo
                
U_BFATM04(aEstrut,cDocSD3)                                 
SF2->(RecLock("SF2", .F.))
SF2->F2_X_DOCD3	:=	cDocSD3
// CONFIRMSX8() alterado por claudio em 26/05/2015 , solicitado por Ezequiel (custo) objetivo facilitar a leitura do kardex do PA

SF2->(MsUnlock())

return()

/*
———————————————————————————————————————————————————————————————————————————————
@function		H_                                                    /@
@date			20/11/2014                                                   /@
@description	Função chamada pela user funct460I. 			         /@
				Altera vendedor x vendedor alternativo					     /@
@author			Luiz Fernando									             /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
*/
Static Function H_()
Local lTpvenda := .F.
Local lTpacess := .F.
Local cQuery,cVend
Local aArea 	:= getArea()
Local aAreaSA1 	:= SA1->(getArea())
Local aAreaSZL 	:= SZL->(getArea())
Local dUltCom	:= CTOD("  /  /  ")
                                          
if Select("TRAB") > 0
	dbSelectArea("TRAB")
	dbCloseArea()
endif

SZL->(dbsetorder(1))

SD2->(dbseek(xFilial("SD2") + SF2->(F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)))
do while SD2->(!eof() .and. D2_DOC+D2_SERIE == SF2->(F2_DOC + F2_SERIE))
	if SZL->(dbseek(xFilial("SZL")+SD2->(D2_X_NUMZL+D2_X_ITEZL)))
		lTpvenda := iif(alltrim(SZL->ZL_ATTCLI) == "NORMAL",.T.,.F.)
		lTpacess := iif(alltrim(SZL->ZL_TPACESS) == "TVEND",.T.,.F.)
	endif
	SD2->(dbskip())
enddo

if lTpacess
	if	SA1->(dbseek(xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA)))
		if SA1->(reclock("SA1",.F.))
			SA1->A1_XRADIX 	:= "A"
			SA1->(MsUnlock())
		endif
	endif

	if lTpvenda 

		cQuery := "SELECT MAX(D2_EMISSAO) ULTEMISSAO FROM "+retsqlname("SD2")+" SD2 LEFT JOIN "+retsqlname("SZL")+" SZL ON "
		cQuery += "D2_FILIAL = ZL_FILIAL AND D2_CLIENTE = ZL_CLIENTE AND D2_LOJA = ZL_LOJA AND D2_X_NUMZL = ZL_NUM AND D2_X_ITEZL = ZL_ITEM "
		cQuery += "WHERE ZL_GRVPED IN ('F','P') AND ZL_TPACESS <> 'TVEND'  AND SD2.D_E_L_E_T_ = ' ' AND SZL.D_E_L_E_T_ = ' ' AND "
		cQuery += "ZL_CLIENTE+ZL_LOJA = '"+SD2->(D2_CLIENTE+D2_LOJA)+"' AND D2_DOC+D2_SERIE <> '"+SD2->(D2_DOC+D2_SERIE)+"' "
		
		//———————————————————————————————————————————————————————————————————————————————
		// Criando a tabela temporaria
		//———————————————————————————————————————————————————————————————————————————————
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRAB", .F., .T.)                
			
	 	if !empty(TRAB->ULTEMISSAO)
			dUltCom := stod(TRAB->ULTEMISSAO)
		endif
	
		if	SA1->(dbseek(xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA)))
			if AllTrim(SA1->A1_XATTCLI) == "NORMAL"		//.and. SF2->F2_EMISSAO - dUltCom > 180 - alterado em 13/05/19 para nao considerar mais tempo (Cassio)
				cVend := SA1->A1_XVENALT
				if SA1->(reclock("SA1",.F.))
					SA1->A1_XVENALT := SA1->A1_VEND
					SA1->A1_VEND 	:= cVend
					SA1->A1_XATTCLI := "TVENDAS-N"                                                         
					SA1->A1_XRADIX 	:= "A"
					SA1->(MsUnlock())
				endif
			endif
		endif
	endif
endif

restArea(aAreaSA1)
restArea(aAreaSZL)
restArea(aArea)

Return()

/*/
———————————————————————————————————————————————————————————————————————————————
@function		I_                                                    /@
@type			Static function                                              /@
@date			22/09/2016                                                   /@
@description	Função chamada pela user funct460I. 
				Grava registros na tabela de historico de alteracoes de 
				vencimento de titulos a receber (ZZ2).                       /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function I_()
Local aAreaSX2 := SX2->(GetArea())
Local aAreaSE1 := SE1->(GetArea())

if SX2->(dbSeek("ZZ2"))

	SE1->(dbSetOrder(2))		//E1_FILIAL, E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO
	SE1->(dbSeek(xFilial("SE1") + SF2->(F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DOC)))
	do while SE1->(!eof() .and. E1_FILIAL + E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM == xFilial("SE1") + SF2->(F2_CLIENTE + F2_LOJA + F2_PREFIXO + F2_DOC))

		SE1->(RecLock("SE1", .F.))
		SE1->E1_XVCTORI 	:= SE1->E1_VENCTO
		SE1->(MsUnlock())

		ZZ2->(RecLock("ZZ2", .T.))
		ZZ2->ZZ2_FILIAL		:= xFilial("ZZ2")
		ZZ2->ZZ2_PREFIX		:= SE1->E1_PREFIXO
		ZZ2->ZZ2_NUM		:= SE1->E1_NUM
		ZZ2->ZZ2_PARCEL		:= SE1->E1_PARCELA
		ZZ2->ZZ2_TIPO		:= SE1->E1_TIPO
		ZZ2->ZZ2_CLIENT		:= SE1->E1_CLIENTE
		ZZ2->ZZ2_LOJA		:= SE1->E1_LOJA
		ZZ2->ZZ2_DTMOV		:= Date()
		ZZ2->ZZ2_HRMOV		:= Time()
		ZZ2->ZZ2_USUMOV		:= cUserName
		ZZ2->ZZ2_VENORI		:= SE1->E1_XVCTORI
		ZZ2->ZZ2_VENCTO		:= SE1->E1_VENCTO
		ZZ2->ZZ2_VENREA		:= SE1->E1_VENCREA
		ZZ2->ZZ2_MOTIVO		:= "01"
		ZZ2->(MsUnlock())
		
		SE1->(dbSkip())

	enddo

endif

RestArea(aAreaSX2)
RestArea(aAreaSE1)

Return()
