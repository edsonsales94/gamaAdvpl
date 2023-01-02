#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma ณBETIQ01บAlterado por ณFelipe Varellaบ     Data ณ  19/06/15  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescri็ใo ณ Rotina de impressao de etiquetas termicas, especifico para บฑฑ
ฑฑบDescri็ใo ณ a impressora Argox imprime o volume da nf de saida         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus - Especํfico para a empresa Brasitech.            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function BETIQ01()

aArea       := GetArea()
aAreaSF2    := SF2->(GetArea())
aAreaSB1    := SB1->(GetArea())
aAreaSA1    := SA1->(GetArea())
aAreaSA2    := SA2->(GetArea())
Titulo		:= "Etiqueta Desisnatแrio"
aPerg       := {}
_cDoc   :=    ""
_cNota	:=	""
_cSerie	:=	""
_nVolume:=	0

Private cPerg  := "BETIQ01"
Private _cRotina := "BETIQ01"

ValidPerg()

If Pergunte(cPerg,.T.) == .F.
	Return(.T.)
Endif

aAreaSF2    := SF2->(GetArea())
Processa({|lEnd| Proces()},Titulo,"Aguarde... Processando a impressใo...",.T.)


RestArea(aArea)
RestArea(aAreaSF2)
RestArea(aAreaSA1)
RestArea(aAreaSA2)
RestArea(aAreaSB1)

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณProcesบAlterado por  ณFelipe Varellaบ Data ณ       30/06/15 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDescri็ใo ณ Processamento da rotina.                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 - Especํfico para a empresa Brasitech.         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/


Static Function Proces()

Local	_cNota	:=	""
Local	_cSerie	:=	""
Local	_nVolume:=	0
Local	_nAux := 1
Local	_cCodbar:= ""
Local x

Private oFont1	:= TFont():New("Verdana",,10,,.F.,,,,,.F. )
Private oFont2	:= TFont():New("Verdana",,11,,.T.,,,,,.F. )
Private oFont3	:= TFont():New("Verdana",,12,,.T.,,,,,.F. )
Private oFont4	:= TFont():New("Verdana",,24,,.T.,,,,,.F. )
Private oPrn	:= TMSPrinter():New("Argox")

dbSelectArea("SF2")
dbSetOrder(10)
If MsSeek(xFilial("SF2") + MV_PAR03 + MV_PAR01,.F.,.F.)
//	dbSelectArea("SF2")
//	dbSetOrder(1)
	oPrn:StartPage()
	oPrn:Setup() // aparece para selecionar a impressora para a impressao
	
	While !SF2->(EOF()) .AND.  SF2->F2_FILIAL == xFilial("SF2") .AND. SF2->F2_DOC <= MV_PAR02 .AND. SF2->F2_SERIE == MV_PAR03
		
		_nVolume:= SF2->F2_VOLUME1
		
		For x:=1 to _nVolume
			
			_cVolume:= Alltrim(STR(x))+"/"+Alltrim(STR(_nVolume))
			_cDOC   := SF2->F2_DOC
			_cSERIE := SF2->F2_SERIE
			_cCli   := Posicione("SA1",1,xFilial("SA1") + SF2->F2_CLIENTE+SF2->F2_LOJA,"SA1->A1_NOME") //cliente
			_cEnd   := Posicione("SA1",1,xFilial("SA1") + SF2->F2_CLIENTE+SF2->F2_LOJA,"SA1->A1_END") //endereco				
			_cBai   := Posicione("SA1",1,xFilial("SA1") + SF2->F2_CLIENTE+SF2->F2_LOJA,"SA1->A1_BAIRRO")//bairro
			_cUf    := Posicione("SA1",1,xFilial("SA1") + SF2->F2_CLIENTE+SF2->F2_LOJA,"SA1->A1_EST") //uf
			_cCep   := Posicione("SA1",1,xFilial("SA1") + SF2->F2_CLIENTE+SF2->F2_LOJA,"SA1->A1_CEP") //cep			
			_cMun   := Posicione("SA1",1,xFilial("SA1") + SF2->F2_CLIENTE+SF2->F2_LOJA,"SA1->A1_MUN") //municipio
			_cTrans := Posicione("SA4",1,xFilial("SA4") + SF2->F2_TRANSP,"SA4->A4_NOME") //transportadora
			
			//say  Linha,Coluna,Largura,Altura

			oPrn:Say(010 ,010, "NF: " 	  + (cValToChar(_cDOC)) + "  " + Alltrim (_cSERIE)		     	            ,oFont4,100,,,3)
		 	oPrn:Say(110 ,010,   _cCli 			                         				    		                  ,oFont3,100,,,3)
		 	oPrn:Say(160 ,010,   _cEnd				                        				    					         ,oFont1,100,,,3)
		 	oPrn:Say(190 ,010,   _cBai				                        				    					         ,oFont1,100,,,3)
			oPrn:Say(220 ,010,   _cMun + " - " + Alltrim(_cUf)                            			            ,oFont1,100,,,3)
			oPrn:Say(260 ,010, "Cep: " 		  + (cValToChar(_cCep))  						                     	,oFont1,100,,,3)	
			oPrn:Say(330 ,280, "VOLUME(S):       " + Alltrim(cValToChar(x)+"/"+cValToChar(SF2->F2_VOLUME1))    ,oFont3,100,,,3)
			oPrn:Say(420 ,010, "BRASITECH IND E COM DE AP P/ BELEZA LTDA"                         ,oFont2,100,,,3)
			oPrn:Say(490 ,020, "Transp: "      + (cValToChar(_cTrans))  					   	     ,oFont1,100,,,3)

			
			//Box (Linha inicial, Coluna inicial, Linha Final, Coluna Final) *** todos obrigatorios
			oPrn:Box(001,001,410,1100)
			oPrn:Box(001,001,410,1100)
			oPrn:Box(001,001,410,1100)
			
//			oPrn:Box(001,001,140,1100)
//			oPrn:Box(001,001,315,1100)
//			oPrn:Box(001,001,450,1100)
		
			
			oPrn:EndPage()
			
			if _nvolume > x   //nao imprime pagina em branco, x porque no meu for eu atribui o x com valor 1, ้ tipo um contador de paginas para cada volume
			   //	oPrn:StartPage()
			Endif
		Next
		
		DbSelectArea("SF2")
		DbSkip()
	EndDo
	
		oPrn:EndPage()
		oPrn:Preview() //funcao que imprime primeiro na tela do usuario dps define a impressora
	//	oPrn:Print()    // manda direto para a impressao, nao precisa da tela de escolha de impressora, ele pega a padrao setada no windows 
		
		
	SET DEVICE TO SCREEN
	MS_FLUSH()
	
Else
	Alert("Atencao!!! Sem etiquetas a imprimir!",_cRotina+"_001")
	
EndIf


Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณValidPerg บAutor  ณFelipe Varellaณ Data ณ 30/06/15          บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณTratamento das perguntas na SX1.                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณProtheus11 - Brasitech                                      บฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/

Static Function ValidPerg()
Local i,j
_sAlias := GetArea()
dbSelectArea("SX1")
dbSetOrder(1)
cPerg   := PADR(cPerg,10)
aRegs   := {}

AADD(aRegs,{cPerg,"01","De Nota     ?","","","mv_ch1","C",09,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SF2","",""})
AADD(aRegs,{cPerg,"02","Ate Nota    ?","","","mv_ch2","C",09,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SF2","",""})
AADD(aRegs,{cPerg,"03","Serie       ?","","","mv_ch3","C",03,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i := 1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j := 1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Else
				exit
			Endif
		Next
		MsUnlock()
	Endif                                                                                                
	
Next

dbSelectArea(_sAlias)

Return