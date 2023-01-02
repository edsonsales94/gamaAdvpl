#Include "Protheus.ch"
#Include "Rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �VldTranEst� Autor � Luiz Fernando C Nogueira �Data�02/09/10 ���
�������������������������������������������������������������������������͹��
���Descricao � Valida transportadora por estado do cliente                ���
�������������������������������������������������������������������������͹��
���Uso       � Brasitech ( Gama Italy )                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function VldTranEst ( cTransp , cUFCli )
/*���������������������������������������������������������������������Ŀ
  � Declara as Variaveis Utilizadas                                     �
  �����������������������������������������������������������������������*/
Local cEstOk      := ""
Local lRetorno    := .T.
Local cCodEdi 	  := ""  
Local cVlTrans    := Getmv("BR_VLTRANS")   

                                          
if (SM0->M0_CODIGO $ "08/09") .or. ( M->C5_TIPO $ "D/B" ) .or. (SM0->M0_CODIGO == "01" .and. xFilial("SC5") != "03")
	return lRetorno
endif

if cTransp $ cVlTrans
	return lRetorno
endIf

/*���������������������������������������������������������������������Ŀ
  � Abre a Tabela de Transportadora x Estado                            �
  �����������������������������������������������������������������������*/
DbSelectArea("SZD")
DbSetOrder(1)

/*���������������������������������������������������������������������Ŀ
  � Verifica as Permissoes da Transportadora quanto ao Estado      		�
  �����������������������������������������������������������������������*/
If DbSeek ( xFilial("SZD") + cTransp ) 
   cEstOk  := SZD->ZD_ESTADO
   
   If !( Alltrim( cUFCli ) $ Alltrim( cEstOk ) )
   		if !l410Auto
	   		Aviso( "Politica Comercial !" , "Esta transpostadora n�o est� autorizada a ser utilizada para o estado deste cliente : " + cUFCli + " !" , {"Ok"} , 1 , "Transportadora Inv�lida ! " )
	   	endif
   		lRetorno  := .F.
   		return lRetorno
	Endif   

   
Else
	if !l410Auto
		Aviso( "Politica Comercial !" , "A Transportadora selecionada n�o est� cadastrada na amarra��o Transportadora x Estado! Solicite o cadastro desta amarra��o para utilziar esta transportadora " , {"Ok"} , 1 , "Transportadora x Estado ! " )
	endif
   lRetorno := .F.
   return lRetorno
Endif


/*���������������������������������������������������������������������Ŀ
  �Validacao referente o codigo EDI - KEEPERS							�
  �����������������������������������������������������������������������*/
if SM0->M0_CODIGO == "01" .AND. SM0->M0_CODFIL == "03"  
	cCodEdi := posicione("SA4",1,xFilial("SA4")+cTransp,"A4_XCODEDI")
	if empty(cCodEdi)
		if !l410Auto
			Aviso("Politica Comercial !", "A Transportadora n�o possui o c�digo Keepers cadastrado. Favor verificar com o Depto de Log�stica", {"Ok"} , 1 , "C�digo Keepers ! ")
		endif
		lRetorno := .F.                                                        
	endif
EndIf
                
Return lRetorno  