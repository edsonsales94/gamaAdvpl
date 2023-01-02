#include "protheus.ch"     

/*/
�������������������������������������������������������������������������������
@function		CN120CMP                                                     /@
@type			Ponto de entrada                                             /@
@date			22/10/2021                                                   /@
@description	Formata os campos adicionandos pelo PE CN120ESY para 
                apresenta��o ao usu�rio na consulta padr�o.                  /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Op��o Um Tecnologia                                          /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
User Function CN120CMP()
Local aCab      := ParamIXB[1]
Local aCampos   := ParamIXB[2]

//�������������������������������������������������������������������������������
// Montagem dos campos adicionados pelo PE CN120ESY para apresenta��o ao usu�rio
// na consulta padr�o.
// Por: Adalberto Moreno Batista (Op��o Um) em /10/2021
//�������������������������������������������������������������������������������
if TRBCN9->(FieldPos("CN9_XOBJET")) > 0
	aAdd(aCab, GetSx3Cache( "CN9_XOBJET", "X3_TITULO"))
	aAdd(aCampos, {"CN9_XOBJET", GetSx3Cache("CN9_XOBJET", "X3_TIPO"), GetSx3Cache("CN9_XOBJET", "X3_CONTEXT"), GetSx3Cache("CN9_XOBJET", "X3_PICTURE")})
endif

if TRBCN9->(FieldPos("CN9_XCNPJ")) > 0
	aAdd(aCab, GetSx3Cache( "CN9_XCNPJ", "X3_TITULO"))
	aAdd(aCampos, {"CN9_XCNPJ", GetSx3Cache("CN9_XCNPJ", "X3_TIPO"), GetSx3Cache("CN9_XCNPJ", "X3_CONTEXT"), GetSx3Cache("CN9_XCNPJ", "X3_PICTURE")})
endif

Return({aCab, aCampos})