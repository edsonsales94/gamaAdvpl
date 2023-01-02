#Include "Protheus.ch"
#Include "Rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CLIPRODSQL  º Autor ³Luiz Fernando º Data ³ 19/11/2009     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Tela de Consulta Cliente                   				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasitech ( Gama Italy )                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CLIPRODSQL

Private cCadastro := "Consulta Cliente x Produto"
Private cAlias    := "SA1"
Private nPosCodPBon  := 0
Private nPosDesPBon  := 0
Private nPosQtdProm  := 0

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta um aRotina proprio                                            ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Private aRotina := {{ "&Pesquisar"	 ,	"AxPesqui"	, 0 , 1 } ,;
					{ "&Visualizar" ,"AxVisual" 	, 0 , 2 } ,;
					{ "&Consulta","U_ConCLIPROSQL"	, 0 , 2}}

Private cDelFunc := ".T."  // Validacao para a exclusao. Pode-se utilizar ExecBlock

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Abre a Tabela de Clientes                     ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

DbSelectArea("SA1")
DbSetOrder(1)

MBrowse( , , , , "SA1", , , , , 3)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ConCLIPROSQLº Autor ³Luiz Fernandoº  Data ³ 19/11/2009     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Lista relação de Notas a  partir de um cliente e um produtoº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasitech ( Gama Italy )                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ConCLIPROSQL()

Local aArea    := GetArea()
Local oDlg     := Nil
Local oLbx     := Nil
Local cTitulo  := "Clientes x Produtos"
Local cAliasQry := GetNextAlias()
Local cQuery    := ''
Local cVarCodCli , cVarNomeCli
Local cNomeCli , cCliePol , cLojaCli

Private cPerg       := "CLIPROD"
Private nChave   := 0
Private cChave   := ""
Private aVetor   := {}

AjustaSX1()

if !Pergunte(cPerg,.T.)
	return
endif

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Atribui as Variaveis caso a Rotina seja Cadastro de Clientes        ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/


cCliePol := SA1->A1_COD
cLojaCli := SA1->A1_LOJA
cNomeCli := SA1->A1_NOME


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Monta a expressão de consulta SQL					    	 	    ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/


cQuery += "SELECT rtrim(SD2.D2_DOC) as 'D2_DOC',"  
cQuery += "rtrim(SD2.D2_SERIE) as 'D2_SERIE',"
cQuery += "rtrim(SD2.D2_EMISSAO) as 'D2_EMISSAO',"
cQuery += "rtrim(SD2.D2_PEDIDO) as 'D2_PEDIDO'," 
cQuery += "rtrim(SD2.D2_TES) as 'D2_TES'," 
cQuery += "rtrim(SF4.F4_FINALID) as 'F4_FINALID'," 
cQuery += "rtrim(SD2.D2_COD) as 'D2_COD'," 
cQuery += "SD2.D2_LOCAL ," 
cQuery += "SD2.D2_QUANT ," 
cQuery += "SD2.D2_PRCVEN ," 
cQuery += "SD2.D2_TOTAL , "
cQuery += "'' AS 'D1_NFORI',"
cQuery += "SD2.D2_QTDEDEV , "
cQuery += "TBLDEV.D1_DOC ,"
cQuery += "TBLDEV.D1_EMISSAO "
cQuery += "FROM " + RetSQLName( "SD2" ) + " SD2 LEFT OUTER JOIN ( "
cQuery += "SELECT DISTINCT D1.D1_FILIAL,D1.D1_COD,D1.D1_DOC,D1.D1_EMISSAO,D1.D1_NFORI,D1.D1_SERIORI,D1.D1_ITEMORI "
cQuery += "FROM " + RetSQLName( "SD1" ) + " D1 RIGHT OUTER JOIN " + RetSQLName( "SD2" ) + " D2 " 
cQuery += "ON  D1.D1_NFORI = D2.D2_DOC AND D1.D1_SERIORI = D2.D2_SERIE AND D1.D1_ITEMORI = D2.D2_ITEM AND "
cQuery += "D1.D1_COD = D2.D2_COD AND D1.D1_FILIAL = D2.D2_FILIAL "
cQuery += "WHERE "
cQuery += "D1.D1_TIPO = 'D' AND "
cQuery += "D1.D1_FILIAL = '"+ xFilial("SD1") + "' AND "
cQuery += "D2.D2_FILIAL = '"+ xFilial("SD2") + "' AND "
cQuery += "D1.D_E_L_E_T_ = ''  AND "
cQuery += "D2.D_E_L_E_T_ = '') "
cQuery += "AS TBLDEV ON TBLDEV.D1_NFORI = SD2.D2_DOC AND TBLDEV.D1_COD = SD2.D2_COD "
cQuery += "LEFT OUTER JOIN "+ RetSQLName( "SF4" ) + " SF4  ON SD2.D2_TES = SF4.F4_CODIGO "
cQuery += "WHERE "
cQuery += "SD2.D2_FILIAL = '" + xFilial("SD2") + "' AND "          
cQuery += "SD2.D2_CLIENTE = '" + cCliePol + "' AND "
cQuery += "SD2.D2_LOJA = '" + cLojaCli + "' AND "
cQuery +="SD2.D2_COD >= '" + MV_PAR01 + "' AND "
cQuery +="SD2.D2_COD <= '" + MV_PAR02 + "' AND "
cQuery +="SD2.D2_EMISSAO >= '" + DtoS(MV_PAR03) + "' AND "
cQuery +="SD2.D2_EMISSAO <= '" + DtoS(MV_PAR04) + "' AND "
cQuery += "SD2.D_E_L_E_T_ = ''"+ " AND "
cQuery += "SF4.D_E_L_E_T_ = '' "
cQuery += "UNION "
cQuery += "select DISTINCT  SD1.D1_DOC,"
cQuery += "SD1.D1_SERIE,"
cQuery += "SD1.D1_EMISSAO,"
cQuery += "SD1.D1_PEDIDO AS 'PEDIDO',"
cQuery += "SD1.D1_TES,"
cQuery += "SF4.F4_FINALID,"
cQuery += "SD1.D1_COD,"
cQuery += "SD1.D1_LOCAL ," 
cQuery += "SD1.D1_QUANT,"
cQuery += "SD1.D1_VUNIT,"
cQuery += "D1_TOTAL,"
cQuery += "SD1.D1_NFORI,"
cQuery += "'' as 'D2_QTDEDEV',"
cQuery += "'' AS 'D1_DOC',"
cQuery += "'' AS 'D1_EMISSAO' "
cQuery += "FROM " + RetSQLName( "SD1" ) + " SD1 "
cQuery += "LEFT OUTER JOIN "+ RetSQLName( "SF4" ) + " SF4  ON SD1.D1_TES = SF4.F4_CODIGO "
cQuery += "WHERE SD1.D1_FILIAL = '" + xFilial("SD1") + "' AND "
cQuery += "SD1.D1_FORNECE = '" + cCliePol + "' AND "
cQuery += "SD1.D1_LOJA = '" + cLojaCli + "' AND "
cQuery +="SD1.D1_COD >= '" + MV_PAR01 + "' AND "
cQuery +="SD1.D1_COD <= '" + MV_PAR02 + "' AND "
cQuery +="SD1.D1_EMISSAO >= '" + DtoS(MV_PAR03) + "' AND "
cQuery +="SD1.D1_EMISSAO <= '" + DtoS(MV_PAR04) + "' AND "
cQuery += "SD1.D_E_L_E_T_ = ''"+ " AND "
cQuery += "SF4.D_E_L_E_T_ = '' "
cQuery += "order by 1,2"



cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)



Memowrite("CLIPROD.Sql" , cQuery )


While !(cAliasQry)->(EoF())
	
	aAdd( aVetor , {	(cAliasQry)->D2_DOC ,;
  	(cAliasQry)->D2_SERIE ,;
	SubStr((cAliasQry)->D2_EMISSAO,7,2)+"/"+SubStr((cAliasQry)->D2_EMISSAO,5,2)+ "/" + SubStr((cAliasQry)->D2_EMISSAO,1,4) ,;
	(cAliasQry)->D2_PEDIDO ,;
	(cAliasQry)->D2_TES ,;
	 alltrim((cAliasQry)->F4_FINALID) ,;
	(cAliasQry)->D2_COD ,;
	(cAliasQry)->D2_LOCAL ,;	
	Transform((cAliasQry)->D2_QUANT,"@E 999,999") ,;
	Transform((cAliasQry)->D2_PRCVEN, "@E 999,999.99"),;
	Transform((cAliasQry)->D2_TOTAL,"@E 999,999.99"),;
	Transform((cAliasQry)->D2_QTDEDEV,"@E 999,999") ,;	 
	(cAliasQry)->D1_DOC ,;
	SubStr((cAliasQry)->D1_EMISSAO,7,2)+"/"+SubStr((cAliasQry)->D1_EMISSAO,5,2)+ "/" + SubStr((cAliasQry)->D1_EMISSAO,1,4)})
	 
	//Transform(nTOTAL,"@E 999,999.99")       exemplo do comando  TRANSFORM 
	
	(cAliasQry)->(DbSkip())
	
EndDo



/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Verifica se há dados com os parâmetros informados                   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

If Len( aVetor ) == 0
	Aviso( cTitulo, "Nao há dados para consulta !", {"Ok"} )
	Return
Endif


//+-----------------------------------------------+
//| Monta a tela para usuario visualizar consulta |
//+-----------------------------------------------+


DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 610,1070 PIXEL

@ 10,10 Say "Cod. Cliente:" PIXEL OF oDlg 
@ 10,50 Say cVarCodCli var cCliePol size 40,40 PIXEL OF oDlg
@ 10,80 Say "Loja Cliente:" PIXEL OF oDlg
@ 10,120 Say cVarLojaCli var cLojaCli size 20,40 PIXEL OF oDlg 
@ 10,150 Say "Nome Cliente:" PIXEL OF oDlg
@ 10,200 Say cVarNomeCli var cNomeCli size 200,40 PIXEL OF oDlg 
@ 20,10 LISTBOX oLbx FIELDS HEADER ;
   "Nota Fiscal","Serie", "Data Emissao", "Pedido", "TES", "Operação", "Produto","Armazem", "Quantidade", "Valor Unitário", "Valor Total",;
	"Qtde Devolvida","Nota Devolução","DT EMISSAO NF DEVOL"   SIZE 520,270	OF oDlg PIXEL	ColSizes 40,15,40,40,15,40,40,15,15,15,15,40,40,40

oLbx:SetArray( aVetor )
oLbx:bLine := {|| {aVetor[oLbx:nAt,1],;
                   aVetor[oLbx:nAt,2],;
                   aVetor[oLbx:nAt,3],;
                   aVetor[oLbx:nAt,4],;
                   aVetor[oLbx:nAt,5],;
                   aVetor[oLbx:nAt,6],;
                   aVetor[oLbx:nAt,7],;
                   aVetor[oLbx:nAt,8],;
                   aVetor[oLbx:nAt,9],;
                   aVetor[oLbx:nAt,10],; 
                   aVetor[oLbx:nAt,11],;
                   aVetor[oLbx:nAt,12],;
                   aVetor[oLbx:nAt,13],;
				   aVetor[oLbx:nAt,14]}}
					
Define SButton From 290,460 Type 14 Action u_LoadSF2(aVetor[oLbx:nAt,1],aVetor[oLbx:nAt,2]) Enable Of oDlg	                    
DEFINE SBUTTON FROM 290,490 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTER


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta Tela para o Usuario Visualr os Dados                     ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
/*
Define MsDialog oDlg Title cTitulo From 0,0 To 400,900 Pixel

@10,10 Say " NF  -          Data Emissão  -   Pedido  -      TES  - "  Pixel Of oDlg   
@10,400 Say "Produto  - Quantidade  - Valor Unitario  - Valor Total" Pixel Of oDlg
@ 20 , 10 ListBox oLbx Var nChave Items aVetor Size 420,150 Of oDlg Pixel
oLbx:bChange := {|| cChave := SubStr ( aVetor [nChave] , 1 , 11 ) }

Define SButton From 190,390 Type 14 Action u_LoadSF2( SubStr ( aVetor [nChave] , 1 , 09 ) ) Enable Of oDlg
Define SButton From 190,420 Type  1 Action oDlg:End() Enable Of oDlg Pixel

Activate MsDialog oDlg Center
*/
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Restaura o Posicionamento dos Arquivos antes de Executar a Rotina   	³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

RestArea( aArea )

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |  LoadSF2  ³ Autor ³Luiz Fernando                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Carrega os dados da NF selecionada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Num da Nota                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function LoadSF2(cNumNF,cSeriNF)

local nReg


DbSelectArea("SF2")
dbSetOrder(1)
DbGoTop()

IF !DbSeek(xFilial("SF2") + cNumNF + cSeriNF)
	MsgAlert("Nota não localizada")
else
	nReg := SF2->(RECNO())
endif

Mc090Visual( "SF2" , Nreg , 2 )

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AjustaSX1  ³ Autor ³Luiz Fernando                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Inclui Perguntas no SX1                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AjustaSX1()
PutSx1( 	"CLIPROD","01","Do Produto:","","",;
"mv_ch1","C",15,0,1,"G","","SB1","","",;
"mv_par01")

PutSx1( 	"CLIPROD","02","Ate o Produto:","","",;
"mv_ch2","C",15,0,1,"G","","SB1","","",;
"mv_par02")

PutSx1( 	"CLIPROD","03","Da Emissão:","","",;
"mv_ch2","D",15,0,1,"G","","","","",;
"mv_par03")

PutSx1( 	"CLIPROD","04","Ate Emissão:","","",;
"mv_ch2","D",15,0,1,"G","","","","",;
"mv_par04")


Return .T.






