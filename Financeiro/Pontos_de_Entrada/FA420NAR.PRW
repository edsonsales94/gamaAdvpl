#Include "protheus.ch"
#Include "rwmake.ch"

/*/

�������������������������������������������������������������������������������
@function		FA420NAR                                                      /@
@type				Ponto de entrada                                              /@
@date				11/12/2014                                                    /@
@description	Usado para manipula��o do nome do arquivo na gera��o do CNAB
					a pagar, mv_para04 do grupo AFI420.                           /@
@author			Adalberto Moreno Batista - Op��o Um Consultoria               /@
@use				Espec�fico Brasitech                                          /@
�������������������������������������������������������������������������������

/*/
User Function FA420NAR()
Local cFile		:= PARAMIXB
Local aArquivo	:= {}
Local nK, cDiretorio, nTL

//�������������������������������������������������������������������������������
// Para casos de gera��o do CNAB � pagar gerada para a empresa FINNET, altero o 
// nome do arquivo conforme padroniza��o definida.
// PAGxxxcccccc_AAAAMMDDHHMMSS.TXT
// |            |       |      +-> Extens�o do arquivo
// |            |       +--------> "HHMMSS" - Hora (HH), minutos (MM) e segundos (SS) da gera��o do arquivo
// |            +----------------> "AAAAMMDD" - Ano (AAAA), m�s (MM) e dia (DD) da gera��o do arquivo
// +-----------------------------> "PAGxxxcccccc_" - String fixa informado em campo especifico de parametros bancarios EE_X_NOMFN
// Vari�veis do grupo AFI420 a serem verificadas
// mv_par03	- Arq.Configuracao
// mv_par04	- Arq. Saida 
//�������������������������������������������������������������������������������

if SEE->(FieldPos("EE_X_NOMFN")) > 0

	if Empty(SEE->EE_X_NOMFN)
	
		if AllTrim(mv_par03) == "FINNET.2PE"
		
			Help(" ", 1, "ATEN��O",, "� obrigat�rio o preenchimento do campo 'Nome FINNET' no cadastro de par�metros banc�rios para a correta cria��o do nome do arquivo para a Finnet. Verifique!" + chr(13) + chr(10) + chr(13) + chr(10) + "FA420NAR (Espec�fico Brasitech). ", 1)
			
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
		
		MsgBox("O arquivo foi renomeado para " + cFile, "Informa��o", "INFO")

	endif
	
endif

//�������������������������������������������������������������������������
// Pagamento de boletos
//�������������������������������������������������������������������������
if AllTrim(mv_par03) == "FINNET.2PE"
	SA6->(dbSetOrder(1))
	if SA6->(dbSeek(xFilial("SA6") + SEE->(EE_CODIGO + EE_AGENCIA + EE_CONTA)))
		if Empty(SA6->A6_XBCON) .or. Empty(SA6->A6_XAGEN) .or. Empty(SA6->A6_XCTAN)
			Help(" ", 1, "ATEN��O", , "O banco, ag�ncia e conta corrente utilizado n�o est� com os campos CNAB preenchidos adequadamente e o arquivos, se transmitido, ser� rejeitado. Verifique o cadastro do respectivo banco, na pasta FINNET, antes da gera��o do arquivo!" + chr(13) + chr(10) + chr(13) + chr(10) + "FA420NAR (Espec�fico Brasitech). ", 1)
		endif
	endif
endif

Return(cFile)