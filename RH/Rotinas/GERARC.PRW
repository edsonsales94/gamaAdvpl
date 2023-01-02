#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GERARC   บ Autor ณ                    บ Data ณ 10/11/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gerar os Arquivos de Fechamento RC a Partir do SRD.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function GERARC

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private cPerg    := "GERSRC"
Private cString  := "SRA"
Private oGeraTxt

//fAsrPerg()
//pergunte(cPerg,.F.)

dbSelectArea( "SRA" )
dbSetOrder( 1 )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Montagem da tela de processamento.                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG oGeraTxt FROM  200,001 TO 410,480 TITLE OemToAnsi( "Gerar Tabelas de Fechamento" ) PIXEL

 @ 002, 010 TO 095, 230 OF oGeraTxt  PIXEL

 @ 010, 018 SAY " Este programa ira gerar as tabelas do fechamento mensal (RC)  " SIZE 200, 007 OF oGeraTxt PIXEL
 @ 018, 018 SAY " a partir das informacoes do SRD                               " SIZE 200, 007 OF oGeraTxt PIXEL
 @ 026, 018 SAY "                                                               " SIZE 200, 007 OF oGeraTxt PIXEL

 //DEFINE SBUTTON FROM 070,128 TYPE 5 ENABLE OF oGeraTxt ACTION (Pergunte(cPerg,.T.))
 DEFINE SBUTTON FROM 070,158 TYPE 1 ENABLE OF oGeraTxt ACTION (OkGeraTxt(),oGeraTxt:End())
 DEFINE SBUTTON FROM 070,188 TYPE 2 ENABLE OF oGeraTxt ACTION (oGeraTxt:End())

ACTIVATE MSDIALOG oGeraTxt Centered

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณOKGERATXT บ Autor ณ AP5 IDE            บ Data ณ  28/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao chamada pelo botao OK na tela inicial de processamenบฑฑ
ฑฑบ          ณ to. Executa a geracao do arquivo texto.                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function OkGeraTxt
 Processa({|| RunCont() },"Processando...")
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณ RUNCONT  บ Autor ณ AP5 IDE            บ Data ณ  28/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela PROCESSA.  A funcao PROCESSA  บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunCont

Local cPerDe  := "@@"
Local cPerAte := "@@"

Local lProc13, nTotReg, cQuery
Local cPathRc, cPathRi, cPath
Local cArqFec, aCposRc, aCposRi
Local cIndCond, cArqNtx, cNtxSrd
Local nContad, nPerc

// Criacao do Arquivo do Fechamento Mensal "RC+Emp+Ano+Mes"
If SX6->(dbSeek( "  " + "MV_DGPESRC" ))
   cPathRc := GETMV( "MV_DGPESRC" )
   cPathRi := cPathRc
EndIf

SX2->(dbSeek( "SRC" ))
cPath := Alltrim( SX2->X2_PATH )

If cPathRc == Nil .Or. Empty( cPathRc )
   cPathRc := cPath
EndIf 

// Definir Aqui os Periodos Inicial e Final em Caso de Necessidade
cPerDe  := "200701"  // Periodo Inicial
cPerAte := "200701"  // Periodo Final

// Monta o Periodo De/Ate que Sera Processado
fDetPeriodo( @cPerDe, @cPerAte, @nTotReg )

If cPerDe > cPerAte
   Aviso("ATENCAO","Nao Existem Movimentos Acumulados para Geracao das Tabelas RC's",{"Sair"})
   Return
EndIf

// Definir Aqui os Periodos Inicial e Final em Caso de Necessidade
cPerDe  := "201208"  // Periodo Inicial
cPerAte := "201312"  // Periodo Final

aCposRc := SRC->( dbStruct() )
aCposRi := SRI->( dbStruct() )

// Cria o Indice Temporario do SRD pelo RD_DATARQ
cNtxSrd := CriaTrab(Nil,.F.)
IndRegua("SRD",cNtxSrd,"RD_DATARQ",,,"Selecionando Registros...")

#IFNDEF TOP
 ProcRegua( nTotReg )
#ENDIF
Do While cPerDe <= cPerAte
   #IFNDEF TOP
    IncProc( "Processando Periodo " + Right(cPerDe,2) + "/" + Left(cPerDe,4) )
   #ENDIF
   
   If Select( "FEC" ) > 0
      FEC->(dbCloseArea())
   EndIf
   If Select( "F13" ) > 0
      F13->(dbCloseArea())
   EndIf

   cArqFec := cPathRc + "RC" + cEmpAnt + SubStr(cPerDe,3,2) + Right(cPerDe,2)
   cArqFec := RetArq(__cRDD,cArqFec,.T.)
   If MSFile( cArqFec )
      If Aviso("ATENCAO","O Arquivo de Fechamento " + cArqFec + " Ja Existe! Sobrepor?",{"Sim","Nao"}) == 1
         #IFDEF TOP
          cQuery := "DROP TABLE " + cArqFec
          TcSqlExec( cQuery )
          If TcGetDB() == "ORACLE"
             TcSqlExec( "COMMIT" )
          EndIf
         #ELSE
          fErase( cArqFec )
         #ENDIF
      Else
         fNextPer( @cPerDe )
         Loop
      EndIf
   EndIf

   If MsCreate( cArqFec , aCposRc , __cRdd )
      If !MsOpenDbf( .T. , __cRdd , cArqFec , "FEC" , .F. )
         Aviso("ATENCAO","Nao Foi Possivel Abrir a Tabela " + cArqFec,{"Continuar"})
         fNextPer( @cPerDe )
         Loop
      EndIf
   Else
      Aviso("ATENCAO","Nao Foi Possivel Criar a Tabela " + cArqFec,{"Continuar"})
      fNextPer( @cPerDe )
      Loop
   EndIf

   cIndCond := "RC_FILIAL+RC_MAT+RC_PD+RC_CC+RC_SEMANA+RC_SEQ"
   cArqNtx  := CriaTrab(NIL,.f.)
   IndRegua("FEC",cArqNtx,cIndCond,,,"Selecionando Registros...")
   // Cria Tabela para o 13o Salario
   lProc13 := .F.
   If Right(cPerDe,2) == "12"
      lProc13 := .T.

      cArqFec := cPathRc + "RI" + cEmpAnt + SubStr(cPerDe,3,2) + Right(cPerDe,2)
      cArqFec := RetArq(__cRDD,cArqFec,.T.)
      If MSFile( cArqFec )
         If Aviso("ATENCAO","O Arquivo de Fechamento " + cArqFec + " Ja Existe! Sobrepor?",{"Sim","Nao"}) == 1
            #IFDEF TOP
             cQuery := "DROP TABLE " + cArqFec
             TcSqlExec( cQuery )
             If TcGetDB() == "ORACLE"
                TcSqlExec( "COMMIT" )
             EndIf
            #ELSE
             fErase( cArqFec )
            #ENDIF
         Else
            lProc13 := .F.
         EndIf
      EndIf

      If lProc13 .And. MsCreate( cArqFec , aCposRi , __cRdd )
         If !MsOpenDbf( .T. , __cRdd , cArqFec , "F13" , .F. )
            lProc13 := .F.
         EndIf
      Else
         lProc13 := .F.
      EndIf
  
      If lProc13
         cIndCond := "RI_FILIAL+RI_MAT+RI_PD"
         cArqNtx  := CriaTrab(NIL,.f.)
         IndRegua("F13",cArqNtx,cIndCond,,,"Selecionando Registros...")
      EndIf
   EndIf

   // Contador
   cQuery := "SELECT COUNT(*) AS RD_TOTREG FROM " + RetSqlName( "SRD" )
   cQuery += " WHERE"
   cQuery += "      RD_DATARQ = '" + cPerDe + "' AND"
   cQuery += "      D_E_L_E_T_ <> '*'"
  
   TCQuery cQuery New Alias "WTMP"
   dbGoTop()
   nTotReg := WTMP->RD_TOTREG
   nContad := 0
   nPerc   := 0
   dbCloseArea()

   dbSelectArea( "SRD" )
   dbSeek( cPerDe )

   #IFDEF TOP
    ProcRegua( nTotReg )
   #ENDIF
   Do While !Eof() .And. SRD->RD_DATARQ == cPerDe
      #IFDEF TOP
       nContad++
       nPerc := Round( (nContad / nTotReg) * 100,2 )
       IncProc( Right(cPerDe,2) + "/" + Left(cPerDe,4) + " - " + StrZero(nContad,8) + " -> " + StrZero(nTotReg,8) + " -> " + Str(nPerc,6,2) + "%" )
      #ENDIF
      
      If SRD->RD_MES == "13"
         If lProc13
            // Ordem - RI_FILIAL+RI_MAT+RI_PD
            dbSelectArea( "F13" )
            If !dbSeek( SRD->(RD_FILIAL + RD_MAT + RD_PD) )
               RecLock("F13",.T.)
                F13->RI_FILIAL := SRD->RD_FILIAL
                F13->RI_MAT    := SRD->RD_MAT
                F13->RI_PD     := SRD->RD_PD
            Else
               RecLock("F13",.T.)
            EndIf
             F13->RI_TIPO1   := SRD->RD_TIPO1
             F13->RI_QTDSEM  := SRD->RD_QTDSEM
             F13->RI_HORAS   := SRD->RD_HORAS
             F13->RI_VALOR   := SRD->RD_VALOR
             F13->RI_DATA    := SRD->RD_DATPGT
             F13->RI_CC      := SRD->RD_CC
             F13->RI_TIPO2   := SRD->RD_TIPO2
            MsUnlock()
         EndIf
      Else
         // Ordem - RC_FILIAL+RC_MAT+RC_PD+RC_CC+RC_SEMANA+RC_SEQ
         dbSelectArea( "FEC" )
         If !dbSeek( SRD->(RD_FILIAL + RD_MAT + RD_PD + RD_CC + RD_SEMANA + RD_SEQ) )
            RecLock("FEC",.T.)
             FEC->RC_FILIAL := SRD->RD_FILIAL
             FEC->RC_MAT    := SRD->RD_MAT
             FEC->RC_PD     := SRD->RD_PD
             FEC->RC_CC     := SRD->RD_CC
             FEC->RC_SEMANA := SRD->RD_SEMANA
             FEC->RC_SEQ    := SRD->RD_SEQ
         Else
            RecLock("FEC",.T.)
         EndIf
          FEC->RC_TIPO1   := SRD->RD_TIPO1
          FEC->RC_QTDSEM  := SRD->RD_QTDSEM
          FEC->RC_HORAS   := SRD->RD_HORAS
          FEC->RC_VALOR   := SRD->RD_VALOR
          FEC->RC_DATA    := SRD->RD_DATPGT
          FEC->RC_TIPO2   := SRD->RD_TIPO2
         MsUnlock()
      EndIf

      dbSelectArea( "SRD" )
      dbSkip()
   EndDo

   fNextPer( @cPerDe )
EndDo
SRD->(RetIndex())
SRD->(dbSetOrder( 1 ))
If Select( "FEC" ) > 0
   FEC->(dbCloseArea())
EndIf
If Select( "F13" ) > 0
   F13->(dbCloseArea())
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGERARC    บAutor  ณMicrosiga           บ Data ณ  11/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */
Static Function fNextPer( cPerDe )

 Local nMes := Val(Right(cPerDe,2))
 Local nAno := Val(Left(cPerDe,4))
   
 nMes++
 If nMes == 13
    nMes := 1
    nAno++
 EndIf
   
 cPerDe := StrZero(nAno,4) + StrZero(nMes,2)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGERARC    บAutor  ณMicrosiga           บ Data ณ  11/10/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ */
Static Function fDetPeriodo( cPerDe, cPerAte, nTotReg )

 Local aOldAtu := GETAREA()
 Local cTemp
 Local cQuery
 Local cArqNtx
 
 #IFDEF TOP
  cQuery := "SELECT DISTINCT RD_DATARQ FROM " + RetSqlName( "SRD" )
  cQuery += " WHERE"
  cQuery += "      RD_DATARQ <> '      ' AND"
  cQuery += "      D_E_L_E_T_ <> '*'"
  cQuery += " ORDER BY RD_DATARQ"
  
  TCQuery cQuery New Alias "WTMP"
  If Alias() == "WTMP"
     dbSelectArea( "WTMP" )
     dbGoTop()
     cPerDe := WTMP->RD_DATARQ
     Do While !Eof() 
        cPerAte := WTMP->RD_DATARQ
        dbSkip()
     EndDo
     dbCloseArea()
  EndIf
 #ELSE 
  cArqNtx := CriaTrab(Nil,.F.)
  IndRegua("SRD",cArqNtx,"RD_DATARQ",,,"Selecionando Registros...")
  dbGoTop()
  cPerDe := WTMP->RD_DATARQ
  dbGoBottom()
  cPerAte := WTMP->RD_DATARQ
  SRD->(RetIndex())
  SRD->(dbSetOrder( 1 ))
 #ENDIF
 
 cTemp   := cPerDe
 nTotReg := 0
 Do While cTemp <= cPerAte
    nTotReg++
    fNextPer( @cTemp )
 EndDo
 
 RESTAREA( aOldAtu )
 
Return
