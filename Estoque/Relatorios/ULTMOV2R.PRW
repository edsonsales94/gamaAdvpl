/*
------------------------------------------------------------------------------
Desenvolvedor: Reginaldo Souza - 28/05/2002
Solicitante..: Sr.Ulysses Ribeiro
Objetivo.....: Relatorio da Carteira de Pedidos de Venda por Cliente
------------------------------------------------------------------------------
Alteracao: Substituicao do saldo atual pelo saldo na data com CalcEst()
Data: 16/03/16
Solicitante: Ezaquiel
Motivo: O Relatorio deve apresentar o saldo da database
------------------------------------------------------------------------------
Alteracao: Filtrar as MOD da Query 
Data: 16/03/16 as 13:00
Solicitante: Ezaquiel
Motivo: O Valor da Mod/(V_DATA:=MV_PAR08 )Data do  nao pode influenciar este realtorio
------------------------------------------------------------------------------               
*/

#include "rwmake.ch"        
#include "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
USER FUNCTION ULTMOV2R()

  cbTxt		:= ""
  cbCont	:= ""
  nOrdem 	:= 0
  Tamanho	:= "G"
  Limite    := 132
  cImpri   	:= ""  
  nTotal   	:= 0
  Titulo 	:= "RELATÓRIO AGIN X USADO"
  cDesc1 	:= "Lista da ultima movimentacao do produto e onde foi usado."
  cDesc2 	:= "Conforme o parametro especificado"
  cDesc3 	:= ""
    aReturn	:= { "Especial", 1,"Administracao", 2, 2, 1,"",1 }//                                                                                                                                           
  NomeProg	:= "ULTMOV"  
  nTipo     := IF(aReturn[4]==1,15,18)
  cPerg		:= "ULTMOV"
  nLastKey	:= 0 
  lContinua := .T.
  M_PAG  	:= 1
  Li  		:= 99
  wnrel 	:= "UltMov"
  cString   := "SB2"

  Pergunte( cPerg , .F. )
  
  wnrel := SetPrint("",wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F., , , , ,.F.)
  
  If ( nLastKey == 27 .Or. LastKey() == 27 )
    Return(.F.)
  Endif
  
  SetDefault(aReturn,cString)
  If ( nLastKey == 27 .Or. LastKey() == 27 )
    Return(.F.)
  Endif

  Titulo 	:= "LISTA ULTIMA "+IF(MV_PAR09==1, "MOVIMENTACAO", "AGIN")+" DO PRODUTO X "+DTOC(MV_PAR07)+" A "+DTOC(MV_PAR08)+" ONDE FOI USADO "
  //cCabec2   := "                                                                  !        Ate' 30 !     De 31 a 60 !     De 61 a 90 !    De 91 a 120 !   De 121 a 150 !   De 151 a 180 !   Acima de 180 ! "+IF(MV_PAR09==1,"Movimento"," Inspecao")+" !     (R$)      !"
  
  nDias:= mv_par10
  cCabec1   := "Produto           Descricao                                UM ALM !                      P E R I O D O   D A   U L T I M A   M O V I M E N T A C A O   E M   D I A S                          ! Data  Ult.! Valor Estoque !"  
  cCabec2   := "                                                                  !        Ate' "+strzero(nDias,3)+" !   De "+strzero((nDias*1)+1,3)+" a "+strzero((nDias*2),3)+" !  De "+strzero((nDias*2)+1,3)+" a "+strzero((nDias*3),3)+" !    De "+strzero((nDias*3)+1,3)+" a "+strzero((nDias*4),3)+" !   De "+strzero((nDias*4)+1,3)+" a "+strzero((nDias*5),3)+" !   De "+strzero((nDias*5)+1,3)+" a "+strzero((nDias*6),3)+" !   Acima de "+strzero((nDias*6)+1,3)+" ! Movimento !  (R$)!"

  
  Processa( {|| UltMova( mv_par01,mv_par02,mv_par03,mv_par04,mv_par07,mv_par08,mv_par09 ) } )

RETURN NIL
 

Static Function Usado(cComp)
cUsado:=""
cAliasSG1:= GetNextAlias()
// USADO NO
BeginSql Alias cAliasSG1
  select DISTINCT (G1_COD) G1_COD from %Table:SG1% SG1
  WHERE  G1_COMP=%exp:cComp% 
  AND SG1.%NotDel%	
EndSql
dbSelectArea(cAliasSG1)  
dbgotop()
Do while !eof()
 cUsado+= allTRIM((cAliasSG1)->G1_COD ) + " / "
 DBSKIP()
Enddo
dbSelectArea(cAliasSG1) 
dbclosearea()
Return cUsado



Static FUNCTION UltMova(cProdIni,cProdFim,cLocalIni,cLocalFim,mv_par07,mv_par08,mv_par09 )
Local oReport,i
aMOVPROD := {}
aSOMA    := {}
nCol     := 0
cDataSD1 := ""
cDataSD2 := ""
cDataSD3 := ""
cUltMov  := ""
nQuant := 0

FOR I:= 1 TO 8
    AADD(aSOMA,0)
NEXT

   SB2->( dbsetOrder(1) )   
   SB1->( dbsetOrder(1) )
   SD1->( dbSetOrder(7) ) //Numero do Pedido                          == Cabecalho do pedido de Venda
   SD2->( dbSetOrder(6) ) //Data da Entrega+Numero do Pedido          == Item do Pedido de Venda
   SD3->( dbSetOrder(7) ) //Codigo do Cliente                         == Cadastro de Clientes
   SA5->( dbSetOrder(2) ) //Codigo do Produto                         == Tabela de preco de Compras
   SA7->( dbSetOrder(2) ) //Codigo do Produto                         == Tabela de preco de vendas
    
   
IF MV_PAR09 == 1

   cSELECT := "B2_COD, B2_LOCAL, B2_QATU,B2_CM1, "  + ;
            " (SELECT MAX(D1_DTDIGIT)D1_DTDIGIT FROM " +RetSqlName('SD1')+" " + ;
            " WHERE D1_FILIAL = " + CHR(39) + xFilial('SD1') +CHR(39) + ; 
            " AND D1_COD = B2_COD AND D1_DTDIGIT<='"+DTOS(MV_PAR08)+"' AND "+RetSqlName('SD1')+".D_E_L_E_T_ <> " +CHR(39) + '*'  +CHR(39) + " ) D1_DTDIGIT," + ; 
            " (SELECT MAX(D2_EMISSAO) D2_EMISSAO FROM "+RetSqlName('SD2')+" " + ;
            " WHERE  D2_FILIAL = " + CHR(39) + xFilial('SD2') + CHR(39) + ; 
            " AND D2_COD = B2_COD AND D2_EMISSAO<='"+DTOS(MV_PAR08)+"' AND "+RetSqlName('SD2')+".D_E_L_E_T_ <> " +CHR(39) + '*'  +CHR(39) + "  ) D2_EMISSAO, " + ; 
            " ISNULL( " +;
            " (SELECT MAX(EMISSAO) FROM "  + ;
            " (SELECT D3_EMISSAO EMISSAO,D3_NUMSEQ SEQ,COUNT(D3_NUMSEQ) NUMSEQ  FROM "+RetSqlName('SD3') +" SD31 " + ;
            " WHERE D3_FILIAL = " + CHR(39) + xFilial('SD3') + CHR(39) + ; 
            " AND D3_COD =  B2_COD AND D3_EMISSAO<='"+DTOS(MV_PAR08)+"' " + ;
            " AND  SD31.D_E_L_E_T_ <>" +CHR(39) + '*'  +CHR(39) + "  AND  D3_OBSERVA<>'AGIN'   AND " + ;
            " D3_CF IN ('RE0','RE1','RE2','PR0','PR1','DE0','DE6','RE6') " + ;
            " GROUP BY SD31.D3_EMISSAO,SD31.D3_NUMSEQ ) INTERNOS ) " + ;
            ",ISNULL((SELECT MAX(D3_EMISSAO) FROM SD3010 WHERE  D3_CF IN ('RE1','RE2','PR0','PR1','DE0','RE0','DE0','DE6','RE6')  AND D3_EMISSAO <='" +DTOS(MV_PAR08)+" ' AND D3_COD =  B2_COD ),"+;
            "(SELECT MAX(D1_DTDIGIT)D1_DTDIGIT FROM SD1010  WHERE D1_FILIAL = '01' AND D1_COD = B2_COD AND D1_DTDIGIT<='" +DTOS(MV_PAR08)+" ' AND SD1010.D_E_L_E_T_ <> '*' ) "+;
            ")) D3_EMISSAO " 
         
            
              
   cWHERE  := RetSqlName('SB2')+'.D_E_L_E_T_ <>   '+CHR(39) + '*'  +CHR(39) + ' AND '+;
			  'B2_FILIAL  =   '+CHR(39) + xFilial('SB2') +CHR(39) + ' AND '+;           
			  "B2_COD   BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "+;
			  "B2_LOCAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'  AND LEFT(B2_COD,3)<>'MOD' "
		  	  //" AND B2_QATU > 0"
ELSE    

   cSELECT := "B2_COD, B2_LOCAL, B2_QATU, B2_ULTINSP "
              
   cWHERE  := RetSqlName('SB2')+'.D_E_L_E_T_ <>   '+CHR(39) + '*'  +CHR(39) + ' AND '+;
			  'B2_FILIAL  =   '+CHR(39) + xFilial('SB2') +CHR(39) + ' AND '+;           
			  "B2_COD   BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND "+;
			  "B2_LOCAL BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' AND "+;
			  "B2_QATU > 0 AND B2_ULTINSP BETWEEN '"+DTOS(MV_PAR07)+"' AND '"+DTOS(MV_PAR08)+"'"
ENDIF   

   cFROM   := RetSqlName('SB2') + ' '
   
   cORDER  := "B2_COD, B2_LOCAL"

   cQuery  := ' SELECT '   + cSELECT + ; 
			  ' FROM '     + cFROM   + ;
			  ' WHERE '    + cWHERE  + ;
			  ' ORDER BY ' + cORDER

   TCQUERY cQuery NEW ALIAS 'TRA'
   If ! USED()
      MsgBox(cQuery+'. Query errada','Erro!!!','STOP')
   EndIf     //Ricky

   DbSelectArea('TRA')
   Count to _nQtdReg
   ProcRegua(_nQtdReg)
   TRA->(DbGoTop())   
   V_DATA:=MV_PAR08

   WHILE !TRA->(Eof()) 

      B2est   :=   CalcEst(TRA->B2_COD,TRA->B2_LOCAL,V_DATA+1) 
 // 	 	nQuant:=B2est[1]
//  		msgAlert(nQuant)

      IF B2est[1]==0     
      //  DBSKIP()             
      TRA->( DbSkip() )
      ELSE 
      
      IncProc("Produto -> "+alltrim(TRA->B2_COD) )     

      
      IF MV_PAR09 == 1 
         cUltMOv    := IF(TRA->D1_DTDIGIT >= TRA->D2_EMISSAO, TRA->D1_DTDIGIT, TRA->D2_EMISSAO)
         cUltMOv    := IF(cUltMOv         >= TRA->D3_EMISSAO  , cUltMOv        , TRA->D3_EMISSAO)      

       ELSE
         cUltMOv    := TRA->B2_ULTINSP
      ENDIF        
		

		
 //     IF aScan(aMOVPROD,{|x| x[1]+x[2] == TRA->B2_COD+TRA->B2_LOCAL}) == 0 .AND. cULTMOV >= DTOS(MV_PAR07) .AND. cULTMOV <= DTOS(MV_PAR08)
      IF aScan(aMOVPROD,{|x| x[1]+x[2] == TRA->B2_COD+TRA->B2_LOCAL}) == 0  .AND. cULTMOV <= DTOS(MV_PAR08)
  
	     c_Mes  := alltrim(str(month(dDataBase) ,2))
	     c_Ano  := alltrim(str( year(dDataBase) ,4)) 
	     mPRECO := B2est[2]/B2est[1]   //custo unitario na data
         
//         Usado(TRA->B2_COD)
         aADD(aMOVPROD,{ TRA->B2_COD,TRA->B2_LOCAL, 0, 0, 0, 0, 0, 0, 0, cUltMov, (B2est[2]),((MV_PAR08)-STOD(cUltMOv)),Usado(TRA->B2_COD) })
         nPOS := LEN(aMOVPROD)
      
        // mudanca no calculo (dDataBase-STOD(cUltMOv)) =>((MV_PAR08)-STOD(cUltMOv))
         
         IF ((MV_PAR08)-STOD(cUltMOv)) <= nDias
            nCOL := 3
         ELSEIF ((MV_PAR08)-STOD(cUltMOv)) >=  (nDias*1)+1 .AND. ((MV_PAR08)-STOD(cUltMOv)) <=  (nDias*2)
            nCOL := 4
         ELSEIF ((MV_PAR08)-STOD(cUltMOv)) >=  (nDias*2)+1 .AND. ((MV_PAR08)-STOD(cUltMOv)) <=  (nDias*3)
            nCOL := 5
         ELSEIF ((MV_PAR08)-STOD(cUltMOv)) >=  (nDias*3)+1 .AND. ((MV_PAR08)-STOD(cUltMOv)) <= (nDias*4)
            nCOL := 6
         ELSEIF ((MV_PAR08)-STOD(cUltMOv)) >=  (nDias*4)+1 .AND. ((MV_PAR08)-STOD(cUltMOv)) <= (nDias*5)
            nCOL := 7
         ELSEIF ((MV_PAR08)-STOD(cUltMOv)) >=  (nDias*5)+1 .AND. ((MV_PAR08)-STOD(cUltMOv)) <= (nDias*6)
            nCOL := 8
         ELSEIF ((MV_PAR08)-STOD(cUltMOv)) >  (nDias*6)
            nCOL := 9                                             
         ENDIF
      
         aMOVPROD[nPOS,nCOL] += B2est[1]  
         aSOMA[nCOL-2] += ((mPRECO/1000)*B2est[1])
         aSOMA[8]      += ((mPRECO/1000)*B2est[1])
                  
      ENDIF
      
      TRA->( DbSkip() )
    ENDIF        
   ENDDO   
   TRA->( DbCloseArea() )
 
 If FindFunction("TRepInUse") .And. TRepInUse()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:= ReportDef()
	oReport:PrintDialog()
 Else   
   // Impressao do Relatorio 
   RptStatus( {|| UltMovb() } , Titulo )
 Endif

RETURN NIL          


Static Function ReportDef()
Local oReport 
Local oSection1 
Local oCell         
Local oBreak
Local cTitle := "LISTA ULTIMA MOVIMENTACAO DO PRODUTO DE "+DTOC(MV_PAR07)+" A "+DTOC(MV_PAR08) + "  AGIN " //"Solicitacao de Compra"

#IFDEF TOP
	Local cAliasSB1 := GetNextAlias()
#ELSE
	Local cAliasSB1 := "SB1"
#ENDIF
oReport := TReport():New("ULTIMOV",cTitle,"ULTIMOV", {|oReport| ReportPrint(oReport,cAliasSB1)},cTitle) //"Emissao das solicitacoes de compras cadastradas"
oReport:SetLandscape() 
oSection1:= TRSection():New(oReport,"Produtos",{"SB1"},/*aOrdem*/)
oSection1:SetHeaderPage()
 
TRCell():New(oSection1,"B1_COD"    ,"SB1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"B1_DESC"   ,"SB1",/*Titulo*/,/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)         
TRCell():New(oSection1,"B1_TIPO"   ,"SB1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)         
TRCell():New(oSection1,"B1_UM"     ,"SB1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"LOCAL"     ,"SB1","ALM",/*Picture*/,3,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"ATE30"     ," ","ATE " ,PesqPict("SB2","B2_QATU" ),12,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"ATE60"     ," ","DE "  ,PesqPict("SB2","B2_QATU" ),12,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"ATE90"     ," ","DE "  ,PesqPict("SB2","B2_QATU" ),12,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"ATE120"    ," ","DE "  ,PesqPict("SB2","B2_QATU" ),12,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"ATE150"    ," ","DE "  ,PesqPict("SB2","B2_QATU" ),12,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"ATE180"    ," ","DE "  ,PesqPict("SB2","B2_QATU" ),12,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"ATE181"    ," ","ACIMA DE ",PesqPict("SB2","B2_QATU" ),12,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DULMOV"    ," ","Dt Ult. Mov.",/*Picture*/                ,8         ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"CMEDIO"    ," ","Val. Estoque",PesqPict("SC7","C7_PRECO") ,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"DIAS"     ," ","D.Corridos " ,/*PesqPict("SB2","B2_QATU" )*/,6,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"USADO"     ," ","ONDE FOI USADO " ,/*PesqPict("SB2","B2_QATU" )*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)

//calcula o total da coluna
TRFunction():New(oSection1:Cell("CMEDIO"),, 'SUM',/*oBreak*/ ,"Total : ",,,.T.,.T.,.T., oSection1)
  

Return(oReport) 

Static Function ReportPrint(oReport,cAliasSB1)
Local x,i
Local oSection1 := oReport:Section(1) 
Private aEnder //array para saldos dos endereços  solicitado por Sra. Cleonice 08/15/2015
oSection1:Cell("DULMOV"):nAlign := 2 //CENTRALIZA A DATA DA ULTIMA MOVIMENTACAO
oSection1:Cell("B1_UM" ):nAlign := 2
//dbSelectArea(cAliasSB1)
oReport:SetMeter(Len(aMOVPROD))
oSection1:Cell("ATE30"):SetTitle("ATE "+strzero((nDias*1),4)  )
oSection1:Cell("ATE60"):SetTitle("DE "+strzero((nDias*1)+1,4)+" A "+strzero((nDias*2),4) )
oSection1:Cell("ATE90"):SetTitle("DE "+strzero((nDias*2)+1,4)+" A "+strzero((nDias*3),4) )
oSection1:Cell("ATE120"):SetTitle("DE "+strzero((nDias*3)+1,4)+" A "+strzero((nDias*4),4))
oSection1:Cell("ATE150"):SetTitle("DE "+strzero((nDias*4)+1,4)+" A "+strzero((nDias*5),4))
oSection1:Cell("ATE180"):SetTitle("DE "+strzero((nDias*5)+1,4)+" A "+strzero((nDias*6),4))
oSection1:Cell("ATE181"):SetTitle("ACIMA DE "+strzero((nDias*6)+1,4))

For I := 1 To Len(aMOVPROD) 
    oReport:IncMeter() 
    If oReport:Cancel()
	 I:=Len(aMOVPROD) + 1  //ENCERRA O FOR
    EndIf
    
    oSection1:Init()
    cDesc:=Posicione("SB1",1,XFILIAL("SB1")+aMOVPROD[I,1],"B1_DESC")
    cUm  :=Posicione("SB1",1,XFILIAL("SB1")+aMOVPROD[I,1],"B1_UM")
    cTipo:=Posicione("SB1",1,XFILIAL("SB1")+aMOVPROD[I,1],"B1_TIPO")
	oSection1:Cell("B1_COD"):SetValue(aMOVPROD[I,1])
	oSection1:Cell("B1_DESC" ):SetValue(cDesc)
	oSection1:Cell("B1_TIPO" ):SetValue(cTipo)
	oSection1:Cell("B1_UM"  ):SetValue(cUm)
	oSection1:Cell("LOCAL"  ):SetValue(aMOVPROD[I,2])
	oSection1:Cell("ATE30"  ):SetValue(aMOVPROD[I,3])
	oSection1:Cell("ATE60"  ):SetValue(aMOVPROD[I,4])
	oSection1:Cell("ATE90"  ):SetValue(aMOVPROD[I,5])
	oSection1:Cell("ATE120" ):SetValue(aMOVPROD[I,6])
	oSection1:Cell("ATE150"  ):SetValue(aMOVPROD[I,7])
	oSection1:Cell("ATE180"  ):SetValue(aMOVPROD[I,8])
	oSection1:Cell("ATE181"  ):SetValue(aMOVPROD[I,9])
	oSection1:Cell("DULMOV"  ):SetValue(DTOC(STOD(aMOVPROD[I,10])))
	oSection1:Cell("CMEDIO"  ):SetValue(aMOVPROD[I,11])
	oSection1:Cell("DIAS"  ):SetValue(aMOVPROD[I,12])
	oSection1:Cell("USADO"  ):SetValue(aMOVPROD[I,13])
	oSection1:PrintLine()
	IF MV_PAR11=2
     SldEnd(aMOVPROD[I,1],aMOVPROD[I,2])
     if len(aEnder)>0                      
       For x:=1 to len(aEnder)
          oReport:PrintText(aEnder[x,1],oReport:nRow,oSection1:Cell("B1_UM"):ColPos()) 
          oReport:PrintText(transform(aEnder[x,2],"@E 999,999.99999"),oReport:nRow,oSection1:Cell("ATE30"):ColPos()) 
          oReport:SkipLine()
       Next
       oReport:SkipLine()
     endif
    ENDIF
	
Next I


oSection1:Finish()
oReport:EndPage() 
Return Nil


Static Function SldEnd(cCod,cLoc)
aEnder:={}
cAliasSBF:= GetNextAlias()
// saldos dos enderecos
BeginSql Alias cAliasSBF
  select BF_LOCALIZ,BF_PRODUTO,BF_QUANT from %Table:SBF% SBF
  WHERE BF_FILIAL=%exp:XFILIAL("SBF")% AND BF_PRODUTO=%exp:cCod% 
  AND BF_LOCAL=%exp:cLoc% AND SBF.%NotDel%	
EndSql
dbSelectArea(cAliasSBF)  
dbgotop()
Do while !eof()
 aadd(aEnder,{(cAliasSBF)->BF_LOCALIZ,(cAliasSBF)->BF_QUANT}) 
 DBSKIP()
Enddo
dbSelectArea(cAliasSBF) 
dbclosearea()
Return

Static Function UltMovb()
 
local   cCodAtu := chr(255)
LOCAL   cCodCli := ""
local   nCntPrd := 0
local   nColRel
local   xCmpRel
local   cPicRel      
local   lCli,i

private nCntPag  := 0
private nCntLin  := 999

PRIVATE _cMes    := ""
PRIVATE _nPreco  := 0

M_PAG := 1             


FOR I:=1 TO LEN(aMOVPROD)

   If lAbortPrint
      @nCntLin,000 psay "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif                   

   IF nCntLin > 55 
      nCntLin := Cabec( Titulo , cCabec1 , cCabec2 , wnRel , Tamanho , nTipo )
   ENDIF       
   
   SB1->( dbSeek( xFilial("SB1")+aMOVPROD[I,1] ) )   
   
   @ ++nCntLin, 000 PSAY aMOVPROD[I,1]+" "+LEFT(SB1->B1_DESC,40)+space(14)+SB1->B1_UM+" "+;
                         aMOVPROD[I,2]+"    "+TRANSFORM(aMOVPROD[I,3],"@E 99,999,999.999")+"     "+;
                         TRANSFORM(aMOVPROD[I,04],"@E 99,999,999.999")+"    "+TRANSFORM(aMOVPROD[I,05],"@E 99,999,999.999")+"   "+;
                         TRANSFORM(aMOVPROD[I,06],"@E 99,999,999.999")+"    "+TRANSFORM(aMOVPROD[I,07],"@E 99,999,999.999")+"   "+;
                         TRANSFORM(aMOVPROD[I,08],"@E 99,999,999.999")+"    "+TRANSFORM(aMOVPROD[I,09],"@E 99,999,999.999")+"    "+;
                         DTOC(STOD(aMOVPROD[I,10]))+"   "+TRANSFORM(aMOVPROD[I,11],"@E 99,999,999.99")   
NEXT
 
nCntLin += 2
 
@ nCntLin,000 PSAY "TOTAL EXPRESSO EM REAIS CONFORME TABELA DE PRECOS            -->>"
 
FOR I:=1 TO LEN(aSOMA)
    
   @ nCntLin,PCOL()+IF(I!=LEN(aSOMA),4,15) PSAY aSOMA[I] PICTURE "@E 99,999,999.99"

NEXT

nCntLin += 2
   
@ nCntLin,001 PSAY "PARAMETROS UTILIZADOS NESTE RELATORIO"
   
nCntLin += 2
                      
@ nCntLin  ,001 PSAY "Produto De        ? " +MV_PAR01
@ nCntLin  ,041 PSAY "Produto Ate'      ? " +MV_PAR02
@ nCntLin  ,081 PSAY "Almoxarifado De   ? " +MV_PAR03
@ nCntLin++,121 PSAY "Almoxarifado Ate' ? " +MV_PAR04
@ nCntLin  ,001 PSAY "Taxa do Dollar R$ ? " +TRANSFORM(MV_PAR05,"@E 9.9999")
@ nCntLin++,041 PSAY "Taxa do Yene   R$ ? " +TRANSFORM(MV_PAR06,"@E 9.99999")

Roda(0,"","G")

If aReturn[5] == 1													// Se impressao em Disco, chama Spool.
	ourspool(wnrel)
Endif
	
MS_FLUSH()																// Libera relatorio para Spool da Rede.

Return Nil               


Static  FUNCTION ConfEnd2()

  cbTxt		:= ""
  cbCont	:= ""
  nOrdem 	:= 0
  Tamanho	:= "M"
  Limite    := 132
  cImpri   	:= ""
  nTotal   	:= 0
  Titulo    := "Relatório AGIN x USADO"
  cDesc1 	:= "Este programa ira emitir lista de Conferencia de Saldos em Estoque X Enderecamento."
  cDesc2 	:= "Conforme o parametro especificado"
  cDesc3 	:= ""
  cCabec1   := "Produto           Descricao                                UM ALM !   Estoque         Saldo          Saldo   "
  cCabec2   := "                                                                  !    Atual       Distribuido   A Distribuir"
  aReturn	:= { "Especial", 1,"Administracao", 2, 2, 1,"",1 }//                                                                                                                                           
  NomeProg	:= "ULTMOV"  
  nTipo     := IF(aReturn[4]==1,15,18)
  cPerg		:= "CNFEND"
  nLastKey	:= 0 
  lContinua := .T.
  M_PAG  	:= 1
  Li  		:= 99
  wnrel 	:= "CNFEND"
  cString   := "SB2"

  Pergunte( cPerg , .F. )
  
  wnrel := SetPrint("",wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F., , , , ,.F.)
  
  If ( nLastKey == 27 .Or. LastKey() == 27 )
    Return(.F.)
  Endif
  
  SetDefault(aReturn,cString)
  If ( nLastKey == 27 .Or. LastKey() == 27 )
    Return(.F.)
  Endif


  Processa( {|| ConfEnda() } )

RETURN NIL





Static FUNCTION ConfEnda()
PRIVATE nCntLin := 99

   cSELECT := "B2_COD, B2_LOCAL, B2_QATU, "+;
              "(SELECT sum(BF_QUANT)BF_QUANT FROM "+RetSqlName('SBF')+" WHERE "+RetSqlName('SBF')+".D_E_L_E_T_<>'*' AND BF_FILIAL = '"+xFILIAL("SBF")+"' AND BF_PRODUTO = B2_COD AND BF_LOCAL = B2_LOCAL) DISTRIBUIDO, "+;
              "(SELECT sum(DA_SALDO)DA_SALDO FROM "+RetSqlName('SDA')+" WHERE "+RetSqlName('SDA')+".D_E_L_E_T_<>'*' AND DA_FILIAL = '"+xFILIAL("SDA")+"' AND DA_PRODUTO = B2_COD AND DA_LOCAL = B2_LOCAL) ADISTRIBUIR"

   cFROM   := RetSqlName('SB2') + ' '
/*   
   cWHERE  := RetSqlName('SB2')+'.D_E_L_E_T_ <>   '+CHR(39) + '*'  +CHR(39) + ' AND '+;
			  'B2_FILIAL  =  '+CHR(39) + xFilial('SB2') +CHR(39) + ' AND '+;           
			  "B2_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND B2_LOCAL IN ('04','05')
  */  
    cWHERE  := RetSqlName('SB2')+'.D_E_L_E_T_ <>   '+CHR(39) + '*'  +CHR(39) + ' AND '+;
			  'B2_FILIAL  =  '+CHR(39) + xFilial('SB2') +CHR(39) + ' AND '+;           
			  "B2_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'  "
   cORDER  := "B2_COD, B2_LOCAL"

   cQuery  := ' SELECT '   + cSELECT + ; 
			  ' FROM '     + cFROM   + ;
			  ' WHERE '    + cWHERE  + ;
			  ' ORDER BY ' + cORDER

   TCQUERY cQuery NEW ALIAS 'TRA'
   If ! USED()
      MsgBox(cQuery+'. Query errada','Erro!!!','STOP')
   EndIf

   DbSelectArea('TRA')
   Count to _nQtdReg
   ProcRegua(_nQtdReg)
   TRA->(DbGoTop())
   
   While !TRA->(Eof()) //.AND. SC1->C1_EMISSAO <= mv_par02

      Incproc("Produto: "+TRA->B2_COD+" Local: "+TRA->B2_LOCAL)

      IF (TRA->DISTRIBUIDO+TRA->ADISTRIBUIR) <> TRA->B2_QATU

         IF nCntLin > 55 
            nCntLin := Cabec( Titulo , cCabec1 , cCabec2 , wnRel , Tamanho , nTipo )
         ENDIF       
   
         SB1->( dbSeek( xFilial("SB1")+TRA->B2_COD ) )   
   
         @ ++nCntLin, 000 PSAY TRANSFORM(TRA->B2_COD,"@R 99!!.!!!!.!!!!-##")+" "+LEFT(SB1->B1_DESC,40)+" "+SB1->B1_UM+" "+;
                         TRA->B2_LOCAL+" "+TRANSFORM(TRA->B2_QATU,"@E 99,999,999.999")+" "+;
                         TRANSFORM(TRA->DISTRIBUIDO,"@E 99,999,999.999")+" "+TRANSFORM(TRA->ADISTRIBUIR,"@E 99,999,999.999")
      ENDIF
      
      TRA->(DbSkip())
      
   ENDDO
TRA->(DBclosearea())
DbSelectArea("SB2")
   
Roda(0,"","M")

If aReturn[5] == 1													// Se impressao em Disco, chama Spool.
	ourspool(wnrel)
Endif
	
MS_FLUSH()																// Libera relatorio para Spool da Rede.

Return nil