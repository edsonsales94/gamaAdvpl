#include "protheus.ch"
#include "ap5mail.ch"
#include "tbiconn.ch"

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
@function		BRAJOB16                                                     	                  /@
@type			User function                                            					      /@
@date			07/12/2016                                                                        /@
@description	Rotina para uso em schedule. Job para Exportar Nfs para o Correio (E-commerce)
				Tabelas (SF2, SD2, SA1, SF4, SC5)      										      /@
@author			Luiz Fernando - Brasitech          			                                   	  /@
@use			Espec?fico Brasitech                                                              /@	
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
/*/
User Function BRAJOB16()
Local aFiles	:= {"SF2", "SD2", "SA1"}
Local cEmp		:= "01"						//Brasitech
Local aFil		:= {"03", "01", "08"}		//Filiais 03-S縊 Paulo;01-Manaus;08-Loja
Local nK, nX

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Abertura do ambiente
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
for nX := 1 to Len(aFil)

	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Abertura do ambiente
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	WfPrepEnv(cEmp, aFil[nX], "U_BRAJOB16",, "FAT")
	
	for nK := 1 to Len(aFiles)
	
		if Select(aFiles[nK]) = 0
			ChkFile(aFiles[nK])
		endif
		
	next
	
	A_BRAJOB16()
	
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	// Encerramento do ambiente                                                     
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
	RpcClearEnv()

	Sleep(2000)
	
next
	
Return()


/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		A_BRAJOB16                                                   /@
@type			Static function                                              /@
@date			09/03/2015                                                   /@
@description	Fun鈬o chamada pela user function BRAJOB16. Seleciona as 
				Notas de sa?da referente ao dia anterior que ser縊 
				enviadas para o GKO                                          /@
@author			Luiz Fernando - Brasitech                                    /@
@use			Espec?fico Brasitech                                         /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
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


//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Seta ordem das tabelas a serem pesquisadas                     
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
SA1->(dbSetOrder(1))
SB1->(dbSetOrder(1))
SC5->(dbSetOrder(1))
SD2->(dbSetOrder(3))
SF2->(dbSetOrder(1))
CC2->(dbSetOrder(1))

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Selecionando registros                                         
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
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
	    ConOut("BRAJOB16 - Erro: " + cArquivo + " n縊 pode ser criado! Verifique os par穃etros.")
	    Return()
	Endif

	Do While TRB->(!Eof()) .and. lOk

		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
		// Posiciona areas                                    
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
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
				
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
		// Gera Detalhe 									   
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
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
覧覧覧ﾂ覧覧覧覧覧覧覧ﾂ覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧猟覧覧覧ﾂ覧覧覧覧覧
Funcaoｳ EnvFTP 		ｳ Por: Adalberto Moreno Batista ｳ Data ｳ20.11.2012
覧覧覧ﾁ覧覧覧覧覧覧覧ﾁ覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧涼覧覧覧ﾁ覧覧覧覧覧
Brasitech                                                              
FTP: vipp.visualset.com.br                                             
PORTA: 21                                                              
User: vipp_000495                                                      
Pwd: 123456                                                            
DIRETORIO: /                                							
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
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
	
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Validando o preenchimento dos parametros do FTP 
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
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
	ConOut(dTOc(Date()) + " as " + Time() + " - BRAJOB16 - Para que a transfer麩cia de arquivos FTP funcione, ser? necess疵io configurar o(s) seguinte(s) par穃etro(s): " + cMsg + " (Espec?fico Brasitech). ")
	Return()
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Criando o diretorio de log de processamento 
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
MakeDir("C:\TEMP")

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Identificando os arquivos a serem enviados 
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
cTipos		:= cLocDir + "*.TXT"
aArqXML 	:= Directory(cTipos)
for nK := 1 to Len(aArqXML)
	aAdd(aArquivos, aArqXML[nK])
next

//ProcRegua( Len(aArquivos) + 1 )

if Len(aArquivos) > 0
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	// Conecta-se ao FTP Protheus para realizar UPLOAD de arquivos. 
	// Conecto a 1a vez e desconecto para evitar falha na 1a conexao
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	FtpDisconnect()
	FtpConnect(cFtpEnd, nFtpPort, cFtpUser, cFtpPass)
	FtpDisconnect()

	for nK := 1 to Len(aArquivos)	

		IncProc("Upload do arquivo " + AllTrim(aArquivos[nK,1]))
		
		if FtpConnect(cFtpEnd, nFtpPort, cFtpUser, cFtpPass)
	
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			// Muda de diretorio dentro do Sevidor FTP 
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			if !FtpDirChange(cFtpDir)
				ConOut("BRAJOB16 - N縊 foi poss?vel localizar o diret?rio " + cFtpDir + " no Servidor FTP (Espec?fico Brasitech). ")
		   		FtpDisconnect()
				Return()
			EndIf
		
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
			// Realiza 2 tentativas antes de abortar o upload 
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
			lUpLoad := .T.
			nTempo	:= 1
			do while nTempo <= 2
				lUpLoad := FtpUpLoad(cLocDir + AllTrim( aArquivos[nK,1] ), AllTrim( aArquivos[nK,1]))
				//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
				// Caso nao tenha conseguido subir o arquivo, aguardo um tempo antes de tentar novamente 
				//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
				if !lUpLoad
					nTempo++
					for nT := 1 to 70000000 * nTempo		//a cada tentativa, espero um tempo maior para tentar novamente
					next
				else
					exit
				endif
			enddo

			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
			// Certifico-me de que o arquivo foi copiado no ftp 
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
			/*
			bloco retirado, pois arquivo havia sido carregado no ftp, mas a fun鈬o
			ftpdirectory n縊 est? retornando os arquivos.
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
			
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			// Testo se o upload foi realizado 
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			If !lUpload
				
				ConOut("BRAJOB16 - N縊 foi poss?vel subir o arquivo " + aArquivos[nK,1] + " para o FTP (Espec?fico Brasitech). ")
				cLog += "N縊 foi poss?vel subir o arquivo " + aArquivos[nK,1] + " para o FTP" + cEol

			else

				__CopyFile(cLocDir  + aArquivos[nK,1], cDirOK + aArquivos[nK,1])
				fErase(cLocDir + aArquivos[nK,1])
				ConOut("O arquivo " + aArquivos[nK,1] + " foi transferido com sucesso para o FTP do sistema VIPP (Espec?fico Brasitech). ")
				cLog += "O arquivo " + aArquivos[nK,1] + " foi transferido com sucesso para o FTP do sistema VIPP" + cEol
			endif

		Else
			ConOut("BRAJOB16 - N縊 foi poss?vel conectar-se ao FTP do sistema VIPP para o envio do arquivo " + aArquivos[nK,1] + "(Espec?fico Brasitech). ")
			cLog += "N縊 foi poss?vel conectar-se ao FTP do sistema VIPP para o envio do arquivo " + aArquivos[nK,1] + cEol
		EndIf
		
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
		// Desconectando do Servidor FTP  
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
		FtpDisconnect()
		MemoWrite(cNomeLog, cLog)

	Next
Endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Envia e-mail com o rela鈬o de notas somente quando gerada a transmiss縊 convencional    
// por meio do "envio" ou "reenvio". E-mail enviado mesmo quando os arquivos n縊 tenham    
// transmitidos para o FTP.                                                                
// Caso seja somente ativada o envio por ftp (op鈬o FTP no menu), o e-mail n縊 ser? gerado 
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if Len(aRelatorio) > 0
	//email no formato html
	cMensagem := '<html>'
	cMensagem += '<font size="2" face="Arial">Segue lista com as notas fiscais carregadas no ftp do sistema VIPP em ' + dTOc(date()) + ', 灣 ' + time() + '.</font><br><br>'

	//Abrindo a tabela
	cMensagem += '<table width="100%" border="1" cellspacing="0" cellpadding="0">'

	//Abrindo a linha do cabe軋lho
	cMensagem += '<tr>'
	cMensagem += '<td width="7%" align="center"><font size="2" face="Calibri"><strong>Nota Fiscal</strong></font></td>'
	cMensagem += '<td width="3%" align="center"><font size="2" face="Calibri"><strong>S駻ie</strong></font></td>'
	cMensagem += '<td width="6%" align="center"><font size="2" face="Calibri"><strong>Emiss縊</strong></font></td>'
	cMensagem += '<td width="25%" align="center"><font size="2" face="Calibri"><strong>Cliente</strong></font></td>'
	cMensagem += '<td width="6%" align="center"><font size="2" face="Calibri"><strong>Tipo Servi輟</strong></font></td>'
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
	
	cErro := U_GISendMail(cDestinat,, "Carregamento de arquivo no ftp VIPP em " + dTOc(dDataBase) + " 灣 " + Time(), cMensagem)
	
	if !Empty(cErro)
		ConOUt("Ocorreu o seguinte erro  no envio do N縊 foram localizadas notas fiscais dentro do per?odo informado.Poss?veis causas: N縊 existem NFs no intervalo selecionado ou as NFs j? foram enviadas ao sistema VIPP ou as notas existentes n縊 pertencem ao grupo apto a gerar separa鈬o. (Espec?fico Brasitech). ")	
	endif
endif

Return()

/*
覧覧覧ﾂ覧覧覧覧覧覧覧ﾂ覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧猟覧覧覧ﾂ覧覧覧覧覧
Funcaoｳ EnvFTP 		ｳ Por: Adalberto Moreno Batista ｳ Data ｳ20.11.2012
覧覧覧ﾁ覧覧覧覧覧覧覧ﾁ覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧涼覧覧覧ﾁ覧覧覧覧覧
Brasitech                                                              
FTP: gamaitaly.com.br                                                  
PORTA: 21                                                              
User: import@gamaitaly.com.br                                          
Pwd: q1w2e3                                                            
DIRETORIO: /                 			              				
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
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
	
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Validando o preenchimento dos parametros do FTP 
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
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
	ConOut(dTOc(Date()) + " as " + Time() + " - BRAJOB16 - Para que a transfer麩cia de arquivos FTP funcione, ser? necess疵io configurar o(s) seguinte(s) par穃etro(s): " + cMsg + " (Espec?fico Brasitech). ")
	Return()
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Criando o diretorio de log de processamento 
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
MakeDir("C:\TEMP")

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
// Identificando os arquivos a serem enviados 
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
cTipos		:= cLocDir + "*.TXT"
aArqXML 	:= Directory(cTipos)
for nK := 1 to Len(aArqXML)
	aAdd(aArquivos, aArqXML[nK])
next

ProcRegua( Len(aArquivos) + 1 )

if Len(aArquivos) > 0
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	//Conecta-se ao FTP Protheus para realizar UPLOAD de arquivos.  
	//Conecto a 1a vez e desconecto para evitar falha na 1a conexao 
	//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
	FtpDisconnect()
	FtpConnect(cFtpEnd, nFtpPort, cFtpUser, cFtpPass)
	FtpDisconnect()

	for nK := 1 to Len(aArquivos)	

		IncProc("Upload do arquivo " + AllTrim(aArquivos[nK,1]))
		
		if FtpConnect(cFtpEnd, nFtpPort, cFtpUser, cFtpPass)
	
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			// Muda de diretorio dentro do Sevidor FTP 
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			if !FtpDirChange(cFtpDir)
				ConOut("BRAJOB16 - N縊 foi poss?vel localizar o diret?rio " + cFtpDir + " no Servidor FTP (Espec?fico Brasitech). ")
		   		FtpDisconnect()
				Return()
			EndIf
		
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
			// Realiza 2 tentativas antes de abortar o upload 
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
			lUpLoad := .T.
			nTempo	:= 1
			do while nTempo <= 2
				lUpLoad := FtpUpLoad(cLocDir + AllTrim( aArquivos[nK,1] ), AllTrim( aArquivos[nK,1]))
				//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
				// Caso nao tenha conseguido subir o arquivo, aguardo um tempo antes de tentar novamente 
				//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
				if !lUpLoad
					nTempo++
					for nT := 1 to 70000000 * nTempo		//a cada tentativa, espero um tempo maior para tentar novamente
					next
				else
					exit
				endif
			enddo

			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
			// Certifico-me de que o arquivo foi copiado no ftp 
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
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
			
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			// Testo se o upload foi realizado 
			//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
			If !lUpload
				
				ConOut("BRAJOB16 - N縊 foi poss?vel subir o arquivo " + aArquivos[nK,1] + " para o FTP (Espec?fico Brasitech). ")
				cLog += "N縊 foi poss?vel subir o arquivo " + aArquivos[nK,1] + " para o FTP" + cEol

			else

				__CopyFile(cLocDir  + aArquivos[nK,1], cDirOK + aArquivos[nK,1])
				fErase(cLocDir + aArquivos[nK,1])
				ConOut("O arquivo " + aArquivos[nK,1] + " foi transferido com sucesso para o FTP do sistema Ecommerce (Espec?fico Brasitech). ")
				cLog += "O arquivo " + aArquivos[nK,1] + " foi transferido com sucesso para o FTP do sistema Ecommerce" + cEol
			endif

		Else
			ConOut("BRAJOB16 - N縊 foi poss?vel conectar-se ao FTP do sistema Ecommerce para o envio do arquivo " + aArquivos[nK,1] + "(Espec?fico Brasitech). ")
			cLog += "N縊 foi poss?vel conectar-se ao FTP do sistema Ecommerce para o envio do arquivo " + aArquivos[nK,1] + cEol
		EndIf
		
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
		// Desconectando do Servidor FTP  
		//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧
		FtpDisconnect()
		MemoWrite(cNomeLog, cLog)

	Next
Endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Envia e-mail com o rela鈬o de notas somente quando gerada a transmiss縊 convencional    
// por meio do "envio" ou "reenvio". E-mail enviado mesmo quando os arquivos n縊 tenham    
// transmitidos para o FTP.                                                                
// Caso seja somente ativada o envio por ftp (op鈬o FTP no menu), o e-mail n縊 ser? gerado 
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if Len(aRelatorio) > 0
	//email no formato html
	cMensagem := '<html>'
	cMensagem += '<font size="2" face="Arial">Segue lista com as notas fiscais carregadas no ftp do sistema de Ecommerce Gama em ' + dTOc(date()) + ', 灣 ' + time() + '.</font><br><br>'

	//Abrindo a tabela
	cMensagem += '<table width="100%" border="1" cellspacing="0" cellpadding="0">'

	//Abrindo a linha do cabe軋lho
	cMensagem += '<tr>'
	cMensagem += '<td width="7%" align="center"><font size="2" face="Calibri"><strong>Nota Fiscal</strong></font></td>'
	cMensagem += '<td width="3%" align="center"><font size="2" face="Calibri"><strong>S駻ie</strong></font></td>'
	cMensagem += '<td width="6%" align="center"><font size="2" face="Calibri"><strong>Emiss縊</strong></font></td>'
	cMensagem += '<td width="25%" align="center"><font size="2" face="Calibri"><strong>Cliente</strong></font></td>'
	cMensagem += '<td width="6%" align="center"><font size="2" face="Calibri"><strong>Tipo Servi輟</strong></font></td>'
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
	
	cErro := U_GISendMail(cDestinat,, "Carregamento de arquivo no ftp Ecommerce Gama em " + dTOc(dDataBase) + " 灣 " + Time(), cMensagem)
	
	if !Empty(cErro)
		ConOUt("Ocorreu o seguinte erro  no envio do N縊 foram localizadas notas fiscais dentro do per?odo informado.Poss?veis causas: N縊 existem NFs no intervalo selecionado ou as NFs j? foram enviadas ao sistema VIPP ou as notas existentes n縊 pertencem ao grupo apto a gerar separa鈬o. (Espec?fico Brasitech). ")	
	endif
endif

Return()
