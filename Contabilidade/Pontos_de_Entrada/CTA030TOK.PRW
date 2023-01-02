#include "totvs.ch"

#define MB_YESNO			4
#define IDYES			    6
#define IDNO			    7

/*/
———————————————————————————————————————————————————————————————————————————————
@function		CTA030TOK                                                    /@
@date			02/02/2017                                                   /@
@type			Ponto de entrada
@description	Valida inclusão e alteração de centros de custo.             /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Opção Um Consultoria                                         /@
@use			Específico Brasitech                                         /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function CTA030TOK()
Local lRet := .F.
Local nOpc := PARAMIXB

//———————————————————————————————————————————————————————————————————————————————
// Valida inclusão e alteração de centro de custo, obrigando informar o código do
// grupo de aprovação de compras para CC analiticos.
// Por: Adalberto Moreno Batista (Opção Um Consultoria) em 02/02/2017
//———————————————————————————————————————————————————————————————————————————————
if (nOpc == 3 .or. nOpc == 4) .and.;
	M->CTT_CLASSE == "2" .and.;
	M->CTT_BLOQ=="2" .and.;
	((CTT->(FieldPos("CTT_XAPVPC")) > 0 .and. Empty(M->CTT_XAPVPC)) .or. (CTT->(FieldPos("CTT_XGEST")) > 0 .and. Empty(M->CTT_XGEST)))

	if MessageBox("Neste centro de custo não foi informado o grupo de aprovação de compras (Grp Aprov PC) ou o código do gestor do centro de custo (Gestor Depto), o que poderá causar problemas caso seja utilizado em um pedido ou solicitação de compras. Deseja gravar mesmo assim?", "® ATENÇÃO", MB_YESNO) == IDNO
		lRet := .T.
	endif

	//lRet := .T.
	//Help(,, "® ATENÇÃO",, "Necessário informar o grupo de aprovacao de compras para o respectivo centro de custo." + chr(13) + chr(10) + chr(13) + chr(10) + "(Específico Brasitech)", 1)
	
endif

Return(lRet)
