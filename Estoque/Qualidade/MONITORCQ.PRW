/*
------------------------------------------------------------------------------
Desenvolvedor: Ricky Moraes - 10/07/2019
Solicitante..: Itamar Junior  (Gestor Ti)
Objetivo.....: Verificar e monitorar os apontamentos/materiais, liberando-os para a transferencia e uso no 
armazen 11.
------------------------------------------------------------------------------
*/ 
/*
#include "rwmake.ch"                        
#include "TOPCONN.CH"         
#include "Colors.ch"      
#INCLUDE "TBICONN.CH"  
#include "vkey.ch"
#include 'protheus.ch'
#include 'parmtype.ch'    
*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"


                 
User Function MONITORCQ() 		
Local cArqTrb//, cIndice1//, cIndice2, cIndice3

 
	Private oBrowse
	Private aRotina		:= MenuDef()
	Private cCadastro 	:= "Monitor Materiais - Controle de Qualidade"
	Private aCampos	:= {}, aSeek := {}, aFieFilter := {} //,aDados := {}, aValores := {} 
	// Define as legendas
	private aLegenda:= {{'BR_VERMELHO','Reprovado'},;
	{'BR_LARANJA','Aguardando CQ'	},;
	{'BR_VERDE' ,'Aprovado'}}			
	
	
	//Array contendo os campos da tabela temporária
	AAdd(aCampos,{"TR_DOC" 	, "C" , 09 , 0})
	AAdd(aCampos,{"TR_EMISSAO"   , "D" , TamSx3("D3_EMISSAO")[1], 0})	 
	AAdd(aCampos,{"TR_COD" , "C" , 15 , 0})
	AAdd(aCampos,{"TR_DESC", "C" , 50 , 0})
	AAdd(aCampos,{"TR_TIPO", "C" , 2 , 0})
	AAdd(aCampos,{"TR_QTD", "N" , 12 , 0})
	AAdd(aCampos,{"TR_END", "C" ,  20 , 0})
	AAdd(aCampos,{"TR_OPER", "C" ,20 , 0})
	AAdd(aCampos,{"TR_OBS", "C" ,  50 , 0})
	AAdd(aCampos,{"TR_CQ"  , "C" , 15 , 0})	 
	AAdd(aCampos,{"TR_CODCQ"  , "C" , 04 , 0})
	AAdd(aCampos,{"TR_CAUSA"  , "C" , 20 , 0})  
	AAdd(aCampos,{"TR_USERCQ"  , "C" , 20 , 0})
	AAdd(aCampos,{"TR_DTINSP"   , "D" , TamSx3("D3_EMISSAO")[1], 0})	 
	 
	
	CriarTRB() //criar tabela temp

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( "TRB" )
	oBrowse:SetDescription( cCadastro )
	oBrowse:SetSeek(.T.,aSeek)
	oBrowse:SetTemporary(.T.)
	oBrowse:SetLocate()
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetDBFFilter(.T.)
	oBrowse:SetFilterDefault("" ) //Exemplo de como inserir um filtro padrão >>> "TR_ST == 'A'"
	oBrowse:SetFieldFilter(aFieFilter)
	oBrowse:DisableDetails()  
		
	
	//Legenda da grade, é obrigatório carregar antes de montar as colunas
	oBrowse:AddLegend("SubStr(TR_CQ,1,2)=='Ap'","GREEN" 	,"Aprovado")
	oBrowse:AddLegend("SubStr(TR_CQ,1,2)=='Ag'","ORANGE"  	,"Aguardando CQ")
	oBrowse:AddLegend("SubStr(TR_CQ,1,2)=='Re'","RED"  	,"Reprovado")
	
	//Detalhes das colunas que serão exibidas
	oBrowse:SetColumns(MontaColunas("TR_EMISSAO"		,"Emissao"		,01,"@!",0,07,0))
	oBrowse:SetColumns(MontaColunas("TR_DOC"			,"Num.PA"		,02,"@!",1,07,0))
	oBrowse:SetColumns(MontaColunas("TR_QTD"  		,"Quant."	,03,"@E9999",1,04,0))
	oBrowse:SetColumns(MontaColunas("TR_COD"			,"Codigo"		,04,"@!",1,015,0))
	oBrowse:SetColumns(MontaColunas("TR_DESC"	  		,"Descricao"	,05,"@!",1,020,0))
	oBrowse:SetColumns(MontaColunas("TR_TIPO"			,"Tipo"	,06,"@!",1,02,0))
	oBrowse:SetColumns(MontaColunas("TR_END"  		,"Endereco"	,08,"",1,09,0))	
	oBrowse:SetColumns(MontaColunas("TR_OPER"  		,"Operador"	,09,"",1,010,0))
	oBrowse:SetColumns(MontaColunas("TR_OBS"  		,"Observacao"	,10,"@!",1,010,0))
	oBrowse:SetColumns(MontaColunas("TR_CQ"		,"Status CQ"	,11,"",1,09,0))
	oBrowse:SetColumns(MontaColunas("TR_USERCQ"		,"Usu.CQ"	,12,"@!",1,10,0))
	oBrowse:SetColumns(MontaColunas("TR_DTINSP","Dt.Inspec",13,"@!",0,07,0))	
	oBrowse:SetColumns(MontaColunas("TR_CODCQ"		,"CQ"	,14,"@!",2,03,0))	
	oBrowse:SetColumns(MontaColunas("TR_CAUSA"		,"Causa"	,15,"",1,10,0))
 
	
		
	                                                                              
 
	//Campos que irão compor o combo de pesquisa na tela principal
  //	Aadd(aSeek,{"Emissao"   , {{"","D",08,0, "TR_EMISSAO"   ,"@!"}}, 1, .T. } )
	Aadd(aSeek,{"Documento", {{"","C",09,0, "TR_DOC","@!"}}, 1, .T. } )
	Aadd(aSeek,{"Codigo" , {{"","C",15,0, "TR_COD" ,"@!"}}, 2, .T. } )
	
	//Campos que irão compor a tela de filtro
	Aadd(aFieFilter,{"TR_CQ"	, "Status"   , "C", 3, 0,"@!"})
	Aadd(aFieFilter,{"TR_COD"	, "Codigo", "C", 15, 0,"@!"})
	Aadd(aFieFilter,{"TR_EMISSAO"	, "Dt.Emissao" , "D", 08, 0,"@!"})
	Aadd(aFieFilter,{"TR_DTINSP"	, "Dt.Inspec" , "D", 08, 0,"@!"})

//Private bFiltraBrw := { || FilBrowse( "TRB" , @aIndex , @cFiltro ) } //Determina a Expressao do Filtro 
	
	
	oBrowse:Activate()
	If !Empty(cArqTrb)
		Ferase(cArqTrb+GetDBExtension())
		Ferase(cArqTrb+OrdBagExt())
		cArqTrb := ""
		TRB->(DbCloseArea())
		delTabTmp('TRB')
    	dbClearAll()
	Endif
	
	

    	
return(Nil)

Static Function CriarTRB()

	//Antes de criar a tabela, verificar se a mesma já foi aberta
	If (Select("TRB") <> 0)
		dbSelectArea("TRB")
		TRB->(dbCloseArea ())
	Endif
	
	//Criar tabela temporária
	cArqTrb   := CriaTrab(aCampos,.T.)
	//Criar e abrir a tabela
	dbUseArea(.T.,,cArqTrb,"TRB",Nil,.F.)
	//DbUseArea(.T.,,cArqTrab,cTemp,.F.,.F.)

	IndRegua( "TRB", cArqTrb, "TR_DOC")
	//Criacao de um Segundo Indice
	cCodInd2:=E_Create(cArqTrb,.F.)
	IndRegua( "TRB", cCodInd2, "TR_COD")
	//Criacao dos Indices na Tabela Temporaria
	SET INDEX TO (cArqTrb),(cCodInd2)
	
	//Monta Arquivo Temporario	
   MsgRun("Atualizando os Registros, Aguarde...",,{|| fMontaTRB()} )
	dbSelectArea("TRB")
	

	


return


 
Static Function MontaColunas(cCampo,cTitulo,nArrData,cPicture,nAlign,nSize,nDecimal)
	Local aColumn
	Local bData 	:= {||}
	Default nAlign 	:= 1
	Default nSize 	:= 10
	Default nDecimal:= 0
	Default nArrData:= 0
	
	
	
	If nArrData > 0
		bData := &("{||" + cCampo +"}") //&("{||oBrowse:DataArray[oBrowse:At(),"+STR(nArrData)+"]}")
	EndIf
	
	/* Array da coluna
	[n][01] Título da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] Máscara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Indica se permite a edição
	[n][09] Code-Block de validação da coluna após a edição
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execução do duplo clique
	[n][12] Variável a ser utilizada na edição (ReadVar)
	[n][13] Code-Block de execução do clique no header
	[n][14] Indica se a coluna está deletada
	[n][15] Indica se a coluna será exibida nos detalhes do Browse
	[n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não)
	*/
	aColumn := {cTitulo,bData,,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}
Return {aColumn}
 
Static Function MenuDef()
//	Local aArea		:= GetArea()
	Local aRotina 	:= {}

	AADD(aRotina, {"Atualizar"			, "U_AtuTRBCQ()"		, 0,1, 0, NIL })
	AADD(aRotina, {"Ver Inspecao"			, "U_DetalharCQ()"		, 0, 2, 0, NIL })
	AADD(aRotina, {"Legenda"			, "U_Legenda()"		, 0, 6, 0, NIL })

Return( aRotina )

User function Legenda()
	brwlegenda('Status Controle de Material','Legenda',aLegenda)
return

User function DetalharCQ()
    Local alCabec   := {" ","Data","Hora","Quant.","Documento","Inspetor","Cod.Def","Causa" }
    Local alTamanho := {}//{01,12,12,15,18,20,10} // tamanho de cada campo lancado manualmente
    LOCAL alDados   := CarTag()
    Local olLista   := Nil
    Local oDlg      := Nil
    Local llCancel := .F.
    Local oNAO   := LoadBitmap(GetResources(), "BR_VERMELHO")
	 Local oSIM   := LoadBitmap(GetResources(), "BR_VERDE")

    IF alDados[1,1]<>"-"
    DEFINE MSDIALOG oDlg FROM 0,0 TO 300,700 PIXEL TITLE "Inspeções Realizadas"
    olLista := TCBrowse():New( 035, 003,350,080,,alCabec,alTamanho,oDlg,,,,,{|| },,,,,,,.F.,,.T.,,.F.,,.T.,.T.)   
    olLista:SetArray(alDados)
//    olLista:bWhen:={||Len(alDados) > 0}
//    olLista:bLDblClick := {|| IIf(olLista:ColPos() == 1,alDados[olLista:nAt][1] := !alDados[olLista:nAt][1],)}
    olLista:bLine      := {|| { IIf(alDados [olLista:nAt][1]=='A',oSIM,oNAO) ,;     
                                StoD(alDados[olLista:nAt][2]),;
                                alDados[olLista:nAt][3],;
                                Transform(alDados[olLista:nAt][4],'@E 999,999.99'),;// alDados[olLista:nAt][4],;
                                alDados[olLista:nAt][5],;
                                alDados[olLista:nAt][6],;
                                alDados[olLista:nAt][7],;                                
                                alDados[olLista:nAt][8]}}
     oDlg:lCentered := .T.
     oDlg:Activate(,,,,,,EnchoiceBar(oDlg,{||llCancel := .F., oDlg:End()},{||llCancel := .T., oDlg:End()}))
    ENDIF

Return


STATIC FUNCTION CarTag()
    LOCAL qTMP := ""
    Local TEMP := "TEMP"     
    LOCAL alDados := {}
    Local nTotal:=0
         
     qTMP := " SELECT   ZTQ_FILIAL,ZTQ_DATA,ZTQ_HORA,ZTQ_COD,ZTQ_CQ,ZTQ_DOC,ZTQ_QUANT,ZTQ_CODCQ,ZTQ_USERCQ,ZTC_DESC " 
     qTMP += "  FROM ZTQ010 ZTQ "
     qTMP += " LEFT JOIN ZTC010 ZTC ON ZTQ_CODCQ=ZTC_COD AND ZTC.D_E_L_E_T_='' "
     qTMP += " WHERE ZTQ.D_E_L_E_T_ <> '*' "
     qTMP += " AND ZTQ_DOC = '" + alltrim(TR_DOC) + "'"
     qTMP += " AND ZTQ_COD = '" + alltrim(TR_COD) + "'	"
     qTMP += " ORDER BY ZTQ_DATA,ZTQ_HORA "
     
     DBUSEAREA( .T.,"TOPCONN",TcGenQry(,,qTMP),TEMP,.F.,.T. )
     Count To nTotal
     IF nTotal>0
     TEMP->(dbgotop())
     WHILE TEMP->(!Eof())    
        Aadd( alDados, {ZTQ_CQ,ZTQ_DATA,ZTQ_HORA,ZTQ_QUANT,ZTQ_DOC,ZTQ_USERCQ,ZTQ_CODCQ,ZTC_DESC})
        TEMP->( DbSkip( ) )
     END
     ELSE
   	   Aadd( alDados, {"-","-","-","-","-","-","-"})
//   	   Msginfo("Não existe inspeção cadastrada no Documento / Produto")
   	   MsgInfo('Não existem Inspeções <br><br> <font size="3" color="red"><b>REPROVADAS<b></font> <br><br>cadastradas no <b>Documento/Produto<b>')
	  Endif
     TEMP->( DbCloseArea() )

RETURN alDados 


User Function AtuTRBCQ()
//Local aBkpFiltro :=GetArea()

// TRB->(dbClearFilter())

 //LIMPA A TABELA
 /*
	While TRB->(!Eof())
	RecLocK("TRB", .F.)
	dbDelete()   
   MsUnlock() 
	TRB->(dbSkip())
	EndDo
*/
TRB->(dbClearFilter())
		TRB->(DbCloseArea())
		delTabTmp('TRB')
    	dbClearAll()
    	
    	CriarTRB() //criar tabela temp

   	
//		MsgRun("Atualizando Registros, Aguarde...",,{|| fMontaTRB()} )   

	//oBrowse:SetFilterDefault()		

//	oBrowse:Refresh()			  
return

              
Static Function fMontaTRB() 
//Local aArea := GetArea()
Local cAliasSD3ckPa := GetNextAlias()  

BeginSql Alias cAliasSD3ckPa    

  SELECT SD3.D3_COD,SD3.D3_EMISSAO,SD3.D3_DOC,SD3.D3_QUANT, SD3.D3_TIPO,SD3.D3_TM,C2_XEND,SD3.D3_NUMSEQ,
  SD3.D3_IDENT,SD3.D3_USUARIO,SD3.D3_XHORA,SD3.D3_OBSERVA,SD3.D3_XCQ,SD3.D3_XCODCQ,SD3.D3_XUSERCQ,ZTC_DESC,

  CASE D3_XCQ
   WHEN 'A' THEN
    ISNULL((SELECT   MAX(ZTQ_DATA)    FROM ZTQ010 ZTQ     
    WHERE ZTQ.D_E_L_E_T_ <> ''    AND ZTQ_DOC =  SD3.D3_DOC   AND ZTQ_COD = SD3.D3_COD ),SD3.D3_EMISSAO) 
	ELSE  
	 ISNULL((SELECT   MAX(ZTQ_DATA)    FROM ZTQ010 ZTQ     
    WHERE ZTQ.D_E_L_E_T_ <> ''    AND ZTQ_DOC =  SD3.D3_DOC   AND ZTQ_COD = SD3.D3_COD ),space(8))
	END AS DT_INSPCQ
  
  
  FROM %Table:SD3% SD3 
  LEFT JOIN SC2010 SC2 ON C2_FILIAL=SD3.D3_FILIAL AND SC2.D_E_L_E_T_='' AND C2_NUM+'01001'=SD3.D3_OP
  LEFT JOIN ZTC010 ZTC ON D3_XCODCQ=ZTC_COD AND ZTC.D_E_L_E_T_=''  AND ZTC_FILIAL=SD3.D3_FILIAL
  WHERE SD3.D3_FILIAL='01' 
  AND SD3.D_E_L_E_T_='' AND SD3.D3_CF IN ('PR0','PR1') AND SD3.D3_ESTORNO='' AND SD3.D3_EMISSAO>='20190728'
  AND D3_TIPO='PI'
 
EndSql 
dbSelectArea(cAliasSD3ckPa)
(cAliasSD3ckPa)->(dbgotop())


//ProcRegua(RecCount())
do while (cAliasSD3ckPa)->(!eof())
		If RecLock("TRB",.t.)
			TRB->TR_DOC:= (cAliasSD3ckPa)->D3_DOC
			TRB->TR_EMISSAO := StoD((cAliasSD3ckPa)->D3_EMISSAO)
			TRB->TR_COD:= (cAliasSD3ckPa)->D3_COD
			TRB->TR_DESC:= left(Posicione("SB1",1,XFILIAL("SB1")+(cAliasSD3ckPa)->D3_COD,"B1_XDESCNF"),50)
			TRB->TR_TIPO:= (cAliasSD3ckPa)->D3_TIPO
			TRB->TR_QTD:= (cAliasSD3ckPa)->D3_QUANT
			TRB->TR_OPER:= (cAliasSD3ckPa)->D3_USUARIO
			TRB->TR_OBS:= (cAliasSD3ckPa)->D3_OBSERVA
			TRB->TR_END:= (cAliasSD3ckPa)->C2_XEND
			IF (cAliasSD3ckPa)->D3_XCQ=="A"
				TRB->TR_CQ:=	"Aprovado"
			ELSEIF(cAliasSD3ckPa)->D3_XCQ=="R"
			 	TRB->TR_CQ:="Reprovado"
			ELSE
			   TRB->TR_CQ:="Aguardado CQ"
			ENDIF	 
							  
			TRB->TR_DTINSP:= StoD((cAliasSD3ckPa)->DT_INSPCQ)	
			TRB->TR_CODCQ:= (cAliasSD3ckPa)->D3_XCODCQ	
			TRB->TR_USERCQ:= (cAliasSD3ckPa)->D3_XUSERCQ	
			TRB->TR_CAUSA:= SUBSTR((cAliasSD3ckPa)->ZTC_DESC,1,20)
			MsUnLock()
		Endif
		(cAliasSD3ckPa)->(DBSKIP()) 
	enddo 
(cAliasSD3ckPa)->(dbCloseArea())
	
//RestArea(aArea)	
return

