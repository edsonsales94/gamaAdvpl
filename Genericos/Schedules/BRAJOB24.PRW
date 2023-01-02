#include "protheus.ch"
#include "ap5mail.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		BRAJOB24                                                     /@
@type			User function                                                /@
@date			21/10/2020                                                   /@
@description	Rotina para uso em schedule. 								 
				Atualiza cadastro de aprovadores com o limite informado no
                respectivo mês do cadastro especifico de limite mensal de
                aprovadores (ZZB).
                Deve ser executada todo dia 1o as 0h                         /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Tecnologia da Informação                            /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function BRAJOB24()
Local aFiles	:= {"SAK", "SCS", "ZZB"}
Local aFil		:= {"03"}
Local nX, nK

//———————————————————————————————————————————————————————————————————————————————
// Lendo por filial
//———————————————————————————————————————————————————————————————————————————————
for nX := 1 to Len(aFil)

	//———————————————————————————————————————————————————————————————————————————————
	// Abertura do ambiente
	//———————————————————————————————————————————————————————————————————————————————
	WfPrepEnv("01", aFil[nX], "U_BRAJOB24",, "COM")

	for nK := 1 to Len(aFiles)
	
		if Empty(Select(aFiles[nK]))
			ChkFile(aFiles[nK])
		endif
		
	next

	//———————————————————————————————————————————————————————————————————————————————
	// Processamento limites e envio de email
    //———————————————————————————————————————————————————————————————————————————————
	A_BRAJOB24()

	//———————————————————————————————————————————————————————————————————————————————
	// Encerramento do ambiente
	//———————————————————————————————————————————————————————————————————————————————
	RpcClearEnv()
	
	ConOut(dTOc(Date()) + " as " + Time() + " - BRAJOB24- Conclusao do processo de atualização limites mensais de compras por aprovador - " + aFil[nX])

	Sleep(15000)		//Aguarda 15 segundos antes de iniciar a próxima empresa
	
next
	
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		A_BRAJOB24                                                   /@
@type			Static function                                              /@
@date			21/10/2020                                                   /@
@description	Atualização limite nas tabelas aprovadores e saldos          /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function A_BRAJOB24()
Local cAno          := StrZero(Year(Date()),4)
Local cMes          := StrZero(Month(Date()),2)
Local aRegistros    := {}
Local cDestinat	    := AllTrim(GetMV("BR_LIMCOM", .F., "equipe.ti@gamaitaly.com.br"))
Local cLinkLogo	    := AllTrim(GetMV("BR_LNKLOGO", .F., "https://sweb.gamaitaly.com.br/images/LogoGamaPeq.jpg"))
Local cAssunto	    := "Brasitech - Limite mensal de aprovadores atualizado em " + dTOc(Date())
Local aMesExtenso   := {"Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto",;
                        "Setembro", "Outubro", "Novembro", "Dezembro"}
Local nValor, nSaldoAnt, cMsg, nX, cCampo

SAK->(dbSetOrder(1))
SCS->(dbSetOrder(2))    //CS_FILIAL, CS_APROV, CS_DATA
ZZB->(dbSetOrder(1))

if ZZB->(dbSeek(xFilial("ZZB") + cAno))

    do while ZZB->(!eof() .and. ZZB_FILIAL == xFilial("ZZB") .and. ZZB_ANO == cAno)
        
        cCampo  := "ZZB_LIMM" + cMes
        nValor  := ZZB->&cCampo
        if SAK->(dbSeek(xFilial("SAK") + ZZB->ZZB_APROV))

            //Verificando o saldo anterior ao mes 
            if cMes $ "01/04/07/10"
                nSaldoAnt   := 0
            else
                nSaldoAnt   := GetSaldo(ZZB->ZZB_APROV)
                nValor      += nSaldoAnt
            endif

            SAK->(RecLock("SAK", .F.))
            SAK->AK_LIMITE      := iif(nValor < 0, 0, nValor)
            SAK->AK_TIPO        := "M"
            SAK->AK_MOEDA       := 1
            SAK->(MsUnlock())

            if SCS->(!dbSeek(xFilial("SCS") + ZZB->ZZB_APROV + dTOs(Date())))
                SCS->(RecLock("SCS", .T.))
                SCS->CS_FILIAL  := xFilial("SCS")
                SCS->CS_COD     := SAK->AK_USER
                SCS->CS_APROV   := SAK->AK_COD
                SCS->CS_DATA    := Date()
            else
                SCS->(RecLock("SCS", .F.))
            endif
            SCS->CS_MOEDA   := 1
            SCS->CS_SALDO   := iif(nValor < 0, 0, nValor)
            SCS->CS_PERFIL  := ""
            SCS->(MsUnlock())
            
            aAdd(aRegistros, {ZZB->ZZB_APROV, SAK->AK_NOME, SAK->AK_TIPO, ZZB->&cCampo, nSaldoAnt, nValor})
        endif

        ZZB->(dbSkip())
    enddo

endif

//———————————————————————————————————————————————————————————————————————————————
// Enviando email com registros
//———————————————————————————————————————————————————————————————————————————————
if Len(aRegistros) > 0

   	//———————————————————————————————————————————————————————————————————————————————
	// Cria texto no formato HTML para envio do e-mail
	//———————————————————————————————————————————————————————————————————————————————
	cMsg := '<html>'
	cMsg += '<body><img src="' + cLinkLogo + '"><br><br>'
	cMsg += '<font size="4" face="Calibri"><b>Relação de aprovadores e respectivos limites para ' + aMesExtenso[Val(cMes)] + " de " + cAno + iif(cMes $ "01/04/07/10", ". (Início de trimestre)", "") + '</b></font><br><br>'
	
	cMsg += '<table width="65%" border="1" cellspacing="0" cellpadding="1">'
	
	cMsg += '<tr>'
	cMsg += '<td width="08%" align="center"><font size="3" face="Calibri"><b>Aprovador</b></font></td>'
	cMsg += '<td width="20%" align="center"><font size="3" face="Calibri"><b>Nome</b></font></td>'
    cMsg += '<td width="07%" align="center"><font size="3" face="Calibri"><b>Tipo</b></font></td>'
	cMsg += '<td width="10%" align="center"><font size="3" face="Calibri"><b>Limite Original</b></font></td>'
	cMsg += '<td width="10%" align="center"><font size="3" face="Calibri"><b>Saldo Anterior</b></font></td>'
	cMsg += '<td width="10%" align="center"><font size="3" face="Calibri"><b>Limite Atualizado</b></font></td>'
	cMsg += '</tr>'

    for nX := 1 to Len(aRegistros)
	
		cMsg += '<tr>'
		cMsg += '<td width="08%" align="left"><font size="3" face="Calibri">' + aRegistros[nX,1] + '</font></td>'
		cMsg += '<td width="20%" align="left"><font size="3" face="Calibri">' + aRegistros[nX,2] + '</font></td>'
        cMsg += '<td width="07%" align="left"><font size="3" face="Calibri">' + aRegistros[nX,3] + '</font></td>'
		cMsg += '<td width="10%" align="right"><font size="3" face="Calibri">' + Transf(aRegistros[nX,4],"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td width="10%" align="right"><font size="3" face="Calibri">' + Transf(aRegistros[nX,5],"@E 999,999,999.99") + '</font></td>'
		cMsg += '<td width="10%" align="right"><font size="3" face="Calibri">' + Transf(aRegistros[nX,6],"@E 999,999,999.99") + '</font></td>'
		cMsg += '</tr>'
				
    next

	cMsg += '</table><br><br><br>'
	cMsg += '<font size="1" face="Calibri"><i>E-mail automático enviado pelo processo de workflow, Favor não respondê-lo.</i></font><br><br>'
	cMsg += '</body>'
	cMsg += '</html>'

    U_GISendMail(cDestinat,, cAssunto, cMsg)

endif

Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		GETSALDO                                                     /@
@type			Static function                                              /@
@date			26/10/2020                                                   /@
@description	Busca do saldo já utilizado                                  /@
@author			Adalberto Moreno Batista (Opção Um)                          /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function GetSaldo(cAprov)
Local nRet      := 0
Local aArea     := GetArea()
Local dDtRefF   := Date() - 1
Local dDtRefI   := cTOd("01/" + StrZero(Month(dDtRefF),2) + "/" + StrZero(Year(dDtRefF),4))
Local cQuery    :=  "SELECT TOP(1) CS_DATA, CS_SALDO " +;
                    "FROM " + RetSQLName("SCS") + " SCS " +;
                    "WHERE CS_FILIAL = '" + xFilial("SCS") + "' " +;
                          "AND CS_APROV = '" + cAprov + "' " +;
                          "AND CS_DATA BETWEEN '" + dTOs(dDtRefI) + "' AND '" + dTOs(dDtRefF) + "' " +;
                    "ORDER BY CS_DATA DESC "

//———————————————————————————————————————————————————————————————————————————————
// Verificando a existencia da area Temporaria
//———————————————————————————————————————————————————————————————————————————————
if Select("SALDO") > 0
	SALDO->(dbCloseArea())
endif

//———————————————————————————————————————————————————————————————————————————————
// Criando a tabela temporaria
//———————————————————————————————————————————————————————————————————————————————
dbUseArea( .T., "TOPCONN", TcGenQRY(,,cQuery), "SALDO", .F., .T.)
dbSelectArea("SALDO")
if SALDO->(!Eof())
    nRet    := SALDO->CS_SALDO
endif

if Select("SALDO") > 0
	SALDO->(dbCloseArea())
endif

RestArea(aArea)
Return(nRet)
