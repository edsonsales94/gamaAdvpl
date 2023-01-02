#include "protheus.ch"
#include "rwmake.ch"

/*/

�������������������������������������������������������������������������������
@function		BFATA08                                                      /@
@date			27/09/2013                                                   /@
@description	User function para o manuten��o dos tipos de percentuais VPC /@
@author			Adalberto Moreno Batista - Op��o Um Consultoria              /@
@use			Espec�fico Brasitech                                         /@
�������������������������������������������������������������������������������

/*/
User Function BFATA08()
Local aAreaSX3		:= SX3->(GetArea())
Local lContinua

SX3->(dbSetOrder(2))
lContinua := SX3->(dbSeek("ZI_COD"))
RestArea(aAreaSX3)

if lContinua
	AxCadastro("SZI", "Cadastro de tipos de percentuais VPC", "U_ExcTpVPC()", ".T.")

else
	Help(" ", 1, "ATEN��O", , "Esta empresa n�o possui configura��o para uso de controle VPC." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec�fico Brasitech). ", 1)

endif

Return()


/*/

�������������������������������������������������������������������������������
@function		CodFT08()                                                    /@
@date			27/09/2013                                                   /@
@description	User function para valida��o na digita��o do c�digo do tipo
                VPC                                                          /@
@author			Adalberto Moreno Batista - Op��o Um Consultoria              /@
@use			Espec�fico Brasitech                                         /@
�������������������������������������������������������������������������������

/*/
User Function CodFT08()
Local lRet	:= .T.
Local cEol	:= Chr(13) + Chr(10) + Chr(13) + Chr(10)
Local aArea	:= GetArea()

SZI->(dbSetOrder(1))
if SZI->(dbSeek(xFilial("SZI") + M->ZI_COD))
	lRet := .F.
	Help(" ", 1, "ATEN��O",, "C�digo j� informado. Utilize outro c�digo." + cEol + "(Espec�fico Brasitech). ", 1)
endif

RestArea(aArea)
Return(lRet)

/*/

�������������������������������������������������������������������������������
@function		ExcTpVPC                                                     /@
@date			27/09/2013                                                   /@
@description	User function para verificar se o tipo de percentual VPC
                poder� ser exclu�do                                          /@
@author			Adalberto Moreno Batista - Op��o Um Consultoria              /@
@use			Espec�fico Brasitech                                         /@
�������������������������������������������������������������������������������

/*/
User Function ExcTpVPC()
Local lRet	:= .T.
Local cEol	:= Chr(13) + Chr(10) + Chr(13) + Chr(10)
Local aArea	:= GetArea()
Local cQuery

//����������������������������������������������������
// Verifica se o tipo foi utilizado em algum contrato 
//����������������������������������������������������
cQuery := 	"SELECT COUNT(*) TIPOPERC " +;
			"FROM " + RetSqlName("SZP") + " SZP " +;
			"WHERE SZP.ZP_FILIAL = '" + xFilial("SZP") + "' AND SZP.ZP_TPVPC = '" + SZI->ZI_COD + "' AND SZP.D_E_L_E_T_='' "

cQuery += 	"UNION "

cQuery += 	"SELECT COUNT(*) TIPOPERC " +;
			"FROM " + RetSqlName("SZK") + " SZK " +;
			"WHERE SZK.ZK_FILIAL = '" + xFilial("SZK") + "' AND SZK.ZK_TPVPC = '" + SZI->ZI_COD + "' AND SZK.D_E_L_E_T_=''"

if Select("TRB") > 0
	TRB->(dbCloseArea())
endif

dbUseArea( .T., "TOPCONN", TCGENQRY(,,ChangeQuery(cQuery)),"TRB", .F., .T.)

TRB->(dbGoTop())
do while TRB->(!eof())
	if TRB->TIPOPERC > 0
		lRet := .F.
		Help(" ", 1, "ATEN��O",, "Este tipo de percentual foi utilizado em um ou mais registros nos contratos VPC ou movimentos VPC, portanto n�o ser� excluido." + cEol + "(Espec�fico Brasitech). ", 1)
		exit
	endif
	TRB->(dbSkip())
enddo

if Select("TRB") > 0
	TRB->(dbCloseArea())
endif

RestArea(aArea)
Return(lRet)