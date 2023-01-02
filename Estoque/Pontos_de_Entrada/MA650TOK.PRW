#Include "Rwmake.ch"
#include "topconn.ch"
/*_____________________________________________________________________________
¦ Função    ¦ MA650TOk   ¦ Autor ¦ Romualdo Neto            ¦ Data ¦ 28-10-13 ¦
+-----------+------------+-------+------------------------+------+------------+
¦ Descriçäo ¦ Validação da Abertura da OP													¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function MA650TOk()

Local cFuncao := Upper(Alltrim(FunName()))
Local lRet := .T.
Local aArea := GetArea()
Local cXEmpOp := "T"
Local cXSLEMP := GETMV("MV_XSALEMP")
Local cQuery  := ""
Local cEndProd := ALLTRIM(M->C2_XEND)
Local cCodMolde := M->C2_XMOLDE
Local lBR_XMOLDE := GETMV("BR_XMOLDE")
Private _cRev   := M->C2_REVISAO
Private cTexto := ""                  
Private cProPi := M->C2_PRODUTO
Private cTipoOP := M->C2_TPOP
Private RFlag  := "S"
Private cDcreVazio   := EMPTY(ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+cProPi,"B1_DCRE")))
Private cTipoPA      := POSICIONE("SB1",1,XFILIAL("SB1")+cProPi,"B1_TIPO")=="PA"


cPro := M->C2_PRODUTO
SB1->(dbseek(xFilial()+cPro))



IF cFuncao = "MATA650" .and. Inclui .AND. cXSLEMP == "S"
	
	If cXEmpOp == "F"			// Checa só os filhos
		
		//		cQuery := "Select B2_COD, B1_DESC, Sum(G1_QUANT) As Necess, Sum(B2_QATU - B2_QEMP) AS Saldo"
		cQuery := "Select B2_COD, B1_DESC, Sum(G1_QUANT) As Necess, Sum(B2_QATU) AS Saldo, SUM(B2_QEMP) AS Empenho, SUM (B2_QATU - B2_QEMP) Total,"
		cQuery += "G1_GROPC, G1_OPC From " + RetSQLName("SG1") + " As G1"
		cQuery += ", " + RetSQLName("SB2") + " As B2"
		cQuery += ", " + RetSQLName("SB1") + " As B1"
		cQuery += " Where G1.D_E_L_E_T_ = ''"
		cQuery += " And G1_FILIAL = '" + SG1->(xFilial()) + "'"
		cQuery += " And G1_COD = '" + M->C2_PRODUTO + "'"
		//		cQuery += " And '" + Dtos(dDataBase) + "' Between G1_INI And G1_FIM"
		cQuery += " And '" + Dtos(dDataBase) + "' >= G1_INI "
		cQuery += " And '" + Dtos(dDataBase) + "' <= G1_FIM "
		cQuery += " And '" +_cRev+ "' >= G1_REVINI "
		cQuery += " And '" +_cRev+ "' <= G1_REVFIM "
		cQuery += " And Left(G1_COMP, 3) <> 'MOD'"
		
		cQuery += " And B2.D_E_L_E_T_ = ''"
		cQuery += " And B2_FILIAL = '" + SB2->(xFilial()) + "'"
		cQuery += " And B2_COD = G1_COMP"
		cQuery += " And B2_LOCAL = '11'
		
		cQuery += " And B1.D_E_L_E_T_ = ''"
		cQuery += " And B1_FILIAL = '" + SB1->(xFilial()) + "'"
		cQuery += " And B1_COD = G1_COMP"
		cQuery += " And B1_MSBLQL <> '1'"
		cQuery += " And B1_TIPO IN ('EM', 'MP')
		cQuery += " And B1_FANTASM <> 'S'"
		
		cQuery += " And (B2_QATU - B2_QEMP) < G1_QUANT * " + AllTrim(Str(M->C2_QUANT))
		//		cQuery += " And (B2_QATU) < G1_QUANT * " + AllTrim(Str(M->C2_QUANT))
		
		cQuery += " Group by B2_COD, B1_DESC, G1_GROPC, G1_OPC"
		
		TCQUERY ChangeQuery(cQuery) NEW ALIAS "TSG1"
		memowrite("NEC_OP",cQuery)
		
		//			cTexto += "Comp:" + TSG1->B2_COD + "-" + TSG1->B1_DESC + " Necessidade: " + Str(TSG1->Necess * M->C2_QUANT, 15, 4) + " Saldo: " + Str(TSG1->Saldo, 15, 4) + chr(13)+chr(10)
		cTexto += "Produto: " + ALLTRIM(TSG1->B2_COD) + "-" + ALLTRIM(TSG1->B1_DESC) + "; Necessidade: " + Str(TSG1->Necess * M->C2_QUANT, 15, 4) + ";  Saldo Atual: " + Str(TSG1->Saldo, 15, 4) + "; Empenho: " +Str(TSG1->Empenho, 15, 4) + ";Saldo Disponivel: " +Str(TSG1->Total, 15, 4) + chr(13)+chr(10)
		//alert(cTexto)
		
		
		
		TSG1->(dbSkip())
		
		
		TSG1->(dbCloseArea())
		
	Else
		
		
		MA650TOka(M->C2_PRODUTO, M->C2_Quant, "")
		
	EndIf
	nLote:=Posicione("SB1",1,xfilial("SB1")+M->C2_PRODUTO,"B1_QE")  
	cTipo:=Posicione("SB1",1,xfilial("SB1")+M->C2_PRODUTO,"B1_TIPO")  
	IF (nLote==0 .or. nLote==1) .and. cTipo=="PA" 
	 alert("Favor Cadastrar a Quantidade por embalagem do Produto!!")
	 Return(.F.)
	endif 
	IF Mod(M->C2_Quant,nLOTE) == 1 .and. cTipo=="PA"         
	  alert("Favor Colocar OP´s Multiplas da Qtde por Embalagem! Embalagem atual é "+str(nLote,8))
	  RestArea(aArea)
      Return(.F.)
	ENDIF
	lRet := .T. 
	If !Empty(cTexto)
		
  //		Aviso("Atencao","Não existem saldos suficientes no estoque para atender esta Ordem de Produção!",{"OK"})
  // adicionado por Ricky 03/06/19
  // Se Op Tipo Firme não deixa incluir por falta de saldo
  /* DESATIVAR PONTO DE ENTRADA conforme solicitado pelo Bruno Martins (PCP)  em 21/01/2020, Não fazer consulta de saldo no estoque*/
  /*INICIO
		IF cTipoOP = 'F'
	  		Alert('<h2>Atenção</h2> Esta OP não pode ser aberta como Tipo = <b>FIRME</b><br> Sem saldo no estoque para atender.')
			lRet := .F. 
		ELSE           
	  		MSGINFO("Não existem saldos suficientes no estoque para atender esta Ordem de Produção! <br> OP tipo : <b>Prevista</b><br>","Atenção")
			lRet := .T. 
	  ENDIF
		
		
		U_GRVTXT(CTEXTO)
		oFont:= TFont():New("COURIER NEW",07,15)
		
		@ 000,000 To 300,700 Dialog oDlgMemo Title "Produtos sem Saldo"
		@ 001,003 Get cTexto Size 340,130  MEMO Object oMemo When .F.
		oMemo:oFont:=oFont
		
		@ 140,170 BmpButton Type 1 Action CLOSE(oDLGMEMO) Object oConf
		
		Activate Dialog oDlgMemo CENTERED On Init (oMemo:SetFocus())
		
//		MSGALERT( 'OP não pode ser aberta Tipo = FIRME','Sem saldo de MP' )
//		lRet := .F.    //vai dar o alerta mas nao vai travar a OP em 06/07/2016 solicitado por itamar
	FIM*/ 		
	EndIf

ENDIF   




IF lRet .and. cEndProd =='INJECAO' .and. lBR_XMOLDE
	if EMPTY(cCodMolde)
		ALERT("Favor Informar o Codigo do Molde")
		lRet:=.F.		
	endif
	
ENDIF



IF lRet
	MSGINFO ("Para a atualizacao dos Empenhos e necessario sair da area de inclusao de OP's","Atualização de Empenhos")
ENDIF


//IF lRet
 //Processa({|lEnd| MA650Process(.T.,1)},"","",.F.)//  claudio 28/08/14 para atualizar os empenhso
 //MA650Process(.F.,1) //explode as op's intermediarias  claudio 28/08/14 
 //A650AtEmpn(M->C2_Quant,"+","F")      //  claudio 28/08/14 para atualizar os empenhso
//Endif 


IF cFuncao = "MATA650" .and. Inclui
    If  cDcreVazio .and. cTipoPA .and. RTRIM(SM0->M0_CODFIL) = '01'
	    M->C2_TPOP = 'P'
	Endif
Endif

RestArea(aArea)

Return lRet




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A650AtEmpn ³ Autor ³Rodrigo de A. Sartorio ³ Data ³04/06/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza o campo B2_QEMPN                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Mata650                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/   
/*
Static Function A650AtEmpn(nQuant,cSinal,cTpOP)
Local aArea		:= GetArea()
Local nMutiplic	:= If(cSinal=="+",1,-1)
Local lAtuSGJ	:= SuperGetMV("MV_PVCOMOP",.F.,.F.) .And. FindFunction("ALIASINDIC") .And. AliasIndic("SGJ")

DEFAULT cSinal 	:= "+"
DEFAULT cTpOP  	:= "F"

dbSelectArea("SB2")
RecLock("SB2",.F.)
If AllTrim(cTpOP) == "F"
	Replace B2_QEMPN  With Max(0,B2_QEMPN + (nQuant*nMutiplic))
	Replace B2_QEMPN2 With Max(0,B2_QEMPN2 + (ConvUM(SB2->B2_COD,nQuant,0,2)*nMutiplic))
ElseIf AllTrim(cTpOP) == "P"
	Replace B2_QEMPPRE With Max(0,B2_QEMPPRE + (nQuant*nMutiplic))
	Replace B2_QEPRE2  With Max(0,B2_QEPRE2 + (ConvUM(SB2->B2_COD,nQuant,0,2)*nMutiplic))
EndIf
MsUnlock()
Return
If lAtuSGJ .And. cSinal == "+"
	A650AtuSGJ(nQuant)
Endif

RestArea( aArea )

Return
*/



/*_____________________________________________________________________________
¦ Função    ¦ MA650TOka  ¦ Autor ¦       ¦ Data ¦ ¦
+-----------+------------+-------+------------------------+------+------------+
¦ Descriçäo ¦ Explosão de Estrutura															¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
Static Function MA650TOka(cComp, nQuant, cOpc)
Local cEmp	   := SM0->M0_CODIGO
Local cQuery   := ""
Local cQuery2  := ""
Local _ValEst  := {}
Local _ValEst2 := {}
Local _cTipo   := POSICIONE("SB1",1,XFILIAL("SB1")+cComp,"B1_TIPO")
LOCAL _cAprop  := POSICIONE("SB1",1,XFILIAL("SB1")+cComp,"B1_APROPRI")
Local _cSaldo  := ""
Local _cSldEmp := POSICIONE("SB2",1,XFILIAL("SB2")+cComp+"20","B2_QEMP")
Local _cRev2   := M->C2_REVISAO
//Local _cDisp   := _cSaldo - _cEmp
Local _cFlag   := "S"
LOCAL nRegSG1  := SG1->(recno())

// Alterado por RMH Informatica  - Reginaldo Silva (11/01/2014)
IF (cEmp == "04" .OR. cEmp == "01") // EMPRESA TECHIT
	
	Simula_a( cProPi , nQuant  ) // Explode o Codigo Pai
	
ENDIF

RETURN Nil

// Explode os PAs para TECHIT/BRASITECH
STATIC FUNCTION Simula_a(cCodPai,nQuant)
LOCAL nTotCus2 := 0
LOCAL cRevComp:=Posicione('SB1',1,xfilial("SB1")+cCodPai,"B1_REVATU")
Local nI
PRIVATE nTotCus
SG1->(dbsetorder(1))
SG1->(dbseek(xFilial("SG1")+cCodPai) )


aComp := {}
DO WHILE SG1->G1_FILIAL+SG1->G1_COD == xFilial("SG1")+cCodPai .AND. !SG1->(eof())
	nRecno := SG1->( RECNO() )  
	//considerar a revisao do produto 20/03/2018 por claudio os produtos intermediarios estavam pegando revisoes anteriores
	IF  SG1->G1_REVFIM==cRevComp .OR. SG1->G1_REVFIM=="ZZZ" 
	 Simula_b( SG1->G1_COMP , (nQuant * SG1->G1_Quant) , (SG1->G1_GROPC + SG1->G1_OPC) , @aComp )
	Endif
	SG1->( dbGoTo(nRecno) )
	SG1->( dbSkip() )
ENDDO      

IF LEN(aComp)>0
	cTexto += "Produto;Tipo;Descricao;Necessidade:; Saldo Almox: ; Empenho: ;  Saldo Processo: ; Saldo Disponivel: " + chr(13)+chr(10)
ENDIF	
           

FOR nI:=1 TO LEN(aComp)

     _CDesc   := POSICIONE("SB1",1,XFILIAL("SB1")+aComp[nI,1],"B1_DESC") 
     _cTipo   := POSICIONE("SB1",1,XFILIAL("SB1")+aComp[nI,1],"B1_TIPO")
     
     
     //cTexto += "Produto: " + ALLTRIM(aComp[nI,1]) + "-"+_cTipo+"-"+ALLTRIM(_CDesc) "; Necessidade: " + Str(aComp[nI,2], 15, 4) +;
     //          ";  Saldo Atual: " + Str(aComp[nI,3], 15, 4) + "; Empenho: " +Str(aComp[nI,4], 15, 4) +;
     //          ";  Saldo Processo: " + Str(aComp[nI,6], 15, 4) + ";Saldo Disponivel: " +Str(aComp[nI,5], 15, 4) + chr(13)+chr(10)
     
     cTexto += ALLTRIM(aComp[nI,1])+";"+_cTipo+";"+ALLTRIM(_CDesc)+";" + TRANSFORM(aComp[nI,2], "@E 999,999.9999" ) +;
               ";" + TRANSFORM(aComp[nI,3], "@E 999,999.9999" ) + ";" +TRANSFORM(aComp[nI,4], "@E 999,999.9999" ) +;
               ";" + TRANSFORM(aComp[nI,6], "@E 999,999.9999" ) + ";" +TRANSFORM(aComp[nI,5], "@E 999,999.9999" ) + chr(13)+chr(10)



NEXT nI

RETURN



// Explode os componentes para TECHIT/BRASITECH
STATIC FUNCTION Simula_b( cComp , nQtd , cOpc, aComp )
LOCAL nRec,nI
LOCAL cRevComp
_cFantas  := POSICIONE("SB1",1,XFILIAL("SB1")+cComp,"B1_FANTASM")
_cBlock   := POSICIONE("SB1",1,XFILIAL("SB1")+cComp,"B1_MSBLQL")
_cTipo   := POSICIONE("SB1",1,XFILIAL("SB1")+cComp,"B1_TIPO")
IF (dDataBase<SG1->G1_Ini .or. dDataBase>SG1->G1_Fim)  .OR. !(cOpc $ M->C2_Opc) .OR. _cBlock == "1"
//IF (SG1->G1_Ini > dDataBase .or. SG1->G1_Fim < dDataBase) .OR. _cFantas == "S" .OR. !(cOpc $ M->C2_Opc) .OR. _cBlock == "1"
	//SG1->(dbskip())
	Return
ENDIF                                                                                                                         


_cProces:=GETMV("MV_LOCPROC")


_cAprop  := ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+cComp,"B1_APROPRI"))
_cAlmox  := IIF(_cTipo$'PI/SA',"11",ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1")+cComp,"B1_LOCPAD")) )    
_ValEst  := POSICIONE("SB2",1,XFILIAL("SB2")+cComp+_cAlmox,"B2_QATU")        

If _cTipo=='PI'
  _ValEst  := _ValEst + ( POSICIONE("SB2",1,XFILIAL("SB2")+cComp+"14","B2_QATU") )  // por claudio solicitado por fabio para acumular com saldo do almox 14 19/11/14
Endif          

_ValEst2 := POSICIONE("SB2",1,XFILIAL("SB2")+cComp+_cProces,"B2_QATU") // CALCEST(cComp,GETMV("MV_LOCPROC"),DDATABASE+1)  Saldo em estoque do almoxarifado de processo (WIP)
_cSfut   :=POSICIONE("SB2",1,XFILIAL("SB2")+cComp+_cAlmox,"B2_NAOCLAS")        //calcest soma B2_NAOCLAS  01/08/2014



//_ValEst := _ValEst - SldEnd(cComp,_cProces)  //Diminuir o saldo do endereço de setup da resina solicitado p/ Fabio em 30/09/15
                                               
IF _cAprop == "D"
	_cSldEmp := POSICIONE("SB2",1,XFILIAL("SB2")+cComp+_cAlmox,"B2_QEMP")
	_cSaldo  := ( _ValEst - _cSldEmp ) // Saldo disponivel=(saldo do ALMOX PADRAO - (empenho do ALMOX PADRAO)
ELSE
	_cSldEmp := POSICIONE("SB2",1,XFILIAL("SB2")+cComp+GETMV("MV_LOCPROC"),"B2_QEMP")
	//_cSaldo:= _ValEst[1] - ( _ValEst2[1]-_cSldEmp)  // Saldo disponivel=(saldo do 11 - (empenho do 20 - saldo est 20) )
	_cSaldo:=  _ValEst - ( _cSldEmp-_ValEst2)  // Saldo disponivel=(saldo do 11 - (empenho do 20 - saldo est 20) )
ENDIF


//Alterado em 15/01/2014 
//Solicitante: Cleonice Rodrigues / Ezaquiel Gama
//Motivo: Verificar saldo de SA e Materia-prima
/*
IF   _cSaldo < nQtd .AND. _cTipo=='PI'                                                                                        
     alert(" Componente tipo PI: "+cComp+" Sem saldo suficiente para atender esta OP , Necessidade : "+str(nQtd,10,2)+" Saldo: "+str(_cSaldo,10,2) )
Endif
*/


//Nova alteracao, porem ainda nao compilada - Reginaldo (15/01/2014) as 13:25
//regra antes da fusao das empresas teckit e brasiteck
//cCheck := IIF( SM0->M0_CODIGO == "04" , '!(_cTipo$"MO/SA/PI")' , '!(_cTipo=="MO")' )   
cCheck := '!(_cTipo$"MO")'     //SA



//IF _cSaldo < nQtd .AND. !(_cTipo$"MO/SA") 
IF _cSaldo < nQtd .AND. &cCheck .and. !(_cFantas == "S") // Validacao de estrutura, fantasmado, opcional e bloqueado.
    
    IF ( nI := aScan(aComp , {|x| x[1]== cComp} ) ) == 0
       aadd(aComp, {cComp , 0,0,0,0,0 } )                                         
       nI := len( aComp )
    ENDIF
    aComp[nI,2] += nQtd //necessidaade
    aComp[nI,3] := _ValEst // Saldo do estoque padrao
    aComp[nI,4] := _cSldEmp
    aComp[nI,5] := _cSaldo
    aComp[nI,6] := _ValEst2 // Saldo do processo
        
ENDIF
If (_cTipo=="MO") 
//retorna em caso tipo de material PI/SA/MO por claudio 25/11/14 para nao percorrer o nivel do PI
// acordado entre fabio e ezequiel para questionar o saldo de PI
 Return
Endif


      
If (_cTipo$"SA/PI/BN")  .and. _cFantas <> "S"
//retorna em caso tipo de material PI/SA/MO por claudio 25/11/14 para nao percorrer o nivel do PI
// acordado entre fabio e ezequiel para questionar o saldo de PI
 Return
Endif

nRec := SG1->( recno() )
SG1->(dbsetorder(1))
IF SG1->( dbSeek( xFilial("SG1")+cComp ) )        
	Do While SG1->G1_FILIAL==xFilial("SG1") .AND. SG1->G1_COD == cComp .and. !SG1->(eof())
	   cRevComp:=Posicione('SB1',1,xfilial("SB1")+cComp,"B1_REVATU")
	   IF  SG1->G1_REVFIM==cRevComp .OR. SG1->G1_REVFIM=="ZZZ" 
	    Simula_b(SG1->G1_COMP , SG1->G1_Quant * nQtd , (SG1->G1_GROPC + SG1->G1_OPC) ,@aComp )
	   Endif 
		SG1->(dbskip())
	EndDo
ENDIF
SG1->( dbGoTo(nRec) )

RETURN .T.



Static Function SldEnd(cCod,cLoc)
aEnder:=0
cAliasSBF:= GetNextAlias()
// saldos dos enderecos
BeginSql Alias cAliasSBF
  select ISNULL(BF_QUANT,0) BF_QUANT from %Table:SBF% SBF
  WHERE BF_FILIAL=%exp:XFILIAL("SBF")% AND BF_PRODUTO=%exp:cCod% 
  AND BF_LOCAL=%exp:cLoc%  AND BF_LOCALIZ="INJECAO" AND SBF.%NotDel%	
EndSql
dbSelectArea(cAliasSBF)  
dbgotop()
Do while !eof()
 aEnder:=(cAliasSBF)->BF_QUANT 
 DBSKIP()
Enddo
dbSelectArea(cAliasSBF) 
dbclosearea()
Return(aEnder)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GrvTXT  ºAutor  ³                    º Data ³ 28/10/2013    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava arquivo TEXTo com base em informacoes                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function GRVTXT(cTexto)

Local nHandle := 0
//Local cArq:= "C:\spool\erro"+.csv"
Local cArq:= "C:\spool\erro"+dTos(dDatabase)+strtran(time(),":","")+".csv"


If File( cArq )
	
	Erase(cArq)
	
	nHandle := FCreate( cArq )
	
	FClose( nHandle )
	
ELSE
	
	nHandle := FCreate( cArq )
	
	FClose( nHandle )
	
Endif

If File( cArq )
	
	nHandle := FOpen( cArq, 2 )
	FSeek( nHandle, 0, 2 )	// Posiciona no final do arquivo
	FWrite( nHandle, cTexto + Chr(13) + Chr(10), Len(cTexto)+2 )
	FClose( nHandle)
	
	
	If ! ApOleClient( 'MsExcel' )        							//Verifica se o Excel esta instalado
		MsgStop( 'MsExcel nao instalado' )
		Return
	EndIf
	
	oExcelApp := MsExcel():New()										// Cria um objeto para o uso do Excel
	oExcelApp:WorkBooks:Open( cArq )	// Atribui à propriedade WorkBooks do Excel
	oExcelApp:SetVisible(.T.)											// Abre o Excel com o arquivo criado exibido na Primeira planilha.
	oExcelApp:Destroy()
	
	
	
	
Endif





Return
