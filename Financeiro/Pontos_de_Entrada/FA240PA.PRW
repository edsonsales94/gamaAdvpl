#INCLUDE "PRTOPDEF.CH"  
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????ͻ??
??TPLX40PA ?Autor  ?Ronaldo Silva           ? Data ?  15/09/21 ???
?????????????????????????????????????????????????????????????????????????͹??
???Desc.     ?da FA240PA permite a seleção de PA com     ???
???          ? movimento banc?rio na tela de Border? de pagamento.        ???
?????????????????????????????????????????????????????????????????????????͹??
???Uso       ? Especifico Ga.Ma Italy                                     ???
?????????????????????????????????????????????????????????????????????????ͼ??
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
*/

User Function FA240PA()

Local lRet  :=  .T.  // .T. - para o sistema permitir a sele??o de PA (com mov. Banc?rio) na tela de border? de pagamento e
                     // .F. - para n?O permitir.

//lRet :=  MsgYesNo("Permite selecionar PA? ","PONTO DE ENTRADA - PA")

Return lRet

