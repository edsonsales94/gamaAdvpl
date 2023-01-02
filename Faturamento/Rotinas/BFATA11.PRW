/*/                 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BFATA11  ³ Por: Luiz Fernando Nogueira ³  Data  ³ 22/01/15³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina para importacao 									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Brasitech                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

#include "rwmake.ch"
#include "tbiconn.ch"

User Function BFATA11()
Local aButton		:= {}
Local aSay			:= {}
Local nOpc			:= 0
Local cCadastro		:= "Importação de Tabelas de Preço"    
Local aArea			:= GetArea()
Local aAreaDA1		:= DA1->(GetArea())
Local aAreaDA0		:= DA0->(GetArea())
Local aAreaSB1		:= SB1->(GetArea())


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Interface                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd ( aSay , "Importação de atualizações de tabelas de Preço utilizando planilha excel como base" )
aAdd ( aSay , "Atenção: o formato do arquivo deve ser .CSV")

aAdd ( aButton , { 1 , .T. , { || nOpc := 1,	FechaBatch()	}} )
aAdd ( aButton , { 2 , .T. , { || FechaBatch()					}} )

FormBatch( cCadastro , aSay , aButton )

If nOpc == 1

	_cArqTab 	:= cGetFile("Arquivos |*.CSV|Todos os Arquivos|*.*",OemToAnsi("Selecione o arquivo")) //,0,,.T.,GETF_OVERWRITEPROMPT)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verificando se o processo ira ser continuado                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if !File(_cArqTab)

		MsgBox("O arquivo nao foi localizado. O PROCESSO NAO PODERA SER INICIADO.","ATENCAO","ERRO")
		
	ElseIf MsgBox("Confirma importação de tabelas de preço?", "Importação de tabelas de preço", "YESNO" )
		
		Processa( { |lEnd| impcsv(_cArqTab) } , "Importação de tabelas de preço" , "Importando tabelas de preço" , .T. )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ renomeando o arquivo lido                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		fClose( _cArqTab )
		nDotPos := At( ".", _cArqTab )
		if nDotPos > 0
			_cNewArqTab := Substr( _cArqTab, 1, nDotPos ) + "ok"
 			__CopyFile( _cArqTab, _cNewArqTab )
 		endif
		fErase( _cArqTab )
	Else
		MsgBox("O arquivo nao foi localizado. O PROCESSO NAO PODERA SER INICIADO.","ATENCAO","ERRO")
	Endif   

Endif   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a posicao original das areas de trabalho ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea( aAreaSB1 )
RestArea( aAreaDA1 )
RestArea( aAreaDA0 )
RestArea( aArea )
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ Impcsv      ³ Por: Adalberto Moreno Batista ³ Data ³15.05.2011³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function impcsv(_cArqTab)

Local aCampos := {}
Local aDados := {}
Local lPrim	:= .T.

ProcRegua(3) // Numero de processos/sub-processos

//ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
//º 1- Carregando arrays  com os dados do arquivoº
//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼
//ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

IncProc("Realizando leitura do arquivo ...")		//1o.

FT_FUSE(_cArqTab)
FT_FGOTOP()

If !FT_FEOF()
	While !FT_FEOF()
		cLinha := FT_FREADLN()
		If lPrim
			lPrim := .F.
		Else
			AADD(aDados,Separa(cLinha,";",.T.))
		EndIf
		FT_FSKIP()
	EndDo
	FT_FUSE()
	ImpCsv_A(aDados)		
Else
	MsgBox("O arquivo de nome " + AllTrim(_cArqTab) + " está vazio!","Atencao!")
Endif

IncProc("Finalizando processo...")	//3o.
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao³ ImpCsv_A           ³ Por: Adalberto Moreno Batista ³ Data ³15.05.2011³±±
±±ÀÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Posições do array aDados³													 ±±
±±³aDados[x][1] == DA1_CODPRO													 ±±
±±³aDados[x][2] == DA1_DESCRI													 ±±
±±³aDados[x][3] == DA1_PRCVEN													 ±±
±±³aDados[x][4] == DA1_CODTAB													 ±±
±±³aDados[x][5] == DA1_DATVIG													 ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpCsv_A(aDados)
Local x

IncProc("Importando dados ...")		//2o.

For x:=1 to len(aDados)

	SB1->(dbSetOrder(1))
	if SB1->(dbSeek(xFilial("SB1")+allTrim(aDados[x][1])))
		DA1->(dbSetOrder(1))
		if DA1->(dbSeek(xFilial("DA1")+StrZero(val(aDados[x][4]),3)+allTrim(aDados[x][1])))
			Reclock("DA1", .F.)
			DA1->DA1_PRCVEN := val(STRTRAN(aDados[x][3],",","."))
			DA1->DA1_DATVIG	:= Ctod(aDados[x][5])
			DA1->(Msunlock())
		else
			DA0->(dbsetorder(1))
			if DA0->( !dbSeek( xFilial( "DA0")+StrZero(val(aDados[x][4]),3)))
	        	Reclock("DA0",.T.)
	        	DA0->DA0_CODTAB := StrZero(val(aDados[x][4]),3)
				DA0->DA0_DESCRI := "Tabela "+StrZero(val(aDados[x][4]),3)
				DA0->DA0_DATDE 	:= ddatabase
				DA0->DA0_HORADE	:= "00:00"
				DA0->DA0_HORATE	:= "23:59"
				DA0->DA0_TPHORA	:= "1"
				DA0->DA0_ATIVO	:= "2"
				DA0->(msunlock())
			endif
			
			auxItem := "0000" 
			DA1->(dbsetOrder(3))
			DA1->(dbSeek(xFilial("DA1")+StrZero(val(aDados[x][4]),3)))
			do while DA1->(!eof() .and. DA1_CODTAB == StrZero(val(aDados[x][4]),3) )
				auxItem	:= DA1->DA1_ITEM
			DA1->(dbskip())
			enddo
			Reclock("DA1", .T.)
			DA1->DA1_ITEM	:= soma1(auxItem)
			DA1->DA1_CODTAB := StrZero(val(aDados[x][4]),3)
			DA1->DA1_CODPRO := aDados[x][1]
			DA1->DA1_PRCVEN := val(STRTRAN(aDados[x][3],",","."))
			DA1->DA1_DATVIG	:= ctod(aDados[x][5])
			DA1->DA1_ATIVO	:= "1"
			DA1->DA1_TPOPER	:= "4"
			DA1->DA1_QTDLOT	:= 999999.99
			DA1->DA1_INDLOT := "000000000999999.99"
			DA1->DA1_MOEDA	:= 1
			DA1->(Msunlock())
		endif
		Reclock("SZZ", .T.)
		SZZ->ZZ_ITEM 	:= DA1->DA1_ITEM
		SZZ->ZZ_CODTAB  := StrZero(val(aDados[x][4]),3)
		SZZ->ZZ_CODPRO	:= aDados[x][1]
		SZZ->ZZ_PRCVEN	:= val(STRTRAN(aDados[x][3],",","."))
		SZZ->ZZ_DATVIG	:= ctod(aDados[x][5])
		SZZ->ZZ_LOG		:= "Alterado por:"+ SubStr(cUsuario,7,15)+"em:"+ dtoc(ddatabase) +" "+ time() //Nome do Usuario + data do log + hora
		SZZ->(Msunlock())
    endif
Next

Return()