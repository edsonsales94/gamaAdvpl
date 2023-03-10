#include "rwmake.ch"
#include "protheus.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MT010INC                                                      /@
@date				21/12/2015                                                    /@
@type				Ponto de entrada
@description	Executado ap?s a confirma鈬o da inclus縊 de um produto.       /@
@author			Adalberto Moreno Batista (Op鈬o Um Consultoria)               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function MT010INC()

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Grava informa鋏es em campos de controle em caso de c?pia de produtos
// Por: Adalberto Moreno Batista (Op鈬o Um Consultoria) em 09/06/2016
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
A_MT010INC()

Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		A_MT010INC                                                    /@
@type				Static Function                                               /@
@date				09/06/2016                                                    /@
@description	Em caso de copia, utiliza o conceito de modificar o campo 
					espec?fico B1_XSITUAC, que identifica a situa鈬o do cadastro, 
					para "1" (pendente de envio do cadastro para a Argentina. As 
					outras situa鋏es pendentes s縊:
					2=Enviado		(registro enviado por schedule para codifica鈬o
										na Argentina)
					3=Registrado	(retorno da nova codificacao de produto. Rotina
										manual executada pelo responsavel por cadastro
										na Argentina)                                  
					Grava a data e hora da inclus縊 do produto (Por Luiz Fernando)/@
@author			Adalberto Moreno Batista (Op鈬o Um Consultoria)               /@
@use				Especifico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
Static Function A_MT010INC()
Local aArea		:= GetArea()
Local aAreaSX3	:= SX3->(GetArea())

SX3->(dbSetOrder(2))

SB1->(RecLock("SB1", .F.))

if SX3->(dbSeek("B1_XSITUAC"))
	SB1->B1_XSITUAC	:= SX3->&X3_RELACAO
endif
if SX3->(dbSeek("B1_MSBLQL"))
	SB1->B1_MSBLQL		:= SX3->&X3_RELACAO
endif
if SX3->(dbSeek("B1_XFECHAL"))
	SB1->B1_XFECHAL	:= Date()
endif
if SX3->(dbSeek("B1_XHORA"))
	SB1->B1_XHORA		:= Time()
endif

SB1->(MsUnlock())

RestArea(aAreaSX3)
RestArea(aArea)
Return()
