#Include "Rwmake.ch"
#include "topconn.ch"  
#include "TOTVS.CH"
/*_____________________________________________________________________________
¦ Função    ¦ MA651PRCLocal ¦ Autor ¦ Ricky Moraes          ¦ Data ¦ 29-05-19 ¦
+-----------+------------+-------+------------------------+------+------------+
¦ Descriçäo ¦ Verifica saldo em OP Prevista para Firme 								¦
 ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯ */
 
 
User Function MA651PRCLocal ()
  
Local cFuncao := Upper(Alltrim(FunName()))
Local lRet := .T.
Local aArea := GetArea()
Local nTotal := 0     

//-- -- Variaveis 
Local     oDlg 
Local     oGrp 
Local     oGridAtd 
Local     aH          := {} 
Local     aC          := {}  
Local oBtn1

//Local cXEmpOp := "T"
Local cXSLEMP := GETMV("MV_XSALEMP")
Local cQuery  := ""
Local aArea := GetArea()        
Local NumOp := SC2->C2_NUM
Private _cRev   := C2_REVISAO
Private cTexto := ""                  
Private cProPi := C2_PRODUTO
Private cTipoOP := C2_TPOP
//Private cNumOp:= C2_NUM
Private RFlag  := "S" 



cMarca   := PARAMIXB[1] // Marca utilizada pela MarkBrowseLocal 
lSelTudo := PARAMIXB[2] // Indica se marcou tudo (.T.) ou nao (.F.) 
lRet         := .F.// Validações do usuárioReturn lRet


cPro := C2_PRODUTO
SB1->(dbseek(xFilial()+cPro))

//alert(cFuncao)

IF cFuncao = "MATA651" 
		cQuery := "SELECT" 													     
		cQuery +="	SUM(B2_QEMP) EMP,											    "
		cQuery +="	SUM(B2_QATU) SALDO,											    "
		cQuery +="	(SUM(B2_QATU)- SUM(B2_QEMP)) DISPONIVEL,									    "
		//cQuery +="	SUM(D4_QUANT) PREVISTAM,
		cQuery +="(SELECT SUM(SD41.D4_QUANT) FROM SD4010 SD41 WHERE SD41.D_E_L_E_T_='' AND SD41.D4_OP=SD4.D4_OP AND SD41.D4_COD=SD4.D4_COD) PREVISTA,							    "		
											    "
		cQuery +="	((SUM(B2_QEMP)-SUM(B2_QATU)) - SUM(D4_QUANT)) FALTA ,							    "
		cQuery +="	B2_COD,													    "
		cQuery +="	B1_TIPO,B1_DESC													    "
		cQuery +=" FROM 													    "
		cQuery +="SD4010 SD4 													    "
		cQuery +="INNER JOIN SB2010 SB2 ON SB2.D_E_L_E_T_='' AND B2_COD=D4_COD AND B2_FILIAL=D4_FILIAL AND B2_LOCAL IN('11','20','17')   "
		cQuery +="INNER JOIN SB1010 SB1 ON SB1.D_E_L_E_T_='' AND D4_COD=B1_COD AND B1_FANTASM<>'S' AND  B1_MSBLQL <> '1'	    "
		cQuery +="														    "
		cQuery +="WHERE D4_OP='" + NumOp+"01001'"
		cQuery +="AND SD4.D_E_L_E_T_='' 								    "
		cQuery +="GROUP BY B2_COD,B1_TIPO,B1_DESC,D4_OP,D4_COD											    "
		cQuery +="HAVING (SUM(B2_QATU)-(SUM(B2_QEMP)) - "
		cQuery +=" (SELECT SUM(SD41.D4_QUANT) FROM SD4010 SD41 WHERE SD41.D_E_L_E_T_='' AND SD41.D4_OP=SD4.D4_OP AND SD41.D4_COD=SD4.D4_COD)   )<0							    "
		cQuery +="														    "
		cQuery +="														    "
		cQuery +="														    "
		cQuery +="														    "

		If Select("TSD4") > 0 
		     dbSelectArea("TSD4") 
		     dbCloseArea() 
		EndIf 
				
		TCQUERY ChangeQuery(cQuery) NEW ALIAS "TSD4"
		//memowrite("NEC_SD4",cQuery)
		

		Count To nTotal
      IF nTotal>0        
      
      //-- -- Popula aHeader. 
		AADD(aH, {"Codigo"      , "B2_COD" , "@!" , 15 , 00, , , "C", "TSD4", , , }) 
		AADD(aH, {"Descrição", "B1_DESC", "@!"		, 40 , 00, , , "C", "TSD4", , , }) 
		AADD(aH, {"Tipo"      , "B1_TIPO" , "@!" ,2 , 00, , , "C", "TSD4", , , }) 
		AADD(aH, {"Já Empenhados" , "EMP", "@E 999,999,999.99"	, TamSX3('D3_QUANT')[1], TamSX3('D3_QUANT')[2], , , "N", "TSD4", , , }) 
		AADD(aH, {"Saldo Fisico" , "SALDO", "@E 999,999,999.99"	, TamSX3('D3_QUANT')[1],TamSX3('D3_QUANT')[2], , , "N", "TSD4", , , }) 
		AADD(aH, {"Disponivel", "DISPONIVEL", "@E 999,999,999.99", TamSX3('D3_QUANT')[1], TamSX3('D3_QUANT')[2], , , "N", "TSD4", , , }) 
		AADD(aH, {"Previsto" , "PREVISTA", "@E 999,999,999.99"	, TamSX3('D3_QUANT')[1], TamSX3('D3_QUANT')[2], , , "N", "TSD4", , , }) 
		AADD(aH, {"Falta" , "FALTA", "@E 999,999,999.99"			, TamSX3('D3_QUANT')[1], TamSX3('D3_QUANT')[2], , , "N", "TSD4", , , }) 

					cTexto += "PRODUTO;DESCRICAO;TIPO;EMPENHADO;SALDO ATUAL;DISPONIVEL;PREVISTO;FALTA" + chr(13)+chr(10)
					TSD4->(DbGoTop())  
					
					While ! TSD4->(Eof()) 
					
					
					

								
						cTexto +=  ALLTRIM(TSD4->B2_COD) + ";"  + ALLTRIM(TSD4->B1_DESC) + ";" +ALLTRIM(TSD4->B1_TIPO) + ";" + Str(TSD4->EMP,15,4) + ";" + Str(TSD4->SALDO, 15, 4) + ";" +Str(TSD4->DISPONIVEL, 15, 4)+ ";"+ Str(TSD4->PREVISTA, 15, 4)  + "; " +Str(TSD4->FALTA, 15, 4) + chr(13)+chr(10)
						
										 AADD(aC, {TSD4->B2_COD, TSD4->B1_DESC,TSD4->B1_TIPO,TSD4->EMP,TSD4->SALDO,TSD4->DISPONIVEL,TSD4->PREVISTA,TSD4->FALTA,.F.}) 
						TSD4->(DbSkip())
			 	   EndDo
				
				
				TSD4->(dbCloseArea())
		
				If !Empty(cTexto)
				U_GRVTXT(CTEXTO)
			   /*
				oFont:= TFont():New("COURIER NEW",07,15)
				
				@ 000,000 To 300,800 Dialog oDlgMemo Title "Produtos sem Saldo"
				@ 001,003 Get cTexto Size 340,150  MEMO Object oMemo When .F.
				oMemo:oFont:=oFont
				
				@ 140,170 BmpButton Type 1 Action CLOSE(oDLGMEMO) Object oConf
				
				Activate Dialog oDlgMemo CENTERED On Init (oMemo:SetFocus())  
				
				*/
				

				oDlg = TDialog():New( 0, 0, 360, 1082, "Analise de Saldos PREVISTA" ,,,,, CLR_BLACK,CLR_WHITE ,,, .T. )
				

				//-- -- Cria objeto MsNewGetDados 
				//-- -- Documentaçã: http://tdn.totvs.com/display/public/mp/MsNewGetDados 
				oGridAtd:= MsNewGetDados():New( 005, 002, 150, 540, , , , , 'B2_COD', , 99, , , , oDlg, aH, aC, , ) 
				                                                                                                    
				//-- botao de sair
				oBtn1 := TButton():New( 156, 499, "Sair", oDlg,{|| oDlg:End() }, 40, 013,,,,.T. )


				//-- -- Ativa Janela DIalog 
				oDlg:Activate( , , , .T., {||}, , {||}, , )     
				
					alert("Não foi possível firmar OP, Sem Saldo no estoque !")
					//alert("Sem saldo, mas liberada")
					//lRet := .T. 
               
				ENDIF
       
		 ELSE
	   	//MSGINFO("Ordem de Produção:" +NumOp+"01001","Liberada")
			lRet := .T.       
		ENDIF //ntotal
		
END   



Return lRet




