# include "protheus.ch"


User Function LcCcusto ()


Local cConta := ""


If SE5->E5_MOTBX$'DCM'
	cConta :="1111"

ElseIf SE5->E5_MOTBX$'DLG'
	cConta :="1051"
	
ElseIf SE5->E5_MOTBX $ 'DFN'
	cConta :="1072"
	
ElseIf SE5->E5_MOTBX $ 'DCT'
	cConta :="1091"
	
ElseIf SE5->E5_MOTBX $ 'DRH'
	cConta :="1041"
	
ElseIf SE5->E5_MOTBX $ 'DMK'
	cConta :="1121"
	
ElseIf SE5->E5_MOTBX $ 'DRP'
	cConta :="1072"

ElseIf SE5->E5_MOTBX $ 'VPC'
	cConta :=SA3->A3_XCCVEND
	
EndIf

Return (cConta)

