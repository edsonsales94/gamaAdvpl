#include "rwmake.ch"
#include "TopConn.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		SF1100E                                                      /@
@date			11/12/2010                                                   /@
@type			Ponto de entrada
@description	Ponto de entrada acionado antes da exclusão de nota          /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)            /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function SF1100E()
Local _aArea   := GetArea()

//———————————————————————————————————————————————————————————————————————————————
// Exclui as informacoes da tabela de complementos CD5 somente para notas de
// importacao.
// por SI8401 Adalberto Moreno em 11/12/10
//———————————————————————————————————————————————————————————————————————————————
if SF1->F1_EST = "EX"

	A_SF1100E()

endif

//———————————————————————————————————————————————————————————————————————————————
// Exclui informacoes de VPC nas devolucoes, somente para as empresas que
// tiverem este controle.                                                
// por Adalberto Moreno Batista em 07/08/13                              
//———————————————————————————————————————————————————————————————————————————————
if SF1->F1_TIPO == "D" .and. SC5->(FieldPos("C5_X_CTVPC")) > 0 .and. SC5->(FieldPos("C5_X_VPCAV")) > 0

	B_SF1100E()

endif


//———————————————————————————————————————————————————————————————————————————————
// Exclusão de anexos vinculados ao documento fiscal
// por Adalberto Moreno Batista em 03/08/21                              
//———————————————————————————————————————————————————————————————————————————————
C_SF1100E()

RestArea(_aArea)
Return()

/*/
———————————————————————————————————————————————————————————————————————————————
@function		A_SF1100E                                                    /@
@date			11/12/2010                                                   /@
@type			Static Function
@description	Exclui as informacoes da tabela de complementos CD5 somente 
				para notas de importacao.                                    /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function A_SF1100E()
Local _aAreaCD5 := CD5->(GetArea())

CD5->(dbSetOrder(1))
CD5->(dbSeek(xFilial("CD5") + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)))

do while CD5->(!eof() .and. CD5_FILIAL == xFilial("CD5") .and. CD5_DOC + CD5_SERIE + CD5_FORNEC + CD5_LOJA = SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA))

	CD5->(RecLock( "CD5", .F. ))
	CD5->(dbDelete())
	CD5->(MsUnlock())
	CD5->(dbSkip())
	
enddo

RestArea(_aAreaCD5)
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		B_SF1100E                                                    /@
@date			07/08/2013                                                   /@
@type			Static Function
@description	Exclui informacoes de VPC nas devolucoes, somente para as
				empresas que tiverem este controle.                          /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function B_SF1100E()
Local aArea := GetArea()

//função encontrada no fonte BFATA03.PRW
U_VPCApaga_FT03("4", SF1->(F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA))

RestArea(aArea)
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		C_SF1100E                                                    /@
@date			03/08/2021                                                   /@
@type			Static Function
@description	Exclui anexos vinculados ao documento fiscal                 /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function C_SF1100E()
Local cNumControle	:= AllTrim(cNFiscal) + "_" + AllTrim(cSerie) + "_" + AllTrim(cA100For) + "_" + AllTrim(cLoja)
Local cDirAnexos	:= GetMV("BR_ANEXOPC")
Local cAno			:= StrZero(Year(dDEmissao), 4)
Local cMes			:= StrZero(Month(dDEmissao), 2)
Local cPathFile		:= cDirAnexos + "\" + cEmpAnt + cFilAnt + "\NF\" + cAno + "\mes_" + cMes + "\"
Local aFiles		:= Directory(cPathFile + cFilAnt + "_" + AllTrim(cNumControle) + "_" + "*.*")
Local nX

for nX := 1 to Len(aFiles)
	fErase(cPathFile + aFiles[nX,1])
next

Return()
