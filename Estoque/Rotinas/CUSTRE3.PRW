
#Include 'Protheus.ch'

User Function CUSTRE3()    
   Processa({|| ProcesSd3()}, "Processando..." )
Return


Static Function ProcesSd3()
Local cAliasSD3:= GetNextAlias()
Local ultFech  := dtos(GETMV("MV_ULMES"))
IF STOD(ultFech)>DDATABASE
   ALERT("NAO E POSSIVEL PROCESSAR ESTA ROTINA COM A DATA MENOR QUE O ULTIMO FECHAMENTO!!!")
ENDIF
//AND D3_COD='SPP3177'
 BeginSql Alias cAliasSD3
   SELECT R_E_C_N_O_ as REGS,* FROM %table:SD3% SD3 WHERE D3_FILIAL=%xFilial:SD3% AND 
   SUBSTRING(D3_EMISSAO,1,6)=%Exp:left(DTOS(DDATABASE),6)% AND D3_ESTORNO<>'S'
   AND D3_CF IN ('RE3','DE3') AND D3_TIPO IN ('SA','PI') 
   AND SD3.%NotDel% 
 EndSql                                          
locproc:=GETMV("MV_LOCPROC")    

dbSelectArea(cAliasSD3)  
ProcRegua(RecCount())
DbGoTop()
While !eof()
   IncProc("Processando ... "+(cAliasSD3)->D3_COD)
   dbSelectArea("SD3")              
   dbgoto((cAliasSD3)->REGS)        
   userid:=SD3->D3_USUARIO
   BEGIN TRANSACTION
   //REFAZ O MOVIMENTO RE3 TRANSFORMANDO ELE EM RE4 
    RECLOCK("SD3",.F.)
     SD3->D3_CF     := "RE4"
     SD3->D3_TM     := "999"
     SD3->D3_CHAVE  := "E0"
     SD3->D3_LOCAL  := iif((cAliasSD3)->D3_CF=="RE3",(cAliasSD3)->D3_LOCAL,locproc)
     SD3->D3_LOCALIZ:= iif((cAliasSD3)->D3_CF=="RE3",(cAliasSD3)->D3_LOCALIZ,"PRODUCAO")
     SD3->D3_STSERV := ""
     SD3->D3_SEQCALC:= ""
    MSUNLOCK()
   // GERANDO A PERNA DE4 DO RE3 TRANSFORMADO
    RECLOCK("SD3",.T.)
     SD3->D3_FILIAL :=(cAliasSD3)->D3_FILIAL
     SD3->D3_TM     := "499"
     SD3->D3_COD    :=(cAliasSD3)->D3_COD
     SD3->D3_UM     :=(cAliasSD3)->D3_UM
     SD3->D3_QUANT  :=(cAliasSD3)->D3_QUANT
     SD3->D3_CF     :="DE4"
     SD3->D3_CONTA  :=(cAliasSD3)->D3_CONTA
     SD3->D3_LOCAL  :=iif((cAliasSD3)->D3_CF=="RE3",locproc,(cAliasSD3)->D3_LOCAL)
     SD3->D3_DOC    :=(cAliasSD3)->D3_DOC
     SD3->D3_GRUPO  :=(cAliasSD3)->D3_GRUPO
     SD3->D3_EMISSAO:=stod((cAliasSD3)->D3_EMISSAO)
     SD3->D3_NUMSEQ :=(cAliasSD3)->D3_NUMSEQ
     SD3->D3_TIPO   :=(cAliasSD3)->D3_TIPO
     SD3->D3_USUARIO:=userid
     SD3->D3_CHAVE  :="E9"
     SD3->D3_LOCALIZ:=""
    MSUNLOCK()
    
   END TRANSACTION
   dbSelectArea(cAliasSD3)
   DBSKIP()
Enddo
dbSelectArea(cAliasSD3)
dbCloseArea()
//zerar residuos de MOD
dbselectarea("SB2")       
DBSETORDER(1)
DBSEEK(XFILIAL("SB2")+"MOD") 
DO WHILE !EOF() .and. LEFT(SB2->B2_COD,3)=="MOD"
 IF LEFT(SB2->B2_COD,3)=="MOD"
  Reclock("SB2",.F.)
  SB2->B2_QATU:=0
  SB2->B2_VFIM1:=0
  SB2->B2_CM1:=0
  SB2->B2_QEMP:=0
  SB2->B2_CMFIM1:=0 
  SB2->(Msunlock())
 ENDIF
 DBSKIP()
ENDDO

Return
