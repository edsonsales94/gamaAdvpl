#INCLUDE "PROTHEUS.CH"
#INCLUDE "ABSENT.CH"
#INCLUDE "RWMAKE.CH"

User Function TRABSENT()
Local oReport     
Private cPerg:="ABSENT"
  
Pergunte(cPerg,.F.)
oReport:= ReportDef()
oReport:PrintDialog()

Return
 

Static Function ReportDef()
//-- Variaveis Locais
Local oReport 
Local oSection1 
Local oCell         
Local oBreak
Local cTitle       := ''
Local cAlias    := 'SPC'				//-- Alias do arquivo a partir do qual os lancamentos serao lidos
Local cAliasSra    := GetNextAlias()	//GetNextAlias()-- Alias do arquivo a partir do qual os Dados do funcionario

oReport := TReport():New("ABSENT",cTitle,cPerg, {|oReport| ReportPrint(oReport,cAliasSra  )},cTitle) //"Emissao das solicitacoes de compras cadastradas"
//oReport:SetLandscape() 
oSection1:= TRSection():New(oReport,"Funcionarios",{"SRA"},/*aOrdem*/)

//oSection1:SetHeaderPage()

TRCell():New(oSection1,"RA_MAT"  ,"SRA","Matricula" ,/*Picture*/,12,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"RA_NOME"  ,"SRA","Nome" ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"RA_CC"  ,"SRA","C.Custo" ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 
TRCell():New(oSection1,"I3_DESC"  ,"SRA","N.Centro Custo" ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) 

TRCell():New(oSection1,"RA_TNOTRAB"  ,"SRA","Turno" ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oSection2:= TRSection():New(oReport,"Apontamentos",{"SPC"},/*aOrdem*/)  
 
TRCell():New(oSection2,"Periodo"  ,"  ","Periodo" ,/*Picture*/,12,/*lPixel*/,/*{|| code-block de impressao }*/,/*Alinhamento*/)
TRCell():New(oSection2,"HRPrev"   ,"  ","Hrs.Prev"        ,PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")
TRCell():New(oSection2,"HRReal"   ,"  ","Hrs.Real"        ,PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")
TRCell():New(oSection2,"PercReal" ,"  "," % "             ,PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")
TRCell():New(oSection2,"HRAdic"   ,"  ","(1) Hrs.Adic."   ,PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")
TRCell():New(oSection2,"PercAdic" ,"  "," % "             ,PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")
TRCell():New(oSection2,"HRNtrab"  ,"  ","(2) Hrs.N.Trab." ,PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")
TRCell():New(oSection2,"PercNtrab","  "," % "             ,PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")
TRCell():New(oSection2,"HRAbon"   ,"  ","(3) Hrs.Abonadas",PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")
TRCell():New(oSection2,"PercAbon" ,"  "," % "             ,PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")

oSection3:= TRSection():New(oReport,"Resumos Funcionario ",{"SPC"},/*aOrdem*/)

TRCell():New(oSection3,"Evento1"  ,"  ","(1) Evento" ,/*Picture*/,12,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER" ,,"LEFT") 
TRCell():New(oSection3,"Descri1"  ,"  ","Descrição" ,/*Picture*/,12,/*lPixel*/,/*{|| code-block de impressao }*/,/*Alinhamento*/)
TRCell():New(oSection3,"Horas1"   ,"  ","Horas"        ,PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")
TRCell():New(oSection3,"Perc1"  ,"  "," %" ,PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")
TRCell():New(oSection3,"Evento2"  ,"  ","(2) Evento" ,/*Picture*/,12,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER" ,,"LEFT") 
TRCell():New(oSection3,"Descri2"  ,"  ","Descrição" ,/*Picture*/,12,/*lPixel*/,/*{|| code-block de impressao }*/,/*Alinhamento*/)
TRCell():New(oSection3,"Horas2"   ,"  ","Horas"        ,PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")
TRCell():New(oSection3,"Perc2"  ,"  "," %" ,PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")
TRCell():New(oSection3,"Evento3"  ,"  ","(3) Evento" ,/*Picture*/,12,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER" ,,"LEFT") 
TRCell():New(oSection3,"Descri3"  ,"  ","Descrição" ,/*Picture*/,12,/*lPixel*/,/*{|| code-block de impressao }*/,/*Alinhamento*/)
TRCell():New(oSection3,"Horas3"   ,"  ","Horas"        ,PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")
TRCell():New(oSection3,"Perc3"  ,"  "," %" ,PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")


oSection4:= TRSection():New(oReport,"Resumos Centro de Custo",{"SPC"},/*aOrdem*/)

TRCell():New(oSection4,"Evento1"  ,"  ","(1) Evento" ,/*Picture*/,12,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER" ,,"LEFT") 
TRCell():New(oSection4,"Descri1"  ,"  ","Descrição" ,/*Picture*/,12,/*lPixel*/,/*{|| code-block de impressao }*/,/*Alinhamento*/)
TRCell():New(oSection4,"Horas1"   ,"  ","Horas"        ,PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")
TRCell():New(oSection4,"Perc1"  ,"  "," %" ,PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")
TRCell():New(oSection4,"Evento2"  ,"  ","(2) Evento" ,/*Picture*/,12,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER" ,,"LEFT") 
TRCell():New(oSection4,"Descri2"  ,"  ","Descrição" ,/*Picture*/,12,/*lPixel*/,/*{|| code-block de impressao }*/,/*Alinhamento*/)
TRCell():New(oSection4,"Horas2"   ,"  ","Horas"        ,PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")
TRCell():New(oSection4,"Perc2"  ,"  "," %" ,PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")
TRCell():New(oSection4,"Evento3"  ,"  ","(3) Evento" ,/*Picture*/,12,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER" ,,"LEFT") 
TRCell():New(oSection4,"Descri3"  ,"  ","Descrição" ,/*Picture*/,12,/*lPixel*/,/*{|| code-block de impressao }*/,/*Alinhamento*/)
TRCell():New(oSection4,"Horas3"   ,"  ","Horas"        ,PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")
TRCell():New(oSection4,"Perc3"  ,"  "," %" ,PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")

oSection5:= TRSection():New(oReport,"Resumos Empresa",{"SPC"},/*aOrdem*/)

TRCell():New(oSection5,"Evento1"  ,"  ","(1) Evento" ,/*Picture*/,12,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER" ,,"LEFT") 
TRCell():New(oSection5,"Descri1"  ,"  ","Descrição" ,/*Picture*/,12,/*lPixel*/,/*{|| code-block de impressao }*/,/*Alinhamento*/)
TRCell():New(oSection5,"Horas1"   ,"  ","Horas"        ,PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")
TRCell():New(oSection5,"Perc1"  ,"  "," %" ,PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")
TRCell():New(oSection5,"Evento2"  ,"  ","(2) Evento" ,/*Picture*/,12,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER" ,,"LEFT") 
TRCell():New(oSection5,"Descri2"  ,"  ","Descrição" ,/*Picture*/,12,/*lPixel*/,/*{|| code-block de impressao }*/,/*Alinhamento*/)
TRCell():New(oSection5,"Horas2"   ,"  ","Horas"        ,PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")
TRCell():New(oSection5,"Perc2"  ,"  "," %" ,PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")
TRCell():New(oSection5,"Evento3"  ,"  ","(3) Evento" ,/*Picture*/,12,/*lPixel*/,/*{|| code-block de impressao }*/,"CENTER" ,,"LEFT") 
TRCell():New(oSection5,"Descri3"  ,"  ","Descrição" ,/*Picture*/,12,/*lPixel*/,/*{|| code-block de impressao }*/,/*Alinhamento*/)
TRCell():New(oSection5,"Horas3"   ,"  ","Horas"        ,PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")
TRCell():New(oSection5,"Perc3"  ,"  "," %" ,PesqPict("SPC","PC_QUANTC" ),12,/*lPixel*/,/*{|| code-block de impressao }*/,"RIGHT" ,,"CENTER")


Return(oReport)


Static Function ReportPrint(oReport, cAliasSra)

Local oSection1 := oReport:Section(1) 
Local oSection2 := oReport:Section(2) //:Section(1) 
Local oSection3 := oReport:Section(3) //:Section(1):Section(1)
Local oSection4 := oReport:Section(4)  
Local oSection5 := oReport:Section(5)  
Local nX

Local dPonmesIni   := Ctod("  /  /  ")	//-- Data de inicio do periodo aberto


Private cDet         := ''				//-- Linha de detalhe da impressao
Private cSeqAnt      := '  '				//-- Sequencia anterior
Private nX           := 0					//-- Variavel de loop for
Private aAbon        := {}				//-- Itens de abono GERAL
Private aNTra        := {}				//-- Itens de hrs nao trabalhadas GERAL
Private aAdic        := {}				//-- Itens de hrs adicionais GERAL     
Private aCodHeAut    := {}				//-- Codigos de hora extra autorizada
Private aCodAbat     := {}				//-- Codigos de horas nao trabalhadas
Private aTurnos      := {}				//-- Trocas de turno do periodo
Private aPeriodos    := {}				//-- Periodos a imprimir
Private cColuna01    := ''				//-- Detalhe da coluna 1 do relatorio
Private cColuna02    := ''				//-- Detalhe da coluna 2 do relatorio
Private cColuna03    := ''				//-- Detalhe da coluna 3 do relatorio
Private lSemApo	   := .F.				//-- Indicador se Existe Apontamentos     
Private nHrsPrev     := 0					//-- Horas previstas
Private nHrsReal     := 0					//-- Horas reais
Private nPReal       := 0					//-- Percentual horas reais
Private nHrsAdic     := 0					//-- Horas adicionais
Private nPAdic       := 0					//-- Percentual horas adicionais
Private nPNTra       := 0					//-- Percentual horas nao trabalhadas
Private nHrsAbon     := 0					//-- Horas abonadas
Private nPAbo        := 0					//-- Percentual horas abonadas
Private dPerIni      := Ctod("  /  /  ")	//-- Data de inicio do periodo
Private dPerFim      := Ctod("  /  /  ")	//-- Data fim do periodo
//Local dPonmesIni   := Ctod("  /  /  ")	//-- Data de inicio do periodo aberto
Private dPonmesFim   := Ctod("  /  /  ")	//-- Data fim do periodo aberto
Private cAcessaSRA   := &("{ || " + ChkRH("ABSENT","SRA","2") + "}")
Private dtInicio	   := Ctod('') 			//-- Auxiliar Inicio do Periodo considerando Data Admissao

Private cFilAnte   := ''				//-- Filial anterior
Private cFilRegra  := ''				//-- Filial para uso na consulta do arquivo Regra
Private cTnoAnt    := ''				//-- Turno anterior
Private cCcAnt     := ''				//-- Centro de custo anterior
Private nHrsnTra   := 0					//-- Horas nao trabalhadas
Private nHrsAfast  := 0                 //-- Horas Afastado
Private aFast      := .T.               //--   Flega afastaentos  
Private aTabPadrao := {}				//-- Tabela de horario padrao
Private aTabCalend := {}				//-- Calendario de trabalho
Private aAdicT     := {}					//-- Totalizador hrs adicionais turno
Private aNTraT     := {}					//-- Totalizador hrs nao trab. turno
Private aAbonT     := {}					//-- Totalizador hrs abonadas turno
Private aAdicC     := {}					//-- Totalizador hrs adicionais centro de custo
Private aNTraC     := {}					//-- Totalizador hrs nao trabalhadas centro de custo
Private aAbonC     := {}					//-- Totalizador hrs abonadas centro de custo
Private aAdicF     := {}					//-- Totalizador hrs adicionais filial
Private aNTraF     := {}					//-- Totalizador hrs nao trabalhadas filial
Private aAbonF     := {}					//-- Totalizador hrs abonadas filial
Private aAdicE     := {}					//-- Totalizador hrs adicionais empresa
Private aNTraE     := {}					//-- Totalizador hrs nao trabalhadas empresa
Private aAbonE     := {}					//-- Totalizador hrs abonadas empresa
Private aTotalF    := {}
Private aTotalE    := {}
Private aTotalC    := {}
Private aTotalT    := {}  
Private aInfo      := {} 
Private lPrimVez   := .T.



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carregando variaveis MV_PAR?? para Variaveis do Sistema.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cFilDe     	:= MV_PAR01					//Filial De           ?
Private cFilAte    	:= MV_PAR02					//Filial Ate          ? 
Private CcDe       	:= MV_PAR03					//Centro de Custo De  ?
Private CcAte      	:= MV_PAR04					//Centro de Custo Ate ?
Private TurDe      	:= MV_PAR05					//Turno De            ?
Private TurAte     	:= MV_PAR06					//Turno Ate           ?
Private MatDe      	:= MV_PAR07					//Matricula De        ?
Private MatAte     	:= MV_PAR08					//Matricula Ate       ?
Private NomDe      	:= MV_PAR09					//Nome De             ?
Private NomAte     	:= MV_PAR10					//Nome Ate            ?
Private cSit       	:= MV_PAR11					//Situacoes a Impr.   ?
Private cCat       	:= MV_PAR12					//Categorias a Impr.  ?
Private lCC        	:= If(MV_PAR13 == 1,.T.,.F.)	//C.C. em Outra Pag.  ? Sim/Nao
Private dDataDe    	:= MV_PAR14					//Data De             ?
Private dDataAte   	:= MV_PAR15					//Data Ate            ?
Private lSintetico 	:= If(MV_PAR16 == 1,.F.,.T.)	//Analitico/Sintetico ? Analitico/Sintetico
Private lDiscri    	:= If(MV_PAR17 == 1,.T.,.F.)	//Discrimina Eventos  ? Sim/Nao 
Private lAfastPrev	:= If(MV_PAR18 == 1,.T.,.F.)	//Considera o Afastamento como Previsto ? Sim/Nao

oSection1:nOrder:=2

If oSection1:nOrder == 1
	cOrd := "%RA_FILIAL , RA_MAT%"
ElseIf oSection1:nOrder == 2
	cOrd := "%RA_FILIAL , RA_CC , RA_MAT%"
ElseIf oSection1:nOrder == 3
	cOrd := "%RA_FILIAL , RA_NOME , RA_MAT%"
ElseIf oSection1:nOrder == 4
	cOrd := "%RA_FILIAL , RA_TNOTRAB%"
ElseIf oSection1:nOrder == 5
	cOrd := "%RA_FILIAL , RA_CC , RA_NOME%" 
Endif    
                          
//-- Carga da tabela de horario padrao
If !fTabTurno(aTabPadrao)
	Help(' ',1,'TPADNCAD')
	Return Nil
EndIf

oReport:SetTitle("Absenteismo de"+' '+Transf(dDataDe,'@E')+' - '+Transf(dDataAte,'@E')) 
// QUERY DOS ITENS VENCIDOS EM 30 DIAS 
oSection1:BeginQuery()	
BeginSql Alias cAliasSra
	SELECT RA_FILIAL , RA_MAT, RA_NOME, RA_CC , RA_TNOTRAB,RA_SITFOLH,RA_CATFUNC,RA_SEQTURN,RA_ADMISSA,RA_DEMISSA,RA_SITFOLH,I3_DESC  
	   		  FROM %table:SRA% SRA
	   		  LEFT JOIN SI3010 SI3 ON RA_FILIAL=I3_FILIAL AND I3_CUSTO=RA_CC
			 WHERE RA_FILIAL  >= %Exp:cFilde% AND RA_FILIAL<= %Exp:cFilAte% AND 
			       RA_CC >= %Exp:CcDe% AND RA_CC <= %Exp:CcAte% AND 
			       RA_TNOTRAB >= %Exp:TurDe% AND RA_TNOTRAB <= %Exp:TurAte% AND
			       RA_MAT >= %Exp:MatDe% AND RA_MAT <= %Exp:MatAte% AND RA_REGRA<>'99' AND  
			       RA_NOME >= %Exp:NomDe% AND RA_NOME <= %Exp:NomAte%  AND  
			       (RA_SITFOLH=%Exp:substr(cSit,1,1)% OR RA_SITFOLH=%Exp:substr(cSit,2,1)% OR 
			        RA_SITFOLH=%Exp:substr(cSit,3,1)% OR RA_SITFOLH=%Exp:substr(cSit,4,1)% OR RA_SITFOLH=%Exp:substr(cSit,5,1)%)  AND
			       (RA_CATFUNC=%Exp:substr(cCat,1,1)% OR RA_CATFUNC=%Exp:substr(cCat,2,1)%  OR RA_CATFUNC=%Exp:substr(cCat,3,1)%  OR RA_CATFUNC=%Exp:substr(cCat,4,1)% OR
			        RA_CATFUNC=%Exp:substr(cCat,5,1)% OR RA_CATFUNC=%Exp:substr(cCat,6,1)%  OR RA_CATFUNC=%Exp:substr(cCat,7,1)%  OR RA_CATFUNC=%Exp:substr(cCat,8,1)% OR
			        RA_CATFUNC=%Exp:substr(cCat,9,1)% OR RA_CATFUNC=%Exp:substr(cCat,10,1)% OR RA_CATFUNC=%Exp:substr(cCat,11,1)% OR RA_CATFUNC=%Exp:substr(cCat,12,1)% )
			       AND SRA.%NotDel% AND SI3.%NotDel%
			ORDER BY %Exp:cOrd%
EndSql
oSection1:EndQuery(/*Array com os parametros do tipo Range*/)
 //((RA_DEMISSA >= %Exp:dtos(dDataDe)% AND RA_DEMISSA <= %Exp:dtos(dDataAte)%) OR RA_DEMISSA='')
dbSelectArea(cAliasSra) 
Count to nRecSra 
dbgotop()     
oReport:SetMeter(nRecSra)
	 //-- Obtem o Periodo Aberto 
    GetPonMesDat( @dPonMesIni , @dPonMesFim , cFilAnte )

If !(cAliasSra)->(Eof())
 //oSection1:Init() 
 cFilAnte     := (cAliasSra)->RA_FILIAL 
 cCcAnt       := (cAliasSra)->RA_Cc
 cTnoAnt      := (cAliasSra)->RA_TNOTRAB	
		
 While !oReport:Cancel() .And. !(cAliasSra)->(Eof())
   oReport:IncMeter()
   If oReport:Cancel()
	 Exit                                                      
   EndIf 
   //-- Processa a Quebra Centro de Custo
   If (cAliasSra)->RA_Cc != cCcAnt
    //achar centro de custo
    
        
     cTit :="Total C.Custo : " + cCcAnt +" - "+ AllTrim(fDesc("SI3",cCcAnt,"I3_DESC",TamSx3("I3_DESC")[1]) )
     
     cFilAnte  := (cAliasSra)->RA_FILIAL 
	  cCcAnt  	:= (cAliasSra)->RA_Cc   
     if  Max(Max(Len(aAdicC), Len(aNTraC)),Len(aAbonC))>0
      oReport:PrintText(cTit,,oSection4:Cell("Evento1"):ColPos()) 
      if lCC
	    oReport:EndPage() 
	    oReport:StartPage()
	   endif 
      //Totaiza o Relatorio
      For nX := 1 To Max(Max(Len(aAdicC), Len(aNTraC)),Len(aAbonC))
       oSection4:Init()                     
       oSection4:Cell("Evento1" ):SetValue(iif(nX<=Len(aAdicC),aAdicC[nX,1],"" )  )
       oSection4:Cell("Descri1" ):SetValue(iif(nX<=Len(aAdicC),aAdicC[nX,2],"" )  )
       oSection4:Cell("Horas1"  ):SetValue(iif(nX<=Len(aAdicC),aAdicC[nX,3],"" )  )
       oSection4:Cell("Perc1"   ):SetValue(iif(nX<=Len(aAdicC),aAdicC[nX,4],"" )  )   
       oSection4:Cell("Evento2" ):SetValue(iif(nX<=Len(aNTraC),aNTraC[nX,1],"" )  )
       oSection4:Cell("Descri2" ):SetValue(iif(nX<=Len(aNTraC),aNTraC[nX,2],"" )  )
       oSection4:Cell("Horas2"  ):SetValue(iif(nX<=Len(aNTraC),aNTraC[nX,3],"" )  )
       oSection4:Cell("Perc2"   ):SetValue(iif(nX<=Len(aNTraC),aNTraC[nX,4],"" )  )
       oSection4:Cell("Evento3" ):SetValue(iif(nX<=Len(aAbonC),aAbonC[nX,1],"" )  )
       oSection4:Cell("Descri3" ):SetValue(iif(nX<=Len(aAbonC),aAbonC[nX,2],"" )  )
       oSection4:Cell("Horas3"  ):SetValue(iif(nX<=Len(aAbonC),aAbonC[nX,3],"" )  )
       oSection4:Cell("Perc3"   ):SetValue(iif(nX<=Len(aAbonC),aAbonC[nX,4],"" )  )
       oSection4:PrintLine() 
      Next nX
      oSection4:Finish()
      oReport:SkipLine()
      //oReport:ThinLine() ricky
      oReport:EndPage()   
      oReport:StartPage()
     endif  
	  aAbonC       := {}				//-- Itens de abono GERAL
     aNTrac       := {}				//-- Itens de hrs nao trabalhadas GERAL
     aAdicC       := {}				//-- Itens de hrs adicionais GERAL     
     nHrsAfast    := 0                 //-- Horas Afastado
     aFast        := .T.               //--   Flega afastaentos  
	 //-- Dados da empresa/filial
	 //If !fInfo(@aInfo,(cAliasSra)->RA_FILIAL)
	 //	Exit
    // Endif
	
	  //-- Carrega os codigos de horas nao trabalhadas
	  //  fCarCodAbat(@aCodAbat)                     
	//    cFilRegra:= fFilFunc("SPA") 
	 
	  /*
	 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 ³ Carrega periodo de Apontamento Aberto						  ³
	 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	 IF !CheckPonMes( @dPerIni , @dPerFim , .F. , .T. , .F. , cFilAnte )
	 	Exit
	 EndIF 
	 
	Endif
	//-- Processa a Quebra de Turno
	If cTnoAnt+cSeqAnt != (cAliasSra)->RA_TNOTRAB+(cAliasSra)->RA_SEQTURN  
		cSeqAnt := (cAliasSra)->RA_SEQTURN
		cTnoAnt := (cAliasSra)->RA_TNOTRAB	
		
		//-- Carrega os codigos de horas nao trabalhadas
		fCarCodAbat(@aCodAbat)                  
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consiste controle de acessos e filiais validas               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !((cAliasSra)->RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA)
	    //fCabTotal()
	   dbSelectArea(cAliasSra)
      dbSkip() 
		Loop
	EndIf
	 
    If !((cAliasSra)->RA_SITFOLH 	$ cSit) 	.Or. !((cAliasSra)->RA_CATFUNC 	$ cCat) 
		//fCabTotal()
		dbSelectArea(cAliasSra)
      dbSkip()
		Loop
	Endif
	
    /*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Retorna Periodos de Apontamentos Selecionados				  ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aPeriodos := Monta_per( dDataDe , dDataAte , cFilAnte , (cAliasSra)->RA_MAT , dPerIni , dPerFim,(cAliasSra)->RA_ADMISSA )
//	IF Len(aPeriodos)>0 .and. !lSintetico  RICKY
	IF Len(aPeriodos)>0
	  oSection1:Init() 
	 IF !lSintetico 
	  oSection1:PrintLine() 
	 ENDIF
	ENDIF
	
	For nX := 1 To Len(aPeriodos)
	  cSeqTurn := '**'
	  DBSELECTAREA("SRA")
	  DBSETORDER(1)
	  DBSEEK(XFILIAL("SRA")+(cAliasSra)->RA_MAT)
	  //FERIFICA SE HOUVE TROCAS DE TURNO
	     //-- Chamada a fTrocaTno() para identificar o turno correto a ser passado para retseq.
	    fTrocaTno(aPeriodos[nX,1], aPeriodos[nX,2], @aTurnos)
	                                
	  
	  cSeqTurn := (cAliasSra)->RA_SEQTURN
	  cTno     := If(Len(aTurnos)==0,(cAliasSra)->RA_TNOTRAB,aTurnos[1,1])
	  //-- Se periodo for anterior ao atual arquivo de trabalho sera SPH
	  If ( aPeriodos[nX,2] < dPonMesIni )
		cAlias := 'SPH'
	  Else                                          
		cAlias := 'SPC' 

	  Endif
	  //-- Considera a Data de Admissao para o Inicio do Periodo
	  dtInicio:=Max(aPeriodos[nX,3],(cAliasSra)->RA_ADMISSA) 
	  //-- Monta calendario com horarios de trabalho 
	  If !CriaCalend( Max(aPeriodos[nX,1],RA_ADMISSA),aPeriodos[nX,2],cTno,cSeqTurn,aTabPadrao,@aTabCalend,RA_FILIAL,RA_MAT,RA_CC,@aTurnos,NIL,NIL,.F.)
		Loop
	  EndIf
	  dbSelectArea(cAliasSra) 
	  //-- Apura as horas trabalhadas a partir do calendario de trabalho
	  nHrsAfast:= 0		                      
     nHrsPrev := fHrsPrev(aTabCalend,dtInicio,aPeriodos[nX,4],cAliasSra)

	  //-- Apura as horas adicionais, horas nao trabalhadas e as horas abonadas, a partir do SPC e/ou SPH
	  nHrsAdic	:= 0
	  nHrsAbon	:= 0		
	  nHrsnTra	:= nHrsAfast		                      
	  
	  fSomaHrs(aCodAbat, aCodHeAut, @aAdic, @aNTra, @aAbon, @nHrsAdic, @nHrsnTra, @nHrsAbon, dtInicio, aPeriodos[nX,4], cAlias, @lSemApo,cAliasSra)
	  //-- Apura as horas efetivamente trabalhadas ( previstas - nao trab )
	  If ! Empty(nHrsnTra)
			nHrsReal := SubHoras(nHrsPrev,nHrsnTra)			
			nHrsReal := If(nHrsReal < 0.00, 0.00, nHrsReal)
	  Else
			If lSemApo                                                                                                  
				//Verifica se trata de um periodo de apontamento futuro
				If ( aPeriodos[nX, 1] > dPonMesFim )
			   		nHrsReal := 0.00
			   	Else                                             
				   	nHrsReal := nHrsPrev
				Endif
			Else 
				 nHrsReal := nHrsPrev
			Endif	   	                   
	  Endif	
	  //-- Percentual de horas reais x previstas
	  nPReal   := (fConvHr(nHrsReal,'D') / fConvHr(nHrsPrev,'D')) * 100
	  //-- Percentual de horas extras x previstas
	  nPAdic   := (fConvHr(nHrsAdic,'D') / fConvHr(nHrsPrev,'D')) * 100
	  //-- Percentual de horas nao trabalhadas x previstas
	  nPNTra   := (fConvHr(nHrsnTra,'D') / fConvHr(nHrsPrev,'D')) * 100
	  //-- Percentual de horas abonadas x horas nao trabalhadas
	  nPAbo    := (fConvHr(nHrsAbon,'D') / fConvHr(nHrsnTra,'D')) * 100
     
     //-- Monta Seção de Funcionario com os periodos 
     if !lSintetico .and. nHrsPrev>0
       oSection2:Init() 
		 oSection2:Cell("Periodo"  ):SetValue(StrZero(Month(aPeriodos[nX,2]),2)+'/'+Transf(Year(aPeriodos[nX,2]),'9999'))
	    oSection2:Cell("HRPrev" ):SetValue(nHrsPrev)
	    oSection2:Cell("HRReal" ):SetValue(nHrsReal) 
	    oSection2:Cell("PercReal" ):SetValue(nPReal)
	    oSection2:Cell("HRAdic" ):SetValue(nHrsAdic) 
	    oSection2:Cell("PercAdic" ):SetValue(nPAdic)
	    oSection2:Cell("HRNtrab" ):SetValue(nHrsnTra)
	    oSection2:Cell("PercNtrab" ):SetValue(nPNTra)
	    oSection2:Cell("HRAbon" ):SetValue(nHrsAbon)
	    oSection2:Cell("PercAbon" ):SetValue(nPAbo)
	    oSection2:PrintLine()
	    oReport:SkipLine() 
	  endif 
	Next nX

   //preencher a seçao 3 com os resultados das leitura
   fCalcPerc(@aAdic)
	fCalcPerc(@aNTra)
	fCalcPerc(@aAbon)  

   For nX := 1 To Max(Max(Len(aAdic), Len(aNTra)),Len(aAbon))
      if !lSintetico .and. Max(Max(Len(aAdic), Len(aNTra)),Len(aAbon))>0
       oSection3:Init()                     
       oSection3:Cell("Evento1" ):SetValue(iif(nX<=Len(aAdic),aAdic[nX,1],"" )  )
       oSection3:Cell("Descri1" ):SetValue(iif(nX<=Len(aAdic),aAdic[nX,2],"" )  )
       oSection3:Cell("Horas1"  ):SetValue(iif(nX<=Len(aAdic),aAdic[nX,3],"" )  )
       oSection3:Cell("Perc1"   ):SetValue(iif(nX<=Len(aAdic),aAdic[nX,4],"" )  )   
       oSection3:Cell("Evento2" ):SetValue(iif(nX<=Len(aNTra),aNTra[nX,1],"" )  )
       oSection3:Cell("Descri2" ):SetValue(iif(nX<=Len(aNTra),aNTra[nX,2],"" )  )
       oSection3:Cell("Horas2"  ):SetValue(iif(nX<=Len(aNTra),aNTra[nX,3],"" )  )
       oSection3:Cell("Perc2"   ):SetValue(iif(nX<=Len(aNTra),aNTra[nX,4],"" )  )
       oSection3:Cell("Evento3" ):SetValue(iif(nX<=Len(aAbon),aAbon[nX,1],"" )  )
       oSection3:Cell("Descri3" ):SetValue(iif(nX<=Len(aAbon),aAbon[nX,2],"" )  )
       oSection3:Cell("Horas3"  ):SetValue(iif(nX<=Len(aAbon),aAbon[nX,3],"" )  )
       oSection3:Cell("Perc3"   ):SetValue(iif(nX<=Len(aAbon),aAbon[nX,4],"" )  )
       oSection3:PrintLine() 
      endif 
	Next nX
	if !lSintetico 
     oReport:SkipLine() 
//     oReport:ThinLine() RICKY
     oSection2:Finish() 
     oSection3:Finish()
   endif 
   //-- Totaliza os Array de Eventos aos Acumuladores: Filial,CC,Turno e Empresa
   fTot(aAdic,{@aAdicF,@aAdicC,@aAdicT,@aAdicE})
   fTot(aNTra,{@aNTraF,@aNTraC,@aNTraT,@aNTraE})
   fTot(aAbon,{@aAbonF,@aAbonC,@aAbonT,@aAbonE})
    
   aAbon        := {}				//-- Itens de abono GERAL
   aNTra        := {}				//-- Itens de hrs nao trabalhadas GERAL
   aAdic        := {}				//-- Itens de hrs adicionais GERAL     
   nHrsAfast    := 0                 //-- Horas Afastado
   aFast        := .T.               //--   Flega afastaentos  
   dbSelectArea(cAliasSra)
   dbSkip()
 EndDo
EndIf
oSection1:Finish()
oReport:EndPage() 
oReport:StartPage()     

//imprime o ultimo centro de custo  Ricky        
cTit :="Total C.Custo Final : "+ALLTRIM(cCcAnt)+" - " + AllTrim(fDesc("SI3",cCcAnt,"I3_DESC",TamSx3("I3_DESC")[1]) )
oReport:PrintText(cTit,,oSection4:Cell("Evento1"):ColPos()) 
For nX := 1 To Max(Max(Len(aAdicC), Len(aNTraC)),Len(aAbonC))
 oSection4:Init()                     
 oSection4:Cell("Evento1" ):SetValue(iif(nX<=Len(aAdicC),aAdicC[nX,1],"" )  )
 oSection4:Cell("Descri1" ):SetValue(iif(nX<=Len(aAdicC),aAdicC[nX,2],"" )  )
 oSection4:Cell("Horas1"  ):SetValue(iif(nX<=Len(aAdicC),aAdicC[nX,3],"" )  )
 oSection4:Cell("Perc1"   ):SetValue(iif(nX<=Len(aAdicC),aAdicC[nX,4],"" )  )   
 oSection4:Cell("Evento2" ):SetValue(iif(nX<=Len(aNTraC),aNTraC[nX,1],"" )  )
 oSection4:Cell("Descri2" ):SetValue(iif(nX<=Len(aNTraC),aNTraC[nX,2],"" )  )
 oSection4:Cell("Horas2"  ):SetValue(iif(nX<=Len(aNTraC),aNTraC[nX,3],"" )  )
 oSection4:Cell("Perc2"   ):SetValue(iif(nX<=Len(aNTraC),aNTraC[nX,4],"" )  )
 oSection4:Cell("Evento3" ):SetValue(iif(nX<=Len(aAbonC),aAbonC[nX,1],"" )  )
 oSection4:Cell("Descri3" ):SetValue(iif(nX<=Len(aAbonC),aAbonC[nX,2],"" )  )
 oSection4:Cell("Horas3"  ):SetValue(iif(nX<=Len(aAbonC),aAbonC[nX,3],"" )  )
 oSection4:Cell("Perc3"   ):SetValue(iif(nX<=Len(aAbonC),aAbonC[nX,4],"" )  )
 oSection4:PrintLine()
Next nX
oSection4:Finish()


//Totaiza o Relatorio
oReport:PrintText("Total Geral :",,oSection5:Cell("Evento1"):ColPos()) 
For nX := 1 To Max(Max(Len(aAdicF), Len(aNTraF)),Len(aAbonF))
     oSection5:Init()                     
     oSection5:Cell("Evento1" ):SetValue(iif(nX<=Len(aAdicF),aAdicF[nX,1],"" )  )
     oSection5:Cell("Descri1" ):SetValue(iif(nX<=Len(aAdicF),aAdicF[nX,2],"" )  )
     oSection5:Cell("Horas1"  ):SetValue(iif(nX<=Len(aAdicF),aAdicF[nX,3],"" )  )
     oSection5:Cell("Perc1"   ):SetValue(iif(nX<=Len(aAdicF),aAdicF[nX,4],"" )  )   
     oSection5:Cell("Evento2" ):SetValue(iif(nX<=Len(aNTraF),aNTraF[nX,1],"" )  )
     oSection5:Cell("Descri2" ):SetValue(iif(nX<=Len(aNTraF),aNTraF[nX,2],"" )  )
     oSection5:Cell("Horas2"  ):SetValue(iif(nX<=Len(aNTraF),aNTraF[nX,3],"" )  )
     oSection5:Cell("Perc2"   ):SetValue(iif(nX<=Len(aNTraF),aNTraF[nX,4],"" )  )
     oSection5:Cell("Evento3" ):SetValue(iif(nX<=Len(aAbonF),aAbonF[nX,1],"" )  )
     oSection5:Cell("Descri3" ):SetValue(iif(nX<=Len(aAbonF),aAbonF[nX,2],"" )  )
     oSection5:Cell("Horas3"  ):SetValue(iif(nX<=Len(aAbonF),aAbonF[nX,3],"" )  )
     oSection5:Cell("Perc3"   ):SetValue(iif(nX<=Len(aAbonF),aAbonF[nX,4],"" )  )
     oSection5:PrintLine() 
Next nX
oSection5:Finish()
oReport:EndPage() 
dbSelectArea(cAliasSra)
dbCloseArea()
 
Return Nil




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Monta_Per³ Autor ³Equipe Advanced RH     ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function Monta_Per( dDataIni , dDataFim , cFil , cMat , dIniAtu , dFimAtu, dAdmissa )

Local aPeriodos := {}
Local cFilSPO	:= xFilial( "SPO" , cFil )
Local dAdmissa	:= dAdmissa
Local dPerIni   := Ctod("//")
Local dPerFim   := Ctod("//")
Local dData		:= Ctod("//")  
Local dIni := substr(dtos(dDataIni),1,6)+"01"

cAliasSPO:= GetNextAlias()
BeginSql Alias cAliasSPO
	SELECT PO_DATAINI,PO_DATAFIM
  	FROM %Table:SPO% SPO
	WHERE PO_FILIAL  = %Exp:cFilSPO% AND PO_DATAINI>= %Exp:dIni%  AND
   SPO.%NotDel% 
   ORDER BY PO_DATAINI 
EndSql      
dbSelectArea(cAliasSPO)  
dbgotop() 

//Obtem os periodos Historicos se estiverem compreendidos pelo periodo solicitado
While (cAliasSPO)->( !Eof()  )
                       
    dPerIni :=stod((cAliasSPO)->PO_DATAINI)
    dPerFim :=stod((cAliasSPO)->PO_DATAFIM)  

    //-- Filtra Periodos de Apontamento a Serem considerados em funcao do Periodo Solicitado
    IF dPerFim < dDataIni .OR. dPerIni > dDataFim                                                      
		(cAliasSPO)->( dbSkip() )  
		Loop  
    Endif

    //-- Somente Considera Periodos de Apontamentos com Data Final Superior a Data de Admissao
    IF ( dPerFim >= dAdmissa )
       aAdd( aPeriodos , { dPerIni , dPerFim , Max( dPerIni , dDataIni ) , Min( dPerFim , dDataFim ) } )
	EndIF

	(cAliasSPO)->( dbSkip() )

End While
DBSELECTAREA(cAliasSPO)
DBCLOSEAREA(cAliasSPO)
//Inclui o periodo atual se estiver compreendido pelo periodo solicitado
IF ( aScan( aPeriodos , { |x| x[1] == dIniAtu .and. x[2] == dFimAtu } ) == 0.00 )
	dPerIni := dIniAtu
	dPerFim	:= dFimAtu 
	IF !(dPerFim < dDataIni .OR. dPerIni > dDataFim)
		IF ( dPerFim >= dAdmissa )
			aAdd(aPeriodos, { dPerIni, dPerFim, Max(dPerIni,dDataIni), Min(dPerFim,dDataFim) } )
		EndIF
    Endif
EndIF

If !Empty(aPeriodos)
	dData	:= aPeriodos[ Len(aPeriodos), 2 ] + 1    
	dPerIni	:= aPeriodos[ Len(aPeriodos), 1 ]     
	dPerFim	:= aPeriodos[ Len(aPeriodos), 2 ]     
Else
	dData	:= dDataIni
	dPerIni	:= dIniAtu 
	dPerFim	:= dFimAtu 
endif

//Inclui periodos futuros se estiverem compreendidos pelo periodo solicitado
If dData > dFimAtu 
	While .T.
		If !PerAponta(@dPerIni,@dPerFim,dData,Nil, Nil, .T., Nil, Nil, .T.)
			HELP(' ',1,'PERNCAD')
			Return Nil
		Endif
		
		//-- Filtra Periodos de Apontamento a Serem considerados em funcao do Periodo Solicitado
		IF ( dPerFim >= dAdmissa )  .and.  !(   dPerFim < dDataIni .OR. dPerIni > dDataFim )
			Aadd(aPeriodos, { dPerIni, dPerFim, Max(dPerIni,dDataIni), Min(dPerFim,dDataFim) })
		Endif
		
		If dDataFim > dPerFim
			dData := dPerFim + 1
		Else
			Exit
		Endif
	
	Enddo
Endif

Return( aPeriodos )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fHrsPrev ³ Autor ³ Alexsandro Pereira    ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fHrsPrev(aTabCalend,dPerIni,dPerfim,cAliasSra)

Local nHrsPrev := 0
Local nX       := 0
Local dData    := 0
Local cTipodia 		:= ''        
Local lTrbFeriado	:=.F.
Local cFRegra		:= ''   
Local cOrdem		:= '!!'  
Local lAfastado		:= .F. 
Local lForaPer		:= .F.

For nX := 1 To Len(aTabCalend)
    
	dData := aTabCalend[nX,1]      
 
		
    //Somente verifica afastamento para Ordem ainda nao lida
    If cOrdem <> aTabCalend[nX,2]
    	cOrdem	:= aTabCalend[nX,2]  
  	   	//-- Desconsidera as datas fora do periodo solicitado
	   	lForaPer	:= (dData < dPerIni .OR. dData > dPerFim)  .OR. (cAliasSra)->( RA_SITFOLH $ 'DúT' .and. dData > RA_DEMISSA ) 
	   	//-- Desconsidera as datas de afastamento             
		  
	Endif    
	 if aTabCalend[nX,24]  //verifica se o funcionario esta afastado
	   if aTabCalend[nX,25]$"F/8"  //Se for ferias nao entra no absenteismo
	     Loop
	   endif                    
	   if aTabCalend[nX,25]$"P/O/A"  //AFASTAMENTO ATESTADO MEDICO
	     if !Empty(aTabCalend[ nX , 27 ]) .and. ((aTabCalend[nX,27]-aTabCalend[nX,26])+1)<15  //SE O AFASTAMENTO FOR MENOR QUE 15 DIAS CONSIDERAR
    	     nHrsAfast:=SomaHoras(nHrsAfast, aTabCalend[nX,7],cAliasSra)
    	  else
    	     loop   
	     endif
	   endif 
	 endif
    lAfastado:=  fAfasta((cAliasSra)->RA_FILIAL,(cAliasSra)->RA_MAT,dData)                               
    //Desconsidera a data de APONTAMENTO se estiver fora do periodo solicitado ou se o funcionario esta afastado 
    //e nao se quer considerar o afastamento.
    If lForaPer //.OR. (lAfastado .AND. !lAfastPrev)
       Loop
    Endif  
    
	//-- Verifica se funcionario Trabalha em Feriado
    If cfRegra <> ( cFilRegra + aTabCalend[ nX , 23 ] )
       cFRegra		:= ( cFilRegra + aTabCalend[ nX , 23 ]  )
       lTrbFeriado	:= GetTrbFer( cFilRegra , aTabCalend[ nX , 23 ] )
	Endif

    // *** Verifica Tipo Dia ***
    //-- Se Feriado 
         //-- Se Excecao
              //Tipo Dia
         //--Senao Excecao     
	         //-- Se NaoTrabalha Feriado
	         //   Tipo dia  = "Feriado"
	         //---Senao NaoTrabalha Feriado
	         //   Tipo dia     
	         //-- Fim se Nao Trabalha Feriado
         //-- Fim se Escecao
    //Senao
    //   Tipo Dia
    //-- Fim se Feriado
    
	cTipoDia	:= IF( aTabCalend[ nX , 19 ] , IF(  aTabCalend[ nX , 10 ]  == "E" , aTabCalend[ nX , 06 ] , IF(!lTrbFeriado,"F",aTabCalend[ nX , 06 ] ) ) , aTabCalend[ nX , 06 ] )                  
    
	If ( cTipoDia !='S' )
		//-- Descarta as Horas da Tabela para Dias diferentes de Trabalhado
		
		If ( !lAfastPrev )
			//-- Apura os dias que o funcionario esta afastado
			If !Empty(aTabCalend[nX,7])
				nHrsnTra := SomaHoras(nHrsnTra, aTabCalend[nX,7],cAliasSra)
			Endif
		Else
			If ( (DOW(dData) > 1) .AND. (DOW(dData) < 7) .AND. (!Empty(aTabCalend[nX,7])) )
				//Desconsidera sabado e domingo, caso as horas de afastamento sejam computadas como horas previstas.
				nHrsPrev := SomaHoras(nHrsPrev,aTabCalend[nX,7],cAliasSra)
			EndIf
		EndIf
	Else
		If !Empty(aTabCalend[nX,7])
			nHrsPrev := SomaHoras(nHrsPrev,aTabCalend[nX,7])
		EndIf
	EndIf
	
Next nX
Return nHrsPrev


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fSomaHrs ³ Autor ³ Alexsandro Pereira    ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fSomaHrs(aCodAbat, aCodHeAut, aAdic, aNTra, aAbon, nHrsAdic, nHrsnTra, nHrsAbon, dPerIni , dPerFim, cAlias, lSemApo,cAliasSra)
Local nX      	:= 0
Local nHoras  	:= 0 
Local nPos	  	:= 0
Local aAbonosPer:= {}
Local bAbono

cPD     := cAlias+'->'+Right(cAlias,2)+'_PD'		//-- Campo codigo de evento
cFil    := cAlias+'->'+Right(cAlias,2)+'_FILIAL'	//-- Campo codigo da filial
cMat    := cAlias+'->'+Right(cAlias,2)+'_MAT'		//-- Campo matricula
cPDI    := cAlias+'->'+Right(cAlias,2)+'_PDI'		//-- Campo codigo de evento informado
cPD     := cAlias+'->'+Right(cAlias,2)+'_PD'		//-- Campo codigo de evento gerado
dData   := cAlias+'->'+Right(cAlias,2)+'_DATA'		//-- Campo data de referencia do lancamento
cQuantc := cAlias+'->'+Right(cAlias,2)+'_QUANTC'	//-- Campo quantidade de horas calculadas
cQuanti := cAlias+'->'+Right(cAlias,2)+'_QUANTI'	//-- Campo quantidade de horas informadas
cTpMarca:= cAlias+'->'+Right(cAlias,2)+'_TPMARCA'	//-- Campo tipo de marcacao
cCC		:= cAlias+'->'+Right(cAlias,2)+'_CC'	    //-- Campo centro de custo
cAbono	:= cAlias+'->'+Right(cAlias,2)+'_ABONO'	    //-- Campo Codigo do Abono
lSemApo:= .T.


/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Corre Todos os Lancamentos do Periodo     					  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/		
dbSelectArea(cAlias)
If dbSeek(fFilFunc(cAlias)+(cAliasSra)->RA_MAT)
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Carrega os Abonos Conforme Periodo       					  ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	fAbonosPer( @aAbonosPer , dPerIni , dPerFim , &cFil , (cAliasSra)->RA_MAT )
	//soma o afastamento  
	If nHrsAfast>0
	if aFast
	  fAcumula(@aNTra , "AFA", nHrsAfast)
	  aFast:=.F.
	endif
   endif
   Do While &cFil + &cMat == (cAliasSra)->RA_FILIAL + (cAliasSra)->RA_MAT
	    //-- Desconsidera Apontamentos fora do Periodo solicitado
	    If &dData < dPerIni .Or. &dData > dPerFim
			(cAlias)->( dbSkip() )
			Loop
		Endif
    
        lSemApo		:= .F.               
                    
		cEvento := If(Empty(&cPDI),&cPD,&cPDI)

	    //-- Obtem as horas do Evento
		nQuant := If(Empty(&cPDI),&cQuantc,&cQuanti)

      
      if len(alltrim(&cAbono))>0
        bAbono := val(Posicione("SP6",1,XFILIAL("SP6")+&cAbono,"P6_XABSENT"))  
      else 
        bAbono := 1
      endif   

       //--201 BANCO DE HORAS
      //Verifica se o motivo do abono entra no absenteismo 

      IF alltrim(&cPDI)=='201'
			bAbono := 0
		ENDIF


      
      //-- Verifica se Evento eh de Desconto
     	If ( Ascan(aCodAbat, cEvento) <> 0 ) .and. bAbono==1             
			//-- Acrescenta o Evento ou Acumula horas do Evento para Array GERAL
			fAcumula(@aNTra , cEvento, nQuant)
			//-- Acumula Total de Horas de Todos os Eventos
			nHrsnTra := SomaHoras(nHrsnTra, nQuant)
		Else
		    //-- Verifica se Evento eh Horas Extras   
	        If ( nPos := aScan( aTabCalend, {|x| x[1] == &dData .and. x[4] == '1E' } ) ) > 0
			    //-- Carrega tabela de Horas Extras / Horas Extras Noturnas        
		        IF ( lRet := GetTabExtra( @aCodHeAut , (cAliasSra)->RA_FILIAL , aTabCalend[ nPos , 14 ] , .F. , .T. ) )
					//-- Verifica se Evento eh hora extra valida para o turno
					If (Ascan(aCodHeAut,{|x| x[4] == cEvento}) <> 0 )  
						//-- Acrescenta o Evento ou Acumula horas do Evento para Array GERAL
						fAcumula(@aAdic , cEvento, nQuant)
						//-- Acumula Total de Horas de Todos os Eventos
						nHrsAdic := SomaHoras(nHrsAdic, nQuant)
			        Else
	        			(cAlias)->( dbSkip() )
						Loop
			        Endif    
			    Else
        			(cAlias)->( dbSkip() )
					Loop
		        Endif    
            Else        
            	(cAlias)->( dbSkip() )
				Loop
            Endif
        Endif
        
        If(Empty(&cPDI))
        	nHrsAbon:=SomaHoras(fHrsAbon(&dData , &cPD, &cTPMARCA , &cCC , aAbonosPer, @aAbon ),nHrsAbon)
        Endif	

		(cAlias)->( dbSkip() )
	Enddo
Endif

//-- Calcula Percentual das Horas do Evento em relacao ao total de horas apontadas 
fCalcPerc(aAbon,nHrsAbon)

Return  



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fCalcPerc³ Autor ³ Mauricio MR           ³ Data ³ 05/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula Percentual de Horas de um Evento em Relacao ao to- ³±±
±±³          ³ tal geral.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fCalcPerc(aColuna)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aColuna  --> Array de Eventos e Horas                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ nHoras   --> Total de Horas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fCalcPerc(aColuna,nHoras)

Local nX      := 0

nHoras  := If(nHoras==Nil,0,nHoras)


//---- Calcula o Total GERAL de Horas 
If Empty(nHoras)
	aEval(aColuna, { |y| nHoras := SomaHoras(nHoras,y[3]) })
Endif

//-- Calcula o percentual de cada item em relacao ao total
aEval(aColuna, { |y| y[4]:=(fConvHr(y[3],'D') / fConvHr(nHoras,'D')) * 100 })

Return nHoras




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fCarCodAbat³ Autor ³ Alexsandro Pereira    ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gen‚rico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fCarCodAbat(aCodAbat)

If SP9->(dbSeek(fFilFunc('SP9')))
	Do While ! SP9->(Eof()) .And. SP9->P9_FILIAL == fFilFunc('SP9')
		If SP9->P9_TIPOCOD = "2" //Evento de Desconto
			Aadd(aCodAbat, SP9->P9_CODIGO)
		Endif
		SP9->(dbSkip())
	Enddo
Endif
Return Nil


Static Function GetTrbFer( cFil , cRegra )
Return( ( PosSPA( cRegra , cFil , "PA_FERIADO" , 1 , .F. ) == "S" ) )



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fHrsAbon ³ Autor ³ Alexsandro Pereira    ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fHrsAbon(dData , cPD, cTPMARCA , cCC , aAbonosPer, aAbon )

Local nHrsAbon 	:= 0
Local nX       	:= 0
Local aAbonos  	:= {}
Local aJustifica:= {}            
Local cEvento	:= ""
Local lAbHoras	:= .F.  
Local nPos		:= 0

If fAbonos( dData , cPD , NIL , @aJustifica , cTPMARCA , cCC , aAbonosPer ) > 0
	//-- Corre Todos os Abonos
	For nX := 1 To Len(aJustifica)
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Cria Array Analitico de Abonos com horas Convertidas.		   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		//-- Obtem a Quantidade de Horas Abonadas
	    If ( nPos := aScan( aAbon, { |x| x[1] == aJustifica[nX,1] } ) ) > 0
			aAbon[nPos,3] := SomaHoras(aAbon[nPos,3], aJustifica[nX,2] ) //_QtAbono
		Else
			Aadd(aAbon, {aJustifica[nX,1] , DescAbono(aJustifica[nX,1],'C'), aJustifica[nX,2], 0 })
		EndIf 
		nHrsAbon:=	SomaHoras( nHrsAbon, aJustifica[nX,2] )
	Next nX 
Endif           

Return(nHrsAbon)           




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ fAcumula ³ Autor ³ Mauricio MR           ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Acumula Evento em array de Acumuladores                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fAcumula(aColuna , cEvento, nQuant)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Absent                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Static Function fAcumula(aColuna , cEvento, nQuant)
Local nPos:=0

//-- Acrescenta o Evento ou Acumula horas do Evento para Array GERAL
If Len(aColuna) > 0 .And. (nPos := Ascan(aColuna, { |x| x[1] == cEvento })) > 0
	aColuna[nPos,3] := SomaHoras(aColuna[nPos,3], nQuant)
Else
	Aadd(aColuna, { cEvento, iif(ALLTRIM(cEvento)=="AFA","POR ATESTADO/AFASTAMENTO",DescPDPon(cEvento)), nQuant, 0 })
Endif

Return




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fTot      ³ Autor ³ Mauricio MR           ³ Data ³04/04/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Totaliza os Acumuladores de Emp,Fil,CC e Turno              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fTot(aCodigos,aCodTot)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aCodigos --> Array com os eventos a serem totalizados       ³±±
±±³          ³aCodTot  --> Array com os SubArrays: Emp,Fil,CC e Turno     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fTot(aCodigos,aCodTot)

Local naCodigos :=Len(aCodigos)
Local naCodTot  :=Len(aCodTot)
Local nX		:=0 
Local nY		:=0

For nX := 1 To naCodigos
    For nY := 1 To naCodTot

		If (nPos := Ascan(aCodTot[nY], { |x| x[1] == aCodigos[nX,1] })) > 0
			aCodTot[nY,nPos,3] := SomaHoras(aCodTot[nY,nPos,3],aCodigos[nX,3])
		Else
			Aadd(aCodTot[nY], { aCodigos[nX,1], aCodigos[nX,2], aCodigos[nX,3], 0 })
		Endif
    Next nY
Next nX 

//Calcula Percentual de Cada Totalizador
aEval(aCodTot, { |aTotal| fCalcPerc(aTotal)})

Return

