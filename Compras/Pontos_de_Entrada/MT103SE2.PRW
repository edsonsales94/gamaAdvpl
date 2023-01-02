#include "rwmake.ch"
#include "protheus.ch"

/*/
———————————————————————————————————————————————————————————————————————————————
@function		MT103SE2                                                     /@
@type			Ponto de entrada                                             /@
@date			23/12/2013                                                   /@
@description	Ponto de entrada utilizado para inclusao de colunas no array
				das duplicatas na nota fiscal de entrada Utilizado em conjunto
				com o ponto de entrada MT103GE2 
				Retorno - array com os elementos que serão incluídos.        /@
@author			Adalberto Moreno Batista - Opção Um Consultoria              /@
@use			Especifico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function MT103SE2()
Local aArea			:= GetArea()
Local aAreaSX3		:= SX3->(GetArea())
Local aCampos		:= PARAMIXB[1]
Local aRet			:= {}
Local aApoio		:= {{"E2_XFORPAG","@!"},;
						{"E2_LINDIG","999999999999999999999999999999999999999999999999"},;
						{"E2_CODBAR","999999999999999999999999999999999999999999999999"},;
						{"E2_FORBCO","@!"},;
						{"E2_FORAGE","@!"},;
						{"E2_FAGEDV","@!"},;
						{"E2_FORCTA","@!"},;
						{"E2_FCTADV","@!"},;
						{"E2_XCONSUM","@!"},;
						{"E2_XCPF","@!"}}
Local nX, cValidacao
//Variáveis publicas utilizadas no ponto de entrada MT100TOK
Public aGIPosSE2	:= {}

//Utilizado em conjunto com o ponto de entrada MT103GE2
SX3->(dbSetOrder(2))
for nX:=1 to Len(aApoio)
	if SX3->(dbSeek(aApoio[nX,1]))

		//tratando validacao dos campos
		cValidacao := ""
		if !Empty(SX3->X3_VALID)
			cValidacao := "(" + AllTrim(SX3->X3_VALID) + ")"
		endif
		if !Empty(SX3->X3_VLDUSER)
			if !Empty(cValidacao)
				cValidacao += " .and. "
			endif
			cValidacao += "(" + AllTrim(SX3->X3_VLDUSER) + ")"
		endif
		
		aAdd(aRet, {Trim(X3Titulo()),;
					SX3->X3_CAMPO,;
					aApoio[nX,2]/*SX3->X3_PICTURE*/,;
					SX3->X3_TAMANHO,;
					SX3->X3_DECIMAL,;
					cValidacao /*SX3->X3_VALID*/,;
					SX3->X3_USADO,;
					SX3->X3_TIPO,;
					SX3->X3_F3,;
					SX3->X3_CONTEXT,;
					SX3->X3_CBOX,;
					SX3->X3_RELACAO,;
					".T."})
		
		aAdd(aGIPosSE2, {aApoio[nX,1], Len(aCampos) + Len(aRet)})
	endif
next

RestArea(aAreaSX3)
RestArea(aArea)

Return(aRet)
