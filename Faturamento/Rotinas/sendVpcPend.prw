//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"


//--------------------------------------------------------------
/*

@Rotina Enviar email para Gerentes VPC pendente                        
@return xRet Return Description                                 
@author Ricky Moraes - ricky.moraes@gamaitaly.com.br
@since 26/04/21
/*/                                                             
//--------------------------------------------------------------


******************************************************************************************************************************************************************
User Function fsendVpcPend()
******************************************************************************************************************************************************************
Local cEmp		:= "01"
Local cFil		:= "01"

//———————————————————————————————————————————————————————————————————————————————
// Abertura do ambiente                                         
//———————————————————————————————————————————————————————————————————————————————
WfPrepEnv(cEmp, cFil, "U_fsendVpcPend",, "COM")

fVpcPend()

 //———————————————————————————————————————————————————————————————————————————————
// Encerramento do ambiente                                                     
//———————————————————————————————————————————————————————————————————————————————
RpcClearEnv()

ConOut(dTOc(Date()) + " as " + Time() + ". Relatorio VPC Pendente ")

Return	


******************************************************************************************************************************************************
Static Function fVpcPend()
******************************************************************************************************************************************************
Local nReg,nTotal:=0
Local cAliasVPC:= GetNextAlias()
Local emailGerente

	BeginSql Alias cAliasVPC

SELECT 
    DISTINCT ZS_NUMPREP as VPC,
    ZS_BLQ as CODIGO, 
    ZS_BLQDESC as DESCRICAO, 
    ZS_NIVEL1 as NIVEL, 
    ZS_NIVGRU as GRUPO, 
    ZS_STATUS as [STATUS],
    ZZV_FPAGOB AS TIPO, 
    A1_NOME AS CLIENTE, 
    ZB_NOME AS GERENTE,
    ZB_EMAIL AS EMAIL
FROM SZS010 ,ZZV010, SA1010 , SA3010, SZB010
 
WHERE ZZV_NUM = ZS_NUMPREP 
AND  ZZV_CLIENT = SA1010.A1_COD 
AND  ZZV_LOJA =  SA1010.A1_LOJA
AND  SA1010.A1_VEND = SA3010.A3_COD
AND  SA3010.A3_XEXECUT = SZB010.ZB_COD
AND  ZS_STATUS  = 'AGUARDANDO APROVACAO'
AND  ZS_NIVEL1 = 'COM_GC'
AND  ZS_NUMPREP LIKE 'VA%'
AND  SZS010.D_E_L_E_T_ = '' 
AND  ZZV010.D_E_L_E_T_ = ''	
ORDER BY SZB010.ZB_EMAIL,ZS_NIVGRU 

	EndSql
	dbSelectArea(cAliasVPC)
	Count To nTotal
	dbgotop()

	IF nTotal>0

		while !eof()

			emailGerente:= (cAliasVPC)->EMAIL
			aVpcAberta:={}
			nReg:=1
			while emailGerente == (cAliasVPC)->EMAIL .and. !eof()
				aAdd(aVpcAberta,{ StrZero(nReg,2),;
					(cAliasVPC)->VPC,;
					(cAliasVPC)->CODIGO,;
					(cAliasVPC)->DESCRICAO,;
					(cAliasVPC)->TIPO,;
					(cAliasVPC)->CLIENTE,;
                    (cAliasVPC)->GERENTE,;
                    (cAliasVPC)->EMAIL})

    				(cAliasVPC)->(DbSkip())
				    nReg++
			end
            //ALERT('Enviar Email registros '+StrZero(nReg,2) +' ' + aVpcAberta[1,7])
            u_fVpcEmail(aVpcAberta)
            emailGerente:= (cAliasVPC)->EMAIL
		end
	else
		Alert('Não existe VPC, com status pendente.')
	ENDIF
	dbclosearea()

Return
