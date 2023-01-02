#include "rwmake.ch"
#include "protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		MT120OK                                                      /@
@date			15/08/2021                                                   /@
@type			Ponto de entrada
@description	Localizado no final da função A120TudOk(), é responsável pela
				validação geral do pedido de compras / autorização de entrega.
				Disparado após a confirmação dos itens da getdados e antes do 
				rodapé da dialog do PC.                                      /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Tecnologia da Informação                            /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MT120OK()
Local lRet			:= .T.
Local cDirAnexos	:= GetMV("BR_ANEXOPC", .F., "")
Local cPathFile		:= cDirAnexos + "\" + cEmpAnt + cFilAnt + "\PC\temp\" + cFilAnt + "_" + AllTrim(ca120Num) + "_" + "*.*"
Local aFiles		:= Directory(cPathFile)

cA120NXPA := cA120Num	//correção de bug

//———————————————————————————————————————————————————————————————————————————————
// Analisa se há anexo vinculado ao pedido de compras. Para o processo, ao menos 
// um arquivo deverá ser anexado. (Não executar a validação se o processo for
// automático)
//———————————————————————————————————————————————————————————————————————————————
if !IsBlind()

	if Empty(Len(aFiles))
		
		lRet := .F.
		Help(,, "® ATENÇÃO",, "Obrigatório anexar ao menos um documento ao pedido de compras ou despesa financeira.", 1)
			
	endif

endif

Return(lRet)
