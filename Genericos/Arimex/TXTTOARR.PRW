#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Programa: TXTTOARR      ||Data: 18/09/2011 ||Empresa: ARIMEX        //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Autor: Marcus Pacheco   ||Empresa: MRW SOLUTIONS                    //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Módulo: Facturacion     || Origen: FSW - TOTVS                      //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
//Descrição: Generador de pedidos de ventas x archivo CSV.            //
//%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%//
User Function TXTTOARR(cLinha, cSepara)
Local aArray   := {}
Local cLinha_  := ""
Default cLinha := ""
Default cSepara:= ""

nPosAt := At(AllTrim(cSepara), cLinha)
If nPosAt == 0
	MsgStop("Separador no encontrado!")
	Return Nil
EndIf

While Len(cLinha)>0
	nPosAt := At(AllTrim(cSepara), cLinha)
	cLinha_ := SubStr(cLinha, 1, nPosAt-1)
	cLinha  := SubStr(cLinha, nPosAt+1)
	If nPosAt == 0
		Aadd(aArray, cLinha)
		cLinha := ""
	Else
		Aadd(aArray, cLinha_)	
	EndIf
End
Return aArray