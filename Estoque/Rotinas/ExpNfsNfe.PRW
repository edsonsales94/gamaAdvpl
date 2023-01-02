#Include "Rwmake.ch" 
#Include "TopConn.CH"
#Include "TbiConn.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ExpNfsNfe º Autor ³ Cristiano Figueiroaº Data ³  30/04/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gera Pre Nota Fiscal de Entrada com Base na Nota Fiscal.    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasitech                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function ExpNfsNfe

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                 Declara as Variaveis Utilizadas na Rotina                  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Private cPerg     := "EXPNFSNFE "
Private nOpc      := 0
Private cCadastro := "Rotina de Geracao de Pre-Nota de Entrada"
Private aSay      := {}
Private aArea     := GetArea()
Private aButton   := {} 

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³           Verifica se o Grupo de Perguntas existe ou nao                   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

ValidPerg( cPerg )

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³               Carrega o Grupo de Perguntas na Tela                         ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Pergunte( cPerg , .F. )

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³           Monta a Janela de Dialogo com as Mensagens Explicativas          ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

aAdd ( aSay, "" )
aAdd ( aSay, "Essa rotina tem como objetivo Gerar Pre Notas de Entrada com base em Notas de Saida." )
aAdd ( aSay, "Apenas as Notas que tiverem Pedidos de Vendas com Flag de Geracao ( C5_PRENF )" )
aAdd ( aSay, "terao suas Notas Fiscais de Saida consideradas para a Geracao da Pre Nota de Entrada" )
aAdd ( aSay, "na outra empresa do Grupo." )
aAdd ( aSay, "Desenvolvida Especificamente para a Brasitech" )
aAdd ( aSay, "" )
aAdd ( aSay, "" )
aAdd ( aSay, "" )

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³              Monta a os Botoes a serem Disponibilizados na Tela            ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

aAdd ( aButton , { 1 , .T. , { || nOpc := 1  , FechaBatch() }} )
aAdd ( aButton , { 2 , .T. , { || FechaBatch()              }} )
aAdd ( aButton , { 5 , .T. , { || Pergunte( cPerg , .T. )   }} )

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³              Abre a Tela para o Processamento das Opcoes                   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

FormBatch( cCadastro , aSay , aButton )

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³     Caso o Usuario Tenha acessado o Botao de Ok inicia o processamento     ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

If nOpc == 1

   If Aviso("Atenção !" , "Confirma a Geração das Pré-Notas ? " , {"Sim","Não"} , 1 , "Confirma o Processamento ?" ) ==  1 
      Processa( { |lEnd| u_SelNfsNfe() } , "Geração de Pré-Notas " , "Aguarde..." , .T. )
   Endif   

Endif   

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Fecha os Arquivos Temporarios e Restaura as Areas Antes da Execucao da Rotina  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

RestArea(aArea)

Return                      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SelNfsNfe  º Autor ³ Cristiano Figueiroaº Data ³  04/05/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Seleciona as Notas Fiscais de Saida para a Geracao da Pre    º±±
±±º          ³ Nota de Entrada.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasitech                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SelNfsNfe()
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                 Declara as Variaveis Utilizadas na Rotina                  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local cQuery     := ""                       
Local cDocumento := ""
Local cSerie     := ""
Local cCliente   := ""
Local cLoja      := ""
Local aCabec     := {}
Local aLinha     := {}
Local aItens     := {}
Local aInf       := {}
Local cInfEmp    := ""
Local cInfFil    := ""
Local cTipoNFE   := ""
Local nCusto
Local aInfNota	:= {}
Local dData		:= DATE() 
Local cTime		:= TIME() 
Private aOcorr   := {}
Private cCnpjOri := SM0->M0_CGC
Private cCodFor := ""
Private cLojFOr := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Query para Selecao de notas fiscais ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_EMISSAO, SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_UM, SD2.D2_LOCAL, "
cQuery += 		  "SD2.D2_ITEM, SD2.D2_COD, SD2.D2_QUANT, SD2.D2_PRCVEN, SD2.D2_TOTAL, SD2.D2_VALIPI, SD2.D2_VALICM, "
cQuery += 		  "SD2.D2_IPI, SD2.D2_PICM, SD2.D2_TES, SD2.D2_TIPO, SC5.C5_CODEMP, SC5.C5_CODFIL, SC5.C5_XTIPONF "
cQuery += "FROM " + RetSqlName("SD2") + " SD2, " + RetSqlName("SC5") + " SC5 "
cQuery += "WHERE SC5.C5_NUM = SD2.D2_PEDIDO "
cQuery += 		 "AND SC5.C5_PRENF = '1' "
cQuery += 		 "AND SD2.D2_FILIAL = SC5.C5_FILIAL "
cQuery += 		 "AND SD2.D2_DOC BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "
cQuery += 		 "AND SD2.D2_EMISSAO BETWEEN '" + dTOs(mv_par04) + "' AND '" + dTOs(mv_par05) + "' "
cQuery += 		 "AND SD2.D2_SERIE = " + "'" + mv_par03 + "' "
cQuery += 		 "AND SD2.D_E_L_E_T_ = '' "
cQuery += 		 "AND SC5.D_E_L_E_T_ = '' "
cQuery += 		 "AND SD2.D2_FILIAL='"+xFilial("SD2")+"' "

cQuery :=  ChangeQuery( cQuery )
memowrite("expnfsnfe.sql",cQuery)

TcQuery cQuery New Alias "NFS_QRY"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta os Campos Apos a Execucao da Query ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TcSetField("NFS_QRY", "D2_EMISSAO", "D", 08, 0)
TcSetField("NFS_QRY", "D2_QUANT", "N", 14, 2)
TcSetField("NFS_QRY", "D2_PRCVEN", "N", 14, 5)
TcSetField("NFS_QRY", "D2_TOTAL", "N", 14, 2)
TcSetField("NFS_QRY", "D2_VALIPI", "N", 14, 2)
TcSetField("NFS_QRY", "D2_VALICM", "N", 14, 2)
TcSetField("NFS_QRY", "D2_IPI", "N", 12, 2)
TcSetField("NFS_QRY", "D2_PICM", "N", 12, 2)

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                       Localiza código da empresa origem como fornecedor		³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
// Alterado a busca para depois de logar na filial destino - Luiz Fernando 31/05/2017
/*
DbSelectArea("SA2")
DbSetOrder(3)
If dbseek ( xFilial("SA2") + cCnpjOri )
  cCodFor := SA2->A2_COD
  cLojFOr := SA2->A2_LOJA
else
	MsgBox("O CNPJ " + Transf(cCnpjOri,"@R 99.999.999/9999-99") + " não está cadastrado como fornecedor na filial destino.","AtençÃo","INFO")
	If Select("NFS_QRY") > 0
	   DbSelectArea("NFS_QRY")
	   DbCloseArea()
	EndIf
	Return()
Endif
*/


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                       Appenda a Query na Tabela                            ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
DbSelectArea("NFS_QRY")
DbGotop()
ProcRegua( NFS_QRY->( Reccount() ) )   


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                     Processa os Itens da Nota Fiscal                       ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
NFS_QRY->(dbGoTop())
Do While NFS_QRY->( !Eof() )
                           
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                    Adiciona a Regua de Processamento                       ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

  IncProc( "Gerando a Pré-Nota Número : " + NFS_QRY->D2_DOC )

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³               Guarda os Dados da Nota que Sera Processada                      ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

   cInfEmp    := NFS_QRY->C5_CODEMP
   cInfFil    := NFS_QRY->C5_CODFIL
   cDocumento := NFS_QRY->D2_DOC
   cSerie     := NFS_QRY->D2_SERIE
   cCliente   := NFS_QRY->D2_CLIENTE
   cLoja      := NFS_QRY->D2_LOJA
   cTipoNFE	  := NFS_QRY->C5_XTIPONF
   aItens     := {}
   aCabec     := {}
   aLinha     := {}


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³            Monta o Array com o Cabecalho da Nota Fiscal de Entrada             ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
//					{"F1_FORNECE",	cCodFor,				Nil },;
//					{"F1_LOJA",		cLojFOr,				Nil },;

   aCabec :=   {	{"F1_TIPO",		NFS_QRY->C5_XTIPONF,	Nil },;
		    		{"F1_FORMUL",	"N",					Nil },;
					{"F1_DOC",		NFS_QRY->D2_DOC,		Nil },;
			  		{"F1_SERIE",	NFS_QRY->D2_SERIE,		Nil },;
					{"F1_EMISSAO",	NFS_QRY->D2_EMISSAO,	Nil },;
					{"F1_ESPECIE",	"SPED",					Nil },;
					{"F1_XDATA",	dData ,					Nil },;
					{"F1_XHORA",	cTime  ,				Nil },;
					{"F1_XUSUAR",	SubStr(cUsuario,7,15),	Nil	}} 	//Nome do Usuario
				  

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³             Armazena todos os itens da Nota de Saida no Array              ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
   Do While NFS_QRY->( !Eof() ) .And. NFS_QRY->D2_DOC     == cDocumento ;
                                 .And. NFS_QRY->D2_SERIE   == cSerie     ;
                                 .And. NFS_QRY->D2_CLIENTE == cCliente   ;
                                 .And. NFS_QRY->D2_LOJA    == cLoja

	//Busca custo do item
	aInfNota := {NFS_QRY->D2_DOC, NFS_QRY->D2_SERIE, NFS_QRY->D2_CLIENTE, NFS_QRY->D2_LOJA, NFS_QRY->D2_COD, NFS_QRY->D2_EMISSAO}
	nCusto	 := (FindCusto(aInfNota, cInfEmp, cInfFil) * NFS_QRY->D2_QUANT)

   /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     ³                Monta o array com os Itens da Nota de Saida                 ³
     ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
      aLinha := {	{"D1_ITEM",		NFS_QRY->D2_ITEM, 	Nil },;
	     			{"D1_COD",		NFS_QRY->D2_COD, 	Nil },;
	     			{"D1_UM",		NFS_QRY->D2_UM, 	Nil },;
	     			{"D1_LOCAL",	NFS_QRY->D2_LOCAL, 	Nil },;
			    	{"D1_QUANT",	NFS_QRY->D2_QUANT, 	Nil },;
				  	{"D1_VUNIT",	NFS_QRY->D2_PRCVEN,	Nil },;
					{"D1_TOTAL",	NFS_QRY->D2_TOTAL,	Nil },;
					{"D1_EMISSAO",	dDataBase, 			Nil },;
					{"D1_VALIPI",	NFS_QRY->D2_VALIPI,	Nil },;
					{"D1_VALICM",	NFS_QRY->D2_VALICM,	Nil },;
					{"D1_IPI",		NFS_QRY->D2_IPI,	Nil },;
					{"D1_PICM",		NFS_QRY->D2_PICM,	Nil },;
					{"D1_CUSGAMA",	nCusto, 			Nil }	}

   /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     ³             Adiciona no Array com todos os Itens da Nota                   ³
     ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
      aAdd(aItens, aLinha)

   /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     ³             Processa o Proximo Item da Nota Fiscal de Saida                ³
     ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
      NFS_QRY->( dbSkip() )

   Enddo
   
 /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³             Chama a Rotina que Gera a Pre Nota de Entrada                  ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

   StartJob( "u_PrcNfsNfe" , GetEnvServer() , .T. , cInfEmp , cInfFil , aCabec , aItens, cCnpjOri )
   
   /* exemplo de degub    
   
   For nX := 1 To Len(aSM0) 
     // sub jobs 
     StartJob("U_EXEMPLO01",GetEnvServer(),.F., { aSM0[nX][1], aSM0[nX][2], ‘20120101‘,‘20120131‘ } ) 
     // U_EXEMPLO01( { aSM0[nX][1], aSM0[nX][2], ‘20100101‘, ‘20100131‘ } ) // utilize esta linha para debugar 
Next nX               
   */
   
   
   //alert("1") ricky
   DbSelectArea("NFS_QRY") 

Enddo

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Fecha os Arquivos Temporarios e Restaura as Areas Antes da Execucao da Rotina  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
//ricky
//alert(NFS_QRY->D2_DOC + "OK")

If Select("NFS_QRY") > 0
   DbSelectArea("NFS_QRY")
   DbCloseArea()
EndIf

//#Aviso( "Geração de Pré Notas de Entrada!" , "Verifique o Log do Processamento na Pasta C:\TEMP\" , {"Ok"} , 1 , "Final do Processamento" )

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PrcNfsNfe  º Autor ³ Cristiano Figueiroaº Data ³  04/05/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Processa a Geração da Pre Nota Fiscal de Entrada com base    º±±
±±º          ³ na Nota Fiscal de Saida.                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasitech                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function PrcNfsNfe( cEmp , cFil , aCab , aIte, cCnpjOri )

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                 Declara as Variaveis Utilizadas na Rotina                  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Local   aArea           := GetArea()
Local   cFile           := ""
Private nModulo         := 99
Private nOpc            :=  3
Private lRefresh        := .T.
Private lMsErroAuto		:= .F.
Private lMsHelpAuto		:= .T.
Private lAutoErrNoFile	:= .F.     
Private __cInterNet     := Nil
Private cTxtErro        := ""

MakeDir("C:\TEMP")

//   alert("2")
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³             Abre a Empresa Destino Onde a Pre Nota Sera Gerada             ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Prepare Environment Empresa cEmp Filial cFil User 'siga' PassWord 't58220' Modulo "EST" Tables "SF1","SD1","SA1","SA2","SB1","SB2","SF4"

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                       Localiza código da empresa origem como fornecedor		³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
DbSelectArea("SA2")
DbSetOrder(3)
If dbseek ( xFilial("SA2") + cCnpjOri )
  cCodFor := SA2->A2_COD
  cLojFOr := SA2->A2_LOJA
else
	MsgBox("O CNPJ " + Transf(cCnpjOri,"@R 99.999.999/9999-99") + " não está cadastrado como fornecedor na filial destino.","AtençÃo","INFO")
	If Select("NFS_QRY") > 0
	   DbSelectArea("NFS_QRY")
	   DbCloseArea()
	EndIf
	Return()
Endif

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³           Verifica se existem Itens para Geracao da Pre Nota de Entrada        ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
//   alert("3")

If Len ( aCab ) > 0 .And. Len ( aIte ) > 0

	aAdd ( aCab, {"F1_FORNECE",	cCodFor,				Nil })
	aAdd ( aCab, {"F1_LOJA",		cLojFOr,				Nil })

   MsAguarde({|| MSExecAuto({ | x , y , z | MATA140( x , y , z )} , aCab , aIte , 3 ) } , "Gerando Pre-Nota de Entrada" )
//   alert("4")

 /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³                   Chama a Rotina que exibe as Mensagens de Erro                ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
         
	If !lMsErroAuto
		Conout( "*** Pré Nota Fiscal Incluida com Sucesso !! ***" )
		cTxtErro := MostraErro()
		cFile := 'NF_' + aCab[3][2] + '_OK' + ".LOG"
//		Memowrite( cFile, cTxtErro )
//		Memowrite( "C:\TEMP\" + cFile, cTxtErro )
		
	Else
		Conout( "*** Erro na Inclusão da Pré Nota !! ***")
		cTxtErro := MostraErro()
		cFile := 'NF_' + aCab[3][2] + '_REJ' + ".LOG"
		Memowrite( cFile, cTxtErro )
		Memowrite( "C:\TEMP\" + cFile, cTxtErro )

		if MsgBox("Deseja ler o log (C:\TEMP\" + cFile + ") de inconsistências do processamento?","Informação","YESNO")
			if file("C:\WINDOWS\NOTEPAD.EXE")
				WinExec("C:\WINDOWS\NOTEPAD.EXE C:\TEMP\" + cFile, 3)
			else
				WinExec("C:\WINNT\NOTEPAD.EXE C:\TEMP\" + cFile, 3)
			endif
		endif
	EndIf

Endif

Reset Environment
  
Return
            
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GatVerEmp º Autor ³ Cristiano Figueiroa º Data ³  04/05/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Gatilho que Retorna se eh uma empresa do Grupo no campo      º±±
±±º          ³C5_PRENF da tela do Pedido de Vendas.                       .º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasitech                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GatVerEmp( cCodCli , cLojCli )

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Declaracao de Variaveis Utilizadas na Rotina                        ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Local aVerEmp := {}
Local cRet

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³           Chama a Funcao que Verifica se eh uma Empresa do Grupo           ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

aVerEmp := u_GenVerEmp( cCodCli , cLojCli )

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                     Atribui as Variaveis de Tela                           ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

cRet         	:= Iif ( aVerEmp[1][1] == .F. , "2" , "1" ) 
M->C5_PRENF  	:= Iif ( aVerEmp[1][1] == .F. , "2" , "1" ) 
M->C5_CODEMP 	:= 	aVerEmp[1][2]
M->C5_CODFIL 	:= 	aVerEmp[1][3]
M->C5_XTIPONF 	:=	aVerEmp[1][4]

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                     Retorna se e uma Empresa do Grupo                      ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GenVerEmp º Autor ³ Cristiano Figueiroa º Data ³  30/04/2010 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Verifica se o cliente informado existe no cadastro de        º±±
±±º          ³empresas do sistema de acordo com seu Cnpj cadastrado no SM0.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cCodCli  - Codigo do Cliente                                º±±
±±º          ³ cLojCli  - Loja do Cliente                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³* Array contendo as informacoes da Empresa do Grupo          º±±
±±º          ³                                                             º±±
±±º          ³  - Variavel Logica Indicando se eh uma Empresa do Grupo     º±±
±±º          ³  - Codigo da Empresa                                        º±±
±±º          ³  - Filial da Empresa                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasitech                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function GenVerEmp( cCodCli , cLojCli )
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Declaracao de Variaveis Utilizadas na Rotina                        ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local aAmbAtu   := GetArea()                      
Local aAmbEmp   := SM0->(GetArea())              
Local aAmbSa1   := SA1->(GetArea())              
Local cCnpjCli  := ""                             
Local aDadEmp   := {}
Local lTem      := .F.

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                 Abre o Cadastro de Clientes - SA1                   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
DbSelectArea("SA1")
DbSetOrder(1)       //  A1_FILIAL + A1_COD + A1_LOJA

 /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   ³             Posiciona no Cadastro de Clientes - SA1                 ³
   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If DbSeek( xFilial("SA1") + cCodCli + cLojCli )
   cCnpjCli := SA1->A1_CGC
Endif

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                  Abre o Cadastro de Empresas - SM0                  ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

DbSelectArea("SM0")
DbSetOrder(1)       //  M0_CODIGO + M0_FILIAL       
DbGoTop()

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ Processa todas as Empresas existentes no cadastro de empresas       ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Do While SM0->( !Eof() ) .And. !lTem
   
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³    Verifica se existe alguma empresa com o mesmo Cnpj do Cliente    ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

	If !empty(cCnpjCli) 
	if cCnpjCli == SM0->M0_CGC

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		  ³  Avisa no Pedido de Vendas que sera gerada uma Pre Nota de Entrada  ³
		  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

		If Funname() == "MATA410"
	
	        /*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	          ³            Caso Encontre a Empresa Alimenta as Variaveis            ³
	          ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
/*			if !l410Auto
//				If Aviso("Empresa do Grupo" , "O cliente selecionado no Pedido de Vendas é uma Empresa do Grupo. Confirma a Geração de Pré-Nota de Entrada na Empresa / Filial : " + Alltrim( SM0->M0_NOME ) + " - " + Alltrim( SM0->M0_FILIAL ) + " ? " , { "Sim" , "Não" } , 1 , "Selecione a Filial" ) == 1
					If Aviso("Importante!" , "Qual o tipo da Pré-Nota a ser gerada ?" , { "Normal" , "Beneficiamento" } , 1 , "Selecione o tipo da Pré-Nota" ) == 1
						Aadd( aDadEmp , {  .T. , SM0->M0_CODIGO , SM0->M0_CODFIL , "N" }  )
						lTem := .T.
					Else
						Aadd( aDadEmp , {  .T. , SM0->M0_CODIGO , SM0->M0_CODFIL , "B" }  )
						lTem := .T.
					Endif
//				Endif
			else
				lTem := .T.
			endif
*/	
	        //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	        //³ Retorna .T. para troca de notas entre empresas do grupo.             ³
	        //³ Por solicitacao do Luiz Fernando, eliminada pergunta se deseja gerar ³
	        //³ pre-nota de entrada na filial destino da mercadoria                  ³
	        //³ Por: Adalberto Moreno Batista em 08/04/13                            ³
	        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        lTem := .T.
	        if !l410Auto
				if Aviso("Empresa do Grupo" , "O cliente selecionado no pedido de vendas é uma empresa do grupo, portanto será gerada uma pré-nota de entrada na empresa / filial : " + Alltrim( SM0->M0_NOME ) + " - " + Alltrim( SM0->M0_FILIAL ) + ". Qual o tipo desta nota?", {"Normal" ,"Beneficiamento"}, 2, "Pergunta") == 1
					Aadd( aDadEmp , {  .T. , SM0->M0_CODIGO , SM0->M0_CODFIL , "N" }  )
				Else
					Aadd( aDadEmp , {  .T. , SM0->M0_CODIGO , SM0->M0_CODFIL , "B" }  )
				Endif
			endif

		Endif

	Endif
	Endif
	
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³                  Proxima empresa cadastrada                         ³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

   DbSkip()
   Loop

Enddo

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³           Caso nao seja empresa do grupo , retorna .F.              ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

If Len ( aDadEmp ) == 0
   Aadd ( aDadEmp , {  .F. , "" , "" , ""}  )
Endif

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³                  Restaura os Ambientes Anteriores                   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

RestArea( aAmbEmp )
RestArea( aAmbSA1 )
RestArea( aAmbAtu )

Return aDadEmp

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg º Autor ³ Analistas Microsiga º Data ³ 13/02/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Cria o Grupo de Perguntas conforme Array                    º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Brasitech                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ValidPerg( cPerg )

/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³            Declara as Variaveis Locais Utilizadas na Rotina                ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local aRegs := {}
Local i,j
/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³            Adiciona as Perguntas no Array a ser Gravado no SX1             ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdd( aRegs , { cPerg , "01" , "Da Nota Fiscal            ?    " , "            " , "            " , "MV_CH1" , "C" , 09 , 0 , 0 , "G" , "" , "MV_PAR01" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""})
aAdd( aRegs , { cPerg , "02" , "Ate a Nota Fiscal         ?    " , "            " , "            " , "MV_CH2" , "C" , 09 , 0 , 0 , "G" , "" , "MV_PAR02" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""})
aAdd( aRegs , { cPerg , "03" , "Qual a Serie              ?    " , "            " , "            " , "MV_CH3" , "C" , 03 , 0 , 0 , "G" , "" , "MV_PAR03" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""})
aAdd( aRegs , { cPerg , "04" , "Da Data de Emissao        ?    " , "            " , "            " , "MV_CH4" , "D" , 08 , 0 , 0 , "G" , "" , "MV_PAR04" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""})
aAdd( aRegs , { cPerg , "05" , "Ate a Data de Emissao     ?    " , "            " , "            " , "MV_CH5" , "D" , 08 , 0 , 0 , "G" , "" , "MV_PAR05" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""})


/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³            Verifica se Ja Existe Registro no SX1 e Grava                   ³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
DbSelectArea("SX1")
DbSetOrder(1)

For i := 1 to Len( aRegs )
   If !SX1->(dbSeek(cPerg+aRegs[i,2]))
      RecLock("SX1",.T.)
	  For j:=1 to FCount()
	     If j <= Len(aRegs[i])
		    FieldPut(j,aRegs[i,j])
		 Endif
	  Next
	  SX1->(MsUnlock())
   Endif
Next  

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ FindCusto    ³                               ³ Data ³04.07.2011³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FindCusto(aInfNota, cEmpDestino, cFilDestino)
Local nRet 		:= 0
Local cDoc		:= aInfNota[1]		//D2_DOC
Local cSerie	:= aInfNota[2]		//D2_SERIE
Local cEntidade	:= aInfNota[3]		//D2_CLIENTE
Local cLoja		:= aInfNota[4]		//D2_LOJA
Local cProd		:= aInfNota[5]		//D2_COD
Local dEmissao	:= aInfNota[6]		//D2_EMISSAO
Local aArea		:= GetArea()
Local aAreaSB2	:= SB2->(GetArea())
Local nDecimal	:= TamSX3("B2_CM1")[2]
Local cQuery, cSF4Filial

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha areas de trabalho TRBa ou TRBb         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if Select("TRBa") > 0
	TRBa->(dbCloseArea())
endif

if Select("TRBb") > 0
	TRBb->(dbCloseArea())
endif


if cEmpAnt == '01' .and. cFilAnt == '06' .and. cEmpDestino == '01' .and. cFilDestino == '03'
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ BRASITECH                                                                  ³
	//³ Para notas fiscais com entrada na filial 03 - Sao Paulo, provenientes da   ³
	//³ da filial 06 - Santa Catarina, o custo de entrada, na filial 03, sera o    ³
	//³ mesmo de uma nota de entrada, na filial 06, imediatamente anterior ao da   ³
	//³ nota de saida da filial 06                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery 	:= 	"SELECT TOP 1 D1_CUSTO, D1_QUANT " +;
				"FROM " + RetSQLName("SD1") + " SD1, " + RetSQLName("SF4") + " SF4 " +;
				"WHERE SD1.D1_FILIAL = '" + cFilAnt + "' " +;
						"AND SD1.D1_COD = '" + cProd + "' " +;
						"AND SD1.D1_DTDIGIT <= '" + dTOs(dEmissao) + "' " +;
						"AND SD1.D_E_L_E_T_ <> '*' " +;
						"AND SF4.F4_CODIGO = D1_TES " +;
						"AND SF4.F4_ESTOQUE = 'S' " +;
						"AND SF4.D_E_L_E_T_ <> '*' " +;
				"ORDER BY SD1.D1_DTDIGIT DESC, SD1.D1_NUMSEQ DESC"

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRBa", .F., .T.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Buscando custo da ultima nota de entrada antes da saida                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if TRBa->( !eof() )
		nRet := Round(TRBa->D1_CUSTO / TRBa->D1_QUANT, nDecimal)
	endif

elseif cEmpAnt == '01' .and. cFilAnt != '06' .and. cEmpDestino == '01' .and. (cFilDestino == '03' .or. cFilDestino == '04')
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ BRASITECH                                                                  ³
	//³ Para notas fiscais com entrada na filial 03 - Sao Paulo, provenientes de   ³
	//³ filiais que nao sejam a 06 - Santa Catarina, (1o.) o custo sera referente  ³
	//³ ao do ultimo fechamento na filial origem. Caso este custo seja igual a     ³
	//³ zero, deve (2o.) buscar o custo medio apurado no ultimo fechamento. Se     ³
	//³ mesmo assim for igual a zero, o custo sera o (3o.) medio do movimento do   ³
	//³ mes corrente na filial destino.                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 1o) Busco o custo medio do ultimo fechamento de estoque na filial corrente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery 	:= 	"SELECT TOP 1 SUM(SB9.B9_VINI1) B9_VINI1, SUM(SB9.B9_QINI) B9_QINI, SB9.B9_DATA " +;
				"FROM " + RetSQLName("SB9") + " SB9 " +;
				"WHERE SB9.B9_FILIAL = '" + cFilAnt + "' " +;
						"AND SB9.B9_COD = '" + cProd + "' " +;
						"AND SB9.D_E_L_E_T_ <> '*' " +;
				"GROUP BY SB9.B9_DATA " +;
				"ORDER BY SB9.B9_DATA DESC"

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRBa", .F., .T.)

	SB2->( dbSetOrder(1) )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Buscando ultimo custo fechado (SB9). Caso nao ache, busca o custo medio atual, na filial origem ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	TRBa->(dbGoTop())
	if TRBa->(!eof())
		nRet := Round(TRBa->B9_VINI1 / TRBa->B9_QINI, nDecimal)
	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 2o) Se o custo da 1a. etapa retornou zero, busco o custo da ultima nota    ³
	//³     fiscal, que tenha atualizado estoque e nao tenha controlado terceiros, ³
	//³     na filial corrente                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if nRet == 0
		cSF4Filial := xFilial("SF4")
		cQuery 	:= 	"SELECT TOP 1 SD2.D2_CUSTO1, SD2.D2_QUANT, SD2.D2_EMISSAO " +;
					"FROM " + RetSQLName("SD2") + " SD2, " + RetSQLName("SF4") +  " SF4 " +;
					"WHERE SD2.D2_FILIAL = '" + cFilAnt + "' " +;
							"AND SD2.D2_COD = '" + cProd + "' " +;
							"AND SD2.D2_EMISSAO <= '" + TRBa->B9_DATA + "' " +;
							"AND SD2.D_E_L_E_T_ <> '*' " +;
							"AND SF4.F4_FILIAL = '" + iif(Empty(cSF4Filial), cSF4Filial, cFilAnt) + "' " +;
							"AND SD2.D2_TES = SF4.F4_CODIGO " +;
							"AND SF4.F4_ESTOQUE = 'S' " +;
							"AND SF4.F4_PODER3 = 'N' " +;
							"AND SF4.D_E_L_E_T_ <> '*' " +;
					"ORDER BY SD2.D2_EMISSAO DESC"
	
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRBb", .F., .T.)

		TRBb->(dbGoTop())
		if TRBb->(!eof())
			nRet := Round(TRBb->D2_CUSTO1 / TRBb->D2_QUANT, nDecimal)
		endif

	endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 3o) Caso o retorno ainda seja zero, busco o custo unitario atual do produto³
	//³     na filial destino                                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if nRet == 0
		if SB2->( dbSeek( cFilDestino + cProd ) )
			nRet := SB2->B2_CM1		//campo com o custo medio unitario
		endif
	endif

endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha areas de trabalho TRBa ou TRBb         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if Select("TRBa") > 0
	TRBa->(dbCloseArea())
endif

if Select("TRBb") > 0
	TRBb->(dbCloseArea())
endif

RestArea(aAreaSB2)
RestArea(aArea)
Return(nRet)
