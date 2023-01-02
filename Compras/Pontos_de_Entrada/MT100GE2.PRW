#include "rwmake.ch" 
#include "protheus.ch" 

/*/
———————————————————————————————————————————————————————————————————————————————
@function		MT100GE2                                                     /@
@type			Ponto de entrada                                             /@
@date			23/12/2013                                                   /@
@description	Ponto de entrada utilizado para a gravacao dos elementos
				incluidos no array das duplicatas da NF entrada, definidos  
				pelo ponto de entrada MT103SE2                               /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Especifico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MT100GE2()   
Local aArea 		:= GetArea()
Local aAreaSA2 		:= SA2->(GetArea())
Local aAreaSC7 		:= SC7->(GetArea())
Local aAreaSD1 		:= SD1->(GetArea())
Local aColunas		:= PARAMIXB[1]
Local lGrava		:= (PARAMIXB[2] == 1)
Local nPosFORPAG	:= aScan(PARAMIXB[3],{|x| Upper(alltrim(x[2])) == "E2_XFORPAG"})
Local nPosCODBAR	:= aScan(PARAMIXB[3],{|x| Upper(alltrim(x[2])) == "E2_CODBAR"})
Local nPosLINDIG	:= aScan(PARAMIXB[3],{|x| Upper(alltrim(x[2])) == "E2_LINDIG"})
Local nPosFORBCO	:= aScan(PARAMIXB[3],{|x| Upper(alltrim(x[2])) == "E2_FORBCO"})
Local nPosFORAGE	:= aScan(PARAMIXB[3],{|x| Upper(alltrim(x[2])) == "E2_FORAGE"})
Local nPosFAGEDV	:= aScan(PARAMIXB[3],{|x| Upper(alltrim(x[2])) == "E2_FAGEDV"})
Local nPosFORCTA	:= aScan(PARAMIXB[3],{|x| Upper(alltrim(x[2])) == "E2_FORCTA"})
Local nPosFCTADV	:= aScan(PARAMIXB[3],{|x| Upper(alltrim(x[2])) == "E2_FCTADV"})
Local nPosXCONSUM	:= aScan(PARAMIXB[3],{|x| Upper(alltrim(x[2])) == "E2_XCONSUM"})
Local nPosXCPF		:= aScan(PARAMIXB[3],{|x| Upper(alltrim(x[2])) == "E2_XCPF"})
Local cForPag		:= aColunas[nPosFORPAG]

if lGrava

	//———————————————————————————————————————————————————————————————————————————————
	// gravando campos complementares no titulo a pagar
	//———————————————————————————————————————————————————————————————————————————————
	SE2->(RecLock("SE2", .F.))
	SE2->E2_XFORPAG	:= cForPag
	SE2->E2_CODBAR	:= iif(cForPag=="BOL", aColunas[nPosCODBAR], "")
	SE2->E2_LINDIG	:= iif(cForPag=="BOL", aColunas[nPosLINDIG], "")
	
	SE2->E2_FORBCO	:= iif(cForPag=="DEP", aColunas[nPosFORBCO], " ")
	SE2->E2_FORAGE	:= iif(cForPag=="DEP", aColunas[nPosFORAGE], " ")
	SE2->E2_FAGEDV 	:= iif(cForPag=="DEP", aColunas[nPosFAGEDV], " ")
	SE2->E2_FORCTA	:= iif(cForPag=="DEP", aColunas[nPosFORCTA], " ")
	SE2->E2_FCTADV	:= iif(cForPag=="DEP", aColunas[nPosFCTADV], " ")
	SE2->E2_XCONSUM	:= iif(cForPag=="DEP", aColunas[nPosXCONSUM], " ")
	SE2->E2_XCPF	:= iif(cForPag=="DEP", aColunas[nPosXCPF], " ")
	SE2->E2_X_USER  := Substr(cUsuario,7,15)
	
	SE2->(MsUnlock())
	
endif

RestArea(aAreaSA2)
RestArea(aAreaSC7)
RestArea(aAreaSD1)
RestArea(aArea)
Return()
