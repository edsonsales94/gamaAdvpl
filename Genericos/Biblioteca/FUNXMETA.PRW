#include "rwmake.ch"
#include "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FUNXMETA  ³ Por: Felipe Varella           ³ Data ³03.10.2014³±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gatilho Metas de Vendas                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Brasitech                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±Alterado 				³ Por: Felipe Varella           ³ Data ³03.10.2014³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


User Function PosRep()

cRetorno := Posicione("SZB",1,xFilial("SZB")+Posicione("SA3",1,xFilial("SA3")+M->ZC_CODREP,"A3_XREPRES"),"ZB_NOME")

return (cRetorno)


User Function PosExec()

cRetorno := Posicione("SZB",1,xFilial("SZB")+Posicione("SA3",1,xFilial("SA3")+M->ZC_CODREP,"A3_XEXECUT"),"ZB_NOME")

return (cRetorno)


User Function PosAss()

cRetorno := Posicione("SZB",1,xFilial("SZB")+Posicione("SA3",1,xFilial("SA3")+M->ZC_CODREP,"A3_XASSIST"),"ZB_NOME")

return (cRetorno)


User Function PosCanal()

cRetorno := Posicione("SZB",1,xFilial("SZB")+Posicione("SA3",1,xFilial("SA3")+M->ZC_CODREP,"A3_XCANAL"),"ZB_NOME")

return (cRetorno)        


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FUNXMETA ³ Por: Felipe Varella           ³ Data ³03.10.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gatilho Meta de Vendas                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Brasitech                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±Alterado 				³ Por: Felipe Varella           ³ Data ³03.10.2014³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


User Function GrvPosRep()

cRetorno := Posicione("SZB",1,xFilial("SZB")+Posicione("SA3",1,xFilial("SA3")+SZC->ZC_CODREP,"A3_XREPRES"),"ZB_NOME")

return (cRetorno)

User Function GrvPosExec()

cRetorno := Posicione("SZB",1,xFilial("SZB")+Posicione("SA3",1,xFilial("SA3")+SZC->ZC_CODREP,"A3_XEXECUT"),"ZB_NOME")

return (cRetorno)


User Function GrvPosAss()                       

cRetorno := Posicione("SZB",1,xFilial("SZB")+Posicione("SA3",1,xFilial("SA3")+SZC->ZC_CODREP,"A3_XASSIST"),"ZB_NOME")

return (cRetorno)


User Function GrvPosCanal()

cRetorno := Posicione("SZB",1,xFilial("SZB")+Posicione("SA3",1,xFilial("SA3")+SZC->ZC_CODREP,"A3_XCANAL"),"ZB_NOME")

return (cRetorno)