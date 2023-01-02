#include "protheus.ch"     
#include "rwmake.ch"
#INCLUDE "FWMVCDEF.CH"

/*/
�������������������������������������������������������������������������������
@function		CTA100MNU                                                    /@
@type			Ponto de entrada                                             /@
@date			28/12/2020                                                   /@
@description	Adiciona fun��o no menu (aRotina) de contratos               /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Op��o Um Tecnologia                                          /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
User Function CTA100MNU()
Local nOpAlt := Iif(VerSenha(58),58,77) 	//Permiss�o de altera��o
Local nPos

//�������������������������������������������������������������������������������
// Altera array aRotina, substituindo funcionalidade do banco de conhecimento
// pela rotina especifica de anexos do contrato. Desta forma, todo o controle
// padr�o de acesso, funcionar� para os Anexos.
// Os arquivos ser�o gravados em diretorio dentro do rootpath e os usu�rios n�o
// ter�o ter acesso � ele.
// Por: Adalberto Moreno Batista (Op��o Um) em 10/12/2019
//�������������������������������������������������������������������������������
nPos := aScan(aRotina, {|x| Upper(AllTrim(x[2])) == "CN300DOCUM"})
if nPos > 0

	aRotina[nPos, 1] := "� Anexos"
	aRotina[nPos, 2] := "U_GenAttach(CN9->CN9_NUMERO, 'CT', AllTrim(CN9->CN9_SITUAC)!='05', {CN9->CN9_NUMERO})"

else

	ADD OPTION aRotina TITLE "� Anexos"	ACTION "U_GenAttach(CN9->CN9_NUMERO, 'CT', AllTrim(CN9->CN9_SITUAC)!='05', {CN9->CN9_NUMERO})"	OPERATION MODEL_OPERATION_UPDATE	ACCESS nOpAlt	//--"� Anexos"

endif

Return()