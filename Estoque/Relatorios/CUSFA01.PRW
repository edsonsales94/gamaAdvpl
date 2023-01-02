#include "rwmake.ch"                  
#include "topconn.ch"

/*_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-------------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ CUSFA01 ¦ Autor ¦ Ronaldo Gomes/Romualdo ¦ Data ¦ 18/09/2013  ¦¦
¦¦+----------+--------------------------------------------------------------+¦¦
¦¦¦Descrição ¦ Relatório - Custo de Fabricação                  		    ¦¦¦
¦¦¦          ¦                                                              ¦¦¦
¦¦+----------+--------------------------------------------------'-----------+¦¦
¦¦¦Parametros¦	                                        	                ¦¦¦
¦¦¦          ¦                                                              ¦¦¦
¦¦+----------+--------------------------------------------------------------+¦¦
¦¦¦Uso       ¦                                                              ¦¦¦
¦¦+----------------------------------- -------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function CUSFA01()
Local oReport 	              // Objeto relatorio TReport
Private cPerg := "CUSFA01" // Nome do grupo de perguntas
Private _cQrbPag:= ""

ValidPerg()
If !Pergunte(cPerg,.T.)
	
	Return
Endif

/*=================================
|  Monta a interface de impressao |
=================================*/
oReport := RLPRDFDEF()
oReport:PrintDialog()

Return

/*_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-------------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ RLPRDFDEF ¦ Autor ¦Ronaldo Gomes/Romualdo ¦Data ¦ 18/09/2013  ¦¦
¦¦+----------+--------------------------------------------------------------+¦¦
¦¦¦Descriçào ¦ Funcao auxiliar para impressao do relatorio                  ¦¦¦
¦¦+----------+--------------------------------------------------------------+¦¦
¦¦¦Parametros¦                                  	     		            ¦¦¦
¦¦¦          ¦                                                              ¦¦¦
¦¦+----------+--------------------------------------------------------------+¦¦
¦¦¦Uso       ¦                                                              ¦¦¦
¦¦+-------------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function RLPRDFDEF()
Local oReport
Local oSection1
Local oSection2    
Local oBreak
Local cNomeRel 	 := "CUSFA01"+cUserName             // Nome do relatorio
Local cTitulo 	 := "Relatório Custo de Fabricação"   	    // Titulo do relatorio
Local cDescri 	 := "Relatório Custo de Fabricação Sintético" 		// Descricao do relatorio
Local aOrdem	 := {}							    	   	        // Ordem de impressao do relatorio
Local cCabec1    := "Relatório "
Local cCabec2    := "Relação de Custo "


/*========================================
| Cria o Objeto de impressao             |
========================================*/
oReport := TReport():New(cNomeRel, cTitulo, cPerg, {|oReport| RunReport(oReport)}, cDescri)

/*========================================
| Define o tamanho da fonte.             |
========================================*/
oReport:nFontBody	:= 10

/*========================================
| Define a altura da linha.              |
========================================*/
oReport:nLineHeight	:= 48

/*========================================
| Define a posicao da pagina do relatorio|
========================================*/
oReport:SetLandScape()     // SetPortrait() Modo Retrato

/*=====================================================|
|   Define secao do relatorio                          |
======================================================*/
                                                                      //06,15,20
oSection1 := TRSection():New( oReport , cCabec1 , {}, aOrdem )	// Dados da nota       
oSection1:SetTotalInLine(.T.)      
 //*D3_OP,*C2_PRODUTO,B1_TIPO,B1_DESC,PA,MP,SA,EM,MO,TOTAL_APONTADO,TOTAL_HORAS,SUM(OI+MP+EM+PA+MC+MO) TOTAL_CUSTO_GERAL
TRCell():New( oSection1, "OP"    , , "Ord.Prod"			 	, "@!" , 20 , .F., /*{|| code-block de impressao }*/)
TRCell():New( oSection1, "CCOD"   , "", "Cod.Prod"			, "@!" , 15 , .F., /*{|| code-block de impressao }*/)
TRCell():New( oSection1, "CTIPO" 	, "", "Tipo"      	        , "@!" , 02 , .F., /*{|| code-block de impressao }*/)
TRCell():New( oSection1, "CDESC"  , "", "Descriçao"      , "@!" , 30 , .F., /*{|| code-block de impressao }*/)
TRCell():New( oSection1, "PA"    , "", "Prod.Acabado"			,"@E 999,999,999.99"   , 14 , .F., /*{|| code-block de impressao }*/)   
TRCell():New( oSection1, "MP"    , "", "Mat.Prima"			,"@E 999,999,999.99"   , 14 , .F., /*{|| code-block de impressao }*/)   
TRCell():New( oSection1, "SA"    , "", "Semi Acabado"			,"@E 999,999,999.99"   , 14 , .F., /*{|| code-block de impressao }*/)   
TRCell():New( oSection1, "EM"    , "", "Embalagem"			,"@E 999,999,999.99"   , 14 , .F., /*{|| code-block de impressao }*/)   
//TRCell():New( oSection1, "MC"    , "", "MC"			,"@E 999,999,999.99"   , 14 , .F., /*{|| code-block de impressao }*/)   
TRCell():New( oSection1, "MO"    , "", "Mao de Obra"			,"@E 999,999,999.99"   , 14 , .F., /*{|| code-block de impressao }*/)   
TRCell():New( oSection1, "TOTAP"    , "", "Total Apontado"			,"@E 999,999,999.99"   , 14 , .F., /*{|| code-block de impressao }*/)   
TRCell():New( oSection1, "TOTHS"    , "", "Total Horas"			,"@E 999,999,999.99"   , 14 , .F., /*{|| code-block de impressao }*/)   
TRCell():New( oSection1, "TOTGER"    , "", "Total Geral"			,"@E 999,999,999.99"   , 14 , .F., /*{|| code-block de impressao }*/)

oBreak := TRBreak():New(oSection1,{ || oSection1:Cell("CCOD"):uPrint },"SubTotal",.T.,"Total ")  

TRFunction():New(oSection1:Cell( "TOTGER" ), " TOTAL ", "SUM" ,oBreak,"Total Geral","@E 999,999,999.99"   ,,.T.,.F.,.F.,,)       


oBreak:Execute()

// Imprime o cabecalho
//oSection1:SetHeaderSection(.F.)
//oSection1:SetHeaderSection(.T.)

//oReport:SetTotalInLine(.F.)


Return oReport

/*_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-------------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ RunReport ¦Autor¦ Ronaldo Gomes/Romualdo ¦ Data ¦ 18/09/2013  ¦¦
¦¦+----------+--------------------------------------------------------------+¦¦
¦¦¦Descriçào ¦ Funcao auxiliar para impressao do relatorio                  ¦¦¦
¦¦¦          ¦                                                              ¦¦¦
¦¦+----------+--------------------------------------------------------------+¦¦
¦¦¦Parametros¦                                                              ¦¦¦
¦¦¦          ¦                                                              ¦¦¦
¦¦+----------+--------------------------------------------------------------+¦¦
¦¦¦Uso       ¦                                                              ¦¦¦
¦¦+-------------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function RunReport(oReport)
Local _cQry    := ""
Local oSection1:= oReport:Section(1)		        // Objeto secao 1 do relatorio
Local aStr     := {}                                // Estrutura do arquivo de trabalho

/*=================================================================================================
|   Seleciona a movimentacoes de acordo com os parametros informados                                |
=================================================================================================*/
Iif(Select("TRD")<>0, TRD->(DbCloseArea()), Nil)
   
//PA,MP,SA,EM,MO

_cQry:= " SELECT D3_OP,C2_PRODUTO,B1_TIPO,B1_DESC,PA,MP,SA,EM,MO,TOTAL_APONTADO,TOTAL_HORAS"
_cQry+= " ,SUM(PA+MP+SA+EM+MO) TOTAL_CUSTO_GERAL "
_cQry+= " FROM "
_cQry+= " ( "
_cQry+= " SELECT D3_OP,C2_PRODUTO,B1_TIPO,B1_DESC,ISNULL(SUM(PA),0)PA,ISNULL(SUM(MP),0) MP,ISNULL(SUM(SA),0) SA, "
_cQry+= " ISNULL(SUM(EM),0) EM,ISNULL (SUM(MO),0) MO, "
_cQry+= " (SELECT SUM(D3_QUANT) FROM "+RetSQLName("SD3") +" B " 
_cQry+= " WHERE B.D_E_L_E_T_ = '' AND B.D3_FILIAL = '"+XFILIAL("SD3")+"' " 
_cQry+= " AND T.D3_OP = B.D3_OP AND D3_CF IN ('PR0','PR1') AND B.D3_OP <> ''"
_cQry+= " AND B.D3_EMISSAO BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' ) TOTAL_APONTADO, "
_cQry+= " (SELECT ISNULL(SUM(D3_QUANT),0) FROM "+ RetSQLName("SD3") +" B WHERE B.D_E_L_E_T_ = '' AND " 
_cQry+= " B.D3_FILIAL = '"+XFILIAL("SD3")+"' AND  T.D3_OP = B.D3_OP AND D3_TIPO IN ('MO') "
_cQry+= " AND B.D3_EMISSAO BETWEEN '" +DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' ) TOTAL_HORAS "
_cQry+= " FROM ( SELECT D3_OP,[PA] AS PA , [MP] AS MP , [SA] AS SA ,[EM] AS EM , [MO] AS MO FROM "+RetSQLName("SD3")+" AS A "
_cQry+= " PIVOT ( SUM(A.D3_CUSTO1) FOR A.D3_TIPO IN ([PA],[MP],[SA],[EM],[MO]) )P WHERE D_E_L_E_T_ = '' AND D3_FILIAL = '"+XFILIAL("SD3")+"' "
_cQry+= " AND D3_EMISSAO BETWEEN '" +DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"'
_cQry+= " AND D3_OP >= '"+MV_PAR05+"' AND D3_OP <= '"+MV_PAR06+"' AND D3_OP <> '' "
_cQry+= " AND D3_CF NOT IN ('PR0','PR1') AND D3_CF NOT IN('RE9')  ) AS T INNER JOIN "+RetSQLName("SC2")+" ON D3_OP = C2_NUM+C2_ITEM+C2_SEQUEN "
_cQry+= " AND "+RetSQLName("SC2")+".D_E_L_E_T_ = '' INNER JOIN " +RetSQLName("SB1")+" ON C2_PRODUTO = B1_COD AND "+RetSQLName("SB1")+".D_E_L_E_T_ = '' "
_cQry+= " AND C2_PRODUTO >= '"+ALLTRIM(MV_PAR03)+"' AND C2_PRODUTO<='"+ALLTRIM(MV_PAR04)+"' "
_cQry+= " AND C2_FILIAL ='"+XFILIAL("SC2")+"' AND B1_FILIAL='"+XFILIAL("SB1")+"' "
_cQry+= " GROUP BY D3_OP,C2_PRODUTO,B1_DESC,B1_TIPO )AS RR "
_cQry+= " GROUP BY D3_OP,C2_PRODUTO,B1_TIPO,B1_DESC,PA,MP,SA,EM,MO,TOTAL_APONTADO,TOTAL_HORAS "
_cQry+= " ORDER BY C2_PRODUTO,D3_OP "
 

TCQUERY ChangeQuery(_cQry) New Alias "TRD" 
memowrite("RRR",_cQry) 


/*===================================================
|    Seta o Tamanho da regua                        |
===================================================*/
oReport:SetMeter( TRD->(RecCount()) )

_lLp := .T.

TRD->(DbGotop())
While !TRD->(Eof()) .And. !oReport:Cancel()
	
	oSection1:Init()               
	
	//_cQry:= " SELECT D3_OP,C2_PRODUTO,B1_TIPO,B1_DESC,PA,MP,SA,EM,MO,TOTAL_APONTADO,TOTAL_HORAS"
    // _cQry+= " ,SUM(OI+MP+EM+PA+MC+MO) TOTAL_CUSTO_GERAL "



	oSection1:Cell("OP")		  	    :SetValue( TRD->D3_OP)  
	oSection1:Cell("CCOD" )			    :SetValue( TRD->C2_PRODUTO)
	oSection1:Cell("CTIPO")			    :SetValue( TRD->B1_TIPO)
	oSection1:Cell("CDESC")	 	   	    :SetValue( TRD->B1_DESC )
	oSection1:Cell("PA")			    :SetValue( TRD->PA)
	oSection1:Cell("MP")			    :SetValue( TRD->MP)
	oSection1:Cell("SA")			    :SetValue( TRD->SA)
	oSection1:Cell("EM")			    :SetValue( TRD->EM)
	oSection1:Cell("MO")			    :SetValue( TRD->MO)
	oSection1:Cell("TOTAP")			    :SetValue( TRD->TOTAL_APONTADO)
	oSection1:Cell("TOTHS")			    :SetValue( TRD->TOTAL_HORAS)
	oSection1:Cell("TOTGER")			:SetValue( TRD->TOTAL_CUSTO_GERAL)
	
	 
  	oSection1:PrintLine()  
	//oSection1:SetHeaderSection(.T.)
	
	oReport:IncMeter()
	
	TRD->(DbSkip(1))
	
EndDo     

  
oSection1:Cell("OP")		  	    :SetValue( "" )  
oSection1:Cell("CCOD" )			 :SetValue( "" )
oSection1:Cell("CTIPO")			 :SetValue( "" )
oSection1:Cell("CDESC")	 	    :SetValue( "" )
oSection1:Cell("PA")			    :SetValue( "" )
oSection1:Cell("MP")			    :SetValue( "" )
oSection1:Cell("SA")			    :SetValue( "" )
oSection1:Cell("EM")			    :SetValue( "" )
oSection1:Cell("MO")			    :SetValue( "" )
oSection1:Cell("TOTAP")			 :SetValue( "" )
oSection1:Cell("TOTHS")			 :SetValue( "" )
		 
         

oSection1:PrintLine()  
oSection1:Cell("TOTGER"):Enable()
TRD->(dbCloseArea())

Return

/*_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-------------------------------------------------------------------------+¦¦
¦¦¦Função    ¦ ValidPerg ¦Autor ¦ Ronaldo Gomes/Romualdo ¦ Data ¦ 18/09/2013 ¦¦
¦¦+----------+--------------------------------------------------------------+¦¦
¦¦¦Descriçào ¦ Grava as perguntas referente ao Relatorio                    ¦¦¦
¦¦¦          ¦                                                              ¦¦¦
¦¦+----------+--------------------------------------------------------------+¦¦
¦¦¦Uso       ¦                                                              ¦¦¦
¦¦+-------------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function ValidPerg()

PutSX1(cPerg,"01","Data De?"       ,"","","mv_ch1","D",08,0,0,"G","","","","","mv_par01")
PutSX1(cPerg,"02","Data Ate?"      ,"","","mv_ch2","D",08,0,0,"G","","","","","mv_par02")
PutSX1(cPerg,"03","Produto De?"    ,"","","mv_ch1","C",15,0,0,"G","","SB1","","","mv_par03")
PutSX1(cPerg,"04","Produto Ate?"   ,"","","mv_ch2","C",15,0,0,"G","","SB1","","","mv_par04")
PutSX1(cPerg,"05","Op De?"         ,"","","mv_ch1","C",09,0,0,"G","","SC2","","","mv_par05")
PutSX1(cPerg,"06","Op Ate?"        ,"","","mv_ch2","C",09,0,0,"G","","SC2","","","mv_par06") 
Return
