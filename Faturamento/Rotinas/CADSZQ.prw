#INCLUDE "Protheus.ch"
//#INCLUDE "Rwmake.ch"


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CADSZQ   � Autor �   Ronaldo Gomes    � Data �  04/09/12   ���
�������������������������������������������������������������������������͹��
���Descricao � Programa para cadastro Macro Canal Margem de Venda         ���
�������������������������������������������������������������������������͹��
���Uso       � GamaItaly                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function CADSZQ()


/*
���������������������������������������������������������������������Ŀ
� Declaracao de Variaveis                                             �
�����������������������������������������������������������������������
*/


Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "SZQ"

DbSelectArea("SZQ")
DbSetOrder(1)


AxCadastro(cString,"Cadastro Macro Canal Margem de Venda",cVldExc,cVldAlt)


Return                                                  
