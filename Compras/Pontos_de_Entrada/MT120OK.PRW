#include "rwmake.ch"
#include "protheus.ch"

/*/
�������������������������������������������������������������������������������
@function		MT120OK                                                      /@
@date			15/08/2021                                                   /@
@type			Ponto de entrada
@description	Localizado no final da fun��o A120TudOk(), � respons�vel pela
				valida��o geral do pedido de compras / autoriza��o de entrega.
				Disparado ap�s a confirma��o dos itens da getdados e antes do 
				rodap� da dialog do PC.                                      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Op��o Um Tecnologia da Informa��o                            /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
User Function MT120OK()
Local lRet			:= .T.
Local cDirAnexos	:= GetMV("BR_ANEXOPC", .F., "")
Local cPathFile		:= cDirAnexos + "\" + cEmpAnt + cFilAnt + "\PC\temp\" + cFilAnt + "_" + AllTrim(ca120Num) + "_" + "*.*"
Local aFiles		:= Directory(cPathFile)

cA120NXPA := cA120Num	//corre��o de bug

//�������������������������������������������������������������������������������
// Analisa se h� anexo vinculado ao pedido de compras. Para o processo, ao menos 
// um arquivo dever� ser anexado. (N�o executar a valida��o se o processo for
// autom�tico)
//�������������������������������������������������������������������������������
if !IsBlind()

	if Empty(Len(aFiles))
		
		lRet := .F.
		Help(,, "� ATEN��O",, "Obrigat�rio anexar ao menos um documento ao pedido de compras ou despesa financeira.", 1)
			
	endif

endif

Return(lRet)