#Include "protheus.ch"
#Include "rwmake.ch"

/*/

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		FA420NAR                                                      /@
@type				Ponto de entrada                                              /@
@date				11/12/2014                                                    /@
@description	Usado para manipula鈬o do nome do arquivo na gera鈬o do CNAB
					a pagar, mv_para04 do grupo AFI420.                           /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

/*/
User Function FA420NAR()
Local cFile		:= PARAMIXB
Local aArquivo	:= {}
Local nK, cDiretorio, nTL

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Para casos de gera鈬o do CNAB ? pagar gerada para a empresa FINNET, altero o 
// nome do arquivo conforme padroniza鈬o definida.
// PAGxxxcccccc_AAAAMMDDHHMMSS.TXT
// |            |       |      +-> Extens縊 do arquivo
// |            |       +--------> "HHMMSS" - Hora (HH), minutos (MM) e segundos (SS) da gera鈬o do arquivo
// |            +----------------> "AAAAMMDD" - Ano (AAAA), m黌 (MM) e dia (DD) da gera鈬o do arquivo
// +-----------------------------> "PAGxxxcccccc_" - String fixa informado em campo especifico de parametros bancarios EE_X_NOMFN
// Vari疱eis do grupo AFI420 a serem verificadas
// mv_par03	- Arq.Configuracao
// mv_par04	- Arq. Saida 
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

if SEE->(FieldPos("EE_X_NOMFN")) > 0

	if Empty(SEE->EE_X_NOMFN)
	
		if AllTrim(mv_par03) == "FINNET.2PE"
		
			Help(" ", 1, "ATENﾇﾃO",, "ﾉ obrigat?rio o preenchimento do campo 'Nome FINNET' no cadastro de par穃etros banc疵ios para a correta cria鈬o do nome do arquivo para a Finnet. Verifique!" + chr(13) + chr(10) + chr(13) + chr(10) + "FA420NAR (Espec?fico Brasitech). ", 1)
			
		endif
	
	else
	
		cDiretorio 	:= ""
		nTL			:= Len(AllTrim(mv_par04))
		for nK := nTL to 1 step -1
			if Substr(AllTrim(mv_par04), nK, 1) == "\"
				cDiretorio := Left(mv_par04, nTL - (nTL - nK))
				exit
			endif
		next
	
		do while .T.
			cFile := cDiretorio + AllTrim(SEE->EE_X_NOMFN) + "_" + dTOs(dDataBase) + AllTrim(StrTran(Time(), ":", "")) + "." + AllTrim(SEE->EE_EXTEN)
			if !File(cFile)
				exit
			endif
		enddo
		
		MsgBox("O arquivo foi renomeado para " + cFile, "Informa鈬o", "INFO")

	endif
	
endif

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Pagamento de boletos
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if AllTrim(mv_par03) == "FINNET.2PE"
	SA6->(dbSetOrder(1))
	if SA6->(dbSeek(xFilial("SA6") + SEE->(EE_CODIGO + EE_AGENCIA + EE_CONTA)))
		if Empty(SA6->A6_XBCON) .or. Empty(SA6->A6_XAGEN) .or. Empty(SA6->A6_XCTAN)
			Help(" ", 1, "ATENﾇﾃO", , "O banco, ag麩cia e conta corrente utilizado n縊 est? com os campos CNAB preenchidos adequadamente e o arquivos, se transmitido, ser? rejeitado. Verifique o cadastro do respectivo banco, na pasta FINNET, antes da gera鈬o do arquivo!" + chr(13) + chr(10) + chr(13) + chr(10) + "FA420NAR (Espec?fico Brasitech). ", 1)
		endif
	endif
endif

Return(cFile)
