#INCLUDE "Protheus.ch"
//#INCLUDE "Rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CADSZS   � Autor �   Ronaldo Gomes    � Data �  04/09/12   ���
�������������������������������������������������������������������������͹��
���Descricao � Programa para cadastro do grupo de Produtos para WEB       ���
�������������������������������������������������������������������������͹��
���Uso       � GamaItaly                                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function CADSZS()


/*
���������������������������������������������������������������������Ŀ
� Declaracao de Variaveis                                             �
�����������������������������������������������������������������������
*/


Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "SZS"

DbSelectArea("SZS")
DbSetOrder(1)


AxCadastro(cString,"Cadastro Grupos de Produto",cVldExc,cVldAlt)


Return              
