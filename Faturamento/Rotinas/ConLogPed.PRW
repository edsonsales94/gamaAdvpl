#include "Rwmake.ch"                
#include "Topconn.ch"

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммямммммммммммммммммммммкммммммяммммммммммммммм╩╠╠
╠╠╨Programa  ЁConLogPed ╨ Autor Ё Cristiano Figueiroa ╨ Data Ё   10/12/2009  ╨╠╠
╠╠лммммммммммьммммммммммймммммммомммммммммммммммммммммйммммммоммммммммммммммм╧╠╠
╠╠╨Descricao Ё Consulta o Log do Pedido de Vendas                            ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Brasitech                                                     ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

User Function ConLogPed()

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё              Declara as Variaveis Utilizadas na Rotina                     Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Local aArea    := GetArea()
Local oDlg     := Nil
Local oLbx     := Nil
Local cQuery   := ""
Local cFilPed  := SC5->C5_FILIAL
Local cNumPed  := SC5->C5_NUM
Private aVetor := {}


/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё              Filtra as Informacoes da Tabela de Log                        Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

cQuery := "Select * "
cQuery += " From  " + RetSqlName("SZA") + " SZA  "
cQuery += "  Where
cQuery += "               SZA.ZA_FILIAL  = '" +  cFilPed + "' "
cQuery += "          And  SZA.ZA_NUMPED  = '" +  cNumPed + "' "
cQuery += "          And  SZA.D_E_L_E_T_ = ''
cQuery += "          And  SZA.R_E_C_N_O_ <>''
 

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                             Adequa a Query                                 Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

cQuery := ChangeQuery(cQuery)

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё    Gera a Query em Arquivo Texto para Analises pelo Query Analyser         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Memowrite("ConLogPed.Sql" , cQuery )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                 Abre o Resultado da Query no Alias QRY                     Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

TcQuery cQuery New Alias "LOGPED"

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                    Ajusta os Campos Data e Numerico                        Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

TcSetField( "LOGPED" , "ZA_DATA"  , "D" , 08 , 0 )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                     Abre o Arquivo Temporario CRD                          Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

DbSelectArea("LOGPED")
DbGoTop()

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                     Processa os Registros do Log                           Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Do While LOGPED->( !Eof() )

 /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   Ё                      Adiciona ao Vetor o Log                             Ё
   юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

	aAdd( aVetor , { LOGPED->ZA_NUMPED , LOGPED->ZA_NOMUSR , LOGPED->ZA_DATA , LOGPED->ZA_HORA , LOGPED->ZA_STATUS , LOGPED->ZA_CODOPER , LOGPED->ZA_OPEDESC , LOGPED->ZA_ROTINA , LOGPED->ZA_PE } )

 /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   Ё                   Processa o Proximo Registro                            Ё
   юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

   DbSkip()
   Loop

EndDo


/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                   Verifica se ha Dados no Log                            Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

If Len( aVetor ) == 0
	Aviso( "AtenГЦo !" , "NЦo existe Log Registrado para o Pedido ! " , {"Ok"}  )
Else

   /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     Ё               Monta a Tela com o Resultado da Consulta                   Ё
     юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
 
   Define MsDialog oDlg Title "Log do Pedido" From 0,0 To 560,1080 Pixel

   @ 20 , 10 ListBox oLbx Fields Header  "Pedido", "UsuАrio", "Data", "Hora" , "Status", "Tipo Oper", "Descr.OperaГЦo			", "Rotina", "Ponto Entrada"  Size 520 , 230	 Of oDlg Pixel ColSizes 40,40,40,15,40,40,15,15,15,40,40,40

   oLbx:SetArray( aVetor )
   oLbx:bLine := {|| {aVetor[oLbx:nAt,1] , aVetor[oLbx:nAt,2] , aVetor[oLbx:nAt,3] , aVetor[oLbx:nAt,4] , aVetor[oLbx:nAt,5] , aVetor[oLbx:nAt,6] , aVetor[oLbx:nAt,7] , aVetor[oLbx:nAt,8] , aVetor[oLbx:nAt,9] }}
					
   Define SButton From 260,500 Type 1 Action oDlg:End() Enable Of oDlg
   Activate MsDialog oDlg Center

Endif

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                     Fecha o Arquivo Temporario                           Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

DbSelectArea("LOGPED")
DbCloseArea()

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                   Restaura as Areas Selecionadas                         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

RestArea( aArea )

Return