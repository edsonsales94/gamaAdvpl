#Include "Protheus.ch"                            
#Include "RwMake.ch"
#Include "TopConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRELVEND      บAutor  ณAMarques          บ Data ณ  17/05/18  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  

User Function RELVEND() 
Local aPar 			:= {}
Local aRet 			:= {}
Local cPergEnt		:= "RELVEND"
Local nA 
     
Private cQry     := ""
Private cArquivo := "\RELVEND.xls"
Private cTitTab  := "Relat๓rio De Vendas"
Private cTitTab2  := "Relat๓rio De Recebimentos"  
Private cAba     := "Vendas"    
Private cAba2     := "Recebimentos"    
Private oExcel := Nil
Private cFunc  := "1"     
Private cVez   := "1" 

//Parametros
AAdd( aPar, { 1, 'Data de Fechamento'	   ,Ctod(Space(8))          ,'',''                    ,''      	         , '', 50, .F. } )
AAdd( aPar, { 1, 'Do Caixa '	    	   ,Space(100) ,'',''                    ,''   	         , '', 100, .F. } )
AAdd( aPar, { 6, 'Diret๓rio de destino',Space(60)               ,'',".T."                 ,"!Empty(mv_par03)",80,.T.," |*.","c:\",GETF_RETDIRECTORY+GETF_LOCALHARD})
//aAdd(aPar,{2,"Informe o m๊s",1,aCombo,50,"",.F.})

For nA := 1 To Len(aPar)
	aPar[nA][03] := ParamLoad(cPergEnt,aPar,nA,aPar[nA][03])
Next nA

//If !ParamBox( aPar, 'Parโmetros de processamento',@aRet)  //,,,,,,,,.T.,.F.)
If !ParamBox( aPar, cTitTab,@aRet ,,,,,,,,.T.,.F.)
	Return()
Endif                        

ParamSave(cPergEnt,aRet,"1")         

cArquivo := Alltrim(MV_PAR03)+cPergEnt+".xls"

Processa( {|| GERREL01() }, cTitTab,"Aguarde, processando os dados...", .F. ) 
	
Return()	 
		
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGERREL01     บAutor  ณAMarques          บ Data ณ  17/05/18  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GERREL01()          
Local aPar 			:= {}
Local aRet 			:= {}
Local cPergEnt		:= "RELVEND" 
     
Private cQry     := ""
Private cArquivo := "\RELVEND.xls"
Private cTitTab  := "Relat๓rio De Vendas" 
Private cTitTab2  := "Relat๓rio De Recebimentos" 
Private cAba     := "Vendas" 
Private cAba2     := "Recebimentos"  
Private oExcel := Nil
Private cFunc  := "1"
Private cVez   := "1"
                                             
cArquivo := Alltrim(MV_PAR03)+cPergEnt+".xls"

cQry   := XQRY01() //Monta QRY 01
oExcel := XSTRUCEXC("1",cVez,oExcel,cTitTab,cAba) //Monta a estrutura do Excel

 
If SELECT("TR1") > 0
	DBSelectArea("TR1")
	TR1->(DBCloseArea())
EndIf
 
TCQUERY cQry ALIAS "TR1" NEW

DbSelectArea("TR1")
TR1->(DbGoTop())

While !TR1->(Eof())
          
	Do Case
		Case cFunc == "1"                                                                                 
		
			oExcel:AddRow(cAba,cTitTab,{ Alltrim(TR1->PDV),;	 
										 		  Alltrim(TR1->PRODUTO),;
										 		  Alltrim(TR1->DESCRICAO),;										 
										        TR1->QUANT,;										 
			                             TR1->VRUNIT,;	
			                             TR1->VALBRUT,;
			                             TR1->VALDESC,;
			                             TR1->VLRLIQ})//VLR_RATEIO
	        
						
	EndCase
	TR1->(DbSkip())  

cVez := "2" // Atribui esta variavel para poder criar a segunda query e criar tambem o segundo cabe็alho	
	
EndDo         
   
	If cVez == "2"   // verifico se ้ a segunda tabela "Venda.. dinheiro/cartใo..."
	  
	
		cQry2 := ""
		cQry2 += " SELECT L1_PDV, "+CRLF  
		cQry2 += "        L4_FORMA AS FORMA,  "+CRLF  
		cQry2 += "        L4_ADMINIS AS DESCRICAO, "+CRLF   
		cQry2 += "        ROUND(SUM(L4_VALOR),2) AS VALOR "+CRLF         
		cQry2 += " FROM "+RETSQLNAME("SL1")+" AS SL1 "+CRLF
		cQry2 += " --INNER JOIN "+RETSQLNAME("SL2")+" AS SL2 ON L1_FILIAL = L2_FILIAL "+CRLF
		cQry2 += " --                        AND L1_NUM = L2_NUM "+CRLF
		cQry2 += " --                        AND SL2.D_E_L_E_T_ = '' "+CRLF
		cQry2 += " --                        AND L2_PDV  BETWEEN '801' AND '803' -- PARAMETRO DE CAIXA "+CRLF
		cQry2 += " --                        AND L2_SITUA = 'RX' "+CRLF
		cQry2 += " INNER JOIN "+RETSQLNAME("SL4")+" AS SL4 ON SL1.L1_FILIAL = SL4.L4_FILIAL "+CRLF  
		cQry2 += "                      AND SL1.L1_NUM = SL4.L4_NUM   "+CRLF
		cQry2 += "                      AND SL4.D_E_L_E_T_ = ''   "+CRLF                        
		cQry2 += " WHERE L1_FILIAL = '08'   "+CRLF 
		cQry2 += " AND L1_EMISSAO = '"+ DtoS(MV_PAR01) +"' "+CRLF
		cQry2 += " AND SL1.L1_SITUA = 'OK'   "+CRLF
		cQry2 += " AND L1_PDV IN " + FormatIn(MV_PAR02,";") + " --('801','802','803') -- BETWEEN '801' AND '803' -- PARAMETRO DE CAIXA "+CRLF
		cQry2 += " AND SL1.D_E_L_E_T_ = '' "+CRLF
		cQry2 += " GROUP BY L1_PDV,L4_FORMA, L4_ADMINIS "+CRLF 
		cQry2 += " ORDER BY L1_PDV; "+CRLF

		MemoWrite("RELVEND_QRY02.SQL",cQry2)

		TCQUERY cQry2 ALIAS "TR2" NEW 
				
		nTotReg := 0
		TR2->(DbGotop())
		TR2->(dbEval({|| nTotReg++ }))
		TR2->(DbGotop())               
		 //	oExcel := XSTRUCEXC("2",cVez,oExcel,cTitTab,cAba2) //Monta a estrutura do Excel
		 
			   oExcel:AddworkSheet(cAba2) //Adiciona aba
				oExcel:AddTable (cAba2,cTitTab2) //Inicia a tabela
				oExcel:AddColumn(cAba2,cTitTab2,"CAIXA" 		,1,1) //
		 		oExcel:AddColumn(cAba2,cTitTab2,"FORMA"       ,1,1) //
		  		oExcel:AddColumn(cAba2,cTitTab2,"DESCRICAO"   ,1,1) //
		  		oExcel:AddColumn(cAba2,cTitTab2,"VALOR"       ,1,2,.T.) //
		
			If nTotReg > 0	
				While !TR2->(Eof()) 				
				oExcel:AddRow(cAba2,cTitTab2,{ Alltrim(TR2->L1_PDV),;	 
													  Alltrim(TR2->FORMA),;
											 		  Alltrim(TR2->DESCRICAO),;
			    	                          TR2->VALOR})//VLR_RATEIO			
				
			    	TR2->(DbSkip())
				EndDo	
				
				TR2->(DbCloseArea())			
			EndIf
	
	EndIf
		

oExcel:Activate()
oExcel:GetXMLFile( cArquivo )

TR1->(DbCloseArea())

If ApOleClient( 'MsExcel' )
	oExcelApp:= MsExcel():New()
	oExcelApp:WorkBooks:Open(ALLTRIM( cArquivo )) // Abre uma planilha
	oExcelApp:SetVisible(.T.)
Else
	Alert(OemtoAnsi( "Microsoft Excel nao encontrado !" ))
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXQRY01      บAutor  ณAMarques          บ Data ณ  17/05/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function XQRY01()

Local cQry := ""

cQry += " "+CRLF
cQry += " SELECT L2_PDV AS PDV, "+CRLF 
cQry += " L2_PRODUTO AS PRODUTO, "+CRLF
cQry += "  L2_DESCRI AS DESCRICAO, "+CRLF
cQry += "      SUM( L2_QUANT) AS QUANT,  "+CRLF
cQry += "              SUM(L2_PRCTAB ) AS VRUNIT, "+CRLF 
cQry += "              (SUM(L2_PRCTAB) * SUM(L2_QUANT)) AS VALBRUT,  "+CRLF
cQry += "              SUM( (L2_VALDESC + L2_DESCPRO)) AS VALDESC,  "+CRLF
cQry += "              ((SUM(L2_PRCTAB) * SUM(L2_QUANT)) - SUM( (L2_VALDESC + L2_DESCPRO)) ) AS VLRLIQ,  "+CRLF
cQry += "        (SELECT SUM(L4_VALOR) FROM SL4010 WHERE L4_FILIAL = L2_FILIAL AND L4_NUM = L2_NUM AND D_E_L_E_T_ = '')  "+CRLF     
cQry += " FROM "+RETSQLNAME("SL2")+" SL2 "+CRLF
cQry += " WHERE L2_FILIAL = '08' "+CRLF
cQry += " AND L2_NUM IN ( SELECT L1_NUM "+CRLF
cQry += "                 FROM "+RETSQLNAME("SL1")+" SL1 "+CRLF
cQry += "                 WHERE L1_FILIAL = '08' "+CRLF
cQry += "                 AND L1_EMISSAO = '"+ DtoS(MV_PAR01) +"' "+CRLF
cQry += "                 AND L1_SITUA = 'OK' "+CRLF
cQry += "                 AND L1_PDV IN " + FormatIn(MV_PAR02,";") + " -- ('801','802','803') "+CRLF
cQry += "                 AND SL1.D_E_L_E_T_ = '' "+CRLF
cQry += "                 GROUP BY L1_NUM) "+CRLF
cQry += " AND D_E_L_E_T_ = '' "+CRLF
cQry += " GROUP BY L2_FILIAL, L2_PDV,L2_PRODUTO, L2_DESCRI,L2_NUM "+CRLF
cQry += " ORDER BY L2_PDV "+CRLF

MemoWrite("RELVEND_QRY01.SQL",cQry)


Return(cQry)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXSTRUCEXC   บAutor  ณAMarques          บ Data ณ  17/05/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function XSTRUCEXC(_cFUNC,_cVez,oOBJExcel,cTitTab,cAba)

Local oExcel  := FWMSEXCEL():New()

Default oOBJExcel := Nil            
Default cTitTab  := "" 
Default cAba     := "" 
Default _cVez 	 := ""
                      

Do Case
	Case _cFUNC == "1"
		
		oExcel:AddworkSheet(cAba) //Adiciona aba
		oExcel:AddTable (cAba,cTitTab) //Inicia a tabela
		oExcel:AddColumn(cAba,cTitTab,"CAIXA" 				,1,1) //
		oExcel:AddColumn(cAba,cTitTab,"PRODUTO"             ,1,1) //
		oExcel:AddColumn(cAba,cTitTab,"DESCRICAO"             ,1,1) //
		oExcel:AddColumn(cAba,cTitTab,"PEวAS"               ,1,1,.T.) //
		oExcel:AddColumn(cAba,cTitTab,"PREวO UNITARIO"      ,1,2) //
		oExcel:AddColumn(cAba,cTitTab,"VALOR VENDA BRUTA"   ,1,2,.T.) //
		oExcel:AddColumn(cAba,cTitTab,"VALOR DO DESCONTO"   ,1,2) //
		oExcel:AddColumn(cAba,cTitTab,"VALOR VENDA LIQUIDA" ,1,2,.T.) //
  
	Case _cFUNC == "2" 
	  oExcel:AddworkSheet(cAba2) //Adiciona aba
		oExcel:AddTable (cAba2,cTitTab) //Inicia a tabela
		oExcel:AddColumn(cAba2,cTitTab,"CAIXA" 		,1,1) //
		oExcel:AddColumn(cAba2,cTitTab,"FORMA"       ,1,1) //
		oExcel:AddColumn(cAba2,cTitTab,"DESCRICAO"   ,1,1) //
		oExcel:AddColumn(cAba2,cTitTab,"VALOR"       ,1,2,.T.) // 		
/*	Case _cVez == "2"
		
		oExcel:AddworkSheet(cAba) //Adiciona aba
		oExcel:AddTable (cAba,cTitTab) //Inicia a tabela
		oExcel:AddColumn(cAba,cTitTab,"CAIXA" 		,1,1) //
		oExcel:AddColumn(cAba,cTitTab,"FORMA"       ,1,1) //
		oExcel:AddColumn(cAba,cTitTab,"DESCRICAO"   ,1,1) //
		oExcel:AddColumn(cAba,cTitTab,"VALOR"       ,1,2) //    */
	EndCase  
            
 
oOBJExcel := oExcel
 
Return(oOBJExcel)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRELVEND   บAutor  ณMicrosiga           บ Data ณ  05/17/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function XSTRUCEXC2(_cFUNC,_cVez,oOBJExcel,cTitTab,cAba)

Local oExcel  := FWMSEXCEL():New()

Default oOBJExcel := Nil            
Default cTitTab  := "" 
Default cAba     := "" 
Default _cVez 	 := ""
                      

Do Case
	Case _cFUNC == "1"
		
		oExcel:AddworkSheet(cAba) //Adiciona aba
		oExcel:AddTable (cAba,cTitTab) //Inicia a tabela
		oExcel:AddColumn(cAba,cTitTab,"CAIXA" 		,1,1) //
		oExcel:AddColumn(cAba,cTitTab,"FORMA"       ,1,1) //
		oExcel:AddColumn(cAba,cTitTab,"DESCRICAO"   ,1,1) //
		oExcel:AddColumn(cAba,cTitTab,"VALOR"       ,1,2,.T.) //  
/*	Case _cVez == "2"
		
  */
	EndCase  
            
 
oOBJExcel := oExcel
 
Return(oOBJExcel)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณXAddRow     บAutor  ณAMarques          บ Data ณ  17/05/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function XAddRow(_cFUNC,oExcel,cAba,cTitTab,aDados)
                        
Default _cFUNC  := ""                        
Default oExcel  := Nil
Default cAba    := ""
Default cTitTab := ""
Default aDados  := {}

Return()   