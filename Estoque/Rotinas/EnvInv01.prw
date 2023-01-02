#include "rwmake.ch"
#include "Colors.ch"
#include "topconn.ch"
#Include "Winapi.ch"
#Include "vkey.ch"
#include "COLORS.CH"
#include "font.ch"
**********************************************************************************************************************************************
User Function EnvINV01()//Programa que gerar a tabela de estatistica de inventário
**********************************************************************************************************************************************
Private cTitulo :="Tabela de Estatistica"
Private cAssunto:= "Lista tabela de Estatistica de Inventario"
Private aOrder  :={"Produto+Local+Endereco+Lote","Produto+Local+Lote","Local+Endereco+Produto","Lote+Local+Produto+Local","Data Inventa+Produto+Local+Endereco+Lote"}
Private cUserEnv
Private cString   := "ZI2"
Private dDTREFINV := CTOD(GetMv("MV_DTINVRF"))
Private nOpc
Private cCadastro := "Geração de Contagem no arquivo de estatistica"
Private aRotina   := { {"Pesquisar"         ,"AxPesqui"      , 0, 1}}
     AAdd(aRotina ,    {"Visualiza"         ,"AxVisual"      , 0, 4} )
     AAdd(aRotina ,    {"Processa Itens   " ,"U_ItensInv()"  , 0, 3} ) ///Atualiza Base da Estatistica - ZI2
     AAdd(aRotina ,    {"Processa Contagem" ,"U_RUNZI1()"    , 0, 4} ) ///Atualiza Contagem no ZI2 pelo SZU
     AAdd(aRotina ,    {"Diverg.  Contagem" ,"U_envinv003()" , 0, 4} )
     AAdd(aRotina ,    {"Rel.Estat.Arm"     ,"U_envinv05()"  , 0, 4} )
     AAdd(aRotina ,    {"Rel.Estat.Arm+End.","U_envinv06()"  , 0, 4} )
     AAdd(aRotina ,    {"Excel"             ,"U_envinv07()"  , 0, 4} )
     AAdd(aRotina ,    {"Etiq. FIFO Inv."   ,"U_envinv04()"  , 0, 4} )
     AAdd(aRotina ,    {"Liberação Contagem","U_DTREFINV()"  , 0, 4} )
     AAdd(aRotina ,    {"Gera contagem Zero","U_GERA_ZERO()" , 0, 4} )
     AAdd(aRotina ,    {"Lista não contados","U_List_NCNT()" , 0, 4} ) 
     AAdd(aRotina ,    {"Transf Inv p/Padrao", "U_Bzinv06()" , 0, 4} ) 
     AAdd(aRotina ,    {"Forca 3a Contagem", "U_FORCECT3()" , 0, 4} ) 
     

dbSelectArea(cString)
dbSetOrder(1)
mBrowse(6,1,22,75,cString)
Return Nil

//Tela dos Itens do Inventariados
*******************************************************************************************************************
User Function ItensInv()
*******************************************************************************************************************
Private nUsado,aHeader,aCols
Private cCadastro := "Itens do Inventário"
Private dDTREFINV := CTOD(GetMv("MV_DTINVRF")) 

IF !MSGYESNO('PROCESSA ESTATISTICA PARA INVENTARIO ???? ','ALERTA')
	RETURN(.F.)
ENDIF	
	

/*If !U_fVer_Acesso(,,,,,.f.)
   MsgBox("Usuario Sem Acesso")
   Return
Endif
*/

Processa({|| fMk_IteInv()}, "Gerando Dados para Inventário ","...Aguarde ...")
Return Nil

********************************************************************************************************************
STATIC Function fMk_IteInv()
********************************************************************************************************************
Local oFont := TFont():New("Courier New",,-14,.T.,.T.)
Local oFont20 := TFont():New("Arial",,-20,.T.,.T.)
Local cQuery,nRegCont,nRegis

cQuery  :="SELECT B1_COD,B1_DESC,B1_TIPO,B1_GRUPO,B1_UM,B1_RASTRO,B1_LOCALIZ,B2_CM1"
cQuery  +=",B2_LOCAL AS ARM,B2_QATU AS QTD,ENDERECO='',LOTE='',SUBLOTE=''"
cQuery  +=" FROM "+RetSqlName("SB2")+" SB2 LEFT JOIN "+RetSqlName("SB1")+" SB1 ON B2_COD = B1_COD AND SB1.D_E_L_E_T_ <> '*'"
cQuery  +=" WHERE SB2.D_E_L_E_T_<>'*' AND B2_FILIAL='"+xFilial("SB2")+"' AND B2_QATU<>0 AND NOT B1_RASTRO IN ('S','L') AND B1_LOCALIZ<>'S'"

cQuery  +=" UNION "

cQuery  +=" SELECT B1_COD,B1_DESC,B1_TIPO,B1_GRUPO,B1_UM,B1_RASTRO,B1_LOCALIZ,B2_CM1=0"
cQuery  +=",BF_LOCAL AS ARM,BF_QUANT AS QTD,BF_LOCALIZ AS ENDERECO,BF_LOTECTL AS LOTE,BF_NUMLOTE AS SUBLOTE"
cQuery  +=" FROM "+RetSqlName("SBF")+" SBF LEFT JOIN "+RetSqlName("SB1")+" SB1 ON BF_PRODUTO = B1_COD AND SB1.D_E_L_E_T_ <> '*' "
cQuery  +=" LEFT JOIN "+RetSqlName("SB2")+" SB2 ON BF_FILIAL = B2_FILIAL AND BF_PRODUTO = B2_COD AND SB1.D_E_L_E_T_ <> '*'"
cQuery  +=" WHERE SBF.D_E_L_E_T_<>'*' AND BF_FILIAL='"+xFilial("SBF")+"' AND BF_QUANT<>0 AND B1_LOCALIZ='S' "

cQuery  +=" UNION "

cQuery  +=" SELECT B1_COD,B1_DESC,B1_TIPO,B1_GRUPO,B1_UM,B1_RASTRO,B1_LOCALIZ,B2_CM1=0"
cQuery  +=",B8_LOCAL AS ARM,B8_SALDO AS QTD,ENDERECO='',B8_LOTECTL AS LOTE,B8_NUMLOTE AS SUBLOTE"
cQuery  +=" FROM "+RetSqlName("SB8")+" SB8 LEFT JOIN "+RetSqlName("SB1")+" SB1 ON B8_PRODUTO = B1_COD AND SB1.D_E_L_E_T_ <> '*'"
cQuery  +=" WHERE SB8.D_E_L_E_T_<>'*' AND B8_FILIAL='"+xFilial("SB8")+"' AND B8_SALDO<>0 AND B1_LOCALIZ='N' AND  B1_RASTRO IN ('S','L') "

TCQUERY cQuery NEW ALIAS TMQ
COUNT TO  nRegis

dbSelectArea("TMQ")
DbGotop()
ProcRegua(nRegis)
nRegCont := 0
While TMQ->(!Eof())
  cCod_ant := TMQ->B1_COD
  _nCm1    := VlrMedio(TMQ->B1_COD)
  DO While TMQ->(!Eof()) .and. TMQ->B1_COD == cCod_ant
     nRegCont := nRegCont+1
     IncProc("Reg =>"+StrZero(nRegCont,10)+" / "+strZero(nRegis,10))
     DbSelectArea("ZI2")
     DbSetOrder(05)
    
     DbSeek(xFilial("ZI2")+Dtos(dDTREFINV)+TMQ->B1_COD+TMQ->ARM+TMQ->ENDERECO,.T.)  // Alterado em 24/06/2014
     
     lEof   := IIF(!EOF().AND.ZI2_FILIAL==xFilial("ZI2").AND.ZI2_DTINV==dDtRefInv.AND.ZI2_COD==TMQ->B1_COD.AND.ZI2_LOCAL==TMQ->ARM.AND.ZI2_LOCALI==TMQ->ENDERECO , .F. , .T. )
     //lEof := IIF(!EOF().AND.ZI2_FILIAL==xFilial("ZI2").AND.ZI2_DTINV==dDtRefInv.AND.ZI2_COD==TMQ->B1_COD.AND.ZI2_LOCAL==TMQ->ARM , .F. , .T. )
     //IF ( lEof )
        RecLock("ZI2",lEof)
        ZI2->ZI2_FILIAL   := xFilial("ZI2")
        ZI2->ZI2_COD      := TMQ->B1_COD
        ZI2->ZI2_DESC     := TMQ->B1_DESC
        ZI2->ZI2_TIPO     := TMQ->B1_TIPO
        ZI2->ZI2_GRUPO    := TMQ->B1_GRUPO
	     ZI2->ZI2_UM       := TMQ->B1_UM
	     ZI2->ZI2_RASTRO   := TMQ->B1_RASTRO
	     ZI2->ZI2_CTLEND   := TMQ->B1_LOCALIZ
	     ZI2->ZI2_LOCAL	  := TMQ->ARM
		 
		 nSldSB2 := CALCEST(TMQ->B1_COD,TMQ->ARM,dDTREFINV+1) // Saldo em estoque do almoxarifado de processo (WIP)	     	     
	     ZI2->ZI2_CM1      := ( nSldSB2[2]/nSldSB2[1] ) 
	     
		 // nSldSB2 := CALCEST(TMQ->B1_COD,TMQ->ARM,dDTREFINV+1) // Saldo em estoque do almoxarifado de processo (WIP)	     
 	     ZI2->ZI2_SLDATU   := TMQ->QTD      // ( ZI2->ZI2_SLDATU +TMQ->QTD )
 	     //ZI2->ZI2_SLDATU   :=nSldSB2[1]
 	     
	     ZI2->ZI2_LOCALI   := TMQ->ENDERECO
	     ZI2->ZI2_LOTE     := TMQ->LOTE
	     ZI2->ZI2_DTINV    := dDTREFINV
	     ZI2->ZI2_ORIGEM   := "S"
	     ZI2->ZI2_CONTAG   := "0"
     //Else
        //RecLock("ZI2",.F.)
        //ZI2->ZI2_DESC     := TMQ->B1_DESC
        //ZI2->ZI2_TIPO     := TMQ->B1_TIPO
        //ZI2->ZI2_GRUPO    := TMQ->B1_GRUPO
	    //ZI2->ZI2_UM       := TMQ->B1_UM
	    //ZI2->ZI2_RASTRO   := TMQ->B1_RASTRO
	    //ZI2->ZI2_CTLEND   := TMQ->B1_LOCALIZ
	    //ZI2->ZI2_CM1      := _nCm1
 	    //ZI2->ZI2_SLDATU   := TMQ->QTD
     //Endif
     MsUnLock()
     DbSelectArea("TMQ")
     TMQ->(DbSkip())
  EndDo
Enddo

DbSelectArea("TMQ")
DbCloseArea() 			// Fecha consulta
Return
********************************************************************************************************************************************************
Static Function VlrMedio(pProduto)//Função para pegar o valor do Custo Médio do Produto
********************************************************************************************************************************************************
Local nPrcVen, cAlias, cOrdem, nRecno
Local cQuery  :="SELECT TOP 1 B9_VINI1/B9_QINI AS MEDIO  FROM "+RetSqlName("SB9")+" SB9A  WHERE SB9A.D_E_L_E_T_<>'*' AND SB9A.B9_FILIAL='"+xFilial("SB9")+"' AND SB9A.B9_COD ='"+pProduto+"' AND SB9A.B9_VINI1<>0 AND SB9A.B9_QINI<>0 ORDER BY SB9A.B9_DATA DESC"

nPrcVen := 0
cAlias  := Alias()
cOrdem  := IndexOrd()
nRecno  := Recno()

TCQUERY cQuery NEW ALIAS TMP

dbSelectArea("TMP")
DbGotop()
If !Eof()
   nPrcVen := Tmp->Medio
EndIf
dbSelectArea("TMP")
DbCloseArea() 			// Fecha consulta

If nPrcVen <= 0
    nPrcVen :=Posicione("SB2" ,1, xFilial("SB2") + pProduto,"B2_CM1")
Endif
dbSelectArea(cAlias)
dbSetOrder(cOrdem)
dbGoto(nRecNo)
Return(nPrcVen)     

**********************************************************************************************************************************************
User Function RUNZI1()     //Rotina de geração
**********************************************************************************************************************************************
Local oFont31 := TFont():New("Arial",,-20,.T.,.T.)
Local oFont32 := TFont():New("Arial",,-50,.T.,.T.)
SetPrvt("DDATAINI,DDATAFIM")
cPerg := "RUNZI1"
aRegs := {}
ValPerg(cPerg)
Pergunte(cPerg,.F.)

@ 96,042 TO 290,505 DIALOG oDlg5 TITLE "Processa contagem na tabela ZI2"
@ 08,010 TO 84,222
@ 08,099 TO 84,222
@ 60,101 TO 82,220
@ 65,108 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg)
@ 65,148 BMPBUTTON TYPE 1 ACTION Processa({||ConfRUN()}, " Processa Movimentos ",".....")
@ 65,188 BMPBUTTON TYPE 2 ACTION Close(oDlg5)
@ 13,100 SAY "GA.MA"  OBJECT oItem1 SIZE 150,40
oItem1:oFont    := oFont32
oItem1:nClrText := CLR_BLUE
@ 43,102 SAY "ITALY."  OBJECT oItem2 SIZE 150,40
oItem2:oFont    := oFont31
oItem2:nClrText := CLR_BLUE

@ 23,014 SAY "Gera contagens na tabela de "
@ 33,014 SAY "estatistica.Esta rotina gera "
@ 43,014 SAY "as quantidades da 1a, 2a e 3a "
@ 53,014 SAY "contagem para a tabela estatis-"
@ 63,014 SAY "tica (ZI2),conforme solicitados"
@ 73,014 SAY "nos parâmetros."
ACTIVATE DIALOG oDlg5 CENTERED
Return

*****************************************************************************************************************************************************
Static Function ValPerg(cPerg)
*****************************************************************************************************************************************************
Local aHelp	:= {}
Local i,j
_sAlias := Alias()
aRegs := {}
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,8)
Aadd(aHelp,{{"Armazém De"},{""},{""} })
Aadd(aHelp,{{"Armazém Até"},{""},{""} })

PutSx1(cPerg,'01','Armazém?'         ,'' ,'' , 'mv_ch1', 'C', 02, 0, 0, 'G','ExistCpo("SX5","Z1"+MV_PAR01)', '        ','', '', 'mv_par01',,,'','','','','','','','','','','','','','', aHelp[1][1],aHelp[1][2],aHelp[1][3])
PutSx1(cPerg,'02','Armazém?'         ,'' ,'' , 'mv_ch2', 'C', 02, 0, 0, 'G','ExistCpo("SX5","Z1"+MV_PAR02)', '        ','', '', 'mv_par02',,,'','','','','','','','','','','','','','', aHelp[2][1],aHelp[2][2],aHelp[2][3])

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next
dbSelectArea(_sAlias)
Return

*****************************************************************************************************************************************************
Static Function ConfRUN()
*****************************************************************************************************************************************************
Local cQuery ,nRegis ,nRegCont
cQuery :=" UPDATE "+RetSqlName("ZI2")+" SET ZI2_CONT1=0,ZI2_CONT2=0,ZI2_CONT3=0,ZI2_CONTAG=0,ZI2_QRCON1=0,ZI2_QRCON2=0,ZI2_QRCON3=0,ZI2_QTDINV=0,ZI2_QTDIFE=0"
cQuery +=" FROM "+RetSqlName("ZI2")
cQuery +=" WHERE D_E_L_E_T_<>'*' AND "
cQuery +=" ZI2_DTINV = '"+DTOS(dDTREFINV)+"' AND "
cQuery +=" ZI2_LOCAL BETWEEN '"+MV_Par01+"' AND '"+Mv_Par02+"' " 
cQuery +=" AND  ZI2_FILIAL="+xFilial("ZI2")

nErUpd := TcSqlExec( cQuery )

//If nErUpd <> 0
//	ApMsgInfo("Erro no UPDATE da tabela CT2(Movimentos Contabeis).","Atenção...")
//Else
//	ApMsgInfo("Arquivo gerado com sucesso.","Informativo")
//EndIf

cQuery  :=" SELECT ZU_COD,ZU_LOCPAD,ZU_LOCALIZ,ZU_ULTCONT,SUM(ZU_CONT1)AS CONT1,SUM(ZU_CONT2)AS CONT2,SUM(ZU_CONT3)AS CONT3,COUNT(*) AS REG"
cQuery  +=" FROM "+RetSqlName("SZU")+" SZU "
cQuery  +=" WHERE D_E_L_E_T_<>'*' AND "
cQuery  +=" ZU_DATA ='"+DTOS(dDTREFINV)+"' AND "
cQuery  +=" ZU_LOCPAD BETWEEN '"+MV_Par01+"' AND '"+Mv_Par02+"' "
cQuery  +=" AND ZU_FILIAL="+xFilial("SZU")                                                          
cQuery  +=" GROUP BY ZU_COD,ZU_LOCPAD,ZU_LOCALIZ,ZU_ULTCONT ORDER BY  ZU_COD,ZU_LOCPAD,ZU_LOCALIZ,ZU_ULTCONT "
//cQuery+=" GROUP BY ZU_COD,ZU_LOCPAD,ZU_LOCALIZ,ZU_ULTCONT ORDER BY  ZU_COD,ZU_LOCPAD,ZU_LOCALIZ"

TCQUERY cQuery NEW ALIAS TMQ
COUNT TO  nRegis

dbSelectArea("TMQ")
DbGotop()
ProcRegua(nRegis)
nRegCont := 0

DO While TMQ->(!Eof())
   
   cCondAnt    := TMQ->ZU_COD+TMQ->ZU_LOCPAD +TMQ->ZU_LOCALIZ  //+TMQ->ZU_LOTECTL
   _nReg1_Cont := _nReg2_Cont := _nReg3_Cont := 0
   
   DO WHILE TMQ->(!Eof()) .and. cCondAnt == TMQ->ZU_COD+TMQ->ZU_LOCPAD +TMQ->ZU_LOCALIZ
       nRegCont := nRegCont+1
       IncProc("Reg =>"+StrZero(nRegCont,10)+" / "+strZero(nRegis,10))
       DbSelectArea("ZI2")
       DbSetOrder(05)               
       
       DbSeek(xFilial("ZI2")+DTOS(dDTREFINV)+TMQ->ZU_Cod+TMQ->ZU_LocPad+TMQ->ZU_LOCALIZ ,.T.)  //+TMQ->ZU_LoteCtl)
       lEof   := IIF(!EOF().AND.ZI2_FILIAL==xFilial("ZI2").AND.ZI2_DTINV==dDtRefInv .AND. alltrim(ZI2->ZI2_COD)==ALLTRIM(TMQ->ZU_COD) .AND. ZI2_LOCAL==TMQ->ZU_LOCPAD.AND.ZI2_LOCALI==TMQ->ZU_LOCALIZ , .F. , .T. )
       
       //lEof := IIF(!EOF().AND.ZI2_FILIAL==xFilial("ZI2").AND.ZI2_DTINV==dDtRefInv .AND. alltrim(ZI2->ZI2_COD)==ALLTRIM(TMQ->ZU_COD) .AND. ZI2_LOCAL==TMQ->ZU_LOCPAD , .F. , .T. )
       IF ( !lEof )
          ZI2->(RecLock("ZI2",.F.))
          
          ZI2->ZI2_Cont1  := TMQ->Cont1+ZI2->ZI2_Cont1
          ZI2->ZI2_Cont2  := TMQ->Cont2+ZI2->ZI2_Cont2
          ZI2->ZI2_Cont3  := TMQ->Cont3+ZI2->ZI2_Cont3 
                                                     
          ZI2->ZI2_Contag := StrZero(TMQ->ZU_ULTCONT,1)
          ZI2->ZI2_QtdInv := ZI2->ZI2_QtdInv + IIF(TMQ->(Cont1-Cont2)==0 .and.  StrZero(TMQ->ZU_ULTCONT,1)<>'3'  ,TMQ->Cont2,TMQ->Cont3)

          /*           
          If ZI2->ZI2_Contag = '1'
             //ZI2->ZI2_QtdInv := ZI2->ZI2_Cont1
             ZI2->ZI2_QtdInv += ZI2->ZI2_Cont1
          ElseIf ZI2->ZI2_Contag = '2'
             ZI2->ZI2_QtdInv += ZI2->ZI2_Cont2
          ElseIf ZI2->ZI2_Contag = '3'
             ZI2->ZI2_QtdInv += ZI2->ZI2_Cont3
          Else
             ZI2->ZI2_QtdInv := 0
          Endif
          */                     
          
          
          ZI2->ZI2_QtDife := ZI2->ZI2_QtdInv - ZI2->ZI2_SldAtu
          MsUnLock()     
          If TMQ->ZU_ULTCONT = 1
            _nReg1_Cont := TMQ->Reg
          ElseIf TMQ->ZU_ULTCONT = 2
            _nReg2_Cont := TMQ->Reg
          ElseIf TMQ->ZU_ULTCONT = 3
            _nReg3_Cont := TMQ->Reg
          endif
          
       Else
          _nCm1 := 0 // VlrMedio(TMQ->ZU_Cod)  
          CTLEND := Posicione("SB1",1,xFilial("SB1")+TMQ->ZU_Cod,"B1_LOCALIZ")
          nSldSB2 := CALCEST(TMQ->ZU_COD,TMQ->ZU_LocPad,dDTREFINV+1) // Saldo em estoque do almoxarifado de processo (WIP)	     	     
	      ZI2->(RecLock("ZI2",.T.))
          ZI2->ZI2_FILIAL   := xFilial("ZI2")
          ZI2->ZI2_COD      := TMQ->ZU_Cod
          ZI2->ZI2_DESC     := Posicione("SB1",1,xFilial("SB1")+TMQ->ZU_Cod,"B1_DESC")
          ZI2->ZI2_TIPO     := Posicione("SB1",1,xFilial("SB1")+TMQ->ZU_Cod,"B1_TIPO")
          ZI2->ZI2_GRUPO    := Posicione("SB1",1,xFilial("SB1")+TMQ->ZU_Cod,"B1_GRUPO")
	      ZI2->ZI2_UM       := Posicione("SB1",1,xFilial("SB1")+TMQ->ZU_Cod,"B1_UM")
	      ZI2->ZI2_RASTRO   := Posicione("SB1",1,xFilial("SB1")+TMQ->ZU_Cod,"B1_RASTRO")
	      ZI2->ZI2_CTLEND   := CTLEND
	      ZI2->ZI2_LOCAL	 := TMQ->ZU_LocPad
	      ZI2->ZI2_CM1      := ( nSldSB2[2]/nSldSB2[1] ) 
 	      ZI2->ZI2_SLDATU   := 0  // o saldo deve vir zero devido nao ter sido gerado pelo sistema , ja que nao existia no momento da geracao
 	      //IIF(LEN(ALLTRIM(TMQ->ZU_Localiz))==0 .AND. CTLEND=='S',0, IIF(LEN(ALLTRIM(TMQ->ZU_Localiz))<>0 .AND. CTLEND=='S',Posicione("SBF",1,xFilial("SBF")+TMQ->ZU_LocPad+TMQ->ZU_Localiz+TMQ->ZU_Cod,"BF_QUANT"),nSldSB2[1])) 	      
 	      ZI2->ZI2_LOCALI   := TMQ->ZU_Localiz
	      //ZI2->ZI2_LOTE     := TMQ->ZU_LoteCtl
	      ZI2->ZI2_DTINV    := dDTREFINV
	      ZI2->ZI2_ORIGEM   := "U"
          ZI2->ZI2_Cont1    := TMQ->Cont1
          ZI2->ZI2_Cont2    := TMQ->Cont2
          ZI2->ZI2_Cont3    := TMQ->Cont3
          ZI2->ZI2_Contag   := StrZero(TMQ->ZU_ULTCONT,1)
          ZI2->ZI2_QtdInv   := ZI2->ZI2_QtdInv + IIF(TMQ->(Cont1-Cont2)==0 .and.  ZI2->ZI2_Contag<>'3'  ,TMQ->Cont2,TMQ->Cont3)
          //ZI2->ZI2_QtdInv   := IIF(TMQ->(Cont1-Cont2)==0 .and.  TMQ->Cont3==0 ,TMQ->Cont2,TMQ->Cont3)
          /*
          If ZI2->ZI2_Contag = '1'
             ZI2->ZI2_QtdInv := ZI2->ZI2_Cont1
          ElseIf ZI2->ZI2_Contag = '2'
             ZI2->ZI2_QtdInv := ZI2->ZI2_Cont2
          ElseIf ZI2->ZI2_Contag = '3'
             ZI2->ZI2_QtdInv += ZI2->ZI2_Cont3
          Else
             ZI2->ZI2_QtdInv := 0
          Endif
          */
          ZI2->ZI2_QtDife := ZI2->ZI2_QtdInv - ZI2->ZI2_SldAtu
          MsUnLock()
          If TMQ->ZU_ULTCONT = 1
            _nReg1_Cont := TMQ->Reg
          ElseIf TMQ->ZU_ULTCONT = 2
            _nReg2_Cont := TMQ->Reg
          ElseIf TMQ->ZU_ULTCONT = 3
            _nReg3_Cont := TMQ->Reg
          endif
       Endif
       DbSelectArea("TMQ")
       TMQ->(DbSkip())
   EndDo
   //Atualiza o numero de registro na primeira , segunda e terceira contagem
   DbSelectArea("ZI2")
   ZI2->(RecLock("ZI2",.F.))
   ZI2->ZI2_QRCon1 := _nReg1_Cont+_nReg2_Cont+_nReg3_Cont
   ZI2->ZI2_QRCon2 := _nReg2_Cont+_nReg3_Cont
   ZI2->ZI2_QRCon3 := _nReg3_Cont
   ZI2->(MsUnLock())
   //DbSelectArea("TMQ")
  // DbSkip()
Enddo
DbSelectArea("TMQ")
DbCloseArea() 			// Fecha consulta
Close(oDlg5)
Return