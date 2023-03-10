#include "protheus.ch"     
#include "rwmake.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MA103MNU                                                     /@
@type			Ponto de entrada                                             /@
@date			21/08/2012                                                   /@
@description	Adiciona fun鈬o no menu (aRotina) em documento de entrada    /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function MTA103MNU()
Private cNumControle

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Somente quando n縊 for executado por msexecauto
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if !IsBlind()

    cNumControle := AllTrim(SF1->F1_DOC) + "_" + AllTrim(SF1->F1_SERIE) + "_" + AllTrim(SF1->F1_FORNECE) + "_" + AllTrim(SF1->F1_LOJA)

    //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
    // Adiciona consulta de log de nota fiscal
    //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
    aAdd(aRotina,	{"ｮ Log Nota", "U_ConLogNf()", 0 , 2})

    //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
    // Adiciona item no aRotina para funcionalidade de vincula鈬o de arquivos ? uma 
    // nota fiscal. Os arquivos ser縊 gravados em diretorio dentro do rootpath.
    // Por: Adalberto Moreno Batista (Op鈬o Um) em 15/05/2021
    //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
    //aAdd(aRotina,   {"ｮ Anexos", 'U_GenAttach(SF1->(AllTrim(F1_DOC) + "_" + AllTrim(F1_SERIE) + "_" + AllTrim(F1_FORNECE) + "_" + AllTrim(F1_LOJA)), "PC", .F., {StrZero(Year(SF1->F1_EMISSAO), 4), StrZero(Month(SF1->F1_EMISSAO), 2)})', 0 , 2, 0, .F.})
    aAdd(aRotina, {"ｮ Anexos", 		{||U_FINATTACH()}, 0, 8,, .F.})

    //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
    // Function utilizada pelo importador "Conexao NFe"
    //覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
    //U_GTPE010()

endif

Return       
