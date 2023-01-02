#include "Rwmake.ch"
#include "Topconn.ch" 

/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммямммммммммммммммммммммкммммммяммммммммммммммм╩╠╠
╠╠╨Programa  Ё ConLogNf ╨ Autor Ё   Ronaldo Gomes     ╨ Data Ё   21/08/2012  ╨╠╠
╠╠лммммммммммьммммммммммймммммммомммммммммммммммммммммйммммммоммммммммммммммм╧╠╠
╠╠╨Descricao Ё Consulta o Log da Nota de Entrada                             ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Brasitech                                                     ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/

User Function ConLogNf()

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё              Declara as Variaveis Utilizadas na Rotina                     Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Local aArea    := GetArea()
Local oDlg     := Nil
Local oLbx     := Nil
Local cQuery   := ""
Local cFilDoc  := SF1->F1_FILIAL
Local cNumDoc  := SF1->F1_DOC
Local cNumSer  := SF1->F1_SERIE
Local cNumFor  := SF1->F1_FORNECE
Local cNumLoj  := SF1->F1_LOJA
	
Private aVetor := {}


/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё              Filtra as Informacoes da Tabela de Log                        Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

cQuery := "Select * "
cQuery += " From  " + RetSqlName("SF1") + " SF1  "
cQuery += "  Where
cQuery += "               SF1.F1_FILIAL  = '" +  cFilDoc + "' "
cQuery += "          And  SF1.F1_DOC  = '" +  cNumDoc + "' "
cQuery += "          And  SF1.F1_SERIE  = '" +  cNumSer + "' "
cQuery += "          And  SF1.F1_FORNECE  = '" +  cNumFor + "' "
cQuery += "          And  SF1.F1_LOJA  = '" +  cNumLoj + "' "
cQuery += "          And  SF1.D_E_L_E_T_ = '' 

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                             Adequa a Query                                 Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

cQuery := ChangeQuery(cQuery)

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё    Gera a Query em Arquivo Texto para Analises pelo Query Analyser         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Memowrite("ConLogNf.Sql" , cQuery )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                 Abre o Resultado da Query no Alias QRY                     Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

TcQuery cQuery New Alias "LOGNF"

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                    Ajusta os Campos Data e Numerico                        Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

TcSetField( "LOGNF" , "F1_XDATA"  , "D" , 08 , 0 )

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                     Abre o Arquivo Temporario CRD                          Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

DbSelectArea("LOGNF")
DbGoTop()

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                     Processa os Registros do Log                           Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

Do While LOGNF->( !Eof() )

 /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   Ё                      Adiciona ao Vetor o Log                             Ё
   юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

	aAdd( aVetor , { LOGNF->F1_DOC , LOGNF->F1_SERIE , LOGNF->F1_XDATA , LOGNF->F1_XHORA , LOGNF->F1_XUSUAR} )

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
	Aviso( "AtenГЦo !" , "NЦo existe Log Registrado para esta NF! " , {"Ok"}  )
Else

   /*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     Ё               Monta a Tela com o Resultado da Consulta                   Ё
     юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/
 
   Define MsDialog oDlg Title "Log da Nota" From 0,0 To 180,500 Pixel

   @ 10 , 10 ListBox oLbx Fields Header  "Numero NF", "Serie NF", "Data Reg", "Hora Reg" , "Usuario Reg" Size 230 , 50 Of oDlg Pixel ColSizes 40,40,40,15,60

   oLbx:SetArray( aVetor )
   oLbx:bLine := {|| {aVetor[oLbx:nAt,1] , aVetor[oLbx:nAt,2] , aVetor[oLbx:nAt,3] , aVetor[oLbx:nAt,4] , aVetor[oLbx:nAt,5]}}
					
   Define SButton From 70, 210 Type 1 Action oDlg:End() Enable Of oDlg
   Activate MsDialog oDlg Center

Endif

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                     Fecha o Arquivo Temporario                           Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

DbSelectArea("LOGNF")
DbCloseArea()

/*здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  Ё                   Restaura as Areas Selecionadas                         Ё
  юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды*/

RestArea( aArea )

Return