#include "rwmake.ch"
#include "protheus.ch"

User Function BraJOB03()

//———————————————————————————————————————————————————————————————————————————————
// Abertura do ambiente
//———————————————————————————————————————————————————————————————————————————————
WfPrepEnv("01", "03", "U_BraJOB03",, "FAT")
	
BFATM04()
	
//———————————————————————————————————————————————————————————————————————————————
// Encerramento do ambiente                                                     
//———————————————————————————————————————————————————————————————————————————————
RpcClearEnv()

ConOut(dTOc(Date()) + " as " + Time() + ". Relatorio de Recebimento: Operador Logistico(BraJOB03)")

Return	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Function  ³ BFATM04  ³ Por: Luiz Fernando C Nogueira ³ Data ³22.08.2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz a leitura do arquivo do Operador Logistico referente   ³±±
±±³          ³ confirmação do recebimento das notas de remessa para       ³±±
±±³      enagem 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Brasitech                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function BFATM04()
Local _nY
Private _cArq
Private _cDirNImp  := "" 
Private _cDirImp   := "" 
Private _aInclui   := {}   

// Obtem o diretorios onde estao localizados os arquivos
_cDirNImp  := Getmv('MB_XDIRFTP')
_cDirImp   := Getmv('MB_XDIRFTP')+"IMPORTADOS\"

// Obtem todos os arquivo a serem importados
_aInclui := Directory(Alltrim(_cDirNImp)+"GISCONFREC*TXT")

For _nY := 1 to Len(_aInclui)
	// Obtem o proximo arquivo a ser importado.
	_cArq := _aInclui[_nY][1]
	// Se o tamanho do arquivo for maior que zero importa, caso contrario 
	// somente transfere do diretorio de arquivos a importar para o diretorio de arquivos ja importados.
	If _aInclui[_nY][2] > 0
		BFATM04_A(_cArq)
	Endif
	// Transfere o arquivo para o diretorio de arquivo importados e importa o proximo se existir.
	If File(_cDirNImp+_aInclui[_nY][1])
		Copy File (_cDirNImp+_aInclui[_nY][1]) To (_cDirImp+_aInclui[_nY][1])
		FErase(_cDirNImp+_aInclui[_nY][1])   
	EndIf
Next _nY

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³ BFATM04_A      ³ Autor ³ Luiz Fernando Nogueira   ³ Data ³ 24/02/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Le as notas dos selecionados a serem importados               	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Brasitech 						        				           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function BFATM04_A(_carq)

Local _cBuff  		:= ""
Local _cTpReceb		:= ""
Local _cCNPJ		:= ""
Local _cFilial 		:= ""
Local _cDoc   		:= ""
Local _cSerie 		:= ""
Local _cProduto		:= ""
Local _nQtdNF		:= ""
Local _nQtdRea		:= ""
Local _nQtdAva		:= ""
Local _dReceb  		:= ""
Local aItem			:= {}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre arquivo com documentos de entrada a serem importados ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ft_fuse(_cDirNImp+_cArq)
ft_fgotop()
While !ft_feof()

	_cBuff  := ft_freadln()
	_cReg   := Substr(_cBuff,001,001)

	If _cReg == "0"
		_cCNPJ 		:= Substr(_cBuff,3,14)
		_cTpReceb	:= Substr(_cBuff,32,2)
		_dReceb		:= Substr(_cBuff,34,2)+"/"+Substr(_cBuff,36,2)+"/"+Substr(_cBuff,38,4)
		_cFilial	:= Iif(_cCNPJ = '07293118000102','01','03')
		Do Case
			Case _cTpReceb = "TR"
			_cTpReceb := "Transferência"
			Case _cTpReceb = "CO"
			_cTpReceb := "Compra Local"
			Case _cTpReceb = "IM"
			_cTpReceb := "Importação"
		EndCase
		ft_fskip()
	Endif

	_cBuff  := ft_freadln()
	_cReg   := Substr(_cBuff,001,001)

	If _cReg == "1"
		_cSerie 	:= Substr(_cBuff,002,003)
		_cDoc   	:= Substr(_cBuff,005,009)	
//		Aadd(aCabec,{_cTpReceb,	_cFilial,_cDoc,_cSerie,_dReceb})
		ft_fskip()
	Endif

	_cBuff  := ft_freadln()
	_cReg   := Substr(_cBuff,001,001)
	
	If _cReg == "2"
		While !ft_feof() .and. Substr(_cBuff,001,001) == "2"
			_cProduto	:= Substr(_cBuff,008,025)	
			_nQtdNF		:= val(Substr(_cBuff,095,019))
			_nQtdRea	:= val(Substr(_cBuff,114,019))
			_nQtdAva	:= val(Substr(_cBuff,133,019))
			Aadd(aItem ,{_cTpReceb,	_cFilial,_cDoc,_cSerie,_dReceb,_cProduto,_nQtdNF,_nQtdRea,_nQtdAva})
			ft_fskip()
			_cBuff 	:= ft_freadln()
			_cReg   := Substr(_cBuff,001,001)
		End
	Endif
	
	If _cReg == "9"
		ft_fskip()
	Endif
	
End

ft_fuse()
//Processa({|| EnvMail(aCabec,aItem) },"Aguarde... ")
EnvMail(aItem,_cArq)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ EnvMail 		³ Por: Luiz Fernando C Nogueira ³ Data ³22.08.2014³±±
±±ÃÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EnvMail(aItem,_cArq)
Local cEol		:= chr(13) + chr(10)
Local cDestinat	:= AllTrim(GetMV("BR_BFATM03", .F., "rodrigo.ramos@gamaitaly.com.br"))
Local cMsg		:= ""
Local cLog		:= ""
Local cNomeLog	:= "C:\TEMP\" + StrTran(dTOs(Date()) + "_" + time() + ".LOG", ":", "-")
Local aArquivos	:= {}
Local cTipos, aArqSepar, aArqXML, lUpLoad, nTempo, aArqUpload, nK, nT, nX, cMensagem, cErro



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia e-mail com a relação de notas que foram recebidas no Operador Logistico, com as   ³
//³ confirmacoes de quantidades recebidas e quantidades com avaria                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if Len(aItem) > 0
	//email no formato html
	cMensagem := '<html>'
	cMensagem += '<font size="2" face="Arial">Arquivo: '+_cArq+' .</font><br><br>'
	//Abrindo a tabela
	cMensagem += '<table width="100%" border="1" cellspacing="0" cellpadding="0">'
	//Abrindo a linha do cabeçalho
	cMensagem += '<tr>'
	cMensagem += '<td width="8%" align="center"><font size="2" face="Calibri"><strong>Tipo</strong></font></td>'
	cMensagem += '<td width="4%" align="center"><font size="2" face="Calibri"><strong>Filial</strong></font></td>'
	cMensagem += '<td width="8%" align="center"><font size="2" face="Calibri"><strong>Nota Fiscal</strong></font></td>'
	cMensagem += '<td width="4%" align="center"><font size="2" face="Calibri"><strong>Serie NF</strong></font></td>'
	cMensagem += '<td width="10%" align="center"><font size="2" face="Calibri"><strong>Data</strong></font></td>'
	cMensagem += '<td width="6%" align="center"><font size="2" face="Calibri"><strong>Produto</strong></font></td>'
	cMensagem += '<td width="6%" align="center"><font size="2" face="Calibri"><strong>Qtde Fiscal</strong></font></td>'
	cMensagem += '<td width="6%" align="center"><font size="2" face="Calibri"><strong>Qtde Fisica</strong></font></td>'
	cMensagem += '<td width="6%" align="center"><font size="2" face="Calibri"><strong>Qtde Avaria</strong></font></td>'
	cMensagem += '</tr>'

	//Abrindo a linha dos itens
	for nX := 1 to len(aItem)
		cMensagem += '<tr>'
		cMensagem += '<td width="8%"  align="left"><font size="2" face="Calibri">' 	+ aItem[nX,1] + '</font></td>'
		cMensagem += '<td width="4%"  align="left"><font size="2" face="Calibri">' 	+ aItem[nX,2] + '</font></td>'
		cMensagem += '<td width="8%"  align="left"><font size="2" face="Calibri">' 	+ aItem[nX,3] + '</font></td>'
		cMensagem += '<td width="4%"  align="left"><font size="2" face="Calibri">' 	+ aItem[nX,4] + '</font></td>'
		cMensagem += '<td width="10%" align="center"><font size="2" face="Calibri">'+ aItem[nX,5] + '</font></td>'
		cMensagem += '<td width="6%" align="left"><font size="2" face="Calibri">' 	+ AllTrim(aItem[nX,6]) + '</font></td>'
		cMensagem += '<td width="6%" align="right"><font size="2" face="Calibri">' + Transform(aItem[nX,7],"@E 999,999") + '</font></td>'
		cMensagem += '<td width="6%" align="right"><font size="2" face="Calibri">' + Transform(aItem[nX,8],"@E 999,999") + '</font></td>'
		cMensagem += '<td width="6%" align="right"><font size="2" face="Calibri">' + Transform(aItem[nX,9],"@E 999,999") + '</font></td>'
		cMensagem += '</tr>'
	next
	
	cMensagem += '</table>'
	cMensagem += '</body>'
	cMensagem += '</html>'
	
	cErro := U_GISendMail(cDestinat,, "Relatório de Recebimento - Gama Italy: " + dTOc(dDataBase) + " às " + Time(), cMensagem)
	
	if !Empty(cErro)
		Help(" ", 1, "ATENÇÃO", , "Ocorreu o seguinte erro  no envio do e-mail: " + cEol + cErro + cEol + "(Específico Brasitech). ", 1)	
	endif
endif

Return()
