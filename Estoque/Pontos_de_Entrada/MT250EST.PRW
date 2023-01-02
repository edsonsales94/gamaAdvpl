#Include 'Protheus.ch'

User Function MT250EST()    
Local aArea   := GetArea()  
Local cCodUsu   := __cUserId              
oRet:=.T.
Conf=.F.                
pTM:="999"    //CADASTRAR ESSA TM NO PRODUTO VERSOS ARMAZEM PARA VALIDAR O ESTORNO
DbSelectArea("SZ8")
DbSetOrder(1)
If DbSeek ( xFilial("SZ8") + cCodUsu )    
   cTMUser := ALLTRIM(SZ8->Z8_TM)    
   DO CASE
 	CASE LEN(cTMUser)==1 .AND.  cTMUser == "*"
	   Conf:=MSGYESNO('Confirma o estorno de Ordem Encerrada ???? ','ALERTA')  
	CASE ( Alltrim( pTM ) $ Alltrim( cTMUser ) )    
	   Conf:=MSGYESNO('Confirma o estorno de Ordem Encerrada ???? ','ALERTA')  
	CASE !( Alltrim( pTM ) $ Alltrim( cTMUser ) ) 
	   	Aviso( "Politica Comercial!" , "Não existe autorização para o seu usuário utilizar o estorno TM " + pTM + "!" , {"Ok"} , 1 , "TM Inválido!" )
   ENDCASE	   
Endif
if !Conf
 If LEN(ALLTRIM(DTOS(SC2->C2_DATRF)))>0
  alert("Ordem de Producao ja Encerrada!")
  oRet:=.F.
 Endif
Endif
RestArea(aArea)
Return(oRet)