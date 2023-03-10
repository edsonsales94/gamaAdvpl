#Include "protheus.ch"
#Include "rwmake.ch"

/*/

覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		F150ARQ                                                       /@
@type				Ponto de entrada                                              /@
@date				11/11/2015                                                    /@
@description	Usado para manipula鈬o do nome do arquivo na gera鈬o do CNAB
					a receber, mv_par04 do grupo AFI150.                          /@
@author			Adalberto Moreno Batista - Op鈬o Um Consultoria               /@
@use				Espec?fico Brasitech                                          /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?

/*/
User Function F150ARQ()
Local cFile		:= PARAMIXB
Local aArquivo	:= {}
Local nK, cDiretorio, nTL

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Para casos de gera鈬o do CNAB ? receber gerada para a empresa FINNET, altero o 
// nome do arquivo conforme padroniza鈬o definida.
// COBxxxcccccc_AAAAMMDDHHMMSS.REM
// |            |       |      +-> Extens縊 do arquivo
// |            |       +--------> "HHMMSS" - Hora (HH), minutos (MM) e segundos (SS) da gera鈬o do arquivo
// |            +----------------> "AAAAMMDD" - Ano (AAAA), m黌 (MM) e dia (DD) da gera鈬o do arquivo
// +-----------------------------> "COBxxxcccccc_" - String fixa informado em campo especifico de parametros bancarios EE_X_NOMFN
// Vari疱eis do grupo AFI150 a serem verificadas
// mv_par04	- Arq. Saida 
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if SEE->(FieldPos("EE_X_NOMFN")) > 0
  
	if Empty(SEE->EE_X_NOMFN)
	
		Help(" ", 1, "ATENﾇﾃO",, "ﾉ obrigat?rio o preenchimento do campo 'Nome FINNET' no cadastro de par穃etros banc疵ios para a correta cria鈬o do nome do arquivo para a Finnet. Verifique!" + chr(13) + chr(10) + chr(13) + chr(10) + "F150ARQ (Espec?fico Brasitech). ", 1)
			
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

Return(cFile)
