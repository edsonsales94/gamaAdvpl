#include "protheus.ch"
#include "ap5mail.ch"

/*/

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		GAMA_ROS                                                      /@
@type				User function                                                 /@
@date				26/05/2015                                                    /@
@description	Rotina para uso em schedule. 
					Job para o envio de informa鋏es de notas fiscais faturadas
					para o sistema Telecontrol. GAMA_ROS                          /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

/*/
User Function GAMA_ROS()
Local aFiles	:= {"SC5", "SC6", "SD2"}
Local aStruLog	:= {{"LINHA",		"C", 200, 0}}
Local nK, cTLOG

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Abertura do ambiente
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
WfPrepEnv("01", "03", "U_GAMA_ROS",, "FAT")
for nK := 1 to Len(aFiles)
	if Select(aFiles[nK]) == 0
		ChkFile(aFiles[nK])
	endif
next

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Cria tabela de log
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
cTLOG := CriaTrab(aStruLOG, .T.)
dbUseArea(.T.,"DBFCDX", cTLOG, "TLOG", .T.)
		
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Seleciona as notas emitidas
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
SUBPROC()

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Fecho o arquivo de log e o excluo
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if Select("TLOG") > 0
	TLOG->(dbCloseArea())
endif
fErase(cTLOG + OrdBagExt())
		
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Encerramento do ambiente                                                     
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
RpcClearEnv()
	
ConOut(dTOc(Date()) + " as " + Time() + " - BRAJOB09 - Envio de informa鋏es de notas emitidas via webservice para o sistema Telecontrol")

Return()


/*/

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		SUBPROC                                                       /@
@type				Static function                                               /@
@date				26/05/2015                                                    /@
@description	Fun鈬o chamada pela user function BRAJOB09. Seleciona os 
					registros de faturamento para envio ao sistema Telecontrol por meio
					de webservice e envio de e-mail do resultado do processamento
					aos interessados.                                             /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

/*/
Static Function SUBPROC()
Local aRet, cAnexo, cMensagem
Local cEol			:= "<br>"
Local cDestinat	:= AllTrim(GetMV("BR_EMLWS09", .F., ""))
Local cAssunto		:= "Brasitech - Log de envio de informa鋏es sobre notas emitidas ao Telecontrol"
Local cQuery 		:= "SELECT DISTINCT(SF2.F2_DOC + SF2.F2_SERIE + SF2.F2_EMISSAO + SC5.C5_PEDCLI) REGISTRO, SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_EMISSAO, SC5.C5_PEDCLI " +;
							 "FROM " + RetSqlName("SF2") + " SF2, " + RetSqlName("SD2") + " SD2, " + RetSqlName("SC5") + " SC5 " +;
							 "WHERE SF2.F2_FILIAL = '" + xFilial("SF2") + "' " +;
							 		 "AND SF2.F2_MSEXP = '' " +;
							 		 "AND SF2.D_E_L_E_T_ = '' " +;
							 		 "AND SD2.D2_FILIAL = '" + xFilial("SD2") + "' " +;
							 		 "AND SD2.D2_DOC = SF2.F2_DOC " +;
							 		 "AND SD2.D2_SERIE = SF2.F2_SERIE " +;
							 		 "AND SD2.D2_CLIENTE = SF2.F2_CLIENTE " +;
							 		 "AND SD2.D2_LOJA = SF2.F2_LOJA " +;
							 		 "AND SD2.D_E_L_E_T_ = '' " +;
							 		 "AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' " +;
							 		 "AND SC5.C5_NUM = SD2.D2_PEDIDO " +;
							 		 "AND SC5.C5_VEND1 = '1379' " +;
							 		 "AND SUBSTRING(SC5.C5_PEDCLI,1,2) IN ('PV','OS') " +;
							 		 "AND SC5.D_E_L_E_T_ = '' " +;
					 		 "GROUP BY SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_EMISSAO, SC5.C5_PEDCLI " +;
					 		 "ORDER BY SF2.F2_DOC, SF2.F2_SERIE, SC5.C5_PEDCLI "

SF2->(dbSetOrder(1))		//F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, F2_TIPO

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Verificando se a existencia da area TRB
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
if Select("TRB") > 0
	TRB->(dbCloseArea())
endif

memowrite("GAMA_ROS.sql",cQuery)
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Criando a tabela temporaria 
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
dbUseArea(.T., "TOPCONN", TcGenQry(,,ChangeQuery(cQuery)), "TRB", .F., .T.)

dbSelectArea("TRB")
TRB->(dbGoTop())
do while TRB->(!eof())

	//_cpar5:="" //CANCELA -   PARA RETORNO DE UM PEDIDO FATURADO, INFORMAR ""(BRANCO). PARA RETORNO DE UMA NF CANCELADA, INFORMAR "N". PARA RETORNO DE UM PEDIDO CANCELADO, INFORMAR "P"
	aRet := GAMA_ROS1(substring(AllTrim(TRB->C5_PEDCLI),3,12), AllTrim(TRB->F2_DOC), AllTrim(TRB->F2_SERIE), TRB->F2_EMISSAO, "")

	GrvLog("[Codigo] " + aRet[1] + ",  [Mensagem] " + aRet[2])
	
	if aRet[1] != "2"
		if SF2->(dbSeek(xFilial("SF2") + TRB->(F2_DOC + F2_SERIE)))
			SF2->(RecLock("SF2", .F.))
			SF2->F2_MSEXP := dTOs(dDataBase)
			SF2->(MsUnlock())
		endif
	endif
	
	TRB->(dbSkip())
	
enddo

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Envio de e-mail com o log de processamento
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
dbSelectArea("TLOG")
dbGoTop()
if !eof()
	MakeDir("\EDI01")
	MakeDir("\EDI01\WS")
	
	cAnexo := "\edi01\ws\ROS_" + dTOs(date()) + "_" + StrTran(Time(), ":", "") + ".LOG"
	
	Copy to &cAnexo SDF
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// e-mail no formato html
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
cMensagem := '<html>' + cEol
cMensagem += '<font size="2" face="Arial">Informa鋏es de ocorr麩cias sobre o envio de informa鋏es de notas emitidas ao Telecontrol em' + dTOc(dDataBase) + ' 灣 ' + Time() + '.</font>' + cEol + cEol + cEol
cMensagem += '<font size="1" face="Calibri">E-mail autom疸ico enviado pelo sistema Microsiga Protheus. Favor n縊 respond?-lo.</font>' + cEol	
cMensagem += '</body>' + cEol
cMensagem += '</html>' + cEol

U_GISendMail(cDestinat,, cAssunto, cMensagem, cAnexo)

Return()


/*/

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		GRVLOG                                                        /@
@type				Static function                                               /@
@date				06/09/2014                                                    /@
@description	Fun鈬o chamada pela static function BRAJOB09A. Grava log de
					processamento na tabela tempor疵ia de log                     /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

/*/
Static Function GrvLog(cErro)
Local aArea	:= GetArea()

dbSelectArea("TLOG")
TLOG->(RecLock("TLOG",.T.))
TLOG->LINHA	:= cErro
TLOG->(MsUnlock())

RestArea(aArea)
Return()


/*/

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		GAMA_ROS1                                                     /@
@type				Webservice                                                    /@
@date				01/04/2015                                                    /@
@description	Webservice para retorno de informa鋏es de faturamento do 
					Protheus para o Telecontrol.                                       /@
@author			Felippe Rainho                                                /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

/*/
Static Function GAMA_ROS1(cParRos1, cParRos2, cParRos3, cParRos4, cParRos5)
Local oWSDL
Local lOk, cResp, cParCod, cParMsg, nIni1, nIni1a, nIni2

oWSDL 			:= tWSDLManager():New()
oWSDL:lVerbose := .T.						// Seta o modo de trabalho da classe para "verbose"

// Primeiro faz o parser do WSDL a partir da URL

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Ambiente de testes QAS
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
//ambiente de testes - lOk := oWsdl:ParseURL( "http://gama.Telecontrolonline.com.br/qas/WS_servers/GAMA/PROTEUS/ROS.PHP?wsdl" )

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Ambiente de producao
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
lOk := oWsdl:ParseURL( "http://ww2.telecontrol.com.br/webservice/gamaitaly/servidor_telecontrol_t.php?wsdl" )		//ambiente de producao

if !lOk
	cParCod="2"
	cParMsg="FALHA AO CONECTAR NO WEBSERVICE ROS"
	//MsgStop( oWsdl:cError , "ParseURL() ERROR")
	Return({cParCod,cParMsg})
endif

// Seta a opera鈬o a ser utilizada
lOk := oWsdl:SetOperation("ROS")
if !lOk
	cParCod="2"
	cParMsg="FALHA AO CONECTAR NO METODO ROS"
	//MsgStop( oWsdl:cError , "SetOperation(ROS) ERROR")
	Return({cParCod,cParMsg})
endif

// Setar um valor para convers縊
lOk := oWsdl:SetFirst("NUMPEDIDO",cParRos1)
if !lOk
	cParCod="2"
	cParMsg="ERRO NO CAMPO NUMPEDIDO"
	//MsgStop( oWsdl:cError , "SetFirst(NUMPEDIDO) ERROR")
	Return({cParCod,cParMsg})
endif

lOk := oWsdl:SetFirst("NUMNOTAFISCAL",cParRos2)
if !lOk
	cParCod="2"
	cParMsg="ERRO NO CAMPO NUMNOTAFISCAL"
	//MsgStop( oWsdl:cError , "SetFirst (NUMNOTAFISCAL) ERROR")
	Return({cParCod,cParMsg})
endif

lOk := oWsdl:SetFirst("SERIENOTAFISCAL",cParRos3)
if !lOk
	cParCod="2"
	cParMsg="ERRO NO CAMPO SERIENOTAFISCAL"
	//MsgStop( oWsdl:cError , "SetFirst (NUMNOTAFISCAL) ERROR")
	Return({cParCod,cParMsg})
endif

lOk := oWsdl:SetFirst("DATANOTAFISCAL",cParRos4)
if !lOk
	cParCod="2"
	cParMsg="ERRO NO CAMPO DATANOTAFISCAL"
	//MsgStop( oWsdl:cError , "SetFirst (DATANOTAFISCAL) ERROR")
	Return({cParCod,cParMsg})
endif

lOk := oWsdl:SetFirst("CANCELA",cParRos5)
if !lOk
	cParCod="2"
	cParMsg="ERRO NO CAMPO CANCELA"
	//MsgStop( oWsdl:cError , "SetFirst (CANCELA) ERROR")
	Return({cParCod,cParMsg})
endif

lOk := oWsdl:SendSoapMsg()		//Faz a requisi鈬o ao WebService da Telecontrol
if !lOk
	cParCod="2"
	cParMsg="ERRO AO ENVIAR REQUISICAO AO WEBSERVICE"
	//MsgStop( oWsdl:cError , "SendSoapMsg() ERROR")
	Return({cParCod,cParMsg})
endif

// Recupera os elementos de retorno
cResp 	:= oWsdl:GetSoapResponse()
nIni1		:= Rat("<MSG xsi:type=", cResp)
nIni1a	:= Rat("</MSG>", cResp)
cParMsg	:= Substr(cResp, nIni1 + 27, nIni1a - (nIni1 + 27))
nIni2		:= Rat("</COD>", cResp)
cParCod	:= Substr(cResp, nIni2 - 1, 1)

/*
If cParCod <>""
	MsgStop("MENSAGEM: "+cParCod+"-"+cParMsg,"Requisi鈬o Ok")
Else
	MsgStop("Resposta n縊 encontrada ou inv疝ida.")
Endif
*/
if cParCod == ""
	cParCod	:= "2"
	cParMsg	:= "SEM RESPOSTA DO WEBSERVICE OU INVALIDA"
endif

Return({cParCod,cParMsg})

