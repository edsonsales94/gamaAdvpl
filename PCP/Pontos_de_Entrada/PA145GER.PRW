#include 'protheus.ch'
#include "topconn.ch"

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦  PA145GER  ¦ Autor ¦ Orismar Silva        ¦ Data ¦ 10/10/2022 ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦Ponto de entrada executado ao finalziar a geração de todos os  ¦¦¦
¦¦¦           ¦documentos do MRP (PCPA712 ou PCPA144).                        ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/


USER function PA145GER()
    Local cOrigem   := ""//"PCPA144"
    Local cTicket   := PARAMIXB[1]

  //
  //SC1 - Solicitações de Compra
  //
  cQryAux := " EXEC sp_TEMPMRPSC "
	cQryAux += " '"+cOrigem+ "' "// ORIGEM
	cQryAux += ",'"+cTicket+ "' "// TICKET
	cQryAux += ",'01' "          // FILIAL

  //Executando consulta e setando o total da régua
	TCQuery cQryAux New Alias "QRY_MPR"
 
    While QRY_MPR->(!Eof())
        //Percorre todos os registros gerados no processamento
        Conout("SC1 - Ticket: " + cTicket)
        if !EMPTY(QRY_MPR->FORNECEDOR)
	          Begin Transaction              
                  cQuery := " UPDATE "+RetSqlName("SC1")+" SET C1_XPRCCOM = "+StrTran(Transform( QRY_MPR->PRCCOMPRA,PesqPict("SC1","C1_XPRCCOM")),",",".")+",  C1_XFORNEC  = '"+ QRY_MPR->FORNECEDOR+"'"                        
                  cQuery += " WHERE C1_SEQMRP = '"+cTicket+"' AND C1_ORIGEM = '"+cOrigem+"' AND C1_NUM ='"+QRY_MPR->C1_NUM+"'  AND C1_FILIAL ='"+XFILIAL("SC1")+"' AND D_E_L_E_T_='' AND C1_PRODUTO='"+QRY_MPR->C1_PRODUTO+"' AND C1_ITEM='"+QRY_MPR->C1_ITEM+"'"
	                TCSQLExec(cQuery)
            End Transaction 
        endif

        QRY_MPR->(dbSkip())
    End
    QRY_MPR->(dbCloseArea())

 
Return
