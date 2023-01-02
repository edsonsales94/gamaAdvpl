#include "protheus.ch"
#include "ap5mail.ch"
#include "tbiconn.ch"

/*/
————————————————————————————————————————————————————————————————————————————————————————————————————
@function		BRAJOB16                                                     	                  /@
@type			User function                                            					      /@
@date			07/12/2016                                                                        /@
@description	Rotina para uso em schedule. Job para Exportar Nfs para o Correio (E-commerce)
				Tabelas (SF2, SD2, SA1, SF4, SC5)      										      /@
@author			Luiz Fernando - Brasitech          			                                   	  /@
@use			Específico Brasitech                                                              /@	
————————————————————————————————————————————————————————————————————————————————————————————————————
/*/
User Function BRAJOB16()
Local aFiles	:= {"SF2", "SD2", "SA1"}
Local cEmp		:= "01"						//Brasitech
Local aFil		:= {"03", "01", "08"}		//Filiais 03-São Paulo;01-Manaus;08-Loja
Local nK, nX

//———————————————————————————————————————————————————————————————————————————————
// Abertura do ambiente
//———————————————————————————————————————————————————————————————————————————————
for nX := 1 to Len(aFil)

	//———————————————————————————————————————————————————————————————————————————————
	// Abertura do ambiente
	//———————————————————————————————————————————————————————————————————————————————
	WfPrepEnv(cEmp, aFil[nX], "U_BRAJOB16",, "FAT")
	
	for nK := 1 to Len(aFiles)
	
		if Select(aFiles[nK]) = 0
			ChkFile(aFiles[nK])
		endif
		
	next
	
	A_BRAJOB16()
	
	//———————————————————————————————————————————————————————————————————————————————
	// Encerramento do ambiente                                                     
	//———————————————————————————————————————————————————————————————————————————————
	RpcClearEnv()

	Sleep(2000)
	
next
	
Return()


/*/
———————————————————————————————————————————————————————————————————————————————
@function		A_BRAJOB16                                                   /@
@type			Static function                                              /@
@date			09/03/2015                                                   /@
@description	Função chamada pela user function BRAJOB16. Seleciona as 
				Notas de saída referente ao dia anterior que serão 
				enviadas para o GKO                                          /@
@author			Luiz Fernando - Brasitech                                    /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function A_BRAJOB16()
Local aArea			:= GetArea()
Local aAreaSF2		:= SF2->(GetArea())
Local aAreaSD2		:= SD2->(GetArea())
Local aAreaSB1		:= SB1->(GetArea())
Local aAreaSA1		:= SA1->(GetArea())
Local cDetalhe		:= ""
Local cEnd			:= ""
Local cNumEnd		:= ""
Local cNomeTipo		:= ""
Local aRelatorio	:= {}
Local cEol			:= chr(13) + chr(10)
Local cPath			:= GetMV("BR_PATHECT", .F., "NAO ENCONTRADO")
Local cSEDEX		:= GetMV("BR_SEDEX", .F., "3220")
Local cPAC			:= GetMV("BR_PAC", .F., "3298")
Local cArquivo		:= cPath + "ECT_"  + dTOs(dDataBase) + AllTrim(StrTran(Time(), ":", ""))+".TXT"
Local lOK			:= .T.
Local cRemetente,cTPServico, cCartao, cContrato, cAdminist

//MakeDir("edi01")
//MakeDir("edi01\ect")

Set(_SET_DATEFORMAT, 'dd/mm/yyyy') // Data com QUATRO digitos para Ano


//————————————————————————————————————————————————————————————————
// Seta ordem das tabelas a serem pesquisadas                     
//————————————————————————————————————————————————————————————————
SA1->(dbSetOrder(1))
SB1->(dbSetOrder(1))
SC5->(dbSetOrder(1))
SD2->(dbSetOrder(3))
SF2->(dbSetOrder(1))
CC2->(dbSetOrder(1))

//————————————————————————————————————————————————————————————————
// Selecionando registros                                         
//————————————————————————————————————————————————————————————————
cQuery := 	"SELECT DISTINCT SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_EMISSAO, SF2.F2_CLIENTE, SF2.F2_LOJA,SF2.F2_FILIAL, "
cQuery += 	"SF2.F2_PBRUTO, SF2.F2_TRANSP, SF2.F2_VOLUME1, SF2.F2_VALBRUT,SF2.F2_CHVNFE, SD2.D2_PEDIDO "
cQuery += 	"FROM "+RetSqlName("SF2") +" SF2,"+ RetSqlName("SD2")+" SD2," +RetSqlName("SA4")+" SA4 "
cQuery += 	"WHERE SF2.F2_FILIAL = '"+xFilial("SF2")+"' AND SF2.D_E_L_E_T_ = ' ' AND SA4.D_E_L_E_T_ = '' AND SD2.D_E_L_E_T_ = '' "
cQuery += 	"AND SF2.F2_DOC = SD2.D2_DOC AND SF2.F2_SERIE = SD2.D2_SERIE AND SF2.F2_FILIAL = SD2.D2_FILIAL AND SA4.A4_COD = SF2.F2_TRANSP "
cQuery +=	"AND SA4.A4_X_ECT = '1' "
cQuery +=	"AND SF2.F2_TIPO IN ('N','B') "
cQuery +=	"AND SF2.F2_TRANSP != '      ' "
cQuery +=	"AND SA4.A4_COD = SF2.F2_TRANSP " 
cQuery +=	"AND SD2.D2_TES IN (SELECT F4_CODIGO FROM SF4010 "
cQuery +=	"WHERE F4_ESTOQUE = 'S' AND D_E_L_E_T_ = '' AND F4_FILIAL = '') "
cQuery +=	"AND SF2.F2_XEXPECT = ' ' AND SF2.F2_CHVNFE <> '' "
cQuery +=	"ORDER BY F2_SERIE, F2_DOC "
              
if Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea()
endif
	
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB", .F., .T.)
tcSetField("TRB", "F2_EMISSAO", "D")

//Memowrite("BRAJOB16.sql" , cQuery )

dbSelectArea("TRB")
dbGotop()
if TRB->(!eof())

	nHdl := Fcreate(cArquivo)
	If nHdl == -1
	    ConOut("BRAJOB16 - Erro: " + cArquivo + " não pode ser criado! Verifique os parâmetros.")
	    Return()
	Endif

	Do While TRB->(!Eof()) .and. lOk

		//————————————————————————————————————————————————————
		// Posiciona areas                                    
		//————————————————————————————————————————————————————
		SA1->( dbSeek(xFilial("SA1") + TRB->F2_CLIENTE + TRB->F2_LOJA ) )
		SD2->( dbSeek(xFilial("SD2") + TRB->F2_DOC + TRB->F2_SERIE + TRB->F2_CLIENTE + TRB->F2_LOJA ) )
		CC2->( dbSeek(xFilial("CC2") + SA1->A1_EST + SA1->A1_COD_MUN ) )
		SC5->( dbSeek(xFilial("SC5") + TRB->D2_PEDIDO) )
		ZZ1->( dbSeek(xFilial("ZZ1") + SC5->C5_XECTCAR) )
		
		cEnd 	:= Substr(SA1->A1_END,1,Iif(at(",",SA1->A1_END) > 0,at(",",SA1->A1_END)-1,len(SA1->A1_END)) )
		cNumEnd := Iif(at(",",SA1->A1_END) > 0, Substr(SA1->A1_END,at(",",SA1->A1_END)+1,len(SA1->A1_END)), "")
		
		cTPServico	:= ""	  // Sedex - 40436 / Pac - 41068
		cRemetente	:= ""

		If alltrim(ZZ1->ZZ1_DEPTO) $ "ECOMM-MKTPC"
			cRemetente := "104410005"
		elseif alltrim(ZZ1->ZZ1_DEPTO) == "SAC"
			if alltrim(TRB->F2_SERIE) == "3"
				cRemetente := "104410004"
			else 
				cRemetente := "104410002"
			endif
		elseif alltrim(ZZ1->ZZ1_DEPTO) == "ASTEC"
			if alltrim(TRB->F2_SERIE) == "3"
				cRemetente := "104410003"
			else 
				cRemetente := "104410001"
			endif
		else
			cRemetente := "104410000"
		endif
		
		if SC5->C5_XECTTRA == "1"
			cTPServico 	:= cSEDEX	//"3220" //4162
			cNomeTipo	:= "SEDEX" //4669
		else
			cTPServico := cPAC		//"3298"
			cNomeTipo	:= "PAC"
		endif
		
		cCartao 	:= ZZ1->ZZ1_CARTAO
		cContrato 	:= "9912350046"
		cAdminist	:= "0014173310"
				
		//————————————————————————————————————————————————————
		// Gera Detalhe 									   
		//————————————————————————————————————————————————————
		cDetalhe := PadR(alltrim(SA1->A1_NOME),50)
		cDetalhe += PadR(alltrim(cEnd),90)												
		cDetalhe += PadR(alltrim(cNumEnd),15)							
		cDetalhe += PadR(alltrim(SA1->A1_COMPLEM),50)
		cDetalhe += PadR(alltrim(SA1->A1_BAIRRO),50)							
		cDetalhe += PadR(alltrim(CC2->CC2_MUN),90)
		cDetalhe += SA1->A1_EST
		cDetalhe += iif(SA1->A1_EST == "EX","",PADR(Transform(SA1->A1_CEP,"@R 99999-999"),40) )
		cDetalhe += Padr(StrZero(val(SA1->A1_DDD),3)+SA1->A1_TEL,20)										
		cDetalhe += Padr(cTPServico,10)
		cDetalhe += space(13)
		cDetalhe += strzero(TRB->F2_PBRUTO * 1000,6)
		cDetalhe += space(21)
		cDetalhe += padr(TRB->F2_DOC,12) 
		cDetalhe += padr(TRB->F2_SERIE,5)
		cDetalhe += padr(ALLTRIM(str(TRB->F2_VALBRUT * 100)),20)
		cDetalhe += space(10)   
		cDetalhe += space(18)
		cDetalhe += padr(cContrato,11)
		cDetalhe += padr(cAdminist,11)		
		cDetalhe += padr(cCartao,11)
		cDetalhe += padr(SA1->A1_EMAIL,100)
		//obs1
		cDetalhe += padr(TRB->F2_CHVNFE,100)
		//obs2
		cDetalhe += padr(substr(SC5->C5_PEDCLI,4,LEN(alltrim(SC5->C5_PEDCLI))-3),100)
		//obs3
		cDetalhe += padr(substr(SC5->C5_PEDCLI,4,LEN(alltrim(SC5->C5_PEDCLI))-3),150)
		
		//cDetalhe += padr(TRB->F2_CHVNFE,250)
		cDetalhe += "0000"		
		cDetalhe += strzero(TRB->F2_VOLUME1,4)
		cDetalhe += cRemetente
		cDetalhe += space(20)
		cDetalhe += cEol				
		
	    If fWrite(nHdl,cDetalhe,Len(cDetalhe)) != Len(cDetalhe)
	       	lOk	:= .F.
	    	Exit
	    Endif

  		If SF2->( dbSeek(xFilial("SF2") + TRB->F2_DOC + TRB->F2_SERIE + TRB->F2_CLIENTE + TRB->F2_LOJA ) )
			SF2->(RecLock("SF2",.F.))
			SF2->F2_XEXPECT := "N"
			SF2->(MsUnlock())
			
			aAdd(aRelatorio, {SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_EMISSAO, SA1->A1_NOME, cNomeTipo, SF2->F2_VOLUME1, SC5->C5_MENNOT1 })
		endif
		
		TRB->(DbSkip())

	enddo

	FClose(nHdl)
else

	lOk	:= .F.
	
Endif

if Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea()
endif

if lOk

	ConOut(dTOc(Date()) + " as " + Time() + " - BRAJOB16 - Arquivo Gerado com Sucesso! ")

endif

RestArea(aAreaSF2)
RestArea(aAreaSD2)
RestArea(aAreaSB1)
RestArea(aAreaSA1)
RestArea(aArea)

EnvFTPVipp(aRelatorio)
If SM0->M0_CODFIL == "08"
	EnvFTPEcom(aRelatorio)
endif

Return()


/*
——————Â——————————————Â———————————————————————————————Â——————Â——————————
Funcao³ EnvFTP 		³ Por: Adalberto Moreno Batista ³ Data ³20.11.2012
——————Á——————————————Á———————————————————————————————Á——————Á——————————
Brasitech                                                              
FTP: vipp.visualset.com.br                                             
PORTA: 21                                                              
User: vipp_000495                                                      
Pwd: 123456                                                            
DIRETORIO: /                                							
———————————————————————————————————————————————————————————————————————
*/
Static Function EnvFTPVipp(aRelatorio)
Local cEol		:= chr(13) + chr(10)
Local cLocDir	:= AllTrim(GetMV("BR_PATHECT", .F., "NAO ENCONTRADO"))			//AllTrim(Getmv("MV_XFTPENV", .F., "NAO ENCONTRADO"))
//Local cDirOK	:= AllTrim(Getmv("BR_FTPECOM", .F., "NAO ENCONTRADO"))
Local cDirOK	:= cLocDir + iif(Right(cLocDir,1) = "\","","\") + "finalizados\"
Local cFtpDir	:= AllTrim(GetMV("BR_FTPDIR", .F., "NAO ENCONTRADO"))
Local cFtpEnd	:= AllTrim(GetMV("BR_FTPEND", .F., "NAO ENCONTRADO"))	  		//GetSrvProfString("PTURLFTP","")    // Deve estar no INI onde o JOB e ativado
Local nFtpPort	:= GetMV("BR_FTPPOR", .F., 0)									//GetSrvProfString("PTPORTFTP","21") // Deve estar no INI onde o JOB e ativado
Local cFtpUser	:= AllTrim(GetMV("BR_FTPUSE", .F., "NAO ENCONTRADO"))
Local cFtpPass	:= AllTrim(GetMV("BR_FTPPAS", .F., "NAO ENCONTRADO"))
Local cDestinat	:= AllTrim(GetMV("BR_JOB16I", .F., "grupoti@gamaitaly.com.br"))
Local cMsg		:= ""
Local cLog		:= ""
Local cNomeLog	:= "C:\TEMP\" + StrTran(dTOs(Date()) + "_" + time() + ".LOG", ":", "-")
Local aArquivos	:= {}
Local cTipos, aArqXML, lUpLoad, nTempo, nK, nT, cMensagem, cErro	//, aArqUpload
Default aRelatorio := {}
	
//—————————————————————————————————————————————————
// Validando o preenchimento dos parametros do FTP 
//—————————————————————————————————————————————————
if Empty(cLocDir) .or. cLocDir = "NAO ENCONTRADO"
	cMsg += "MV_XFTPENV, "
endif

if Empty(cFtpDir) .or. cFtpDir = "NAO ENCONTRADO"
	cMsg += "BR_FTPDIR, "
endif

if Empty(cFtpEnd) .or. cFtpEnd = "NAO ENCONTRADO"
	cMsg += "BR_FTPEND, "
endif

if nFtpPort = 0
	cMsg += "BR_FTPPOR, "
endif

if Empty(cFtpUser) .or. cFtpUser = "NAO ENCONTRADO"
	cMsg += "BR_FTPUSE, "
endif

if Empty(cFtpPass) .or. cFtpPass = "NAO ENCONTRADO"
	cMsg += "BR_FTPPAS, "
endif

if !Empty(cMsg)
	ConOut(dTOc(Date()) + " as " + Time() + " - BRAJOB16 - Para que a transferência de arquivos FTP funcione, será necessário configurar o(s) seguinte(s) parâmetro(s): " + cMsg + " (Específico Brasitech). ")
	Return()
endif

//—————————————————————————————————————————————
// Criando o diretorio de log de processamento 
//—————————————————————————————————————————————
MakeDir("C:\TEMP")

//————————————————————————————————————————————
// Identificando os arquivos a serem enviados 
//————————————————————————————————————————————
cTipos		:= cLocDir + "*.TXT"
aArqXML 	:= Directory(cTipos)
for nK := 1 to Len(aArqXML)
	aAdd(aArquivos, aArqXML[nK])
next

//ProcRegua( Len(aArquivos) + 1 )

if Len(aArquivos) > 0
	//——————————————————————————————————————————————————————————————
	// Conecta-se ao FTP Protheus para realizar UPLOAD de arquivos. 
	// Conecto a 1a vez e desconecto para evitar falha na 1a conexao
	//——————————————————————————————————————————————————————————————
	FtpDisconnect()
	FtpConnect(cFtpEnd, nFtpPort, cFtpUser, cFtpPass)
	FtpDisconnect()

	for nK := 1 to Len(aArquivos)	

		IncProc("Upload do arquivo " + AllTrim(aArquivos[nK,1]))
		
		if FtpConnect(cFtpEnd, nFtpPort, cFtpUser, cFtpPass)
	
			//—————————————————————————————————————————
			// Muda de diretorio dentro do Sevidor FTP 
			//—————————————————————————————————————————
			if !FtpDirChange(cFtpDir)
				ConOut("BRAJOB16 - Não foi possível localizar o diretório " + cFtpDir + " no Servidor FTP (Específico Brasitech). ")
		   		FtpDisconnect()
				Return()
			EndIf
		
			//————————————————————————————————————————————————
			// Realiza 2 tentativas antes de abortar o upload 
			//————————————————————————————————————————————————
			lUpLoad := .T.
			nTempo	:= 1
			do while nTempo <= 2
				lUpLoad := FtpUpLoad(cLocDir + AllTrim( aArquivos[nK,1] ), AllTrim( aArquivos[nK,1]))
				//———————————————————————————————————————————————————————————————————————————————————————
				// Caso nao tenha conseguido subir o arquivo, aguardo um tempo antes de tentar novamente 
				//———————————————————————————————————————————————————————————————————————————————————————
				if !lUpLoad
					nTempo++
					for nT := 1 to 70000000 * nTempo		//a cada tentativa, espero um tempo maior para tentar novamente
					next
				else
					exit
				endif
			enddo

			//——————————————————————————————————————————————————
			// Certifico-me de que o arquivo foi copiado no ftp 
			//——————————————————————————————————————————————————
			/*
			bloco retirado, pois arquivo havia sido carregado no ftp, mas a função
			ftpdirectory não está retornando os arquivos.
			if lUpload
				aArqUpload 	:= FtpDirectory(AllTrim(aArquivos[nK,1]),,.F.)
				if Len(aArqUpLoad) > 0
					if Upper(AllTrim(aArquivos[nK,1])) != Upper(AllTrim(aArqUpLoad[1,1]))
						lUpload := .F.
					endif
				else
					lUpload := .F.
				endif
			endif
			*/
			
			//—————————————————————————————————
			// Testo se o upload foi realizado 
			//—————————————————————————————————
			If !lUpload
				
				ConOut("BRAJOB16 - Não foi possível subir o arquivo " + aArquivos[nK,1] + " para o FTP (Específico Brasitech). ")
				cLog += "Não foi possível subir o arquivo " + aArquivos[nK,1] + " para o FTP" + cEol

			else

				__CopyFile(cLocDir  + aArquivos[nK,1], cDirOK + aArquivos[nK,1])
				fErase(cLocDir + aArquivos[nK,1])
				ConOut("O arquivo " + aArquivos[nK,1] + " foi transferido com sucesso para o FTP do sistema VIPP (Específico Brasitech). ")
				cLog += "O arquivo " + aArquivos[nK,1] + " foi transferido com sucesso para o FTP do sistema VIPP" + cEol
			endif

		Else
			ConOut("BRAJOB16 - Não foi possível conectar-se ao FTP do sistema VIPP para o envio do arquivo " + aArquivos[nK,1] + "(Específico Brasitech). ")
			cLog += "Não foi possível conectar-se ao FTP do sistema VIPP para o envio do arquivo " + aArquivos[nK,1] + cEol
		EndIf
		
		//————————————————————————————————
		// Desconectando do Servidor FTP  
		//————————————————————————————————
		FtpDisconnect()
		MemoWrite(cNomeLog, cLog)

	Next
Endif

//—————————————————————————————————————————————————————————————————————————————————————————
// Envia e-mail com o relação de notas somente quando gerada a transmissão convencional    
// por meio do "envio" ou "reenvio". E-mail enviado mesmo quando os arquivos não tenham    
// transmitidos para o FTP.                                                                
// Caso seja somente ativada o envio por ftp (opção FTP no menu), o e-mail não será gerado 
//—————————————————————————————————————————————————————————————————————————————————————————
if Len(aRelatorio) > 0
	//email no formato html
	cMensagem := '<html>'
	cMensagem += '<font size="2" face="Arial">Segue lista com as notas fiscais carregadas no ftp do sistema VIPP em ' + dTOc(date()) + ', às ' + time() + '.</font><br><br>'

	//Abrindo a tabela
	cMensagem += '<table width="100%" border="1" cellspacing="0" cellpadding="0">'

	//Abrindo a linha do cabeçalho
	cMensagem += '<tr>'
	cMensagem += '<td width="7%" align="center"><font size="2" face="Calibri"><strong>Nota Fiscal</strong></font></td>'
	cMensagem += '<td width="3%" align="center"><font size="2" face="Calibri"><strong>Série</strong></font></td>'
	cMensagem += '<td width="6%" align="center"><font size="2" face="Calibri"><strong>Emissão</strong></font></td>'
	cMensagem += '<td width="25%" align="center"><font size="2" face="Calibri"><strong>Cliente</strong></font></td>'
	cMensagem += '<td width="6%" align="center"><font size="2" face="Calibri"><strong>Tipo Serviço</strong></font></td>'
	cMensagem += '<td width="4%" align="center"><font size="2" face="Calibri"><strong>Vol.</strong></font></td>'


	cMensagem += '</tr>'
	
	//Abrindo a linha dos itens
	for nK := 1 to len(aRelatorio)
		cMensagem += '<tr>'
		cMensagem += '<td width="7%" align="left"><font size="2" face="Calibri">' 	+ 	AllTrim(aRelatorio[nK,1]) + '</font></td>'
		cMensagem += '<td width="3%" align="center"><font size="2" face="Calibri">' + 	AllTrim(aRelatorio[nK,2]) + '</font></td>'
		cMensagem += '<td width="6%" align="center"><font size="2" face="Calibri">' + 	dTOc(aRelatorio[nK,3]) + '</font></td>'
		cMensagem += '<td width="25%" align="left"><font size="2" face="Calibri">' 	+ 	AllTrim(aRelatorio[nK,4]) + '</font></td>'
		cMensagem += '<td width="6%" align="left"><font size="2" face="Calibri">' 	+ 	AllTrim(aRelatorio[nK,5]) + '</font></td>'
		cMensagem += '<td width="4%" align="right"><font size="2" face="Calibri">' 	+ 	Transform(aRelatorio[nK,6],"@E 999,999,999") + '</font></td>'
		
		cMensagem += '</tr>'
	next
	
	cMensagem += '</table>'
	
	cMensagem += '</body>'
	cMensagem += '</html>'
	
	cErro := U_GISendMail(cDestinat,, "Carregamento de arquivo no ftp VIPP em " + dTOc(dDataBase) + " às " + Time(), cMensagem)
	
	if !Empty(cErro)
		ConOUt("Ocorreu o seguinte erro  no envio do Não foram localizadas notas fiscais dentro do período informado.Possíveis causas: Não existem NFs no intervalo selecionado ou as NFs já foram enviadas ao sistema VIPP ou as notas existentes não pertencem ao grupo apto a gerar separação. (Específico Brasitech). ")	
	endif
endif

Return()

/*
——————Â——————————————Â———————————————————————————————Â——————Â——————————
Funcao³ EnvFTP 		³ Por: Adalberto Moreno Batista ³ Data ³20.11.2012
——————Á——————————————Á———————————————————————————————Á——————Á——————————
Brasitech                                                              
FTP: gamaitaly.com.br                                                  
PORTA: 21                                                              
User: import@gamaitaly.com.br                                          
Pwd: q1w2e3                                                            
DIRETORIO: /                 			              				
———————————————————————————————————————————————————————————————————————
*/
Static Function EnvFTPEcom(aRelatorio)
Local cEol		:= chr(13) + chr(10)
Local cLocDir	:= AllTrim(GetMV("BR_PATHECT", .F., "NAO ENCONTRADO"))			//AllTrim(Getmv("BR_FTPECOM", .F., "NAO ENCONTRADO"))
Local cDirOK	:= cLocDir + iif(Right(cLocDir,1) = "\","","\") + "finalizados\"
Local cFtpDir	:= AllTrim(GetMV("BR_FTPDIR1", .F., "NAO ENCONTRADO"))
Local cFtpEnd	:= AllTrim(GetMV("BR_FTPEND1", .F., "NAO ENCONTRADO"))	  		//GetSrvProfString("PTURLFTP","")    // Deve estar no INI onde o JOB e ativado
Local nFtpPort	:= GetMV("BR_FTPPOR1", .F., 0)									//GetSrvProfString("PTPORTFTP","21") // Deve estar no INI onde o JOB e ativado
Local cFtpUser	:= AllTrim(GetMV("BR_FTPUSE1", .F., "NAO ENCONTRADO"))
Local cFtpPass	:= AllTrim(GetMV("BR_FTPPAS1", .F., "NAO ENCONTRADO"))
Local cDestinat	:= AllTrim(GetMV("BR_JOB16II", .F., "luiz.fernando@gamaitaly.com.br"))
Local cMsg		:= ""
Local cLog		:= ""
Local cNomeLog	:= "C:\TEMP\" + StrTran(dTOs(Date()) + "_" + time() + ".LOG", ":", "-")
Local aArquivos	:= {}
Local cTipos, aArqXML, lUpLoad, nTempo, nK, nT, cMensagem, cErro	//, aArqUpload
Default aRelatorio := {}
	
//—————————————————————————————————————————————————
// Validando o preenchimento dos parametros do FTP 
//—————————————————————————————————————————————————
if Empty(cLocDir) .or. cLocDir = "NAO ENCONTRADO"
	cMsg += "BR_FTPECOM, "
endif

if Empty(cFtpDir) .or. cFtpDir = "NAO ENCONTRADO"
	cMsg += "BR_FTPDIR1, "
endif

if Empty(cFtpEnd) .or. cFtpEnd = "NAO ENCONTRADO"
	cMsg += "BR_FTPEND1, "
endif

if nFtpPort = 0
	cMsg += "BR_FTPPOR1, "
endif

if Empty(cFtpUser) .or. cFtpUser = "NAO ENCONTRADO"
	cMsg += "BR_FTPUSE1, "
endif

if Empty(cFtpPass) .or. cFtpPass = "NAO ENCONTRADO"
	cMsg += "BR_FTPPAS1, "
endif

if !Empty(cMsg)
	ConOut(dTOc(Date()) + " as " + Time() + " - BRAJOB16 - Para que a transferência de arquivos FTP funcione, será necessário configurar o(s) seguinte(s) parâmetro(s): " + cMsg + " (Específico Brasitech). ")
	Return()
endif

//—————————————————————————————————————————————
// Criando o diretorio de log de processamento 
//—————————————————————————————————————————————
MakeDir("C:\TEMP")

//————————————————————————————————————————————
// Identificando os arquivos a serem enviados 
//————————————————————————————————————————————
cTipos		:= cLocDir + "*.TXT"
aArqXML 	:= Directory(cTipos)
for nK := 1 to Len(aArqXML)
	aAdd(aArquivos, aArqXML[nK])
next

ProcRegua( Len(aArquivos) + 1 )

if Len(aArquivos) > 0
	//——————————————————————————————————————————————————————————————
	//Conecta-se ao FTP Protheus para realizar UPLOAD de arquivos.  
	//Conecto a 1a vez e desconecto para evitar falha na 1a conexao 
	//——————————————————————————————————————————————————————————————
	FtpDisconnect()
	FtpConnect(cFtpEnd, nFtpPort, cFtpUser, cFtpPass)
	FtpDisconnect()

	for nK := 1 to Len(aArquivos)	

		IncProc("Upload do arquivo " + AllTrim(aArquivos[nK,1]))
		
		if FtpConnect(cFtpEnd, nFtpPort, cFtpUser, cFtpPass)
	
			//—————————————————————————————————————————
			// Muda de diretorio dentro do Sevidor FTP 
			//—————————————————————————————————————————
			if !FtpDirChange(cFtpDir)
				ConOut("BRAJOB16 - Não foi possível localizar o diretório " + cFtpDir + " no Servidor FTP (Específico Brasitech). ")
		   		FtpDisconnect()
				Return()
			EndIf
		
			//————————————————————————————————————————————————
			// Realiza 2 tentativas antes de abortar o upload 
			//————————————————————————————————————————————————
			lUpLoad := .T.
			nTempo	:= 1
			do while nTempo <= 2
				lUpLoad := FtpUpLoad(cLocDir + AllTrim( aArquivos[nK,1] ), AllTrim( aArquivos[nK,1]))
				//———————————————————————————————————————————————————————————————————————————————————————
				// Caso nao tenha conseguido subir o arquivo, aguardo um tempo antes de tentar novamente 
				//———————————————————————————————————————————————————————————————————————————————————————
				if !lUpLoad
					nTempo++
					for nT := 1 to 70000000 * nTempo		//a cada tentativa, espero um tempo maior para tentar novamente
					next
				else
					exit
				endif
			enddo

			//——————————————————————————————————————————————————
			// Certifico-me de que o arquivo foi copiado no ftp 
			//——————————————————————————————————————————————————
			/*if lUpload
				aArqUpload 	:= FtpDirectory(AllTrim(aArquivos[nK,1]),,.F.)
				if Len(aArqUpLoad) > 0
					if Upper(AllTrim(aArquivos[nK,1])) != Upper(AllTrim(aArqUpLoad[1,1]))
						lUpload := .F.
					endif
				else
					lUpload := .F.
				endif
			endif*/
			
			//—————————————————————————————————
			// Testo se o upload foi realizado 
			//—————————————————————————————————
			If !lUpload
				
				ConOut("BRAJOB16 - Não foi possível subir o arquivo " + aArquivos[nK,1] + " para o FTP (Específico Brasitech). ")
				cLog += "Não foi possível subir o arquivo " + aArquivos[nK,1] + " para o FTP" + cEol

			else

				__CopyFile(cLocDir  + aArquivos[nK,1], cDirOK + aArquivos[nK,1])
				fErase(cLocDir + aArquivos[nK,1])
				ConOut("O arquivo " + aArquivos[nK,1] + " foi transferido com sucesso para o FTP do sistema Ecommerce (Específico Brasitech). ")
				cLog += "O arquivo " + aArquivos[nK,1] + " foi transferido com sucesso para o FTP do sistema Ecommerce" + cEol
			endif

		Else
			ConOut("BRAJOB16 - Não foi possível conectar-se ao FTP do sistema Ecommerce para o envio do arquivo " + aArquivos[nK,1] + "(Específico Brasitech). ")
			cLog += "Não foi possível conectar-se ao FTP do sistema Ecommerce para o envio do arquivo " + aArquivos[nK,1] + cEol
		EndIf
		
		//————————————————————————————————
		// Desconectando do Servidor FTP  
		//————————————————————————————————
		FtpDisconnect()
		MemoWrite(cNomeLog, cLog)

	Next
Endif

//—————————————————————————————————————————————————————————————————————————————————————————
// Envia e-mail com o relação de notas somente quando gerada a transmissão convencional    
// por meio do "envio" ou "reenvio". E-mail enviado mesmo quando os arquivos não tenham    
// transmitidos para o FTP.                                                                
// Caso seja somente ativada o envio por ftp (opção FTP no menu), o e-mail não será gerado 
//—————————————————————————————————————————————————————————————————————————————————————————
if Len(aRelatorio) > 0
	//email no formato html
	cMensagem := '<html>'
	cMensagem += '<font size="2" face="Arial">Segue lista com as notas fiscais carregadas no ftp do sistema de Ecommerce Gama em ' + dTOc(date()) + ', às ' + time() + '.</font><br><br>'

	//Abrindo a tabela
	cMensagem += '<table width="100%" border="1" cellspacing="0" cellpadding="0">'

	//Abrindo a linha do cabeçalho
	cMensagem += '<tr>'
	cMensagem += '<td width="7%" align="center"><font size="2" face="Calibri"><strong>Nota Fiscal</strong></font></td>'
	cMensagem += '<td width="3%" align="center"><font size="2" face="Calibri"><strong>Série</strong></font></td>'
	cMensagem += '<td width="6%" align="center"><font size="2" face="Calibri"><strong>Emissão</strong></font></td>'
	cMensagem += '<td width="25%" align="center"><font size="2" face="Calibri"><strong>Cliente</strong></font></td>'
	cMensagem += '<td width="6%" align="center"><font size="2" face="Calibri"><strong>Tipo Serviço</strong></font></td>'
	cMensagem += '<td width="4%" align="center"><font size="2" face="Calibri"><strong>Vol.</strong></font></td>'
	cMensagem += '<td width="25%" align="center"><font size="2" face="Calibri"><strong>Mens. Nota</strong></font></td>'

	cMensagem += '</tr>'
	
	//Abrindo a linha dos itens
	for nK := 1 to len(aRelatorio)
		cMensagem += '<tr>'
		cMensagem += '<td width="7%" align="left"><font size="2" face="Calibri">' 	+ 	AllTrim(aRelatorio[nK,1]) + '</font></td>'
		cMensagem += '<td width="3%" align="center"><font size="2" face="Calibri">' + 	AllTrim(aRelatorio[nK,2]) + '</font></td>'
		cMensagem += '<td width="6%" align="center"><font size="2" face="Calibri">' + 	dTOc(aRelatorio[nK,3]) + '</font></td>'
		cMensagem += '<td width="25%" align="left"><font size="2" face="Calibri">' 	+ 	AllTrim(aRelatorio[nK,4]) + '</font></td>'
		cMensagem += '<td width="6%" align="left"><font size="2" face="Calibri">' 	+ 	AllTrim(aRelatorio[nK,5]) + '</font></td>'
		cMensagem += '<td width="4%" align="right"><font size="2" face="Calibri">' 	+ 	Transform(aRelatorio[nK,6],"@E 999,999,999") + '</font></td>'   
		cMensagem += '<td width="25%" align="left"><font size="2" face="Calibri">' 	+ 	AllTrim(aRelatorio[nK,7]) + '</font></td>'
		cMensagem += '</tr>'
	next
	
	cMensagem += '</table>'
	
	cMensagem += '</body>'
	cMensagem += '</html>'
	
	cErro := U_GISendMail(cDestinat,, "Carregamento de arquivo no ftp Ecommerce Gama em " + dTOc(dDataBase) + " às " + Time(), cMensagem)
	
	if !Empty(cErro)
		ConOUt("Ocorreu o seguinte erro  no envio do Não foram localizadas notas fiscais dentro do período informado.Possíveis causas: Não existem NFs no intervalo selecionado ou as NFs já foram enviadas ao sistema VIPP ou as notas existentes não pertencem ao grupo apto a gerar separação. (Específico Brasitech). ")	
	endif
endif

Return()
