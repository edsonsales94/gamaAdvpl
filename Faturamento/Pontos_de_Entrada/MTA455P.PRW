/*
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????ͻ??
???Programa  ? Mta455p  ?Autor  ?Cristiano Figueiroa ? Data ?  03/02/09   ???
?????????????????????????????????????????????????????????????????????????͹??
???Descricao ? Ponto de Entrada para Bloquear a Liberacao Manual do       ???
???          ? Estoque.                                                   ???
?????????????????????????????????????????????????????????????????????????͹??
???Uso       ? Brasitech                                                  ???
?????????????????????????????????????????????????????????????????????????ͼ??
?????????????????????????????????????????????????????????????????????????????
?????????????????????????????????????????????????????????????????????????????
*/

User Function Mta455p()

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ? Declara as Variaveis utilizadas na Rotina                                  ?
  ??????????????????????????????????????????????????????????????????????????????/*/

Local lRetorno := .F.

/*????????????????????????????????????????????????????????????????????????????Ŀ
  ? Verifica se o Estoque podera ficar negativo e bloqueia a liberacao manual  ?
  ??????????????????????????????????????????????????????????????????????????????/*/

If GetMv( "MV_ESTNEG" ) == "N"
   Aviso( "Aten??o !" , "Libera??o Manual de Estoque n?o Permitida ! O sistema est? configurado para que n?o se permita a libera??o de estoque sem que haja saldo no sistema !" , {"Ok"} , 1 , "Liberacao n?o Permitida ! " )
Else
   lRetorno := .T.
Endif   

Return lRetorno