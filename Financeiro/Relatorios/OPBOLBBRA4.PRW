#INCLUDE "RWMAKE.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ProgramaOPBOLBBRA³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ Adaptacao p/Gama ³ Fernando de Almeida       ³ Data ³ 22/07/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO BANCO DO BRASIL COM CODIGO DE BARRAS   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function OPBRA()
                                  
LOCAL	aPergs 		:= {} 
PRIVATE lExec    	:= .F.
PRIVATE cIndexName 	:= ''
PRIVATE cIndexKey  	:= ''
PRIVATE cFilter    	:= ''
Private cLogogama  	:= "LogogamaBol.bmp"
Private cLogoBB  	:= "BBrasil.bmp"


Tamanho  := "M"
titulo   := "Impressao de Boleto com Codigo de Barras - Banco do Brasil"
cDesc1   := "Este programa destina-se a impressao do Boleto com Codigo de Barras - Banco do Brasil"
cDesc2   := ""
cDesc3   := ""
cString  := "SE1"
wnrel    := "BRA"
lEnd     := .F.
cPerg    := "BLTBRAXXXA"
aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }   
nLastKey := 0



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ValidPerg()
Pergunte (cPerg,.F.)


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


	cIndexName := Criatrab(Nil,.F.)
	cIndexKey  := 	"E1_PORTADO+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+DTOS(E1_EMISSAO)"
	cFilter    := 	"E1_PREFIXO >= '" + MV_PAR01 + "' .And. E1_PREFIXO <= '" + MV_PAR02 + "' .And. " + ;
	"E1_NUM     >= '" + MV_PAR03 + "' .And. E1_NUM     <= '" + MV_PAR04 + "' .And. " + ;
	"E1_PARCELA >= '" + MV_PAR05 + "' .And. E1_PARCELA <= '" + MV_PAR06 + "' .And. " + ;
	"E1_PORTADO >= '" + MV_PAR07 + "' .And. E1_PORTADO <= '" + MV_PAR08 + "' .And. " + ;
	"E1_CLIENTE >= '" + MV_PAR09 + "' .And. E1_CLIENTE <= '" + MV_PAR10 + "' .And. " + ;
	"E1_EMISSAO >= CTOD('" + DTOC(MV_PAR15) + "') .And. E1_EMISSAO <= CTOD('" + DTOC(MV_PAR16) + "') .And. " + ;
	"E1_VENCREA  >= CTOD('" + DTOC(MV_PAR13) + "') .And. E1_VENCREA <= CTOD('" + DTOC(MV_PAR14) + "') .And. "+ ;
	"E1_LOJA    >= '"+MV_PAR11+"' .And. E1_LOJA <= '"+MV_PAR12+"' .And. "+;
	"E1_SALDO > 0 .And. " + ;
	"SubsTring(E1_TIPO,3,1) != '-' .And. "+;
	"E1_PORTADO = '001'"


IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde selecionando registros....")
DbSelectArea("SE1")
#IFNDEF TOP
	DbSetIndex(cIndexName + OrdBagExt())
#ENDIF
dbGoTop()

//Aviso( "Atenção ! " , "Os Titulos a Receber cuja forma de Pagamento seja igual a Deposito não serão apresentados !" , {"Ok"} , 1 , "Atenção !" )    

@ 001,001 TO 400,700 DIALOG oDlg TITLE "Selecao de Titulos"
@ 001,001 TO 170,350 BROWSE "SE1" MARK "E1_OK"
@ 180,310 BMPBUTTON TYPE 01 ACTION (lExec := .T.,Close(oDlg))
@ 180,280 BMPBUTTON TYPE 02 ACTION (lExec := .F.,Close(oDlg))
ACTIVATE DIALOG oDlg CENTERED
	
dbGoTop()
If lExec

	//Posiciona o SA6 (Parametros de Bancos)
	DbSelectArea("SA6")
	DbSetOrder(1)
	If !DbSeek(xFilial("SA6") + MV_PAR21 + MV_PAR22 + MV_PAR23 )
       Aviso( "Atenção ! " , "O Banco : " + Alltrim(MV_PAR21) + " Agencia : " + Alltrim(MV_PAR22) + " Conta : " + Alltrim(MV_PAR23) + " nào foram encontrados no cadastro de bancos !" , {"Ok"} , 1 , "Banco não encontrado !" )
       Return
	Endif
	
	//Posiciona na Arq de Parametros CNAB
	DbSelectArea("SEE")
	DbSetOrder(1)
	If !DbSeek(xFilial("SEE") + MV_PAR21 + MV_PAR22 + MV_PAR23 + MV_PAR24)
       Aviso( "Atenção ! " , "Não existem parametros de bancos Cnab (SEE) cadastrados para a o Banco : " + Alltrim(MV_PAR21) + " Agencia : " + Alltrim(MV_PAR22) + " Conta : " + Alltrim(MV_PAR23) + " e Sub-Conta : " + Alltrim(MV_PAR24) + " . Cadastre os Parametros de Bancos antes de Imprimir o Boleto !" , {"Ok"} , 1 , "Parametros Bancos" )
       Return
    Endif   

	Processa({|lEnd|MontaRel()})

Endif
RetIndex("SE1")
Ferase(cIndexName+OrdBagExt())

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  MontaRel³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASER DO SUDAMERIS C/ CODIGO DE BARRAS ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MontaRel()
LOCAL oPrint
LOCAL nX := 0
Local cNroDoc :=  " "
LOCAL aDadosEmp    := {	SM0->M0_NOMECOM                                    								  ,; //[1]Nome da Empresa
								SM0->M0_ENDCOB                                     						  ,; //[2]Endereço
								AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //[3]Complemento
								"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             ,; //[4]CEP
								"PABX/FAX: "+SM0->M0_TEL                                                  ,; //[5]Telefones
								"CNPJ: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+          	   ; //[6]
								Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+                       ; //[6]
								Subs(SM0->M0_CGC,13,2)                                                    ,; //[6]CGC
								"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+            ; //[7]
								Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)                         }  //[7]I.E

LOCAL aDadosTit
LOCAL aDadosBanco
LOCAL aDatSacado
LOCAL aBolText     := {"Boleto , gerado pela gama ref. NF/Data: "		,;  //[1]Validade Boleto
 					   "Sr. caixa, conceder desconto de R$ "  										,;  //[2]Valor da Multa
 					   "Valor da Mora por Dia em Atraso de R$ "                                    	,;  //[3]Mora Diaria
					   "Protestar apos 05 dias do vencimento."			}   //[4]Protesto


LOCAL nI           := 1
LOCAL aCB_RN_NN    := {}
LOCAL nVlrAbat		:= 0

oPrint:= TMSPrinter():New( "Boleto Laser" )
oPrint:SetPortrait() // ou SetLandscape()
oPrint:StartPage()   // Inicia uma nova página


			If Empty (SE1->E1_NUMBCO)
		   		U_GrvDadBol( SE1->E1_PREFIXO , SE1->E1_NUM , SE1->E1_PARCELA , SE1->E1_TIPO , SE1->E1_CLIENTE , SE1->E1_LOJA , SEE->EE_CODIGO , SUBSTR(SEE->EE_AGENCIA, 1, 5) , SUBSTR(SEE->EE_CONTA,1,10) , Alltrim(SEE->EE_SUBCTA) )
			EndIf   

	    	DbSelectArea("SEE")
			DbSetOrder(1)
			aDadosBanco  := {SEE->EE_CODIGO                    						,;	// [1]Numero do Banco
	   	                   	"BANCO DO BRASIL"      	            	                ,; 	// [2]Nome do Banco
			               	SUBSTR(SEE->EE_AGENCIA, 1, 5)                       	,;	// [3]Agência
	   	                   	SUBSTR(SEE->EE_CONTA,1,5)								,; 	// [4]Conta Corrente
	   	                   	SUBSTR(SEE->EE_CONTA,Len(AllTrim(SEE->EE_CONTA)),1) 	,; 	// [5]Dígito da conta corrente
	   	                   	SUBSTR(SEE->EE_SUBCTA,1,3) 											,;  // [6]Codigo da Carteira
                        	SEE->EE_XMORA 										,;	// [7]Tx de Mora Diaria
                            SUBSTR(SEE->EE_CODEMP,1,7)								}	// [8]Codigo do Convenio da gama no BB

	   	
			If Empty(SA1->A1_ENDCOB) .OR. Empty(SA1->A1_CEPC) 
				aDatSacado   := {AllTrim(SA1->A1_NOME)           	,;     	// [1]Razão Social
				AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           	,;     	// [2]Código
				AllTrim(SA1->A1_END )+"-"+AllTrim(SA1->A1_BAIRRO)	,;     	// [3]Endereço
				AllTrim(SA1->A1_MUN )                            	,;  	// [4]Cidade
				SA1->A1_EST                                      	,;    	// [5]Estado
				SA1->A1_CEP                                      	,;     	// [6]CEP
				SA1->A1_CGC										 	,;  	// [7]CGC
				SA1->A1_PESSOA										}		// [8]PESSOA
			Else
				aDatSacado   := {AllTrim(SA1->A1_NOME)          	,;   	// [1]Razão Social
				AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           	,;   	// [2]Código
				AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;   	// [3]Endereço
				AllTrim(SA1->A1_MUNC)	                     		,;   	// [4]Cidade
				SA1->A1_ESTC	                                    ,;   	// [5]Estado
				SA1->A1_CEPC                                    	,;   	// [6]CEP
				SA1->A1_CGC											,;		// [7]CGC
				SA1->A1_PESSOA										}		// [8]PESSOA
			Endif
			
   	
			//Aqui esta o Calculo do Digito Verificador do Nosso Numero do Banco do Brasil
			//Modulo 11 da juncao do Nr do Conveio + Seguencial de Nr Bancario do SEE
         
			nNrBancario := StrZero(Val(Alltrim(SE1->E1_NUMBCO)),10)
			nNrConvenio := SUBSTR(SEE->EE_CODEMP,1,7)
			nNrBanc		:= Alltrim(nNrConvenio) + Alltrim(nNrBancario)
			nDVNrBanc	:= modulo11A(nNrBanc) // Div verifacador Convenio + Seguencial do Nosso Num 

	
			aDadosTit	:= {AllTrim(SE1->E1_NUM)+AllTrim(SE1->E1_PARCELA)		,;  // [1] Número do título
								SE1->E1_EMISSAO                      			,;  // [2] Data da emissão do título
								dDataBase                    	     			,;  // [3] Data da emissão do boleto
								SE1->E1_VENCREA                       			,;  // [4] Data do vencimento
                              	U_CalcVal()                          			,;  // [5] Valor do título - Alterado por César Moura em 20/03/2007	
							 	SE1->E1_NUMBCO					     			,;  // [6] Nosso número (Ver fórmula para calculo)
								SE1->E1_PREFIXO                      			,;  // [7] Prefixo da NF
								SE1->E1_TIPO	                     			,;	// [8] Tipo do Titulo
								SE1->E1_DESCFIN									}	// [9] Desconto Financeiro

			//Monta codigo de barras
//			aCB_RN_NN    := Ret_cBarra(Subs(aDadosBanco[1],1,3)+"9",aDadosBanco[8],nNrBancario,aDadosTit[5],SE1->E1_VENCREA,nDVNrBanc,aDadosBanco[6])
			aCB_RN_NN    := Ret_cBarra(Subs(aDadosBanco[1],1,3)+"9",aDadosBanco[8],nNrBancario,aDadosTit[5],SE1->E1_VENCREA,nDVNrBanc,aDadosBanco[6])
			
			Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN,nDVNrBanc)
			nX := nX + 1
//	EndIf
	dbSkip()
	IncProc()
	nI := nI + 1
//EndDo
oPrint:EndPage()     // Finaliza a página
oPrint:Preview()     // Visualiza antes de imprimir
Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  Impress ³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESS BOLETO LASER DO BCO DO BRASIL COM CODIGO DE BARRAS ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN,nDVNrBanc)
LOCAL oFont8
LOCAL oFont11c
LOCAL oFont10
LOCAL oFont14
LOCAL oFont16n
LOCAL oFont15
LOCAL oFont14n
LOCAL oFont24
LOCAL nI := 0

//Parametros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)
oFont8  := TFont():New("Arial",9,8,.T.,.F.,5,.T.,5,.T.,.F.)
oFont11c := TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont20  := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
oFont21  := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n := TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont15  := TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
oFont15n := TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:StartPage()   // Inicia uma nova página

/*****************/
/* SEGUNDA PARTE */
/*****************/

nRow2 := 0

oPrint:SayBitmap(0137,100,cLogoBB,405,080)		// Imprime o Logo do Banco
oPrint:SayBitmap(0480,850,cLogogama,600,600)	// Imprime o Logo da gama - Marca D'agua

oPrint:Line (nRow2+0210,100,nRow2+0210,2300)
oPrint:Line (nRow2+0210,500,nRow2+0130, 500)
oPrint:Line (nRow2+0210,710,nRow2+0130, 710)

oPrint:Say  (nRow2+0135,515,"001-9"				,oFont20)		// [1]Numero do Banco
oPrint:Say  (nRow2+0144,1800,"Recibo do Sacado"	,oFont10)

oPrint:Line (nRow2+0310,100,nRow2+0310,2300 )
oPrint:Line (nRow2+0410,100,nRow2+0410,2300 )
oPrint:Line (nRow2+0480,100,nRow2+0480,2300 )
oPrint:Line (nRow2+0550,100,nRow2+0550,2300 )

oPrint:Line (nRow2+0410,500,nRow2+0550,500)
oPrint:Line (nRow2+0480,750,nRow2+0550,750)
oPrint:Line (nRow2+0410,1000,nRow2+0550,1000)
oPrint:Line (nRow2+0410,1300,nRow2+0480,1300)
oPrint:Line (nRow2+0410,1480,nRow2+0550,1480)

oPrint:Say  (nRow2+0210,100 ,"Local de Pagamento",oFont8)
oPrint:Say  (nRow2+0225,400 ,"Pagavel em qualquer Banco até o Vencimento , após , somente nas agências",oFont10)
oPrint:Say  (nRow2+0265,400 ,"do Banco do Brasil.                       ",oFont10)

oPrint:Say  (nRow2+0210,1810,"Vencimento"                                     ,oFont8)
cString	:= StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
nCol := 1910+(374-(len(cString)*22))
oPrint:Say  (nRow2+0250,nCol,cString,oFont11c)

oPrint:Say  (nRow2+0310,100 ,"Cedente"                                        ,oFont8)
oPrint:Say  (nRow2+0350,100 ,aDadosEmp[1]+"                  - "+aDadosEmp[6]	,oFont10) //Nome + CNPJ

oPrint:Say  (nRow2+0310,1810,"Agência/Código Cedente",oFont8)
cString :=  SUBSTR(aDadosBanco[3],1,4)+"-"+SUBSTR(aDadosBanco[3],5,1)+"/"+aDadosBanco[4]+"-"+aDadosBanco[5]
nCol := 1910+(374-(len(cString)*22))
oPrint:Say  (nRow2+0350,nCol,cString,oFont11c)

oPrint:Say  (nRow2+0410,100 ,"Data do Documento"                              ,oFont8)
oPrint:Say  (nRow2+0440,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4),oFont10)

oPrint:Say  (nRow2+0410,505 ,"Nro.Documento"                                  ,oFont8)
oPrint:Say  (nRow2+0440,605 ,aDadosTit[7]+aDadosTit[1]						,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (nRow2+0410,1005,"Espécie Doc."                                   ,oFont8)
oPrint:Say  (nRow2+0440,1050,aDadosTit[8]										,oFont10) //Tipo do Titulo

oPrint:Say  (nRow2+0410,1305,"Aceite"                                         ,oFont8)
oPrint:Say  (nRow2+0440,1400,"N"                                             ,oFont10)

oPrint:Say  (nRow2+0410,1485,"Data do Processamento"                          ,oFont8)
oPrint:Say  (nRow2+0440,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4),oFont10) // Data impressao

oPrint:Say  (nRow2+0410,1910,"Nosso Número"                                   ,oFont8)
//If Alltrim(nDVNrBanc) ="X"
//   cString :=  Alltrim(aDadosBanco[8])+Alltrim(aDadosTit[6])+"-"+Alltrim(nDVNrBanc)
//Else
//   cString :=  Alltrim(aDadosBanco[8])+Alltrim(aDadosTit[6])+"-"+Alltrim(str(nDVNrBanc))
//EndIf
cString :=  Alltrim(aDadosBanco[8])+Alltrim(aDadosTit[6])
nCol := 1660+(594-(len(cString)*22))
oPrint:Say  (nRow2+0440,nCol,cString,oFont11c)

oPrint:Say  (nRow2+0480,100 ,"Uso do Banco"                                   ,oFont8)

oPrint:Say  (nRow2+0480,505 ,"Carteira"                                       ,oFont8)
oPrint:Say  (nRow2+0510,555 ,aDadosBanco[6]+"/019"                            ,oFont10)

oPrint:Say  (nRow2+0480,755 ,"Espécie"                                        ,oFont8)
oPrint:Say  (nRow2+0510,805 ,"R$"                                             ,oFont10)

oPrint:Say  (nRow2+0480,1005,"Quantidade"                                     ,oFont8)
oPrint:Say  (nRow2+0480,1485,"Valor"                                          ,oFont8)

oPrint:Say  (nRow2+0480,1810,"Valor do Documento"                          	,oFont8)
cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
nCol := 1915+(374-(len(cString)*22))
oPrint:Say  (nRow2+0510,nCol,cString ,oFont11c)

oPrint:Say  (nRow2+0550,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do cedente)",oFont8)
If aDadosTit[8] == "GNR"
   oPrint:Say  (nRow2+0600,100 ,aBolText[1]+Substr(aDadosTit[1],1,6)+" - "+StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4),oFont10)
EndIf
If !Empty(aDadosTit[9])
   oPrint:Say  (nRow2+0650,100 ,aBolText[2]+" "+AllTrim(Transform((aDadosTit[5]*(aDadosTit[9]/100)),"@E 99,999.99")+" ("+Alltrim(Transform(aDadosTit[9],"@E 99,99"))+"%)."),oFont10)
EndIf   
oPrint:Say  (nRow2+0700,100 ,aBolText[3]+" "+AllTrim(Transform((((aDadosTit[5])*(aDadosBanco[7]/100))/30) ,"@E 99,999.99")+" ("+Alltrim(Transform(aDadosBanco[7],"@E 99,99"))+"% a.m.).")  ,oFont10)
oPrint:Say  (nRow2+0750,100 ,aBolText[4]                                                                  ,oFont10)

oPrint:Say  (nRow2+0550,1810,"(-)Desconto/Abatimento"                         ,oFont8)
oPrint:Say  (nRow2+0620,1810,"(-)Outras Deduções"                             ,oFont8)
oPrint:Say  (nRow2+0690,1810,"(+)Mora/Multa"                                  ,oFont8)
oPrint:Say  (nRow2+0760,1810,"(+)Outros Acréscimos"                           ,oFont8)
oPrint:Say  (nRow2+0830,1810,"(=)Valor Cobrado"                               ,oFont8)

oPrint:Say  (nRow2+0900,100 ,"Sacado"                                         ,oFont8)
oPrint:Say  (nRow2+0930,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)
oPrint:Say  (nRow2+0983,400 ,aDatSacado[3]                                    ,oFont10)
oPrint:Say  (nRow2+1036,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado


	oPrint:Say  (nRow2+1089,400 ,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC

oPrint:Say  (nRow2+1145,100 ,"Sacador/Avalista",oFont8)
oPrint:Say  (nRow2+1185,1500,"Autenticação Mecânica",oFont8)

oPrint:Line (nRow2+0210,1800,nRow2+0900,1800 ) 
oPrint:Line (nRow2+0620,1800,nRow2+0620,2300 )
oPrint:Line (nRow2+0690,1800,nRow2+0690,2300 )
oPrint:Line (nRow2+0760,1800,nRow2+0760,2300 )
oPrint:Line (nRow2+0830,1800,nRow2+0830,2300 )
oPrint:Line (nRow2+0900,100 ,nRow2+0900,2300 )
oPrint:Line (nRow2+1140,100 ,nRow2+1140,2300 )


/******************/
/* TERCEIRA PARTE */
/******************/

nRow3 := 0

For nI := 100 to 2300 step 50
	oPrint:Line(nRow3+1380, nI, nRow3+1380, nI+30)
Next nI

oPrint:SayBitmap(1427,100,cLogoBB,405,080)       	// Imprime o Logo do Banco
oPrint:SayBitmap(1770,850,cLogogama,600,600)		// Imprime o Logo da gama - Marca D'agua

oPrint:Line (nRow3+1500,100,nRow3+1500,2300)
oPrint:Line (nRow3+1500,500,nRow3+1420, 500)
oPrint:Line (nRow3+1500,710,nRow3+1420, 710)

oPrint:Say  (nRow3+1425,515,"001-9"				,oFont20 )	// 	[1]Numero do Banco
oPrint:Say  (nRow3+1434,755,aCB_RN_NN[2]		,oFont14n)	//	Linha Digitavel do Codigo de Barras

oPrint:Line (nRow3+1600,100,nRow3+1600,2300 )
oPrint:Line (nRow3+1700,100,nRow3+1700,2300 )
oPrint:Line (nRow3+1770,100,nRow3+1770,2300 )
oPrint:Line (nRow3+1840,100,nRow3+1840,2300 )

oPrint:Line (nRow3+1700,500 ,nRow3+1840,500 )
oPrint:Line (nRow3+1770,750 ,nRow3+1840,750 )
oPrint:Line (nRow3+1700,1000,nRow3+1840,1000)
oPrint:Line (nRow3+1700,1300,nRow3+1770,1300)
oPrint:Line (nRow3+1700,1480,nRow3+1840,1480)

oPrint:Say  (nRow3+1500,100 ,"Local de Pagamento",oFont8)
oPrint:Say  (nRow3+1515,400 ,"Pagavel em qualquer Banco até o Vencimento , após , somente nas agências",oFont10)
oPrint:Say  (nRow3+1555,400 ,"do Banco do Brasil  ",oFont10)

oPrint:Say  (nRow3+1500,1810,"Vencimento",oFont8)
cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
nCol	 	 := 1910+(374-(len(cString)*22))
oPrint:Say  (nRow3+1540,nCol,cString,oFont11c)

oPrint:Say  (nRow3+1600,100 ,"Cedente",oFont8)
oPrint:Say  (nRow3+1640,100 ,aDadosEmp[1]+"                  - "+aDadosEmp[6]	,oFont10) //Nome + CNPJ

oPrint:Say  (nRow3+1600,1810,"Agência/Código Cedente",oFont8)
cString :=  SUBSTR(aDadosBanco[3],1,4)+"-"+SUBSTR(aDadosBanco[3],5,1)+"/"+aDadosBanco[4]+"-"+aDadosBanco[5]
nCol 	 := 1910+(374-(len(cString)*22))
oPrint:Say  (nRow3+1640,nCol,cString ,oFont11c)


oPrint:Say  (nRow3+1700,100 ,"Data do Documento"                              ,oFont8)
oPrint:Say (nRow3+1730,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4), oFont10)


oPrint:Say  (nRow3+1700,505 ,"Nro.Documento"                                  ,oFont8)
oPrint:Say  (nRow3+1730,605 ,aDadosTit[7]+aDadosTit[1]						,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (nRow3+1700,1005,"Espécie Doc."                                   ,oFont8)
oPrint:Say  (nRow3+1730,1050,aDadosTit[8]										,oFont10) //Tipo do Titulo

oPrint:Say  (nRow3+1700,1305,"Aceite"                                         ,oFont8)
oPrint:Say  (nRow3+1730,1400,"N"                                             ,oFont10)

oPrint:Say  (nRow3+1700,1485,"Data do Processamento"                          ,oFont8)
oPrint:Say  (nRow3+1730,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4)                               ,oFont10) // Data impressao


oPrint:Say  (nRow3+1700,1910,"Nosso Número"                                   ,oFont8)
//If Alltrim(nDVNrBanc) ="X"
//   cString :=  Alltrim(aDadosBanco[8])+Alltrim(aDadosTit[6])+"-"+Alltrim(nDVNrBanc)
//Else
//   cString :=  Alltrim(aDadosBanco[8])+Alltrim(aDadosTit[6])+"-"+Alltrim(str(nDVNrBanc))
//EndIf
cString :=  Alltrim(aDadosBanco[8])+Alltrim(aDadosTit[6])
nCol 	 := 1660+(594-(len(cString)*22))
oPrint:Say  (nRow3+1730,nCol,cString,oFont11c)


oPrint:Say  (nRow3+1770,100 ,"Uso do Banco"                                   ,oFont8)

oPrint:Say  (nRow3+1770,505 ,"Carteira"                                       ,oFont8)
oPrint:Say  (nRow3+1800,555 ,aDadosBanco[6]+"/019"                            ,oFont10)

oPrint:Say  (nRow3+1770,755 ,"Espécie"                                        ,oFont8)
oPrint:Say  (nRow3+1800,805 ,"R$"                                             ,oFont10)

oPrint:Say  (nRow3+1770,1005,"Quantidade"                                     ,oFont8)
oPrint:Say  (nRow3+1770,1485,"Valor"                                          ,oFont8)

oPrint:Say  (nRow3+1770,1810,"Valor do Documento"                          	,oFont8)
cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
nCol 	 := 1915+(374-(len(cString)*22))
oPrint:Say  (nRow3+1800,nCol,cString,oFont11c)

oPrint:Say  (nRow2+1840,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do cedente)",oFont8)
If aDadosTit[8] == "GNR"
   oPrint:Say  (nRow2+1890,100 ,aBolText[1]+Substr(aDadosTit[1],1,6)+" - "+StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4),oFont10)
EndIf
If !Empty(aDadosTit[9])
   oPrint:Say  (nRow2+1940,100 ,aBolText[2]+" "+AllTrim(Transform((aDadosTit[5]*(aDadosTit[9]/100)),"@E 99,999.99")+" ("+Alltrim(Transform(aDadosTit[9],"@E 99,99"))+"%)."),oFont10)
Endif
oPrint:Say  (nRow2+1990,100 ,aBolText[3]+" "+AllTrim(Transform((((aDadosTit[5])*(aDadosBanco[7]/100))/30) ,"@E 99,999.99")+" ("+Alltrim(Transform(aDadosBanco[7],"@E 99,99"))+"% a.m.).")  ,oFont10)
oPrint:Say  (nRow2+2040,100 ,aBolText[4]                                                                  ,oFont10)

oPrint:Say  (nRow3+1840,1810,"(-)Desconto/Abatimento"                         ,oFont8)
oPrint:Say  (nRow3+1910,1810,"(-)Outras Deduções"                             ,oFont8)
oPrint:Say  (nRow3+1980,1810,"(+)Mora/Multa"                                  ,oFont8)
oPrint:Say  (nRow3+2050,1810,"(+)Outros Acréscimos"                           ,oFont8)
oPrint:Say  (nRow3+2120,1810,"(=)Valor Cobrado"                               ,oFont8)

oPrint:Say  (nRow3+2190,100 ,"Sacado"                                         ,oFont8)
oPrint:Say  (nRow3+2200,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)

	oPrint:Say  (nRow3+2200,1750,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC

oPrint:Say  (nRow3+2253,400 ,aDatSacado[3]                                    ,oFont10)
oPrint:Say  (nRow3+2306,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado

oPrint:Say  (nRow3+2355,100 ,"Sacador/Avalista"                               ,oFont8)
oPrint:Say  (nRow3+2395,1500,"Autenticação Mecânica - Ficha de Compensação"                        ,oFont8)

oPrint:Line (nRow3+1500,1800,nRow3+2190,1800 )
oPrint:Line (nRow3+1910,1800,nRow3+1910,2300 )
oPrint:Line (nRow3+1980,1800,nRow3+1980,2300 )
oPrint:Line (nRow3+2050,1800,nRow3+2050,2300 )
oPrint:Line (nRow3+2120,1800,nRow3+2120,2300 )
oPrint:Line (nRow3+2190,100 ,nRow3+2190,2300 )

oPrint:Line (nRow3+2350,100,nRow3+2350,2300  )

MSBAR("INT25",11,1,aCB_RN_NN[1],oPrint,.F.,Nil,Nil,0.014,0.7,Nil,Nil,"A",.F.)

oPrint:EndPage() // Finaliza a página

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Modulo10 ³ Autor ³ Microsiga             ³ Data ³ 12/06/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo do Modulo 10                                       ³±±
±±³          ³ para calcular os Digitos Verificadores da Linha Digitavel  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Modulo10(cData)
LOCAL L,D,P := 0
LOCAL B     := .F.
L := Len(cData)
B := .T.
D := 0
While L > 0
	P := Val(SubStr(cData, L, 1))
	If (B)
		P := P * 2
		If P > 9
			P := P - 9
		End
	End
	D := D + P
	L := L - 1
	B := !B
End
D := 10 - (Mod(D,10))
If D = 10
	D := 0
End
Return(D)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Modulo11 ³ Autor ³ Microsiga             ³ Data ³ 12/06/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo do Modulo 11                                       ³±±
±±³          ³ para calcular o Dig Verificador do Codigo de Barras        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Modulo11(cData)
LOCAL L, D, P := 0
L := Len(cdata)
D := 0
P := 1
While L > 0
	P := P + 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P = 9
		P := 1
	End
	L := L - 1
End
D := 11 - (mod(D,11))
If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
	D := 1
End
Return(D)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ Modulo11A³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Calculo Modulo 11  										  ³±±
±±³          ³ especifico para Nosso Numero do Banco do Brasil            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Modulo11A(cData)
LOCAL L, D, P := 0
L := Len(cdata)
D := 0
P := 1
While L > 0
	P := P + 1
	D := D + (Val(SubStr(cData, L, 1)) * P)
	If P = 9
		P := 1
	End
	L := L - 1
End
D := 11 - (mod(D,11))

If (D == 10)
	D := "X"
ElseIf (D == 11)
	D := 0
End

Return(D)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Ret_cBarra³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prepara os dados do Codigo de Barras e Linha Digitavel     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Ret_cBarra(cBanco,nNrConvenio,nNrBancario,nValor,dVencto,nDVNrBanc,nCarteira)

LOCAL cValorFinal := strzero(int(nValor*100),10)
LOCAL nDvnn			:= 0
LOCAL nDvcb			:= 0
LOCAL nDv			:= 0
LOCAL cNN			:= ''
LOCAL cRN			:= ''
LOCAL cCB			:= ''
LOCAL cS			:= ''
LOCAL cFator      	:= strzero(dVencto - ctod("07/10/97"),4)
LOCAL cCmpltoNsNr	:= '0000000'


//----------------------------------
//	 Definicao do CODIGO DE BARRAS
//----------------------------------
cS:= cBanco + cFator +  cValorFinal + cCmpltoNsNr + nNrConvenio + nNrBancario + nCarteira
nDvcb := modulo11(Substr(cS,1,43))
cCB   := SubStr(cS, 1, 4) + Alltrim(str(nDvcb)) + SubStr(cS,5,39)

//-------- Definicao da LINHA DIGITAVEL (Representacao Numerica)
//	Campo 1			Campo 2						Campo 3				Campo 4	   	Campo 5
//	AAABC.CCCCX		DDDDD.DDDDDY	EEEEE.EEEEEZ			K						UUUUVVVVVVVVVV

// 	CAMPO 1:
//	AAA	= Codigo do banco na Camara de Compensacao
//	  BC = Codigo da moeda, sempre 9
//	CCCCC = Codigo da Carteira de Cobranca
//	  X = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo

cS1   := cBanco + SubStr(cCmpltoNsNr,1,5)
nDv1  := modulo10(cS1)
cLD1  := SubStr(cS1, 1, 5) + '.' + SubStr(cS1, 6, 4) + AllTrim(Str(nDv1)) + '  '

// 	CAMPO 2:
//	DDDDD = Restante do Nosso Numero
//	 DDDDD = DAC do campo Agencia/Conta/Carteira/Nosso Numero
//	     Y = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
           
cS2	:= SubStr(cCmpltoNsNr,1,2) +  SubStr(nNrConvenio,1,7) + SubStr(cCmpltoNsNr,1,1)
nDv2:= modulo10(cS2)
cLD2:= SubStr(cS2, 1, 5) + '.' + SubStr(cS2, 6, 5) + AllTrim(Str(nDv2)) + '  '

// 	CAMPO 3:
//	EEEEE = Nosso numero
// EEEEE =
//	     Z = DAC que amarra o campo, calculado pelo Modulo 10 da String do campo
cS3   := SubStr(nNrBancario,1,10) 
nDv3  := modulo10(cS3)
cLD3  := SubStr(cS3, 1, 5) + '.' + SubStr(cS3, 6, 5) + AllTrim(Str(nDv3)) + '   '

//	CAMPO 4:
//	     K = DAC do Codigo de Barras
cLD4  := AllTrim(Str(nDvcb)) + '   '

// 	CAMPO 5:
//	      UUUU = Fator de Vencimento
//	VVVVVVVVVV = Valor do Titulo
cLD5  := cFator + cValorFinal

cLD	  := cLD1 + cLD2 + cLD3 + cLD4 + cLD5

Return({cCB,cLD})

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
AADD(aRegs,{PADR(cPerg,10),"09","Do Cliente           ?","","","mv_ch9","C",06,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"10","Ate o Cliente        ?","","","mv_chA","C",06,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
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
AADD(aRegs,{PADR(cPerg,10),"27","Mensagem Adicional 1 ?","","","mv_chr","C",99,0,0,"G","","mv_par27","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"28","Mensagem Adicional 2 ?","","","mv_chs","C",99,0,0,"G","","mv_par28","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{PADR(cPerg,10),"29","Mensagem Adicional 3 ?","","","mv_cht","C",99,0,0,"G","","mv_par29","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
