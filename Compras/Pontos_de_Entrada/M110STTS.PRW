#include "rwmake.ch"
#include "protheus.ch"

/*/
�������������������������������������������������������������������������������
@function		M110STTS                                                     /@
@date			28/09/2020                                                   /@
@type			Ponto de entrada
@description    Function A110Inclui, A110Altera, e A110Deleta responsaveis 
                pela inclus�o, altera��o, exclus�o e c�pia das Solicita��es 
                de Compras.
                Executado ap�s a grava��o da SC pela fun��o A110Grava em 
                inclus�o, altera��o e exclus�o , localizado fora da transa��o
                possibilitando assim a inclusao de interface ap�s a grava��o
                de todas as solicita��es.	                                 /@
@parameters     [1] - Caracter - N�mero da solicita��o
                [2] - Num�rico - N�mero da opera��o sendo:
                        1 = Inclus�o
                        2 = Altera��o
                        3 = Exclus�o
                [3] - L�gico   - Se a solicita��o � originada de uma c�pia   /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Op��o Um Tecnologia da Informa��o                            /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
User Function M110STTS()
Local cNum      := PARAMIXB[1]
Local nOpc      := PARAMIXB[2]
Local lCopia    := PARAMIXB[3]
Local aArea	 	:= GetArea()

//�������������������������������������������������������������������������������
// Limpa o campo C1_XLINK, respons�vel pelo controlflow
// Por: Adalberto Moreno Batista em 28/09/2020
//�������������������������������������������������������������������������������
if (nOpc == 2 .or. lCopia) .and. SC1->(FieldPos("C1_XLINK")) > 0
	A_M110STTS(cNum)
endif

//�������������������������������������������������������������������������������
// Efetiva os anexos movendo-os do diretorio TEMP para o diret�rio definitivo 
// para casos de incluss�o e altera��o ou os elimina em caso de exclus�o
// Por: Adalberto Moreno Batista em 09/10/2020
//�������������������������������������������������������������������������������
B_M110STTS(cNum, nOpc)

RestArea(aArea)

Return()


/*/
�������������������������������������������������������������������������������
@function		A_M110STTS                                                   /@
@type			Static Function                                              /@
@date			28/09/2020                                                   /@
@description	Limpa o campo C1_XLINK, respons�vel pelo controlflow
				somente em casos de altera��o e inclus�es provenientes de 
                c�pias.                                                      /@
@author			Adalberto Moreno Batista - Op��o Um Tecnologia da Informa��o /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
Static Function A_M110STTS(cNum)
Local aAreaSC1	 := SC1->(GetArea())

SC1->(dbSetOrder(1))
SC1->(dbSeek(xFilial("SC1") + cNum))
do While SC1->(!eof() .and. C1_FILIAL == xFilial("SC1") .and. C1_NUM == cNum)
    SC1->(RecLock("SC1", .F.))
    SC1->C1_XLINK   := ""
    SC1->(MsUnlock())
    SC1->(dbSkip())
enddo

RestArea(aAreaSC1)

Return() 



/*/
�������������������������������������������������������������������������������
@function		B_M110STTS                                                   /@
@type			Static Function                                              /@
@date			09/10/2020                                                   /@
@description	Efetiva os anexos movendo-os do diretorio TEMP para o 
                diret�rio definitivo para casos de incluss�o e altera��o ou
                os elimina em caso de exclus�o.                              /@
@author			Adalberto Moreno Batista - Op��o Um Tecnologia da Informa��o /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
Static Function B_M110STTS(cNum, nOpcao)
Local cDirAnexos	:= GetMV("BR_ANEXOPC")
Local nX, aFiles, cAno, cMes, cPathTemp, cPathReal

if INCLUI .or. ALTERA
	cAno				:= StrZero(Year(dA110Data), 4)
	cMes				:= StrZero(Month(dA110Data), 2)
else
	cAno				:= StrZero(Year(SC1->C1_EMISSAO), 4)
	cMes				:= StrZero(Month(SC1->C1_EMISSAO), 2)
endif

cPathTemp		:= cDirAnexos + "\" + cEmpAnt + cFilAnt + "\SC\temp\"
cPathReal		:= cDirAnexos + "\" + cEmpAnt + cFilAnt + "\SC\" + cAno + "\mes_" + cMes + "\"

MakeDir(cDirAnexos)
MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt)
MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\SC")
MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\SC\temp")
MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\SC\" + cAno)
MakeDir(cDirAnexos + "\" + cEmpAnt + cFilAnt + "\SC\" + cAno + "\mes_" + cMes)

//�������������������������������������������������������������������������������
// Confirma��o da exclus�o
//�������������������������������������������������������������������������������
if nOpcao == 3
	//�������������������������������������������������������������������������������
	// Exclui os arquivos vinculados ao pedido de compras, para situa��es onde h� o
	// abandono da inclus�o do PC ou confirma��o da exclus�o do PC
	// H� a refer�ncia do diretorio \ANEXOS_PC\ no ponto de entrada MA120BUT
	// Por: Adalberto Moreno Batista (Op��o Um Consultoria) em 16/03/2017
	//�������������������������������������������������������������������������������
	//Excluo os anexos do diretorio REAL
	aFiles		:= Directory(cPathReal + cFilAnt + "_" + AllTrim(cA110Num) + "_" + "*.*")
	if Len(aFiles) > 0
		for nX := 1 to Len(aFiles)
			fErase(cPathReal + aFiles[nX,1])
		next
	endif
   
//�������������������������������������������������������������������������������
// Confirma��o da inclus�o ou altera��o
//�������������������������������������������������������������������������������
elseif nOpcao == 1 .or. nOpcao == 2		

	//�������������������������������������������������������������������������������
	// Ao confirmar a opera��o de inclus�o ou altera��o realizo as seguintes a��es:
	// 1�) Limpo os anexos remanescentes do diretorio REAL
	// 2�) Copio os anexos do diret�rio TEMP para o diretorio REAL
	// 3�) Limpo os anexos do diret�rio TEMP
	//�������������������������������������������������������������������������������
	aFiles		:= Directory(cPathReal + cFilAnt + "_" + AllTrim(cA110Num) + "_" + "*.*")
	if Len(aFiles) > 0
		for nX := 1 to Len(aFiles)
			fErase(cPathReal + aFiles[nX,1])                                // 1�
		next
	endif

	aFiles		:= Directory(cPathTemp + cFilAnt + "_" + AllTrim(cA110Num) + "_" + "*.*")
	if Len(aFiles) > 0
		for nX := 1 to Len(aFiles)
			__CopyFile(cPathTemp + aFiles[nX,1], cPathReal + aFiles[nX,1])  // 2�
			fErase(cPathTemp + aFiles[nX,1])                                // 3�
		next
	endif

endif

Return()