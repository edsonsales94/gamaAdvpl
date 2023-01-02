
#INCLUDE 'APVT100.CH'  
#INCLUDE 'RWMAKE.CH' 
#INCLUDE "PROTHEUS.ch"
#INCLUDE "topconn.ch"

/*/
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Funcao   ::VTDEMO1 :: Autor:: ACD                  :: Data ::17/07/03   ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Descrição:: Programa de exemplo de uso das funcoes de VT100             ::
::          ::                                                             ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Parametros::                                                            ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::  Uso     :: PROGRAMA EXEMPLO DE UMA APLICACAO PARA MICROTERMINAL        ::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
/*/
User Function AOCSALDO()
aItens:={}
_cProduto:=space(28)


While .T. 
	VTClear()
	VTClearBuffer()
	DLVTCabec("Consulta Saldos por Produto",.F.,.F.,.T.)
	@ 01, 00 VTSay PadR('Cod   :' , VTMaxCol())
	@ 01, 08 VTGet _cProduto Pict '@!' 	   
	VTREAD



   VTClear()
	fSaldoSB2SBF(_cProduto)
	VTAlert("Carregando Saldos aguarde...","[-]",.T.,1500)  
	 //aItens :={{"1010 ",10, "DESCRICAO1","UN "}}	

  
          
	acab :={"DESCRICAO            ","LOCAL","ENDERECO","SALDO  ","UM"}
	aSize   := {20,3,16,9,3}                                  
	nPos := 1
	npos := VTaBrowse(,,,,aCab,aItens,aSize,,nPos)   
	

/*

	VTAlert("Carregando Saldos aguarde...","[-]",.T.,2000)
	aFields := {"CODIGO","DESCRICAO","LOCAL","ENDERECO","SALDO","UM"}
	aSize   := {16,20,10,15}          
	aHeader := {"CODIGO","DESCRICAO      ","LOCAL","ENDERECO","SALDO","UM"}       
	sb1->(dbseek(xfilial()))
	npos := VTDBBrowse(,,,,"cAliasSALDO",aHeader,aFields,aSize)
*/

             
	VTClearBuffer() 
   If VTYesNo("Deseja finalizar?","Pergunta")
   	Exit
   EndIf
  
   If VTLastKey() == 27
      Loop
   EndIF

   VTClearBuffer()
   
EndDo

Return .T.

Return



******************************************************************************************************************************************************
Static Function fSaldoSB2SBF(cProduto)
******************************************************************************************************************************************************
Local lResp:=.f.
Local cObs:="" 
Local cQuery:="" 
Local cAliasQry := GetNextAlias()


cQuery += "SELECT B1_COD CODIGO ,B1_DESC DESCRICAO , B2_LOCAL AS LOCAL, ISNULL(BF_LOCALIZ,'N-CONTROLA') AS ENDERECO ,COALESCE(BF_QUANT,B2_QATU) SALDO,B1_UM UM "
cQuery += "FROM " 
cQuery += "SB1010 SB1	INNER JOIN SB2010  SB2 ON SB1.D_E_L_E_T_='' AND SB2.D_E_L_E_T_='' AND B2_COD=B1_COD"
cQuery += " LEFT JOIN SBF010 SBF ON SBF.D_E_L_E_T_='' AND BF_FILIAL=B2_FILIAL AND BF_LOCAL=B2_LOCAL AND BF_PRODUTO=B1_COD" 
cQuery += "	WHERE B2_QATU>0 AND B2_FILIAL='01' AND B1_COD ='" + SUBSTR(cProduto,1,15) + "'"

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .T., .F.)

Memowrite("ACDSaldo.Sql" , cQuery )

dbSelectArea(cAliasQry)
//Conta total e registros     
Count To nRecCount

      IF nRecCount>0                                                                                                               
      
		  //	cObs+=" Registros "+ cValToChar(nRecCount)
	     //VTAlert(cObs,"SIGAWMS - AVISO",.t.,3000)

			dbGotop()
			
			While !(cAliasQry)->(EoF())
					//acab :={"CODIGO","DESCRICAO            ","LOCAL","ENDERECO","UM"}
				AADD(aItens,{(cAliasQry)->DESCRICAO  ,(cAliasQry)->LOCAL,(cAliasQry)->ENDERECO, Transform((cAliasQry)->SALDO,"@E 999,999")  ,(cAliasQry)->UM })
				(cAliasQry)->(DbSkip())
				
			EndDo     
			
	     
	   else
	   //aItens
	   
		  	cObs+=" Registros "+ cValToChar(nRecCount)
	      VTAlert(cObs,"SIGAWMS - AVISO",.t.,3000)
		endif

return
