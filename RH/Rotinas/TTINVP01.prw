#include "Protheus.ch"
#include "rwmake.ch"

#DEFINE CGETFILE_TYPE GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE

/*/
+-------------------------------------------------------------------------------+
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ TTINVP01   ¦ Autor ¦Orismar Silva         ¦ Data ¦ 30/12/2022 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ DESCRIÇÃO ¦ Rotina para ler arquivo TXT e gerar o registro no RGB.        ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
+-------------------------------------------------------------------------------+
/*/
User Function TTINVP01()

Local cArq        := Space(100) //GetMV("MV_ARQINV")
Local cPerg       := PadR("TTINVP01", Len(SX1->X1_GRUPO))
Local cArquivo    := Space(50)
Local cArmazem    := Space(1) 
Private cTipo     := "Endereco (*.CSV)        | *.CSV | "
Private cTipo     := cTipo + "Todos os Arquivos (*.csv)   | *.csv     "
Private cxPath    := "P:\CSV\"       
Private nMaskDef  := 1
Private cCaminho  := Space(100)
Private mvpar01   := Space(30)
Private oEndereco


If !(__cUserID $ GetMv("MV_XUSUPRC"))
    MsgStop("Usuário sem permissão para utilizar essa rotina !")
    Return
Endif

@ 304,302 To 479,1061 Dialog oEndereco Title OemToAnsi("Gerar registro")
@ 53,4 To 57,366
@ 14,5 Say OemToAnsi("Arquivo:") Size 25,8 OF oEndereco PIXEL
@ 13,38 MSGET cCaminho Size 250,10 of oEndereco PIXEL When .F.
@ 13,295 Button OemToAnsi("Carregar arquivo CSV") Size 75,16 Action TTINVCSV()
@ 65,319 Button OemToAnsi("Sair") Size 50,16 Action  Close(oEndereco)     

Activate Dialog oEndereco CENTERED


Return


/*/
+-------------------------------------------------------------------------------+
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ TTINVCSV   ¦ Autor ¦Orismar Silva         ¦ Data ¦ 30/12/2020 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ DESCRIÇÃO ¦ Rotina para ler arquivo TXT e gerar o registro no RGB.        ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
+-------------------------------------------------------------------------------+
/*/
Static Function TTINVCSV()

#DEFINE OPEN_FILE_ERROR -1

Private cFile := ( cxPath + RTRIM(mvpar01) + ".CSV" )

IF ( !FILE(cFile) )
   lArq := .F.
   cFile := cGetFile( cTipo,"Selecione arquivo...",@nMaskDef    , cxPath , .T. , CGETFILE_TYPE )
   If Empty(cFile).AND.Empty(mvpar01)
      Aviso("Cancelada a Seleção!","Você cancelou a seleção do arquivo.",{"Ok"})
   Endif
ENDIF   

If FT_FUSE( cFile ) = OPEN_FILE_ERROR
	MSGINFO("Arquivo " + cFile + " não encontrado!")
	Return
Endif

IF ( !EMPTY(cFile) )
   cCaminho := cFile
   oEndereco:Refresh()
   Processa({|lEnd| Importa()}, "Aguarde...", "Importando inventário ....")
ENDIF

Close(oEndereco)
Return   


/*/
+-------------------------------------------------------------------------------+
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Programa  ¦ IMPORTA    ¦ Autor ¦Orismar Silva         ¦ Data ¦ 30/12/2020 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ DESCRIÇÃO ¦ Rotina para ler arquivo TXT e gerar o registro no RGB.        ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
+-------------------------------------------------------------------------------+
/*/

Static Function Importa()

Local cArq     := cFile
Local aFile    := {}
Local cLinha   := ""
Local cSubLin  := ""
Local aLinha   := {}
Local nFile    := 0
Local lincluiu := .F.
Local nLinha   := 0
Local nI       := 0

QOut("Lendo...")
ProcRegua( FT_FLASTREC() )


/*
MODELO DO ARQUIVO
MARTRICULA;VERBA;HORA
999999;242;2
*/

If File(cArq)
	nJ := 0
	FT_FUse(cArq)
	FT_FGOTOP()
    
    // Ler a Primeira linha como cabecalho
    cLinha := FT_FREADLN()

    // Ler a segunda linha, com os campos do cadastro de produtos (B1_)
    FT_FSKIP()              
    cLinha := FT_FREADLN()
    nLinha++                                                  
	
	
	While !FT_FEOF()
		cLinha := FT_FReadLN()
		
		aFile := {}
		//
		// Arquivo TXT separado por ";"
		//
		For nI := 1 to Len(cLinha)+1
			If SubStr(cLinha,nI,1)=Chr(59) .or. SubStr(cLinha,nI,2)=Chr(13)+Chr(10) .or. Len(cLinha)+1=nI
				If Len(cSubLin)=0
				   cSubLin := " "
				EndIF
				aAdd(aLinha,cSubLin)
				cSubLin := ""
			Else
				cSubLin += SubStr(cLinha,nI,1)
			EndIF
			
		Next
		
		aAdd(aFile,array(Len(aLinha)))
		aFile[Len(aFile)] := aClone(aLinha)
		aLinha := {}
		
		FT_FSKIP()
		
		QOut(nJ)
		//  .----------------------------------------.
		// |     Gravação da tabela de inventário     |
		//  '----------------------------------------'
		RGB->(dbSetOrder(1))
		//If !RBG->(dbSeek(XFILIAL("RGB")+aFile[1][3]+aFile[1][1]+aFile[1][2]))
			RGB->(RecLock("RGB",.T.))
			RGB->RGB_FILIAL  := xFILIAL("RGB")
			RGB->RGB_PROCES  := "00001"
			RGB->RGB_PERIOD  := "202211"
			RGB->RGB_SEMANA  := "01" 
			RGB->RGB_ROTEIR  := "FOL"
			RGB->RGB_MAT     :=  STRZERO(VAL(aFile[1][1]),6)
			RGB->RGB_PD      := "242"
			RGB->RGB_TIPO1   := "H"
			RGB->RGB_HORAS   := Val(Alltrim(aFile[1][3]))     
			RGB->RGB_DTREF   := DDATABASE
			RGB->RGB_CC      := POSICIONE("SRA",1,xFilial("SRA")+STRZERO(VAL(aFile[1][1]),6),"RA_CC") 
            RGB->RGB_PARCEL  := 1
            RGB->RGB_TIPO2   := "G"
            RGB->RGB_CODFUN  := POSICIONE("SRA",1,xFilial("SRA")+STRZERO(VAL(aFile[1][1]),6),"RA_CODFUNC")
			RGB->(MsUnlock())
			lincluiu := .T.
		//Endif
        *		
		nJ++
		qout(nJ)
	Enddo
	
	qout("Salvando Dados")
	nFile:=Len(aFile)
	
	If Empty(aFile)
		Alert("Erro ao ler o arquivo")
	endif
	
	FT_FUSE()
Else
	Alert("Arquivo não encontrado")
Endif

If lincluiu = .T.
	MsgBox ("IMPORTAÇÃO REALIZADA COM SUCESSO!!!","IMPORTAÇÃO","YES")
endif

Return



//  .------------------------------------------------.
// |     Inclui grupo de perguntas no arquivo SX1     |
//  '------------------------------------------------'
Static Function CriaSx1() 

PutSX1(cPerg, "01",PadR("Atualizar tabela de",29)+"?","","","mv_ch1","N",1,0,0,"C","","","","","mv_par01","Inventario","","","","")
PutSX1(cPerg, "02",PadR("Custo do Produto   ",29)+"?","","","mv_ch2","N",1,0,0,"C","","","","","mv_par02","Custo Standard","","","","Ult.Preco Compra","","","Custo Medio")

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PutSx1    ³ Autor ³Wagner                 ³ Data ³ 14/02/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria uma pergunta usando rotina padrao                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PutSx1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
	cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,;
	cF3, cGrpSxg,cPyme,;
	cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,;
	cDef02,cDefSpa2,cDefEng2,;
	cDef03,cDefSpa3,cDefEng3,;
	cDef04,cDefSpa4,cDefEng4,;
	cDef05,cDefSpa5,cDefEng5,;
	aHelpPor,aHelpEng,aHelpSpa,cHelp)

LOCAL aArea := GetArea()
Local cKey  := "P."+AllTrim(cGrupo)+AllTrim(cOrdem)+"."
Local lPort := .f.
Local lSpa  := .f.
Local lIngl := .f. 

cPyme    := Iif(cPyme == Nil, " " , cPyme )
cF3      := Iif(cF3 == NIl, " ", cF3 )
cGrpSxg  := Iif(cGrpSxg == Nil, " " , cGrpSxg )
cCnt01   := Iif(cCnt01 == Nil, "",cCnt01 )
cHelp	 := If(cHelp==Nil,"",cHelp)

dbSelectArea("SX1")
dbSetOrder(1)

If !(dbSeek(cGrupo + cOrdem ))

   cPergunt := If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
	cPerSpa	:= If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
	cPerEng	:= If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)

	Reclock("SX1" , .T. )
	Replace X1_GRUPO   With cGrupo
	Replace X1_ORDEM   With cOrdem
	Replace X1_PERGUNT With cPergunt
	Replace X1_PERSPA  With cPerSpa
	Replace X1_PERENG  With cPerEng
	Replace X1_VARIAVL With cVar
	Replace X1_TIPO    With cTipo
	Replace X1_TAMANHO With nTamanho
	Replace X1_DECIMAL With nDecimal
	Replace X1_PRESEL  With nPresel
	Replace X1_GSC     With cGSC
	Replace X1_VALID   With cValid

	Replace X1_VAR01   With cVar01

	Replace X1_F3      With cF3
	Replace X1_GRPSXG  With cGrpSxg

	If Fieldpos("X1_PYME") > 0
		If cPyme != Nil
			Replace X1_PYME With cPyme
		Endif
	Endif

	Replace X1_CNT01   With cCnt01
	If cGSC == "C"			// Mult Escolha
		Replace X1_DEF01   With cDef01
		Replace X1_DEFSPA1 With cDefSpa1
		Replace X1_DEFENG1 With cDefEng1

		Replace X1_DEF02   With cDef02
		Replace X1_DEFSPA2 With cDefSpa2
		Replace X1_DEFENG2 With cDefEng2

		Replace X1_DEF03   With cDef03
		Replace X1_DEFSPA3 With cDefSpa3
		Replace X1_DEFENG3 With cDefEng3

		Replace X1_DEF04   With cDef04
		Replace X1_DEFSPA4 With cDefSpa4
		Replace X1_DEFENG4 With cDefEng4

		Replace X1_DEF05   With cDef05
		Replace X1_DEFSPA5 With cDefSpa5
		Replace X1_DEFENG5 With cDefEng5
	Endif

	Replace X1_HELP  With cHelp

	PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

	MsUnlock()
Else

   lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT)
   lSpa  := ! "?" $ X1_PERSPA  .And. ! Empty(SX1->X1_PERSPA)
   lIngl := ! "?" $ X1_PERENG  .And. ! Empty(SX1->X1_PERENG)

   If lPort .Or. lSpa .Or. lIngl
		RecLock("SX1",.F.)
		If lPort 
         SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?"
		EndIf
		If lSpa 
			SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?"
		EndIf
		If lIngl
			SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?"
		EndIf
		SX1->(MsUnLock())
	EndIf
Endif

RestArea( aArea )

Return
