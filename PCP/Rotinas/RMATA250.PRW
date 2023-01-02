#include 'protheus.ch'
#include 'parmtype.ch'
#include "rwmake.ch"
#include "tbiconn.ch"

User Function RMATA250(aParam)
	Local aVetor := {}
	Local dDataLocal 
	Local cHora 
	Local cPath,cArqlog,x
	Private lWorkFlow  	 := IIF( aParam = Nil , .F. , .T. )
	Private ARQLOG := "\AUTOPRD\RMATA250.LOG"
	Private vProd := {} 	
	nOpc   := 3 //-Opção de execução da rotina, informado nos parametros quais as opções possiveis
	lMsErroAuto := .F.
	
	If lWorkFlow
		PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] USER 'siga' PASSWORD 't58220' TABLES "SBF","SD3","SB1","SB2","SF4" MODULO "EST"
	Endif
	cArqlog :="MATA250ERR.LOG"
	cPath :="\AUTOPRD\" 
	
	//AUTPRTOTAL:="N"
	nProd := 1 
	ProdZ04()
	for x:=1 to len(vProd)
	 dData:=stod(vProd[x,2])
	 cOp := PADR(vProd[x,1],13)  
	 aVetor := {;
	 {"D3_OP"		  ,vProd[x,1]  	    ,NIL},;
	 {"D3_TM"		  ,"200"			,NIL},;
	 {"D3_EMISSAO"	  ,stod(vProd[x,2]) ,NIL},;
	 {"D3_QUANT"      ,vProd[x,4]       ,NIL}}
	 
	 //MSExecAuto({|x, y| mata250(x, y)},aVetor, nOpc )
	 /*
	 If lMsErroAuto
	    vProd[x,5]:=.F.
	    cTxtErro := MostraErro()
		cFile := 'PROD_'+DTOS(dData)+"_"+cOp+ '_REJ' + ".LOG"
	    Memowrite( cPath+cFile, cTxtErro )
	 endif 
	 */
	 AtuZ04(vProd[X,1],vProd[x,2],vProd[x,3]+":00")
	next 
	IF lWorkflow
		RESET ENVIRONMENT
	Endif
Return   
 
 
Static Function ProdZ04()
Local cData := dtos(ddatabase-2)
Local cAliasZ04:= GetNextAlias()
Local cHora := substr(time(),1,2)
cHora:= strzero(val(cHora)-1,2)+":00:00"
 BeginSql Alias cAliasZ04 
  select Z04_OP,Z04_DATA,LEFT(Z04_HORA,2) HORA,SUM(Z04_QUANT) QTDE  from %Table:Z04% Z04
  WHERE Z04_FILIAL=%xFilial:Z04%  AND Z04_DATA>=%exp:cData% AND Z04_HORA<%exp:cHora% AND Z04_STATUS='F'  AND Z04.%NotDel%
  GROUP BY Z04_OP,Z04_DATA,LEFT(Z04_HORA,2)
  ORDER BY Z04_OP 
 EndSql 
 dbSelectArea(cAliasZ04)  
 dbgotop()
 Do while !(cAliasZ04)->(eof())
   aadd(vProd,{(cAliasZ04)->Z04_OP,(cAliasZ04)->Z04_DATA,(cAliasZ04)->HORA,(cAliasZ04)->QTDE,.F.}) 
   (cAliasZ04)->(dbskip())
 Enddo
 dbSelectArea(cAliasZ04) 
 dbclosearea() 
Return


Static Function AtuZ04(opprd,dataprd,horaprd)
Local nreg
Local cAliasZ04 := GetNextAlias()
 BeginSql Alias cAliasZ04 
  select R_E_C_N_O_  REGISTRO from %Table:Z04% Z04
  WHERE Z04_FILIAL=%xFilial:Z04%  AND Z04_OP=%exp:opprd% AND Z04_DATA=%exp:dataprd% AND LEFT(Z04_HORA,2)=%exp:LEFT(horaprd,2)% 
  AND Z04_STATUS='F' AND Z04.%NotDel%
 EndSql 
 dbSelectArea(cAliasZ04)  
 dbgotop()
 Do while !(cAliasZ04)->(eof())
   nreg:=(cAliasZ04)->REGISTRO
   dbSelectArea("Z04")
   Z04->(DBGOTO(nreg))
   RecLock("Z04",.F.)
   Z04->Z04_STATUS :=.T.
   MsUnlock() 
   dbSelectArea(cAliasZ04)
   (cAliasZ04)->(dbskip())
 Enddo
 dbSelectArea(cAliasZ04) 
 dbclosearea()
 Return


