#Include "Protheus.ch"
#Include "Rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BFATC01  บ Autor ณLuiz Fernando บ Data ณ 04/12/2013        บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Consulta Notas Canceladas                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Brasitech ( Gama Italy )                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function BFATC01

Local 	aIndex 	:= {}
Local 	cFiltro := "Substr(F3_CFO,1,1) $ ('1,2,3,5,6,7') .AND. 'CANCELADA' $ Upper(F3_OBSERV) " //Expressao do Filtro
Private cCadastro := "Consulta Notas Canceladas"
Private cAlias    := "SF3"

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Monta um aRotina proprio                                            ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/

Private aRotina := {{ "&Pesquisar"	,"AxPesqui"		,0 ,1 } 	,;
					{ "&Visualizar" ,"AxVisual" 	,0 ,2 } 	,;
					{ "&Consulta"	,'Execblock("A_BFATC01")',0 ,2 },;
                    { "Legenda"     ,'Execblock("LEGBFATC")'  ,0 ,2 }}
					
Private cDelFunc := ".T."  // Validacao para a exclusao. Pode-se utilizar ExecBlock

Private bFiltraBrw := { || FilBrowse( cAlias , @aIndex , @cFiltro ) } //Determina a Expressao do Filtro

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ Variavel que definira as cores do browse                            ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/

Private aCores  := {} 

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ Array com as cores do browse                                        ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/

Aadd( aCores , { "Substr(F3_CFO,1,1) $ ('1,2,3')" , "BR_AMARELO"   	})  // Documento de Entrada
Aadd( aCores , { "Substr(F3_CFO,1,1) $ ('5,6,7')" , "BR_VERDE" 		})  // Documento de Saida

Eval( bFiltraBrw )    //Efetiva o Filtro antes da Chamada a mBrowse

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ฺฺฺ Abre a Tabela de Livros Fiscais                						ณ
ฺฺฺภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ*/

DbSelectArea(cAlias)
DbSetOrder(1)
MBrowse( , , , , cAlias, , , , ,3, aCores )

EndFilBrw( cAlias , @aIndex ) //Finaliza o Filtro

Return


/*ษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LEGBFATC บ Autor ณLuiz Fernando       บ Data ณ 04/12/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออน*/

User Function LEGBFATC( cAlias , nRecno , cOpcao )  

Local aLegenda := {}

Aadd( aLegenda , {"BR_VERDE"   , "Documento de Saida"    })
Aadd( aLegenda , {"BR_AMARELO" , "Documento de Entrada"  })

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ                              Monta Legenda                                 ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/

BrwLegenda( cCadastro , OemToAnsi("Legendas") , aLegenda )

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ชA_BFATC01บ Autor ณLuiz Fernandoบ  Data ณ 04/12/2013        บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDescricao ณVisualiza data e usuแrio que cancelou a nota fiscal        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Brasitech ( Gama Italy )                                  บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function A_BFATC01()

Local aArea    	:= GetArea()
Local oDlg     	:= Nil
Local oLbx     	:= Nil
Local cTitulo  	:= "Notas Canceladas"
Local cAliasQry := GetNextAlias()
Local cQuery    := ""
Local aVetor   	:= {}
Local cNota, cSerie

cNota := SF3->F3_NFISCAL
cSerie := SF3->F3_SERIE

cQuery := "Select DISTINCT F3_FILIAL,F3_NFISCAL,F3_SERIE,F3_CLIEFOR,F3_LOJA,F3_DTCANC, "
cQuery += "F2_X_DATA ,F2_X_USUAR,F1_X_DATA ,F1_X_USUAR,A1_NOME,A2_NOME,D2_PEDIDO "
cQuery += "FROM " + RetSQLName("SF3") + " F3 Left Outer Join " + RetSQLName("SF2") + " F2 ON "
cQuery += "F3_FILIAL = F2_FILIAL AND F3_NFISCAL = F2_DOC AND F3_SERIE = F2_SERIE AND F3_CLIEFOR = F2_CLIENTE AND F3_LOJA = F2_LOJA "
cQuery += "Left Outer Join " + RetSQLName("SF1") + " F1 ON "
cQuery += "F3_FILIAL = F1_FILIAL AND F3_NFISCAL = F1_DOC AND F3_SERIE = F1_SERIE AND F3_CLIEFOR = F1_FORNECE AND F3_LOJA = F1_LOJA "
cQuery += "left outer join "
cQuery += "(SELECT A1_FILIAL,A1_COD,A1_LOJA,A1_NOME FROM "+ RetSqlName("SA1") + " WHERE D_E_L_E_T_ = '' ) A1 on F3_FILIAL = A1_FILIAL and  F3_CLIEFOR = A1_COD and F3_LOJA = A1_LOJA "
cQuery += "left outer join "
cQuery += "(SELECT A2_FILIAL,A2_COD,A2_LOJA,A2_NOME FROM "+ RetSqlName("SA2") + " WHERE D_E_L_E_T_ = '' ) A2 on F3_FILIAL = A2_FILIAL and  F3_CLIEFOR = A2_COD and F3_LOJA = A2_LOJA "
cQuery += "left outer join "
cQuery += "(SELECT DISTINCT D2_FILIAL,D2_DOC,D2_SERIE,D2_PEDIDO,D2_CLIENTE,D2_LOJA FROM SD2010 ) D2 ON "
cQuery += "F3_FILIAL = D2_FILIAL AND F3_NFISCAL = D2_DOC AND F3_SERIE = D2_SERIE AND F3_CLIEFOR = D2_CLIENTE AND F3_LOJA = D2_LOJA "
cQuery += "WHERE F3_FILIAL = '"+ xFilial("SF3") + "' AND F3_OBSERV LIKE '%CANCELADA%' and F3.D_E_L_E_T_ = '' AND "
cQuery += "substring(F3_CFO,1,1) IN ('1','2','3','5','6','7') AND F3_NFISCAL = '" + cNota + "' AND F3_SERIE = '" + cSerie + "' "

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verificando se a existencia da area TRB      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
if Select(cAliasQry) > 0
	dbSelectArea(cAliasQry) 
	dbCloseArea()
endif


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Criando a tabela temporaria                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cQuery := ChangeQuery(cQuery)
Memowrite("NFCANCEL.Sql" , cQuery )
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
TcSetField(cAliasQry,"F3_DTCANC","D")
TcSetField(cAliasQry,"F2_X_DATA","D")
TcSetField(cAliasQry,"F1_X_DATA","D")   

dbSelectArea(cAliasQry)
dbGotop()

While !(cAliasQry)->(EoF())
	aAdd( aVetor , {	(cAliasQry)->D2_PEDIDO ,;
	(cAliasQry)->F3_NFISCAL ,;
  	(cAliasQry)->F3_SERIE 	,;
  	(cAliasQry)->F3_CLIEFOR ,;
   	(cAliasQry)->F3_LOJA 	,;
   	IIF(!empty((cAliasQry)->A1_NOME), (cAliasQry)->A1_NOME ,IIF(!empty((cAliasQry)->A2_NOME),(cAliasQry)->A2_NOME,"")),;
   	IIF(!empty((cAliasQry)->F2_X_DATA), (cAliasQry)->F2_X_DATA ,IIF(!empty((cAliasQry)->F1_X_DATA),(cAliasQry)->F1_X_DATA,"")),;
   	IIF(!empty((cAliasQry)->F2_X_USUAR),(cAliasQry)->F2_X_USUAR,IIF(!empty((cAliasQry)->F1_X_USUAR),(cAliasQry)->F1_X_USUAR,"")) })
   	
	(cAliasQry)->(DbSkip())
EndDo

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ                   Verifica se ha Dados no Log                            ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/

If Len( aVetor ) == 0
	Aviso( "Aten็ใo !" , "Nใo hแ dados para consulta !" , {"Ok"}  )
Else

   /*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
     ณ               Monta a Tela com o Resultado da Consulta                   ณ
     ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
//40,40,40,15,40,40,15,15,15,40,40,40 
   Define MsDialog oDlg Title cTitulo From 0,0 To 560,1080 Pixel

   @ 20 , 10 ListBox oLbx Fields Header  "Pedido","Documento", "Serie ", "Codigo  ", "Loja" ,"Nome Cliente ", "Data Cancelamento", "Usuแrio Cancel." Size 520 , 230	 Of oDlg Pixel ColSizes 30,40,20,40,15,100,35,50

   oLbx:SetArray( aVetor )
   oLbx:bLine := {|| {aVetor[oLbx:nAt,1] , aVetor[oLbx:nAt,2] , aVetor[oLbx:nAt,3] , aVetor[oLbx:nAt,4] , aVetor[oLbx:nAt,5] , aVetor[oLbx:nAt,6] , aVetor[oLbx:nAt,7], aVetor[oLbx:nAt,8]  }}
					
   Define SButton From 260,500 Type 1 Action oDlg:End() Enable Of oDlg
   Activate MsDialog oDlg Center

Endif


/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ                     Fecha o Arquivo Temporario                           ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/

DbSelectArea(cAliasQry)
DbCloseArea()

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ                   Restaura as Areas Selecionadas                         ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/

RestArea( aArea )

Return


Return