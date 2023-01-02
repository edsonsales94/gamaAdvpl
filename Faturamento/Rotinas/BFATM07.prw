#include "rwmake.ch"
#include "protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BFATM07  ³ Por: Luiz Fernando            ³ Data ³07.02.2018³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Altera os vendedores dos clientes							     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Brasitech                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function BFATM07()           

Local aArea 	:= GetArea()
Local cPerg		:= "BFATM07"
Local aRegs		:= {}   
Local aCabSX1	:= { "X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_VARIAVL", "X1_TIPO", "X1_TAMANHO", "X1_DECIMAL", "X1_GSC", "X1_VAR01", "X1_F3", "X1_VALID" }
Local aHlp01	:= {"Informe qual vendedor deseja", "filtrar para realizar", "alteração"}
Local aHlp02	:= {"Informe qual vendedor deseja", "filtrar para realizar", "alteração"}
Local aHlp03	:= {"Informe qual canal deseja", "filtrar para realizar", "alteração"}
Local aHlp04	:= {"Informe qual gerente deseja", "filtrar para realizar", "alteração"}
Local aHlp05	:= {"Informe qual gerente deseja", "filtrar para realizar", "alteração"}
Local aHlp06	:= {"Informe qual região deseja", "filtrar para realizar", "alteração"}
Local aHlp07	:= {"Informe novo vendedor para", "realizar altereção", ""}
Local cEol		:= chr(13) + chr(10)
Local cQuery	:= ""
Local aRegiao	:= {}
Local cRegiao	:= ""
Local nx := 0 

aAdd(aRegs, {cPerg, "01", "Do Vendedor?"	, "mv_ch1", "C", 06, 0, "G", "mv_par01", "SA3", "vazio() .or. ExistCpo('SA3')"})
aAdd(aRegs, {cPerg, "02", "Até Vendedor?"	, "mv_ch2", "C", 06, 0, "G", "mv_par02", "SA3", "vazio() .or. pertence('ZZZZZZ') .or. ExistCpo('SA3')"})
aAdd(aRegs, {cPerg, "03", "Canal?"			, "mv_ch3", "C", 20, 0, "G", "mv_par03", "SZQ", "vazio() .or. ExistCpo('SZQ',mv_par03,2)"})
aAdd(aRegs, {cPerg, "04", "Do Gerente?"	, "mv_ch4", "C", 06, 0, "G", "mv_par04", "ZB4", "vazio() .or. ExistCpo('SZB')"})
aAdd(aRegs, {cPerg, "05", "Até Gerente?"	, "mv_ch5", "C", 06, 0, "G", "mv_par05", "ZB4", "vazio() .or. pertence('ZZZZZZ') .or. ExistCpo('SZB')"})
aAdd(aRegs, {cPerg, "06", "Região?"			, "mv_ch6", "C", 50, 0, "G", "mv_par06", "", ""})
aAdd(aRegs, {cPerg, "07", "Novo Vendedor:", "mv_ch7", "C", 06, 0, "G", "mv_par07", "SA3", "ExistCpo('SA3')"})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando o grupo de perguntas                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
U_BRASX1(aRegs, aCabSX1)	//Funcao contida dentro do BCFGA01.prw

PutSX1Help("P." + AllTrim(cPerg) + "01.", aHlp01, aHlp01, aHlp01)
PutSX1Help("P." + AllTrim(cPerg) + "02.", aHlp02, aHlp02, aHlp02)
PutSX1Help("P." + AllTrim(cPerg) + "03.", aHlp03, aHlp03, aHlp03)
PutSX1Help("P." + AllTrim(cPerg) + "04.", aHlp04, aHlp04, aHlp04)
PutSX1Help("P." + AllTrim(cPerg) + "05.", aHlp05, aHlp05, aHlp05)
PutSX1Help("P." + AllTrim(cPerg) + "06.", aHlp06, aHlp06, aHlp06)
PutSX1Help("P." + AllTrim(cPerg) + "07.", aHlp07, aHlp07, aHlp07)


if !Pergunte(cPerg, .T.)
	Return()
endif

If MsgBox("Confirma alteração de vendedor nos clientes ?","Atenção","YESNO")
	if !empty(mv_par07)
		if !empty (mv_par04) .and. !empty (mv_par05)  
			aRegiao := STRTOKARR(mv_par06,"-,;/")
			
			for nx := 1 to len(aRegiao)
				cRegiao += "'"+alltrim(aRegiao[nx])+"',"			
			next
			
			cRegiao := substr(cRegiao,1,len(cRegiao)-1)
			
			
			////ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			////³ Faz update do A1_VEND de acordo com os parâmetros informados ³
			////ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
			cQuery := "UPDATE "+RetSQLname("SA1")+" "
			cQuery += "SET A1_VEND = '"+mv_par07+"',A1_XRADIX ='A' " 
			cQuery += "FROM "+RetSQLname("SA1")+" JOIN "+RetSQLname("SA3")+" ON A1_VEND = A3_COD JOIN "+RetSQLname("SZB")+" ON A3_XEXECUT = ZB_COD "
			cQuery += "WHERE A1_VEND >= '"+mv_par01+"' AND A1_VEND <= '"+mv_par02+"' "
			if !empty(mv_par03)
				cQuery += "AND A1_XMCANAL = '"+mv_par03+"' "
			endif
			cQuery += "AND ZB_COD >= '"+mv_par04+"' AND ZB_COD <='"+mv_par05+"' "
			if !empty(mv_par06)
				cQuery += "AND A1_REGIAO IN("+cRegiao+")"
			endif
			                 
			TCSQLEXEC(cQuery)
			
			MsgBox("Alteração finalizada. Favor verificar os cadastros dos clientes.","Atenção","INFO")
		else 
			Help(" ", 1, "ATENÇÃO", , "O Parâmetro que contém os códigos do gerente não podem ficar em branco." + cEol + "(Específico Brasitech). ", 1)	
		endif		                                           
	else 
		Help(" ", 1, "ATENÇÃO", , "O Parâmetro que contém o código do novo vendedor não pode ficar em branco." + cEol + "(Específico Brasitech). ", 1)	
	endif
endif

RestArea(aArea)
Return