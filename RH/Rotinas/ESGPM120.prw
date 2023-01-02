#INCLUDE "protheus.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ESGPM120 �Autor  � Tiago Caires       � Data � 18/05/2014  ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao para Validar o Acesso ao Fechamento Mensal da Folha ���
���          � de Pagamento.                                              ���
�������������������������������������������������������������������������͹��
���Uso       � MP11                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function ESGPM120()

 Local cUserFech := GETMV("GP_UFECFOL",,"")		// Usuarios Liberados para Realizar o Fechamento Mensal - Codigo User
 Local cMensagem := "Usu�rio sem permiss�o para executar o fechamento mensal! Contate o Administrador do sistema!"
 Local lFechOk   := .F.

 If !Empty( cUserFech )
    If __cUserId $ cUserFech
       lFechOk := .T.
    EndIf 
 EndIf
 
 // Executa a Rotina do Fechamento Mensal
 If lFechOk
    GPEM120()
 Else
    Aviso("ATENCAO",cMensagem,{"Sair"})
 EndIf

Return
