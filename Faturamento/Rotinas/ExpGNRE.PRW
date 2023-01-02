#include "rwmake.ch"
#include "topconn.ch"
#define TAB CHR(09)
#define CRLF CHR(13)+CHR(10)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ EXPGNRE  ³ Autor ³ Luiz Fernando C Noguiera |Data 21.09.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geracao de arquivo com notas fiscais de saida de venda para³±±
±±³          ³ geração da guia de pagamento de ST.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Brasitech                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Data      ³ Programador   ³ Manutencao efetuada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             												 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³    						         									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function EXPGNRE()

Local _cEstDe      := ""
Local _cEstAte     := ""
Local _cCliDe       := ""
Local _cCliAte      := ""
Local _cljCliDe      := ""
Local _cljCliAte     := ""
Local _cCodRecei := "" 
Local _cDiasVenc := ""
Local _cDocDe     := ""
Local _cDocAte    := ""
Local _cSerieDe   := ""
Local _cSerieAte  := ""
Local _dDataDe    := Ctod("  /  /  ")
Local _dDataAte   := Ctod("  /  /  ")
Local _cPath      := ""
Private _aDocs    := {}
Private _cPerg    := "EXPGNREX"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inclui as perguntas caso nao existam                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RFATI01_A()
Pergunte(_cPerg,.T.)
_cDocDe     := MV_PAR01
_cDocAte    := MV_PAR02
_cSerieDe   := MV_PAR03
_cSerieAte  := MV_PAR04
_dDataDe    := MV_PAR05
_dDataAte   := MV_PAR06
_cPath        := MV_PAR07
_cEstDe      := MV_PAR08
_cEstAte     := MV_PAR09
_cCliDe       := MV_PAR10
_cCliAte      := MV_PAR11
_cljCliDe      := MV_PAR12
_cljCliAte     := MV_PAR13             
_cCodRecei := MV_PAR14
_cDiasVenc := MV_PAR15

If MsgBox("Confirma exportacao de dados ?","Atencao","YESNO")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera arquivos de trabalho                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RFATI01_B(_cDocDe,_cDocAte,_cSerieDe,_cSerieAte,_dDataDe,_dDataAte,_cEstDe,_cEstAte,_cCliDe,_cCliAte,_cljCliDe,_cljCliAte,_cCodRecei)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera array na estrutura do arquivo texto              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Processa({|| RFATI01_C(_cDiasVenc)}, "Processando..." )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera arquivo texto a partir do array dos documentos   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Processa({|| RFATI01_D(_cPath)}, "Processando..." )
	Aviso("Aviso","Processamento concluido",{"Ok"})
Else
	Aviso("Aviso","Processamento Cancelado",{"Ok"})
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Apaga arquvos temporarios utilizados na rotina        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Select("TRB1") > 0
	dbselectArea("TRB1")
	dbCloseArea()
EndIf

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ RFATI01_B   ³ Autor ³ Wilson Cruz - Totvs   ³ Data ³ 21/02/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera arquivos base para exportacao de dados                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Brasitech 						        				     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static function RFATI01_B(_cDocDe,_cDocAte,_cSerieDe,_cSerieAte,_dDataDe,_dDataAte,_cEstDe,_cEstAte,_cCliDe,_cCliAte,_cljCliDe,_cljCliAte,_cCodRecei)
Local _cQuery
Local _aStru    :={}

_cArqQry:= GetNextAlias()
_cQuery := 	"SELECT rtrim(ltrim(SA1.A1_CGC)) AS RB1_CGC,rtrim(ltrim(SA1.A1_NOME)) AS RB1_NOME,rtrim(ltrim(SF2.F2_EST)) AS RB1_EST, "
_cQuery += 	"rtrim(ltrim(SF2.F2_DOC)) AS RB1_DOC,SF2.F2_ICMSRET AS RB1_ICMSST,0 AS RB1_ATUMON, 0 AS RB1_MULTA,0 AS RB1_JUROS, SF2.F2_ICMSRET AS RB1_TOTAL,"
_cQuery += 	"rtrim(ltrim(SF2.F2_EMISSAO)) as RB1_VENC, rtrim(ltrim(TBLSM4.M4_FORMULA)) AS RB1_CONVEN,'"+alltrim(_cCodRecei)+"' AS RB1_RECEIT "
_cQuery += 	"FROM "+RetSqlName("SF2")+" SF2 LEFT OUTER JOIN  (SELECT DISTINCT M4_FORMULA, F2.F2_DOC, F2.F2_SERIE FROM "+RetSqlName("SM4")+" AS SM4 LEFT OUTER JOIN "+RetSqlName("SC5") + " AS SC5 " 
_cQuery += 	"ON M4_CODIGO = C5_MENPAD  AND M4_FILIAL = C5_FILIAL LEFT OUTER JOIN "+RetSqlName("SD2")+ " as SD2 ON C5_FILIAL = D2_FILIAL AND C5_NUM = D2_PEDIDO LEFT OUTER JOIN "+RetSqlName("SF2")+" F2 " 
_cQuery += 	"ON F2.F2_FILIAL = C5_FILIAL AND F2.F2_DOC = D2_DOC AND F2.F2_SERIE = D2_SERIE "  
_cQuery += 	"where SC5.D_E_L_E_T_ = '' AND SD2.D_E_L_E_T_ = '' AND F2.D_E_L_E_T_ = '' AND SM4.D_E_L_E_T_ = '' ) AS TBLSM4 on SF2.F2_DOC = TBLSM4.F2_DOC AND SF2.F2_SERIE = TBLSM4.F2_SERIE "
_cQuery +=	"left outer join "+RetSqlName("SA1")+ " as SA1 ON "

If xFilial("SA1") == "  " 
	_cQuery +=	"SF2.F2_CLIENTE = SA1.A1_COD AND SF2.F2_LOJA = SA1.A1_LOJA "
else
	_cQuery +=	"SF2.F2_FILIAL = SA1.A1_FILIAL AND SF2.F2_CLIENTE = SA1.A1_COD AND SF2.F2_LOJA = SA1.A1_LOJA "
endif

_cQuery +=	" WHERE SF2.F2_FILIAL = '"+xFilial("SF2")+"'"
_cQuery +=	" AND SF2.F2_ICMSRET > 0"
_cQuery +=	" AND SA1.A1_FILIAL = '"+xFilial("SA1")+"'"
_cQuery += 	" AND SF2.D_E_L_E_T_ = '' "
_cQuery +=	" AND SA1.D_E_L_E_T_ = '' "
_cQuery += 	" AND SF2.F2_DOC BETWEEN '"+_cDocDe+"' AND '"+_cDocAte+"'"
_cQuery += 	" AND SF2.F2_SERIE BETWEEN '"+_cSerieDe+"' AND '"+_cSerieAte+"'"
_cQuery += 	" AND SF2.F2_EMISSAO BETWEEN '"+Dtos(_dDataDe)+"' AND '"+Dtos(_dDataAte)+"'"
_cQuery += 	" AND SF2.F2_EST BETWEEN '"+_cEstDe+"' AND '"+_cEstAte+ "'"
_cQuery += 	" AND SF2.F2_CLIENTE BETWEEN '"+_cCliDe+"' AND '"+_cCliAte+ "'"
_cQuery += 	" AND SF2.F2_LOJA BETWEEN '"+_cljCliDe+"' AND '"+_cljCliAte+ "'"

Memowrite("ExpGnre.Sql" , _cQuery )
MsgRun("Selecionando Registros...",,{||dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cArqQry,.F.,.T.)})
_aStru    :={}
AADD(_aStru, { "RB1_CGC"		,"C",014, 0})
AADD(_aStru, { "RB1_NOME"		,"C",040, 0})
AADD(_aStru, { "RB1_EST"		,"C",002, 0})
AADD(_aStru, { "RB1_DOC"		,"C",010, 0})
AADD(_aStru, { "RB1_ICMSST"		,"N",014, 2})
AADD(_aStru, { "RB1_ATUMON"		,"N",014, 2})
AADD(_aStru, { "RB1_JUROS"		,"N",014, 2})
AADD(_aStru, { "RB1_MULTA"		,"N",014, 2})
AADD(_aStru, { "RB1_TOTAL"		,"N",014, 2})
AADD(_aStru, { "RB1_VENC"		,"C",008, 0})
AADD(_aStru, { "RB1_CONVEN"		,"C",128, 0})
AADD(_aStru, { "RB1_RECEIT"		,"C",006, 0})

_cArqTMP:=CriaTrab(Nil,.f.)
dbCREATE(_cArqTMP,_aStru)
dbUseArea(.T.,,_cArqTMP,"TRB1",.F.,.F.)
INDEX ON RB1_DOC TO &_cArqTMP
Append From &_cArqQry
If Select(_cArqQry) > 0
	dbselectArea(_cArqQry)
	dbCloseArea()
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ RFATI01_C   ³ Autor ³ Wilson Cruz - Totvs   ³ Data ³ 21/02/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta array com os documentos de saida                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Brasitech 						        				     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static function RFATI01_C(_cDiasVenc)

Local cMsgComp := ""
Local aArea
Local dtReferen := Dtos(Date())
Local cReferen  := ""
Local cConven  := ""
Local cVenc :=""
Local aDadosEmp    := {SM0->M0_NOMECOM              							,; //[1]Nome da Empresa  
SM0->M0_ENDCOB                                                      			,; //[2]Endereço 
SM0->M0_CIDCOB																	,; //[3]Cidade
SM0->M0_ESTCOB																	,; //[4]Estado
Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             				,; //[5]CEP
Subs(SM0->M0_TEL,3,8)                                                  			,; //[6]Telefones
SM0->M0_CGC                                                    					,; //[7]CGC
SM0->M0_INSC                  }  												   //[8]I.E     

 
Set Century On                // define máscara para tipos de dados Datas de anos com 4 digitos: DD/MM/AAAA
DbSelectArea("TRB1")
aArea := GetArea() 
ProcRegua(RecCount())
DbGoTop()
While !eof()

cVenc := DTOC(STOD(TRB1->RB1_VENC)+val(_cDiasVenc))
cMsgComp := "ICMS/ST POR OPERAÇÃO REFERENTE A NF "+alltrim(TRB1->RB1_DOC)+" - "+alltrim(TRB1->RB1_NOME)+" - CNPJ: "+alltrim(TRB1->RB1_CGC)

if ( alltrim(POSICIONE("SZE",1,xFilial("SZE")+TRB1->RB1_EST,"ZE_REFEREN")) == "" )
   	cReferen := ""
else
	cReferen := alltrim(POSICIONE("SZE",1,xFilial("SZE")+TRB1->RB1_EST,"ZE_REFEREN") + substr(dtReferen,5,2)+substr(dtReferen,1,4))
endif

if ( alltrim( Posicione("SM4",1,xFilial("SM4")+POSICIONE("SZE",1,xFilial("SZE")+TRB1->RB1_EST,"ZE_MENPAD"),"M4_FORMULA"))  == "" )		
	cConven := ""
else
	cConven := &( alltrim( Posicione ("SM4",1,xFilial("SM4")+POSICIONE ("SZE",1,xFilial("SZE")+TRB1->RB1_EST,"ZE_MENPAD"),"M4_FORMULA") ) )
endif	
   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava os cabecalhos dos documentos de saida no array  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IncProc("Processando ... ")


		Aadd(_aDocs,{alltrim(TRB1->RB1_EST)+TAB+alltrim(TRB1->RB1_RECEITA)+TAB+alltrim(aDadosEmp[7])+TAB+str(val(alltrim(TRB1->RB1_DOC)))+TAB+;
		cReferen+TAB+alltrim( Transform(TRB1->RB1_ICMSST, "@E 999999999.99"))+TAB+alltrim(Transform(TRB1->RB1_ATUMON, "@E 999999999.99"))+TAB+;
		alltrim(Transform(TRB1->RB1_JUROS, "@E 999999999.99"))+TAB+alltrim(Transform(TRB1->RB1_MULTA, "@E 999999999.99"))+TAB+alltrim(Transform(TRB1->RB1_TOTAL, "@E 999999999.99"))+TAB+;
		cVenc+TAB+cConven+TAB+alltrim(aDadosEmp[1])+TAB+TAB+;                   
		alltrim(aDadosEmp[2])+TAB+alltrim(aDadosEmp[3])+TAB+alltrim(aDadosEmp[4])+TAB+alltrim(aDadosEmp[5])+TAB+alltrim(aDadosEmp[6])+TAB+;
		cMsgComp}) 

//RestArea(aArea)		

	dbSkip()
End
Return()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ RFATI01_D   ³ Autor ³ Wilson Cruz - Totvs   ³ Data ³ 21/02/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera arquivo texto com documentos selecionados                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Brasitech 						        				     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RFATI01_D(_cPath)

Local _nTime
Local _nHdl, _nI
_nTime := Time()
_nTime := Strtran(time(),":","")
_nTime := SubStr(_nTime,1,4)
_nHdl  := MSFCREATE(Alltrim(_cPath)+Dtos(Date())+_nTime+".TXT",0)
ProcRegua(Len(_aDocs))
For _nI := 1 to len(_aDocs)
	IncProc("Processando ... ")
	FWrite(_nHdl,_aDocs[_nI,1] + CRLF)
Next _nI
FClose(_nHdl)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ RFATI01_A   ³ Autor ³ Wilson Cruz - Totvs   ³ Data ³ 21/02/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclui as perguntas caso nao existam                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Brasitech 						        				     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RFATI01_A

Local _aRegs := {}
Local i,j
dbSelectArea("SX1")
dbSetOrder(1)
_cPerg := PADR(_cPerg,10)

Aadd(_aRegs,	{_cPerg,"01","Documento de       ?","                   ?","                   ?","mv_ch1","C",09,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
Aadd(_aRegs,	{_cPerg,"02","Documento ate      ?","                   ?","                   ?","mv_ch2","C",09,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
Aadd(_aRegs,	{_cPerg,"03","Serie de           ?","                   ?","                   ?","mv_ch3","C",03,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
Aadd(_aRegs,	{_cPerg,"04","Serie ate          ?","                   ?","                   ?","mv_ch4","C",03,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
Aadd(_aRegs,	{_cPerg,"05","Emissao de         ?","                   ?","                   ?","mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
Aadd(_aRegs,	{_cPerg,"06","Emissao ate        ?","                   ?","                   ?","mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
Aadd(_aRegs,	{_cPerg,"07","Diretorio          ?","                   ?","                   ?","mv_ch7","C",30,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})      
Aadd(_aRegs,	{_cPerg,"08","Estado de       ?","                   ?","                   ?","mv_ch8","C",02,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
Aadd(_aRegs,	{_cPerg,"09","Estado ate       ?","                   ?","                   ?","mv_ch9","C",02,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
Aadd(_aRegs,	{_cPerg,"10","Cliente de       ?","                   ?","                   ?","mv_chA","C",08,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
Aadd(_aRegs,	{_cPerg,"11","Cliente ate       ?","                   ?","                   ?","mv_chB","C",08,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
Aadd(_aRegs,	{_cPerg,"12","Loja Cliente de       ?","                   ?","                   ?","mv_chC","C",02,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
Aadd(_aRegs,	{_cPerg,"13","Loja Cliente ate       ?","                   ?","                   ?","mv_chD","C",02,0,0,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
Aadd(_aRegs,	{_cPerg,"14","Codigo da Receita ?","                   ?","                   ?","mv_chE","C",06,0,0,"G","","mv_par14","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
Aadd(_aRegs,	{_cPerg,"15","Dias p/ Venc apos Emissao ?","                   ?","                   ?","mv_chF","C",02,0,0,"G","","mv_par15","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})

For i:=1 to Len(_aRegs)
	If !dbSeek(_cPerg+_aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(_aRegs[i])
				FieldPut(j,_aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

Return
