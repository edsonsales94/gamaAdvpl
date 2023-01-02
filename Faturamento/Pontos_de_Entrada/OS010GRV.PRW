#INCLUDE "Protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		OS010GRV                                                      /@
@date				17/11/2014                                                    /@
@type				Ponto de entrada
@description	Gravação da Tabela de Preço.                                  /@
@parameters		PARAMIXB[1] - Tipo (1-Tabela/2-Produto)
					PARAMIXB[2]	- Opção(1-Inclusão/2-Alteração/3-Exclusão)        /@
@return			Nil
@author			Luiz Fernando Nogueira                                        /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
/*/

User function OS010GRV()
Local cCodTab	:= DA0->DA0_CODTAB
Local aArea		:= getArea()
Local aAreaDA1	:= DA1->(getArea())

if DA1->(FieldPos("DA1_XLOG")) > 0 
	DA1->(dbsetorder(1))
	DA1->(dbseek(xFilial("DA1")+cCodtab))
	do while DA1->DA1_CODTAB == cCodtab 
		if !empty(DA1->DA1_XLOG)
			if SZZ->(reclock("SZZ",.T.))
				SZZ->ZZ_FILIAL 	:= xFilial("DA1")
				SZZ->ZZ_ITEM   	:= DA1->DA1_ITEM
				SZZ->ZZ_CODTAB 	:= DA1->DA1_CODTAB
				SZZ->ZZ_CODPRO 	:= DA1->DA1_CODPRO
				SZZ->ZZ_PRCVEN 	:= DA1->DA1_PRCVEN
				SZZ->ZZ_DATVIG 	:= DA1->DA1_DATVIG
				SZZ->ZZ_LOG		:= "Alterado por:"+ cUserName+"em:"+ dtoc(ddatabase) +" "+ time() //Nome do Usuario + data do log + hora
				SZZ->(MsUnlock())
				if DA1->(reclock("DA1",.F.))
					DA1->DA1_XLOG := space(2)
				endif
			endif
		endif
		DA1->(dbskip())
	enddo
endif
     
restArea(aAreaDA1)
restArea(aArea)

return()