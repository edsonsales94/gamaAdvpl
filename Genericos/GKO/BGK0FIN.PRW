#Include "Protheus.ch"
#Include "Rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBGK015()       บฑฑ Jose Mendes
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Consulta Titulos Gko                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function BGK015()

Local 	aIndex 	:= {}
Local 	cFiltro := "E2_HIST ='Fatura GKO               ' .and. Empty(E2_BAIXA)"
Private cCadastro := "Consulta Titulos gerado Gko"
Private cAlias    := "SE2"



Private aRotina := {{ "&Pesquisar"	,"AxPesqui"		,0 ,1 } 	,;
					{ "&Visualizar" ,"AxVisual" 	,0 ,2 } 	,;
					{ "&Consulta"	,'',0 ,2 },;
                    { "Legenda"     ,'U_LEGGKO'  ,0,3}}
					
Private cDelFunc := ".T."  

Private bFiltraBrw := { || FilBrowse( cAlias , @aIndex , @cFiltro ) } 


Private aCores  := {} 


Aadd( aCores , { "!Empty(E2_BAIXA)" , "BR_VERDE"   	})  // Titulos Pagos
Aadd( aCores , { "Empty(E2_BAIXA)" , "BR_VERMELHO" 		})  // Titulos pendente

Eval( bFiltraBrw )   


DbSelectArea(cAlias)
DbSetOrder(1)
MBrowse( , , , , cAlias, , , , ,3, aCores )

EndFilBrw( cAlias , @aIndex ) //Finaliza o Filtro

Return

User Function LEGGKO()  

Local aLegenda := {}

Aadd( aLegenda , {"BR_VERDE"   , "Titulos Pagos"    })
Aadd( aLegenda , {"BR_VERMELHO" , "Titulos Pendentes"  })

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ                              Monta Legenda                                 ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/

BrwLegenda( cCadastro , OemToAnsi("Legendas") , aLegenda )

Return


