#include "protheus.ch"
#include "ap5mail.ch"

/*/

———————————————————————————————————————————————————————————————————————————————
@function		GAMA_ROS                                                      /@
@type				User function                                                 /@
@date				26/05/2015                                                    /@
@description	Rotina para uso em schedule. 
					Job para o envio de informações de notas fiscais faturadas
					para o sistema Telecontrol. GAMA_ROS                          /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————

/*/
User Function GAMA_ROS()
Local aFiles	:= {"SC5", "SC6", "SD2"}
Local aStruLog	:= {{"LINHA",		"C", 200, 0}}
Local nK, cTLOG

//———————————————————————————————————————————————————————————————————————————————
// Abertura do ambiente
//———————————————————————————————————————————————————————————————————————————————
WfPrepEnv("01", "03", "U_GAMA_ROS",, "FAT")
for nK := 1 to Len(aFiles)
	if Select(aFiles[nK]) == 0
		ChkFile(aFiles[nK])
	endif
next

//———————————————————————————————————————————————————————————————————————————————
// Cria tabela de log
//———————————————————————————————————————————————————————————————————————————————
cTLOG := CriaTrab(aStruLOG, .T.)
dbUseArea(.T.,"DBFCDX", cTLOG, "TLOG", .T.)
		
//———————————————————————————————————————————————————————————————————————————————
// Seleciona as notas emitidas
//———————————————————————————————————————————————————————————————————————————————
SUBPROC()

//———————————————————————————————————————————————————————————————————————————————
// Fecho o arquivo de log e o excluo
//———————————————————————————————————————————————————————————————————————————————
if Select("TLOG") > 0
	TLOG->(dbCloseArea())
endif
fErase(cTLOG + OrdBagExt())
		
//———————————————————————————————————————————————————————————————————————————————
// Encerramento do ambiente                                                     
//———————————————————————————————————————————————————————————————————————————————
RpcClearEnv()
	
ConOut(dTOc(Date()) + " as " + Time() + " - BRAJOB09 - Envio de informações de notas emitidas via webservice para o sistema Telecontrol")

Return()


/*/

———————————————————————————————————————————————————————————————————————————————
@function		SUBPROC                                                       /@
@type				Static function                                               /@
@date				26/05/2015                                                    /@
@description	Função chamada pela user function BRAJOB09. Seleciona os 
					registros de faturamento para envio ao sistema Telecontrol por meio
					de webservice e envio de e-mail do resultado do processamento
					aos interessados.                                             /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————

/*/
Static Function SUBPROC()
Local aRet, cAnexo, cMensagem
Local cEol			:= "<br>"
Local cDestinat	:= AllTrim(GetMV("BR_EMLWS09", .F., ""))
Local cAssunto		:= "Brasitech - Log de envio de informações sobre notas emitidas ao Telecontrol"
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

//————————————————————————————————————————————————————————————————————————————
// Verificando se a existencia da area TRB
//————————————————————————————————————————————————————————————————————————————
if Select("TRB") > 0
	TRB->(dbCloseArea())
endif

memowrite("GAMA_ROS.sql",cQuery)
//————————————————————————————————————————————————————————————————————————————
// Criando a tabela temporaria 
//————————————————————————————————————————————————————————————————————————————
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

//————————————————————————————————————————————————————————————————————————————
// Envio de e-mail com o log de processamento
//————————————————————————————————————————————————————————————————————————————
dbSelectArea("TLOG")
dbGoTop()
if !eof()
	MakeDir("\EDI01")
	MakeDir("\EDI01\WS")
	
	cAnexo := "\edi01\ws\ROS_" + dTOs(date()) + "_" + StrTran(Time(), ":", "") + ".LOG"
	
	Copy to &cAnexo SDF
endif

//————————————————————————————————————————————————————————————————————————————
// e-mail no formato html
//————————————————————————————————————————————————————————————————————————————
cMensagem := '<html>' + cEol
cMensagem += '<font size="2" face="Arial">Informações de ocorrências sobre o envio de informações de notas emitidas ao Telecontrol em' + dTOc(dDataBase) + ' às ' + Time() + '.</font>' + cEol + cEol + cEol
cMensagem += '<font size="1" face="Calibri">E-mail automático enviado pelo sistema Microsiga Protheus. Favor não respondê-lo.</font>' + cEol	
cMensagem += '</body>' + cEol
cMensagem += '</html>' + cEol

U_GISendMail(cDestinat,, cAssunto, cMensagem, cAnexo)

Return()


/*/

———————————————————————————————————————————————————————————————————————————————
@function		GRVLOG                                                        /@
@type				Static function                                               /@
@date				06/09/2014                                                    /@
@description	Função chamada pela static function BRAJOB09A. Grava log de
					processamento na tabela temporária de log                     /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————
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
———————————————————————————————————————————————————————————————————————————————
@function		GAMA_ROS1                                                     /@
@type				Webservice                                                    /@
@date				01/04/2015                                                    /@
@description	Webservice para retorno de informações de faturamento do 
					Protheus para o Telecontrol.                                       /@
@author			Felippe Rainho                                                /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————

/*/
Static Function GAMA_ROS1(cParRos1, cParRos2, cParRos3, cParRos4, cParRos5)
Local oWSDL
Local lOk, cResp, cParCod, cParMsg, nIni1, nIni1a, nIni2

oWSDL 			:= tWSDLManager():New()
oWSDL:lVerbose := .T.						// Seta o modo de trabalho da classe para "verbose"

// Primeiro faz o parser do WSDL a partir da URL

//————————————————————————————————————————————————————————————————————————————
// Ambiente de testes QAS
//————————————————————————————————————————————————————————————————————————————
//ambiente de testes - lOk := oWsdl:ParseURL( "http://gama.Telecontrolonline.com.br/qas/WS_servers/GAMA/PROTEUS/ROS.PHP?wsdl" )

//————————————————————————————————————————————————————————————————————————————
// Ambiente de producao
//————————————————————————————————————————————————————————————————————————————
lOk := oWsdl:ParseURL( "http://ww2.telecontrol.com.br/webservice/gamaitaly/servidor_telecontrol_t.php?wsdl" )		//ambiente de producao

if !lOk
	cParCod="2"
	cParMsg="FALHA AO CONECTAR NO WEBSERVICE ROS"
	//MsgStop( oWsdl:cError , "ParseURL() ERROR")
	Return({cParCod,cParMsg})
endif

// Seta a operação a ser utilizada
lOk := oWsdl:SetOperation("ROS")
if !lOk
	cParCod="2"
	cParMsg="FALHA AO CONECTAR NO METODO ROS"
	//MsgStop( oWsdl:cError , "SetOperation(ROS) ERROR")
	Return({cParCod,cParMsg})
endif

// Setar um valor para conversão
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

lOk := oWsdl:SendSoapMsg()		//Faz a requisição ao WebService da Telecontrol
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
	MsgStop("MENSAGEM: "+cParCod+"-"+cParMsg,"Requisição Ok")
Else
	MsgStop("Resposta não encontrada ou inválida.")
Endif
*/
if cParCod == ""
	cParCod	:= "2"
	cParMsg	:= "SEM RESPOSTA DO WEBSERVICE OU INVALIDA"
endif

Return({cParCod,cParMsg})

