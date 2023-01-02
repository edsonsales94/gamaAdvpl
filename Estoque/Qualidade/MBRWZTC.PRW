/*
------------------------------------------------------------------------------
Desenvolvedor: Ricky Moraes - 10/07/2019
Solicitante..: Itamar Junior  (Gestor Ti)
Objetivo.....: Cadatra Codigo de Defeitos tabela customizada ZTC
------------------------------------------------------------------------------
*/
#include 'protheus.ch'


USER FUNCTION mBrwZTC()

LOCAL cAlias := "ZTC"

PRIVATE cCadastro := "Cadastro Causa/Defeito"

PRIVATE aRotina     := { }

//Alert(ChkFile("ZTC"))
//Alert(ChkFile("ZTQ"))
 

AADD(aRotina, { "Pesquisar", "AxPesqui", 0, 1,NIL })

AADD(aRotina, { "Visualizar", "AxVisual"  , 0, 2,NIL })

AADD(aRotina, { "Incluir"      , "AxInclui"   , 0, 3 ,NIL})

AADD(aRotina, { "Alterar"     , "AxAltera"  , 0, 4,NIL })

AADD(aRotina, { "Excluir"     , "AxDeleta" , 0, 5,NIL })
 

dbSelectArea(cAlias)

dbSetOrder(1)

mBrowse(6, 1, 22, 75, cAlias)
//MBrowse(06, 01, 22, 75, cAlias,,,,,, /*aCores*/,,,,,,,,, 60000, {|| o := GetMBrowse(), o:GoBottom(), o:GoTop(), o:Refresh() }) 

 

RETURN NIL