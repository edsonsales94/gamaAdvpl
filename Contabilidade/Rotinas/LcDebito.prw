# include "protheus.ch"


User Function LcCdebito ()


Local cConta := ""

If SE5->E5_MOTBX = 'DRP'
	cConta :='4210401006'

ElseIf SE5->E5_MOTBX$'DFN' .AND. SE5->E5_TIPO = 'NCC'
	cConta :='2150102003'

ElseIf SE5->E5_MOTBX = 'DFN' .AND. SE5->E5_TIPO = 'RA'
	cConta :='2150101001'
	
ElseIf SE5->E5_MOTBX $ 'DAC/DCT/DFN/DLG'
	cConta :='4210401006'
	
ElseIf SE5->E5_MOTBX $ 'VPC/DCM'
	cConta :='4210102005'
Else
	cConta := SA6->A6_CONTA
	
EndIf

Return (cConta)