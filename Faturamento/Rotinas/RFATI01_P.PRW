#include "rwmake.ch"
#include "topconn.ch"
#define CRLF CHR(13)+CHR(10)
/*/
??????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????Ŀ??
???Funcao    ? RFATI01P ? Autor ? Wilson A. da Cruz      ? Data ? 21.02.09 ???
??????????????????????????????????????????????????????????????????????????Ĵ??
???Descri??o ? Geracao de arquivo com notas fiscais de saida de venda de   ???
???          ? cliente para armazem                                        ???
??????????????????????????????????????????????????????????????????????????Ĵ??
???Uso       ? Brasitech                                                   ???
??????????????????????????????????????????????????????????????????????????Ĵ??
???Data      ? Programador   ? Manutencao efetuada                         ???
??????????????????????????????????????????????????????????????????????????Ĵ??
???          ?               ? Alteracao do tipo do documento de saida,    ???
???12.05.09  ? Wilson Cruz   ? tipo SGC para notas com valor de mercadoria ???
???          ?               ? iguais ou superiores ao parametro ES_VLREDI ???
???          ?               ? e M3S para valores inferiores.              ???
??????????????????????????????????????????????????????????????????????????Ĵ??
???          ?               ? Alteracao do tipo do documento de saida,    ???
???18.06.09  ? Wilson Cruz   ? tipo M3X para clientes classificados como   ???
???          ?               ? prioritarios, campo A1_X_PRIOR preenchido.  ???
??????????????????????????????????????????????????????????????????????????Ĵ??
??? Layout do arquivo:                                                     ???
???	Campo               Ini  Fim  Tam  Dec  Tipo  Formato                  ???
???	Tipo Registro = 1  (Cabecalho Documento Saida)                         ???
???	Campo               Ini  Fim  Tam  Dec  Tipo  Formato   Observacao     ???
???	Id Cabecalho        001  001  002       C               1-Fixo         ???
???	Numero da Nota      002  011  010       C                              ???
??? Nome Cliente        027  061  035       C                              ???
??? Endereco            062  091  030       C                              ???
??? Complemento         092  111  020       C                              ???
??? Bairro              112  126  015       C                              ???
??? Cidade              127  146  020       C                              ???
??? Estado              147  148  002       C                              ???
???	CEP                 149  156  008       C                              ???
???	CNPJ/CPF            157  170  014       C                              ???
???	Data Entrega        171  178  008       D     DDMMAAAA                 ???
???	Data Emissao NF     179  186  008       D     DDMMAAAA                 ???
???	Codigo Operacao     187  189  003       C               M3S ou SGC     ???
???	Observacao          190  389  200       C                              ???
???	Transportadora      390  419  030       C                              ???
???	                                                                       ???
??? Tipo Registro = 9 (Item Documento Saida)                               ???
??? Campo               Ini  Fim  Tam  Dec  Tipo  Formato   Observacao     ???
??? Id                  001  001  001       C               9-Fixo         ???
??? Numero NF           002  011  010       C                              ???
??? Item Pedido         012  014  003       C                              ???
??? Produto             015  039  025       C                              ???
??? Descricao           040  049  020       C                              ???
??? Unidade de Medida   059  061  002       C                              ???
??? Quantidade          062  072  011  000  C                              ???
??? Valor Unitario      073  092  016  004  C                              ???
??? Projeto             092  107  015       C                              ???
??? Lote                108  122  016       C                              ???
???                                                                        ???
??? Nome do arquivo : DSDDMMAA_HHMM.TXT                                    ???
???             Onde: DS     -> Fixo                                       ???
???                   DDMMAA -> DD = dia , MM = mes  e AA = ano            ???
???                   HHMM   -> HH = hora, MM = minuto                     ???
???????????????????????????????????????????????????????????????????????????ٱ?
??????????????????????????????????????????????????????????????????????????????
??????????????????????????????????????????????????????????????????????????????
/*/
User Function RFATI01P()

Local _cDocDe     := ""
Local _cDocAte    := ""
Local _cSerieDe   := ""
Local _cSerieAte  := ""
Local _dDataDe    := Ctod("  /  /  ")
Local _dDataAte   := Ctod("  /  /  ")
Local _cPath      := ""
Private _aDocs    := {}
Private _cPerg    := "RFAT01XXXX"
//???????????????????????????????????????????????????????Ŀ
//? Inclui as perguntas caso nao existam                  ?
//?????????????????????????????????????????????????????????
RFATI01P_A()
Pergunte(_cPerg,.T.)
_cDocDe     := MV_PAR01
_cDocAte    := MV_PAR02
_cSerieDe   := MV_PAR03
_cSerieAte  := MV_PAR04
_dDataDe    := MV_PAR05
_dDataAte   := MV_PAR06
_cPath      := MV_PAR07

If MsgBox("Confirma exportacao de dados ?","Atencao","YESNO")
	//???????????????????????????????????????????????????????Ŀ
	//? Gera arquivos de trabalho                             ?
	//?????????????????????????????????????????????????????????
	RFATI01P_B(_cDocDe,_cDocAte,_cSerieDe,_cSerieAte,_dDataDe,_dDataAte)
	//???????????????????????????????????????????????????????Ŀ
	//? Verifica se notas selecionadas devem ser exportadas   ?
	//? e carrega as datas de entrega                         ?
	//?????????????????????????????????????????????????????????
	
	/*Processa({|| RFATI01P_E()}, "Processando..." )*/
	
	//???????????????????????????????????????????????????????Ŀ
	//? Gera array na estrutura do arquivo texto              ?
	//?????????????????????????????????????????????????????????
	Processa({|| RFATI01P_C()}, "Processando..." )
	//???????????????????????????????????????????????????????Ŀ
	//? Gera arquivo texto a partir do array dos documentos   ?
	//?????????????????????????????????????????????????????????
	Processa({|| RFATI01P_D(_cPath)}, "Processando..." )
	//???????????????????????????????????????????????????????Ŀ
	//? Marca as notas que foram exportadas                   ?
	//?????????????????????????????????????????????????????????
	
	/*Processa({|| RFATI01P_F()}, "Processando..." )*/
	
	Aviso("Aviso","Processamento concluido",{"Ok"})
Else
	Aviso("Aviso","Processamento Cancelado",{"Ok"})
Endif
//???????????????????????????????????????????????????????Ŀ
//? Apaga arquvos temporarios utilizados na rotina        ?
//?????????????????????????????????????????????????????????
If Select("TRB1") > 0
	dbselectArea("TRB1")
	dbCloseArea()
EndIf
If Select("TRB2") > 0
	dbselectArea("TRB2")
	dbCloseArea()
EndIf

Return
/*/
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????Ŀ??
???Fun??o	 ? RFATI01P_B   ? Autor ? Wilson Cruz - Totvs   ? Data ? 21/02/09 ???
????????????????????????????????????????????????????????????????????????????Ĵ??
???Descri??o ? Gera arquivos base para exportacao de dados                   ???
????????????????????????????????????????????????????????????????????????????Ĵ??
???Uso       ? Brasitech 						        				     ???
?????????????????????????????????????????????????????????????????????????????ٱ?
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????*/
Static function RFATI01P_B(_cDocDe,_cDocAte,_cSerieDe,_cSerieAte,_dDataDe,_dDataAte)
Local _cQuery
Local _aStru    :={}
Local _nVlrNf   := Getmv("ES_VLREDI")
//Local _cCondEdi := GETMV("MV_CONDEDI")


_cArqQry:= GetNextAlias()
_cQuery := " SELECT F2_DOC AS RB1_DOC,A1_NOME AS RB1_NOME,A1_MUN AS RB1_CIDADE,A1_EST AS RB1_EST,A1_CGC AS RB1_CNPJ,"
_cQuery += " TBL.D2_COD AS RB1_COD,TBL.B1_XDESCNF AS RB1_DESCNF,TBL.D2_CF AS RB1_CFOP,F2_SERIE AS RB1_SERIE,F2_CLIENTE AS RB1_CLIENT,"
_cQuery += " TBL.D2_QUANT AS RB1_QUANT, TBL.D2_PRCVEN AS RB1_PRCVEN,TBL.D2_TOTAL as RB1_TOTAL,TBL.D2_VALIPI AS RB1_IPI,"
_cQuery += " TBL.D2_VALICM AS RB1_ICM,TBL.D2_VALBRUT AS RB1_BRUTO,F2_TRANSP AS RB1_TRANSP,A4_NOME AS RB1_NMTRAN"
_cQuery += " FROM "+RetSqlName("SF2")+" F2 INNER JOIN "+RetSqlName("SA1")+" A1 ON A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA "
_cQuery += " INNER JOIN "+RetSqlName("SA4")+" A4 ON A4_COD = F2_TRANSP "
_cQuery += " INNER JOIN (SELECT DISTINCT D2_DOC, D2_COD, B1_DESC, B1_XDESCNF, D2_CF, D2_QUANT, D2_PRCVEN , D2_TOTAL , D2_VALIPI, D2_VALICM," 
_cQuery += " D2_VALBRUT, D2_FILIAL,D2_SERIE FROM "+RetSqlName("SD2")+ " D2 " 
_cQuery += " INNER JOIN "+RetSqlName("SB1") + " B1 ON D2_COD = B1_COD  " 
_cQuery += " where D2.D_E_L_E_T_ = '' AND B1.D_E_L_E_T_ = '' AND D2.D2_LOCAL IN ('06','01','13') ) AS TBL "
_cQuery += " ON F2_DOC = TBL.D2_DOC AND F2_FILIAL = TBL.D2_FILIAL  AND F2_SERIE = TBL.D2_SERIE  "
_cQuery += " WHERE F2_FILIAL = '"+xFilial("SF2")+"'"
_cQuery += " AND F2_SERIE BETWEEN '"+_cSerieDe+"' AND '"+_cSerieAte+"'"
_cQuery += " AND F2_DOC BETWEEN '"+_cDocDe+"' AND '"+_cDocAte+"'"
_cQuery += " AND F2_EMISSAO BETWEEN '"+Dtos(_dDataDe)+"' AND '"+Dtos(_dDataAte)+"'"
_cQuery += " AND A1_FILIAL = '"+xFilial("SA1")+"'"
_cQuery += " AND A4_FILIAL = '"+xFilial("SA4")+"'"
_cQuery += " AND F2.D_E_L_E_T_ = ''"
_cQuery += " AND A1.D_E_L_E_T_ = ''"
_cQuery += " AND A4.D_E_L_E_T_ = ''"
_cQuery += " ORDER BY F2_DOC"
//_cQuery += " ORDER BY A1_NOME"
_cQuery := ChangeQuery(_cQuery) 
Memowrite("keepers_capa.Sql" , _cQuery )
MsgRun("Selecionando Registros...",,{||dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cArqQry,.F.,.T.)})
_aStru    :={}
AADD(_aStru, { "RB1_CLIENT"		,"C",015, 0})
AADD(_aStru, { "RB1_CNPJ"		,"C",014, 0})
AADD(_aStru, { "RB1_NOME"		,"C",035, 0})
AADD(_aStru, { "RB1_EST"		,"C",002, 0})
AADD(_aStru, { "RB1_CIDADE"		,"C",020, 0})
AADD(_aStru, { "RB1_DOC"		,"C",010, 0})
AADD(_aStru, { "RB1_SERIE"		,"C",003, 0})
AADD(_aStru, { "RB1_COD"		,"C",25, 0})
AADD(_aStru, { "RB1_DESCNF"		,"C",60, 0})
AADD(_aStru, { "RB1_CFOP"		,"C",05, 0})
AADD(_aStru, { "RB1_QUANT"		,"N",11,0})
AADD(_aStru, { "RB1_PRCVEN"		,"N",14, 4})
AADD(_aStru, { "RB1_TOTAL"		,"N",14, 4})
AADD(_aStru, { "RB1_IPI"		,"N",14, 2})
AADD(_aStru, { "RB1_ICM"		,"N",14, 2})
AADD(_aStru, { "RB1_BRUTO"		,"N",14, 2})
AADD(_aStru, { "RB1_NMTRAN"		,"C",40, 0})
AADD(_aStru, { "RB1_TRANSP"		,"C",006, 0})

_cArqTMP:=CriaTrab(Nil,.f.)
dbCREATE(_cArqTMP,_aStru)
dbUseArea(.T.,,_cArqTMP,"TRB1",.F.,.F.)
//INDEX ON RB1_DOC TO &_cArqTMP
INDEX ON RB1_NOME TO &_cArqTMP
Append From &_cArqQry
If Select(_cArqQry) > 0
	dbselectArea(_cArqQry)
	dbCloseArea()
EndIf
//???????????????????????????????????????????????????????Ŀ
//? Gera arquivo com itens dos documentos de saida        ?
//?????????????????????????????????????????????????????????
_cArqQry:= GetNextAlias()
_cQuery := " SELECT DISTINCT D2_DOC AS RB2_DOC, D2_ITEM AS RB2_ITEM, D2_COD AS RB2_COD,"
_cQuery += " B1_DESC AS RB2_DESC, D2_CF AS RB2_CFOP, B1_UM AS RB2_UM, D2_QUANT AS RB2_QUANT,"
_cQuery += " D2_PRCVEN AS RB2_PRCVEN, D2_TOTAL AS RB2_TOTAL, D2_VALIPI AS RB2_IPI, D2_VALICM AS RB2_ICM,"
_cQuery += " D2_VALBRUT AS RB2_BRUTO, C6_ENTREG AS RB2_ENTREG"
_cQuery += " FROM "+RetSQlName("SD2")+" D2"
_cQuery += " INNER JOIN "+RetSqlName("SB1")+" B1 ON B1_COD = D2_COD"
_cQuery += " INNER JOIN "+RetSqlName("SF4")+" F4 ON F4_CODIGO = D2_TES"
_cQuery += " INNER JOIN "+RetSqlName("SC6")+" C6 ON C6_NUM = D2_PEDIDO AND C6_ITEM = D2_ITEMPV"
_cQuery += " WHERE D2_FILIAL = '"+xFilial("SD2")+"'"
_cQuery += " AND D2_SERIE BETWEEN '"+_cSerieDe+"' AND '"+_cSerieAte+"'"
_cQuery += " AND D2_LOCAL ='06'"
_cQuery += " AND D2_DOC BETWEEN '"+_cDocDe+"' AND '"+_cDocAte+"'"
_cQuery += " AND D2_EMISSAO BETWEEN '"+Dtos(_dDataDe)+"' AND '"+Dtos(_dDataAte)+"'"
_cQuery += " AND F4_FILIAL = '"+xFilial("SF4")+"'"
_cQuery += " AND F4_ESTOQUE = 'S'"
_cQuery += " AND C6_FILIAL = '"+xFilial("SC6")+"'"
_cQuery += " AND B1_FILIAL = '"+xFilial("SB1")+"'"
_cQuery += " AND F4.D_E_L_E_T_ = ''"
_cQuery += " AND B1.D_E_L_E_T_ = ''"
_cQuery += " AND D2.D_E_L_E_T_ = ''"
_cQuery += " AND C6.D_E_L_E_T_ = ''"
_cQuery += " ORDER BY RB2_DOC"
_cQuery := ChangeQuery(_cQuery)
MsgRun("Selecionando Registros...",,{||dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),_cArqQry,.F.,.T.)})
_aStru    :={}
AADD(_aStru, { "RB2_DOC"		,"C",10, 0})
AADD(_aStru, { "RB2_ITEM"		,"C",03, 0})
AADD(_aStru, { "RB2_COD"		,"C",25, 0})
AADD(_aStru, { "RB2_DESC"		,"C",20, 0})
AADD(_aStru, { "RB2_CFOP"		,"C",05, 0})
AADD(_aStru, { "RB2_UM"			,"C",02, 0})
AADD(_aStru, { "RB2_QUANT"		,"N",11,0})
AADD(_aStru, { "RB2_PRCVEN"		,"N",14, 4})
AADD(_aStru, { "RB2_TOTAL"		,"N",14, 4})
AADD(_aStru, { "RB2_IPI"		,"N",14, 2})
AADD(_aStru, { "RB2_ICM"		,"N",14, 2})
AADD(_aStru, { "RB2_BRUTO"	,"N",14, 2})
AADD(_aStru, { "RB2_PROJ"		,"C",15, 2})
AADD(_aStru, { "RB2_LOTE"		,"C",16, 0})
AADD(_aStru, { "RB2_ENTREG"		,"C",08, 0})
_cArqTMP2:=CriaTrab(Nil,.f.)
dbCREATE(_cArqTMP2,_aStru)
dbUseArea(.T.,,_cArqTMP2,"TRB2",.F.,.F.)
INDEX ON RB2_DOC TO &_cArqTMP2
Append From &_cArqQry
If Select(_cArqQry) > 0
	dbselectArea(_cArqQry)
	dbCloseArea()
EndIf
Return
/*/
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????Ŀ??
???Funcao	 ? RFATI01p_E   ? Autor ? Wilson Cruz - Totvs   ? Data ? 21/02/09 ???
????????????????????????????????????????????????????????????????????????????Ĵ??
???Descricao ? Verifica se todos as notas serao exportadas e carrega data    ???
???          ? de entrega                                                    ???
????????????????????????????????????????????????????????????????????????????Ĵ??
???Uso       ? Brasitech 						        				     ???
?????????????????????????????????????????????????????????????????????????????ٱ?
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????*/
Static Function RFATI01P_E()
Local _cTransp := ""

dbSelectArea("TRB1")  
dbSetOrder(1)
dbGotop()
While !Eof()
	DbSelectArea("TRB2")
	dbSetOrder(1)
	If !dbSeek(TRB1->RB1_DOC)
		RecLock("TRB1",.F.)
		TRB1->RB1_FLGIMP := "N"
		MsUnlock()
	Else
		dbSelectArea("SA4")
		_cTransp :=GetAdvFVal("SA4","A4_XCODEDI",xFilial("SA4")+TRB1->RB1_TRANSP,1)
		_cTransp +=GetAdvFVal("SA4","A4_NOME",xFilial("SA4")+TRB1->RB1_TRANSP,1)
		RecLock("TRB1",.F.)
		MsUnlock()
	Endif
	dbSelectArea("TRB1")
	dbSkip()
End

Return
/*/
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????Ŀ??
???Fun??o	 ? RFATI01P_C  ? Autor ? Wilson Cruz - Totvs   ? Data ? 21/02/09 ???
????????????????????????????????????????????????????????????????????????????Ĵ??
???Descri??o ? Monta array com os documentos de saida                        ???
????????????????????????????????????????????????????????????????????????????Ĵ??
???Uso       ? Brasitech 						        				     ???
?????????????????????????????????????????????????????????????????????????????ٱ?
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????*/
Static function RFATI01P_C() 

	/*
	Aadd(_aDocs,{"Cod Cliente;CNPJ;Nome Cliente;Estado;Cidade;Nota Fiscal;Serie NF;Cod Produto;Nome Produto;Cfop;Quantidade;Valor Unit;"+;
	"Valor Total Prod;Valor IPI;Valor ICMS;Valor Total;Transportadora"})
	*/

DbSelectArea("TRB1")
ProcRegua(RecCount())
DbGoTop()
While !eof()
	//???????????????????????????????????????????????????????Ŀ
	//? Grava os cabecalhos dos documentos de saida no array  ?
	//?????????????????????????????????????????????????????????
	IncProc("Processando ... ")

		Aadd(_aDocs,{AllTrim(TRB1->RB1_CLIENT)+";"+AllTrim(TRB1->RB1_CNPJ)+";"+AllTrim(TRB1->RB1_NOME)+";"+AllTrim(TRB1->RB1_EST)+";"+; 
		AllTrim(TRB1->RB1_CIDADE)+";"+AllTrim(TRB1->RB1_DOC)+";"+AllTrim(TRB1->RB1_SERIE)+";"+AllTrim(TRB1->RB1_COD)+";"+;
		AllTrim(TRB1->RB1_DESCNF)+";"+AllTrim(TRB1->RB1_CFOP)+";"+AllTrim(STR(Round((TRB1->RB1_QUANT),2)))+";"+;
		AllTrim(Transform(Round((TRB1->RB1_PRCVEN),2),"@E 999,999,999,999.99" ))+";"+;
		AllTrim(Transform(Round((TRB1->RB1_TOTAL),2),"@E 999,999,999,999.99" ))+";"+;
		AllTrim(Transform(Round((TRB1->RB1_IPI),2),"@E 999,999,999,999.99" ))+";"+;
		AllTrim(Transform(Round((TRB1->RB1_ICM),2),"@E 999,999,999,999.99" ))+";"+;
		AllTrim(Transform(Round((TRB1->RB1_BRUTO),2),"@E 999,999,999,999.99" ))+";"+;
		AllTrim(TRB1->RB1_NMTRAN) })

	dbSkip()
End
Return()
/*/
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????Ŀ??
???Fun??o	 ? RFATI01P_D   ? Autor ? Wilson Cruz - Totvs   ? Data ? 21/02/09 ???
????????????????????????????????????????????????????????????????????????????Ĵ??
???Descri??o ? Gera arquivo texto com documentos selecionados                ???
????????????????????????????????????????????????????????????????????????????Ĵ??
???Uso       ? Brasitech 						        				     ???
?????????????????????????????????????????????????????????????????????????????ٱ?
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????*/
Static Function RFATI01P_D(_cPath)

Local _nTime
Local _nHdl, _nI
_nTime := Time()
_nTime := Strtran(time(),":","")
_nTime := SubStr(_nTime,1,4)
_nHdl  := MSFCREATE(Alltrim(_cPath)+"PED"+Dtos(Date())+_nTime+".CSV",0)
ProcRegua(Len(_aDocs))
For _nI := 1 to len(_aDocs)
	IncProc("Processando ... ")
	FWrite(_nHdl,_aDocs[_nI,1] + CRLF)
Next _nI
FClose(_nHdl)

Return
/*/
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????Ŀ??
???Funcao	 ? RFATI01P_F  ? Autor ? Wilson Cruz - Totvs   ? Data ? 21/02/09 ???
????????????????????????????????????????????????????????????????????????????Ĵ??
???Descricao ? Grava flag de exportacao no cabecalho nota fiscal de saida    ???
????????????????????????????????????????????????????????????????????????????Ĵ??
???Uso       ? Brasitech 						        				     ???
?????????????????????????????????????????????????????????????????????????????ٱ?
????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????*/
Static Function RFATI01P_F()
Local _cDoc    := ""
Local _cSerie  := ""
Local _nTamDoc := TamSX3("F2_DOC")
Local _nTamSer := TamSX3("F2_SERIE")

dbSelectArea("TRB1")
dbGotop()
While !Eof()
	IncProc("Processando ... ")
	If Empty(TRB1->RB1_FLGIMP)
		DbSelectArea("SF2")
		dbSetOrder(1)
		_cDoc   := Substr(TRB1->RB1_DOC,1,_nTamDoc[1])
		_cSerie := Substr(TRB1->RB1_SERIE,1,_nTamSer[1])
		If dbSeek(xFilial("SF2")+_cDoc+_cSerie)
			RecLock("SF2",.F.)
			SF2->F2_X_DTEXP := Date()
			SF2->F2_X_HREXP := Strtran(time(),":","")
			MsUnlock()
		Endif
	Endif
	dbSelectArea("TRB1")
	dbSkip()
End

Return
/*/
?????????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????Ŀ??
???Fun??o	 ? RFATI01P_A   ? Autor ? Wilson Cruz - Totvs   ? Data ? 21/02/09 ???
?????????????????????????????????????????????????????????????????????????????Ĵ??
???Descri??o ? Inclui as perguntas caso nao existam                           ???
?????????????????????????????????????????????????????????????????????????????Ĵ??
???Uso       ? Brasitech 						        				      ???
??????????????????????????????????????????????????????????????????????????????ٱ?
?????????????????????????????????????????????????????????????????????????????????
????????????????????????????????????????????????????????????????????????????????*/
Static Function RFATI01P_A

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
