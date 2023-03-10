#Include "RwMake.ch"

User Function Rettabpad(cCodtab , cCodProd )

/*旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
  ? Declara as Variaveis da Rotina                                      ?
  읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
*/

Local aArea    	:=GetArea()
Local cAliasQry :=GetNextAlias()
Local cQuery    :=''
local nRet 		:=0
local aVetor   	:={}   


/*旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
  ? Valida a existencia do cadastro da tabela de pre?o padrao           ?
  읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
*/

if alltrim(cCodtab) == ""
	return nRet
endif

/*旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
  ? Monta a express?o de consulta SQL					    	 	    ?
  읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
*/


cQuery += "SELECT rtrim(DA1_PRCVEN) as 'DA1_PRCVEN' "
cQuery += "FROM " + RetSQLName( "DA1" ) 
cQuery += " WHERE DA1_DATVIG = (SELECT MAX(DA1_DATVIG) FROM " + RetSQLName( "DA1" )
cQuery += " WHERE DA1_CODPRO = '"+cCodProd + "' AND DA1_CODTAB = '"+ cCodtab + "' AND D_E_L_E_T_ = '' AND DA1_DATVIG <= (CONVERT(nvarchar(30), GETDATE(), 112)) ) " 
cQuery += "AND DA1_CODPRO = '" +cCodProd + "' AND DA1_CODTAB = '"+ cCodtab + "' AND D_E_L_E_T_ = '' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .T., .F.)

Memowrite("rettabpad.Sql" , cQuery )

dbSelectArea(cAliasQry)
dbGotop()

While !(cAliasQry)->(EoF())
	
	nRet := val((cAliasQry)->DA1_PRCVEN)
	(cAliasQry)->(DbSkip())
	
EndDo     

return nRet 