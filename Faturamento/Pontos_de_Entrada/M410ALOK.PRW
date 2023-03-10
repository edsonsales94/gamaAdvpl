#Include "protheus.ch"
#Include "rwmake.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		M410ALOK                                                      /@
@type				Ponto de entrada                                              /@
@date				17/06/2013                                                    /@
@description	Executado antes da altera鈬o do pedido de venda verificando
					se h? ou n縊 permiss縊 para a altera鈬o/exclus縊.
					Retorno obrigat?rio de T. ou .F.                              /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Op鈬o Um Consultoria                                          /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function M410ALOK()
Local lRet 	:= .T.

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Caso seja um pedido com origem 2-WEB, nao permitir a alteracao 
// Por: Adalberto Moreno Batista em 17/06/13                      
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if SC5->(FieldPos("C5_X_ORIG")) > 0

	if ALTERA
		if SC5->C5_X_ORIG == "2"
			Help(" ", 1, "Aten鈬o",, "Este ? um pedido de origem Web. N縊 alterar informa鋏es de condi鈬o de pagamento, descontos ou incluir/excluir itens." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec?fico Gama Italy)"+ chr(13) + chr(10) + "ponto de entrada M410ALOK", 1)
/*
		elseif SC5->C5_X_ORIG == "3"
			lRet := .F.
			Help(" ", 1, "Aten鈬o",, "Este pedido n縊 poder? ser alterado pois ? origin疵io do site GAMA Store." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec?fico Gama Italy)"+ chr(13) + chr(10) + "ponto de entrada M410ALOK", 1)
*/
		endif
	endif

endif

Return(lRet)