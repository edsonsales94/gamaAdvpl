#include "rwmake.ch"       
#INCLUDE "PROTHEUS.CH"    
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "XMLXFUN.CH"
#Define CRLF CHR(13)+CHR(10)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � Alelo    � Autor � Jorge Sato            � Data � 23/03/17 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Geracao do Arquivo Alelo para Vale Alimentacao e Refeicao  ���
���Descri��o � para Empresa FortServ                                      ���
�������������������������������������������������������������������������Ĵ��
���          �         �                                                  ���
���          �         �                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

User Function Alelo()

	//Local oDlg
	Local oRadio
	Local nRadio
	Local nOpca := 1

	// Declaracao de variaveis private
	SetPrvt("lEnd,lContinua,lAbortPrint,lImpLis,nHdl,nLin0,cPerg,cFilDe,cFilAte,cCcDe,cCcAte,cMatDe,cMatAte,nQtdFun,cCivi")
	SetPrvt("cGvt,cGva,cCodCon,cNomeCon,cNomeArq,cShowFil,cShowMat,cFil,cPerRef,cTipo,cEmp,cDtEntr,cDtEmis,cValRef,cMat,cArq")
	SetPrvt("cDatN,cDatA,cNomeF,cPis,cCic,cLin,dPerRef,dDtEnt,nDtrab,nDafas,nDfal,nValBen,nValBenT,nValRef,nSeq,lImpLis,lFlag,aReg,aInfoE")
	SetPrvt("aCamp,cString,aOrd,aReturn,nTamanho,Titulo,cDesc1,cDesc2,cDesc3,cCancel,wCabec1,wCabec2,NomeProg,cArqInd,cInd,nLastKey,m_pag,li")
	SetPrvt("ContFl,nOrdem,nTfunc,nTccFunc,nTBen,nTccBen,nTgfunc,nTgBen,wnrel,cGvr,cNumPed,cCcAnt,cCcDesc,nPerDes,cValAnt,cCCAnt,oDlg")

	//���������������������������������������������������������������������Ŀ
	//� Declaracao de Variaveis                                             �
	//�����������������������������������������������������������������������
	cNomeArq    := '' 
	cArq        := ''
	lEnd        := .F.
	lContinua   := .T.
	lAbortPrint := .F.
	lImpLis     := .F.
	nHdl        := 0 
	nLin0       := 0
	cPerg 		:= 'ALELOVAVR '

	//����������������������������������������������������������������������Ŀ
	//� Verifica as perguntas                                                �
	//�����������������������������������������������������������������������Ĵ
	//� mv_par01    Da Filial          -  Filial Inicial                     �
	//� mv_par02    Ate a Filial       -  Filial final                       �
	//� mv_par03    Do Centro de Custo -  Do Centro de Custo                 �
	//� mv_par04    Ate Centro de Custo-  Ate Centro de Custo                �
	//� mv_par05    Da Matricula       -  Matricula inicial                  �
	//� mv_par06    Ate a Matricula    -  Matricula final                    �
	//� mv_par07    Alimenta./Refeicao -  Alimentacao/Refeicao               �
	//� mv_par08    Periodo de Refer.  -  Data para Referencia               �
	//� mv_par09    Data de Efetivacao -  Data para Efetivacao               �
	//� mv_par10    Pedido Normal/Comp -  Pedido Normal/Complementar         �
	//� mv_par11    Nome do Contato    -  Nome do Contato na Empresa         �
	//� mv_par12    Codigo Contrato    -  Codigo Contrato                    �
	//� mv_par13    Numero do Pedido   -  Numero do Pedido                   �
	//� mv_par14    Centraliza Entrega -  Centraliza Entrega                 �
	//� mv_par15    Nome do Arquivo    -                                     �
	//� mv_par16    Imprime Listagem   -  Sim/Nao                            �
	//������������������������������������������������������������������������  

	//Valida indices espec�ficos.
	//criar indices RG2_FILIAL+RG2_MAT+RG2_ANOMES+RG2_TPVALE+RG2_TPBEN+RG2_CODIGO                                                                                                   
	If !u_fsVlSixRG2()
		Return
	EndIf

	VerPerg()

	//Pergunte(cPerg,.T.)	

	//���������������������������������������������������������������������Ŀ
	//� Montagem da tela para selecionar qual beneficio quer gerar          �
	//�����������������������������������������������������������������������  

	While nOpca == 1 

		DEFINE MSDIALOG oDlg FROM  94,1 TO 273,293 TITLE OemToAnsi("Gera��o de Arquivo Texto Alelo") PIXEL 

		@ 10,17 Say OemToAnsi("Qual benef�cio voc� deseja gerar ?") SIZE 150,7 OF oDlg PIXEL

		@ 27,07 TO 72, 140 OF oDlg  PIXEL

		@ 35,10 Radio 	oRadio VAR nRadio;
		ITEMS "Vale Alimentacao",;	
		"Vale Refeicao";
		3D SIZE 100,10 OF oDlg PIXEL

		DEFINE SBUTTON FROM 75,085 TYPE 1 ENABLE OF oDlg ACTION (nOpca := 1, oDlg:End())
		DEFINE SBUTTON FROM 75,115 TYPE 2 ENABLE OF oDlg ACTION (nOpca := 0, oDlg:End())

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT (nOpca := 0, .T.)	// Zero nOpca caso 
		//	para saida com ESC

		If nOpca == 1
			If nRadio == 1
				cGvt := "1"    // vA
				Continua()
			ElseIf nRadio == 2
				cGvt := "2"   // vR
				Continua()
			EndIf
		EndIf

		//grava o registro 
		If nHdl > 0 .and. nOpca # 0
			If fClose(nHdl)
				If /*nLin0 > 0 .And.*/ lContinua
					Aviso('AVISO','Gerado o arquivo ' + AllTrim(cNomeArq) + '...',{'OK'})
					nOpca := 2
					//Imprime Listagem
					If lImpLis
						fImpLis()
					End

				Else
					If fErase(ALLTRIM(cNomeArq)) == 0
						If lContinua
							Aviso('AVISO','Nao existem registros a serem gravados. A geraco do arquivo ' + AllTrim(cNomeArq) + ' foi abortada ...',{'OK'})
						EndIf	
					Else

						MsgAlert('Ocorreram problemas na tentativa de deletar o arquivo '+AllTrim(cNomeArq)+'.')

					EndIf	
				EndIf	
			Else

				MsgAlert('Ocorreram problemas no fechamento do arquivo '+AllTrim(cNomeArq)+'.')

			EndIf
		EndIf  

		//Deleta Arquivo Temporario 
		/*	If lImplis
		If File(cArq + '.DBF')     
		dbSelectArea('TMP')
		dbCloseArea()
		fErase(cArq + '.DBF')
		FErase (cArqInd+OrdBagExt())
		Endif	
		Endif
		*/		
	EndDo



Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao    � Continua     �  Autor � Jorge Sato       � Data � 23/03/17 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Fun��o para continua��o do processamento (na confirma��o)  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � 		                                                      ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function Continua()

	//���������������������������������������������������������������������Ŀ
	//� Inicializa variaveis utilizadas pelo programa                       �
	//�����������������������������������������������������������������������
	cFilDe		:= ''
	cFilAte		:= ''
	cCcDe		:= ''
	cCcAte		:= ''
	cMatDe		:= ''
	cMatAte		:= ''
	//cGvt		:= ''
	cGva		:= ''
	cGvr		:= ''
	cCodCon		:= ''
	cNomeCon	:= ''
	cNomeArq	:= ''
	cShowFil	:= ''
	cShowMat	:= ''
	cFil		:= ''
	cPerRef		:= ''
	cPerPes		:= ''
	cTipo		:= ''
	cEmp		:= ''
	cDtEntr		:= ''
	cDtEmis		:= ''
	cValRef		:= ''
	cMat		:= ''
	cDatN		:= ''
	cDatA		:= ''
	cNomeF		:= ''
	cPis		:= ''
	cCic		:= ''
	cLin		:= ''
	cArq		:= ''
	cNumPed		:= ''
	cGera		:= ''
	cDiasMes	:= ''
	cValAnt		:= ''
	cCivi		:= ''
	cCCAnt		:= ''
	dPerRef		:= cTod("  /  /  ")
	dDtEnt		:= cTod("  /  /  ")
	nDtrab		:= 0
	nDafas		:= 0
	nDfal		:= 0
	nValBen		:= 0
	nValBenT	:= 0
	nValRef		:= 0
	nSeq		:= 0
	nQtdFun		:= 0    
	nPerDes		:= 0
	nEntre		:= 0
	lImpLis		:= .F.
	lFlag		:= .F.
	aReg		:= {}
	aInfoE		:= {}
	aCamp		:= {}
	cPerg 		:= 'ALELOVAVR '

	IF !Pergunte(cPerg, .T. )
		Return
	EndIf 

	//���������������������������������������������������������������������Ŀ
	//� Inicializa variaveis utilizadas como Pergunte                       �
	//�����������������������������������������������������������������������
	cFilDe   := mv_par01 								// Da Filial
	cFilAte  := mv_par02 								// Ate a Filial
	cCcDe    := mv_par03 								// Do Centro de Custo
	cCcAte   := mv_par04 								// Ate Centro de Custo
	cMatDe   := mv_par05 						   		// Da Matricula
	cMatAte  := mv_par06 								// Ate a Matricula
	//cGvt     := If(mv_par07==1,"1","2") 				// Vale Alimentacao/Vale Refeicao
	dPerRef  := If(Empty(mv_par07),dDataBase,mv_par07)	// Periodo de Referencia
	dDtEnt   := If(Empty(mv_par08),dDataBase,mv_par08) 	// Data da Efetivacao
	cGva     := If(mv_par09==1,"1","2") 				// Pedido Normal/Complementar
	cNomeCon := mv_par10 								// Nome do Contato na Empresa
	cCodCon	 := mv_par11 								// Codigo Contrato
	cNumPed	 := mv_par12 								// Numero do Pedido
	cGvr	 := If(mv_par13==1,"1","2")					// Centraliza Entrega
	cNomeArq := mv_par14 								// Nome do Arquivo
	//lImpLis  := If(mv_par16==1,.T.,.F.) 				// Imprime Listagem


	While .T.
		If File(cNomeArq)
			If (nAviso := Aviso('AVISO','Deseja substituir o ' + AllTrim(cNomeArq) + ' existente ?', {'Sim','Nao','Cancela'})) == 1
				If fErase(cNomeArq) == 0
					Exit
				Else
					MsgAlert('Ocorreram problemas na tentativa de deletar o arquivo '+AllTrim(cNomeArq)+'.')
				EndIf		
			ElseIf nAviso == 2
				Pergunte(cPerg,.T.)							
				Loop
			Else
				Return
			EndIf		
		Else
			Exit
		EndIf	
	EndDo

	//���������������������������������������������������������������������Ŀ
	//� Cria o arquivo texto                                                �
	//�����������������������������������������������������������������������	     

	nHdl := fCreate(cNomeArq)

	If nHdl == -1
		MsgAlert('O arquivo '+AllTrim(cNomeArq)+' nao pode ser criado! Verifique os parametros.','Atencao!')
		Return
	Endif

	//Carrega Dados da Filial
	fLocalInfo()

	//��������������������������������������������������������������Ŀ
	//� Cria Arquivo Temporario de Impressao                         �
	//����������������������������������������������������������������
	If lImpLis
		//Criacao do Array               
		aadd(aCamp,{'TP','C',1,0})
		aadd(aCamp,{'FIL','C',2,0})
		aadd(aCamp,{'CC','C',9,0})
		aadd(aCamp,{'MAT','C',6,0})
		aadd(aCamp,{'CAMPO','C',55,0})

		//Nome e Criacao do Arquivo
		cArq := Criatrab(aCamp,.t.)

		//Abertura do Arquivo
		dbUseArea(.t.,,cArq,'TMP')
		dbSelectArea('TMP')

	Endif	

	// Inicializa processamento
	Processa({|lEnd| RunCont()}, 'Processando...')
	//Close(oDlg)
Return  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �   RunCont    �  Autor � Jorge Sato       � Data � 23/03/17 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Processamento                                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RDMAKE                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � 		                                                      ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function RunCont()

	//Posiciona Indices
	dbSelectArea('SR0')
	SR0->(dbSetOrder(3))    

	dbSelectArea('SRA')
	SRA->(dbSetOrder(1))
	//dbSeek(alltrim(cFilDe) + cMatDe  + cCcDe , .T.)
	ProcRegua(SRA->(RecCount())) 

	cShowFil := Space(Len(SRA->RA_FILIAL))
	cShowMat := Space(Len(SRA->RA_MAT))
	cFil     := SRA->RA_FILIAL 


	//Periodo de Referencia
	cPerRef  := AllTrim(StrZero(Month(dPerRef),2)) + AllTrim(Str(Year(dPerRef)))
	cShAnomes:= AllTrim(Str(Year(dPerRef))) + AllTrim(StrZero(Month(dPerRef),2))
	SRA->(dbgotop())
	// Processamento
	While !SRA->(Eof()).And. lContinua

		If SRA->RA_SITFOLH <> 'D' .AND. SRA->RA_SITFOLH <> 'A' .AND. SRA->RA_FILIAL = alltrim(cFilDe)
			If SRA->RA_FILIAL + SRA->RA_MAT + SRA->RA_CC  <= alltrim(cFilAte) + cMatAte + cCcAte
				cShowFil  := SRA->RA_FILIAL
				cShowMat  := SRA->RA_MAT                    
				nDtrab    := 30
				nDfal	  := 0
				lFlag	  := .F.

				//���������������������������������������������������������������������Ŀ
				//� Incrementa a regua                                                  �
				//�����������������������������������������������������������������������
				//IncProc('Gerando o Arquivo... Fil. / Mat.: ' + cShowFil + ' / ' + cShowMat)
				If lAbortPrint .Or. lEnd
					If Aviso('ATENCAO','Deseja abandonar a Geracao do arquivo ' + AllTrim(AllTrim(cNomeArq)) + ' ?',{'Sim','Nao'}) == 1
						lContinua := .F.
						Exit
					EndIf	
				Endif

				//Filtra Demitidos
/*				If SRA->RA_SITFOLH =='D'
					SRA->(dbSkip())
					Loop		
				EndIf   
*/
				//Gera Registro Tipo 1
				//	If cFil != SRA->RA_FILIAL .And. SRA->(!Eof())
				//			cFilAnt := SRA->RA_FILIAL

				//Carrega Dados da Filial
				//			fLocalInfo()     

				//			fGeraTipo1()

				//Gera Registro Tipo 2
				//If cGvr == '2' //Centraliza Entrega
				//	cCCAnt := SRA->RA_CC
				//	fGeraTipo2()
				//Endif			

				//	Endif


				// Verifica Filtro Conforme Parametros
				If alltrim(SRA->RA_FILIAL) < alltrim(cFilDe) .Or. alltrim(SRA->RA_FILIAL) > alltrim(cFilAte) .Or. ;
				alltrim(SRA->RA_CC) < alltrim(cCcDe) .Or. alltrim(SRA->RA_CC) > alltrim(cCcAte) .Or. ;
				alltrim(SRA->RA_MAT) < alltrim(cMatDe) .Or. alltrim(SRA->RA_MAT) > alltrim(cMatAte)
					SRA->(dbSkip())	
					Loop
				EndIf	

				// Verifica Dias de Afastamento
				//fDiasAfast(@nDafas,@nDtrab,dPerRef)

				//���������������������������������������������������������������������Ŀ
				//� Vale Alimentacao(1) / Vale Refeicao (2)								�
				//�����������������������������������������������������������������������

				//���������������������������������������������������������������������Ŀ
				//� Informa��es de Vale Transporte (SR0 e SRN)                          �
				//�����������������������������������������������������������������������
				cFilSR0 := If(Empty(xFilial('SR0')),xFilial('SR0'),SRA->RA_FILIAL)
				cFilSRN := If(Empty(xFilial('SRN')),xFilial('SRN'),SRA->RA_FILIAL)
				//	cFilRG2 := If(Empty(xFilial('RG2')),xFilial('RG2'),SRA->RA_FILIAL)

				//Posiciona Indices R0_FILIAL+R0_MAT+R0_TPVALE+R0_CODIGO                                                                 
				dbSelectArea('SR0')
				dbSetOrder(3)    

				If cGvt == "2"
					If SR0->(dbSeek(cFilSR0 + SRA->RA_MAT + "1" + "01",.F.))       
						lFlag := .T.
					ElseIf SR0->(dbSeek(cFilSR0 + SRA->RA_MAT + "1" + "03",.F.))       
						lFlag := .T.		
					ElseIf SR0->(dbSeek(cFilSR0 + SRA->RA_MAT + "1" + "10",.F.))       
						lFlag := .T.											
					Endif	
				ElseIf cGvt == "1"
					If SR0->(dbSeek(cFilSR0 + SRA->RA_MAT + "2" + "52",.F.))
						lFlag := .T.
					ElseIf SR0->(dbSeek(cFilSR0 + SRA->RA_MAT + "2" + "51",.F.)) 
						lFlag := .T.
					ElseIf SR0->(dbSeek(cFilSR0 + SRA->RA_MAT + "2" + "60",.F.)) 
						lFlag := .T.	
					Endif	
				Endif

				//Busca o VA ou VR pela variavel cGvt
				If lFlag == .T.

					//incializa linha
					If nLin0 == 0
						nLin0 += 1
					Endif

					//Gera Registro linha 1
					If nSeq == 0
						nSeq += 1
						fGeraTipo0()
					Endif	

					If cGvr == '2' //Centraliza Entrega
						If cCCAnt != SRA->RA_CC
							cCCAnt := SRA->RA_CC
							fGeraTipo2()
						Endif
					Endif	 

					nDtrab	:= SR0->R0_QDIACAL
					nValBen	:= SR0->R0_VALCAL

					fGeraTipo5()

					//Totaliza Funcionario e Beneficio
					nQtdFun  += 1
					nValBenT += nValBen

					//Zera Variaveis
					nDtrab := 0
					nDfal  := 0

				Endif	


				SRA->(dbSkip())

				//Gera Registro Tipo 1
				/*	If cFil != SRA->RA_FILIAL .And. SRA->(!Eof())
				cFil := SRA->RA_FILIAL
				fGeraTipo1()

				//Gera Registro Tipo 2
				If cGvr == '2' .And. SRA->(!Eof()) //Centraliza Entrega
				cCCAnt := SRA->RA_CC
				fGeraTipo2()
				Endif			

				Endif
				*/
			Else
				SRA->(dbSkip())
			EndIF
		Else
			SRA->(dbSkip())
		EndIF
	EndDo          

	fGeraTipo9()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �   fGeraTipo0 �  Autor � Jorge Sato       � Data � 23/03/17 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera linha com Registro Tipo "0"                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RDMAKE                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GeraKit                                                    ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function fGeraTipo0()

	cTipo         := '0'
	cEmp          := Substr(aInfoE[2] + Space(40),1,35)
	cDtEntr       := AllTrim(StrZero(Day(dDtEnt),2)) + AllTrim(StrZero(Month(dDtEnt),2)) + AllTrim(Str(Year(dDtEnt)))
	cDtEmis       := AllTrim(StrZero(Day(dDataBase),2)) + AllTrim(StrZero(Month(dDataBase),2)) + AllTrim(Str(Year(dDataBase)))
	cNumPed		  := AllTrim(StrZero(Val(cNumPed),6))

	cLin := cTipo + cDtEmis + "A001"  + cEmp + aInfoE[9] + Replic("0",11) + cCodCon + cNumPed + cDtEntr + cGvt
	cLin += cGva + cPerRef + Space(18) + "007" + Space(267) + StrZero(nSeq,6) +  CRLF 

	nSeq += 1

	fGravaReg()

	If lImpLis
		If RecLock("TMP",.T.)
			TMP->TP		:= cTipo
			TMP->CAMPO := cEmp + cDtEntr + cGvt + cGva 
		Endif	
	Endif	

	fGeraTipo1()

	//Gera Registro Tipo 2
	If cGvr == '2' //Centraliza Entrega
		cCCAnt := SRA->RA_CC
		fGeraTipo2()
	Endif			

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �   fGeraTipo1 � Autor Totvs               � Data � 16/04/15 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera linha com Registro Tipo "1"                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RDMAKE                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GeraKit                                                    ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function fGeraTipo1()

	cTipo   := '1'           

	cLin    := cTipo +	aInfoE[09] + Replic("0",10) + Subst(aInfoE[10] + Space(35),1,35) + "0000" + Subst(cNomeCon + Space(35),1,35)
	cLin    += Space(40) + Replic("0",18) + Space(75) + Replic("0",18) + Space(75) + Replic("0",18) + Space(20) + Space(31)
	cLin 	+= StrZero(nSeq,6) + CRLF

	fGravaReg()

	If lImpLis
		If RecLock("TMP",.T.)
			TMP->TP 	:= cTipo
			TMP->FIL	:= cFil
			TMP->CAMPO := aInfoE[10]
		Endif	
	Endif	

	nSeq += 1

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �   fGeraTipo2 �  Autor � Jorge Sato       � Data � 23/03/17 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera linha com Registro Tipo "2"                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RDMAKE                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GeraKit                                                    ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function fGeraTipo2()

	cTipo   := '2'           
	cDesc	:= DescCC(cCcAnt)

	cLin    := cTipo +	Space(20) + Space(20) + Subst((cCcAnt + Space(20)),1,20)
	cLin    += Subst((cDesc + Space(20)),1,20) + Space(40) + Replic("0",4) + cNomeCon + Replic("0",12) + Replic("0",6)
	cLin 	+= Space(35) + Replic("0",12) + Replic("0",6) + Space(163) + StrZero(nSeq,6) + CRLF

	fGravaReg()

	nSeq += 1

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �   fGeraTipo5 �  Autor � Jorge Sato       � Data � 23/03/17 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera linha com Registro Tipo "5"                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RDMAKE                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � aLELO                                                      ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function fGeraTipo5()

	//Gera Registro tipo Zero
	If nSeq == 0
		nSeq += 1
		fGeraTipo0()
	Endif	 

	cTipo 	:= "5"
	cValRef := StrZero(nValBen * 100,11) 
	cMat 	:= Subst(SRA->RA_MAT + Space(13),1,13)
	cDatN	:= AllTrim(StrZero(Day(SRA->RA_NASC),2)) + AllTrim(StrZero(Month(SRA->RA_NASC),2)) + AllTrim(Str(Year(SRA->RA_NASC)))
	cDatA	:= AllTrim(StrZero(Day(SRA->RA_ADMISSA),2)) + AllTrim(StrZero(Month(SRA->RA_ADMISSA),2)) + AllTrim(Str(Year(SRA->RA_ADMISSA)))
	cNomeF	:= Subst(SRA->RA_NOME + Space(40),1,40)
	cCic	:= Iif(Empty(SRA->RA_CIC),Replic("0",11),SRA->RA_CIC)	
	cPis	:= Iif(Empty(SRA->RA_PIS),Replic("0",15),StrZero(Val(SRA->RA_PIS),15))

	//Gerar cart�o e senha em branco
	cGera := ' '


	//Codigo de Estado Civil
	If SRA->RA_ESTCIVI == "S"
		cCivi	:= "1"
	ElseIf SRA->RA_ESTCIVI == "C"
		cCivi	:= "2"
	ElseIf SRA->RA_ESTCIVI == "V"
		cCivi	:= "3"
	ElseIf SRA->RA_ESTCIVI $ "D*Q"
		cCivi	:= "4"
	Else
		cCivi	:= "5"
	Endif				

	cLin 	:= cTipo + cValRef + cGera + cMat + Space(54) + cDatN + cCic + Space(40) + cPis + SRA->RA_SEXO
	cLin	+= cCivi + Space(45) + Replic("0",13) + Space(96) + Replic("0",28) + " " + cDatA + " " + cNomeF 
	cLin	+= Space(6) + StrZero(nSeq,6) + CRLF

	fGravaReg()

	If lImpLis
		If RecLock("TMP",.T.)
			TMP->TP		:= 	cTipo 
			TMP->FIL	:= cFil
			TMP->CC		:=	SRA->RA_CC 
			TMP->MAT	:= SRA->RA_MAT
			TMP->CAMPO	:= cNomeF + cValRef + StrZero(nDtrab,2) + StrZero(nDfal,2)
		Endif	
	Endif	

	nSeq += 1

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �   fGeraTipo9 �  Autor � Jorge Sato       � Data � 23/03/17 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera linha com Registro Tipo "9"                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � RDMAKE                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � aLELO                                                      ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function fGeraTipo9()

	cTipo := "9" 

	cLin := cTipo + StrZero(nQtdFun,6) + StrZero(nValBenT * 100,15) + Space(372) + StrZero(nSeq,6)

	fGravaReg()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �   fGravaReg  �  Autor � Jorge Sato       � Data � 23/03/17 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava Registros no Arquivo Texto                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fGravaReg()                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GeraKit                                                    ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function fGravaReg()

	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If !MsgYesNo('Ocorreu um erro na gravacao do arquivo '+AllTrim(cNomeArq)+'.   Continua?','Atencao!')
			lContinua := .F.
			Return
		Endif
	Endif            

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �   fImpLis    �  Autor � Jorge Sato       � Data � 23/03/17 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime Listagem de Pedidos do Kit                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fImpLis()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GeraKit                                                    ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

USER Function fImpLis()

	cString  := 'SRA' // Alias do Arquivo Principal
	aOrd     := {"Matricula","Centro de Custo"}
	aReturn  := { 'Especial', 1,'Administra��o', 1, 2, 2,'',1 }
	nTamanho := 'P'
	Titulo   := 'LISTAGEM DE BENEFICIOS DA ALELO'
	cDesc1   := 'Emissao de Relatorio de Vale Refeicao e Vale Alimentaca. '
	cDesc2   := 'Sera impresso de acordo com os parametros solicitados '
	cDesc3   := 'pelo usuario.'
	cPerg    := ''
	cCancel  := '*** ABORTADO PELO OPERADOR ***'
	wCabec1	 := ' Matr.     Nome                         Valor Beneficio   Dias   Faltas '
	wCabec2  := '	                                                                  Benef.       '
	NomeProg := 'ALELO'
	cArqInd  := ''
	cInd	 := ''
	cCcAnt	 := ''
	cCcDesc	 := ''
	nLastKey := 0
	m_pag    := 0
	li       := 0
	ContFl   := 1 
	nOrdem	 := 0
	nTfunc   := 0 
	nTccFunc := 0
	nTBen    := 0
	nTccBen  := 0
	nTgfunc  := 0
	nTgBen   := 0
	lEnd     := .F.
	wnrel    := 'ALELO'


	//��������������������������������������������������������������Ŀ
	//� Envia controle para a funcao SETPRINT                        �
	//����������������������������������������������������������������

	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,nTamanho)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	// Inicio do Arquivo Temporario
	dbSelectArea('TMP')
	TMP->(dbGoTop())

	nOrdem   := aReturn[8]

	//Processa Selecao de Ordem
	Processa({|lEnd| ContOrd()},"Ordenando Arquivo...")

	//Processa Impressao
	RptStatus({|lEnd| Nota()},'Imprimindo...')

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �   ContOrd    �  Autor � Jorge Sato       � Data � 23/03/17 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime Listagem de Pedidos do Kit                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Nota()                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GeraCard                                                   ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function ContOrd()

	//Cria Indice Temporario
	//Nome do Indice
	cArqInd := CriaTrab(Nil,.F.)

	//Chave do Indice
	If nOrdem == 1
		cInd := "FIL + MAT"
	Else	
		cInd := "FIL + CC + MAT"
	Endif

	//Criacao do Indice
	IndRegua("TMP",cArqInd,cInd,,,"Selecionando Registros")	

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �   Nota       �  Autor � Jorge Sato       � Data � 23/03/17 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime Listagem de Pedidos do Kit                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Nota()                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GeraCard                                                   ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Static Function Nota()

	// Carrega Regua
	SetRegua(TMP->(RecCount())) 


	While !TMP->(Eof())

		//Abortado Pelo Operador
		If lAbortPrint
			lEnd := .T.
		Endif

		If lEnd
			cDet := cCancel
			Impr(cDet,'C')
			Exit
		EndIF			

		If TMP->TP == '0'

			//		cDet := Replic('*',80)
			//		Impr(cDet,'C')
			cDet := 'Empresa: ' + Subst(TMP->CAMPO,1,35)
			Impr(cDet,'C')
			cDet := 'Data Entrega: ' + Subst(TMP->CAMPO,36,2) + '/' + Subst(TMP->CAMPO,38,2) + '/' + Subst(TMP->CAMPO,40,4)
			cDet += '  -  Tipo Beneficio: ' + Iif(Subst(TMP->CAMPO,44,1) == '1', 'Alimentacao', 'Refeicao') 
			cDet += Iif(Subst(TMP->CAMPO,45,1) ==  '1',' - Pedido Normal',' - Pedido Complementar')
			Impr(cDet,'C')

			TMP->(dbSkip())

			IncRegua('Imprimindo.... ')

			Loop

		Endif

		If TMP->TP == '1'

			cDet := Replic('*',80)
			Impr(cDet,'C')
			cDet := 'Filial: ' + TMP->FIL + "-" + Subst(TMP->CAMPO,1,35)
			Impr(cDet,'C')

			cDet := ''
			Impr(cDet,'C')

			// Zerando Variaveis
			nTfunc    := 0
			nTBen     := 0

			TMP->(dbSkip())

			IncRegua('Imprimindo.... ')

			Loop

		Endif

		If (nOrdem == 2)

			cCcAnt  := TMP->CC
			cCcDesc := DescCC(cCcAnt)

			cDet := cCcAnt + ' - ' + cCcDesc
			Impr(cDet,'C')

		Endif	

		While TMP->TP == '5' .And. !TMP->(Eof()) .And. !lEnd

			If (nOrdem == 2) .And. (cCcAnt != TMP->CC)

				cCcAnt  := TMP->CC
				cCcDesc := DescCC(cCcAnt)

				cDet := cCcAnt + ' - ' + cCcDesc
				Impr(cDet,'C')

			Endif	

			//Abortado Pelo Operador
			If lAbortPrint
				lEnd := .T.
			Endif

			If lEnd
				cDet := cCancel
				Impr(cDet,'C')
				Exit
			EndIF			    	        

			cDet := TMP->MAT + "  "  +  Subst(TMP->CAMPO,1,40) + "  " + Transform(Val(Subst(TMP->CAMPO,41,11))/100,'@E 999,999,999.99')
			cDet += "    " + Subst(TMP->CAMPO,52,2) + "      " + Subst(TMP->CAMPO,54,2)
			Impr(cDet,'C')

			//Totaliza 							
			nTBen   += Val(Subst(TMP->CAMPO,41,11))/100
			nTfunc  += 1

			//Totaliza por Centro de Custo		
			nTccBen  += Val(Subst(TMP->CAMPO,41,11))/100		
			nTccfunc += 1

			TMP->(dbSkip())       

			If (nOrdem == 2) .And. (cCcAnt != TMP->CC)

				cDet := 'Totais do Centro de Custo - ' + cCcAnt + ' - '  + cCcDesc
				Impr(cDet,'C')

				cDet := 'Total Beneficio (R$): ' + Transform(nTccBen,'@E 999,999,999.99') 
				Impr(cDet,'C')

				cDet := 'Total Funcionario: ' + Transform(nTccfunc,'@E 99999') 
				Impr(cDet,'C')

				cDet := '' 
				Impr(cDet,'C')

				//Zera Variaveis
				nTccBen  := 0		
				nTccfunc := 0

			Endif	


			IncRegua('Imprimindo... ')

		Enddo

		cDet := ''
		Impr(cDet,'C')

		cDet := 'Totais da Filial ' 
		Impr(cDet,'C')

		cDet := 'Funcionarios ' + Transform(nTFunc,'@E 99999')
		Impr(cDet,'C')

		If nTBen > 0
			cDet:= 'Valor do Beneficio R$: ' + Transform(nTBen,'@E 999,999,999.99') 
			Impr(cDet,'C')
		Endif

		//Acumula Totais
		nTgfunc   += nTfunc
		nTgBen    += nTBen  

		//Zera Variaveis
		nTfunc    := 0
		nTBen     := 0

	Enddo						                                    

	//Imprime Total Geral da Empresa
	cDet := ''
	Impr(cDet,'C')

	cDet := Replic('*',80)
	Impr(cDet,'C')

	cDet := 'Totais da Empresa ' 
	Impr(cDet,'C')

	cDet := 'Funcionarios ' + Transform(nTgfunc,'@E 99999')
	Impr(cDet,'C')

	If nTgBen > 0
		cDet:= 'Valor do Beneficio R$: ' + Transform(nTgBen,'@E 999,999,999.99') 
		Impr(cDet,'C')
	Endif

	cDet := ''
	Impr(cDet,'F')

	If aReturn[5] == 1
		Set Printer TO
		ourspool(wnrel)
	Endif

	MS_FLUSH()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �   fLocalInfo �  Autor � Jorge Sato       � Data � 23/03/17 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inicializa o Array aInfo com informacoes do Local          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fCallFunc()                                                ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � GeraKit                                                    ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function fLocalInfo()

	aInfoE := {}

	// Armazena Registro Atual
	nSM0Recno := SM0->(Recno())

	SM0->(dbSeek(cEmpAnt + cFilAnt,.T.))

	Aadd(aInfoE,SM0->M0_NOME)
	Aadd(aInfoE,SM0->M0_NOMECOM)
	Aadd(aInfoE,SM0->M0_ENDENT)
	Aadd(aInfoE,SM0->M0_CIDENT)
	Aadd(aInfoE,SM0->M0_ESTENT)
	Aadd(aInfoE,SM0->M0_CEPENT)
	Aadd(aInfoE,SM0->M0_BAIRENT)
	Aadd(aInfoE,SM0->M0_COMPENT)
	Aadd(aInfoE,SM0->M0_CGC)
	Aadd(aInfoE,SM0->M0_FILIAL)

	// Retorna ao Registro
	SM0->(dbGoto(nSM0Recno))

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �   VerPerg    �  Autor � Jorge Sato       � Data � 23/03/17 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica  as perguntas, Incluindo-as caso n�o existam      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � VerPerg                                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � ALELO                                                      ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function VerPerg()
	LOCAL i	:= 0
	Local j := 0

	aRegs     := {}

	cPerg := Left(cPerg,10)

	//       X1_GRUPO,X1_ORDEM,X1_PERGUNT,X1_PERSPA,                  X1_PERENG,X1_VARIAVL,X1_TIPO,X1_TAMANHO,X1_DECIMAL,X1_PRESEL,X1_GSC,X1_VALID,X1_VAR01,X1_DEF01,X1_DEFSPA1,X1_DEFENG1,X1_CNT01,X1_VAR02,X1_DEF02,X1_DEFSPA2,X1_DEFENG2,X1_CNT02,X1_VAR03,X1_DEF03,X1_DEFSPA3,X1_DEFENG3,X1_CNT03,X1_VAR04,X1_DEF04,X1_DEFSPA4,X1_DEFENG4,X1_CNT04,X1_VAR05,X1_DEF05,X1_DEFSPA5,X1_DEFENG5,X1_CNT05,X1_F3,X1_PYME,X1_GRPSXG,X1_HELP  
	aAdd(aRegs,{cPerg,"01","Da Filial          ?","Da Filial          ?","Da Filial          ?","mv_ch1","C",4,0,0,"G","","mv_par01","","","","0101","","","","","","","","","","","","","","","","","","","","","SM0","","",""})
	aAdd(aRegs,{cPerg,"02","Ate a Filial       ?","Ate a Filial       ?","Ate a Filial       ?","mv_ch2","C",4,0,0,"G","","mv_par02","","","","0101","","","","","","","","","","","","","","","","","","","","","SM0","","",""})
	aAdd(aRegs,{cPerg,"03","Do Centro Custo    ?","Do Centro Custo    ?","Do Centro Custo    ?","mv_ch3","C",9,0,0,"G","","mv_par03","","","","000000111","","","","","","","","","","","","","","","","","","","","","CTT","","",""})
	aAdd(aRegs,{cPerg,"04","Ate Centro de Custo?","Ate Centro de Custo?","Ate Centro de Custo?","mv_ch4","C",9,0,0,"G","","mv_par04","","","","ZZZZZZZZZ","","","","","","","","","","","","","","","","","","","","","CTT","","",""})
	aAdd(aRegs,{cPerg,"05","Da Matricula       ?","Da Matricula       ?","Da Matricula       ?","mv_ch5","C",6,0,0,"G","","mv_par05","","","","000001","","","","","","","","","","","","","","","","","","","","","SRA","","",""})
	aAdd(aRegs,{cPerg,"06","Ate Matricula      ?","Ate Matricula      ?","Ate Matricula      ?","mv_ch6","C",6,0,0,"G","","mv_par06","","","","999999","","","","","","","","","","","","","","","","","","","","","SRA","","",""})
	//aAdd(aRegs,{cPerg,"07","Aliment./Refeicao  ?","Aliment./Refeicao  ?","Aliment./Refeicao  ?","mv_ch7","N",1,0,2,"C","","mv_par07","Alimentacao","Alimentacao","Alimentacao","","","Refeicao","Refeicao","Refeicao","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Data de Referencia ?","Data de Referencia ?","Data de Referencia ?","mv_ch7","D",8,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"08","Data Efetivacao    ?","Data Efetivacao    ?","Data Efetivacao    ?","mv_ch8","D",8,0,0,"G","naovazio","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"09","Normal/Complementar?","Normal/Complementar?","Normal/Complementar?","mv_ch9","N",1,0,0,"C","","mv_par09","Normal","Normal","Normal","","","Complementar","Complementar","Complementar","","","","","","","","","","","","","","","","","","","",""})  
	aAdd(aRegs,{cPerg,"10","Nome do Contato    ?","Nome do Contato    ?","Nome do Contato    ?","mv_cha","C",35,0,0,"G","naovazio","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"11","Codigo Contrato    ?","Codigo Contrato    ?","Codigo Contrato    ?","mv_chb","C",11,0,0,"G","naovazio","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"12","Numero Pedido      ?","Numero Pedido      ?","Numero Pedido      ?","mv_chc","C",6,0,0,"G","naovazio","mv_par12","","","","000000","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"13","Centraliza Entrega ?","Centraliza Entrega ?","Centraliza Entrega ?","mv_chd","N",1,0,2,"C","","mv_par13","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"14","Nome do Arquivo    ?","Nome do Arquivo    ?","Nome do Arquivo    ?","mv_che","C",40,0,0,"G","naovazio","mv_par14","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	//aAdd(aRegs,{cPerg,"15","Imprime Listagem   ?","Imprime Listagem   ?","Imprime Listagem   ?","mv_chg","N",1,0,2,"C","","mv_par16","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","","","","",""}) 

	//ValidPerg(aRegs,cPerg ,.F.)
	dbselectarea("sx1")
	sx1->( dbsetorder(1))

	if !sx1->(dbseek(cperg))
		for i := 1 to len(aregs)
			if	!sx1->(dbseek(cperg + aregs[i, 2]))
				reclock("sx1", .t.)
				for j := 1 to fcount()
					fieldput(j, aregs[i, j])
				next
				msunlock("sx1")
			endif
		next
	endif

	Return


	****************************************
User Function fsVlSixRG2()
	****************************************

	Local lRet := .T.
	Local aArea := GetArea()

	DbSelectArea("SIX")
	dbSetOrder(1)

	If !dbSeek("SR0"+"3")//R0_FILIAL+R0_MAT+R0_TPVALE+R0_CODIGO  
		lRet:= .F.
		Aviso( "Aten��o",  "� necess�rio a cria��o do indice na tabela SR0 - Itens de Benef�cios" +" "+ "Favor entrar em contato com o TI.", { "OK" } ) 	
	EndIf

	RestArea(aArea)

Return lRet                

