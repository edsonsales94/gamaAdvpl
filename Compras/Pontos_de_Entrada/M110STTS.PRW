#include "rwmake.ch"
#include "protheus.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		M110STTS                                                     /@
@date			28/09/2020                                                   /@
@type			Ponto de entrada
@description    Function A110Inclui, A110Altera, e A110Deleta responsaveis 
                pela inclus縊, altera鈬o, exclus縊 e c?pia das Solicita鋏es 
                de Compras.
                Executado ap?s a grava鈬o da SC pela fun鈬o A110Grava em 
                inclus縊, altera鈬o e exclus縊 , localizado fora da transa鈬o
                possibilitando assim a inclusao de interface ap?s a grava鈬o
                de todas as solicita鋏es.	                                 /@
@parameters     [1] - Caracter - N?mero da solicita鈬o
                [2] - Num駻ico - N?mero da opera鈬o sendo:
                        1 = Inclus縊
                        2 = Altera鈬o
                        3 = Exclus縊
                [3] - L?gico   - Se a solicita鈬o ? originada de uma c?pia   /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Op鈬o Um Tecnologia da Informa鈬o                            /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function M110STTS()
Local cNum      := PARAMIXB[1]
Local nOpc      := PARAMIXB[2]
Local lCopia    := PARAMIXB[3]
Local aArea	 	:= GetArea()

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Limpa o campo C1_XLINK, respons疱el pelo controlflow
// Por: Adalberto Moreno Batista em 28/09/2020
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if (nOpc == 2 .or. lCopia) .and. SC1->(FieldPos("C1_XLINK")) > 0
	A_M110STTS(cNum)
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Efetiva os anexos movendo-os do diretorio TEMP para o diret?rio definitivo 
// para casos de incluss縊 e altera鈬o ou os elimina em caso de exclus縊
// Por: Adalberto Moreno Batista em 09/10/2020
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
B_M110STTS(cNum, nOpc)

RestArea(aArea)

Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		A_M110STTS                                                   /@
@type			Static Function                                              /@
@date			28/09/2020                                                   /@
@description	Limpa o campo C1_XLINK, respons疱el pelo controlflow
				somente em casos de altera鈬o e inclus?es provenientes de 
                c?pias.                                                      /@
@author			Adalberto Moreno Batista - Op鈬o Um Tecnologia da Informa鈬o /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
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
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		B_M110STTS                                                   /@
@type			Static Function                                              /@
@date			09/10/2020                                                   /@
@description	Efetiva os anexos movendo-os do diretorio TEMP para o 
                diret?rio definitivo para casos de incluss縊 e altera鈬o ou
                os elimina em caso de exclus縊.                              /@
@author			Adalberto Moreno Batista - Op鈬o Um Tecnologia da Informa鈬o /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
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

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Confirma鈬o da exclus縊
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if nOpcao == 3
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Exclui os arquivos vinculados ao pedido de compras, para situa鋏es onde h? o
	// abandono da inclus縊 do PC ou confirma鈬o da exclus縊 do PC
	// H? a refer麩cia do diretorio \ANEXOS_PC\ no ponto de entrada MA120BUT
	// Por: Adalberto Moreno Batista (Op鈬o Um Consultoria) em 16/03/2017
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	//Excluo os anexos do diretorio REAL
	aFiles		:= Directory(cPathReal + cFilAnt + "_" + AllTrim(cA110Num) + "_" + "*.*")
	if Len(aFiles) > 0
		for nX := 1 to Len(aFiles)
			fErase(cPathReal + aFiles[nX,1])
		next
	endif
   
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Confirma鈬o da inclus縊 ou altera鈬o
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
elseif nOpcao == 1 .or. nOpcao == 2		

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Ao confirmar a opera鈬o de inclus縊 ou altera鈬o realizo as seguintes a鋏es:
	// 1ｺ) Limpo os anexos remanescentes do diretorio REAL
	// 2ｺ) Copio os anexos do diret?rio TEMP para o diretorio REAL
	// 3ｺ) Limpo os anexos do diret?rio TEMP
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	aFiles		:= Directory(cPathReal + cFilAnt + "_" + AllTrim(cA110Num) + "_" + "*.*")
	if Len(aFiles) > 0
		for nX := 1 to Len(aFiles)
			fErase(cPathReal + aFiles[nX,1])                                // 1ｺ
		next
	endif

	aFiles		:= Directory(cPathTemp + cFilAnt + "_" + AllTrim(cA110Num) + "_" + "*.*")
	if Len(aFiles) > 0
		for nX := 1 to Len(aFiles)
			__CopyFile(cPathTemp + aFiles[nX,1], cPathReal + aFiles[nX,1])  // 2ｺ
			fErase(cPathTemp + aFiles[nX,1])                                // 3ｺ
		next
	endif

endif

Return()
