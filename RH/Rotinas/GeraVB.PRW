#include "topconn.ch"
#include "RWMAKE.ch"

#DEFINE  CRLF  Chr(13)+Chr(10)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ GeraVB ณ Autor ณ Equipe Totvs           ณ Data ณ 07/02/13 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Geracao Arquivo de Vale Transporte para VB Servicos        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณ BOPS ณ  Motivo da Alteracao                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑณ            ณ        ณ      ณ                                          ณฑฑ
ฑฑณ            ณ        ณ      ณ                                          ณฑฑ
ฑฑณ            ณ        ณ      ณ                                          ณฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
User Function GeraVB()

Local aSays:={}, aButtons:= {},aRegs := {} //<== arrays locais de preferencia

SetPrvt("cCadastro,cPerg,nOpca,cNome,cSexo,cData_Aniv,cEmail,cArquivo,cEmissao,cDDD,cTelefone")
SetPrvt("lContinua,cNomeArq,cLin,lEnd,nAviso,cCab1,cCab2,cCab3,nReg,nQtdEmp,nQtdEnd,nQtdFun,nQtdBnf,nQtdVtr")
SetPrvt("nX_,nPos,cMatDe,cMatAte,cTurDe,cTurAte,cSit,cCat")

//Iniciar Variaveis
cCadastro	:= OemToAnsi("Geracao Arquivo VB Servico") 
cPerg		:= "GERAVB"
cNome		:= ''
cSexo      	:= ''
cData_Aniv 	:= ''
cEmail     	:= ''
cArquivo   	:= ''
cEmissao   	:= ''
cDDD       	:= ''
cTelefone  	:= ''
cNomeArq	:= ''
cLin		:= ''
cCab1 		:= ''
cCab2 		:= ''
cCab3 		:= ''
cMatDe		:= ''
cMatAte		:= ''
cTurDe		:= ''
cTurAte		:= ''
cSit		:= ''
cCat		:= ''
nReg    	:= 1 
nIdEnd      := 0 
nQtdEmp 	:= 0
nQtdEnd 	:= 0
nQtdFun 	:= 0
nQtdBnf 	:= 0
nQtdVtr 	:= 0
nOpca	    := 0
nHdl		:= 0
nAviso		:= 0
nX_			:= 0
nPos		:= 0
lContinua	:= .T.
lEnd		:= .T.
aInfoE		:= {}
aSet		:= {}

fChkPerg()
Pergunte(cPerg,.F.)

AADD(aSays,OemToAnsi("Este programa gera arquivo VB Servico ") ) 

AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,Iif(GpconfOK(),FechaBatch(),nOpca:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons )

If nOpca == 1
	Processa({|lEnd| fVBProc(),"Gerando Arquivo"})  
Endif

If nHdl > 0
	If fClose(nHdl)
		If lContinua 
			Aviso('AVISO','Gerado o arquivo ' + AllTrim(cNomeArq) + '...',{'OK'})	
		Else
			If fErase(cNomeArq) == 0
				If lContinua
					Aviso('AVISO','No existem registros a serem gravados. A gerao do arquivo ' + AllTrim(cNomeArq) + ' foi abortada ...',{'OK'})
				EndIf	
			Else

				MsgAlert('Ocorreram problemas na tentativa de deleo do arquivo '+AllTrim(cNomeArq)+'.')

			EndIf	
		EndIf	
	Else

		MsgAlert('Ocorreram problemas no fechamento do arquivo '+AllTrim(cNomeArq)+'.')

	EndIf
	
EndIf 

//Fechamento das Tabelas Temporarias
If Select("R0NW") > 0
   DbSelectArea("R0NW")
   DbCloseArea("R0NW")
EndIf   
 
If Select("R0Z9") > 0
   DbSelectArea("R0Z9")
   DbCloseArea("R0Z9")
EndIf   

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ  fVBProc บ Autor ณEquipe Totvs บ Data ณ  28/03/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Processamento                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */
Static Function fVBProc()

//Variaveis das Perguntas
Pergunte(cPerg,.F.)

//Carrega as Variaveis das Perguntas
cFilDe			:= mv_par01	//Filial De
cFilAte			:= mv_par02	//Filial Ate
cCcDe			:= mv_par03	//Centro de Custo De
cCcAte			:= mv_par04	//Centro de Custo Ate
cMatDe			:= mv_par05 //Matricula De
cMatAte			:= mv_par06 //Matricula Ate
cTurDe			:= mv_par07 //Turno De
cTurAte			:= mv_par08 //Turno Ate
cSit			:= mv_par09 //Situacao a Gerar
cCat			:= mv_par10 //Categorias a Gerar
cConvenio		:= mv_par11	//Codigo de Cliente na VB
cNome			:= mv_par12	//Usuแrio do Sistema
cEmail			:= mv_par13	//Email Usuario do Sistema
cNomeArq		:= mv_par14	//Nome do Arquivo
cDddFone        := mv_par15	//DDD+Telefone do Contato Exemplo 11-9999-9999
cSxCont         := If(mv_par16==1,"M","F")	//Sexo do Contato
cNascCont       := dtos(mv_par17)//Dt Nasc do Contato
                                             
//Carrega Variaveis
cNascCont       := substr(cNascCont,7,2)+substr(cNascCont,5,2)+substr(cNascCont,3,2)
cEmissao		:= GravaData(dDataBase,.F.,1)
cTpoFrn 		:= "000001"
cDDD			:= Space(2)
cTelefone		:= Space(10)

      	
//Cria o arquivo texto
While .T.
	If File(cNomeArq)
		If (nAviso := Aviso('AVISO','Deseja substituir o ' + AllTrim(cNomeArq) + ' existente ?', {'Sim','No','Cancela'})) == 1
			If fErase(cNomeArq) == 0
				Exit
			Else
				MsgAlert('Ocorreram problemas na tentativa de deleo do arquivo '+AllTrim(cNomeArq)+'.')
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
nHdl := fCreate(cNomeArq)

If nHdl == -1
	MsgAlert('O arquivo '+AllTrim(cNomeArq)+' no p“de ser criado! Verifique os parmetros.','Ateno!')
	Return
Endif

SRA->(dbSetOrder(1))

//Monta Query de Filtro
cQuery := ""
cQuery += "Select RA_FILIAL,RA_MAT,RA_NOME,RA_NASC,RA_CEP,RA_ESTCIVI,RA_CIC,RA_RG,RA_SITFOLH,RA_CATFUNC,RA_SEXO,RA_PAI,RA_MAE,RA_ENDEREC,RA_COMPLEM,RA_MUNICIP,RA_ESTADO"
cQuery += ",RJ_DESC,R0_MEIO,R0_QDIACAL,RN_VUNIATU,RN_COD,RN_DESC,RN_ITEMVB,CTT_CUSTO,CTT_DESC01,CTT_ENDER,CTT_BAIRRO,CTT_MUNIC,CTT_CEP"


cQuery += " FROM " + RETSQLNAME("SRA")+ " , " +  RETSQLNAME("SRJ")+ " , " +  RETSQLNAME("SR0")+ " , " 
cQuery +=  RETSQLNAME("SRN")+ " , " +  RETSQLNAME("CTT") 

cQuery += " Where RA_CODFUNC = RJ_FUNCAO and RN_COD = R0_MEIO and R0_QDIACAL > 0"   
cQuery += " and RA_CC  = CTT_CUSTO "
cQuery += " and RA_FILIAL = R0_FILIAL and RA_MAT = R0_MAT"

cQuery += " and RA_FILIAL >= '"+cFilDe+"' and RA_FILIAL <= '"+cFilAte+"' "
cQuery += " and RA_CC >= '"+cCcDe+"' and RA_CC <= '"+cCcAte+"' "
cQuery += " and RA_MAT >= '"+cMatDe+"' and RA_MAT <= '"+cMatAte+"' "
cQuery += " and RA_TNOTRAB >= '"+cTurDe+"' and RA_TNOTRAB <= '"+cTurAte+"' "

cQuery += " and "+RETSQLNAME("SRA")+".D_E_L_E_T_ = ''"
cQuery += " and "+RETSQLNAME("SRJ")+".D_E_L_E_T_ = ''"
cQuery += " and "+RETSQLNAME("SR0")+".D_E_L_E_T_ = ''"
cQuery += " and "+RETSQLNAME("SRN")+".D_E_L_E_T_ = ''"
cQuery += " and "+RETSQLNAME("CTT")+".D_E_L_E_T_ = ''"


cQuery += " ORDER BY R0_FILIAL,R0_CC,R0_MAT,R0_MEIO"

cQuery := ChangeQuery(cQuery)

//Verifica se Tabela Aberta
If Select("R0NW") > 0
   DbSelectArea("R0NW")
   DbCloseArea("R0NW")
EndIf   

//Abre Tabela
dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), 'R0NW', .T., .F. )

R0NW->(DbGotop())

ProcRegua(SR0->(RecCount())) 
  
//Seleciona Setor

While R0NW->(!Eof())

	If aScan(aSet,{|x| x[1] == R0NW->CTT_CUSTO })== 0
		aAdd(aSet,{R0NW->CTT_CUSTO,R0NW->CTT_ENDER,R0NW->CTT_BAIRRO,R0NW->CTT_MUNIC,R0NW->CTT_CEP})
	Endif

    R0NW->(dbSkip())
    
    IncProc('Selecionando Registro... ')

Enddo    

R0NW->(DbGotop())

//Informa็๕es da Empresa
fEmpInfo()

cCgc 		:= aInfoE[9]
cEmpresa 	:= Left(aInfoE[2] + Space(60),60)
cEnderec	:= aInfoE[3]
cInscricao 	:= Left(aInfoE[10] + Space(20),20)
cInscMun   	:= Space(20)
cCep    	:= aInfoE[6]
nX			:= 1


While Subs(aInfoE[3],nX,1) <> "," .and. Subs(aInfoE[3],nX,1) <> "." // Identifica o numero do estabelecimento
	cNumEnd	:= Subs(aInfoE[3],nX+3,len(aInfoE[3])-nX)
	nX := nX + 1
dbSkip()
Enddo    

nX := 1
While Subs(aInfoE[3],nX,1) <> "," .and. Subs(aInfoE[3],nX,1) <> "."// Identifica o endere็o do estabelecimento
	cEnderec := Subs(aInfoE[3],1,nX)
    If right(cEnderec,3) == " Nr"
		cEnderec := Substr(cEnderec,1,len(cEnderec)-3)
    Endif
	nX := nX + 1
dbSkip()
Enddo    

cEnderec	:= Left(cEnderec + Space(60),60)
cNumEnd		:= Left(cNumEnd  + Space(10),10)

R0NW->(DbGotop())

//Gera Registro 0 (Zero)
fGera0()

//Gera Registro 1
fGera1()
                                      
//Gera Registro 2

While R0NW->(!Eof())

	fGera2()

	While R0NW->(!Eof()) 
	
	ProcRegua(SR0->(RecCount())) 
	
	
		If !(R0NW->RA_SITFOLH $ cSit) .Or. !(R0NW->RA_CATFUNC $ cCat)
	
			R0NW->(dbSkip())
			IncProc('Gerando arquivo para o Funcionแrio '+R0NW->RA_FILIAL+' - '+R0NW->RA_MAT+'...')
			Loop
			
		Endif           
	   	
	   	IF R0NW->RA_ESTCIVI = "C" 
	      	cEstCivi := "2"     
	      	
	    ELSEIF R0NW->RA_ESTCIVI = "M" 
	      	cEstCivi := "2" 	
	   	ELSEIF R0NW->RA_ESTCIVI = "D" 
	      	cEstCivi := "4"
	   	ELSEIF R0NW->RA_ESTCIVI = "Q" 
	      	cEstCivi := "3"
	   	ELSEIF R0NW->RA_ESTCIVI = "S" 
	      	cEstCivi := "1"              
	   	ELSEIF R0NW->RA_ESTCIVI = "V" 
	      	cEstCivi := "5"                      
	   	ENDIF
	 
	   	cFilial_Ant := R0NW->RA_FILIAL
	   	cMat_Ant    := R0NW->RA_MAT
	   	
	   	//Pesquisa Local de Entrega
		nPos := aScan(aSet,{|x| x[1] == R0NW->CTT_CUSTO})
	
		fGera3() 
			   
	   	While R0NW->(!Eof()) .AND. cFilial_Ant = R0NW->RA_FILIAL .AND. cMat_Ant = R0NW->RA_MAT
	       
	
	        fGera5()
			
	      	nQtdVtr ++
			         
			R0NW->(DbSkip())
			
			IncProc('Gerando o Arquivo... ')
	     
	   	EndDo
		
	EndDo   
EndDo	
fGera9()

//Fim da Rotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ  fGera0  บ Autor ณEquipe Totvs บ Data ณ  28/03/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Gera Registro Zero                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gera VB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */
Static Function fGera0()

cLin 	:= "0"					//001	001	IDENTIFICADOR	CONTEฺDO "0"
cLin 	+= "0100"				//002	005	CD_VERSAO	CONTEฺDO "0100"
cLin 	+= CEmissao				//006	011 DT_EMISSAO	EMISSAO ARQUIVO (DDMMYY)
//cLin 	+= cCgc					//012	025	CำDIGO "CNPJ" 
cLin 	+= cCgc					//012	025	CำDIGO "CNPJ" 
cLin    += cEmpresa 	        //026	085	RAZรO SOCIAL DA EMPRESA PRINCIPAL
cLin 	+= SPACE(509)			//086	594	BRANCOS
cLin 	+= StrZero(nReg,6)		//595	600	SEQUENCIAL

cLin 	+= CRLF 				//Fim da Linha

//Grava Registro
fGravaReg(cLin) 

//Atualiza Sequencia
nReg  	+= 1
nQtdEmp += 1

Return

//Fim da Rotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ  fGera1  บ Autor ณEquipe Totvs บ Data ณ  28/03/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Gera Registro Um                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gera VB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */
Static Function fGera1()

cSexo		:= ' '
cData_Aniv	:= Space(6)

cLin	:= "1"							//001	001	IDENTIFICADOR	CONTEฺDO "1"
cLin 	+= cConvenio					//002	010	IDENTIFICADOR DA EMPRESA NO VT ONLINE
cLin	+= cCgc							//011	024	CำDIGO "CNPJ"
cLin	+= cEmpresa						//025	084	RAZรO SOCIAL DA EMPRESA 
cLin 	+= Left(cEmpresa,40)			//085	124	NOME FANTASIA DA EMPRESA
cLin	+= cInscricao					//125	144	INSCRIวรO ESTADUAL
cLin 	+= cInscMun						//145	164	INSCRIวรO MUNICIPAL
cLin	+= "0040"						//165	168	CำDIGO DO RAMO DE ATIVIDADE
cLin	+= substr(cDddFone,1,2)    		//169	170	DDD DO TELEFONE -> Exemplo 11-9999-9999
cLin 	+= substr(cDddFone,4,9)+" "    	//171	180	NฺMERO DO TELEFONE -> Exemplo 11-9999-9999
cLin	+= SPACE(10)					//181	190	RAMAL DO TELEFONE
cLin	+= LEFT(cNome+SPACE(60),60)	    //191	250	NOME DO CONTATO RESPONSมVEL PELO PEDIDO
cLin	+= "0022"						//251	254	IDENTIFICAวรO DO DEPARTAMENTO DO CONTATO
cLin	+= "0005"						//255	258 IDENTIFICAวรO DO CARGO DO CONTATO
cLin	+= cSxCont   					//259	259	SEXO DO CONTATO
cLin	+= cNascCont 					//260	265	DATA DE ANIVERSมRIO DO CONTATO NO FORMATO "DDMMAA" = Exemplo "130468" 
cLin	+= LEFT(cEmail+SPACE(50),50)	//266	315	E-MAIL DO CONTATO
cLin	+= SPACE(279)					//316	594	BRANCOS
cLin 	+= StrZero(nReg,6)				//595	600	SEQUENCIAL DO REGISTRO

cLin 	+= CRLF 						//Fim da Linha
         
fGravaReg(cLin)

//Atualiza Sequencia
nReg    += 1      
nQtdEnd += 1                                

Return

//Fim da Rotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ  fGera2  บ Autor ณEquipe Totvs บ Data ณ  28/03/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Gera Registro Dois                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gera VB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */
Static Function fGera2()

nIdEnd  += 1 
nX_		+= 1

cLin	:= "2"									  				  			//001	001	IDENTIFICADOR	CONTEฺDO "2"
cLin	+= cCgc													  			//002	015	CำDIGO "CNPJ"
cLin	+= StrZero(nIdEnd,4)    							   				//016	019	IDENTIFICADOR DO ENDEREวO
//StrZero(nX_,4)												 			//016	019	IDENTIFICADOR DO ENDEREวO
cLin	+= "1"												   				//020	020	TIPO DE ENDEREวO
cLin	+= cCep												   				//021	028	CEP DO ENDEREวO
cLin	+= cEnderec							   				  				//029	088	LOGRADOURO DO ENDEREวO
cLin	+= cNumEnd					 										//089	098	NฺMERO DO ENDEREวO
cLin	+= Left( " - " + aSet[nX_,3] + " - " + aSet[nX_,4] + Space(40) ,40)	//099	138	COMPLEMENTO DO ENDEREวO
cLin 	+= LEFT(cNome+SPACE(60),60)		   									//139	198	RESPONSมVEL PELO RECEBIMENTO
cLin	+= SPACE(396)				   		 								//199	594	COMPLEMENTO	BRANCOS
cLin	+= StrZero(nReg,6)													//595	600	SEQUENCIAL DO REGISTRO

cLin 	+= CRLF 										//Fim da Linha

//Grava Registro        
fGravaReg(cLin)
                
//Atualiza Sequencia
nReg    += 1   



Return

//Fim da Rotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ  fGera3  บ Autor ณEquipe Totvs บ Data ณ  28/03/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Gera Registro Tres                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gera VB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */
Static Function fGera3()

Local cData := Subst(R0NW->RA_NASC,7,2) + Subst(R0NW->RA_NASC,5,2) + Subst(R0NW->RA_NASC,3,2) 
                                                                  
cLin	:= "3"                                      //001	001	IDENTIFICADOR	CONTEฺDO "3"
cLin 	+= cCgc										//002	015	CำDIGO "CNPJ"
cLin	+= StrZero(nIdEnd,4)    					//016	019	IDENTIFICADOR DO ENDEREวO P/ENTREGA DOS VALES
//StrZero(nPos,4)					  				//016	019	IDENTIFICADOR DO ENDEREวO P/ENTREGA DOS VALES
cLin	+= LEFT(R0NW->RA_MAT+SPACE(15),15)			//020	034	CำDIGO DA MATRอCULA DO FUNCIONมRIO
cLin	+= '001'									//035	037	QUANT. DIAS TRABALHADOS
cLin	+= LEFT(R0NW->RA_NOME+SPACE(40),40)		//038	077	NOME COMPLETO DO FUNCIONมRIO
cLin	+= LEFT(R0NW->CTT_DESC01+SPACE(40),40)		//078	117	NOME DO DEPARTAMENTO DO FUNCIONมRIO
cLin	+= LEFT(R0NW->RJ_DESC+SPACE(30),30)	   		//118	147	DESCRIวรO DO CARGO DO FUNCIONมRIO
cLin	+= cData									//148	153	DATA DE NASCIMENTO DO FUNCIONมRIO (DDMMAA)
cLin	+= STRZERO(VAL(R0NW->RA_CEP),8)					//154	161	CEP DO ENDEREวO DE RESIDสNCIA DO FUNCIONมRIO
cLin 	+= cEstCivi									//162	162	ESTADO CIVIL DO FUNCIONมRIO
cLin	+= LEFT(R0NW->RA_CIC+SPACE(14),14)			//163	176	CPF DO FUNCIONมRIO
cLin	+= SUBSTR(R0NW->RA_RG,1,14)				//177	190	RG DO FUNCIONมRIO
cLin	+= "00000000"								//191	198	DATA DE EMISSรO DO RG NO FORMATO "DDMMAAAA"
cLin	+= R0NW->RA_SEXO							//199	199	SEXO DO FUNCIONมRIO
cLin	+= LEFT(R0NW->RA_MAE+Space(40),40)			//200	239	NOME COMPLETO DA MAE
cLin	+= LEFT(R0NW->RA_PAI+Space(40),40)			//240	279	NOME COMPLETO DO PAI
cLin	+= "00000000"								//280	287	DATA DE ADMISSรO NO FORMATO "DDMMAAAA"
cLin	+= LEFT(R0NW->RA_ENDEREC+Space(60),60)		//288	347	LOGRADOURO DO ENDEREวO DE RESIDสNCIA DO FUNCIONมRIO
cLin	+= "0000000000"								//348	357	NฺMERO DO ENDEREวO DE RESIDสNCIA DO FUNCIONมRIO
cLin	+= LEFT(R0NW->RA_COMPLEM+Space(40),40)		//358	397	COMPLEMENTO DO ENDEREวO DE RESIDสNCIA DO FUNCIONมRIO
cLin	+= LEFT(R0NW->RA_MUNICIP+Space(60),60)		//398	457	CIDADE DO ENDEREวO DE RESIDสNCIA DO FUNCIONมRIO
cLin	+= R0NW->RA_ESTADO							//458	459	UF DO ENDEREวO DE RESIDสNCIA DO FUNCIONมRIO
cLin	+= Space(135)								//460	594	COMPLEMENTO	BRANCOS
cLin	+= StrZero(nReg,6) 							//595	600	SEQUENCIAL DO REGISTRO

cLin 	+= CRLF 									//Fim da Linha

//Grava Registro        
fGravaReg(cLin)

//Atualiza Sequencia
nReg    += 1
nQtdFun += 1

Return

//Fim da Rotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ  fGera5  บ Autor ณEquipe Totvs บ Data ณ  28/03/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Gera Registro Cinco                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gera VB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */
Static Function fGera5()

Local cRecar 

//cRecar	:= Iif(Subst(R0NW->RN_COD,1,1) == "S",Subst(R0NW->RA_RECARG_ + Space(20),1,20),Space(20))

cRecar  := Space(20)

cLin	:= "5"										//001	001 IDENTIFICADOR	CONTEฺDO "5"
cLin	+= cCgc										//002	015	CำDIGO "CNPJ"
cLin	+= LEFT(R0NW->RA_MAT+SPACE(15),15)			//016	030	CำDIGO DA MATRอCULA DO FUNCIONมRIO
cLin	+= LEFT(R0NW->RN_ITEMVB+SPACE(15),15)    	//031	045	CำDIGO DO อTEM
cLin	+= LEFT(R0NW->RN_DESC+SPACE(60),60)		//046	105	NOME DO อTEM
cLin	+= STRZERO(R0NW->R0_QDIACAL,14)			//106	119	QUANTIDADE DE ITENS
cLin	+= STRZERO(R0NW->RN_VUNIATU*100,14)		//120	133	VALOR DO ITEM
cLin	+= "000000"									//134	139	QUANTIDADE DE FOLHAS NO TALรO
cLin	+= SPACE(10)								//140	149	CำDIGO DO CARTรO
cLin	+= "N"										//150	150	TIPO DE FORNECIMENTO
cLin	+= STRZERO(01,6)  		//151	156	FORNECEDOR PARA ENVIO DAS INFORMAวีES
cLin	+= SPACE(20)				//157	176	REDE PARA RECARGA
cLin	+= SPACE(418)								//177	594	COMPLEMENTO	BRANCOS
cLin	+= StrZero(nReg,6)							//595	600	SEQUENCIAL DO REGISTRO

cLin 	+= CRLF 									//Fim da Linha
      
//Grava Registro
fGravaReg(cLin) 

//Atualiza Sequencia
nReg    += 1

Return

//Fim da Rotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ  fGera9  บ Autor ณEquipe Totvs บ Data ณ  28/03/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Gera Registro Nove                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gera VB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */
Static Function fGera9()
     
cLin	:= "9"					//001	001	IDENTIFICADOR	CONTEฺDO "9"
cLin	+= StrZero(nReg,6)		//002	007	QUANTIDADE DE REGISTROS NO ARQUIVO
cLin	+= StrZero(nQtdEmp,6)	//008	013	QUANTIDADE DE EMPRESAS NO ARQUIVO ( REGISTRO TIPO "1" )
cLin	+= StrZero(nQtdEnd,6)	//014	019	QUANTIDADE DE ENDEREวOS NO ARQUIVO ( REGISTRO TIPO "2" )
cLin	+= StrZero(nQtdFun,6)	//020	025	QUANTIDADE DE FUNCIONมRIOS NO ARQUIVO ( REGISTRO TIPO "3" )
cLin	+= StrZero(nQtdBnf,6)	//026	031	QUANTIDADE DE BENEFICIมRIOS NO ARQUIVO ( REGISTRO TIPO "4" )
cLin	+= StrZero(nQtdVtr,6)	//032	037	QUANTIDADE DE VALES-TRANSPORTE/REFEIวรO CONVสNIO ( REGISTRO TIPO "5" )
cLin	+= SPACE(557)			//038	594	COMPLEMENTO	BRANCOS
cLin	+= StrZero(nReg,6)		//595	600	SEQUENCIAL DO REGISTRO

cLin 	+= CRLF 				//Fim da Linha

//Grava Registro
fGravaReg(cLin) 

Return         

//Fim da Rotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ fEmpInfo   ณ Autor ณ Jos้ Carlos Gouveia ณ Data ณ 28/03/13 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Inicializa o Array aInfo com informacoes da Empresa        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ fEmpInfo()                                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ GeraVB                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fEmpInfo()
                                     
aInfoE := {}

// Armazena Registro Atual
nSM0Recno := SM0->(Recno())

SM0->(dbSeek(cEmpAnt+CFILATE,.T.))

Aadd(aInfoE,SM0->M0_NOME)
Aadd(aInfoE,SM0->M0_NOMECOM)
Aadd(aInfoE,SM0->M0_ENDCOB)
Aadd(aInfoE,SM0->M0_CIDCOB)
Aadd(aInfoE,SM0->M0_ESTCOB)
Aadd(aInfoE,SM0->M0_CEPCOB)
Aadd(aInfoE,SM0->M0_BAIRCOB)
Aadd(aInfoE,SM0->M0_COMPCOB)
Aadd(aInfoE,SM0->M0_CGC)
Aadd(aInfoE,SM0->M0_INSC)

// Retorna ao Registro
SM0->(dbGoto(nSM0Recno))

Return

// Fim da Rotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ fGravaReg    ณ Autor ณEquipe Totvsณ Data ณ 28/03/13 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Grava Registros no Arquivo Texto                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ fGravaReg()                                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fGravaReg(cLin)

If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
	If !MsgYesNo('Ocorreu um erro na gravao do arquivo '+AllTrim(cNomeArq)+'.   Continua?','Ateno!')
		lContinua := .F.
		Return
	Endif
Endif            
	
Return

//Fim da Rotina

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o	 ณ FGETPATH ณ Autor ณ Kleber Dias Gomes     ณ Data ณ 28/03/13 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Permite que o usuario decida onde sera criado o arquivo    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ             												  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function fGetPath()

Local cRet	:= Alltrim(ReadVar())
Local cPath	:= cNomeArq

oWnd := GetWndDefault()

While .T.
	If Empty(cPath)
		cPath := cGetFile( "Arquivos Texto de Importacao | *.TXT ",OemToAnsi("Selecione Arquivo"))
	EndIf
	
	If Empty(cPath)
		Return .F.
	EndIf
	&cRet := cPath
	Exit
EndDo

If oWnd != Nil
	GetdRefresh()
EndIf

Return .T.
//Fim da Rotina 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ fChkPerg บ Autor ณEquipe Totvs บ Data ณ  28/03/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Cria Perguntas                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */
Static Function fChkPerg()

Local aRegs	:= {}

aAdd(aRegs,{cPerg,'01','Filial De               ?','','','mv_ch1','C',02,0,0,'G','           ','mv_par01','               ','','','','','             ','','','','','             ','','','','','              ','','','','','               ','','','','SM0','','',''})
aAdd(aRegs,{cPerg,'02','Filial Ate              ?','','','mv_ch2','C',02,0,0,'G','NaoVazio   ','mv_par02','               ','','','','','             ','','','','','             ','','','','','              ','','','','','               ','','','','SM0','','',''})
aAdd(aRegs,{cPerg,'03','Centro de Custo De      ?','','','mv_ch3','C',09,0,0,'G','           ','mv_par03','               ','','','','','             ','','','','','             ','','','','','              ','','','','','               ','','','','CTT','','',''})
aAdd(aRegs,{cPerg,'04','Centro de Custo Ate     ?','','','mv_ch4','C',09,0,0,'G','NaoVazio   ','mv_par04','               ','','','','','             ','','','','','             ','','','','','              ','','','','','               ','','','','CTT','','',''})
aAdd(aRegs,{cPerg,'05','Matricula De            ?','','','mv_ch5','C',06,0,0,'G','           ','mv_par05','               ','','','','','             ','','','','','             ','','','','','              ','','','','','               ','','','','SRA','','',''})
aAdd(aRegs,{cPerg,'06','Matricula Ate           ?','','','mv_ch6','C',06,0,0,'G','NaoVazio   ','mv_par06','               ','','','','','             ','','','','','             ','','','','','              ','','','','','               ','','','','SRA','','',''})
aAdd(aRegs,{cPerg,'07','Turno de                ?','','','mv_ch7','C',03,0,0,'G','           ','mv_par07','               ','','','','','             ','','','','','             ','','','','','              ','','','','','               ','','','','SR6','','',''})
aAdd(aRegs,{cPerg,'08','Turno Ate               ?','','','mv_ch8','C',03,0,0,'G','NaoVazio   ','mv_par08','               ','','','','','             ','','','','','             ','','','','','              ','','','','','               ','','','','SR6','','',''})
aAdd(aRegs,{cPerg,'09','Situacoes a Gerar       ?','','','mv_ch9','C',05,0,0,'G','fSituacao  ','mv_par09','               ','','','','','             ','','','','','             ','','','','','              ','','','','','               ','','','','   ','','',''})
aAdd(aRegs,{cPerg,'10','Categorias a Gerar      ?','','','mv_cha','C',12,0,0,'G','fCategoria ','mv_par10','               ','','','','','             ','','','','','             ','','','','','              ','','','','','               ','','','','   ','','',''})
aAdd(aRegs,{cPerg,'11','Codigo de Cliente       ?','','','mv_chb','C',09,0,0,'G','NaoVazio   ','mv_par11','               ','','','','','             ','','','','','             ','','','','','              ','','','','','               ','','','','   ','','',''})
aAdd(aRegs,{cPerg,'12','Usuแrio do Sistema      ?','','','mv_chc','C',30,0,0,'G','NaoVazio   ','mv_par12','               ','','','','','             ','','','','','             ','','','','','              ','','','','','               ','','','','   ','','',''}) 
aAdd(aRegs,{cPerg,'13','Email Usuario Sistema   ?','','','mv_chd','C',30,0,0,'G','NaoVazio   ','mv_par13','               ','','','','','             ','','','','','             ','','','','','              ','','','','','               ','','','','   ','','',''}) 
aAdd(aRegs,{cPerg,'14','Nome do Arquivo         ?','','','mv_che','C',25,0,0,'G','fGetPath() ','mv_par14','               ','','','','','             ','','','','','             ','','','','','              ','','','','','               ','','','','   ','','',''})
aAdd(aRegs,{cPerg,'15','DDD+Num Tel Contato     ?','','','mv_chf','C',12,0,0,'G','NaoVazio   ','mv_par15','               ','','','','','             ','','','','','             ','','','','','              ','','','','','               ','','','','   ','','',''}) 
aAdd(aRegs,{cPerg,'16','Sexo do Contato         ?','','','mv_chg','N',01,0,0,'C','           ','mv_par16','Masculino      ','','','','','Feminino     ','','','','','             ','','','','','              ','','','','','               ','','','','   ','','',''}) 
aAdd(aRegs,{cPerg,'17','Dt Nasc do Contato      ?','','','mv_chh','D',08,0,0,'G','NaoVazio   ','mv_par17','               ','','','','','             ','','','','','             ','','','','','              ','','','','','               ','','','','   ','','',''})

ValidPerg(aRegs,cPerg) 

Return

//Fim da Rotina
