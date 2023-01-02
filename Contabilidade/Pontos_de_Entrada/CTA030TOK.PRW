#include "totvs.ch"

#define MB_YESNO			4
#define IDYES			    6
#define IDNO			    7

/*/
�������������������������������������������������������������������������������
@function		CTA030TOK                                                    /@
@date			02/02/2017                                                   /@
@type			Ponto de entrada
@description	Valida inclus�o e altera��o de centros de custo.             /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Op��o Um Consultoria                                         /@
@use			Espec�fico Brasitech                                         /@
�������������������������������������������������������������������������������
/*/
User Function CTA030TOK()
Local lRet := .F.
Local nOpc := PARAMIXB

//�������������������������������������������������������������������������������
// Valida inclus�o e altera��o de centro de custo, obrigando informar o c�digo do
// grupo de aprova��o de compras para CC analiticos.
// Por: Adalberto Moreno Batista (Op��o Um Consultoria) em 02/02/2017
//�������������������������������������������������������������������������������
if (nOpc == 3 .or. nOpc == 4) .and.;
	M->CTT_CLASSE == "2" .and.;
	M->CTT_BLOQ=="2" .and.;
	((CTT->(FieldPos("CTT_XAPVPC")) > 0 .and. Empty(M->CTT_XAPVPC)) .or. (CTT->(FieldPos("CTT_XGEST")) > 0 .and. Empty(M->CTT_XGEST)))

	if MessageBox("Neste centro de custo n�o foi informado o grupo de aprova��o de compras (Grp Aprov PC) ou o c�digo do gestor do centro de custo (Gestor Depto), o que poder� causar problemas caso seja utilizado em um pedido ou solicita��o de compras. Deseja gravar mesmo assim?", "� ATEN��O", MB_YESNO) == IDNO
		lRet := .T.
	endif

	//lRet := .T.
	//Help(,, "� ATEN��O",, "Necess�rio informar o grupo de aprovacao de compras para o respectivo centro de custo." + chr(13) + chr(10) + chr(13) + chr(10) + "(Espec�fico Brasitech)", 1)
	
endif

Return(lRet)