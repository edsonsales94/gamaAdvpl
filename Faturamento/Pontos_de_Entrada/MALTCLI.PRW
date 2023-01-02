#Include "Rwmake.ch"
#Include  "Protheus.ch"  

/*
 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³MALTCLI ºAutor ³Ronaldo Gomes º Data ³ 13/10/2011            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. ³ Confirma as alterações do campo A1_NREDUZ para todos os        º±±
±±º cadastro no campo A1_XNOMGRU 										  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso ³                                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

*/

User Function MALTCLI ()
Local aArea := GetArea ()
Local nReg := SA1->(Recno()) // Guarda o Registro SA1 Atual
Local cNReduz := SA1->A1_NREDUZ
Local cCod := SA1->A1_COD
Local cLoja := SA1->A1_LOJA 

If SM0->M0_CODIGO <> '01'

Return .T.

Endif
               

DbSelectArea("SA1")
//dbSetOrder(10) // Ordem do Novo Indice Criado
dbOrderNickName("CODGRU") // Ordem do Novo Indice Criado

If dbSeek(xFilial("SA1")+cCod+cLoja)

	While SA1->(!Eof()) .And. A1_FILIAL == xFilial("SA1") .And. A1_XCODGRU == cCod .And. A1_XLOJGRU == cLoja

		If RecLock("SA1",.F.)
			SA1->A1_XCODGRU:=cCod
			SA1->A1_XLOJGRU:=cLoja
			SA1->A1_XNOMGRU:= cNReduz
			MsUnlock()                                     
	
		EndIf
		
		SA1->(dbSkip(1))

	EndDo

EndIf

SA1->(dbGoTo(nReg))
RestArea(aArea)

Return 