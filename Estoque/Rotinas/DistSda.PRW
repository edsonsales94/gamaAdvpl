#include 'protheus.ch'
#include 'parmtype.ch'

user function DistSda()
Local aArea := GetArea()
Local cExprFilTop :="" 
Local aFixe :={}
Private cCadastro := "Itens nao Enderecados "
Private cAliasSDA := GetNextAlias()
Private pOpc
aCores 	:= {{'LEFT(D3_OBSERVA,1)== "R" ','ENABLE' },;  // Cores padroes do semaforo
            {'LEFT(D3_OBSERVA,1)<> "R" ','DISABLE' } }

aFixe:= {{"TIPO CF","D3_CF","C",3,"@!"},;
	     {"OBSERVACAO","D3_OBSERVA","C",20,"@!"},;
	      {"OP","D3_OP","C",12,"@!"},;
	      {"TM","D3_TM","C",3,"@!"},;
	      {"CODIGO","D3_COD","C",15,"@!"},;
	      {"QTDE","D3_QUANT","N",15,"@E 99,999,999.999999"},;
	      {"SEQUENCIA","D3_NUMSEQ","C",6,"@!"},;
	      {"DOCUMENTO","D3_DOC","C",9,"@!"},;
		 {"ENDERECO ","DESTINO","C",20,"@!"}}			
			

distSDA()
dbSelectArea("TRB")
aRotina   := {{"Pesquisar" ,"AXPESQUI"       ,0,1},;
         	 {"Distribuir Materiais" ,	"U_DsitSDA()"  ,0,3},;
			 {"Legenda" ,	"U_DistLEG()"   ,0,5}}
          
			 
mBrowse(06,01,22,75,"TRB",aFixe,,,,,aCores,,,,,,,,cExprFilTop )
dbclosearea("TRB")
RestArea(aArea)
Return

User Function DsitSDA()
 Local  _cLocDes := GETMV("MV_LOCPROC")
 dbSelectArea("TRB")
 dbgotop()
 do while !eof()
   if  LEN(ALLTRIM(TRB->DESTINO))>0
    u_fSd3265(3 , TRB->D3_COD , TRB->D3_NUMSEQ , TRB->D3_DOC , _cLocDes , TRB->DESTINO )
    RecLock("SDA") 
   endif
   dbSelectArea("TRB")
   TRB->(dbskip())
 enddo
 ALERT("Itens distribuidos com sucesso!!")
 
Return


User Function DistLEG()
BrwLegenda(cCadastro,"Legenda",{{"ENABLE","Requisicao para OP"},;
	                            {"DISABLE","Outras entradas no Proceso"}})
Return .T.

Static Function distSDA()
	BeginSql Alias "TRB"
	SELECT D3_CF,D3_OBSERVA,SUBSTRING(D3_OBSERVA,7,12) D3_OP,D3_TM,
	SD3.D3_COD,SD3.D3_NUMSEQ,SD3.D3_DOC,DESTINO=
	RTRIM(
	CASE
	WHEN LEFT(D3_OBSERVA,2)='RQ' THEN
	(SELECT ISNULL(C2_XEND,'') FROM %Table:SC2%  SC2 WHERE C2_FILIAL=DA_FILIAL AND LTRIM(RTRIM(C2_NUM+C2_ITEM+C2_SEQUEN))=SUBSTRING(D3_OBSERVA,7,11) AND C2_ITEMGRD='' AND SC2.%NotDel% )
	WHEN LEFT(D3_OBSERVA,2)='SC' THEN
	(SELECT DISTINCT CP_XLOCALI FROM %Table:SCP%  SCP WHERE CP_FILIAL=DA_FILIAL AND CP_NUM=SUBSTRING(D3_OBSERVA,6,6) AND CP_ITEM<>'00' AND CP_PRODUTO=SD3.D3_COD AND CP_LOCAL='11' AND SCP.%NotDel%  AND D3_QUANT=CP_QUANT)
	WHEN LEFT(D3_OBSERVA,2)='RA' THEN
	(SELECT DISTINCT CP_XLOCALI FROM %Table:SCP%  SCP1 WHERE CP_FILIAL=DA_FILIAL AND CP_NUM=SUBSTRING(D3_OBSERVA,6,6) AND CP_ITEM<>'00' AND CP_PRODUTO=SD3.D3_COD AND CP_LOCAL='11' AND SCP1.%NotDel% AND D3_QUANT=CP_QUANT)
	WHEN LEFT(D3_OBSERVA,3)='RET' THEN
	(SELECT DISTINCT CP_XLOCALI FROM %Table:SCP%  SCP1 WHERE CP_FILIAL=DA_FILIAL AND CP_NUM=SUBSTRING(D3_DOC,1,6) AND CP_ITEM<>'00' AND CP_PRODUTO=SD3.D3_COD AND CP_LOCAL='11' AND SCP1.%NotDel% AND D3_QUANT=CP_QUANT)
	WHEN LEFT(D3_OBSERVA,2)='BX' THEN 
     (SELECT DISTINCT CP_XLOCALI FROM %Table:SCP% SCP2 WHERE CP_FILIAL=DA_FILIAL AND CP_NUM=SUBSTRING(D3_DOC,1,6) AND CP_ITEM<>'00' AND CP_PRODUTO=SD3.D3_COD AND CP_LOCAL='11' AND SCP2.%NotDel% AND D3_QUANT=CP_QUANT)
	ELSE ''
	END),SD3.D3_QUANT
	FROM %Table:SDA%  SDA
	LEFT OUTER JOIN SD3010 SD3 ON D3_FILIAL=%xFilial:SD3%  AND  D3_NUMSEQ=DA_NUMSEQ AND D3_CHAVE='E0' AND D3_COD=DA_PRODUTO AND SD3.%NotDel%
	WHERE DA_FILIAL=%xFilial:SDA% AND DA_PRODUTO BETWEEN '' AND 'ZZZZZZZZZZZZZZZ' AND DA_LOCAL='20' AND DA_LOTECTL='' AND DA_SALDO>0 AND SDA.%NotDel%
	AND DA_ORIGEM='SD3' AND SD3.D3_CF='RE3'  ORDER BY SD3.D3_COD
	EndSql
	dbSelectArea("TRB")
	dbgotop()
	
Return()
