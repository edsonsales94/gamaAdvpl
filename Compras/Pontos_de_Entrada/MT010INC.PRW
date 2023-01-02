#include "rwmake.ch"
#include "protheus.ch"

/*/
�������������������������������������������������������������������������������
@function		MT010INC                                                      /@
@date				21/12/2015                                                    /@
@type				Ponto de entrada
@description	Executado ap�s a confirma��o da inclus�o de um produto.       /@
@author			Adalberto Moreno Batista (Op��o Um Consultoria)               /@
@use				Espec�fico Brasitech                                          /@
�������������������������������������������������������������������������������
/*/
User Function MT010INC()

//�������������������������������������������������������������������������������
// Grava informa��es em campos de controle em caso de c�pia de produtos
// Por: Adalberto Moreno Batista (Op��o Um Consultoria) em 09/06/2016
//�������������������������������������������������������������������������������
A_MT010INC()

Return()


/*/
�������������������������������������������������������������������������������
@function		A_MT010INC                                                    /@
@type				Static Function                                               /@
@date				09/06/2016                                                    /@
@description	Em caso de copia, utiliza o conceito de modificar o campo 
					espec�fico B1_XSITUAC, que identifica a situa��o do cadastro, 
					para "1" (pendente de envio do cadastro para a Argentina. As 
					outras situa��es pendentes s�o:
					2=Enviado		(registro enviado por schedule para codifica��o
										na Argentina)
					3=Registrado	(retorno da nova codificacao de produto. Rotina
										manual executada pelo responsavel por cadastro
										na Argentina)                                  
					Grava a data e hora da inclus�o do produto (Por Luiz Fernando)/@
@author			Adalberto Moreno Batista (Op��o Um Consultoria)               /@
@use				Especifico Brasitech                                          /@
�������������������������������������������������������������������������������
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