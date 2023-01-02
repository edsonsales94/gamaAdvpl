#include "rwmake.ch"  
#include "topconn.ch" 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFINR99   ºAutor  ³Osmil Squarcine     º Data ³  23/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Boleto Grafico do Unibanco                                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP10 - Du Jour                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function BolUni

LOCAL   aCampos := {{"E1_NOMCLI","Cliente","@!"},{"E1_PREFIXO","Prefixo","@!"},{"E1_NUM","Titulo","@!"},;
{"E1_PARCELA","Parcela","@!"},{"E1_VALOR","Valor","@E 9,999,999.99"},{"E1_VENCREA","Vencimento"}}
LOCAL   nOpc       := 0
LOCAL   aMarked    := {}
LOCAL   aDesc      := {"Este programa imprime os boletos de","cobranca bancaria de acordo com","os parametros informados"}

PRIVATE Exec       := .F.
PRIVATE cIndexName := ''
PRIVATE cIndexKey  := ''
PRIVATE cFilter    := ''
//Private cPerg    :="RFIN99XXXX"
Private cPerg    := "BOLUNIBAXX"

Private cLogoEmp   	:= "Gama.bmp"
Private cLogoBrd  	:= "Unibanco.bmp"

Tamanho  := "M"
titulo   := "Impressao de Boleto Unibanco"
cDesc1   := "Este programa destina-se a impressao do Boleto Unibanco."
cDesc2   := ""
cDesc3   := ""
cString  := "SE1"
wnrel    := "RFINR02"
lEnd     := .F.
cQuery   := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis tipo Private padrao de todos os relatorios         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }   //"Zebrado"###"Administracao"
nLastKey := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ValidPerg()
Pergunte (cPerg,.F.)

////ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//	³ Faz update do e1_ok para que funcione depois da atualizacao  ³
//	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cQuery := "UPDATE "                         
cQuery := cQuery + RetSQLname("SE1")+" "
cQuery := cQuery + "  SET  E1_OK  = 'CR' "

//TCSQLEXEC(cQuery)                                           

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Envia controle para a funcao SETPRINT                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("SE1")

Wnrel := SetPrint(cString,Wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,,Tamanho,,)

If nLastKey == 27
	Set Filter to
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Set Filter to
	Return
Endif

nOpc := 1

If nOpc == 1
	cIndexName := Criatrab(Nil,.F.)
//	cIndexKey  := 	"E1_PORTADO+E1_CLIENTE+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+DTOS(E1_EMISSAO)"
	cIndexKey  := 	"E1_PORTADO+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+DTOS(E1_EMISSAO)"
	cFilter    := 	"E1_PREFIXO >= '" + MV_PAR01 + "' .And. E1_PREFIXO <= '" + MV_PAR02 + "' .And. " + ;
	"E1_NUM     >= '" + MV_PAR03 + "' .And. E1_NUM     <= '" + MV_PAR04 + "' .And. " + ;
	"E1_PARCELA >= '" + MV_PAR05 + "' .And. E1_PARCELA <= '" + MV_PAR06 + "' .And. " + ;
	"E1_PORTADO >= '" + MV_PAR07 + "' .And. E1_PORTADO <= '" + MV_PAR08 + "' .And. " + ;
	"E1_CLIENTE >= '" + MV_PAR09 + "' .And. E1_CLIENTE <= '" + MV_PAR10 + "' .And. " + ;
	"E1_EMISSAO >= CTOD('" + DTOC(MV_PAR15) + "') .And. E1_EMISSAO <= CTOD('" + DTOC(MV_PAR16) + "') .And. " + ;
	"E1_VENCREA  >= CTOD('" + DTOC(MV_PAR13) + "') .And. E1_VENCREA <= CTOD('" + DTOC(MV_PAR14) + "') .And. "+ ;
	"E1_LOJA    >= '"+MV_PAR11+"' .And. E1_LOJA <= '"+MV_PAR12+"' .And. "+;
	"E1_FILIAL   = '"+xFilial("SE1")+"' .And. E1_SALDO > 0 .And. " + ;
	"SubsTring(E1_TIPO,3,1) != '-' .And. "+;
	"E1_PORTADO = '409'"
	
	IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde selecionando registros....")
	dbSelectArea("SE1")
	
	#IFNDEF TOP
		DbSetIndex(cIndexName + OrdBagExt())
	#ENDIF

	dbGoTop()
	
	If mv_par17 = 1
		@ 001,001 TO 400,700 DIALOG oDlg TITLE "Selecao de Titulos"
		@ 001,001 TO 170,350 BROWSE "SE1" MARK "E1_OK"
		@ 180,310 BMPBUTTON TYPE 01 ACTION (Exec := .T.,Close(oDlg))
		@ 180,280 BMPBUTTON TYPE 02 ACTION (Exec := .F.,Close(oDlg))
		ACTIVATE DIALOG oDlg CENTERED
	EndIf
	
	dbGoTop()
	
	Do While !Eof()
		If Marked("E1_OK")
			AADD(aMarked,.F.)
		Else
			AADD(aMarked,.T.)
		EndIf
		dbSkip()
	EndDo
	
	dbGoTop()
	
	If Exec
		Processa({|lEnd|ImpBolU(aMarked)})
	Endif
	
	RetIndex("SE1")
	FErase(cIndexName+OrdBagExt())
	
EndIf

Return Nil
	
/*/
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Føcao    ¦ImpBolUnib¦ Autor ¦GILDESIO CAMPOS        ¦ Data ¦ 28/11/05 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descricao ¦ BOLETO GRAFICO BANCO UNIBANCO                			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Uso       ¦ Especifico EBH					                          ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
/*/
Static Function ImpBolU(aMarked)
Local yy, xx
Local i         := 1   
Local nRec      := 0

oPrn := TMSPrinter():New()
oPrn:SetPortrait() // ou SetLandscape()
oPrn:StartPage()   // Inicia uma nova página
	                                     
	
oFont1 := TFont():New("Courier New",,08,,.F.,,,,,.F. )
oFont1A:= TFont():New("Courier New",,14,,.T.,,,,,.F. )     	//Negrito
oFont2 := TFont():New("Courier New",,12,,.T.,,,,,.F. )		//Negrito
oFont3 := TFont():New("Times New Roman",,18,,.T.,,,,.T.,.F. )
oFont4 := TFont():New("Courier New",,20,,.T.,,,,,.F. )		//Negrito
oFont5 := TFont():New("Courier New",,24,,.T.,,,,,.F. )    	//Negrito
oFont6 := TFont():New("Courier New",,14,,.T.,,,,,.F. )		//Negrito
oFont7 := TFont():New("Courier New",,08,,.T.,,,,,.F. )		//Negrito

//AADD(aRegs,{PADR(cPerg,10),"21","Banco                ?","","","mv_chl","C",03,0,0,"G","","mv_par21","","","","","","","","","","","","","","","","","","","","","","","","","SA6","","","","","",""})
//AADD(aRegs,{PADR(cPerg,10),"22","Agencia              ?","","","mv_chm","C",05,0,0,"G","","mv_par21","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
//AADD(aRegs,{PADR(cPerg,10),"23","Conta                ?","","","mv_chn","C",10,0,0,"G","","mv_par22","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

dbGoTop()
Do While !EOF()
	nRec := nRec + 1
	dbSkip()
EndDo

dbGoTop()
ProcRegua(nRec)


DbSelectArea("SA6")
DbSetOrder(1)
If !DbSeek( xFilial("SA6") + mv_par21 + mv_par22 + mv_par23 )
	Alert("Banco/Agencia/Conta nao encontrado.")
	Return
Endif

DbSelectArea("SEE")
DbSetOrder(1)
If !DbSeek( xFilial("SEE") + mv_par21 + mv_par22 + mv_par23 + mv_par24 )
	Alert("Arquivo de parametros banco/cnab incorreto. Verifique banco/agencia/conta/sub-conta.")
	Return
Endif

If mv_par21 != "409"
	Alert("Banco invalido. Configuracao valida apenas para Unibanco")
	Return
Endif
Modulo := 11
nValor := 0

Do While !EOF()

//   If !aMarked[i]
 //     DbSkip()
  //    i++
   //   Loop
   //EndIf
   
   If !Marked("E1_OK")
      DbSkip()
      Loop
   Endif   


	_lOk      := .T.
	nValor    := 0
	_cPrefixo := SE1->E1_PREFIXO
	_cNumero  := SE1->E1_NUM
	_cParcela := SE1->E1_PARCELA
	
	While !Eof() .And. xFilial("SE1") == SE1->E1_FILIAL ;
		.And. SE1->E1_PREFIXO <= _cPrefixo ;
		.And. SE1->E1_NUM <= _cNumero ;
		.And. SE1->E1_PARCELA <= _cParcela
		
		DbSelectArea("SA1")
		DbSetOrder(1)
		If !DbSeek( xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA  )
			Alert("Cliente nao encontrado.")
			_lOk := .F.			
			DbSelectArea("SE1")
			SE1->(DbSkip())
			Loop
		Endif
		
		If mv_par26 == 1 .And. !Empty(SE1->E1_NUMBCO)
			Alert("Titulo " +SE1->E1_PREFIXO+"-"+SE1->E1_NUM+"-"+SE1->E1_PARCELA+" ja foi impresso."+;
			"Utilize 're-impressao = sim'")
			_lOk := .F.
			DbSelectArea("SE1")
			SE1->(DbSkip())
			Loop
		Endif
		
		If mv_par26 == 2 .And. Empty(SE1->E1_NUMBCO)
			Alert("Titulo "+SE1->E1_PREFIXO+"-"+SE1->E1_NUM+"-"+SE1->E1_PARCELA+" ainda nao foi impresso."+;
			"Utilize 're-impressao = nao'")
			_lOk := .F.
			DbSelectArea("SE1")
			SE1->(DbSkip())
			Loop
		Endif
		
		If Substr(SE1->E1_TIPO,3,1) == "-"
			nValor -= SE1->E1_VALOR
		Else
			nRecNF := SE1->(Recno())
			nValor += SE1->E1_VALOR
		Endif
		
		DbSelectArea("SE1")
		SE1->(DbSkip())
	Enddo
	
	If !_lOk
		Loop
	Endif
	
	SE1->(DbSkip(-1))
	aAliasSE1 := {Alias(),IndexOrd(),SE1->(Recno())}
	
	
	If nLastKey == 27
		Set Filter to
		Return
	Endif
	
	
	nValLiq := nValor
	cValor  := StrZero(100 * (nValor),10)
	nValor  := 0
	
	cEnd1 := IIf(!Empty(SA1->A1_ENDCOB),SA1->A1_ENDCOB+" - "+SA1->A1_BAIRROC,SA1->A1_END+" - "+SA1->A1_BAIRRO)
	cEnd2 := IIf(!Empty(SA1->A1_MUNC),SA1->A1_MUNC+" - "+SA1->A1_ESTC,SA1->A1_MUN+" - "+SA1->A1_EST)
	cCep  := IIf(!Empty(SA1->A1_CEPC),SA1->A1_CEPC,SA1->A1_CEP)
	
	_cNome   := SA6->A6_NOME
	_cNReduz := "UNIBANCO"
	_cIdBco  := "409-0"
	//---Agencia
	_cAgenc   := Alltrim(SA6->A6_AGENCIA)
	//	_cTam     := Len(Alltrim(SA6->A6_AGENCIA))
	// _cAgencia := Strzero(Val(Substr(_cAgenc,1,_cTam - 1)),5)  //Codigo da agencia sem DV
	//_cAgencia := _cAgenc  //Codigo da agencia sem DV
//	_cAgencDv := Alltrim(SA6->A6_DIGAG) //"3" //Right(_cAgenc,1)                             //DV da Agencia Wilder
//	_cAgencDv := "9"

	_cAgencDv := Alltrim( SA6->A6_DIGAG ) // Alterado em 13/04 para Ajuste do Conteúdo fixo no Digito da Agencia.

	//---Conta Corrente
	_cContaC  := Alltrim(SA6->A6_NUMCON)
	_cTam     := Len(Alltrim(SA6->A6_NUMCON))
	_cConta   := Strzero(Val(Substr(_cContaC,1,_cTam - 1)),7)  //Codigo da conta sem DV
	_cContaDv := Right(_cContaC,1)                             //DV da Conta
	cSubConta := mv_par24				// ""
	
	nCodEmp := Val(SUBSTR(AllTrim(SEE->EE_CODEMP),1,6))
	cCodEmp := StrZero(nCodEmp,4)
	
	_cCartei  := "04"
	_cInstr1  := ""
	_cInstr2  := ""
	_cCedent  := Substr(SM0->M0_NOMECOM,1,40)     	//"UNIBANCO"
	_cSacador := Substr(SM0->M0_NOMECOM,1,40)
	_cUsoBco  := "Cod. Transacao CVT      5539-5"
//	_cCodCed  := _cAgenc+"-"+_cAgencDv+"/"+_cConta+"-"+_cContaDv
	_cCodCed  := _cAgenc+"/"+_cConta+"-"+_cContaDv
	
	_Banco   := "409"
//	_Agencia := _cAgenc +_cAgencDv
	_Agencia := _cAgenc
	_Moeda   := "9"
	
	If mv_par26 == 1          //Reimpressao - 1.Nao 2.Sim
		
		If Empty(SEE->EE_FAXATU)
			RecLock("SEE",.F.)
			SEE->EE_FAXATU := Substr(SEE->EE_FAXINI,1,10)
			MsUnLock()
		Endif
		//- O NossoNumero deve ser IMPRESSO: 1/NNNNNNNNNND/S  -->N-Nosso Numero  D-Digito  S-Super Digito Verificador
	 //	_nNumfaix := Val( Substr(SEE->EE_FAXATU,1,10) )// + 1
//		cNossoNum := StrZero(_nNumfaix,10)
		cNossoNum := Substr (SEE->EE_FAXATU, 1, 10) 
		
	   /*			
		If _nNumfaix > Val(Substr(SEE->EE_FAXFIM,1,10))
			// Alert("O nosso numero atingiu a faixa maxima permitida. A sequencia sera reiniciada.")
			// Reinicia automaticamente
			_nNumfaix := 1
			cNossoNum := StrZero(_nNumfaix,10)				  //Alltrim(SEE->EE_FAXINI)
		Endif
		 */
	   /*	RecLock("SEE",.F.)
		SEE->EE_FAXATU := cNossoNum
		 MsUnLock()
		 */
		 	RecLock ("SEE", .F.)	// Atualiza o "Nosso Numero" no cadastro de parametros do banco.
		Replace	SEE -> EE_FAXATU  With StrZero (Val (cNossoNum) + 1, 10)
		SEE -> (MsUnlock ())
		
	Else
		SE1->(DbGoto(nRecNF))
		cNossoNum := Substr(SE1->E1_NUMBCO,1,10)     //Alltrim(SE1->E1_NUMBCO)
	Endif
	
	// Calculo do fator
	_dVencto := SE1->E1_VENCREA
  //	_dBase   := CtoD("03/10/2000")
	//_cFator  := STR(INT(_dVencto - _dBase),4)
	
	_cDia    := StrZero(Day(_dVencto),2)		//Day(SE1->E1_VENCREA)
	_cMes    := StrZero(Month(_dVencto),2) 		//Month(SE1->E1_VENCREA)
	_cAno    := StrZero(Year(_dVencto),4)		//Year(SE1->E1_VENCREA)
	_cTotal  := _cDia+"/"+_cMes+"/"+_cAno
	_cVencto := Substr(_cAno,3,2) + _cMes + _cDia
	
	_cDia1   := StrZero(Day(SE1->E1_EMISSAO),2)
	_cMes1   := StrZero(Month(SE1->E1_EMISSAO),2)
	_cAno1   := StrZero(Year(SE1->E1_EMISSAO),4)
	_cTotal1 := _cDia1+"/"+_cMes1+"/"+_cAno1
	
	_cDia2   := StrZero(Day(dDatabase),2)
	_cMes2   := StrZero(Month(dDatabase),2)
	_cAno2   := StrZero(Year(dDatabase),4)
	_cTotal2 := _cDia2+"/"+_cMes2+"/"+_cAno2
	  
    
	// Calculo do "Fator de Vencimento", conforme manual do Bacno.
	cFatVenc := StrZero (SE1 -> E1_VENCREA - ctod ("07/10/1997"), 4)	  
	  
	// Nosso numero formato Unibanco
	cNN := cNossoNum
	
	//Calculo do digito verificador do nosso numero banco Unibanco - Modulo 11
	_StrMult := "234567892345"
	_BaseDiv := 0
	nPos :=Len(cNN)
	For yy:= 1 To Len(cNN)   //10 posicoes do nosso numero
		_BaseDiv := _BaseDiv + Val(Substr(cNN,nPos,1)) * Val(Substr(_StrMult,yy,1))
        nPos:=nPos-1
	Next yy
	
	_BaseDiv :=	( _BaseDiv * 10 )
	_cNnDv := Mod(_BaseDiv,11)      		//Digito Verificador de Nosso Numero
	
	If _cNnDv == 10  .or. _cNnDv == 0
		_cNnDv := "0"
	Else
		_cNnDv := StrZero(_cNnDv,1)
	Endif
	
	//Calculo do super digito verificador - Modulo 11
	_BaseDiv := 0
	cNN := "1" + cNossoNum + _cNnDv                // 1NNNNNNNNNNDS
	nPos :=Len(cNN)	
	For yy:= 1 To Len(cNN)   //11
		_BaseDiv := _BaseDiv + Val(Substr(cNN,nPos,1)) * Val(Substr(_StrMult,yy,1))
        nPos:=nPos-1
	Next yy
	
	_BaseDiv :=	( _BaseDiv * 10 )
	_cNnSDv := Mod(_BaseDiv,11)      		//Super Digito Verificador de Nosso Numero
	
	If _cNnSDv == 10 .or. _cNnSDv == 0
		_cNnSDv := "0"
	Else
		_cNnSDv := StrZero(_cNnSDv,1)
	Endif
	
	cImpNNum  := "1/" + cNossoNum + _cNnDv + "/" + _cNnSDv
	//cNossoNum := cNossoNum  + _cNnDv + _cNnSDv    	//-- NNNNNNNNNNDS
	
	//Grava NossoNumero no arquivo SE1
	If mv_par26 == 1
		RecLock("SE1",.F.)
		SE1->E1_NUMBCO	:=	cNossoNum  + _cNnDv + _cNnSDv    //NNNNNNNNNNDS
		MsUnLock()
	Else
		cNossoNum := Substr(AllTrim(SE1->E1_NUMBCO),1,12)
	Endif
	/*
	--------------------------------------------------------------------------
	CALCULO DO CODIGO DE BARRAS - MODULO 11
	--------------------------------------------------------------------------*/
       	StrMult := "2345678923456789234567892345678923456789234"
      //  StrMult := "23456789234567892345678923456789234567 9234"            	
	If mv_par26 == 1
		sBarra  := _Banco +_Moeda+cFatVenc+cValor+"04"+_cVencto +_cAgenc +_cAgencDv+ cNossoNum + _cNnDv + _cNnSDv
	Else
		sBarra  := _Banco +_Moeda+cFatVenc+cValor +"04"+_cVencto+_cAgenc +_cAgencDv+ cNossoNum 	//Reimpressao
	EndIf
	BaseDiv := 0
	nPos :=Len(sBarra)
	For xx := 1 To Len(sBarra)
    	BaseDiv := BaseDiv + Val(Substr(sBarra,nPos,1)) * Val(Substr(StrMult,xx,1))
//		BaseDiv := BaseDiv + Val(Substr(sBarra,nPos,1)) * Val(Substr(StrMult,nPos,1))
	    nPos:=nPos-1
	Next xx
	BaseDiv := ( BaseDiv * 10 )
	cBar1Dv := Mod(BaseDiv,11)      		//Digito Verificador de Nosso Numero
	
	If cBar1Dv == 0 .Or. cBar1Dv == 1 .Or. cBar1Dv == 10
		cBar1Dv := "1"
	Else
		cBar1Dv := StrZero(cBar1Dv,1)
	Endif
	
	If mv_par26 == 1
		sBarra  := _Banco +_Moeda+cBar1Dv+cFatVenc+cValor+"04"+_cVencto +_cAgenc +_cAgencDv+ cNossoNum + _cNnDv + _cNnSDv
	Else
		sBarra  := _Banco +_Moeda+cBar1Dv+cFatVenc+cValor+"04"+_cVencto+_cAgenc +_cAgencDv+ cNossoNum 	//Reimpressao
	EndIf
	Barra  := AllTrim(sBarra)
	/*
	--------------------------------------------------------------------------
	CALCULO DA LINHA DIGITAVEL - IPTE   - MODULO 10
	--------------------------------------------------------------------------*/
	cLDG1 := _Banco + _Moeda + "04" + Substr(_cVencto,1,3)  							//Linha Digitavel Grupo 1
	cLDG2 := Substr(_cVencto,4,3) + _cAgenc + _cAgencDv + Subst(cNossoNum,1,2)		//Linha Digitavel Grupo 2
	
	If mv_par26 == 1
		cLDG3 := Right(cNossoNum,8) + _cNnDv + _cNnSDv									//Linha Digitavel Grupo 3
	Else
		cLDG3 := Right(cNossoNum,10)													//Reimpressao - Linha Digitavel Grupo 3
	Endif
	
	cLDG4 := cBar1Dv																	//Linha Digitavel Grupo 4
	cLDG5 := cFatVenc + cValor															//Linha Digitavel Grupo 5

    

	cLDV1 := CalcDvMod10(cLDG1)
	cLDV2 := CalcDvMod10(cLDG2)
	cLDV3 := CalcDvMod10(cLDG3)

	cLinDig := Substr(cLDG1,1,5) + "." + Substr(cLDG1,6) + cLDV1 + Space(1)
	cLinDig += Substr(cLDG2,1,5) + "." + Substr(cLDG2,6) + cLDV2 + Space(1)
	cLinDig += Substr(cLDG3,1,5) + "." + Substr(cLDG3,6) + cLDV3 + Space(1)
	cLinDig += cLDG4 + Space(1) + cLDG5
	
	Imprbjs(oPrn)
	
	DbSelectArea(aAliasSE1[1])
	DbSetOrder(aAliasSE1[2])
	DbGoTo(aAliasSE1[3])
	
	ProcessMessages()
	DbSelectArea("SE1")
	SE1->(DbSkip())
//	i := i + 1
	
Enddo

oPrn:EndPage()     // Finaliza a página
oPrn:Setup()     // Seta a Impressora
oPrn:Preview()     // Visualiza antes de imprimir


Return

/*/
	_____________________________________________________________________________
	¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
	¦¦+-----------------------------------------------------------------------+¦¦
	¦¦¦Funcao    ¦ Imprbjs ¦ Autor ¦ Fernando de Almeida     ¦ Data¦ 30/11/05 ¦¦¦
	¦¦+----------+------------------------------------------------------------¦¦¦
	¦¦¦Descricao ¦ Impressao do boleto bancario.				              ¦¦¦
	¦+----------+-------------------------------------------------------------¦¦¦
	¦¦¦Uso       ¦ Exclusivo CNA                   					                      ¦¦¦
	¦¦+----------+------------------------------------------------------------¦¦¦
	¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
	¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	/*/
	Static Function Imprbjs(oPrn)
	Local i
	If mv_par25 == 1	// Impressao Total / Parcial
		_nValor1 := SE1 -> E1_VALOR
	Else
		_nValor1 := SE1 -> E1_SALDO
	EndIf
	
	
    nMulta := If ( MV_PAR19 == 0 , SEE->EE_XMULT , MV_PAR19 )
    nMora  := If ( MV_PAR20 == 0 , SEE->EE_XMORA , MV_PAR20 )
	nJuros := Round (Round (_nValor1 * (nMora/100), 2) / 30, 2)    
	nDiasProt := SEE->EE_XPROT

//	oPrn := ReturnPrtObj()
//	oPrn :StartPage()
	
	_nLin := -70
	
	//For i:= 1 to 3
	For i:= 1 to 2


        oPrn:SayBitmap(_nLin + 080,010,cLogoBrd,340,090)		// Imprime o Logo do Banco//AQUI
//        oPrn:SayBitmap(_nLin + 0600,700 ,cLogoEmp,400,300)	// Imprime o Logo da Opus - Marca D'agua//AQUI

//		oPrn:Say(_nLin+100,0020,_cNReduz,oFont1A,100)
		oPrn:Box(_nLin+100,0360,_nLin+175,0361) 
		oPrn:Say(_nLin+098,0367,_cIdBco,oFont4,100)
		oPrn:Box(_nLin+100,0540,_nLin+175,0541)

		If i > 1
			oPrn:Say(_nLin+110,0545,cLinDig,oFont6,100)
			
		Endif
		
		oPrn:Box(_nLin+180,0000,_nLin+260,1650) // Local Pagamento
		oPrn:Box(_nLin+180,1650,_nLin+260,2200) // Vencimento
		oPrn:Say(_nLin+190,0020,"Local de Pagamento: " + "Até o vencimento, pagável em qualquer banco. Após o vencimento," ,oFont1,100)
		oPrn:Say(_nLin+220,0350,"em qualquer agencia Unibanco mediante consulta no sistema VC" ,oFont1,100)
		oPrn:Say(_nLin+180,1660,"Vencimento  ",oFont1,100)
		oPrn:Say(_nLin+210,1660,"        " + _cTotal,oFont2,100)
		
		oPrn:Box(_nLin+260,0000,_nLin+340,1650) // Cedente
		oPrn:Box(_nLin+260,1650,_nLin+340,2200) // Agencia / Codigo Cedente
		oPrn:Say(_nLin+260,0020,"Cedente",oFont1,100)
		oPrn:Say(_nLin+260,1660,"Agência/Código Cedente",oFont1,100)
		oPrn:Say(_nLin+300,0020,_cCedent,oFont1,100) // Cedente
		oPrn:Say(_nLin+300,1660,_cCodCed,oFont1,100) // Agencia / Codigo Cedente
		
		oPrn:Box(_nLin+340,0000,_nLin+420,0500) // Data do Documento
		oPrn:Box(_nLin+340,0500,_nLin+420,0800) // Numero do Documento
		oPrn:Box(_nLin+340,0800,_nLin+420,1100) // Especie Doc.
		oPrn:Box(_nLin+340,1100,_nLin+420,1300) // Aceite
		oPrn:Box(_nLin+340,1300,_nLin+420,1650) // Dia Processamento
		oPrn:Box(_nLin+340,1650,_nLin+420,2200) // Nosso numero
		
		oPrn:Say(_nLin+340,0020,"Data do Documento",oFont1,100) // Data do Documento
		oPrn:Say(_nLin+340,0520,"No.Documento",oFont1,100) // Numero do Documento
		oPrn:Say(_nLin+340,0820,"Espécie Doc.",oFont1,100) // Especie Doc.
		oPrn:Say(_nLin+340,1120,"Aceite",oFont1,100) // Aceite
		oPrn:Say(_nLin+340,1320,"Data Processamento",oFont1,100) // Dia Processamento
		oPrn:Say(_nLin+340,1660,"Nosso Número",oFont1,100) // Nosso numero
		
		oPrn:Say(_nLin+380,0020,_cTotal1,oFont1,100) // Data do Documento
		oPrn:Say(_nLin+380,0520,SE1->E1_NUM + " " + SE1->E1_PARCELA,oFont1,100) // Numero do Documento
		oPrn:Say(_nLin+380,0820,"DM",oFont1,100) // Especie Doc.
		oPrn:Say(_nLin+380,1120,"Nao",oFont1,100) // Aceite
		oPrn:Say(_nLin+380,1320,_cTOTAL2,oFont1,100) // Dia Processamento
		oPrn:Say(_nLin+380,1660,"         " + cImpNNum,oFont1,100) // Nosso numero
		
		oPrn:Box(_nLin+420,0000,_nLin+500,0400) // No. Conta
		oPrn:Box(_nLin+420,0400,_nLin+500,0700) // Carteira
		oPrn:Box(_nLin+420,0700,_nLin+500,1000) // Especie Moeda
		oPrn:Box(_nLin+420,1300,_nLin+445,1303) // Quantidade
        oPrn:Box(_nLin+480,1300,_nLin+500,1303) // Valor
//		oPrn:Box(_nLin+499,1000,_nLin+501,1650) // Linha para fechar
		oPrn:Say(_nLin+450,1300,"X",oFont1,100) // Sinal de X
		oPrn:Box(_nLin+420,1650,_nLin+500,2200) // Valor do Documento
		
		oPrn:Say(_nLin+420,0020,"Uso Banco",oFont1,100) // Uso Banco
		oPrn:Say(_nLin+420,0420,"Carteira",oFont1,100) // Carteira
		oPrn:Say(_nLin+420,0720,"Espécie Moeda",oFont1,100) // Especie Moeda
		oPrn:Say(_nLin+420,1020,"Quantidade",oFont1,100) // Quantidade
		oPrn:Say(_nLin+420,1320,"Valor",oFont1,100) // Valor
		oPrn:Say(_nLin+420,1670,"(=) Valor do Documento",oFont1,100) // Valor do documento
		
		oPrn:Say(_nLin+460,0420,_cCartei,oFont1,100) // Carteira
		oPrn:Say(_nLin+460,0720,"R$",oFont1,100) // Especie Moeda
		If mv_par25 == 1	// Impressao Total / Parcial
			oPrn:Say(_nLin+460,1720,Transform(nValLiq,PesqPict("SE1","E1_VALOR")),oFont1,100) // Valor do documento
		Else
			oPrn:Say(_nLin+460,1720,Transform(nValLiq,PesqPict("SE1","E1_SALDO")),oFont1,100) // Valor do documento
		EndIf
		oPrn:Box(_nLin+500,0000,_nLin+900,2200) // Instrucoes para o banco
		oPrn:Box(_nLin+500,1650,_nLin+580,2200) // (-)Desconto/Abatimento
		
		oPrn:Say(_nLin+500,1670,"(-) Desconto/Abatimento",oFont1,100) // (-)Desconto/Abatimento
		oPrn:Say(_nLin+500,0020,"Instruções: (Todas as informações deste boleto são de exclusiva responsabilidade do cedente)",oFont1,100) // Instrucoes para o banco
		If SE1->E1_DESCONT > 0
			oPrn:Say(_nLin+540,1720,Transform(SE1->E1_DESCONT,PesqPict("SE1","E1_SALDO")),oFont1,100) // Valor do abatimento
		Endif
		
		oPrn:Box(_nLin+580,1650,_nLin+660,2200) // (-)Outras Deduções
		
		oPrn:Say(_nLin+580,1670,"(-) Outras Deduções",oFont1,100) // (-)Outras Deduções
		oPrn:Say(_nLin+550,0020,"Após o Vencimento",oFont1,100)
		oPrn:Say(_nLin+550,1000,"Nota Fiscal/Parcela",oFont1,100)
		//	nJuros := ((12/30)/100) * SE1->E1_VALOR
		//	oPrn:Say(_nLin+570,0840,Transform(nJuros,PesqPict("SE1","E1_SALDO")),oFont1,100)
		
		//		oPrn:Say (0515 + _nAjuste,0010, "Multa (Percentual)........: " + Transform (nMulta, "@E 999.99") + "%", oFont5, 100)
		//    	oPrn:Say (0515 + _nAjuste,1850,Transform (_nDesc, "@E@Z 999,999,999,999.99"), oFont4, 100)   // Impressao do desconto
		//		oPrn:Say (0555 + _nAjuste,0010, "Mora Diária (Percentual)..: " + Transform (nMora, "@E 999.99") + "% ao mês", oFont5, 100)
		//		oPrn:Say (0595 + _nAjuste,0010, "Valor Mora................: R$ " + Alltrim (Transform (nJuros, "@E 99,999,999.99")) + " por dia de atraso.", oFont5, 100)
		//		If ! Empty (nDiasProt) .and. Val (nDiasProt) <> 0
		//			oPrn:Say (0645 + _nAjuste,0010, "PROTESTAR APÓS " + Alltrim (nDiasProt) + " DIAS DO VENCIMENTO", oFont5, 100)
		
		oPrn:Say(_nLin+590,0020,"Multa (Percentual)........: " + Transform (nMulta, "@E 999.99") + "%", oFont1, 100)
		oPrn:Say(_nLin+590,1000,(SE1->E1_NUM)+"/"+(SE1->E1_PARCELA), oFont1, 100)
		oPrn:Say(_nLin+620,0020,"Mora Diária (Percentual)..: " + Transform (nMora, "@E 999.99") + "% ao mês", oFont1, 100)
		oPrn:Say (_nLin+650,0020, "Valor Mora................: R$ " + Alltrim (Transform (nJuros, "@E 99,999,999.99")) + " por dia de atraso.", oFont1, 100)
		oPrn:Say(_nLin+680,0020,"PROTESTAR APÓS " + StrZero (nDiasProt,2) + " DIAS DO VENCIMENTO", oFont1, 100)

		oPrn:Say(_nLin+740,0020,Alltrim(MV_PAR27), oFont1, 100)
		oPrn:Say(_nLin+770,0020,Alltrim(MV_PAR28), oFont1, 100)
		oPrn:Say(_nLin+800,0020,Alltrim(MV_PAR29), oFont1, 100)
		
		If SE1->E1_DESCFIN > 0
			nDescFin := SE1->E1_VALOR*(SE1->E1_DESCFIN/100)
			_cInstr1 := "Conceder desconto de R$ "+Transform(nDescFin,PesqPict("SE1","E1_SALDO"))+" ate o vencimento."
		Endif
		oPrn:Say(_nLin+630,0020,_cInstr1,oFont1,100) // Primeira Instrucao
		oPrn:Say(_nLin+640,0020,_cInstr2,oFont1,100) // Segunda Instrucao
		
		oPrn:Box(_nLin+660,1650,_nLin+740,2200) // (-)Mora/Multa
		oPrn:Say(_nLin+660,1670,"(+) Mora/Multa",oFont1,100) // (-)Mora/Multa
		
		oPrn:Box(_nLin+740,1650,_nLin+820,2200) // (-)Outros Acrescimos
		oPrn:Say(_nLin+740,1670,"(+)Outros Acréscimos",oFont1,100) // (-)Outros Acrescimos
		
		oPrn:Box(_nLin+820,1650,_nLin+900,2200) // (=)Valor Cobrado
		oPrn:Say(_nLin+820,1670,"(=) Valor Cobrado",oFont1,100) // (=)Valor Cobrado
		
		oPrn:Box(_nLin+900,0000,_nLin+1060,2200) // Sacado
		oPrn:Say(_nLin+900,0020,"Sacado ",oFont1,100)
		oPrn:Say(_nLin+900,1670,"Cod. Transacao CVT     5539-5",oFont1,100) // Cobranca com registro no Unibanco
		oPrn:Say(_nLin+930,0020,SA1->A1_NOME,oFont1,100)
		
		If Len(AllTrim(SA1->A1_CGC))==11
			oPrn:Say(_nLin+940,1180,"CPF "+Transform(SA1->A1_CGC,"@R 999.999.999-99"),oFont1,100)
		Else
			oPrn:Say(_nLin+940,1180,"CNPJ "+Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),oFont1,100)
		Endif
		
		oPrn:Say(_nLin+960,0020,cEnd1,oFont1,100)
		oPrn:Say(_nLin+990,0020,Transform(cCep,"@R 99999-999")+"   "+cEnd2,oFont1,100)
		oPrn:Say(_nLin+1020,0020,"Sacador/Avalista: "+_cSacador,oFont1,100)
		
		If i > 1
			
			oPrn:Say(_nLin+1080,1300,"  Autenticação Mecânica",oFont1,100)
/*			
			if i = 2
				oPrn:Say(_nLin+1110,0020, Replicate("-",84),oFont2)
			endif
*/			

				oPrn:Say(_nLin+1080,1820,"  Ficha de Compensação",oFont7,100)
				
			
			
			if i = 2
				/*
				MSBAR("INT25"   ,; //01 cTypeBar - String com o tipo do codigo de barras ("EAN13","EAN8","UPCA","SUP5","CODE128","INT25","MAT25,"IND25","CODABAR","CODE3_9")
				26.5      ,; //02 nRow	 - Numero da Linha em centimentros
				1      ,; //03 nCol	 - Numero da coluna em centimentros
				Barra     ,; //04 cCode	 - String com o conteudo do codigo
				oPrn      ,; //05 oPr		 - Objecto Printer
				.F.       ,; //06 lcheck	 - Se calcula o digito de controle
				Nil       ,; //07 Cor 	 - Numero da Cor, utilize a "common.ch"
				.T.       ,; //08 lHort	 - Se imprime na Horizontal
				0.02185     ,; //09 nWidth	 - Numero do Tamanho da barra em centimetros
				1.10      ,; //10 nHeigth	 - Numero da Altura da barra em milimetros
				Nil       ,; //11 lBanner	 - Se imprime a linha em baixo do codigo
				Nil	    ,; //12 cFont	 - String com o tipo de fonte
				Nil       ,; //13 cMode	 - String com o modo do codigo de barras CODE128
				.F.        ) //14 lImprime - Imprime direto sem preview
				*/

    		  
//				MSBAR3("INT25",21.7,1.0,Barra,oPrn,.F.,,,,1.2,,,,.F.)
				MSBAR3("INT25",18.7,1.0,Barra,oPrn,.F.,,,,1.2,,,,.F.)
					
//				oPrn:EndPage() 
//				oPrn:Preview()  
			endif
		Else
			oPrn:Say(_nLin+1080,1300,"      Autenticação Mecânica",oFont1,100)
			oPrn:Say(_nLin+103, 1500,"      RECIBO DO SACADO",oFont2,100)
			oPrn:Say(_nLin+1110,0020, Replicate("-",84,oFont1))
		Endif
//		IF i  >= 3
//			_nLin := _nLin + 1960
//		else
			_nLin := _nLin +  1060
//		endif
	Next i       
	
	oPrn:EndPage() 
//	oPrn:Preview()  

	Return
	/*/
	_____________________________________________________________________________
	¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
	¦¦+-----------------------------------------------------------------------+¦¦
	¦¦¦Funcao    ¦ _Digito   ¦ Autor ¦  Luis Brandini   ¦   Data  ¦  20/09/04 ¦¦¦
	¦¦+----------+------------------------------------------------------------¦¦¦
	¦¦¦Descricao ¦ Calcula digito.											  ¦¦¦
	¦+----------+-------------------------------------------------------------¦¦¦
	¦¦¦Uso       ¦ Especifico EBH					                          ¦¦¦
	¦¦+----------+------------------------------------------------------------¦¦¦
	¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
	¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	/*/
	
	Static Function CalcDvMod10(xGrupo) 

	Local xRetDv  := ""
	Local nRetDv, w, x
	Local xUmDois := 2
	Local nCnt , nSomaX
	Local nSoma   := 0 
	nCnt :=Len(xGrupo)
/*	
	For nCnt := 1 To Len(xGrupo)
		nProduto := ( Val(Substr(xGrupo,nCnt,1)) * xUmDois )
		
		//	If Len(Alltrim(Str(nProduto))) > 1
		If nProduto > 9
			nSomaX   := 0
			xProduto := Alltrim(Str(nProduto))
			For x := 1 To Len(xProduto)
				nSomaX := nSomaX + Val(Substr(xProduto,x,1))
			Next
			nSoma := nSoma + nSomaX
		Else
			nSoma := nSoma + nProduto
		EndIf
		
		If xUmDois == 2
			xUmDois := 1
		Else
			xUmDois := 2
		EndIf
	Next nCnt
*/	

	For w := 1 To Len(xGrupo)
		nProduto := ( Val(Substr(xGrupo,nCnt,1)) * xUmDois )
		
		//	If Len(Alltrim(Str(nProduto))) > 1
		If nProduto > 9
			nSomaX   := 0
			xProduto := Alltrim(Str(nProduto))
			For x := 1 To Len(xProduto)
				nSomaX := nSomaX + Val(Substr(xProduto,x,1))
			Next
			nSoma := nSoma + nSomaX
		Else
			nSoma := nSoma + nProduto
		EndIf
		
		If xUmDois == 2
			xUmDois := 1
		Else
			xUmDois := 2
		EndIf
	    nCnt :=nCnt-1
	Next w


	nRetDv := Mod(nSoma,10)
	nRetDv := 10 - nRetDv
	
	If nRetDv == 10
		xRetDv := "0"
	Else
		xRetDv := StrZero(nRetDv,1)
	EndIf
	
	Return(xRetDv)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa    ³ CriaSx1  ³ Verifica e cria um novo grupo de perguntas com base nos      º±±
±±º             ³          ³ parâmetros fornecidos                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Solicitante ³ 23.05.05 ³ Modelagem de Dados                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Produção    ³ 99.99.99 ³ Ignorado                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parâmetros  ³ ExpA1 = array com o conteúdo do grupo de perguntas (SX1)                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno     ³ Nil                                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Observações ³                                                                         º±±
±±º             ³                                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Alterações  ³ 99/99/99 - Consultor - Descricao da alteração                           º±±
±±º             ³                                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CriaSx1(aRegs)

Local aAreaAtu	:= GetArea()
Local aAreaSX1	:= SX1->(GetArea())
Local nJ		:= 0
Local nY		:= 0

dbSelectArea("SX1")
dbSetOrder(1)

For nY := 1 To Len(aRegs)
	If !MsSeek(aRegs[nY,1]+aRegs[nY,2])
		RecLock("SX1",.T.)
		For nJ := 1 To FCount()
			If nJ <= Len(aRegs[nY])
				FieldPut(nJ,aRegs[nY,nJ])
			EndIf
		Next nJ
		MsUnlock()
	EndIf
Next nY

RestArea(aAreaSX1)
RestArea(aAreaAtu)

Return(Nil)

RETURN





/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³VALIDPERG ³ Autor ³  Luiz Carlos Vieira	³ Data ³ 03/07/97   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica as perguntas incluindo-as caso nao existam		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³                            					                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPerg()
Local nLoop2, nLoop1
Local cLAlias := Alias()
Local aRegs   := {}

Aadd(aRegs,{PADR(cPerg,10),"01","Do Prefixo           ?","","","mv_ch1","C",03,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{PADR(cPerg,10),"02","Ate o Prefixo        ?","","","mv_ch2","C",03,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{PADR(cPerg,10),"03","Do Titulo            ?","","","mv_ch3","C",09,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"04","Ate o Titulo         ?","","","mv_ch4","C",09,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"05","Da Parcela           ?","","","mv_ch5","C",01,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"06","Ate a Parcela        ?","","","mv_ch6","C",01,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"07","Do Portador          ?","","","mv_ch7","C",03,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"08","Ate o Portador       ?","","","mv_ch8","C",03,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"09","Do Cliente           ?","","","mv_ch9","C",06,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"10","Ate o Cliente        ?","","","mv_chA","C",06,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"11","Da Loja              ?","","","mv_chB","C",02,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"12","Ate a Loja           ?","","","mv_chC","C",02,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"13","Do Vencimento        ?","","","mv_chD","D",08,0,0,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"14","Ate o Vencimento     ?","","","mv_chE","D",08,0,0,"G","","mv_par14","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"15","Da Emissao           ?","","","mv_chF","D",08,0,0,"G","","mv_par15","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"16","Ate a Emissao        ?","","","mv_chG","D",08,0,0,"G","","mv_par16","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"17","Seleciona Titulos    ?","","","mv_chH","N",01,0,0,"C","","mv_par17","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"18","Codigo de Barras     ?","","","mv_chI","N",01,0,0,"C","","mv_par18","Laser","","","","","Jato de Tinta","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"19","Valor Multa          ?","","","mv_chJ","N",11,2,0,"G","","mv_par19","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"20","Juros Mensal         ?","","","mv_chK","N",11,2,0,"G","","mv_par20","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"21","Banco                ?","","","mv_chl","C",03,0,0,"G","","mv_par21","","","","","","","","","","","","","","","","","","","","","","","","","SA6","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"22","Agencia              ?","","","mv_chm","C",05,0,0,"G","","mv_par22","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"23","Conta                ?","","","mv_chn","C",10,0,0,"G","","mv_par23","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"24","Sub Conta            ?","","","mv_cho","C",03,0,0,"G","","mv_par24","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"25","Total / Parcial      ?","","","mv_chp","N",01,0,0,"C","","mv_par25","Total","","","","","Parcial","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"26","Re-Impressao         ?","","","mv_chq","N",01,0,0,"C","","mv_par26","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"27","Mensagem Adicional 1 ?","","","mv_chr","C",99,0,0,"G","","mv_par27","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"28","Mensagem Adicional 2 ?","","","mv_chs","C",99,0,0,"G","","mv_par28","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"29","Mensagem Adicional 3 ?","","","mv_cht","C",99,0,0,"G","","mv_par29","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualizacao do SX1 com os parametros criados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX1")
dbSetorder(1)
For nLoop1 := 1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[nLoop1,2])
		RecLock("SX1",.T.)
		For nLoop2 := 1 to FCount()
			FieldPut(nLoop2,aRegs[nLoop1,nLoop2])
		Next
		MsUnlock()
		dbCommit()
	Endif
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Retorna ambiente original³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cLAlias)

Return