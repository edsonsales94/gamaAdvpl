#Include 'Protheus.ch'
/**
Ponto de entrada Criado por Claudio Almeida
Data: 27/05/2015
Objetivo: Obrigatoriedade do centro de custo de debito para as despesa do grupo 4
Solicitado: Contabilidade (Fabiano Am/Marcos SP)
**/
User Function F100TOK()
Local URET:=.T.

If LEFT(ALLTRIM(M->E5_NATUREZ),1)=="4" .AND. LEN(ALLTRIM(M->E5_CCD))==0
  Alert("O uso dos centros de custos são obrigatórios para as contas de despesas, grupo 4 !!!")
  URET:=.F.
Endif

Return(URET)
