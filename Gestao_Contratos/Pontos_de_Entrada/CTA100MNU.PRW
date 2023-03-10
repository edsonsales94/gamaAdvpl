#include "protheus.ch"     
#include "rwmake.ch"
#INCLUDE "FWMVCDEF.CH"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		CTA100MNU                                                    /@
@type			Ponto de entrada                                             /@
@date			28/12/2020                                                   /@
@description	Adiciona fun鈬o no menu (aRotina) de contratos               /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Op鈬o Um Tecnologia                                          /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function CTA100MNU()
Local nOpAlt := Iif(VerSenha(58),58,77) 	//Permiss縊 de altera鈬o
Local nPos

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Altera array aRotina, substituindo funcionalidade do banco de conhecimento
// pela rotina especifica de anexos do contrato. Desta forma, todo o controle
// padr縊 de acesso, funcionar? para os Anexos.
// Os arquivos ser縊 gravados em diretorio dentro do rootpath e os usu疵ios n縊
// ter縊 ter acesso ? ele.
// Por: Adalberto Moreno Batista (Op鈬o Um) em 10/12/2019
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
nPos := aScan(aRotina, {|x| Upper(AllTrim(x[2])) == "CN300DOCUM"})
if nPos > 0

	aRotina[nPos, 1] := "ｮ Anexos"
	aRotina[nPos, 2] := "U_GenAttach(CN9->CN9_NUMERO, 'CT', AllTrim(CN9->CN9_SITUAC)!='05', {CN9->CN9_NUMERO})"

else

	ADD OPTION aRotina TITLE "ｮ Anexos"	ACTION "U_GenAttach(CN9->CN9_NUMERO, 'CT', AllTrim(CN9->CN9_SITUAC)!='05', {CN9->CN9_NUMERO})"	OPERATION MODEL_OPERATION_UPDATE	ACCESS nOpAlt	//--"ｮ Anexos"

endif

Return()
