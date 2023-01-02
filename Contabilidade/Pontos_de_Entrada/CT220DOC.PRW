/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Ponto Entr³ CT220DOC ³                               ³ Data ³24.05.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gravacao do numero do DOC                                  ³±±
±±³Utilizacao³ Chamado no momento da gravacao dos lancamentos contabeis   ³±±
±±³          ³ na Consolidacao Geral. Tem como objetivo, possibilitar que ³±±
±±³          ³ seja alterado o numero do documento, para que nao haja     ³±±
±±³          ³ duplicacao da chave: DATA+LOTE+SUB-LOTE+DOC+LINHA, pois    ³±±
±±³          ³ caso queira alterar algum lancamento da empresa consolidada³±±
±±³          ³ nao havera problema do sistema se perder.                  ³±±
±±³          ³ O registro do CT2 ja esta travado.                         ³±±
±±³Parametros³ UPAR do tipo X : é passado como parametro o Alias do       ³±±
±±³          ³ arquivo posicionado para validar se esta no CT2, pois so   ³±± 
±±³          ³ devera ser executado se estiver no CT2.                    ³±±
±±³Retorno   ³ URET do tipo X : Pode retornar .t. ou .f.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Brasitech                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
#include "rwmake.ch"
      
User Function CT220DOC()
Local cAlias	:= PARAMIXB[1]

if cAlias = 'CT2'
	CT2->CT2_SBLOTE	:= "0" + CT2->CT2_EMPORI
endif

Return(.T.)
