#include "rwmake.ch"       

User Function Bzinv05a()      

SetPrvt("TAMANHO,TITULO,CDESC1,CDESC2,CDESC3,CPERG")
SetPrvt("LIMITE,ARETURN,NOMEPROG,NLASTKEY,LCONTINUA,M_PAG")
SetPrvt("LI,WNREL,CSTRING,ADTAEST,V_LOCPAD,V_CARINI")
SetPrvt("V_CARFIM,V_CLIINI,V_CLIFIM,V_PROINI,V_PROFIM,V_GRPINI")
SetPrvt("V_GRPFIM,V_TIPINI,V_TIPFIM,V_CAMDES,II,VVVV")
SetPrvt("CCABDTA,CABEC1,CABEC2,AESTRU,CNOMTMP,IIREGUA")
SetPrvt("V_CARRO,AESTATU,AESTC,V_DESC,CARQ,CGRUPO")
SetPrvt("TT,NORDEM,MPERGUNT,MVARIAVL,MTIPO,MTAMANHO")
SetPrvt("MDECIMAL,MGSC,MDEF01,MDEF02,MVAR01,acm")

SET CENTURY ON

tamanho  := "G"
titulo   := "DIFERENCA ENTRE CONTAGENS"
cDesc1   := "Imprime Relatorio Com as Diferencas de Contagem"
cDesc2   := " "
cDesc3   := " "
cPerg    := "BZINV5"
limite   := 220
aReturn  := { "Branco", 1,"Generico", 1, 2, 1, "",1 }
nomeprog := "BZINV05A"
nLastKey := 0
lContinua:= .T.
m_pag    := 1
li       := 100
wnrel    := "BZINV05A"
cString  := "SZU"
acm      := .f.
sx1_cad()  // CADASTRA PARAMETROS DE IMPRESSAO SE NAO EXISTIREM

pergunte(cPerg,.F.)
wnrel:=SetPrint(cString,wnrel,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,.F.,,.F.,tamanho)
If nLastKey == 27
	Return
Endif
SetDefault(aReturn,cString)
If nLastKey == 27
	Return
Endif

RptStatus({|| RptDetail()})// Substituido pelo assistente de conversao do AP6 IDE em 25/07/02 ==> RptStatus({|| Execute(RptDetail)})

Return

// --------------------------------------------------------------------------
// -----------------> Corpo do Programa

// Substituido pelo assistente de conversao do AP6 IDE em 25/07/02 ==> Function RptDetail
Static Function RptDetail()

V_DATA   := mv_par01          // Data                ?
V_LOCA1  := mv_par02          // Almoxarifado        ?
V_LOCA2  := MV_PAR03
V_PROD1  := mv_par04          // Carro Final         ?
V_PROD2  := mv_par05          // Prod.Cliente Inicial?
V_TIPO1  := mv_par06          // Prod.Cliente Final  ?
V_TIPO2  := mv_par07          // Produto Inicial     ?              

 
            cQuery    := "SELECT "
			cQuery    += "  ZU_FILIAL,ZU_COD,ZU_LOCPAD, ZU_TIPO, ZU_UM,ZU_NUMETQ, ZU_CONT1,ZU_CONT2,ZU_CONT3, ZU_ULTCONT, ZU_LOCALIZ"
			cQuery    += "FROM "
			cQuery    += RetSqlName("SZU")+" SZU "
			cQuery    += "WHERE "
			cQuery    += "    D_E_L_E_T_ <> '*' AND ZU_FILIAL='"+xFilial("SZU")+"' "
			cQuery	  += "    AND ZU_LOCPAD BETWEEN  '"+(mv_par02)+"'  AND    '"+(mv_par03)+"' "
			cQuery	  += "    AND ZU_COD    BETWEEN  '"+(mv_par04)+"'  AND    '"+(mv_par05)+"' "
			cQuery	  += "    AND ZU_TIPO BETWEEN    '"+(mv_par06)+"'  AND    '"+(mv_par07)+"' "
			cQuery    += "  ORDER BY ZU_FILIAL, ZU_COD, ZU_LOCPAD  "
			cQuery    := ChangeQuery(cQuery)
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)


Cabec1 := "               |         |                              |     |     |                 |                 |                 |                 |                 | Inventario  |     Saldo em     |  Diferenca   |  Endereço"
Cabec2 := "Codigo Produto |Nr. Etiq.|Descricao                     |Local|Unid.|Qtde. 1a Contagem|Qtde. 2a Contagem|Diferenca 1a - 2a|Qtde. 3a Contagem|Diferenca 2a - 3a|    Final    |     Estoque      |Estoque-Cont. |"


/*
|                |         |                                        |     |     |                 |                 |                 |                 |                 |             |     Diferenca    |
|Codigo Produto  |Nr. Etiq.|Descricao                               |Local|Unid.|Qtde. 1a Contagem|Qtde. 2a Contagem|Diferenca 1a - 2a|Qtde. 3a Contagem|Diferenca 2a - 3a|Qtde. Estoque|  Estoque-Contagem|
| xxxxxxxxxxxxxx |         |XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX| xx  |XXXXX|    999.999.99   |xxxxxxxxxxxxxxxxx|xxxxxxxxxxxxxxxxx|xxxxxxxxxxxxxxxxx|xxxxxxxxxxxxxxxxx|Nr. Etiqueta |                  |
012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123
1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20
*/

// --------------------------------------------------------------------------
// ----------------> Arquivos Utilizados

DbSelectArea("SB1")           // Produtos
DbSetOrder(1)                 // Produto

DbSelectArea("SZU")
DbSetOrder(2)

DbSelectArea("SB2")           // Produtos
DbSetOrder(1)
dbgotop()             // Produto

SetRegua( TMP->(LastRec()) )   // Regua
iiRegua := 0
li      := 200
v_qtdtot := 0
v_valtot := 0



TMP->( DBGOTOP() )

@ 00,00 Psay AvalImp(limite)
DO While !TMP->(Eof()) 
	
	IncRegua()
	
		
	titulo := "INVENTARIO ARMAZEM - " + V_LOCA1+" a "+V_LOCA2
	
	
	If lAbortPrint
		@ 00,01 PSAY "** CANCELADO PELO OPERADOR **"
		lContinua := .F.
		Exit
	Endif
	
	If li > 60
		li:= Cabec(titulo,cabec1,cabec2,nomeprog,tamanho)+1 //Impressao do cabecalho
	EndIf
	
	
	if !TMP->(eof())
	
		vDif := 0
		vCod   := left(TMP->ZU_cod,15)
		vLocal := TMP->ZU_locpad
		SB1->(DbSeek(xFilial("SB1")+TMP->ZU_cod))
		
		@li,000 PSAY TMP->ZU_COD //SB2->B2_COD
		@li,017 PSAY TMP->ZU_NUMETQ
		@li,026 PSAY SUBSTR(SB1->B1_DESC,1,32)
		@li,059 PSAY TMP->ZU_LOCPAD 
		@li,065 PSAY TMP->ZU_UM
		@li,073 PSAY TMP->ZU_CONT1               Picture "@E 9,999,999.99"
		@li,092 PSAY TMP->ZU_CONT2               Picture "@E 9,999,999.99"
		@li,110 PSAY TMP->ZU_CONT1-TMP->ZU_CONT2 Picture "@E 9,999,999.99"
		@li,127 PSAY TMP->ZU_CONT3               Picture "@E 9,999,999.99"
		if TMP->ZU_ultcont == 3
			@li,145 PSAY TMP->ZU_CONT2-TMP->ZU_CONT3 Picture "@E 9,999,999.99"
		endif
				
		// Acumular quantidade
		if TMP->ZU_ultcont <= 1
			vDif := TMP->ZU_cont1        
			@li,159 PSAY TMP->ZU_cont1                Picture "@E 9,999,999.99"
		elseif TMP->ZU_ultcont == 2
			vDif := TMP->ZU_cont2     
			@li,159 PSAY TMP->ZU_cont2                Picture "@E 9,999,999.99"
		elseif TMP->ZU_ultcont == 3
			vDif := TMP->ZU_cont3     
			@li,159 PSAY TMP->ZU_cont3                Picture "@E 9,999,999.99"
		endif   
		cEndItem := AllTrim(TMP->ZU_LOCALIZ)
		
				
		TMP->(dbskip())
		DO WHILE Alltrim(vCod)==Alltrim(TMP->ZU_cod) .and. Alltrim(vLocal)==Alltrim(TMP->ZU_locpad) .AND. !TMP->(EOF())
			
			/*
			IF TMP->ZU_LOCPAD < V_LOCA1 .or. TMP->ZU_LOCPAD > V_LOCA2
			   TMP->(DbSkip())
			   Loop
			ENDIF
			*/
			
			SB1->( DbSeek(xFilial("SB1")+LEFT(TMP->ZU_cod,15) ) )
			
			acm := .T.
			li := li + 1
			//@li,000 PSAY SB2->B2_COD
			@li,017 PSAY TMP->ZU_NUMETQ
			@li,026 PSAY SUBSTR(SB1->B1_DESC,1,32)
			@li,059 PSAY TMP->ZU_LOCPAD //SB2->B2_LOCAL
			@li,065 PSAY TMP->ZU_UM
			@li,073 PSAY TMP->ZU_CONT1               Picture "@E 9,999,999.99"
			@li,092 PSAY TMP->ZU_CONT2               Picture "@E 9,999,999.99"
			@li,110 PSAY TMP->ZU_CONT1-TMP->ZU_CONT2 Picture "@E 9,999,999.99"
			@li,127 PSAY TMP->ZU_CONT3               Picture "@E 9,999,999.99"
			if TMP->ZU_ultcont == 3
				@li,145 PSAY TMP->ZU_CONT2-TMP->ZU_CONT3 Picture "@E 9,999,999.99"
			endif
			
			// Acumular quantidade
			if TMP->ZU_ultcont <= 1
				vDif := vDif + TMP->ZU_cont1
				@li,159 PSAY TMP->ZU_cont1                Picture "@E 9,999,999.99"
			elseif TMP->ZU_ultcont == 2
				vDif := vDif + TMP->ZU_cont2
				@li,159 PSAY TMP->ZU_cont2                Picture "@E 9,999,999.99"
			elseif TMP->ZU_ultcont == 3
				vDif := vDif + TMP->ZU_cont3
				@li,159 PSAY TMP->ZU_cont3                Picture "@E 9,999,999.99"
			endif
			
			@ li,208 PSAY AllTrim(TMP->ZU_LOCALIZ)
			
			If li > 60
				li:= Cabec(titulo,cabec1,cabec2,nomeprog,tamanho)+1 //Impressao do cabecalho
			EndIf
			
			TMP->(dbskip())
		ENDDO
		
		
		
		aSaldos := CalcEst(vCod,vLocal, V_DATA+1 )
		nQtde  := aSaldos[1]
		nCusto := aSaldos[2]
		nQtde2 := aSaldos[7]
		
		//v_unit := (nCusto / nQtde)
		SB2->( dbSeek(xFilial("SB2")+vCod+vLocal) )
	    v_unit := SB2->B2_CM1
		
		IF acm 
			li := li + 1
			@li,026 PSAY "TOTAL DO PRODUTO..."
			@li,157 PSAY vDif                Picture "@E 999,999,999.99"
			@li,177 PSAY nQtde               Picture "@E 999,999,999.99"
  		    @li,192 PSAY vDif-nQtde          Picture "@E 999,999,999.99"
  		ELSE                                                            
    		@li,177 PSAY nQtde               Picture "@E 999,999,999.99"
  		    @li,192 PSAY vDif-nQtde          Picture "@E 999,999,999.99"
   		    @ li,208 PSAY cEndItem
  		   
		ENDIF
		
		
		if acm 
			li := li + 2
			acm := .f.
		else
			li := li + 1
		endif
		v_qtdtot := v_qtdtot + (vDif-nQtde)
		v_valtot := v_valtot + ((vDif-nQtde) * v_unit)
		
	endif
	
EndDO
li++
@li,175 PSAY v_qtdtot   Picture "@E 9,999,999,999.99"
@li,195 PSAY v_valtot  Picture "@E 99,999,999,999.99"
//@ li,208 PSAY AllTrim(TMP->ZU_LOCALIZ)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se em disco, desvia para Spool                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If aReturn[5] == 1
	Set Printer TO
	dbcommitAll()
	ourspool(wnrel)
Endif

TMP->(DBCLOSEAREA())
MS_FLUSH()


Return NIL

**************************************************************************************
//-------------------------------------------
//---------------> Cadastro de parametros SX1
// Substituido pelo assistente de conversao do AP6 IDE em 25/07/02 ==> function sx1_cad
Static function sx1_cad()
Local tt, nOrdem
cARQ   := alias()   // Salva Alias do Arquivo Atual

cGRUPO := "BZINV5"  // Alterar para nome parametros do RDMAKE

dbselectarea("SX1") // Arquivo de parametros
dbsetorder(1)
dbseek(cGRUPO,.T.)
if found()
	dbselectarea(cARQ)
	return NIL
endif

tt       := 0                              // Tentativas de bloqueio

nORDEM   := 0                              // Numero de Ordem

// -------> Array     @00,000 say s contendo dados dos parametros

mPERGUNT := {"Dta. Contagem      ?","Almoxarifado       ?",;
"Produto Inicial    ?","Produto Final      ?",;
"Tipo Inicial       ?","Tipo Final         ?"}

mVARIAVL := {"mv_ch1","mv_ch2","mv_ch3","mv_ch4","mv_ch5","mv_ch6"}
mTIPO    := {"D","C","C","C","C","C"}
mTAMANHO := {08,02,15,15,02,02}
mDECIMAL := {00,00,00,00,00,00}
mGSC     := {"G","G","G","G","G","G"}
mDEF01   := {"","","","","",""}
mDEF02   := {"","","","","",""}
mVAR01   := {"mv_par01","mv_par02","mv_par03","mv_par04","mv_par05","mv_par06"}
// Grava Parametros
for nORDEM := 1 to len(mPERGUNT)
	
	for tt := 1 to 5
		if reclock("SX1",.T.)
			replace X1_GRUPO   with cGRUPO
			replace X1_ORDEM   with strzero(nORDEM,2)
			replace X1_PERGUNT with mPERGUNT[nORDEM]
			replace X1_VARIAVL with mVARIAVL[nORDEM]
			replace X1_TIPO    with mTIPO[nORDEM]
			replace X1_TAMANHO with mTAMANHO[nORDEM]
			replace X1_DECIMAL with mDECIMAL[nORDEM]
			replace X1_GSC     with mGSC[nORDEM]
			replace X1_DEF01   with mDEF01[nORDEM]
			replace X1_DEF02   with mDEF02[nORDEM]
			replace X1_VAR01   with mVAR01[nORDEM]
			dbunlock()
			exit
		endif
	next
	
next

dbcommit()
dbselectarea(cARQ)
Return NIL
