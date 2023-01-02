#Include "Protheus.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Mta410T º Autor ³ Cristiano Figueiroa º Data ³ 07/12/2009  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ponto de Entrada disparado na Gravacao do Pedido de Vendas º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasitech ( Gama Italy )                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function Mta410T()
Local aStatPed := {}
Local cNumPed  := IIf ( Type("M->C5_NUM")     == "U" , SC5->C5_NUM  , M->C5_NUM     )
Local cCliente := IIf ( Type("M->C5_CLIENTE") == "U" , SC5->C5_CLIENTE , M->C5_CLIENTE )
Local cLoja    := IIf ( Type("M->C5_LOJACLI") == "U" , SC5->C5_LOJACLI , M->C5_LOJACLI )
Local cContrato
Local nVlfat := 0
Local nVlbon := 0
Local nCont  := 0 


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                      Adiciona o Log do Pedido                         ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If Inclui .AND. !(SM0->M0_CODIGO = "05")
   u_GrvLogPed ( Funname() , "MTA410T" , cNumPed , "Pedido Incluído"  )
Endif 

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³              Grava o Log de Alteracao do Pedido                       ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If Altera .And. Funname() <>  "MATA440" .AND. !(SM0->M0_CODIGO = "05")

   u_GrvLogPed ( Funname() , "MTA410" , cNumPed , "Pedido Alterado" )

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                 Limpa o Flag de Rejeicao do Pedido                    ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
   RecLock("SC5" , .F. )
   SC5->C5_PEDREJ := ""
   MsUnlock()

Endif
   
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³          Caso tenha sido Liberado , Grava o Log de Liberacao          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !Empty (SC5->C5_LIBEROK )  .AND. !(SM0->M0_CODIGO = "05")                                           
   u_GrvLogPed ( Funname() , "MTA410T" , cNumPed , "Pedido Liberado" )
Endif

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                Verifica o Status Atual do Pedido                      ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aStatPed := u_VerStatPed( xFilial("SC5") , cNumPed , cCliente , cLoja )
u_GrvLogPed ( Funname() , "MTA410" , cNumPed , aStatPed[1] )     
  
  
//————————————————————————————————————————————————————————————————————————————
// atualizando o código de contrato VPC
// Por: Adalberto Moreno Batista (Opção Um Consultoria) em 26/03/14
//————————————————————————————————————————————————————————————————————————————
if SC5->C5_TIPO $ "NCIP" .and. SC5->(FieldPos("C5_X_CTVPC")) > 0

	cContrato	:= U_VPCFindCt_FT03(cCliente, cLoja)
	if SC5->C5_X_CTVPC != cContrato
		SC5->(RecLock("SC5",.F.))
		SC5->C5_X_CTVPC := cContrato
		SC5->(MsUnlock())
	endif
endif

//————————————————————————————————————————————————————————————————————————————————————
// atualiza os campos C5_X_VLFAT (Valor Faturado) e C5_X_VLBON (Valor de Bonificação)
// Por: Felipe Varella em 05/11/14
//————————————————————————————————————————————————————————————————————————————————————                                                                              
/*
IF SC5->(FieldPos("C5_X_VLFAT")) > 0 .and. SC5->(FieldPos("C5_X_VLBON")) > 0
	
	nPosOper := aScan(aHeader, {|x| Alltrim(x[2])=="C6_XOPER"})
	nPosVal  := aScan(aHeader, {|x| Alltrim(x[2])=="C6_VALOR"})
	nPosTes  := aScan(aHeader, {|x| Alltrim(x[2])=="C6_TES"})
	            
	
	SF4->(DBSETORDER(1))
	
	For nCont := 1 To Len(aCols)
		SF4->(dbseek(xFilial("SF4")+ aCols[nCont][nPosTes]))
	
		If aCols[nCont][nPosOper] == '01' .AND. SF4->F4_DUPLIC == 'S'
			nVlfat += aCols[nCont][nPosVal]
		EndIf
		If aCols[nCont][nPosOper] == '03' .AND. SF4->F4_DUPLIC == 'N' 
			nVlbon += aCols[nCont][nPosVal]
	    Endif
	Next           
	
	If RecLock("SC5",.F.)
		SC5->C5_X_VLFAT := nVlfat
		SC5->C5_X_VLBON := nVlbon
		SC5->(MsUnlock())
	EndIf                    
EndIf
*/
Return .T.

