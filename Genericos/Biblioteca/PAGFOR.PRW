#include "rwmake.ch"
#include "protheus.ch"
/*/
———————————————————————————————————————————————————————————————————————————————
@fonte			PAGFOR.PRW                                                   /@
@date		  	11/11/2011                                                   /@
@description	fonte com funções utilizadas no CNAB a pagar do Bradesco,
				PAGFOR. No Protheus é configurado com o .CPE                 
				1) Usar o E2_IDCNAB ou criar o parametro ES_SEQPF (Numérico)
				   para gerar numero sequencia de pagamentos. Ajustar o BPF05
				2) Verificar quais os modos de pagamento realizados na empre-
				   sa e se os codigos dos modos batem com o solicitado pelo 
				   Bradesco, vide BPF06. Verficar a necessidade de alteracao
				   do BPF06.
				3) Verificar função para validar codigo de barras.           /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Clientes Opção Um Consultoria                                /@
———————————————————————————————————————————————————————————————————————————————
/*/


/*
———————————————————————————————————————————————————————————————————————————————
@function		BPF01                                                        /@
@type			User Function                                                /@
@date			11/11/2011                                                   /@
@description	Retornar o fator de vencimento do título encontrado no código
				de barras.
               	Posição 191 a 194                                            /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Clientes Opção Um Consultoria                                /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function BPF01()
Local cFatVcto := "0000"

if Len( AllTrim(SE2->E2_CODBAR) ) == 47		//Codigo de barras linha digitada

	cFatVcto := Substr( SE2->E2_CODBAR, 34, 4 )

elseif Len( AllTrim(SE2->E2_CODBAR) ) == 44		//Codigo de barras leitor codigo

	cFatVcto := Substr(SE2->E2_CODBAR, 6, 4)

endif

Return(cFatVcto)


/*
———————————————————————————————————————————————————————————————————————————————
@function		BPF02                                                        /@
@type			User Function                                                /@
@date			11/11/2011                                                   /@
@description	Retorna o código do banco do código de barras ou do cadastro
				do fornecedor.
               	Posição 096 a 098                                            /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Clientes Opção Um Consultoria                                /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function BPF02()
Local cBco := iif(!empty(SE2->E2_FORBCO), SE2->E2_FORBCO, SA2->A2_BANCO)

if Len(AllTrim(SE2->E2_CODBAR)) == 44 .or. Len(AllTrim(SE2->E2_CODBAR)) == 47

	cBco := Substr(SE2->E2_CODBAR, 1, 3)

endif

Return(cBco)


/*
———————————————————————————————————————————————————————————————————————————————
@function		BPF03                                                        /@
@type			User Function                                                /@
@date			11/11/2011                                                   /@
@description	Retorna o código e dígito verificador da agência. 
               	Posição 099 a 104                                            /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Clientes Opção Um Consultoria                                /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function BPF03()
Local cAgencia 	:= "00000"
Local cModal	:= U_BPF06()
Local nMult, nResult, nResto, nDigito, cRetDigito

if Substr(SE2->E2_CODBAR, 1, 3) == "237"		//somente para o Bradesco

	
	if Len( AllTrim( SE2->E2_CODBAR ) ) == 44		//leitura do codigo de barras
		cAgencia  :=  Substr( SE2->E2_CODBAR, 20, 4 )

	elseif Len( AllTrim( SE2->E2_CODBAR ) ) == 47		//linha digitada
		cAgencia  :=  Substr( SE2->E2_CODBAR, 5, 4 )

	endif

	nMult 		:=	(Val( Substr(cAgencia,1,1) ) * 5) +;
					(Val( Substr(cAgencia,2,1) ) * 4) +;
					(Val( Substr(cAgencia,3,1) ) * 3) +;
					(Val( Substr(cAgencia,4,1) ) * 2)
	nResult 	:= Int(nMult / 11)
	nResto		:= Int(nMult % 11)
	nDigito		:= 11 - nResto
	cRetDigito	:= iif(nResto == 0 .or. nResto == 1, "0", Str(nDigito,1))
	cAgencia 	:= "0" + cAgencia + cRetDigito

elseif !cModal $ '30.31'
	
	if !Empty(SE2->E2_FORAGE)
		cAgencia := StrZero( Val(SE2->E2_FORAGE), 5 ) + SE2->E2_FAGEDV
	else
		cAgencia := StrZero( Val(SA2->A2_AGENCIA), 5 ) + SA2->A2_X_DVA
	endif

endif

Return(cAgencia)


/*
———————————————————————————————————————————————————————————————————————————————
@function		BPF04                                                        /@
@type			User Function                                                /@
@date			11/11/2011                                                   /@
@description	Retornar o código da conta corrente. 
               	Posição 105 a 119                                            /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Clientes Opção Um Consultoria                                /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function BPF04()
Local cConta 	:= Repl("0",15)
Local cModal	:= U_BPF06()
Local nMult, nResult, nResto, nDigito, cRetDigito

if Substr(SE2->E2_CODBAR, 1, 3) == "237"	//somente para o Bradesco

	if Len( AllTrim(SE2->E2_CODBAR) ) == 44		//leitura do codigo de barras
		cConta  :=  Substr( SE2->E2_CODBAR, 37, 7 )

	elseif Len( AllTrim( SE2->E2_CODBAR ) ) == 47		//linha digitada
		cConta  :=  Substr( SE2->E2_CODBAR, 24, 7 )

	endif

	nMult 		:= 	(Val( Substr(cConta,1,1) ) * 2) +;
					(Val( Substr(cConta,2,1) ) * 7) +;
					(Val( Substr(cConta,3,1) ) * 6) +;
					(Val( Substr(cConta,4,1) ) * 5) +;
					(Val( Substr(cConta,5,1) ) * 4) +;
					(Val( Substr(cConta,6,1) ) * 3) +;
					(Val( Substr(cConta,7,1) ) * 2)

	nResult 	:= Int(nMult / 11)
	nResto		:= Int(nMult % 11)
	nDigito		:= 11 - nResto
	cRetDigito	:= iif(nResto = 0 .or. nResto = 1, "0 ", PadR( AllTrim( Str( nDigito ) ), 2) )
	cConta		:= "000000" + cConta + cRetDigito

elseif !cModal $ '30.31'
	
	if !Empty(SE2->E2_FORCTA)
		cConta	:= StrZero( Val( SE2->E2_FORCTA ), 13 ) + Left(SE2->E2_FCTADV, 2 )
	else
		 cConta	:= StrZero( Val( SA2->A2_NUMCON ), 13 ) + Left(SA2->A2_X_DVC, 2 )
	endif
	 
endif

Return(cConta)


/*
———————————————————————————————————————————————————————————————————————————————
@function		BPF05                                                        /@
@type			User function                                                /@
@date			16/11/2011                                                   /@
@description	Idenfica o número do pagamento a ser efetuado  alterado ou 
				excluído. Individualiza o pagamento	e não pode se repetir. 
				Gerado  pelo cliente pagador quando do agendamento de paga-
				mento por parte desse, exceto para a modalidade 30-títulos 
				em cobrança  Bradesco, que é fornecido pelo	banco quando da 
				geração do arquivo de rastreamento, o qual deverá ser mantido
				e  informado quando da autorização de agendamento, alteração 
				ou exclusão.
               	Posição 120 a 135                                            /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Clientes Opção Um Consultoria                                /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function BPF05()
Local cRet 		:= Space(16)
Local cModal	:= U_BPF06()

if cModal != '30'

	cRet := PadR(SE2->E2_IDCNAB, 16)

endif

Return(cRet)


/*
———————————————————————————————————————————————————————————————————————————————
@function		BPF06                                                        /@
@type			User Function                                                /@
@date			23/11/2011                                                   /@
@description	Idenfica a modalidade do  pagamento  utilizada no borderô, 
				isto é, o modo com o qual o repasse será feito ao favorecido.
				Exemplo:
				01 - credito em conta
				02 - Cheque OP
				03 - DOC             
				08 - TED (ref. Protheus 41 e 43)
				30 - pagto titulos mesmo banco
				31 - pagto titulos outro banco                               
				aModelos [1] - Código modelo pagamento Protheus
							[2] - Modalidade pagamento no Bradesco
							[3] - Descricao do modelo no Protheus}           /@
				Posição 264 a 265                                            /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Clientes Opção Um Consultoria                                /@
———————————————————————————————————————————————————————————————————————————————
 
*/
User Function BPF06()
Local cRet		:= "00"
Local aArea		:= GetArea()
Local aAreaSEA	:= SEA->(GetArea())
Local aModelos 	:= {	{"01", "01", "Credito em conta corrente"},;
								{"02", "02", "Cheque pagamento / administrativo"},;
								{"03", "03", "DOC"},;
								{"04", "02", "OP a disposicao com aviso para o favorecido"},;
								{"05", "01", "Credito em conta poupanca"},;
								{"06", "01", "Credito em conta corrente mesma titularidade"},;
								{"10", "02", "OP a disposicao sem aviso para o favorecido"},;
								{"13", "00", "Pagamento a Concessionarias"},;
								{"16", "00", "Pagamento de Tributos DARF"},;
								{"17", "00", "Pagamento de Tributos GPS"},;
								{"18", "00", "Pagamento de Tributos DARF SIMPLES"},;
								{"19", "00", "Pagamento de IPTU"},;
								{"21", "00", "Pagamento de Tributos DARJ"},;
								{"22", "00", "Pagamento de Tributos GARE ICMS SP"},;
								{"25", "00", "Pagamento de Tributos IPVA (SP e MG)"},;
								{"27", "00", "Pagamento de Tributos DPVAT"},;
								{"28", "00", "GR-PR com Codigo de Barras"},;
								{"29", "00", "GR-PR sem Codigo de Barras"},;
								{"30", "31", "Liquidacao de titulos em cobranca no mesmo banco"},;
								{"31", "31", "Pagamento de titulos em outros bancos"},;
								{"35", "00", "Pagamento de Tributos FGTS - GFIP"},;
								{"41", "08", "TED - Outro Titular"},;
								{"43", "08", "TED - Mesmo titular"},;
								{"91", "00", "TRIBUTOS - GNRE COM CODIGO DE BARRAS"} }
Local nK

SEA->(dbSetOrder(1))
if SEA->(dbSeek( xFilial("SEA") + SE2->( E2_NUMBOR + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA ) ))
	nK := aScan( aModelos, {|x| x[1] == Left(SEA->EA_MODELO,2)} )
	if nK > 0
		cRet := aModelos[nK, 2]
	endif
endif

RestArea(aAreaSEA)
RestArea(aArea)

Return(cRet)


/*
———————————————————————————————————————————————————————————————————————————————
@function		BPF07                                                        /@
@type			User Function                                                /@
@date			23/11/2011                                                   /@
@description	Retorna a data de vencimento, do respectivo título, com base
				no fator de vencimento do codigo de barras, caso  exista e o
				modelo do borderô seja 31. Caso o codigo esteja em branco,
				utilizo o campo E2_VENCTO.
                Posição 166 a 173                                            /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Clientes Opção Um Consultoria                                /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function BPF07()
Local cVencto 	:= dTOs( SE2->E2_VENCTO )
Local nFatVcto	:= 0
Local dDtBase 	:= cTOd("07/10/97")

if U_BPF06() $ '30.31'	//pagamento de boletos

	if Len( AllTrim(SE2->E2_CODBAR) ) == 47		//Codigo de barras linha digitada
	
		nFatVcto := Val(Substr( SE2->E2_CODBAR, 34, 4 ))
	
	elseif Len( AllTrim(SE2->E2_CODBAR) ) == 44		//Codigo de barras leitor codigo
	
		nFatVcto := Val(Substr( SE2->E2_CODBAR, 6, 4 ))
	
	endif

	if nFatVcto > 0
		cVencto := dTOs( dDtBase + nFatVcto )
	endif
	
endif	

Return(cVencto)


/*
———————————————————————————————————————————————————————————————————————————————
@function		BPF08                                                        /@
@type			User Function                                                /@
@date			23/11/2011                                                   /@
@description	Preenchimento das informações complementares de acordo com o 
				modelo do borderô.
                Posição 374 a 413                                            /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Clientes Opção Um Consultoria                                /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function BPF08()
Local aArea		:= GetArea()
Local aAreaSEA	:= SEA->(GetArea())
Local cModal	:= U_BPF06()
Local cRet		:= space(40)
Local cMoeda, cDAC, cLivre, cTit

if cModal $ '01.05'			//credito em conta
	cRet := space(40)

elseif cModal $ '03.08'		//doc ou ted
	cTit := "C"
	SEA->(dbSetOrder(1))
	if SEA->(dbSeek( xFilial("SEA") + SE2->(E2_NUMBOR + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA) ))
		if Left(SEA->EA_MODELO,2) == "43"
			cTit	:= "D"
		endif
	endif
	RestArea(aAreaSEA)
	RestArea(aArea)
	
	cRet := cTit + '0000000301' + space(29)
	
elseif cModal $ '30.31'		//pagto de boletos
	//———————————————————————————————————————
	// retorno previsto de:
	//		374 a 398 (25) campo livre
	//		399 a 399 (1) DAC         
	//		400 a 400 (1) moeda       
	//		401 a 413 (13) brancos    
	//———————————————————————————————————————
	if Len( AllTrim(SE2->E2_CODBAR) ) == 44
		cLivre		:= Substr(SE2->E2_CODBAR, 20, 25)
		cDAC		:= Substr(SE2->E2_CODBAR, 5, 1)
		cMoeda		:= Substr(SE2->E2_CODBAR, 4, 1)
		
	elseif Len( AllTrim(SE2->E2_CODBAR) ) == 47 .or. Len(AllTrim(SE2->E2_CODBAR)) == 36
		cLivre		:= Substr(SE2->E2_CODBAR, 5, 5) + Substr(SE2->E2_CODBAR, 11, 10) + Substr(SE2->E2_CODBAR, 22, 10)
		cDAC		:= Substr(SE2->E2_CODBAR, 33, 1)
		cMoeda		:= Substr(SE2->E2_CODBAR, 4, 1)
	
	else
		cLivre		:= space(25)
		cDAC		:= " "
		cMoeda		:= " "

	endif

	cRet := cLivre + cDAC +  cMoeda + space(13)
	
endif

Return(cRet)


/*
———————————————————————————————————————————————————————————————————————————————
@function		BPF09                                                        /@
@type			User Function                                                /@
@date			16/10/2010                                                   /@
@description	Preenchimento do valor do pagamento. Se borderô do tipo 31,
				envia o valor do registrado no codigo de barras, caso contrário
				envia o  valor  líquido valor do Titulo, considerando abatimento
				e/ou acréscimo.
                Posição 205 a 219                                            /@
@author			Adalberto Moreno Batista                                     /@
@use			Clientes Opção Um Consultoria                                /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function BPF09()
Local aArea		:= GetArea()
Local cModal	:= U_BPF06()
Local nValTit, nVlAbat, cValor

if cModal $ '30.31'		//pagto de boletos

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
	//Funcao Substituida pelo SOMAABAT(), apos a atualizacao do TOP4 AS400 em 30/11/2010.
	//_nVlAbat    := GetAdvFVal('SE2','E2_SALDO',xFilial('SE2')+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+'AB-'+E2_FORNECE+E2_LOJA),1,0)
	nVlAbat	:= SOMAABAT(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, "P" , SE2->E2_MOEDA, DDATABASE, SE2->E2_FORNECE, SE2->E2_LOJA)
	nValTit	:= SE2->E2_SALDO - SE2->E2_DECRESC - nVlAbat + SE2->E2_ACRESC

	cValor	:= StrZero(nValTit * 100, 15)

endif

RestArea(aArea)

Return(cValor)



/*
———————————————————————————————————————————————————————————————————————————————
@function		BPF10                                                        /@
@type			User Function                                                /@
@date			26/09/2013                                                   /@
@description	Preenchimento do código da carteira.
                Posição 136 a 138                                            /@
@author			Adalberto Moreno Batista                                     /@
@use			Clientes Opção Um Consultoria                                /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function BPF10()
Local cRet := "000"

if Left(SE2->E2_CODBAR,3) == "237"
	
	if Len(AllTrim(SE2->E2_CODBAR)) == 44			//codigo de barras lido pelo leitor
		cRet := "0" + Substr(SE2->E2_CODBAR, 24, 2)
		
	else											//linha digitavel para boletos registrados
		cRet := "0" + Substr(SE2->E2_CODBAR, 9, 1) + Substr(SE2->E2_CODBAR, 11, 1)
	
	endif
		
endif

Return(cRet)


/*
———————————————————————————————————————————————————————————————————————————————
@function		BPF11                                                        /@
@type			User Function                                                /@
@date			26/09/2013                                                   /@
@description	Preenchimento da identificação do fornecedor.
                Posição 003 a 017                                            /@
@author			Adalberto Moreno Batista                                     /@
@use			Clientes Opção Um Consultoria                                /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function BPF11()
Local cRet

if Len(AllTrim(SA2->A2_CGC)) < 14
	cRet := Left(SA2->A2_CGC, 9) + "0000" + Substr(SA2->A2_CGC, 10, 2)
else
	cRet := "0" + SA2->A2_CGC
endif

Return(cRet)


/*
———————————————————————————————————————————————————————————————————————————————
@function		BPF12                                                        /@
@type			User Function                                                /@
@date			26/09/2013                                                   /@
@description	Preenchimento do valor do pagamento a ser realizado.
                Posição 205 a 219                                            /@
@author			Adalberto Moreno Batista                                     /@
@use			Clientes Opção Um Consultoria                                /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function BPF12()
Local nRet, nVlAbat

nVlAbat := SOMAABAT(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, "P", SE2->E2_MOEDA, DDATABASE, SE2->E2_FORNECE, SE2->E2_LOJA)
nRet	:= (SE2->E2_SALDO - SE2->E2_DECRESC - nVlAbat + SE2->E2_ACRESC) * 100

Return(StrZero(nRet,15))


/*
———————————————————————————————————————————————————————————————————————————————
@function		BPF13                                                        /@
@type			User Function                                                /@
@date			26/09/2013                                                   /@
@description	Preenche o valor do desconto do título.
                Posição 220 a 234                                            /@
@author			Adalberto Moreno Batista                                     /@
@use			Clientes Opção Um Consultoria                                /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function BPF13()
Local nVlAbat	:= SomaAbat(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, "P", SE2->E2_MOEDA, dDataBase, SE2->E2_FORNECE, SE2->E2_LOJA)
Local nRet		:= (SE2->E2_DECRESC + nVlAbat) * 100

Return(StrZero(nRet,15))


/*
———————————————————————————————————————————————————————————————————————————————
@function		BPF14                                                        /@
@type			User function                                                /@
@date			11/10/2013                                                   /@
@description	Preenche o nosso número.
                Obrigatório somente quando o banco for igual a 237 (Bradesco)
                (extraído do Código de Barras ou Linha Digitável). 
                Para os demais bancos, preencher com zeros.
                Posição 139 a 150                                            /@
@author			Adalberto Moreno Batista                                     /@
@use			Clientes Opção Um Consultoria                                /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function BPF14()
Local cRet := Repl("0",12)

if Left(SE2->E2_CODBAR,3) == "237"

	if Len( AllTrim(SE2->E2_CODBAR) ) == 44			//codigo de barras lido pelo leitor
		cRet	:= "0" + Substr(SE2->E2_CODBAR, 26, 11)
		
	elseif Len( AllTrim(SE2->E2_CODBAR) ) == 47		//linha digitavel para boletos registrados
		cRet	:= "0" + Substr(SE2->E2_CODBAR, 12, 9) + Substr(SE2->E2_CODBAR, 22, 2)
		
	endif
	
endif

Return(cRet)


/*
———————————————————————————————————————————————————————————————————————————————
@function		BPF15                                                        /@
@type			User function                                                /@
@date			21/01/2014                                                   /@
@description	Preenche o número da conta complementar. Obrigatório quando 
				o cliente pagador for optante pelo pagamento diferenciado, 
				ou seja contas de débito diferenciadas.
                Posição 480 a 486                                            /@
@author			Adalberto Moreno Batista                                     /@
@use			Clientes Opção Um Consultoria                                /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function BPF15()
Local cRet
Local nPos := At("-", SA6->A6_NUMCON)

if nPos > 0
	cRet := StrZero( Val( Left(SA6->A6_NUMCON, nPos-1) ), 7 )
else
	cRet := StrZero( Val(SA6->A6_NUMCON), 7 )
endif

Return(cRet)


/*
———————————————————————————————————————————————————————————————————————————————
@function		BPF16                                                        /@
@type			User function                                                /@
@date			14/04/2014                                                   /@
@description	Preenche o detalhe para pagamentos de tributos.
                Posição 001 a 464                                            /@
@author			Adalberto Moreno Batista                                     /@
@use			Clientes Opção Um Consultoria                                /@
———————————————————————————————————————————————————————————————————————————————
*/
User Function BPF16()
Local cRet

if SEA->EA_MODELO == "18" 	//DARF

	cRet := SE2->E2_X_TDARF +;
			PadL(SM0->M0_NOMECOM, 40) +;
			PadL(SM0->M0_ENDCOB, 40) +;
			SM0->M0_CEPCOB +;
			SM0->M0_ESTCOB +;
			PadL(SM0->M0_CIDCOB, 20) +;
			PadL(SM0->M0_BAIRCOB, 20) +;
			"2" +;
			"0" + SM0->M0_CGC +;
			PadL(SM0->M0_TEL, 20) +;
			GravaData(SE2->E2_VENCTO, .F., 8) +;
			"S" +;
			StrZero(SE2->E2_VALOR * 100, 15) +;
			StrZero(0,15) +;
			StrZero(0,15) +;
			StrZero(SE2->E2_VALOR * 100, 15) +;
			GravaData(SE2->E2_VENCTO, .F., 8) +;
			Left(SE2->E2_CODRET, 4) +;
			GravaData(SE2->E2_X_PAPU, .F., 8) +;
			StrZero(SE2->E2_X_PDARF * 100, 4) +;
			Space(17) +;
			StrZero(SE2->E2_X_RECAC * 100, 15) +;
			Space(80) +;
			Space(91)
						
elseif SEA->EA_MODELO == "17" 	 //GPS
	
	cRet := "7" +;
			PadL(SM0->M0_NOMECOM,40) +;
			PadL(SM0->M0_ENDCOB,40) +;
			SM0->M0_CEPCOB +;
			SM0->M0_ESTCOB +;
			PadL(SM0->M0_CIDCOB,20) +;
			PadL(SM0->M0_BAIRCOB,20) +;
			"2" +;
			"0" + SM0->M0_CGC +;
			PadL(SM0->M0_TEL,20) +;
			GravaData(SE2->E2_VENCTO,.F.,8) +;
			"S" +;
   			StrZero(SE2->E2_VALOR * 100, 15) +;
			StrZero(0,15) +;
			StrZero(0,15) +;
			StrZero(SE2->E2_VALOR * 100, 15) +;
			Left(SE2->E2_CODRET,4) +;
   			"01" +;
			Left(SM0->M0_CGC,14) +;
			StrZero(Year(SE2->E2_X_PAPU),4) + StrZero(Month(SE2->E2_X_PAPU),2) +;
			Space(80) +;
			PadL(iif(AllTrim(SE2->E2_CODRET) $ "2631.2658", SM0->M0_NOMECOM, ""), 40) +;
			Space(81)
			
elseif SEA->EA_MODELO == "22"	 //GARE 
			
	cRet := "6" +;
   			PadL(SM0->M0_NOMECOM,40) +;
			PadL(SM0->M0_ENDCOB,40) +;
			SM0->M0_CEPCOB +;
			SM0->M0_ESTCOB +;
			PadL(SM0->M0_CIDCOB,20) +;
			PadL(SM0->M0_BAIRCOB,20) +;
   			"2" +;
			"0" + SM0->M0_CGC +;
			PadL(SM0->M0_TEL,20) +;
			GravaData(SE2->E2_VENCTO,.F.,8) +;
			"S" +;
			StrZero(SE2->E2_VALOR * 100, 15) +;
			StrZero(0,15) +;
			StrZero(0,15) +;
			StrZero(0,15) +;
			StrZero(0,15) +;
			StrZero(SE2->E2_VALOR * 100, 15) +;
			Space(2) +;
			GravaData(SE2->E2_VENCTO, .F., 8) +;
			Left(SE2->E2_CODRET,4) +;
		  	Space(1) +;
			StrZero(Month(SE2->E2_X_PAPU),2) + StrZero(Year(SE2->E2_X_PAPU),4) +;
			PadL(SM0->M0_INSC, 12) +;
			Space(13) +;
			Space(13) +;
			Space(1) +;  
			Space(1) +;
			Space(40) +;
			Space(40) +;
			PadL(SM0->M0_CNAE,7) +;
			Space(7) +;
			Space(42)

/* elseif SEA->EA_MODELO == "23" // GARE-120 
	
	cRet := "R" +;
			SE2->E2_CODBAR +;
	   		GravaData(SE2->E2_VENCTO,.F.,8) +;
			GravaData(SE2->E2_VENCTO,.F.,8) +;
			Space(298) +;
			StrZero(Val(Left(SA6->A6_AGENCIA, 4)), 4) +;
			StrZero(Val(SA6->A6_NUMCON),6) + SA6->A6_DVCTA +;
			Space(8) +;
			"N" +;
			Space(80)
*/

elseif SEA->EA_MODELO == "35" //FGTS via codigo de barras     

	cRet := "F" +;
			SE2->E2_CODBAR +;
   			GravaData(SE2->E2_VENCTO,.F.,8) +;
			Space(8) +;
			Space(15) +;
   			Space(15) +;
   			Space(45) +;
		  	Space(20) +; 
			Space(222) +;
			"S" +;
   			Space(80)

elseif SEA->EA_MODELO $ "13#16#19#21#23#28#91" //CONTAS DE CONSUMO E TRIBUTOS COM CÓDIGOS DE BARRAS
	
	cRet := "B" +;
			SE2->E2_CODBAR +;
			GravaData(SE2->E2_VENCTO,.F.,8) +;
			Space(15) +;
			"S" +;
			Space(390)

/* elseif SEA->EA_MODELO == "16" //DARF via codigo de barras
	
	cRet := "D" +;
			SE2->E2_CODBAR +;
			GravaData(SE2->E2_VENCTO,.F.,8) +;
			StrZero(SE2->E2_VALOR * 100, 15) +;
   			"S" +;
			Space(291) +;
			StrZero(Val(Left(SA6->A6_AGENCIA, 4)), 4) +;
			StrZero(Val(SA6->A6_NUMCON),6) + SA6->A6_DVCTA +;
			Space(8) +;
			Space(80)

elseif SEA->EA_MODELO == "19" //IPTU e ISS via codigo de barras

	cRet := "I" +;
			SE2->E2_CODBAR +;
			GravaData(SE2->E2_VENCTO,.F.,8) +;
			Space(15) +;
			"S" +;
			Space(291) +;
			StrZero(Val(Left(SA6->A6_AGENCIA, 4)), 4) +;
			StrZero(Val(SA6_A6_NUMCON),6) + SA6->A6_DVCTA +;
			Space(8) +;
			Space(80)

elseif SEA->EA_MODELO == "??" //Outros codigos de barras	

	cRet := "O" +;
			SE2->E2_CODBAR +;
			GravaData(SE2->E2_VENCTO,.F.,8) +;
			Space(15) +;
			"S" +;
			Space(291) +;
			StrZero(Val(Left(SA6->A6_AGENCIA, 4)), 4) +;
			StrZero(Val(SA6->A6_NUMCON),6) + SA6->A6_DVCTA +;
			Space(8) +;
			Space(80)

	O - Pagamento Outros Codigos de Barras - Identificador do Tributo - C,1
	Código de Barras N,48 (E2_CODBAR). Pode conter o codigo de barras com 44 posicoes - sem os 4 DACs adicionais. O campo e alinhado a direita com zeros a esquerda)
	Data de Pagamento do Tributo - 8 - Obrigatorio (AAAAMMDD - E2_VENCTO)
	Reserva - C,15
	Autoriza Pagamento - C,1 (S=Autoriza, N=Não Autoriza. A autorizacao e definida no software OBB)
	Reserva - C,291
	Agencia - N,4 (A6_AGENCIA, A6_DVAGE)
	Conta - N,7 (A6_NUMCON, A6_DVCTA)
	Mestre - N,8 - Somente se empresa realizar pagamentos com mais de 1 conta no Bradesco. Deixar em branco
	Uso da Empresa - C,80
*/

endif

Return(cRet)
