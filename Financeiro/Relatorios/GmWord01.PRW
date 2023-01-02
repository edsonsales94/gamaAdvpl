#include 'protheus.ch'
#INCLUDE "RWMAKE.CH"
#include 'parmtype.ch'
#INCLUDE "MSOLE.CH"

user function GmWord01()

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// - Este exemplo demonstra como salvar arquivos do tipo doc e docx como PDF -
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

local hWinWord  := nil 
local cDocument :=  cGetFile( '*.DOT',"Modelos Word" )
    // esse exemplo é exclusivo para ambiente Windows
     if !(GetRemoteType() == 1) .and. !(isPlugin())
          return conOut("Windows only")
     endIf
     // verifica se o documento existe
     if !file(cDocument)                 
          alert("Document not found") 
     endif
    // cria objeto OLE para conversar com WinWord
    hWinWord	:= OLE_CreateLink() 
    OLE_NewFile( hWinWord ,  cDocument  )
  
     if !(val(hWinWord) == 0)
          alert("Nao foi capaz de acessar o word ole link")
     endIf 
     
     cExt:=Extenso(SE2->(E2_VALOR+E2_ACRESC-E2_DECRESC),.F.,1,1)
     cCnpj:=posicione("SA2",1,xfilial("SA2")+SE2->(E2_FORNECE+E2_LOJA),"A2_CGC")
     cValor:=transform(SE2->(E2_VALOR+E2_ACRESC-E2_DECRESC), "@E 999,999.99")
     
     wcData		:= AllTrim(Str(Day(dDataBase),2))+' de '+AllTrim(MesExtenso(dDataBase))+' de '+AllTrim(Str(Year(dDataBase),4))
     aCampos:={}
     aAdd( aCampos, {'FinDoc'    , SE2->E2_NUM  	  , "E2_NUM"			,""	} ) 
     aAdd( aCampos, {'FinValor'  , cValor             , "@E 999,999.99"		,""	} ) 
     aAdd( aCampos, {'FinCnpj'   , cCnpj              , "E2_CGC"			,""	} ) 
     aAdd( aCampos, {'FinFornece', SE2->E2_NOMFOR     , "E2_NOMFOR"			,""	} ) 
     aAdd( aCampos, {'FinHist'   , SE2->E2_HIST  	  , "E2_HIST"	    	,""	} ) 
     aAdd( aCampos, {'FinExtenso', cExt         	  , "@!"	    	    ,""	} ) 
     aAdd( aCampos, {'FinData'   , wcData	       	  , ""	    	    ,""	} )    
     
     
     Aeval(	aCampos,{ |x| OLE_SetDocumentVar(hWinWord, x[1],x[2])	} )
     OLE_UpDateFields( hWinWord )    																 							 	 
	 
	 
    
     //
     
     If MsgYesNo("Imprime o Documento ?")
       OLE_SetProperty( hWinWord, '208', .F. ) ; OLE_PrintFile( hWinWord ) 
	   
     EndIf
       
    If MsgYesNo("Fecha o Word e Corta o Link ?")
	    OLE_CloseLink( hWinWord )
    Endif	
     
return	
	
	
return