#include "rwmake.ch"
#include "protheus.ch"

User Function BraJOB03()

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Abertura do ambiente
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
WfPrepEnv("01", "03", "U_BraJOB03",, "FAT")
	
BFATM04()
	
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Encerramento do ambiente                                                     
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
RpcClearEnv()

ConOut(dTOc(Date()) + " as " + Time() + ". Relatorio de Recebimento: Operador Logistico(BraJOB03)")

Return	

/*
ﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜ
ｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱ
ｱｱﾚﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾂﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾂﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾂﾄﾄﾄﾄﾄﾄﾂﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄｿｱｱ
ｱｱｳFunction  ｳ BFATM04  ｳ Por: Luiz Fernando C Nogueira ｳ Data ｳ22.08.2014ｳｱｱ
ｱｱﾃﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾅﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾁﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾁﾄﾄﾄﾄﾄﾄﾁﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄｴｱｱ
ｱｱｳDescricao ｳ Faz a leitura do arquivo do Operador Logistico referente   ｳｱｱ
ｱｱｳ          ｳ confirma鈬o do recebimento das notas de remessa para       ｳｱｱ
ｱｱｳ      enagem 												  ｳｱｱ
ｱｱﾃﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾅﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄｴｱｱ
ｱｱｳUso       ｳ Especifico Brasitech                                       ｳｱｱ
ｱｱﾀﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾁﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾙｱｱ
ｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱ
ﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟ
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
ﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜ
ｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱ
ｱｱﾚﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾂﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾂﾄﾄﾄﾄﾄﾄﾄﾂﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾂﾄﾄﾄﾄﾄﾄﾂﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄｿｱｱ
ｱｱｳFuncao	 ｳ BFATM04_A      ｳ Autor ｳ Luiz Fernando Nogueira   ｳ Data ｳ 24/02/09 ｳｱｱ
ｱｱﾃﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾅﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾁﾄﾄﾄﾄﾄﾄﾄﾁﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾁﾄﾄﾄﾄﾄﾄﾁﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄｴｱｱ
ｱｱｳDescricao ｳ Le as notas dos selecionados a serem importados               	   ｳｱｱ
ｱｱﾃﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾅﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄｴｱｱ
ｱｱｳUso       ｳ Brasitech 						        				           ｳｱｱ
ｱｱﾀﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾁﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾙｱｱ
ｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱ
ﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟ*/
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


//ﾚﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄｿ
//ｳ Abre arquivo com documentos de entrada a serem importados ｳ
//ﾀﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾙ
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
			_cTpReceb := "Transfer麩cia"
			Case _cTpReceb = "CO"
			_cTpReceb := "Compra Local"
			Case _cTpReceb = "IM"
			_cTpReceb := "Importa鈬o"
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
ﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜﾜ
ｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱ
ｱｱﾚﾄﾄﾄﾄﾄﾄﾂﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾂﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾂﾄﾄﾄﾄﾄﾄﾂﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄｿｱｱ
ｱｱｳFuncaoｳ EnvMail 		ｳ Por: Luiz Fernando C Nogueira ｳ Data ｳ22.08.2014ｳｱｱ
ｱｱﾃﾄﾄﾄﾄﾄﾄﾁﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾁﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾁﾄﾄﾄﾄﾄﾄﾁﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄｴｱｱ
ｱｱﾀﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾙｱｱ
ｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱｱ
ﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟﾟ
*/
Static Function EnvMail(aItem,_cArq)
Local cEol		:= chr(13) + chr(10)
Local cDestinat	:= AllTrim(GetMV("BR_BFATM03", .F., "rodrigo.ramos@gamaitaly.com.br"))
Local cMsg		:= ""
Local cLog		:= ""
Local cNomeLog	:= "C:\TEMP\" + StrTran(dTOs(Date()) + "_" + time() + ".LOG", ":", "-")
Local aArquivos	:= {}
Local cTipos, aArqSepar, aArqXML, lUpLoad, nTempo, aArqUpload, nK, nT, nX, cMensagem, cErro



//ﾚﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄｿ
//ｳ Envia e-mail com a rela鈬o de notas que foram recebidas no Operador Logistico, com as   ｳ
//ｳ confirmacoes de quantidades recebidas e quantidades com avaria                          ｳ
//ﾀﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾄﾙ
if Len(aItem) > 0
	//email no formato html
	cMensagem := '<html>'
	cMensagem += '<font size="2" face="Arial">Arquivo: '+_cArq+' .</font><br><br>'
	//Abrindo a tabela
	cMensagem += '<table width="100%" border="1" cellspacing="0" cellpadding="0">'
	//Abrindo a linha do cabe軋lho
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
	
	cErro := U_GISendMail(cDestinat,, "Relat?rio de Recebimento - Gama Italy: " + dTOc(dDataBase) + " 灣 " + Time(), cMensagem)
	
	if !Empty(cErro)
		Help(" ", 1, "ATENﾇﾃO", , "Ocorreu o seguinte erro  no envio do e-mail: " + cEol + cErro + cEol + "(Espec?fico Brasitech). ", 1)	
	endif
endif

Return()
