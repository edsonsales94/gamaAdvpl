#include "protheus.ch"     
#include "rwmake.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		MA103MNU                                                     /@
@type			Ponto de entrada                                             /@
@date			21/08/2012                                                   /@
@description	Adiciona função no menu (aRotina) em documento de entrada    /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MTA103MNU()
Private cNumControle

//———————————————————————————————————————————————————————————————————————————————
// Somente quando não for executado por msexecauto
//———————————————————————————————————————————————————————————————————————————————
if !IsBlind()

    cNumControle := AllTrim(SF1->F1_DOC) + "_" + AllTrim(SF1->F1_SERIE) + "_" + AllTrim(SF1->F1_FORNECE) + "_" + AllTrim(SF1->F1_LOJA)

    //———————————————————————————————————————————————————————————————————————————————
    // Adiciona consulta de log de nota fiscal
    //———————————————————————————————————————————————————————————————————————————————
    aAdd(aRotina,	{"® Log Nota", "U_ConLogNf()", 0 , 2})

    //———————————————————————————————————————————————————————————————————————————————
    // Adiciona item no aRotina para funcionalidade de vinculação de arquivos à uma 
    // nota fiscal. Os arquivos serão gravados em diretorio dentro do rootpath.
    // Por: Adalberto Moreno Batista (Opção Um) em 15/05/2021
    //———————————————————————————————————————————————————————————————————————————————
    //aAdd(aRotina,   {"® Anexos", 'U_GenAttach(SF1->(AllTrim(F1_DOC) + "_" + AllTrim(F1_SERIE) + "_" + AllTrim(F1_FORNECE) + "_" + AllTrim(F1_LOJA)), "PC", .F., {StrZero(Year(SF1->F1_EMISSAO), 4), StrZero(Month(SF1->F1_EMISSAO), 2)})', 0 , 2, 0, .F.})
    aAdd(aRotina, {"® Anexos", 		{||U_FINATTACH()}, 0, 8,, .F.})

    //———————————————————————————————————————————————————————————————————————————————
    // Function utilizada pelo importador "Conexao NFe"
    //———————————————————————————————————————————————————————————————————————————————
    //U_GTPE010()

endif

Return       
