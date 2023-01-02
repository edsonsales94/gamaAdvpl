#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"
#Define ENTER Chr(13)+Chr(10)
#define VK_F4    115 

//+------------+---------------+-------+------------------------+------+------------+
//| Função:    | BGKO06        | Criado por: |Jose Mendes       |Data: 07/06/2018   | 
//+------------+---------------+-------+------------------------+------+------------+
//| Descrição: | Rotina para reprocessar e exportar notas para o Gko avulso colocado 
//| em nenu NO GRUPO de usuario especifico 
//+------------+--------------------------------------------------------------------+
//|Empresa:    | Brasitech     | Os/Chamado: 			                            |
//+---------------------------------------------------------------------------------+

user function  BGKO06()


private cTitulo := "Reprocessa NFs Gko - Brasitech " //titulo da janela 
private cTexto := "Numero da Nfs: "   //label 
private cAr     := "000000000"

     DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 100,300 PIXEL   //monta janela 

//posicionamento dos objetos 

     @005,005 TO 045,145 OF oDlg PIXEL                          //borda interna 
     @015,020 SAY cTexto SIZE 060,007 OF oDlg PIXEL             //label 
     @012,075 MSGET cAr SIZE 055,011 OF oDlg PIXEL PICTURE "@!" VALID !Vazio()
     
     DEFINE SBUTTON FROM 030,025 TYPE 1; 
     ACTION (Procuranfs(cAr)) ENABLE OF oDlg              
     DEFINE SBUTTON FROM 030,100 TYPE 2; 
     ACTION (oDlg:End()) ENABLE OF oDlg 
     
      DEFINE SBUTTON FROM 030,100 TYPE 2; 
     ACTION (oDlg:End()) ENABLE OF oDlg 
      

ACTIVATE MSDIALOG oDlg CENTERED 

RETURN 


static function Procuranfs(cAr) 
Local aAreaSF2	:= SF2->(GetArea()) 
Local lOk       := .T. 

SF2->(dbSetOrder(1))

cQuery := 	"SELECT DISTINCT SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_EMISSAO, SF2.F2_CLIENTE, SF2.F2_LOJA,SF2.F2_FILIAL,SA4.A4_VIA,  "
cQuery += 	"SF2.F2_X_COLET, SF2.F2_TRANSP, SF2.F2_VOLUME1, SA4.A4_XPEDCLI,SF2.F2_X_OPLOG,SF2.F2_X_DBLQ2,SF2.F2_X_DBLQ1, SF2.F2_VALBRUT "
cQuery += 	"FROM " + RetSQLName("SF2") + " SF2, " + RetSQLName("SA4") + " SA4, " + RetSQLName("SD2") + " SD2, "
cQuery += 	"WHERE SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND SF2.D_E_L_E_T_ = ' ' "
cQuery += 	"AND SA4.A4_FILIAL = ' ' AND SA4.D_E_L_E_T_ = ' ' "
cQuery += 	"AND SF2.F2_DOC = '"+ cValToChar(cAr) +"' "
cQuery +=	"AND SF2.F2_DOC = SD2.D2_DOC "
cQuery +=	"AND SF2.F2_SERIE = SD2.D2_SERIE "
cQuery +=	"AND SF2.F2_FILIAL = SD2.D2_FILIAL "
cQuery +=	"AND SA4.A4_COD = SF2.F2_TRANSP " 
cQuery +=	"AND SF2.F2_TIPO IN ('N','B') "
cQuery +=	"AND SD2.D2_CF NOT IN ('5905','6905','5934','6934') "
cQuery +=	"AND SF2.F2_TRANSP != '      ' "
cQuery +=	"AND SD2.D2_TES IN (SELECT F4_CODIGO FROM " + RetSqlName("SF4") + " "
cQuery +=	"WHERE F4_ESTOQUE = 'S' AND D_E_L_E_T_ = '' AND F4_FILIAL = '" + xFilial("SF4") + "') "
cQuery += 	"ORDER BY F2_SERIE, F2_DOC"

              
if Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea()
endif
	
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"TRB", .F., .T.)
tcSetField("TRB", "F2_EMISSAO", "D")

Memowrite("Procuranfs.Sql" , cQuery  )

dbSelectArea("TRB")
dbGotop()
if TRB->(!eof()) 

           //atualiza sf2 para processar novamente A EXPORTAÇÃO PARA GKO
     
			If SF2->( dbSeek(xFilial("SF2") + TRB->F2_DOC + TRB->F2_SERIE + TRB->F2_CLIENTE + TRB->F2_LOJA ) )
					    //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA
				If SF2->( RecLock("SF2",.F.) )
					//SF2->F2_X_EXPGK := " "
					SF2->(MsUnlock())
				lOk = .T.
				
				endif
				else
				//NÃO ENCONTROU A NOTA
				lOk = .F.
			endif

else
   //NÃO ENCONTROU A NOTA
	lOk = .F.	
	
Endif

if Select("TRB") > 0
	dbSelectArea("TRB")
	dbCloseArea()
endif

if lOk
  	
  		If MsgYesNo("Nota alterada com sucesso!Deseja Processar outra nota?","","YESNO")
   			//chama rotina para exportaR notas GKO
   		  //	U_BRAJOB07()
   			
			Else
  			//chama rotina para exportaR notas GKO
			U_()   
			msgbox("Processo Realizado com Sucesso")
  			oDlg:End()  
			EndIf
  	else

msgbox("Nota fiscal Saida não encontrada")

endif

RestArea ( aAreaSF2 )

RETURN()
