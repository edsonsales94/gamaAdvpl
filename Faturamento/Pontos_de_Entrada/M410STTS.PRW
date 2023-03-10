#Include "RwMake.ch"
#Include "Protheus.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		M410STTS                                                      /@
@type				Ponto de entrada                                              /@
@date				21/09/2017                                                    /@
@description	Acionado ao final de todas as transa鋏es de um pedido de 
					vendas.                                                       /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function M410STTS()
Local aArea		:= GetArea()

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Na empresa 01, filial 08, quando pedido do eCommerce (C5_X_ORIG == "3"),
// Liberar automaticamente o cr馘ito
// Por: Adalberto Moreno Batista (Op鈬o Um Consultoria) em 21/09/2017
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
if SM0->M0_CODIGO == "01" .and. SM0->M0_CODFIL == "08" .and. SC5->C5_X_ORIG == "3"

	U_A_M410STTS()
	
endif

RestArea(aArea)
Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		A_M410STTS                                                    /@
@type				Static function                                               /@
@date				21/09/2017                                                    /@
@description	Libera automaticamente o cr馘ito para pedidos do e-Commerce   /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function A_M410STTS()
Local aArea			:= GetArea()
Local cPedido		:= SC5->C5_NUM
Local cCliente		:= SC5->C5_CLIENTE
Local cLojaCli		:= SC5->C5_LOJACLI
Local aRegSC6 		:= {}
Local cQuery		:=	"SELECT C9_FILIAL, C9_PEDIDO, C9_BLCRED, C9_ITEM, SC9.R_E_C_N_O_ SC9RECNO, SC6.R_E_C_N_O_ SC6RECNO " +;
							"FROM " + RetSqlName("SC9") + " SC9, " +;
										 RetSqlName("SC6") + " SC6 "+;
							"WHERE SC9.C9_FILIAL = '" + xFilial("SC9") + "' " +;
									"AND SC9.C9_PEDIDO = '" + cPedido + "' " +;
									"AND SC9.C9_BLCRED NOT IN ('  ','09','10','ZZ') " +;
									"AND SC9.D_E_L_E_T_ = ' ' " +;
									"AND SC6.C6_FILIAL = '" + xFilial("SC6") + "' " +;
									"AND SC6.C6_NUM = SC9.C9_PEDIDO " +;
									"AND SC6.C6_ITEM = SC9.C9_ITEM " +;
									"AND SC6.C6_PRODUTO = SC9.C9_PRODUTO " +;
									"AND SC6.D_E_L_E_T_ = ' ' "

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TEMP", .T., .T.)

do while TEMP->(!eof())
	
	If SC5->C5_TIPLIB == "2"
		aadd(aRegSC6, TEMP->SC6RECNO)
	Else
		SC6->(MsGoto(TEMP->SC6RECNO))
		SC9->(MsGoto(TEMP->SC9RECNO))
		a450Grava(1, .T., .F.)
	EndIf
		
	TEMP->(dbSkip())
	
enddo

If Len(aRegSC6) > 0
	
	SC9->(dbClearFilter())
	SC9->(dbSetOrder(1))

	Begin Transaction
		MaAvalSC5("SC5",3,.F.,.F.,,,,,,cPedido,aRegSC6,.T.,.F.)
	End Transaction
	
/*ﾚﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄｿ
  ｳ                Verifica o Status Atual do Pedido                      ｳ
  ﾀﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾙ*/
aStatPed := u_VerStatPed( xFilial("SC5") , cPedido , cCliente , cLojaCli )
u_GrvLogPed ( Funname() , "MTA410" , cPedido , aStatPed[1] )     

EndIf

MsUnLockAll()

if Select("TEMP") > 0
	TEMP->(dbCloseArea())
endif

RestArea(aArea) 
Return()
