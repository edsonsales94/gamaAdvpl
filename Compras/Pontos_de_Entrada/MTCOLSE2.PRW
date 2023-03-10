#include "protheus.ch" 

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		MTCOLSE2                                                     /@
@type			Ponto de entrada                                             /@
@date			18/12/2018                                                   /@
@description	Manipula os dados do aCols de t?tulos a pagar (SE2) antes da
				grava鈬o do documento de entrada e do t?tulo financeiro.
				Obs: Executado na visualiza鈬o do documento de entrada.      /@
@Parameters		Array - aCols das duplicatas
				Numerico - (0) Visualiza鈬o do documento ou (1) Inclus縊 ou
				Classifica鈬o do documento                                   /@
@Return			Array com as colunas das duplicatas                          /@
@author			                                                             /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function MTCOLSE2()
Local aSE2 			:= Paramixb[1]	//{}
Local nOpc          := ParamIXB[2] //0-Tela de visualiza鈬o / 1-Inclus縊 ou Classifica鈬o
Local aArea         := GetArea()
Local aAreaSC7      := SC7->(GetArea())
Local nPosPEDIDO    := aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "D1_PEDIDO"})
Local nPosITEMPC    := aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "D1_ITEMPC"})
Local cForPag       := ""
Local nPosXFORPAG	:= 0
Local nPosFORBCO	:= 0
Local nPosFORAGE	:= 0
Local nPosFAGEDV	:= 0
Local nPosFORCTA	:= 0
Local nPosFCTADV	:= 0
Local nPosXCONSUM	:= 0
Local nPosXCPF		:= 0
Local nK, nPosApoio, cForBco, cForAge, cFAgeDV, cForCta, cFCtaDV, cConsum, cCPF

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Adalberto Moreno Batista (Op鈬o Um Tecnologia)
// Vari疱el publica utilizada no ponto de entrada MT100TOK. Em 06/08/20
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
Public aGI103Dupl 	:= PARAMIXB[1]	

if nOpc == 1 .and. nPosPEDIDO > 0 .and. nPosITEMPC > 0
    SC7->(dbSetOrder(1))
	nPosApoio     := aScan(aGIPosSE2, {|x| Upper(AllTrim(x[1])) == "E2_XFORPAG"})
    if !Empty(aCols[1,nPosPEDIDO]) .and.;
        SC7->(dbSeek(xFilial("SC7") + aCols[1,nPosPEDIDO] + aCols[1,nPosITEMPC])) .and.;
        nPosApoio > 0

        nPosXFORPAG     := aGIPosSE2[nPosApoio,2]
		
        if nPosXFORPAG > 0
            if SC7->C7_X_FORPG == "1"		//Boleto
                cForPag     := "BOL"
            elseif SC7->C7_X_FORPG == "2"	//Deposito em conta
                cForPag     := "DEP"
				cForBco		:= iif(Empty(SC7->C7_XBANCO), SA2->A2_BANCO, SC7->C7_XBANCO)
				cForAge		:= iif(Empty(SC7->C7_XAGENC), SA2->A2_AGENCIA, SC7->C7_XAGENC)
				cFAgeDV		:= iif(Empty(SC7->C7_XDVAGE), SA2->A2_DVAGE, SC7->C7_XDVAGE)
				cForCta		:= iif(Empty(SC7->C7_XCONTA), SA2->A2_NUMCON, SC7->C7_XCONTA)
				cFCtaDV		:= iif(Empty(SC7->C7_XDVCTA), SA2->A2_DVCTA, SC7->C7_XDVCTA)
				cConsum		:= SC7->C7_XCONSUM
				cCPF		:= SC7->C7_XCPF

				// Identificando posicao de campos no aCols dos titulos
				nPosApoio	:= aScan(aGIPosSE2, {|x| x[1]=="E2_FORBCO"})
				if nPosApoio > 0
					nPosFORBCO	:= aGIPosSE2[nPosApoio,2]
				endif

				nPosApoio	:= aScan(aGIPosSE2, {|x| x[1]=="E2_FORAGE"})
				if nPosApoio > 0
					nPosFORAGE	:= aGIPosSE2[nPosApoio,2]
				endif

				nPosApoio	:= aScan(aGIPosSE2, {|x| x[1]=="E2_FAGEDV"})
				if nPosApoio > 0
					nPosFAGEDV	:= aGIPosSE2[nPosApoio,2]
				endif

				nPosApoio	:= aScan(aGIPosSE2, {|x| x[1]=="E2_FORCTA"})
				if nPosApoio > 0
					nPosFORCTA	:= aGIPosSE2[nPosApoio,2]
				endif

				nPosApoio	:= aScan(aGIPosSE2, {|x| x[1]=="E2_FCTADV"})
				if nPosApoio > 0
					nPosFCTADV	:= aGIPosSE2[nPosApoio,2]
				endif

				nPosApoio	:= aScan(aGIPosSE2, {|x| x[1]=="E2_XCONSUM"})
				if nPosApoio > 0
					nPosXCONSUM	:= aGIPosSE2[nPosApoio,2]
				endif

				nPosApoio	:= aScan(aGIPosSE2, {|x| x[1]=="E2_XCPF"})
				if nPosApoio > 0
					nPosXCPF		:= aGIPosSE2[nPosApoio,2]
				endif

			elseif SC7->C7_X_FORPG == "5"	//Debito em conta
				cForPag     := "DBC"
				
            endif

            for nK:=1 to Len(aGI103Dupl)
				if Empty(aGI103Dupl[nK, nPosXFORPAG])
                	aGI103Dupl[nK, nPosXFORPAG] := cForPag

					if cForPag == "DEP"
						if nPosFORBCO > 0
							aGI103Dupl[nK, nPosFORBCO] := cForBco
						endif
						if nPosFORAGE > 0
							aGI103Dupl[nK, nPosFORAGE] := cForAge
						endif
						if nPosFAGEDV > 0
							aGI103Dupl[nK, nPosFAGEDV] := cFAgeDV
						endif
						if nPosFORCTA > 0
							aGI103Dupl[nK, nPosFORCTA] := cForCta
						endif
						if nPosFCTADV > 0 
							aGI103Dupl[nK, nPosFCTADV] := cFCtaDV
						endif
						if nPosXCONSUM > 0 
							aGI103Dupl[nK, nPosXCONSUM] := cConsum
						endif
						if nPosXCPF > 0 
							aGI103Dupl[nK, nPosXCPF] := cCPF
						endif
					endif
				endif
            next
        endif
    endif
    RestArea(aAreaSC7)
    RestArea(aArea)
endif

/* ####################################################################### *\
|| #           PONTO DE ENTRADA UTILIZADO PELO IMPORTADOR GATI           # ||
|| #                                                                     # ||
|| #    PONTO DE ENTRADA UTILIZADO PARA CONSIDERAR A DATA DE VENCIMENTO  # ||
|| #          DA DUPLICATA DO CTE INFORMADA NA IMPORTAﾇﾃO POR LOTE       # ||
|| #                                                                     # ||
\* ####################################################################### */

// Altera a data de vencimento da duplicata
aSE2 := U_GTPE013()
// Regra j? existente no ponto de entrada

Return(aSE2)


