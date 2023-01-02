#Include "Rwmake.ch"

/*_______________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Função    ¦ MTOPCADD    ¦¦¦
¦¦+-----------+------------+-------+----------------------+------+------------+¦¦
¦¦¦ Descriçäo ¦ Ponto de Entrada de inclusão de campo adicional nos opcionais ¦¦¦
¦¦+-----------+---------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
User Function MTOPCADD()
	Local nX     := 0
	Local aItens := ParamIXB[1]
	Local aRet   := {}
	
	AAdd( aRet , { "Saldo Estoque", 0} )   // Adiciona o cabeçalho
	
	For nX:=1 To Len(aItens)
		AAdd( aRet , { aItens[nX], "" } )
		If nX > 1
			aRet[Len(aRet),2] := CalcEst(aItens[nX,9],"11",dDataBase+1)[1]
		Endif
	Next
	

	aEval(aItens , {|x| nX++, AAdd( aRet , { x, If(nX==1,"",CalcEst(x[9],"01",dDataBase+1)[1])} ) } )
	
	If FunName() == "MATA650"
		AAdd( aRet , { "Necessidade", 0} )   // Adiciona o cabeçalho
		
		For nX:=1 To Len(aItens)
			AAdd( aRet , { aItens[nX], "" } )
			If nX > 1
				SG1->(dbGoTo(aItens[nX,5]))   // Posiciona no registro do opcional
				aRet[Len(aRet),2] := SG1->G1_QUANT
			Endif
		Next
	Endif
	
Return aRet