#include "protheus.ch"     

/*/
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
@function		CN120CMP                                                     /@
@type			Ponto de entrada                                             /@
@date			22/10/2021                                                   /@
@description	Formata os campos adicionandos pelo PE CN120ESY para 
                apresenta鈬o ao usu疵io na consulta padr縊.                  /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Op鈬o Um Tecnologia                                          /@
@use			Brasitech                                                    /@
覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
/*/
User Function CN120CMP()
Local aCab      := ParamIXB[1]
Local aCampos   := ParamIXB[2]

//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
// Montagem dos campos adicionados pelo PE CN120ESY para apresenta鈬o ao usu疵io
// na consulta padr縊.
// Por: Adalberto Moreno Batista (Op鈬o Um) em /10/2021
//覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧覧?
if TRBCN9->(FieldPos("CN9_XOBJET")) > 0
	aAdd(aCab, GetSx3Cache( "CN9_XOBJET", "X3_TITULO"))
	aAdd(aCampos, {"CN9_XOBJET", GetSx3Cache("CN9_XOBJET", "X3_TIPO"), GetSx3Cache("CN9_XOBJET", "X3_CONTEXT"), GetSx3Cache("CN9_XOBJET", "X3_PICTURE")})
endif

if TRBCN9->(FieldPos("CN9_XCNPJ")) > 0
	aAdd(aCab, GetSx3Cache( "CN9_XCNPJ", "X3_TITULO"))
	aAdd(aCampos, {"CN9_XCNPJ", GetSx3Cache("CN9_XCNPJ", "X3_TIPO"), GetSx3Cache("CN9_XCNPJ", "X3_CONTEXT"), GetSx3Cache("CN9_XCNPJ", "X3_PICTURE")})
endif

Return({aCab, aCampos})
