#Include "protheus.ch"
#Include "rwmake.ch"

/*/

———————————————————————————————————————————————————————————————————————————————
@function		F150ARQ                                                       /@
@type				Ponto de entrada                                              /@
@date				11/11/2015                                                    /@
@description	Usado para manipulação do nome do arquivo na geração do CNAB
					a receber, mv_par04 do grupo AFI150.                          /@
@author			Adalberto Moreno Batista - Opção Um Consultoria               /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————

/*/
User Function F150ARQ()
Local cFile		:= PARAMIXB
Local aArquivo	:= {}
Local nK, cDiretorio, nTL

//———————————————————————————————————————————————————————————————————————————————
// Para casos de geração do CNAB à receber gerada para a empresa FINNET, altero o 
// nome do arquivo conforme padronização definida.
// COBxxxcccccc_AAAAMMDDHHMMSS.REM
// |            |       |      +-> Extensão do arquivo
// |            |       +--------> "HHMMSS" - Hora (HH), minutos (MM) e segundos (SS) da geração do arquivo
// |            +----------------> "AAAAMMDD" - Ano (AAAA), mês (MM) e dia (DD) da geração do arquivo
// +-----------------------------> "COBxxxcccccc_" - String fixa informado em campo especifico de parametros bancarios EE_X_NOMFN
// Variáveis do grupo AFI150 a serem verificadas
// mv_par04	- Arq. Saida 
//———————————————————————————————————————————————————————————————————————————————
if SEE->(FieldPos("EE_X_NOMFN")) > 0
  
	if Empty(SEE->EE_X_NOMFN)
	
		Help(" ", 1, "ATENÇÃO",, "É obrigatório o preenchimento do campo 'Nome FINNET' no cadastro de parâmetros bancários para a correta criação do nome do arquivo para a Finnet. Verifique!" + chr(13) + chr(10) + chr(13) + chr(10) + "F150ARQ (Específico Brasitech). ", 1)
			
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
		
		MsgBox("O arquivo foi renomeado para " + cFile, "Informação", "INFO")

	endif
	
endif

Return(cFile)
