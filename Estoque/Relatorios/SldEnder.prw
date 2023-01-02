#include "rwmake.ch"        
#include "TOPCONN.CH"

User Function SldEnder()
Tamanho	:= "G"
Limite	:= 132
Titulo 	:= "Posicao de estoque atual e endereçado"
cDesc1 	:= "Este programa ira emitir a posição de estoque atual e endereçado."
cDesc2 	:= "Conforme o parametro especificado"
cDesc3 	:= ""
Cabec1  := "Produto           Descricao                         UM ALMOX!               !   SALDO  A   !    SALDO    !  DIFERENCA   !        HISTORICO POR LOCALIZACAO        !"
Cabec2  := "                                                            ! ESTOQUE ATUAL !  DISTRIBUIR  ! LOCALIZACAO ! EST. x LOCAL ! DATA INICIO ! ENDERECO ! SALDO ENDERECO !"
aReturn	:= { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
NomeProg:= "SldEnder" 
nTipo   := IIf(aReturn[4]==1,15,18)
cPerg	:= "SLDEND"
nLastKey:= 0 
lContinua := .T.
M_PAG  	:= 1
Li 		:= 99
wnrel 	:= "SldEnder"
cString := "SB2"
  
Pergunte( cPerg , .F. )  

wnrel    := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F., , , , ,.F.)

If ( nLastKey == 27 .Or. LastKey() == 27 )
   Return(.F.)
Endif
  
SetDefault(aReturn,cString)
If ( nLastKey == 27 .Or. LastKey() == 27 )
   Return(.F.)
Endif
  
Processa( {|| SldEndera( ) } )

Return Nil

Static Function SldEndera()
/*INICIO DO SELECT */
cQuery := " SELECT B2_LOCAL,B2_COD,B1_DESC,B1_UM,B2_QATU , "

/*QTDE TOTAL ENDERECADA*/
cQuery += " QTDENDER= CASE WHEN BF_QUANT IS NULL THEN 0 ELSE "
cQuery += " (SELECT SUM(BF_QUANT)  FROM "+RetSqlName('SBF')+" WHERE  BF_FILIAL=B2_FILIAL AND BF_PRODUTO=B2_COD AND BF_LOCAL=B2_LOCAL AND "+RetSqlName('SBF')+".D_E_L_E_T_<>'*') END, "

/*QTDE TOTAL DISTRIBUIDA*/
cQuery += " DISTRIBUI= CASE WHEN (SELECT SUM(DA_SALDO) FROM "+RetSqlName('SDA')+" WHERE  DA_FILIAL = '"+XFILIAL("SB2")+"' AND DA_PRODUTO = B2_COD AND DA_LOCAL=B2_LOCAL AND "+RetSqlName('SDA')+".D_E_L_E_T_<>'*') IS NULL THEN 0 "
cQuery += " ELSE (SELECT SUM(DA_SALDO) FROM "+RetSqlName('SDA')+" WHERE  DA_FILIAL = '"+XFILIAL("SB2")+"' AND DA_PRODUTO = B2_COD AND DA_LOCAL=B2_LOCAL AND "+RetSqlName('SDA')+".D_E_L_E_T_<>'*') END, "

/*QTDES ENDERECADAS POR DATA INICIO*/
//cQuery += " BF_DATAINI= CASE WHEN BF_DATAINI IS NULL THEN '' ELSE BF_DATAINI END, "  
cQuery += " BF_DATAVEN= CASE WHEN BF_DATAVEN IS NULL THEN '' ELSE BF_DATAVEN END, "  
cQuery += " BF_LOCALIZ= CASE WHEN BF_LOCALIZ IS NULL THEN '' ELSE BF_LOCALIZ END, "
cQuery += " BF_QUANT=   CASE WHEN BF_QUANT   IS NULL THEN  0 ELSE BF_QUANT   END "  


/*ARQUIVOS FROM*/
cQuery += " FROM "+RetSqlName('SB2') 
cQuery += " LEFT OUTER JOIN "+RetSqlName('SB1')+" ON B1_COD=B2_COD AND "+RetSqlName('SB1')+".D_E_L_E_T_<>'*' "
cQuery += " LEFT OUTER JOIN "+RetSqlName('SBF')+" ON BF_FILIAL=B2_FILIAL AND BF_PRODUTO=B2_COD AND BF_LOCAL=B2_LOCAL AND "+RetSqlName('SBF')+".D_E_L_E_T_<>'*' "
/*FILTRO DA QUERY*/
cQuery += " WHERE B2_FILIAL='"+XFILIAL("SB2")+"' AND B2_COD>='"+MV_PAR01+"' AND B2_COD<='"+MV_PAR02+"'  "
cQuery += " AND B2_LOCAL>='"+MV_PAR03+"' AND B2_LOCAL<='"+MV_PAR04+"' AND "+RetSqlName('SB2')+".D_E_L_E_T_<>'*' ORDER BY B2_COD,B2_LOCAL "  

TCQUERY cQuery NEW ALIAS 'TMP'
If	! USED()
  MsgBox(cQuery+'. Query errada','Erro!!!','STOP')
EndIf

DbSelectArea('TMP')
Count to _nQtdReg
ProcRegua(_nQtdReg)
TMP->(DbGoTop())

While !TMP->( Eof() ) 

   IncProc( "Produto: "+TMP->B2_COD )
   IF ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+TMP->B2_COD,"B1_LOCALIZ")) <> "S"
      TMP->( DbSkip() )
      LOOP
   ENDIF

   If Li >= 58
   
      Li := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      cProduto := ""
      
   Endif
   if TMP->B2_QATU<>0 .or. (TMP->QTDENDER + TMP->DISTRIBUI)<>0 
    If Mv_par05 == 1 .or. mv_par05 == 2 .and. TMP->B2_QATU <> (TMP->QTDENDER + TMP->DISTRIBUI) .or. mv_par05 == 3 .and. TMP->B2_QATU == (TMP->QTDENDER + TMP->DISTRIBUI)

      If cProduto <> TMP->B2_COD
         
         Li++
         @ Li,000      PSAY TMP->B2_COD                                        PICTURE "@!"
         //@ Li,PCOL()+1 PSAY LEFT(TMP->B1_DESC,50)
         @ Li,18       PSAY LEFT(TMP->B1_DESC,50)
         @ Li,PCOL()+1 PSAY TMP->B1_UM
         @ Li,PCOL()+3 PSAY TMP->B2_LOCAL
         @ Li,PCOL()+2 PSAY TMP->B2_QATU                                       PICTURE "@E 99,999,999.999"
         @ Li,PCOL()+1 PSAY TMP->DISTRIBUI                                     PICTURE "@E 99,999,999.999"         
         @ Li,PCOL()+1 PSAY TMP->QTDENDER                                      PICTURE "@E 99,999,999.999"
         @ Li,PCOL()+1 PSAY (TMP->B2_QATU - (TMP->QTDENDER + TMP->DISTRIBUI))  PICTURE "@E 99,999,999.999"
         cProduto := TMP->B2_COD
         
      Endif

      @ Li,121      PSAY STOD(TMP->BF_DATAVEN)
      @ Li,PCOL()+4 PSAY LEFT(TMP->BF_LOCALIZ,10)
      @ Li,PCOL()+1 PSAY TMP->BF_QUANT      PICTURE "@E 99,999,999.999"
   
      Li++
    endif  
   Endif

   TMP->( DbSkip() )
	
EndDO
TMP->(DbCloseArea())
DbSelectArea("SB2")

RODA(0,"","G")

If aReturn[5] == 1																		// Impressao em Disco, Spool.
   ourspool(NomeProg)
Endif

Return Nil