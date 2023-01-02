#Include "protheus.ch"
#Include "rwmake.ch"

/*/

�������������������������������������������������������������������������������
@function		F150ARQ                                                       /@
@type				Ponto de entrada                                              /@
@date				11/11/2015                                                    /@
@description	Usado para manipula��o do nome do arquivo na gera��o do CNAB
					a receber, mv_par04 do grupo AFI150.                          /@
@author			Adalberto Moreno Batista - Op��o Um Consultoria               /@
@use				Espec�fico Brasitech                                          /@
�������������������������������������������������������������������������������

/*/
User Function F150ARQ()
Local cFile		:= PARAMIXB
Local aArquivo	:= {}
Local nK, cDiretorio, nTL

//�������������������������������������������������������������������������������
// Para casos de gera��o do CNAB � receber gerada para a empresa FINNET, altero o 
// nome do arquivo conforme padroniza��o definida.
// COBxxxcccccc_AAAAMMDDHHMMSS.REM
// |            |       |      +-> Extens�o do arquivo
// |            |       +--------> "HHMMSS" - Hora (HH), minutos (MM) e segundos (SS) da gera��o do arquivo
// |            +----------------> "AAAAMMDD" - Ano (AAAA), m�s (MM) e dia (DD) da gera��o do arquivo
// +-----------------------------> "COBxxxcccccc_" - String fixa informado em campo especifico de parametros bancarios EE_X_NOMFN
// Vari�veis do grupo AFI150 a serem verificadas
// mv_par04	- Arq. Saida 
//�������������������������������������������������������������������������������
if SEE->(FieldPos("EE_X_NOMFN")) > 0
  
	if Empty(SEE->EE_X_NOMFN)
	
		Help(" ", 1, "ATEN��O",, "� obrigat�rio o preenchimento do campo 'Nome FINNET' no cadastro de par�metros banc�rios para a correta cria��o do nome do arquivo para a Finnet. Verifique!" + chr(13) + chr(10) + chr(13) + chr(10) + "F150ARQ (Espec�fico Brasitech). ", 1)
			
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

Return(cFile)