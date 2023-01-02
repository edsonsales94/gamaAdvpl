#include "rwmake.ch"
#include "protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		M110STTS                                                     /@
@date			28/09/2020                                                   /@
@type			Ponto de entrada
@description    Function A110Inclui, A110Altera, e A110Deleta responsaveis 
                pela inclusão, alteração, exclusão e cópia das Solicitações 
                de Compras.
                Executado após a gravação da SC pela função A110Grava em 
                inclusão, alteração e exclusão , localizado fora da transação
                possibilitando assim a inclusao de interface após a gravação
                de todas as solicitações.	                                 /@
@parameters     [1] - Caracter - Número da solicitação
                [2] - Numérico - Número da operação sendo:
                        1 = Inclusão
                        2 = Alteração
                        3 = Exclusão
                [3] - Lógico   - Se a solicitação é originada de uma cópia   /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Tecnologia da Informação                            /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function M110STTS()
Local cNum      := PARAMIXB[1]
Local nOpc      := PARAMIXB[2]
Local lCopia    := PARAMIXB[3]
Local aArea	 	:= GetArea()

//———————————————————————————————————————————————————————————————————————————————
// Limpa o campo C1_XLINK, responsável pelo controlflow
// Por: Adalberto Moreno Batista em 28/09/2020
//———————————————————————————————————————————————————————————————————————————————
if (nOpc == 2 .or. lCopia) .and. SC1->(FieldPos("C1_XLINK")) > 0
	A_M110STTS(cNum)
endif

//———————————————————————————————————————————————————————————————————————————————
// Efetiva os anexos movendo-os do diretorio TEMP para o diretório definitivo 
// para casos de inclussão e alteração ou os elimina em caso de exclusão
// Por: Adalberto Moreno Batista em 09/10/2020
//———————————————————————————————————————————————————————————————————————————————
B_M110STTS(cNum, nOpc)

RestArea(aArea)

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		A_M110STTS                                                   /@
@type			Static Function                                              /@
@date			28/09/2020                                                   /@
@description	Limpa o campo C1_XLINK, responsável pelo controlflow
				somente em casos de alteração e inclusões provenientes de 
                cópias.                                                      /@
@author			Adalberto Moreno Batista - Opção Um Tecnologia da Informação /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
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
———————————————————————————————————————————————————————————————————————————————
@function		B_M110STTS                                                   /@
@type			Static Function                                              /@
@date			09/10/2020                                                   /@
@description	Efetiva os anexos movendo-os do diretorio TEMP para o 
                diretório definitivo para casos de inclussão e alteração ou
                os elimina em caso de exclusão.                              /@
@author			Adalberto Moreno Batista - Opção Um Tecnologia da Informação /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
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

//———————————————————————————————————————————————————————————————————————————————
// Confirmação da exclusão
//———————————————————————————————————————————————————————————————————————————————
if nOpcao == 3
	//———————————————————————————————————————————————————————————————————————————————
	// Exclui os arquivos vinculados ao pedido de compras, para situações onde há o
	// abandono da inclusão do PC ou confirmação da exclusão do PC
	// Há a referência do diretorio \ANEXOS_PC\ no ponto de entrada MA120BUT
	// Por: Adalberto Moreno Batista (Opção Um Consultoria) em 16/03/2017
	//———————————————————————————————————————————————————————————————————————————————
	//Excluo os anexos do diretorio REAL
	aFiles		:= Directory(cPathReal + cFilAnt + "_" + AllTrim(cA110Num) + "_" + "*.*")
	if Len(aFiles) > 0
		for nX := 1 to Len(aFiles)
			fErase(cPathReal + aFiles[nX,1])
		next
	endif
   
//———————————————————————————————————————————————————————————————————————————————
// Confirmação da inclusão ou alteração
//———————————————————————————————————————————————————————————————————————————————
elseif nOpcao == 1 .or. nOpcao == 2		

	//———————————————————————————————————————————————————————————————————————————————
	// Ao confirmar a operação de inclusão ou alteração realizo as seguintes ações:
	// 1º) Limpo os anexos remanescentes do diretorio REAL
	// 2º) Copio os anexos do diretório TEMP para o diretorio REAL
	// 3º) Limpo os anexos do diretório TEMP
	//———————————————————————————————————————————————————————————————————————————————
	aFiles		:= Directory(cPathReal + cFilAnt + "_" + AllTrim(cA110Num) + "_" + "*.*")
	if Len(aFiles) > 0
		for nX := 1 to Len(aFiles)
			fErase(cPathReal + aFiles[nX,1])                                // 1º
		next
	endif

	aFiles		:= Directory(cPathTemp + cFilAnt + "_" + AllTrim(cA110Num) + "_" + "*.*")
	if Len(aFiles) > 0
		for nX := 1 to Len(aFiles)
			__CopyFile(cPathTemp + aFiles[nX,1], cPathReal + aFiles[nX,1])  // 2º
			fErase(cPathTemp + aFiles[nX,1])                                // 3º
		next
	endif

endif

Return()
