/*
------------------------------------------------------------------------------
Desenvolvedor: Ricky Moraes - 31/08/19
Solicitante..: Itamar Junior  (Gestor Ti)
Objetivo.....: Cadatra Codigo de Origem tabela customizada ZTO
------------------------------------------------------------------------------
*/
#include 'protheus.ch'


USER FUNCTION mBrwZTO()

LOCAL cAlias := "ZTO"

PRIVATE cCadastro := "Cadastro Origem Defeito - CQ"

PRIVATE aRotina     := { }


//ChkFile("ZTO")
//Alert(ChkFile("ZTQ"))
 

AADD(aRotina, { "Pesquisar", "AxPesqui", 0, 1,NIL })

AADD(aRotina, { "Visualizar", "AxVisual"  , 0, 2,NIL })

AADD(aRotina, { "Incluir"      , "AxInclui"   , 0, 3 ,NIL})

AADD(aRotina, { "Alterar"     , "AxAltera"  , 0, 4,NIL })

//AADD(aRotina, { "Excluir"     , "AxDeleta" , 0, 5,NIL })
 

dbSelectArea(cAlias)

dbSetOrder(1)

mBrowse(6, 1, 22, 75, cAlias)
//MBrowse(06, 01, 22, 75, cAlias,,,,,, /*aCores*/,,,,,,,,, 60000, {|| o := GetMBrowse(), o:GoBottom(), o:GoTop(), o:Refresh() }) 

 

RETURN NIL