#include "protheus.ch"     
#include "rwmake.ch"
#INCLUDE "FWMVCDEF.CH"

/*/
�������������������������������������������������������������������������������
@function		CNT121BT                                                     /@
@type			Ponto de entrada                                             /@
@date			28/12/2020                                                   /@
@description	Adiciona fun��o no menu (aRotina) de medi��es de contrato    /@
@author			Adalberto Moreno Batista (amoreno@opcaoum.com.br)
				Op��o Um Tecnologia                                          /@
@use			Brasitech                                                    /@
�������������������������������������������������������������������������������
/*/
User Function CNT121BT()
//Local nOpAlt := Iif(VerSenha(58),58,77) 	//Permiss�o de altera��o

//�������������������������������������������������������������������������������
// Altera array aRotina, substituindo funcionalidade do banco de conhecimento
// pela rotina especifica de anexos do contrato. Desta forma, todo o controle
// padr�o de acesso, funcionar� para os Anexos.
// Os arquivos ser�o gravados em diretorio dentro do rootpath e os usu�rios n�o
// ter�o ter acesso � ele.
// utiliza a funcionalidade do anexo do contrato
// Por: Adalberto Moreno Batista (Op��o Um) em 16/01/2020
/*
aadd(aRotina,{'TEXTO DO BOT�O','NOME DA FUN��O' , 0 , 3,0,NIL})   
ONDE:
Parametros do array a Rotina:
1. Nome a aparecer no cabecalho
2. Nome da Rotina associada    
3. Reservado                        
4. Tipo de Transa��o a ser efetuada:     
    1 - Pesquisa e Posiciona em um Banco de Dados      
    2 - Simplesmente Mostra os Campos                  
    3 - Inclui registros no Bancos de Dados             
    4 - Altera o registro corrente                      
    5 - Remove o registro corrente do Banco de Dados 
5. Nivel de acesso                                   
6. Habilita Menu Funcional
*/
//�������������������������������������������������������������������������������
aAdd(aRotina, {"� Anexos", "U_GenAttach(CND->CND_CONTRA, 'ME', !AllTrim(CND->CND_SITUAC)$'E/FE', {CND->CND_CONTRA})", 0, 4, 0})

Return()
