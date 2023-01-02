#Include "protheus.ch"
#Include "rwmake.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		M410ALOK                                                      /@
@type				Ponto de entrada                                              /@
@date				17/06/2013                                                    /@
@description	Executado antes da alteração do pedido de venda verificando
					se há ou não permissão para a alteração/exclusão.
					Retorno obrigatório de T. ou .F.                              /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
					Opção Um Consultoria                                          /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function M410ALOK()
Local lRet 	:= .T.

//———————————————————————————————————————————————————————————————————————————————
// Caso seja um pedido com origem 2-WEB, nao permitir a alteracao 
// Por: Adalberto Moreno Batista em 17/06/13                      
//———————————————————————————————————————————————————————————————————————————————
if SC5->(FieldPos("C5_X_ORIG")) > 0

	if ALTERA
		if SC5->C5_X_ORIG == "2"
			Help(" ", 1, "Atenção",, "Este é um pedido de origem Web. Não alterar informações de condição de pagamento, descontos ou incluir/excluir itens." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Gama Italy)"+ chr(13) + chr(10) + "ponto de entrada M410ALOK", 1)
/*
		elseif SC5->C5_X_ORIG == "3"
			lRet := .F.
			Help(" ", 1, "Atenção",, "Este pedido não poderá ser alterado pois é originário do site GAMA Store." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Gama Italy)"+ chr(13) + chr(10) + "ponto de entrada M410ALOK", 1)
*/
		endif
	endif

endif

Return(lRet)