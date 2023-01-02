#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

/*/
———————————————————————————————————————————————————————————————————————————————
———————————————————————————————————————————————————————————————————————————————
@fonte			.PRW                                                  /@
@description	fonte com funções utilizadas no CNAB a pagar e a receber.     /@
@use				Gama Italy                                                    /@
———————————————————————————————————————————————————————————————————————————————
———————————————————————————————————————————————————————————————————————————————
/*/


/*/
———————————————————————————————————————————————————————————————————————————————
@function		SLDTIT                                                        /@
@type				User Function                                                 /@
@date				07/01/2009                                                    /@
@description	Funcao para retornar o valor do titulo nos Cnabs Receber      /@
@author			Fernando de Almeida                                           /@
@use				Gama Italy                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function SLDTIT()

_nAbat    := SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA,"R", 1,, SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_FILIAL)
_cRetorno := SE1->(E1_SALDO + E1_ACRESC - E1_DECRESC)- _nAbat
_cRetorno := Substr(Strzero(_cRetorno*100,16,2),1,13)

//(e1 valor                    vlrabat)

Return _cRetorno


/*/
———————————————————————————————————————————————————————————————————————————————
@function		JURDIA                                                        /@
@type				User Function                                                 /@
@date				07/01/2009                                                    /@
@description	Funcao para retornar o valor do juros diario dos cnab a 
					receber (10 %)                                                /@
@author			Fernando de Almeida                                           /@
@use				Gama Italy                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function JURDIA()

_nAbat    := SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA,"R", 1,, SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_FILIAL)
_cRetorno := SE1->E1_SALDO - _nAbat
_cRetorno := (_cRetorno*GetMv("MV_MORAD"))/30
_cRetorno := Substr(Strzero(_cRetorno*100,16,2),1,13)

Return _cRetorno                                                                


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MSGMORA                                                       /@
@type				User Function                                                 /@
@date				07/01/2009                                                    /@
@description	Funcao para retornar o valor do juros diario dos cnab a 
					receber (6 %)                                                 /@
@author			Fernando de Almeida                                           /@
@use				Gama Italy                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MSGMORA()

_nAbat    := SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA,"R", 1,, SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_FILIAL)
_cRetorno := SE1->E1_SALDO - _nAbat
_cRetorno := ((_cRetorno*GetMv("MV_MORAD"))/30)         
_cRetorno := Substr(Strzero(_cRetorno*100,16,2),1,13)
_cRetorno := NoRound(Val(_cRetorno)/100,2)
_cRetorno := "Apos Vencimento Cobrar Mora Diaria de R$ "+Alltrim(STR(_cRetorno,12,2))

Return _cRetorno                                                                


/*/
———————————————————————————————————————————————————————————————————————————————
@function		LIMPCAR                                                       /@
@type				User Function                                                 /@
@date				21/01/2014                                                    /@
@description	Funcao para limpar caracteres especiais CNAB CEF.             /@
@author			Felipe Varella                                                /@
@use				Gama Italy                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function limpcar(cTexto)
Local cRet := cTexto

cRet := StrTran(cRet, "#", "")
cRet := StrTran(cRet, "º", "")
cRet := StrTran(cRet, "$", "")            
cRet := StrTran(cRet, "&", "")
cRet := StrTran(cRet, "!", "")
cRet := StrTran(cRet, "%", "")
cRet := StrTran(cRet, "(", "")
cRet := StrTran(cRet, ")", "")
cRet := StrTran(cRet, "*", "")
cRet := StrTran(cRet, "+", "")
cRet := StrTran(cRet, ">", "")
cRet := StrTran(cRet, "<", "")
cRet := StrTran(cRet, "[", "")
cRet := StrTran(cRet, "]", "")
cRet := StrTran(cRet, "©", "")
cRet := StrTran(cRet, "ª", "")
cRet := StrTran(cRet, "¿", "")
cRet := StrTran(cRet, "Ç", "")          
cRet := StrTran(cRet, "ç", "")

Return(cRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		VLDEMP                                                        /@
@type				User Function                                                 /@
@date				25/06/2014                                                    /@
@description	Funcao para validar o digito da agencia e conta CNAB Brasdeco./@
@author			Felipe Varella                                                /@
@use				Gama Italy                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function VLDEMP1()
Local cRetorno := ""

	IF "-" $ (SA6->A6_NUMCON)
		cRetorno :=	STRZERO(VAL(SUBSTR(SA6->A6_NUMCON,1,At("-" , SA6->A6_NUMCON)-1) + SUBSTR(SA6->A6_NUMCON,At("-" , SA6->A6_NUMCON)+1,1) ),8) 
		
  	ELSEIF (SA6->A6_DVCTA) == ""
		cRetorno :=	STRZERO(VAL(ALLTRIM(SA6->A6_NUMCON)),8)
		
	ELSEIF (SA6->A6_DVCTA) <> ""
		cRetorno := STRZERO(VAL(ALLTRIM(SA6->A6_NUMCON)+ ALLTRIM(SA6->A6_DVCTA)),8)

	ENDIF
               
Return(cRetorno)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		VLDEMP2                                                       /@
@type				User Function                                                 /@
@date				25/06/2014                                                    /@
@description	Funcao para validar o digito da agencia e conta CNAB Brasdeco./@
@author			Felipe Varella                                                /@
@use				Gama Italy                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function VLDEMP2()
Local cRetorno := ""
	IF (SA6->A6_AGENCIA) $ "-"
		cRetorno := SUBSTR(SA6->A6_AGENCIA, 1,5)
		
  	ELSEIF EMPTY(SA6->A6_DVAGE)
		cRetorno := SUBSTR(SA6->A6_AGENCIA, 1,5)
		
	ELSEIF (SA6->A6_DVAGE) <> ""
		cRetorno :=	(SUBSTR(Alltrim(SA6->A6_AGENCIA) , 1, 4) + SA6->A6_DVAGE)

	ENDIF
Return(cRetorno)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		VLDPCCINC                                                     /@
@type				User Function                                                 /@
@date				25/06/2014                                                    /@
@description	                                                              /@
@author			Felipe Varella                                                /@
@use				Gama Italy                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function VLDPCCINC()
Local cRetorno := SD1->(D1_TOTAL+D1_VALIPI+D1_ICMSRET+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC-IIF(SF1->F1_IRRF>=GETMV("MV_VLRETIR"),D1_VALIRR,0)-D1_VALINS-D1_VALISS-D1_VALPIS-D1_VALCOF-D1_VALCSL)
     
Return(cRetorno)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		VLDPCCEXC                                                     /@
@type				User Function                                                 /@
@date				25/06/2014                                                    /@
@description	                                                              /@
@author			Felipe Varella                                                /@
@use				Gama Italy                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function VLDPCCEXC()
Local cRetorno := SD1->(D1_TOTAL+D1_VALIPI+D1_ICMSRET+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC-IIF(SF1->F1_IRRF>=GETMV("MV_VLRETIR"),D1_VALIRR,0)-D1_VALINS-D1_VALISS-D1_VALPIS-D1_VALCOF-D1_VALCSL) 

Return(cRetorno)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		VLCODBAR                                                      /@
@type				User Function                                                 /@
@date				19/02/2014                                                    /@
@description	VALIDA CODIGO DE BARRAS                                       /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use				Clientes Opção Um Consultoria                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function VlCodBar(cCodBar)
Local lRet	:= .T.
Local cEol	:= chr(13) + chr(10) + chr(13) + chr(10)
Local cFixo	:= "Específico Brasitech"
Local cMsg	:= ""
Local nX, cCampo

//———————————————————————————————————————————————————————————————————————————————
// Caso o numero do codigo de barras nao tenha sido passado por parametro, assumo
// o campo E2_CODBAR
//———————————————————————————————————————————————————————————————————————————————
cCodBar := iif(cCodBar == NIL, AllTrim(M->E2_CODBAR), AllTrim(cCodBar))

if !Empty(cCodBar)

	//———————————————————————————————————————————————————————————————————————————————
	// Verifico se a representação do código de barras do titulo possui o tamanho de
	// 43 (com valor zerado), 47 (codbar digitado), 44 (codbar lido) ou 48 (tributos)
	//———————————————————————————————————————————————————————————————————————————————
	if lRet
		cCodBar += iif(Len(cCodBar) == 36, "00000000000", "")
		if Len(cCodBar) != 44 .and. Len(cCodBar) != 47 .and. Len(cCodBar) != 48
			lRet := .F.
			Help(" ", 1, "ATENÇÃO", , "O tamanho do código de barras está incorreto. Verifique." + cEol + cFixo, 1)
		endif
	endif

	//———————————————————————————————————————————————————————————————————————————————
	// Verifico se todos os digitos preenchidos são numéricos.
	//———————————————————————————————————————————————————————————————————————————————
	if lRet
		for nX := 1 to Len(cCodBar)
			if !IsDigit(Substr(cCodBar,nX,1))
				lRet := .F.
				Help(" ", 1, "ATENÇÃO", , "O código de barras é composto somente de números. Verifique." + cEol + cFixo, 1)
				Exit
			endif
		next
	endif

	//———————————————————————————————————————————————————————————————————————————————
	// Verifico se o codigo foi preenchido com zeros
	//———————————————————————————————————————————————————————————————————————————————
	if lRet
		if cCodBar == Repl("0",Len(cCodBar))
			lRet := .F.
			Help(" ", 1, "ATENÇÃO", , "O código de barras inválido. Verifique." + cEol + cFixo, 1)
		endif
	endif
	
	//———————————————————————————————————————————————————————————————————————————————
	// Valido o código de barras lido Boletos
	//———————————————————————————————————————————————————————————————————————————————
	if lRet .and. Len(cCodBar)==44 .and. Left(cCodBar,1) != "8"
		if Mod11(Substr(cCodBar,1,4) + SubStr(cCodBar,6)) != SubStr(cCodBar,5,1)
			lRet := .F.
			Help(" ", 1, "ATENÇÃO", , "Código de barras inválido. Verifique." + cEol + cFixo, 1)
		endif
	
	//———————————————————————————————————————————————————————————————————————————————
	// Valido o código de barras digitado Boletos
	//———————————————————————————————————————————————————————————————————————————————
	elseif lRet .and. (Len(cCodBar)==47)

		if 	Mod10(Substr(cCodBar,1,9)) != Substr(cCodBar,10,1) .or.;
			Mod10(Substr(cCodBar,11,10)) != Substr(cCodBar,21,1) .or.;
			Mod10(Substr(cCodBar,22,10)) != Substr(cCodBar,32,1) .or.;
			Mod11(Substr(cCodBar,1,4) +	Substr(cCodBar,34,14) + Substr(cCodBar,5,5) + Substr(cCodBar,11,10)+ Substr(cCodBar,22,10)) != SubStr(cCodBar,33,1)
			lRet := .F.
			Help(" ", 1, "ATENÇÃO", , "Código de barras inválido. Verifique." + cEol + cFixo, 1)
		endif

	//———————————————————————————————————————————————————————————————————————————————
	// Valido o código de barras de tributos e concessionarias lido (não vem com DV)
	// Segmento, substring(2,1) do codigo de barras, onde:
	// 1 = Prefeituras (IPTU)
	// 2 = Saneamento 
	// 3 = Energia Elétrica e Gás 
	// 4 = Telecomunicações
	//———————————————————————————————————————————————————————————————————————————————
	elseif lRet .and. Len(cCodBar)==44 .and. Left(cCodBar,1) == "8"
	
		cCodBar := 	Substr(cCodBar,1,11) +;
					Mod10(Substr(cCodBar,1,11)) +;
					Substr(cCodBar,12,11) +;
					Mod10(Substr(cCodBar,12,11)) +;
					Substr(cCodBar,23,11) +;
					Mod10(Substr(cCodBar,23,11)) +;
					Substr(cCodBar,34,11) +;
					Mod10(Substr(cCodBar,34,11))
						
		M->E2_CODBAR := cCodBar
			
/*
	comentado em 25/02/2015, pois nao encontrei a formula para calculo do DV de FGTS
	//———————————————————————————————————————————————————————————————————————————————
	// Valido o código de barras de tributos e concessionarias digitado
	//———————————————————————————————————————————————————————————————————————————————
	elseif lRet .and. Len(cCodBar)==48

		if Mod10(Substr(cCodBar,1,11)) != Substr(cCodBar,12,1)
			cMsg := "1o bloco, "
			lRet := .F.
		endif
		
		if Mod10(Substr(cCodBar,13,11)) != Substr(cCodBar,24,1)
			cMsg := "2o bloco, "
			lRet := .F.
		endif
		
		if Mod10(Substr(cCodBar,25,11)) != Substr(cCodBar,36,1)
			cMsg := "3o bloco, "
			lRet := .F.
		endif
		
		if Mod10(Substr(cCodBar,37,11)) != Substr(cCodBar,48,1)
			cMsg := "4o bloco, "
			lRet := .F.
		endif
		
		if !lRet
			Help(" ", 1, "ATENÇÃO", , "Código de barras inválido. Verifique dígito verificador no " + cMsg + cEol + cFixo, 1)
		endif
*/			
	endif

endif

Return(lRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MOD10                                                         /@
@type				Static Function                                               /@
@date				20/02/2014                                                    /@
@description	Acionado pela user function VLCODBAR. Calcula dígito verifi-
					cador pelo Modulo 10.                                         /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use				Clientes Opção Um Consultoria                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function Mod10(cCodBar)
Local nSoma	:= 0
Local nMult	:= 2
Local nI, nK, cRet, cResult

for nI := Len(cCodBar) to 1 Step -1
	cResult := AllTrim(Str(Val(Substr(cCodBar,nI,1)) * nMult))
	for nK := 1 to Len(cResult)
		nSoma += Val(Substr(cResult,nK,1))
	next
	nMult := iif(nMult == 2, 1, 2)
next

if nSoma % 10 > 0
	cRet := Str(10 - (nSoma % 10),1)
else
    cRet := Str(nSoma % 10,1)
endif

return(cRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		MOD11                                                         /@
@type				Static Function                                               /@
@date				19/02/2014                                                    /@
@description	Acionado pela user function VLCODBAR. Calcula dígito verifi- 
					cador pelo Modulo 11.                                         /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use				Clientes Opção Um Consultoria                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
Static Function Mod11(cCodBar)
Local nSoma	:= 0
Local nMult	:= 2
Local nI, cRet, nResto

for nI := Len(cCodBar) to 1 Step -1
	nSoma += Val(Substr(cCodBar,nI,1)) * nMult
	nMult := iif(nMult == 9, 2, nMult + 1)
next

nSoma := nSoma * 10
if nSoma % 11 == 10 .or. nSoma % 11 == 0
	cRet := "1"
Else
	cRet := Str(nSoma % 11, 1)
Endif

return(cRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		CNAB01                                                        /@
@type		  		User Function                                                 /@
@date				16/10/2010                                                    /@
@description	Preenchimento do valor do pagamento. Quando pagamento de boleto
					envia valor registrado no código de barras, caso contrário, 
					envia o valor líquido do Título, considerando abatimento e/ou
					acréscimo.
			   	   Segmento J - Posição 153 a 167 (pagamento boleto)
				      Segmento A - Posição 120 a 134 (crédito em conta, DOC, TED)/@
@author			Adalberto Moreno Batista                                      /@
@use				Clientes Opção Um Consultoria                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function CNAB01()
Local aArea		:= GetArea()
Local nVlAbat	:= SomaAbat(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, "P" , SE2->E2_MOEDA, DDATABASE, SE2->E2_FORNECE, SE2->E2_LOJA)
Local nValTit	:= SE2->E2_SALDO - SE2->E2_DECRESC - nVlAbat + SE2->E2_ACRESC
Local cValor	:= StrZero(nValTit * 100, 15)

/*
Local cModal	:= SEA->EA_MODELO
if cModal $ "30.31"		//pagto de boletos
	//nValTit	:= SE2->E2_VALOR
	if Len(AllTrim(SE2->E2_CODBAR)) == 44			//codigo de barras lido pelo leitor
		cValor	:= "00000" + Substr(SE2->E2_CODBAR, 10, 10)
	elseif Len(AllTrim(SE2->E2_CODBAR)) == 47		//linha digitavel para boletos registrados
		cValor	:= "00000" + Substr( SE2->E2_CODBAR, 38, 10 )
	elseif Len(AllTrim(SE2->E2_CODBAR)) == 36		//linha digitavel para boletos nao registrados
		cValor	:= Repl("0", 15)
	else
		cValor	:= Repl("0", 15)
	endif
else	
	nVlAbat	:= SomaAbat(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, "P" , SE2->E2_MOEDA, DDATABASE, SE2->E2_FORNECE, SE2->E2_LOJA)
	nValTit	:= SE2->E2_SALDO - SE2->E2_DECRESC - nVlAbat + SE2->E2_ACRESC
	cValor	:= StrZero(nValTit * 100, 15)
endif
*/

RestArea(aArea)

Return(cValor)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		CNAB02                                                        /@
@type				User Function                                                 /@
@date				26/09/2013                                                    /@
@description	Retorna o valor do desconto comparando com o código de barras.
					Para pagamento de boletos, segmento J - Posição 115 a 129
					Para credito em conta, segmento A - Posição 166 a 180         /@
@author			Adalberto Moreno Batista                                      /@
@use				Clientes Opção Um Consultoria                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function CNAB02()
Local nRet		:= 0
Local nVlAbat	:= 0
Local nValBar	:= 0

if Len(AllTrim(SE2->E2_CODBAR)) == 44			//codigo de barras lido pelo leitor
	nVlrBar	:= Val(Substr(SE2->E2_CODBAR, 10, 10)) / 100
	
elseif Len(AllTrim(SE2->E2_CODBAR)) == 47		//linha digitavel para boletos registrados com valor e vencimento
	nValBar	:= Val(Substr(SE2->E2_CODBAR, 38, 10)) / 100
	
else
	nValBar	:= SE2->E2_VALOR

endif

//———————————————————————————————————————————————————————————————————————————————
// Comparo se o valor encontrado no código de barras é igual ao valor do título.
// IGUAL     - indica que o código de barras é o original, portanto deve ser 
//             enviado valor de desconto.
// DIFERENTE - indica que o código de barras foi atualizado com o valor de 
//             desconto, portanto envio ZERO no valor do desconto
// O envio do valor do título foi contemplado com a funçao CNAB08.
//———————————————————————————————————————————————————————————————————————————————
if nValBar == SE2->E2_VALOR
	nVlAbat	:= SomaAbat(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, "P", SE2->E2_MOEDA, dDataBase, SE2->E2_FORNECE, SE2->E2_LOJA)
	nRet		:= (SE2->E2_DECRESC + nVlAbat) * 100
endif
	
Return(StrZero(nRet, 15))


/*/
———————————————————————————————————————————————————————————————————————————————
@function		CNAB03                                                        /@
@type				User function                                                 /@
@date				11/10/2013                                                    /@
@description	Preenche o nosso número.
					Segmento A - Posição 135 a 154
					Segmento J - Posição 203 a 222
					Segmento O - Posição 143 a 162
					Segmento N - Posição 038 a 057
@author			Adalberto Moreno Batista                                      /@
@use				Clientes Opção Um Consultoria                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function CNAB03()
Local cRet := Repl(" ",20)

if Len( AllTrim(SE2->E2_CODBAR) ) == 44			//codigo de barras lido pelo leitor
	cRet	:= Substr(SE2->E2_CODBAR, 26, 11)  //"0" + Substr(SE2->E2_CODBAR, 26, 11)
	
elseif Len( AllTrim(SE2->E2_CODBAR) ) == 47		//linha digitavel para boletos registrados
	cRet	:= Substr(SE2->E2_CODBAR, 12, 9) + Substr(SE2->E2_CODBAR, 22, 2)  //"0" + Substr(SE2->E2_CODBAR, 12, 9) + Substr(SE2->E2_CODBAR, 22, 2)
	
endif
	
Return(cRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		CNAB04                                                        /@
@type				User function                                                 /@
@date				14/04/2014                                                    /@
@description	Preenche o detalhe para pagamentos de tributos.
					Somente segmento N
               Posição 001 a 240                                             /@
@author			Adalberto Moreno Batista                                      /@
@use				Clientes Opção Um Consultoria                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function CNAB04()
Local cRet 	:= ""
Local cCNPJ := U_CNAB06()

if SEA->EA_MODELO == "16" //DARF Comum (Preta)
	
	cRet :=	Strzero(val(SE2->E2_CODRET),6)+; // PadR(SE2->E2_CODRET, 6) +; //Código da Receita com 6 dígitos conforme layout da Febraban
				"01" +;
				cCNPJ +;							//Left(SM0->M0_CGC, 14)
				"16" +;
				GravaData(SE2->E2_X_PAPU, .F., 5) +;
				Strzero(0,17) +;
				StrZero(SE2->E2_VALOR * 100, 15) +;
				StrZero(SE2->(E2_ACRESC - E2_X_JUROS) * 100, 15) +; //Valor da Multa
				StrZero(SE2->E2_X_JUROS * 100, 15) +; //Valor dos Juros / Encargos
				GravaData(SE2->E2_VENCTO,.F.,5) +;
				Space(18)

elseif SEA->EA_MODELO == "17"		//GPS
	
	cRet :=	Strzero(val(SE2->E2_CODRET),6) +; //Código da Receita com 6 dígitos conforme layout Febraban)
				"01" +;
				cCNPJ +;							//Left(SM0->M0_CGC, 14)
				"17" +;
				StrZero(Month(SE2->E2_X_PAPU),2) + StrZero(Year(SE2->E2_X_PAPU),4) +;
				StrZero((SE2->E2_VALOR - SE2->E2_XOUTEN) * 100, 15) +;
				StrZero(SE2->E2_XOUTEN * 100, 15) +;
				StrZero(SE2->E2_ACRESC * 100, 15) +; //Valor Atualizacao Monetaria
				Space(45)

elseif SEA->EA_MODELO == "18" 			//DARF Simples (Verde)

	cRet := 	PadR(SE2->E2_CODRET, 6) +; //Código da Receita com 6 dígitos conforme layout da Febraban
				"01" +;
				cCNPJ +;							//Left(SM0->M0_CGC, 14)
				"18" +;
				GravaData(SE2->E2_X_PAPU, .F., 5) +;
				StrZero(SE2->E2_X_RECAC * 100, 15) +;
				StrZero(SE2->E2_X_PDARF * 100, 7) +;
				StrZero(SE2->E2_VALOR * 100, 15) +;
				StrZero(SE2->(E2_ACRESC - E2_X_JUROS) * 100, 15) +;  //Valor da Multa
				StrZero(SE2->E2_X_JUROS * 100, 15) +;  // Valor dos Juros / Encargos
				Space(21)
				
elseif SEA->EA_MODELO == "22"	 //GARE 

	cRet := 	PadR(SE2->E2_CODRET, 6) +; //Código da Receita com 6 dígitos conforme layout da Febraban                        
				"01" +;												
				cCNPJ +;							//Left(SM0->M0_CGC, 14)
				"22" +;
				GravaData(SE2->E2_VENCTO, .F., 5) +;      		                          
				Left(SM0->M0_INSC, 12) +;					
				StrZero(0,13) +;
				StrZero(Month(SE2->E2_X_PAPU),2) + StrZero(Year(SE2->E2_X_PAPU),4) +;
				Strzero(0,13) +;
				StrZero(SE2->E2_VALOR * 100, 15) +;
				StrZero(SE2->E2_X_JUROS * 100, 14) +; //Valor dos Juros - Encargos
				StrZero(SE2->(E2_ACRESC - E2_X_JUROS) * 100, 14) +; //Valor da Multa
				Space(1)

endif

Return(cRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		CNAB05                                                        /@
@type				User function                                                 /@
@date				26/11/2014                                                    /@
@description	Retorna a sequencia do codigo de barras em 44 posições.
					Posição Tamanho Conteúdo
					01 a 03    3    Identificação do banco
					04 a 04    1    Código da moeda (Real = 9, Outras=0)
					05 a 05    1    Dígito verificador do código de barras
					06 a 09    4    Fator de vencimento
					10 a 19   10    Valor
					20 a 44   25    Campo livre
					
					Para linha digitável, a sequência das instruções é:
					1o.campo: Composto pelo código de Banco, código da moeda, as 
					          cinco primeiras posições do campo livre e o dígito
					          verificador deste campo.
					2o.campo: Composto pelas posições 6ª a 15ª do campo livre e o
					          dígito verificador deste campo.
					3o.campo: Composto pelas posições 16ª a 25ª do campo livre e
					          o dígito verificador deste campo.
					4o.campo: Composto pelo dígito verificador do código de barras,
					          ou seja, a 5a. posição do código de barras.
					5o.campo: Composto pelo fator de vencimento com 4(quatro)
					          caracteres e o valor do documento com 10(dez) 
					          caracteres, sem separadores e sem edição.
					23790.0310D__40031.77200D__28009.52790D__D__10010000000000    /@
@author			Adalberto Moreno Batista                                      /@
@use				Clientes Opção Um Consultoria                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function CNAB05()
Local cRet := AllTrim(SE2->E2_CODBAR)

if Len(cRet) == 44			//codigo de barras lido pelo leitor
	cRet := AllTrim(SE2->E2_CODBAR)
	
elseif Len(cRet) == 47		//linha digitavel para boletos registrados com valor e vencimento
	cRet	:= Substr(SE2->E2_CODBAR, 1, 3) /*Id Banco*/ +;
				Substr(SE2->E2_CODBAR, 4, 1) /*Moeda*/+;
				Substr(SE2->E2_CODBAR, 33, 1) /*DV*/ +;
				Substr(SE2->E2_CODBAR, 34, 4) /*Fator vencto*/ +;
				Substr(SE2->E2_CODBAR, 38, 10) /*Valor*/ +;
				Substr(SE2->E2_CODBAR, 5, 5) + Substr(SE2->E2_CODBAR, 11, 10) + Substr(SE2->E2_CODBAR, 22, 10) /*Campo livre*/

elseif Len(cRet) == 36		//linha digitavel para boletos registrados sem valor e vencimento
	cRet	:= Substr(SE2->E2_CODBAR, 1, 3) /*Id Banco*/ +;
				Substr(SE2->E2_CODBAR, 4, 1) /*Moeda*/+;
				Substr(SE2->E2_CODBAR, 33, 1) /*DV*/ +;
				Replicate("0", 4) /*Fator vencto*/ +;
				Replicate("0", 10) /*Valor*/ +;
				Substr(SE2->E2_CODBAR, 5, 5) + Substr(SE2->E2_CODBAR, 11, 10) + Substr(SE2->E2_CODBAR, 22, 10) /*Campo livre*/

elseif Len(cRet) == 48		//tributos ou concessionárias
	cRet	:= Substr(SE2->E2_CODBAR, 1, 11) +;
				Substr(SE2->E2_CODBAR, 13, 11) +;
				Substr(SE2->E2_CODBAR, 25, 11) +;
				Substr(SE2->E2_CODBAR, 37, 11)

endif
	
Return(cRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		CNAB06                                                        /@
@type				User function                                                 /@
@date				10/04/2015                                                    /@
@description	Retorna o CNPJ da matriz, filial ou do fornecedor, de acordo
					com tipo do tributo.
					Utiliza parametros especificos para este controle.            /@
@author			Adalberto Moreno Batista                                      /@
@use				Clientes Opção Um Consultoria                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function CNAB06()
Local aArea			:= GetArea()
Local aAreaSA2		:= SA2->(GetArea())
Local aAreaSE2		:= SE2->(GetArea())
Local cCNPJ 		:= Left(GetMV("BR_CNPJMTZ"), 14)				//Inicio a variável de retorno com o CNPJ da Matriz (regra)
Local cCodRet		:= AllTrim(SE2->E2_CODRET)
Local cCodRetFil	:= AllTrim(GetMV("BR_CNPJFIL", .F., ""))	//Armazena os códigos de retenção que obrigam o preenchimento do CNPJ da empresa que estaja realizando o pagamento
Local cCodRetFor	:= AllTrim(GetMV("BR_CNPJFOR", .F., ""))	//Armazena os códigos de retenção que obrigam o preenchimento do CNPJ do fornecedor para quem será realizado o pagamento
Local cEol			:= chr(13) + chr(10)
Local cChave

//———————————————————————————————————————————————————————————————————————————————
// Pagamento de tributos obrigam que o CNPJ da matriz seja enviado como pagadora, 
// mesmo que o titulo seja gerado em uma filial, exceto para os pagamentos:
//     IPI (cod.ret 5123) 										- O CNPJ da filial
//     GPS/INSS apurado pela folha, (cod.ret 2100) 	- O CNPJ da filial
//     GPS/INSS retido do fornecedor (cod.ret 2631) 	- O CNPJ do fornecedor
// 
// ATENÇÃO: Para pagamento de tributos será necessário o preenchimento do 
//          respectivo código de retenção
//———————————————————————————————————————————————————————————————————————————————
if !Empty(cCodRet)

	// Verifico se o código de retenção está parametrizado para enviar o CNPJ da empresa que esteja realizando o pagamento
	if cCodRet $ cCodRetFil
	
		cCNPJ := Left(SM0->M0_CGC, 14)

	// Verifico se o código de retenção está parametrizado para enviar o CNPJ do fornecedor
	elseif cCodRet $ cCodRetFor
	
		if !Empty(SE2->E2_TITPAI)
	
			cChave := SE2->E2_TITPAI

			SA2->(dbSetOrder(1))		//A2_FILIAL + A2_COD + A2_LOJA
			SE2->(dbSetOrder(1))		//E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA
			
			if SE2->(dbSeek(xFilial("SE2") + cChave))
			
				SA2->(dbSeek(xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA))
				cCNPJ := Left(SA2->A2_CGC, 14)
				
			else
			
				cCNPJ := Repl(" ", 14)
				Help(" ", 1, "ATENÇÃO",, "O titulo pai chave " + cChave + " não foi encontrado, portanto o título de imposto será recusado pelo banco. Verifique!" + cEol + cEol + "Função CNfonte CNABXFUN (Específico Brasitech).", 1)
				
			endif
			
			RestArea(aAreaSA2)
			RestArea(aAreaSE2)
			RestArea(aArea)
			
		else
		
			cCNPJ := Repl(" ", 14)
			Help(" ", 1, "ATENÇÃO",, "O titulo chave de pesquisa (FILIAL + PREFIXO + NUMERO + PARCELA + TIPO + FORNECEDOR + LOJA) " + SE2->(E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA) + " está com código de retenção de imposto, porém não foi gerado automaticamente pelo sistema, portanto será recusado pelo banco. Verifique!" + cEol + cEol + "Funç6(), fonte CNABXFUN (Específico Brasitech).", 1)
			
		endif

	endif

endif

Return(cCNPJ)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		CNAB07                                                        /@
@type				User function                                                 /@
@date				17/04/2015                                                    /@
@description	Retorna a razão social do contribuinte do imposto. Poderá ser
					a empresa ou o fornecedor de acordo com o tipo do tributo.
					Utiliza parametros especificos para este controle.            /@
@author			Adalberto Moreno Batista                                      /@
@use				Clientes Opção Um Consultoria                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function CNAB07()
Local aArea			:= GetArea()
Local aAreaSA2		:= SA2->(GetArea())
Local aAreaSE2		:= SE2->(GetArea())
Local cRazao 		:= Left(SM0->M0_NOMECOM, 30)				//Inicio a variável de retorno com o CNPJ da Matriz (regra)
Local cCodRet		:= AllTrim(SE2->E2_CODRET)
Local cCodRetFor	:= AllTrim(GetMV("BR_CNPJFOR", .F., ""))	//Armazena os códigos de retenção que obrigam o preenchimento do CNPJ do fornecedor para quem será realizado o pagamento
Local cEol			:= chr(13) + chr(10)
Local cChave

//———————————————————————————————————————————————————————————————————————————————
// Pagamento de tributos obrigam que a razao social do o CNPJ da matriz seja enviado como pagadora, 
// mesmo que o titulo seja gerado em uma filial, exceto para os pagamentos:
//     IPI (cod.ret 5123) 										- Razão social filial
//     GPS/INSS apurado pela folha, (cod.ret 2100) 	- O CNPJ da filial
//     GPS/INSS retido do fornecedor (cod.ret 2631) 	- O CNPJ do fornecedor
// 
// ATENÇÃO: Para pagamento de tributos será necessário o preenchimento do 
//          respectivo código de retenção
//———————————————————————————————————————————————————————————————————————————————
if !Empty(cCodRet)

	// Verifico se o código de retenção está parametrizado para enviar o CNPJ do fornecedor
	if cCodRet $ cCodRetFor
	
		if !Empty(SE2->E2_TITPAI)
	
			cChave := SE2->E2_TITPAI

			SA2->(dbSetOrder(1))		//A2_FILIAL + A2_COD + A2_LOJA
			SE2->(dbSetOrder(1))		//E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA
			
			if SE2->(dbSeek(xFilial("SE2") + cChave))
			
				SA2->(dbSeek(xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA))
				cRazao := Left(SA2->A2_NOME, 30)
				
			else
			
				cRazao := Space(30)
				
			endif
			
			RestArea(aAreaSA2)
			RestArea(aAreaSE2)
			RestArea(aArea)
			
		else
		
			cRazao := Space(30)
			
		endif

	endif

endif

Return(cRazao)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		CNAB08                                                        /@
@type				User function                                                 /@
@date				03/07/2015                                                    /@
@description	Retorna o valor do titulo para pagamento de boletos, sequencia
					J, comparando o valor do codigo de barras.                    /@
@author			Adalberto Moreno Batista                                      /@
@use				Clientes Opção Um Consultoria                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function CNAB08()
Local nRet

if Len(AllTrim(SE2->E2_CODBAR)) == 44			//codigo de barras lido pelo leitor
	nRet	:= Val(Substr(SE2->E2_CODBAR, 10, 10))
	
elseif Len(AllTrim(SE2->E2_CODBAR)) == 47		//linha digitavel para boletos registrados com valor e vencimento
	nRet	:= Val(Substr(SE2->E2_CODBAR, 38, 10))

else
	nRet	:= SE2->E2_VALOR * 100
	
endif

Return(StrZero(nRet, 15))


/*/
———————————————————————————————————————————————————————————————————————————————
@function		CNAB09                                                        /@
@type				User function                                                 /@
@date				03/07/2015                                                    /@
@description	Retorna o valor do acrescimo comparando com o código de barras.
					Somente para pagamento de boletos, sequencia J.               /@
@author			Adalberto Moreno Batista                                      /@
@use				Clientes Opção Um Consultoria                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function CNAB09()
Local nRet		:= 0
Local nValBar	:= 0

if Len(AllTrim(SE2->E2_CODBAR)) == 44			//codigo de barras lido pelo leitor
	nVlrBar	:= Val(Substr(SE2->E2_CODBAR, 10, 10)) / 100
	
elseif Len(AllTrim(SE2->E2_CODBAR)) == 47		//linha digitavel para boletos registrados com valor e vencimento
	nValBar	:= Val(Substr(SE2->E2_CODBAR, 38, 10)) / 100
	
else
	nValBar	:= SE2->E2_VALOR

endif

//———————————————————————————————————————————————————————————————————————————————
// Comparo se o valor encontrado no código de barras é igual ao valor do título.
// IGUAL     - indica que o código de barras é o original, portanto deve ser 
//             enviado valor de acrescimo.
// DIFERENTE - indica que o código de barras foi atualizado com o valor de 
//             juros e multa, portanto envio ZERO no valor do acrescimo
// O envio do valor do título foi contemplado com a funçao CNAB08.
//———————————————————————————————————————————————————————————————————————————————
if nValBar == SE2->E2_VALOR
	nRet	:= SE2->E2_ACRESC * 100
endif
	
Return(StrZero(nRet, 15))


/*/
———————————————————————————————————————————————————————————————————————————————
@function		CNAB10                                                        /@
@type				User function                                                 /@
@date				11/09/2015                                                    /@
@description	Retorna o valor de abatimento de um titulo a receber.         /@
@author			Adalberto Moreno Batista                                      /@
@use				Clientes Opção Um Consultoria                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function CNAB10()
Local nAbat    := SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA,"R", 1,, SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_FILIAL)
Local nDesc		:= SE1->E1_DECRESC
Local nRet		:= (nAbat + nDesc) * 100
Return(StrZero(nRet, 13))


/*/
———————————————————————————————————————————————————————————————————————————————
@function		CNAB11                                                        /@
@type				User function                                                 /@
@date				16/12/2015                                                    /@
@description	Retorna o valor de cheio do título, saldo + acréscimo.        /@
@author			Adalberto Moreno Batista                                      /@
@use				Clientes Opção Um Consultoria                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function CNAB11()
Local nRet := SE1->(E1_SALDO + E1_ACRESC) * 100
Return(StrZero(nRet, 13))


/*/
———————————————————————————————————————————————————————————————————————————————
@function		CNAB12                                                        /@
@type				User function                                                 /@
@date				16/12/2015                                                    /@
@description	Retorna se Pessoa Física (01-CPF) ou Jurídica (02-CNPJ).      /@
@author			Luciane Davino                                                /@
@use				Clientes Opção Um Consultoria                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function CNAB12()
Local cRet
      
if FunName() != "FINA150" .and. AllTrim(FI2->FI2_OCORR) $ "04/05"
	cRet := Repl("0",2)
else
	if SA1->A1_PESSOA == "F"
		cRet := "01"
	else
		cRet := "02"
	endif
endif
Return(cRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		CNAB13                                                        /@
@type				User function                                                 /@
@date				16/12/2015                                                    /@
@description	Retorna número do CPF ou CNPJ.                                /@
@author			Luciane Davino                                                /@
@use				Clientes Opção Um Consultoria                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function CNAB13()
Local cRet

if FunName() != "FINA150" .and. AllTrim(FI2->FI2_OCORR) $ "04/05"
	cRet := Repl("0", 14)
else
	cRet := SA1->A1_CGC
endif
Return(cRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		CNAB14                                                        /@
@type				User function                                                 /@
@date				16/12/2015                                                    /@
@description	Retorna o Nome do Sacado.                                     /@
@author			Luciane Davino                                                /@
@use				Clientes Opção Um Consultoria                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function CNAB14()
Local cRet

if FunName() != "FINA150" .and. AllTrim(FI2->FI2_OCORR) $ "04/05"
	cRet := Space(40)
else
	cRet := SA1->A1_NOME
endif
Return(cRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		CNAB15                                                        /@
@type				User function                                                 /@
@date				16/12/2015                                                    /@
@description	Retorna Rua, Número e Complemento do Sacado.                  /@
@author			Luciane Davino                                                /@
@use				Clientes Opção Um Consultoria                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function CNAB15()
Local cRet

if FunName() != "FINA150" .and. AllTrim(FI2->FI2_OCORR) $ "04/05"
	cRet := Space(40)
else
	if empty(SA1->A1_ENDCOB)
		cRet := SA1->A1_END
	else
		cRet := SA1->A1_ENDCOB
	endif
endif
Return(cRet) 


/*/
———————————————————————————————————————————————————————————————————————————————
@function		CNAB16                                                        /@
@type				User function                                                 /@
@date				16/12/2015                                                    /@
@description	Retorna o Bairro do Sacado.                                   /@
@author			Luciane Davino                                                /@
@use				Clientes Opção Um Consultoria                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function CNAB16()
Local cRet

if FunName() != "FINA150" .and. AllTrim(FI2->FI2_OCORR) $ "04/05"
	cRet := Space(12)
else
	if empty(SA1->A1_BAIRROC)
		cRet := SA1->A1_BAIRRO
	else
		cRet := SA1->A1_BAIRROC
	endif
endif
Return(cRet) 


/*/
———————————————————————————————————————————————————————————————————————————————
@function		CNAB17                                                        /@
@type				User function                                                 /@
@date				16/12/2015                                                    /@
@description	Retorna o CEP do Sacado.										        /@
@author			Luciane Davino                                                /@
@use				Clientes Opção Um Consultoria                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function CNAB17()
Local cRet

if FunName() != "FINA150" .and. AllTrim(FI2->FI2_OCORR) $ "04/05"
	cRet := Repl("0",9)
else
	if empty(SA1->A1_CEPC)
		cRet := SA1->A1_CEP
	else
		cRet := SA1->A1_CEPC
	endif
endif
Return(cRet)


/*/
———————————————————————————————————————————————————————————————————————————————
@function		CNAB18                                                        /@
@type				User function                                                 /@
@date				16/12/2015                                                    /@
@description	Retorna a Cidade do Sacado.                                   /@
@author			Luciane Davino                                                /@
@use				Clientes Opção Um Consultoria                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function CNAB18()
Local cRet

if FunName() != "FINA150" .and. AllTrim(FI2->FI2_OCORR) $ "04/05"
	cRet := Space(15)
else
	if empty(SA1->A1_MUNC)
		cRet := SA1->A1_MUN
	else
		cRet := SA1->A1_MUNC
	endif
endif
Return(cRet) 


/*/
———————————————————————————————————————————————————————————————————————————————
@function		CNAB19                                                        /@
@type				User function                                                 /@
@date				16/12/2015                                                    /@
@description	Retorna o Estado do Sacado.                                   /@
@author			Luciane Davino                                                /@
@use				Clientes Opção Um Consultoria                                 /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function CNAB19()
Local cRet

if FunName() != "FINA150" .and. AllTrim(FI2->FI2_OCORR) $ "04/05"
	cRet := Space(2)
else
	if empty(SA1->A1_ESTC)
		cRet := SA1->A1_EST
	else
		cRet := SA1->A1_ESTC
	endif
endif
Return(cRet)
