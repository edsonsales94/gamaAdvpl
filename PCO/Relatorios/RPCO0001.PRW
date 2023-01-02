#include 'protheus.ch'
#include 'parmtype.ch'

user function rpco0001()

	Local oReport

	Private cAliasQRY := "AK3"
	Private aRetCQ	:= {}
	Private cPerg	:= "RPCO01"
	pRIVATE cSqlinc,cSqlind
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//só aparece o totalizador se abrir os meses 08/04/16 por claudio solicitado por ezaquiel
	//caso o mes seja analitico o MV_PAR10 <> de branco só mostra os mes solicitado 08/04/16 por claudio solicitado por ezaquiel
	//12/04/16 correção dos totais por conta sintetica
	//19/04/16 Alterações solicitadas : Retirar CC dos detalhes dos lancamentos e corrigir totalizadores
	//28/04/16 criado o parametro filial de - ate para consolidar o realizado entre empresas solicitado por Julio-Sp
	//20/06/16 CORREÇÃO DOS TOTAIS
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := ReportDef()
	oReport:PrintDialog()

return

Static Function ReportDef()

	Local oReport
	Local oSection
	Local oCell, x, nA
	Local meses := {"Janeiro","Feveriro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}
	private sconta:=""

	ValidPerg(cPerg)

	oReport := TReport():New("RPCO0001","Orcado x Relizado",cPerg, {|oReport| ReportPrint(oReport)})

	oReport:SetLandScape()
	oReport:HideParamPage()
	oReport:PrintHeader(.F.,.F.)
	oReport:lEmptyLineExcel:=.F.
	Pergunte(oReport:uParam,.F.)

	if MV_PAR06==2
		for x=1 to 12
			meses[x] = meses[x]+" Orcado"
		next
	Endif

	oSection := TRSection():New(oReport,"Orcamento",{"AK3"}) //"Planilha de Orcamento"
	oSection2 := TRSection():New(oReport,"Lancamentos",{"CT2"}) //"Planilha de Orcamento"

	TRCell():New(oSection2,"CT2_CCC"  ,"CT2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_CCD"  ,"CT2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_DEBITO"  ,"CT2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_HIST"    ,"CT2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_DATA"    ,"CT2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_CREDIT"    ,"CT2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR"   ,"CT2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

	TRCell():New(oSection2,"CT2_VALOR02A"  ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR02B"  ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR02C"  ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR02"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

	TRCell():New(oSection2,"CT2_VALOR03A"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR03B"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR03C"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR03"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)

	TRCell():New(oSection2,"CT2_VALOR04A"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR04B"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR04C"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR04"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)

	TRCell():New(oSection2,"CT2_VALOR05A"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR05B"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR05C"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR05"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)

	TRCell():New(oSection2,"CT2_VALOR06A"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR06B"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR06C"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR06"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)

	TRCell():New(oSection2,"CT2_VALOR07A"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR07B"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR07C"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR07"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)

	TRCell():New(oSection2,"CT2_VALOR08A"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR08B"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR08C"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR08"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)

	TRCell():New(oSection2,"CT2_VALOR09A"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR09B"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR09C"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR09"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)

	TRCell():New(oSection2,"CT2_VALOR10A"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR10B"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR10C"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR10"  ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)

	TRCell():New(oSection2,"CT2_VALOR11A"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR11B"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR11C"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR11"  ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)

	TRCell():New(oSection2,"CT2_VALOR12A"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR12B"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR12C"   ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection2,"CT2_VALOR12"  ,""  ,"Valor",PesqPict("CT2","CT2_VALOR"),/*lPixel*/,/*{|| code-block de impressao }*/)
	for x:=2 to 12
		oSection2:Cell("CT2_VALOR"+strzero(x,2)+"A"):Hide(); oSection2:Cell("CT2_VALOR"+strzero(x,2)+"B"):Hide(); oSection2:Cell("CT2_VALOR"+strzero(x,2)+"C"):Hide()
		oSection2:Cell("CT2_VALOR"+strzero(x,2)+"A"):HideHeader(); oSection2:Cell("CT2_VALOR"+strzero(x,2)+"B"):HideHeader(); oSection2:Cell("CT2_VALOR"+strzero(x,2)+"C"):HideHeader()
	next

	oSection:SetHeaderBreak(.F.)
	oSection:SetHeaderPage(.F.)
	oSection2:Cell("CT2_CCC"):Hide()
	oSection2:Cell("CT2_CCD"):Hide()
	oSection2:Cell("CT2_CREDIT"):Hide()
	oSection2:Cell("CT2_CCC"):HideHeader()
	oSection2:Cell("CT2_CCD"):HideHeader()
	oSection2:Cell("CT2_CREDIT"):HideHeader()
	oSection2:Cell("CT2_DEBITO"):HideHeader()
	oSection2:Cell("CT2_HIST"):HideHeader()
	oSection2:Cell("CT2_DATA"):HideHeader()
	oSection2:Cell("CT2_VALOR"):HideHeader()
	for x:=2 to 12
		oSection2:Cell("CT2_VALOR"+strzero(x,2)):HideHeader()
	next

	oSection2:SetHeaderPage()  //imprim a linha de cabecalho no topo da pagina
	oSection2:lHeaderVisible := .F.
	oSection2:SetLineStyle(.F.)
	oSection2:SetLinesBefore(0)
	oSection2:SetBorder('')
	oSection2:SetBorder('',,,.T.)
	oSection2:ACELL[1]:OHBRDBOTTOM:NLINESTYLE:=0    //borda do cabecalho
	oSection2:ACELL[2]:OHBRDBOTTOM:NLINESTYLE:=0

	//IF MV_PAR07==1
	TRCell():New(oSection,"AK2_CC"    ,"AK2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"DESCCC"    ,"","Centro de Custo",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	//ENDIF
	TRCell():New(oSection,"AK3_CO"    ,"AK3",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection,"AK3_DESCRI","AK3")
	TRCell():New(oSection,"AK3_NIVEL" ,"AK3")

	//if  val(SUBSTR(MV_PAR10,5,2))==1 .OR. LEN(ALLTRIM(MV_PAR10))==0
	TRCell():New(oSection,"VALOR_ORC01" ,"",meses[1] ,PesqPict("AK2","AK2_VALOR"),,,{|| aRetStq((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES01,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
	if MV_PAR06==2
		TRCell():New(oSection,"VALOR_REAL01" ,"","Realizado"   ,PesqPict("AK2","AK2_VALOR"),,,     {|| aRetCT2((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES01,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		TRCell():New(oSection,"DIF01" ,"","Diferença R$"       ,PesqPict("AK2","AK2_VALOR"),,,     {|| aRetDif((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES01,1,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		TRCell():New(oSection,"VAR01" ,"","Variação %"         ,PesqPict("AK2","AK2_VALOR"),,,     {|| aRetDif((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES01,2,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		if LEN(ALLTRIM(MV_PAR10))==0
			oSection:Cell("VAR01"):SetBorder(4,2)
		endif
	endif
	//endif

	//if  val(SUBSTR(MV_PAR10,5,2))==2 .OR. LEN(ALLTRIM(MV_PAR10))==0
	TRCell():New(oSection,"VALOR_ORC02" ,"",meses[2] ,PesqPict("AK2","AK2_VALOR"),,,{|| aRetStq((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES02,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
	if MV_PAR06==2
		TRCell():New(oSection,"VALOR_REAL02" ,"","Realizado",PesqPict("AK2","AK2_VALOR"),,,        {|| aRetCT2((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES02,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		TRCell():New(oSection,"DIF02" ,"","Diferença R$"       ,PesqPict("AK2","AK2_VALOR"),,,     {|| aRetDif((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES02,1,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		TRCell():New(oSection,"VAR02" ,"","Variação %"       ,PesqPict("AK2","AK2_VALOR"),,,       {|| aRetDif((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES02,2,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		if LEN(ALLTRIM(MV_PAR10))==0
			oSection:Cell("VAR02"):SetBorder(4,2)
		endif
	endif
	//endif

	//if  val(SUBSTR(MV_PAR10,5,2))==3 .OR. LEN(ALLTRIM(MV_PAR10))==0
	TRCell():New(oSection,"VALOR_ORC03" ,"",meses[3] ,PesqPict("AK2","AK2_VALOR"),,,{|| aRetStq((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES03,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
	if MV_PAR06==2
		TRCell():New(oSection,"VALOR_REAL03" ,"","Realizado",PesqPict("AK2","AK2_VALOR"),,,        {|| aRetCT2((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES03,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		TRCell():New(oSection,"DIF03" ,"","Diferença R$"       ,PesqPict("AK2","AK2_VALOR"),,,     {|| aRetDif((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES03,1,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		TRCell():New(oSection,"VAR03" ,"","Variação %"       ,PesqPict("AK2","AK2_VALOR"),,,       {|| aRetDif((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES03,2,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		if LEN(ALLTRIM(MV_PAR10))==0
			oSection:Cell("VAR03"):SetBorder(4,2)
		endif
	endif
	//endif

	//if  val(SUBSTR(MV_PAR10,5,2))==4 .OR. LEN(ALLTRIM(MV_PAR10))==0
	TRCell():New(oSection,"VALOR_ORC04" ,"",meses[4] ,PesqPict("AK2","AK2_VALOR"),,,{|| aRetStq((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES04,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
	if MV_PAR06==2
		TRCell():New(oSection,"VALOR_REAL04" ,"","Realizado",PesqPict("AK2","AK2_VALOR"),,,        {|| aRetCT2((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES04,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		TRCell():New(oSection,"DIF04" ,"","Diferença R$"       ,PesqPict("AK2","AK2_VALOR"),,,     {|| aRetDif((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES04,1,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		TRCell():New(oSection,"VAR04" ,"","Variação %"       ,PesqPict("AK2","AK2_VALOR"),,,       {|| aRetDif((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES04,2,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		if LEN(ALLTRIM(MV_PAR10))==0
			oSection:Cell("VAR04"):SetBorder(4,2)
		endif
	endif
	//endif

	//if  val(SUBSTR(MV_PAR10,5,2))==5 .OR. LEN(ALLTRIM(MV_PAR10))==0
	TRCell():New(oSection,"VALOR_ORC05" ,"",meses[5] ,PesqPict("AK2","AK2_VALOR"),,,{|| aRetStq((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES05,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
	if MV_PAR06==2
		TRCell():New(oSection,"VALOR_REAL05" ,"","Realizado",PesqPict("AK2","AK2_VALOR"),,,        {|| aRetCT2((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES05,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		TRCell():New(oSection,"DIF05" ,"","Diferença R$"       ,PesqPict("AK2","AK2_VALOR"),,,     {|| aRetDif((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES05,1,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		TRCell():New(oSection,"VAR05" ,"","Variação %"       ,PesqPict("AK2","AK2_VALOR"),,,       {|| aRetDif((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES05,2,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		if LEN(ALLTRIM(MV_PAR10))==0
			oSection:Cell("VAR05"):SetBorder(4,2)
		endif
	endif
	//endif

	//if  val(SUBSTR(MV_PAR10,5,2))==6 .OR. LEN(ALLTRIM(MV_PAR10))==0
	TRCell():New(oSection,"VALOR_ORC06" ,"",meses[6] ,PesqPict("AK2","AK2_VALOR"),,,{|| aRetStq((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES06,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
	if MV_PAR06==2
		TRCell():New(oSection,"VALOR_REAL06" ,"","Realizado",PesqPict("AK2","AK2_VALOR"),,,        {|| aRetCT2((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES06,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		TRCell():New(oSection,"DIF06" ,"","Diferença R$"       ,PesqPict("AK2","AK2_VALOR"),,,     {|| aRetDif((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES06,1,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		TRCell():New(oSection,"VAR06" ,"","Variação %"       ,PesqPict("AK2","AK2_VALOR"),,,       {|| aRetDif((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES06,2,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		if LEN(ALLTRIM(MV_PAR10))==0
			oSection:Cell("VAR06"):SetBorder(4,2)
		endif
	endif
	//endif

	//if  val(SUBSTR(MV_PAR10,5,2))==7 .OR. LEN(ALLTRIM(MV_PAR10))==0
	TRCell():New(oSection,"VALOR_ORC07" ,"",meses[7] ,PesqPict("AK2","AK2_VALOR"),,,{|| aRetStq((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES07,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
	if MV_PAR06==2
		TRCell():New(oSection,"VALOR_REAL07" ,"","Realizado",PesqPict("AK2","AK2_VALOR"),,,        {|| aRetCT2((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES07,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		TRCell():New(oSection,"DIF07" ,"","Diferença R$"       ,PesqPict("AK2","AK2_VALOR"),,,     {|| aRetDif((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES07,1,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		TRCell():New(oSection,"VAR07" ,"","Variação %"       ,PesqPict("AK2","AK2_VALOR"),,,       {|| aRetDif((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES07,2,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		if LEN(ALLTRIM(MV_PAR10))==0
			oSection:Cell("VAR07"):SetBorder(4,2)
		endif
	endif
	//endif

	//if  val(SUBSTR(MV_PAR10,5,2))==8 .OR. LEN(ALLTRIM(MV_PAR10))==0
	TRCell():New(oSection,"VALOR_ORC08" ,"",meses[8] ,PesqPict("AK2","AK2_VALOR"),,,{|| aRetStq((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES08,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
	if MV_PAR06==2
		TRCell():New(oSection,"VALOR_REAL08" ,"","Realizado",PesqPict("AK2","AK2_VALOR"),,,        {|| aRetCT2((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES08,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		TRCell():New(oSection,"DIF08" ,"","Diferença R$"       ,PesqPict("AK2","AK2_VALOR"),,,     {|| aRetDif((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES08,1,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		TRCell():New(oSection,"VAR08" ,"","Variação %"       ,PesqPict("AK2","AK2_VALOR"),,,       {|| aRetDif((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES08,2,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		if LEN(ALLTRIM(MV_PAR10))==0
			oSection:Cell("VAR08"):SetBorder(4,2)
		endif
	endif
	//endif

	//if  val(SUBSTR(MV_PAR10,5,2))==9 .OR. LEN(ALLTRIM(MV_PAR10))==0
	TRCell():New(oSection,"VALOR_ORC09" ,"",meses[9] ,PesqPict("AK2","AK2_VALOR"),,,{|| aRetStq((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES09,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
	if MV_PAR06==2
		TRCell():New(oSection,"VALOR_REAL09" ,"","Realizado",PesqPict("AK2","AK2_VALOR"),,,        {|| aRetCT2((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES09,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		TRCell():New(oSection,"DIF09" ,"","Diferença R$"       ,PesqPict("AK2","AK2_VALOR"),,,     {|| aRetDif((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES09,1,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		TRCell():New(oSection,"VAR09" ,"","Variação %"       ,PesqPict("AK2","AK2_VALOR"),,,       {|| aRetDif((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES09,2,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		if LEN(ALLTRIM(MV_PAR10))==0
			oSection:Cell("VAR09"):SetBorder(4,2)
		endif
	endif
	//endif

	//if  val(SUBSTR(MV_PAR10,5,2))==10 .OR. LEN(ALLTRIM(MV_PAR10))==0
	TRCell():New(oSection,"VALOR_ORC10" ,"",meses[10] ,PesqPict("AK2","AK2_VALOR"),,,{|| aRetStq((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES10,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
	if MV_PAR06==2
		TRCell():New(oSection,"VALOR_REAL10" ,"","Realizado",PesqPict("AK2","AK2_VALOR"),,,        {|| aRetCT2((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES10,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		TRCell():New(oSection,"DIF10" ,"","Diferença R$"       ,PesqPict("AK2","AK2_VALOR"),,,     {|| aRetDif((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES10,1,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		TRCell():New(oSection,"VAR10" ,"","Variação %"       ,PesqPict("AK2","AK2_VALOR"),,,       {|| aRetDif((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES10,2,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		if LEN(ALLTRIM(MV_PAR10))==0
			oSection:Cell("VAR10"):SetBorder(4,2)
		endif
	endif
	//endif

	//if  val(SUBSTR(MV_PAR10,5,2))==11 .OR. LEN(ALLTRIM(MV_PAR10))==0
	TRCell():New(oSection,"VALOR_ORC11" ,"",meses[11] ,PesqPict("AK2","AK2_VALOR"),,,{|| aRetStq((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES11,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
	if MV_PAR06==2
		TRCell():New(oSection,"VALOR_REAL11" ,"","Realizado",PesqPict("AK2","AK2_VALOR"),,,        {|| aRetCT2((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES11,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		TRCell():New(oSection,"DIF11" ,"","Diferença R$"       ,PesqPict("AK2","AK2_VALOR"),,,     {|| aRetDif((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES11,1,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		TRCell():New(oSection,"VAR11" ,"","Variação %"       ,PesqPict("AK2","AK2_VALOR"),,,       {|| aRetDif((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES11,2,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		if LEN(ALLTRIM(MV_PAR10))==0
			oSection:Cell("VAR11"):SetBorder(4,2)
		endif
	endif
	//endif

	//if  val(SUBSTR(MV_PAR10,5,2))==12 .OR. LEN(ALLTRIM(MV_PAR10))==0
	TRCell():New(oSection,"VALOR_ORC12" ,"",meses[12] ,PesqPict("AK2","AK2_VALOR"),,,{|| aRetStq((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES12,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
	if MV_PAR06==2
		TRCell():New(oSection,"VALOR_REAL12" ,"","Realizado",PesqPict("AK2","AK2_VALOR"),,,        {|| aRetCT2((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES12,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		TRCell():New(oSection,"DIF12" ,"","Diferença R$"       ,PesqPict("AK2","AK2_VALOR"),,,     {|| aRetDif((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES12,1,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		TRCell():New(oSection,"VAR12" ,"","Variação %"       ,PesqPict("AK2","AK2_VALOR"),,,       {|| aRetDif((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES12,2,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		if LEN(ALLTRIM(MV_PAR10))==0
			oSection:Cell("VAR12"):SetBorder(4,2)
		endif
	endif
	//endif
	//if LEN(ALLTRIM(MV_PAR10))==0
	TRCell():New(oSection,"TOTALO" ,"","Total Orcado",PesqPict("AK2","AK2_VALOR"),,,            {|| aRetTot((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
	if MV_PAR06==2
		TRCell():New(oSection,"TOTALR" ,"","Total Realizado",PesqPict("AK2","AK2_VALOR"),,,            {|| aRetTotCT2((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,12,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		TRCell():New(oSection,"DIF13" ,"","Diferença R$"       ,PesqPict("AK2","AK2_VALOR"),,,     {|| aRetDif((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES13,1,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
		TRCell():New(oSection,"VAR13" ,"","Variação %"       ,PesqPict("AK2","AK2_VALOR"),,,       {|| aRetDif((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->MES13,2,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)})
	endif
	//endif

	oBreak2 := TRBreak():New(oSection,{ || oSection:Cell('AK2_CC'):uPrint},"",.F.)
	TRFunction():New(oSection:Cell('AK3_CO')       ,, 'COUNT',oBreak2 ,,,,.F.,.F.)
	//if  val(SUBSTR(MV_PAR10,5,2))==1 .OR. LEN(ALLTRIM(MV_PAR10))==0
	TRFunction():New(oSection:Cell('VALOR_ORC01') ,'FORC01', 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('VALOR_ORC01'):uPrint,0)},.F.,.F.)
	//endif
	//if  val(SUBSTR(MV_PAR10,5,2))==2 .OR. LEN(ALLTRIM(MV_PAR10))==0
	TRFunction():New(oSection:Cell('VALOR_ORC02') ,'FORC02', 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('VALOR_ORC02'):uPrint,0)},.F.,.F.)
	//endif
	//if  val(SUBSTR(MV_PAR10,5,2))==3 .OR. LEN(ALLTRIM(MV_PAR10))==0
	TRFunction():New(oSection:Cell('VALOR_ORC03') ,'FORC03', 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('VALOR_ORC03'):uPrint,0)},.F.,.F.)
	//endif
	//if  val(SUBSTR(MV_PAR10,5,2))==4 .OR. LEN(ALLTRIM(MV_PAR10))==0
	TRFunction():New(oSection:Cell('VALOR_ORC04') ,'FORC04', 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('VALOR_ORC04'):uPrint,0)},.F.,.F.)
	//endif
	//if  val(SUBSTR(MV_PAR10,5,2))==5 .OR. LEN(ALLTRIM(MV_PAR10))==0
	TRFunction():New(oSection:Cell('VALOR_ORC05') ,'FORC05', 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('VALOR_ORC05'):uPrint,0)},.F.,.F.)
	//endif
	//if  val(SUBSTR(MV_PAR10,5,2))==6 .OR. LEN(ALLTRIM(MV_PAR10))==0
	TRFunction():New(oSection:Cell('VALOR_ORC06') ,'FORC06', 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('VALOR_ORC06'):uPrint,0)},.F.,.F.)
	//endif
	//if  val(SUBSTR(MV_PAR10,5,2))==7 .OR. LEN(ALLTRIM(MV_PAR10))==0
	TRFunction():New(oSection:Cell('VALOR_ORC07') ,'FORC07', 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('VALOR_ORC07'):uPrint,0)},.F.,.F.)
	//endif
	//if  val(SUBSTR(MV_PAR10,5,2))==8 .OR. LEN(ALLTRIM(MV_PAR10))==0
	TRFunction():New(oSection:Cell('VALOR_ORC08') ,'FORC08', 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('VALOR_ORC08'):uPrint,0)},.F.,.F.)
	//endif
	//if  val(SUBSTR(MV_PAR10,5,2))==9 .OR. LEN(ALLTRIM(MV_PAR10))==0
	TRFunction():New(oSection:Cell('VALOR_ORC09') ,'FORC09', 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('VALOR_ORC09'):uPrint,0)},.F.,.F.)
	//endif
	//if  val(SUBSTR(MV_PAR10,5,2))==10 .OR. LEN(ALLTRIM(MV_PAR10))==0
	TRFunction():New(oSection:Cell('VALOR_ORC10') ,'FORC10', 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('VALOR_ORC10'):uPrint,0)},.F.,.F.)
	//endif
	//if  val(SUBSTR(MV_PAR10,5,2))==11 .OR. LEN(ALLTRIM(MV_PAR10))==0
	TRFunction():New(oSection:Cell('VALOR_ORC11') ,'FORC11', 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('VALOR_ORC11'):uPrint,0)},.F.,.F.)
	//endif
	//if  val(SUBSTR(MV_PAR10,5,2))==12 .OR. LEN(ALLTRIM(MV_PAR10))==0
	TRFunction():New(oSection:Cell('VALOR_ORC12') ,'FORC12', 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('VALOR_ORC12'):uPrint,0)},.F.,.F.)
	//endif

	if MV_PAR06==2
		//if  val(SUBSTR(MV_PAR10,5,2))==1 .OR. LEN(ALLTRIM(MV_PAR10))==0
		TRFunction():New(oSection:Cell('VALOR_REAL01'),, 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('VALOR_REAL01'):uPrint,0)},.F.,.F.)
		TRFunction():New(oSection:Cell('DIF01')       ,'FDIF01', 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('DIF01'):uPrint,0)},.F.,.F.)
		TRFunction():New(oSection:Cell('VAR01')       ,, 'ONPRINT',oBreak2 ,,,{|| oSection:GetFunction("FDIF01"):uLastValue / oSection:GetFunction("FORC01"):uLastValue },.F.,.F.)
		//endif
		//if  val(SUBSTR(MV_PAR10,5,2))==2 .OR. LEN(ALLTRIM(MV_PAR10))==0
		TRFunction():New(oSection:Cell('VALOR_REAL02'),, 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('VALOR_REAL02'):uPrint,0)},.F.,.F.)
		TRFunction():New(oSection:Cell('DIF02')       ,'FDIF02', 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('DIF02'):uPrint,0)},.F.,.F.)
		TRFunction():New(oSection:Cell('VAR02')       ,, 'ONPRINT',oBreak2 ,,,{|| oSection:GetFunction("FDIF02"):uLastValue / oSection:GetFunction("FORC02"):uLastValue },.F.,.F.)
		//endif
		//if  val(SUBSTR(MV_PAR10,5,2))==3 .OR. LEN(ALLTRIM(MV_PAR10))==0
		TRFunction():New(oSection:Cell('VALOR_REAL03'),, 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('VALOR_REAL03'):uPrint,0)},.F.,.F.)
		TRFunction():New(oSection:Cell('DIF03')       ,'FDIF03', 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('DIF03'):uPrint,0)},.F.,.F.)
		TRFunction():New(oSection:Cell('VAR03')       ,, 'ONPRINT',oBreak2 ,,,{|| oSection:GetFunction("FDIF03"):uLastValue / oSection:GetFunction("FORC03"):uLastValue },.F.,.F.)
		//endif
		//if  val(SUBSTR(MV_PAR10,5,2))==4 .OR. LEN(ALLTRIM(MV_PAR10))==0
		TRFunction():New(oSection:Cell('VALOR_REAL04'),, 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('VALOR_REAL04'):uPrint,0)},.F.,.F.)
		TRFunction():New(oSection:Cell('DIF04')       ,'FDIF04', 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('DIF04'):uPrint,0)},.F.,.F.)
		TRFunction():New(oSection:Cell('VAR04')       ,, 'ONPRINT',oBreak2 ,,,{|| oSection:GetFunction("FDIF04"):uLastValue / oSection:GetFunction("FORC04"):uLastValue },.F.,.F.)
		//endif
		//if  val(SUBSTR(MV_PAR10,5,2))==5 .OR. LEN(ALLTRIM(MV_PAR10))==0
		TRFunction():New(oSection:Cell('VALOR_REAL05'),, 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('VALOR_REAL05'):uPrint,0)},.F.,.F.)
		TRFunction():New(oSection:Cell('DIF05')       ,'FDIF05', 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('DIF05'):uPrint,0)},.F.,.F.)
		TRFunction():New(oSection:Cell('VAR05')       ,, 'ONPRINT',oBreak2 ,,,{|| oSection:GetFunction("FDIF05"):uLastValue / oSection:GetFunction("FORC05"):uLastValue },.F.,.F.)
		//endif
		//if  val(SUBSTR(MV_PAR10,5,2))==6 .OR. LEN(ALLTRIM(MV_PAR10))==0
		TRFunction():New(oSection:Cell('VALOR_REAL06'),, 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('VALOR_REAL06'):uPrint,0)},.F.,.F.)
		TRFunction():New(oSection:Cell('DIF06')       ,'FDIF06', 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('DIF06'):uPrint,0)},.F.,.F.)
		TRFunction():New(oSection:Cell('VAR06')       ,, 'ONPRINT',oBreak2 ,,,{|| oSection:GetFunction("FDIF06"):uLastValue / oSection:GetFunction("FORC06"):uLastValue },.F.,.F.)
		//endif
		//if  val(SUBSTR(MV_PAR10,5,2))==7 .OR. LEN(ALLTRIM(MV_PAR10))==0
		TRFunction():New(oSection:Cell('VALOR_REAL07'),, 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('VALOR_REAL07'):uPrint,0)},.F.,.F.)
		TRFunction():New(oSection:Cell('DIF07')       ,'FDIF07', 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('DIF07'):uPrint,0)},.F.,.F.)
		TRFunction():New(oSection:Cell('VAR07')       ,, 'ONPRINT',oBreak2 ,,,{|| oSection:GetFunction("FDIF07"):uLastValue / oSection:GetFunction("FORC07"):uLastValue },.F.,.F.)
		//endif
		//if  val(SUBSTR(MV_PAR10,5,2))==8 .OR. LEN(ALLTRIM(MV_PAR10))==0
		TRFunction():New(oSection:Cell('VALOR_REAL08'),, 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('VALOR_REAL08'):uPrint,0)},.F.,.F.)
		TRFunction():New(oSection:Cell('DIF08')       ,'FDIF08', 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('DIF08'):uPrint,0)},.F.,.F.)
		TRFunction():New(oSection:Cell('VAR08')       ,, 'ONPRINT',oBreak2 ,,,{|| oSection:GetFunction("FDIF08"):uLastValue / oSection:GetFunction("FORC08"):uLastValue },.F.,.F.)
		//endif
		//if  val(SUBSTR(MV_PAR10,5,2))==9 .OR. LEN(ALLTRIM(MV_PAR10))==0
		TRFunction():New(oSection:Cell('VALOR_REAL09'),, 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('VALOR_REAL09'):uPrint,0)},.F.,.F.)
		TRFunction():New(oSection:Cell('DIF09')       ,'FDIF09', 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('DIF09'):uPrint,0)},.F.,.F.)
		TRFunction():New(oSection:Cell('VAR09')       ,, 'ONPRINT',oBreak2 ,,,{|| oSection:GetFunction("FDIF09"):uLastValue / oSection:GetFunction("FORC09"):uLastValue },.F.,.F.)
		//endif
		//if  val(SUBSTR(MV_PAR10,5,2))==10 .OR. LEN(ALLTRIM(MV_PAR10))==0
		TRFunction():New(oSection:Cell('VALOR_REAL10'),, 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('VALOR_REAL10'):uPrint,0)},.F.,.F.)
		TRFunction():New(oSection:Cell('DIF10')       ,'FDIF10', 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('DIF10'):uPrint,0)},.F.,.F.)
		TRFunction():New(oSection:Cell('VAR10')       ,, 'ONPRINT',oBreak2 ,,,{|| oSection:GetFunction("FDIF10"):uLastValue / oSection:GetFunction("FORC10"):uLastValue },.F.,.F.)
		//endif
		//if  val(SUBSTR(MV_PAR10,5,2))==11 .OR. LEN(ALLTRIM(MV_PAR10))==0
		TRFunction():New(oSection:Cell('VALOR_REAL11'),, 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('VALOR_REAL11'):uPrint,0)},.F.,.F.)
		TRFunction():New(oSection:Cell('DIF11')       ,'FDIF11', 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('DIF11'):uPrint,0)},.F.,.F.)
		TRFunction():New(oSection:Cell('VAR11')       ,, 'ONPRINT',oBreak2 ,,,{|| oSection:GetFunction("FDIF11"):uLastValue / oSection:GetFunction("FORC11"):uLastValue },.F.,.F.)
		//endif
		//if  val(SUBSTR(MV_PAR10,5,2))==12 .OR. LEN(ALLTRIM(MV_PAR10))==0
		TRFunction():New(oSection:Cell('VALOR_REAL12'),, 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('VALOR_REAL12'):uPrint,0)},.F.,.F.)
		TRFunction():New(oSection:Cell('DIF12')       ,'FDIF12', 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell('DIF12'):uPrint,0)},.F.,.F.)
		TRFunction():New(oSection:Cell('VAR12')       ,, 'ONPRINT',oBreak2 ,,,{|| oSection:GetFunction("FDIF12"):uLastValue / oSection:GetFunction("FORC12"):uLastValue },.F.,.F.)
		//endif

	Endif

	//if LEN(ALLTRIM(MV_PAR10))==0   //só aparece o totalizador se abrir os meses 08/04/16 por claudio solicitado por ezaquiel
	TRFunction():New(oSection:Cell("TOTALO")   ,'FTOTALO', 'SUM',oBreak2  ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell("TOTALO"):uPrint,0)},.F.,.F.)
	if MV_PAR06==2
		TRFunction():New(oSection:Cell("TOTALR")  ,, 'SUM',oBreak2 ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell("TOTALR"):uPrint,0)},.F.,.F.)
		TRFunction():New(oSection:Cell("DIF13")  ,'FDIF13', 'SUM',oBreak2  ,,,{|| iif(len(alltrim(oSection:Cell('AK3_CO'):uPrint))==7,oSection:Cell("DIF13"):uPrint,0)},.F.,.F.)
		TRFunction():New(oSection:Cell('VAR13')       ,, 'ONPRINT',oBreak2 ,,,{|| oSection:GetFunction("FDIF13"):uLastValue / oSection:GetFunction("FTOTALO"):uLastValue },.F.,.F.)
	endif
	//endif

	oSection:Cell("AK3_NIVEL"):Hide()
	oSection:Cell("AK3_NIVEL"):HideHeader()

Return(oReport)

Static Function ReportPrint(oReport)

	Local oSection  := oReport:Section(1)
	Local osection2 := oReport:Section(2)
	//Local oBreak1   := oSection:ABREAK[1]
	Local oBreak2   := oSection:ABREAK[1]
	Local cAliasCT2a, x

	//oBreak:= TRBreak():New(oSection,oSection:Cell("BF_LOCAL"),Nil,.F.,,.T.)

	MakeSqlExpr(oReport:uParam)

	cSqlinc := "%"+alltrim(MV_PAR14)+"%"
	cSqlind := "%"+alltrim(MV_PAR15)+"%"
	IF LEN(alltrim(cSqlinc))<7 .AND. LEN(alltrim(cSqlind))>7    
	 ALERT("Para usar faixa de centro de cutso deve-se preencher a faixa cc credito!")
	 Return NIL
	ENDIF
	IF  LEN(alltrim(cSqlind))<7 .AND. LEN(alltrim(cSqlinc))>7    
	 ALERT("Para usar faixa de centro de cutso deve-se preencher a faixa cc debito!")
	 Return NIL
	ENDIF
	if LEN(alltrim(cSqlinc))>7
	   if alltrim(mv_par08)<>alltrim(mv_par09)
	      ALERT("Para usar faixa de centro de cutso deve-se preencher somente um CC por vez pergunta 8 e 9!")
   	    Return NIL
	   endif  
	endif 
	//if len(alltrim(cSqlinc))==0 .or.  len(alltrim(cSqlind))
	//	ALERT("Para que o relatorio seja processado corretamente é necessario que as faixa de CC debito e credito sejam informadas!!!")
	//	Return nil
	//Endif

	//if alltrim(MV_PAR08)==alltrim(MV_PAR09) .or.  len(alltrim(MV_PAR08+MV_PAR09))==0
	//	ALERT("Para que o relatorio seja processado corretamente é necessario que seja informada apenas um CC por vez!!!")
	//	Return nil
	//Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query do relatório da secao 1                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):BeginQuery()

	cAliasQRY := GetNextAlias()

	IF MV_PAR07==2
		BeginSql Alias cAliasQRY
		SELECT '' AS AK2_CC, AK3_ORCAME,AK3_VERSAO,AK3_CO,AK3_DESCRI,AK3_NIVEL,
		1  AS MES01,2  AS MES02,3  AS MES03,4  AS MES04,5  AS MES05,
		6  AS MES06,7  AS MES07,8  AS MES08,9  AS MES09,10 AS MES10,
		11 AS MES11,12 AS MES12,13 MES13
		FROM %table:AK3% AK3
		WHERE AK3_FILIAL= %xFilial:AK3% AND AK3_ORCAME= %Exp:mv_par01% AND AK3_VERSAO= %Exp:mv_par02% AND
		AK3_CO>=%Exp:mv_par03%  AND AK3_CO<=%Exp:mv_par04%   AND
		LEN(AK3_CO)>5 AND AK3_CO<>%Exp:mv_par01% AND
		AK3.%NotDel% AND AK3_CO NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100')
		ORDER BY AK3_CO,AK2_CC
		EndSql
	ELSE
		BeginSql Alias cAliasQRY
		SELECT DISTINCT CTT_CUSTO AK2_CC ,AK3_ORCAME ,AK3_VERSAO ,AK3_CO,AK3_DESCRI,AK3_NIVEL,
		1  AS MES01,2  AS MES02,3  AS MES03,4  AS MES04,5  AS MES05,
		6  AS MES06,7  AS MES07,8  AS MES08,9  AS MES09,10 AS MES10,
		11 AS MES11,12 AS MES12,13 AS MES13
		FROM %table:CTT% AK2,%table:AK3% AS AK3TMP
		
		WHERE  CTT_FILIAL=%xFilial:CTT%  AND AK3_FILIAL=%xFilial:AK3% AND AK3_ORCAME=%Exp:mv_par01%  AND AK3_VERSAO=%Exp:mv_par02%  AND
		( ( AK3TMP.AK3_CO>=%Exp:mv_par03%  AND AK3TMP.AK3_CO<=%Exp:mv_par04% ) OR 
		  (AK3_CO>=LEFT(%Exp:mv_par03%,7) AND AK3_CO<=LEFT(%Exp:mv_par04%,7) ) 
		) AND
		AK3TMP.AK3_CO<>%Exp:mv_par01% AND CTT_CUSTO>=%Exp:mv_par08%  AND CTT_CUSTO<=%Exp:mv_par09%  AND LEN(CTT_CUSTO)=4
		AND LEN(AK3TMP.AK3_CO)>5 AND   AK3TMP.%NotDel% AND
		AK2.%NotDel%  AND AK3_CO NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100')
		order by CTT_CUSTO,AK3_CO
		EndSql

	ENDIF
	/*
	ATENDER MANAUS E SAO PAULO CORRECAO PARA QUE FAÇA A QUERY POR CENTRO DE CUSTO CTT , NAO MAIS POR AK2
			SELECT DISTINCT AK2_CC ,AK2_ORCAME AS AK3_ORCAME,AK2_VERSAO AS AK3_VERSAO,AK3_CO,AK3_DESCRI,AK3_NIVEL,
		1  AS MES01,2  AS MES02,3  AS MES03,4  AS MES04,5  AS MES05,
		6  AS MES06,7  AS MES07,8  AS MES08,9  AS MES09,10 AS MES10,
		11 AS MES11,12 AS MES12,13 AS MES13
		FROM %table:AK2% AK2
	
		LEFT OUTER JOIN
		(SELECT AK3_CO,AK3_DESCRI,AK3_NIVEL FROM  %table:AK3% AK3
		WHERE AK3_FILIAL=%xFilial:AK3% AND AK3_ORCAME=%Exp:mv_par01%   AND AK3_VERSAO=%Exp:mv_par02%  AND AK3.%NotDel%) AS AK3TMP
		ON (AK3TMP.AK3_CO>=%Exp:mv_par03% AND AK3_CO<=%Exp:mv_par04%) OR AK3TMP.AK3_CO=LEFT(AK2_CO,7)

		WHERE AK2_FILIAL=%xFilial:AK2% AND AK2_ORCAME=%Exp:mv_par01%  AND AK2_VERSAO=%Exp:mv_par02%  AND
		AK2_CO>=%Exp:mv_par03%  AND AK2_CO<=%Exp:mv_par04%  AND
		AK3TMP.AK3_CO<>%Exp:mv_par01% AND AK2_CC>=%Exp:mv_par08% AND AK2_CC<=%Exp:mv_par09%
		AND LEN(AK3_CO)>5 AND
		AK2.%NotDel%  AND AK3_CO NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100')

		ORDER BY AK2_CC,AK3_CO
    */
	// 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Metodo EndQuery ( Classe TRSection )                                    ³
	//³                                                                        ³
	//³Prepara o relatório para executar o Embedded SQL.                       ³
	//³                                                                        ³
	//³ExpA1 : Array com os parametros do tipo Range                           ³
	//³                                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

	dif:=0
	dbSelectArea(cAliasQRY)
	DBGOTOP()
	cCusto   :=(cAliasQRY)->AK2_CC
	cConta   :=left((cAliasQRY)->AK3_CO,7)
	cSecao   :="Total "+Posicione("CTT",1,xfilial()+cCusto,"CTT_DESC01")
	cSubsecao:="Sub.Total "+Posicione("CT1",1,xfilial()+cConta,"CT1_DESC01")
	oReport:SetMeter((cAliasQRY)->(LastRec()))
	//oBreak1:SetTotalText(cSubsecao)
	oBreak2:SetTotalText(cSecao)
	oReport:SetDevice(4) //1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html
	//cria uma celula com o titulo do relatorio -------------------------------
	oReport:XlsNewRow(.t.)
	oReport:XmlLoad("cab01.xml")
	oReport:XlsNewStyle("TIT","TIT",2,{"ARIAL",14},,.f.,"C")
	oReport:XlsNewStyle("CTIT","CIT",2,{"ARIAL BLACK",8},,.f.,"C")
	oReport:XlsNewCell(oReport:Title(),.f.,2,"TIT",9,20,"C")
	//----------------------------------------- --------------------------------

	//oReport:SkipLine(1)
	//oReport:PrintText("Centro de Custo "+cCusto+" "+Posicione("CTT",1,xfilial()+cCusto,"CTT_DESC01"),,oSection:Cell("AK2_CC"):ColPos())
	//oSection:SetHeaderBreak(.T.)
	//oSection:SetHeaderPage()
	oReport:SetUseGC(.F.)
	oReport:SetTitle("Orcado Versos Realizado")
	oReport:EndPage() //Reinicia Paginas
	oSection:Cell("AK2_CC"):Hide()
	oSection:Cell("AK2_CC"):HideHeader()
	//oSection:ACELL[1]:nCellPixel:=40     //largura da celula em pixel (1 cm = 37 px)
	//oSection:ACELL[1]:NHEADERSIZE:=4
	//oSection:ACELL[2]:LBOLD:=.T.
	oSection:Cell("DESCCC"):SetValue(cCusto+" "+Posicione("CTT",1,xfilial()+cCusto,"CTT_DESC01"))
	OSection:Cell("DESCCC"):cXlsStyle:="CTIT"
	OSection:Cell("DESCCC"):lBold:=.T.
	lfirst:=.T.
	oReport:lEmptyLineExcel:=.T.
	//oSection:SetPageBreak(.F.)
	//oSection:SetLinesBefore(1)
	//oSection:lHeaderBreak:=.F.
	//oSection:lPageBreak:=.F.
	oSection:Init()
	While !oReport:Cancel() .And. !(cAliasQRY)->(Eof())
		If oReport:Cancel()
			Exit
		EndIf

		oReport:IncMeter()
		if left((cAliasQRY)->AK3_CO,7)<>alltrim(cConta)
			//oReport:SkipLine(2)
			cConta   :=left((cAliasQRY)->AK3_CO,7)
		endif

		if alltrim((cAliasQRY)->AK2_CC)<>alltrim(cCusto)
			oReport:IncMeter()
			oSection:Cell("DESCCC"):SetValue((cAliasQRY)->AK2_CC+" "+Posicione("CTT",1,xfilial()+(cAliasQRY)->AK2_CC,"CTT_DESC01"))
			vorc :=aRetTot((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)
			vreal:=aRetTotCT2((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,12,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)
			if (vorc+vreal)==0
				dbSelectArea(cAliasQRY)
				dbSkip()
				LOOP
			endif
			oSection:Printline()
			cCusto:=(cAliasQRY)->AK2_CC
			cConta   :=left((cAliasQRY)->AK3_CO,7)
			cSecao:="Total "+Posicione("CTT",1,xfilial()+cCusto,"CTT_DESC01")
			oBreak2:SetTotalText(cSecao)
			oSection:Cell("DESCCC"):SetValue("")
			dbSelectArea(cAliasQRY)
			dbSkip()
			LOOP
		endif

		cContadet:=(cAliasQRY)->AK3_CO
		vorc :=aRetTot((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)
		vreal:=aRetTotCT2((cAliasQRY)->AK3_CO,(cAliasQRY)->AK3_ORCAME,(cAliasQRY)->AK3_VERSAO,12,(cAliasQRY)->AK2_CC,(cAliasQRY)->AK2_CC)
		if (vorc+vreal)<>0
			oSection:Printline()
			oSection:Cell("DESCCC"):SetValue("")
		else
			dbSelectArea(cAliasQRY)
			dbSkip()
			LOOP
		endif

		if len(alltrim((cAliasQRY)->AK3_CO))>7
			//inicializo a segunda seção
			IncProc("Imprimindo Lancamentos ")
			cAliasCT2a := GetNextAlias()
			//MakeSqlExpr(cPerg)
			//osection2:BeginQuery()
			IF LEN(alltrim(cSqlinc))>7
			 BeginSql Alias cAliasCT2a
			 select CT2_DATA,CT2_HIST,CT2_DEBITO,CT2_CREDIT,CT2_VALOR
			 FROM  %table:CT2%  CT2
			 WHERE  CT2_FILIAL>=%Exp:MV_PAR12%  AND CT2_FILIAL<=%Exp:MV_PAR13%  AND
			 (    (CT2_DEBITO=%Exp:cContadet% AND %Exp:cSqlind%)
			 OR (CT2_CREDIT=%Exp:cContadet% AND %Exp:cSqlinc%) )
			 AND CT2_DEBITO NOT IN ('4010101099','4010202099','4010204099','4210201100','4210202100','4210301100','2430101003') AND CT2_DEBITO<>'2430101003'
			 AND CT2_CREDIT NOT IN ('4010101099','4010202099','4010204099','4210201100','4210202100','4210301100','2430101003') AND CT2_CREDIT<>'2430101003'
			 AND SUBSTRING(CT2_DATA,1,6)=%Exp:MV_PAR10% AND CT2.%NotDel%
			 ORDER BY CT2_DATA
			 EndSql
			ELSE
			 BeginSql Alias cAliasCT2a
			 select CT2_DATA,CT2_HIST,CT2_DEBITO,CT2_CREDIT,CT2_VALOR
			 FROM  %table:CT2%  CT2
			 WHERE  CT2_FILIAL>=%Exp:MV_PAR12%  AND CT2_FILIAL<=%Exp:MV_PAR13%  AND
			 (    (CT2_DEBITO=%Exp:cContadet% AND CT2_CCD=%Exp:cCusto%)
			 OR (CT2_CREDIT=%Exp:cContadet% AND CT2_CCC=%Exp:cCusto%) )
			 AND CT2_DEBITO NOT IN ('4010101099','4010202099','4010204099','4210201100','4210202100','4210301100','2430101003') AND CT2_DEBITO<>'2430101003'
			 AND CT2_CREDIT NOT IN ('4010101099','4010202099','4010204099','4210201100','4210202100','4210301100','2430101003') AND CT2_CREDIT<>'2430101003'
			 AND SUBSTRING(CT2_DATA,1,6)=%Exp:MV_PAR10% AND CT2.%NotDel%
			 ORDER BY CT2_DATA
			 EndSql
			ENDIF
			//osection2:EndQuery(/*Array com os parametros do tipo Range*/)
			iSalt:=.F.

			dbSelectArea(cAliasCT2a)
			DBGOTOP()
			//IF !(cAliasCT2a)->(Eof()) .and. MV_PAR11==2
			//oreport:NXLSROW-=2
			//ENDIF
			if !(cAliasCT2a)->(Eof()) .and. MV_PAR11==2

				oSection2:init()
				While !(cAliasCT2a)->(Eof()) .and. MV_PAR11==2
					iSalt:=.T.
					oSection2:Cell("CT2_CCC"):SetValue((cAliasQRY)->AK2_CC)
					oSection2:Cell("CT2_DATA"):SetValue(stod((cAliasCT2a)->CT2_DATA))
					oSection2:Cell("CT2_HIST"):SetValue((cAliasCT2a)->CT2_HIST)
					oSection2:Cell("CT2_DEBITO"):SetValue("")  //cContadet
					oSection2:Cell("CT2_VALOR"):SetValue(0)
					oSection2:Cell("CT2_VALOR"):Hide()
					for x:=2 to 12
						oSection2:Cell("CT2_VALOR"+strzero(x,2)):SetValue(0)
						oSection2:Cell("CT2_VALOR"+strzero(x,2)):Hide()
					next
					IF val(SUBSTR(MV_PAR10,5,2))==1
						oSection2:Cell("CT2_VALOR"):SetValue(iif(alltrim(cContadet)==alltrim(CT2_CREDIT),(cAliasCT2a)->CT2_VALOR*-1,(cAliasCT2a)->CT2_VALOR))
						oSection2:Cell("CT2_VALOR"):lVisible := .T.
					ELSE
						oSection2:Cell("CT2_VALOR"+SUBSTR(MV_PAR10,5,2)):SetValue(iif(alltrim(cContadet)==alltrim(CT2_CREDIT),(cAliasCT2a)->CT2_VALOR*-1,(cAliasCT2a)->CT2_VALOR))
						oSection2:Cell("CT2_VALOR"+SUBSTR(MV_PAR10,5,2)):lVisible := .T.
					ENDIF
					osection2:Printline()
					dbSelectArea(cAliasCT2a)
					dbSkip()
				Enddo
				//finalizo a segunda seção para que seja reiniciada para o proximo registro
				osection2:Finish()
			endif
			//IF iSalt
			// oReport:SkipLine(1)
			//ENDIF
			dbSelectArea(cAliasCT2a)
			dbclosearea(cAliasCT2a)
		endif
		dbSelectArea(cAliasQRY)
		dbSkip()
	EndDo
	oSection:Finish()
	oReport:EndPage()
	dbSelectArea(cAliasQRY)
	dbclosearea(cAliasQRY)
Return NIL

Static Function aRetStq(cta_o,orc,ver,per,cci,ccf)
	Local aret:=0
	Local cAliasSTC := GetNextAlias()
	Local orcamento, periodo
	if len(alltrim(cci))==0
		cci:=''
		ccf:='ZZZZZZZZ'
	endif
	periodo:=MV_PAR05+strzero(per,2)+"01"
	orcamento:=alltrim(cta_o)+'%'
	BeginSql Alias cAliasSTC
	SELECT ISNULL(SUM(AK2_VALOR),0) as VALOR FROM %table:AK2% AK2
	WHERE AK2_FILIAL=%xFilial:AK2% AND AK2_ORCAME=%Exp:orc% AND AK2_VERSAO=%Exp:ver%
	AND AK2_CO LIKE (%Exp:orcamento%) AND AK2_PERIOD=%Exp:periodo% AND AK2.%NotDel%
	AND AK2_CC>=%Exp:cci% and AK2_CC<=%Exp:ccf% AND AK2_CO NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100')
	EndSql
	dbselectArea(cAliasSTC)
	(cAliasSTC)->(dbgotop())
	aret:=(cAliasSTC)->valor
	dbclosearea(cAliasSTC)
Return(aret)

Static Function aRetTot(cta_o,orc,ver,cci,ccf)
	Local aret:=0
	Local cAliasSTC := GetNextAlias()
	Local orcamento, periodo
	Local dinicio,dfim
	if len(alltrim(cci))==0
		cci:=mv_par08
		ccf:=mv_par09
	endif
	periodo:=MV_PAR05
	dinicio:=periodo+"0101"
	dfim   :=iif(LEN(ALLTRIM(MV_PAR10))>0, dtos(LastDate(stod(MV_PAR10+"0101"))),periodo+"1231")
	orcamento:=alltrim(cta_o)+'%'
	if LEN(ALLTRIM(MV_PAR10))==0
		BeginSql Alias cAliasSTC
		SELECT ISNULL(SUM(AK2_VALOR),0) as VALOR FROM %table:AK2% AK2
		WHERE AK2_FILIAL=%xFilial:AK2% AND AK2_ORCAME=%Exp:orc% AND AK2_VERSAO=%Exp:ver%
		AND AK2_CO LIKE (%Exp:orcamento%) AND SUBSTRING(AK2_PERIOD,1,4)=%Exp:periodo% AND AK2.%NotDel%
		AND AK2_CC>=%Exp:cci% and AK2_CC<=%Exp:ccf%  AND AK2_CO NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100')
		EndSql
	else
		BeginSql Alias cAliasSTC
		SELECT ISNULL(SUM(AK2_VALOR),0) as VALOR FROM %table:AK2% AK2
		WHERE AK2_FILIAL=%xFilial:AK2% AND AK2_ORCAME=%Exp:orc% AND AK2_VERSAO=%Exp:ver%
		AND AK2_CO LIKE (%Exp:orcamento%) AND AK2_PERIOD>=%Exp:dinicio% AND AK2_PERIOD<=%Exp:dfim%  AND AK2.%NotDel%
		AND AK2_CC>=%Exp:cci% and AK2_CC<=%Exp:ccf%  AND AK2_CO NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100')
		EndSql
	endif
	dbselectArea(cAliasSTC)
	(cAliasSTC)->(dbgotop())
	aret:=(cAliasSTC)->valor
	dbclosearea(cAliasSTC)
Return(aret)

Static Function aRetCT2(cta_o,orc,ver,per,cci,ccf)
	Local aret:=0
	Local cAliasSTC := GetNextAlias()
	Local orcamento, periodo
	Local cDat, cDatade, cDataAte
	Local cLastCT2:=""

	cDat:="01/"+strzero(iif(per==13,12,per),2)+"/"+MV_PAR05
	cDatade :="01/"+strzero(iif(per==13,1,per),2)+"/"+MV_PAR05
	cDataAte:=LastDate(ctod(cDat))
	if per>val(substr(mv_par10,5,2)) .and. len(alltrim(mv_par10))>0
		Return(aret)
	endif
	if len(alltrim(cci))==0
		cci:=mv_par08
		ccf:=mv_par09
	endif
	periodo:=MV_PAR05+strzero(per,2)
	orcamento:=alltrim(cta_o)+'%'
	cLastCT2:=alltrim(cta_o)

	//SO PEGAR AS CONTAS DO ORCAMENTO

	BeginSql Alias cAliasSTC
	select DISTINCT AK3_CO CONTA from %table:AK3%  AK3
	WHERE AK3_FILIAL=%xFilial:AK3% AND  AK3_ORCAME=%Exp:orc%  AND AK3_VERSAO=%Exp:ver%
	AND AK3_CO LIKE(%Exp:orcamento%)  AND AK3.%NotDel%
	EndSql
	//endif
	dbselectArea(cAliasSTC)
	(cAliasSTC)->(dbgotop())
	do while !eof()
		IF len(alltrim((cAliasSTC)->CONTA))>0
			cLastCT2:=ALLTRIM(cLastCT2)+"','"+(cAliasSTC)->CONTA
		ENDIF
		dbskip()
	enddo
	dbclosearea(cAliasSTC)
	//executa stored procedure para recuperar os debitos e creditos do periodo
	IF LEN(alltrim(cSqlinc))>7
		BeginSql Alias cAliasSTC
		select isnull(SUM(CT2_VALOR),0) DEBITOS,
		(select isnull(SUM(CT2_VALOR),0) from %table:CT2%  CT2B
		WHERE CT2_FILIAL>=%Exp:MV_PAR12% AND CT2_FILIAL<=%Exp:MV_PAR13% AND CT2_CREDIT IN (%Exp:cLastCT2%) AND SUBSTRING(CT2_DATA,1,6)=%Exp:periodo%
		AND CT2B.%NotDel% AND %Exp:cSqlinc%  AND CT2_DEBITO<>'2430101003'
		AND CT2_CREDIT NOT IN ('4010101099','4010202099','4010204099','4210201100','4210202100','4210301100','2430101003')  ) CREDITOS
		from %table:CT2%  CT2
		WHERE  CT2_FILIAL>=%Exp:MV_PAR12% AND CT2_FILIAL<=%Exp:MV_PAR13%  AND CT2_DEBITO IN (%Exp:cLastCT2%)  AND
		SUBSTRING(CT2_DATA,1,6)=%Exp:periodo%  AND CT2.%NotDel%
		AND  %Exp:cSqlind%  AND CT2_CREDIT<>'2430101003'
		AND CT2_DEBITO NOT IN ('4010101099','4010202099','4010204099','4210201100','4210202100','4210301100','2430101003')
		EndSql
	ELSE
		BeginSql Alias cAliasSTC
		select isnull(SUM(CT2_VALOR),0) DEBITOS,
		(select isnull(SUM(CT2_VALOR),0) from %table:CT2%  CT2B
		WHERE CT2_FILIAL>=%Exp:MV_PAR12% AND CT2_FILIAL<=%Exp:MV_PAR13% AND CT2_CREDIT IN (%Exp:cLastCT2%) AND SUBSTRING(CT2_DATA,1,6)=%Exp:periodo%
		AND CT2B.%NotDel% AND CT2_CCC>=%Exp:cci% AND CT2_CCC<=%Exp:ccf%  AND CT2_DEBITO<>'2430101003'
		AND CT2_CREDIT NOT IN ('4010101099','4010202099','4010204099','4210201100','4210202100','4210301100','2430101003')  ) CREDITOS
		from %table:CT2%  CT2
		WHERE  CT2_FILIAL>=%Exp:MV_PAR12% AND CT2_FILIAL<=%Exp:MV_PAR13%  AND CT2_DEBITO IN (%Exp:cLastCT2%)  AND
		SUBSTRING(CT2_DATA,1,6)=%Exp:periodo%  AND CT2.%NotDel%
		AND  CT2_CCD>=%Exp:cci% AND CT2_CCD<=%Exp:ccf%    AND CT2_CREDIT<>'2430101003'
		AND CT2_DEBITO NOT IN ('4010101099','4010202099','4010204099','4210201100','4210202100','4210301100','2430101003')
		EndSql
	ENDIF
	//aret:=CTSMMOV(cDatade,cDataAte,"01","1",3,ALLTRIM(cta_o) ,orcamento ,ALLTRIM(cci) ,ccf  ,''   ,'ZZZZZZZZZ'   ,''  ,'ZZZZZZZZZ')

	dbselectArea(cAliasSTC)
	(cAliasSTC)->(dbgotop())
	aret:=(cAliasSTC)->(DEBITOS - CREDITOS)
	dbclosearea(cAliasSTC)

Return(aret)

Static Function aRetTotCT2(cta_o,orc,ver,per,cci,ccf)
	Local aret:=0
	Local cAliasSTC := GetNextAlias()
	Local orcamento, periodo
	Local cLastCT2:=""
	Local inicio
	Local cDat,cDatade,cDataAte
	if len(alltrim(MV_PAR10))==0
		cDat:="01/"+strzero(iif(per==13,12,per),2)+"/"+MV_PAR05
	else
		cDat:="01/"+substr(MV_PAR10,5,2)+"/"+MV_PAR05
	endif
	cDatade :=MV_PAR05+"0101"
	cDataAte:=dtos(LastDate(ctod(cDat)))

	if len(alltrim(cci))==0
		cci:=mv_par08
		ccf:=mv_par09
	endif
	periodo:=MV_PAR05
	orcamento:=alltrim(cta_o)+'%'
	cLastCT2:=alltrim(cta_o)
	inicio:=iif(LEN(ALLTRIM(MV_PAR10))>0,MV_PAR10+"01",periodo+"0101")
	//SO PEGAR AS CONTAS DO ORCAMENTO
	/*
	if len(orcamento)>8
	if LEN(ALLTRIM(MV_PAR10))==0
	BeginSql Alias cAliasSTC
	select DISTINCT AK2_CO CONTA from %table:AK2%  AK2
	WHERE AK2_FILIAL=%xFilial:AK2% AND  AK2_ORCAME=%Exp:orc%  AND AK2_VERSAO=%Exp:ver%
	AND AK2_CO LIKE(%Exp:orcamento%)  AND SUBSTRING(AK2_PERIOD,1,4)=%Exp:periodo%
	AND AK2_CC>=%Exp:cci% AND AK2_CC<=%Exp:ccf% AND AK2.%NotDel%
	EndSql
	else
	BeginSql Alias cAliasSTC
	select DISTINCT AK2_CO CONTA from %table:AK2%  AK2
	WHERE AK2_FILIAL=%xFilial:AK2% AND  AK2_ORCAME=%Exp:orc%  AND AK2_VERSAO=%Exp:ver%
	AND AK2_CO LIKE(%Exp:orcamento%) AND AK2_PERIOD=%Exp:inicio%   AND AK2.%NotDel%
	EndSql
	endif
	endif
	*/
	BeginSql Alias cAliasSTC
	select DISTINCT AK3_CO CONTA from %table:AK3%  AK3
	WHERE AK3_FILIAL=%xFilial:AK3% AND  AK3_ORCAME=%Exp:orc%  AND AK3_VERSAO=%Exp:ver%
	AND AK3_CO LIKE(%Exp:orcamento%)  AND AK3.%NotDel%
	EndSql

	dbselectArea(cAliasSTC)
	(cAliasSTC)->(dbgotop())
	do while  !eof()
		if len(alltrim((cAliasSTC)->CONTA))>0
			cLastCT2:=ALLTRIM(cLastCT2)+"','"+(cAliasSTC)->CONTA
		endif
		dbskip()
	enddo
	dbclosearea(cAliasSTC)
	cAliasSTC := GetNextAlias()

	if LEN(ALLTRIM(MV_PAR10))==0
		IF LEN(alltrim(cSqlinc))>7
			BeginSql Alias cAliasSTC
			select isnull(SUM(CT2_VALOR),0) DEBITOS,

			(select isnull(SUM(CT2_VALOR),0) from %table:CT2%  CT2B
			WHERE  CT2_FILIAL>=%Exp:MV_PAR12% AND CT2_FILIAL<=%Exp:MV_PAR13%   AND CT2_CREDIT IN (%Exp:cLastCT2%)  AND SUBSTRING(CT2_DATA,1,4)=%Exp:periodo%
			AND CT2B.%NotDel% AND  %Exp:cSqlinc%  AND CT2_DEBITO<>'2430101003' AND CT2_CREDIT NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100')) CREDITOS

			from %table:CT2%  CT2
			WHERE  CT2_FILIAL>=%Exp:MV_PAR12% AND CT2_FILIAL<=%Exp:MV_PAR13%  AND CT2_DEBITO IN (%Exp:cLastCT2%) AND
			SUBSTRING(CT2_DATA,1,4)=%Exp:periodo%  AND CT2.%NotDel%
			AND %Exp:cSqlind%  AND CT2_CREDIT<>'2430101003' AND CT2_DEBITO NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100')
			EndSql
		ELSE
			BeginSql Alias cAliasSTC
			select isnull(SUM(CT2_VALOR),0) DEBITOS,

			(select isnull(SUM(CT2_VALOR),0) from %table:CT2%  CT2B
			WHERE  CT2_FILIAL>=%Exp:MV_PAR12% AND CT2_FILIAL<=%Exp:MV_PAR13%   AND CT2_CREDIT IN (%Exp:cLastCT2%)  AND SUBSTRING(CT2_DATA,1,4)=%Exp:periodo%
			AND CT2B.%NotDel% AND CT2_CCC>=%Exp:cci% AND CT2_CCC<=%Exp:ccf%   AND CT2_DEBITO<>'2430101003' AND CT2_CREDIT NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100')) CREDITOS

			from %table:CT2%  CT2
			WHERE  CT2_FILIAL>=%Exp:MV_PAR12% AND CT2_FILIAL<=%Exp:MV_PAR13%  AND CT2_DEBITO IN (%Exp:cLastCT2%) AND
			SUBSTRING(CT2_DATA,1,4)=%Exp:periodo%  AND CT2.%NotDel%
			AND CT2_CCD>=%Exp:cci% AND CT2_CCD<=%Exp:ccf%  AND CT2_CREDIT<>'2430101003' AND CT2_DEBITO NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100')
			EndSql

		ENDIF
	else
		IF LEN(alltrim(cSqlinc))>7
			BeginSql Alias cAliasSTC
			select isnull(SUM(CT2_VALOR),0) DEBITOS,

			(select isnull(SUM(CT2_VALOR),0) from %table:CT2%  CT2B
			WHERE  CT2_FILIAL>=%Exp:MV_PAR12% AND CT2_FILIAL<=%Exp:MV_PAR13%  AND CT2_CREDIT IN (%Exp:cLastCT2%)
			AND CT2_DATA>=%Exp:cDataDe% AND CT2_DATA<=%Exp:cDataAte% AND CT2B.%NotDel%
			AND %Exp:cSqlinc% AND CT2_DEBITO<>'2430101003' AND CT2_CREDIT NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100')) CREDITOS

			from %table:CT2%  CT2
			WHERE  CT2_FILIAL>=%Exp:MV_PAR12% AND CT2_FILIAL<=%Exp:MV_PAR13%  AND CT2_DEBITO IN (%Exp:cLastCT2%)
			AND CT2_DATA>=%Exp:cDataDe% AND CT2_DATA<=%Exp:cDataAte%  AND CT2.%NotDel%
			AND %Exp:cSqlind%  AND CT2_CREDIT<>'2430101003' AND CT2_DEBITO NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100')
			EndSql
		ELSE
			BeginSql Alias cAliasSTC
			select isnull(SUM(CT2_VALOR),0) DEBITOS,

			(select isnull(SUM(CT2_VALOR),0) from %table:CT2%  CT2B
			WHERE  CT2_FILIAL>=%Exp:MV_PAR12% AND CT2_FILIAL<=%Exp:MV_PAR13%  AND CT2_CREDIT IN (%Exp:cLastCT2%)
			AND CT2_DATA>=%Exp:cDataDe% AND CT2_DATA<=%Exp:cDataAte% AND CT2B.%NotDel%
			AND  CT2_CCC>=%Exp:cci% AND CT2_CCC<=%Exp:ccf% AND CT2_DEBITO<>'2430101003' AND CT2_CREDIT NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100')) CREDITOS

			from %table:CT2%  CT2
			WHERE  CT2_FILIAL>=%Exp:MV_PAR12% AND CT2_FILIAL<=%Exp:MV_PAR13%  AND CT2_DEBITO IN (%Exp:cLastCT2%)
			AND CT2_DATA>=%Exp:cDataDe% AND CT2_DATA<=%Exp:cDataAte%  AND CT2.%NotDel%
			AND CT2_CCD>=%Exp:cci% AND CT2_CCD<=%Exp:ccf% AND CT2_CREDIT<>'2430101003' AND CT2_DEBITO NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100')
			EndSql
		ENDIF
	endif
	dbselectArea(cAliasSTC)
	(cAliasSTC)->(dbgotop())
	aret:=(cAliasSTC)->(DEBITOS - CREDITOS)
	dbclosearea(cAliasSTC)
Return(aret)

Static Function aRetDif(cta_o,orc,ver,per,tp,cci,ccf)
	Local aret:=0
	Local cAliasSTC := GetNextAlias()
	Local orcamento, periodo
	Local cLastCT2 :=""
	Local dinicio,dfim
	if len(alltrim(cci))==0
		cci:=mv_par08
		ccf:=mv_par09
	endif

	periodo:=MV_PAR05+strzero(per,2)+"01"
	dinicio:=iif(per>12,MV_PAR05+"0101",periodo)
	if per>12
		if len(alltrim(mv_par10))>0
			dfim := dtos(LastDate(stod(MV_PAR10+"01")))
		else
			dfim := dtos(LastDate(stod(MV_PAR05+"1231")))
		endif
	else
		dfim   := dtos(LastDate(stod(dinicio)))
	endif
	orcamento:=alltrim(cta_o)+'%'
	cLastCT2:=alltrim(cta_o)
	//SO PEGAR AS CONTAS DO ORCAMENTO

	BeginSql Alias cAliasSTC
	select DISTINCT AK3_CO CONTA from %table:AK3%  AK3
	WHERE AK3_FILIAL=%xFilial:AK3% AND  AK3_ORCAME=%Exp:orc%  AND AK3_VERSAO=%Exp:ver%
	AND AK3_CO LIKE(%Exp:orcamento%)  AND AK3.%NotDel%
	EndSql

	dbselectArea(cAliasSTC)
	(cAliasSTC)->(dbgotop())
	DO WHILE !eof()
		IF LEN(ALLTRIM((cAliasSTC)->CONTA))>0
			cLastCT2:=ALLTRIM(cLastCT2)+"','"+(cAliasSTC)->CONTA
		ENDIF
		dbskip()
	enddo
	dbclosearea(cAliasSTC)
	cAliasSTC := GetNextAlias()

	//----------------------------------------------------------------

	IF per<=12
		IF LEN(alltrim(cSqlinc))>7
			BeginSql Alias cAliasSTC
			select isnull(SUM(CT2_VALOR),0) DEBITOS,

			(select isnull(SUM(CT2_VALOR),0) from %table:CT2% CT2B
			WHERE  CT2_FILIAL>=%Exp:MV_PAR12% AND CT2_FILIAL<=%Exp:MV_PAR13%  AND CT2_CREDIT IN (%Exp:cLastCT2%)
			AND CT2_DATA>=%Exp:dinicio% AND CT2_DATA<=%Exp:dfim%
			AND CT2B.%NotDel% AND  %Exp:cSqlinc% AND CT2_DEBITO<>'2430101003' AND CT2_CREDIT NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100','2430101003')) CREDITOS,

			(SELECT ISNULL(SUM(AK2_VALOR),0) FROM %table:AK2% AK2
			WHERE AK2_FILIAL=%xFilial:AK2% AND AK2_ORCAME=%Exp:orc% AND AK2_VERSAO=%Exp:ver%
			AND AK2_CO IN (%Exp:cLastCT2%)
			AND AK2_PERIOD>=%Exp:dinicio% AND AK2_PERIOD<=%Exp:dfim%
			AND AK2.%NotDel% AND AK2_CC>=%Exp:cci% and AK2_CC<=%Exp:ccf%
			AND AK2_CO NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100','2430101003')
			)OCAMENTO

			from %table:CT2% CT2
			WHERE  CT2_FILIAL>=%Exp:MV_PAR12% AND CT2_FILIAL<=%Exp:MV_PAR13%  AND CT2_DEBITO  IN (%Exp:cLastCT2%)  AND
			CT2_DATA>=%Exp:dinicio% AND CT2_DATA<=%Exp:dfim%  AND CT2.%NotDel%
			AND  %Exp:cSqlind%  AND CT2_CREDIT<>'2430101003'  AND CT2_DEBITO NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100')
			EndSql
		ELSE
			BeginSql Alias cAliasSTC
			select isnull(SUM(CT2_VALOR),0) DEBITOS,

			(select isnull(SUM(CT2_VALOR),0) from %table:CT2% CT2B
			WHERE  CT2_FILIAL>=%Exp:MV_PAR12% AND CT2_FILIAL<=%Exp:MV_PAR13%  AND CT2_CREDIT IN (%Exp:cLastCT2%)
			AND CT2_DATA>=%Exp:dinicio% AND CT2_DATA<=%Exp:dfim%
			AND CT2B.%NotDel% AND   CT2_CCC>=%Exp:cci% AND CT2_CCC<=%Exp:ccf% AND CT2_DEBITO<>'2430101003' AND CT2_CREDIT NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100','2430101003')) CREDITOS,

			(SELECT ISNULL(SUM(AK2_VALOR),0) FROM %table:AK2% AK2
			WHERE AK2_FILIAL=%xFilial:AK2% AND AK2_ORCAME=%Exp:orc% AND AK2_VERSAO=%Exp:ver%
			AND AK2_CO IN (%Exp:cLastCT2%)
			AND AK2_PERIOD>=%Exp:dinicio% AND AK2_PERIOD<=%Exp:dfim%
			AND AK2.%NotDel% AND AK2_CC>=%Exp:cci% and AK2_CC<=%Exp:ccf%
			AND AK2_CO NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100','2430101003')
			)OCAMENTO

			from %table:CT2% CT2
			WHERE  CT2_FILIAL>=%Exp:MV_PAR12% AND CT2_FILIAL<=%Exp:MV_PAR13%  AND CT2_DEBITO  IN (%Exp:cLastCT2%)  AND
			CT2_DATA>=%Exp:dinicio% AND CT2_DATA<=%Exp:dfim%  AND CT2.%NotDel%
			AND   CT2_CCD>=%Exp:cci% AND CT2_CCD<=%Exp:ccf%  AND CT2_CREDIT<>'2430101003'  AND CT2_DEBITO NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100')
			EndSql
		ENDIF
	ELSE
		if LEN(ALLTRIM(MV_PAR10))==0
		  IF LEN(alltrim(cSqlinc))>7
			BeginSql Alias cAliasSTC
			select isnull(SUM(CT2_VALOR),0) DEBITOS,

			(select isnull(SUM(CT2_VALOR),0) from %table:CT2% CT2B
			WHERE  CT2_FILIAL>=%Exp:MV_PAR12% AND CT2_FILIAL<=%Exp:MV_PAR13%  AND CT2_CREDIT  IN (%Exp:cLastCT2%)
			AND SUBSTRING(CT2_DATA,1,4)=SUBSTRING(%Exp:periodo%,1,4)
			AND CT2B.%NotDel% AND  %Exp:cSqlinc% AND CT2_DEBITO<>'2430101003' AND CT2_CREDIT NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100','2430101003')) CREDITOS,

			(SELECT ISNULL(SUM(AK2_VALOR),0) FROM %table:AK2% AK2
			WHERE AK2_FILIAL=%xFilial:AK2% AND AK2_ORCAME=%Exp:orc% AND AK2_VERSAO=%Exp:ver%
			AND AK2_CO IN (%Exp:cLastCT2%)
			AND AK2_PERIOD>=%Exp:dinicio% AND AK2_PERIOD<=%Exp:dfim%
			AND AK2.%NotDel% AND AK2_CC>=%Exp:cci% and AK2_CC<=%Exp:ccf%
			AND AK2_CO NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100','2430101003')
			)OCAMENTO

			from %table:CT2% CT2
			WHERE  CT2_FILIAL>=%Exp:MV_PAR12% AND CT2_FILIAL<=%Exp:MV_PAR13%  AND CT2_DEBITO  IN (%Exp:cLastCT2%)  AND
			SUBSTRING(CT2_DATA,1,4)=SUBSTRING(%Exp:MV_PAR05%,1,4)  AND CT2.%NotDel%
			AND  %Exp:cSqlind%  AND CT2_CREDIT<>'2430101003'  AND CT2_DEBITO NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100')
			EndSql
		  ELSE
		    BeginSql Alias cAliasSTC
			select isnull(SUM(CT2_VALOR),0) DEBITOS,

			(select isnull(SUM(CT2_VALOR),0) from %table:CT2% CT2B
			WHERE  CT2_FILIAL>=%Exp:MV_PAR12% AND CT2_FILIAL<=%Exp:MV_PAR13%  AND CT2_CREDIT  IN (%Exp:cLastCT2%)
			AND SUBSTRING(CT2_DATA,1,4)=SUBSTRING(%Exp:periodo%,1,4)
			AND CT2B.%NotDel% AND CT2_CCC>=%Exp:cci% AND CT2_CCC<=%Exp:ccf%  AND CT2_DEBITO<>'2430101003' AND CT2_CREDIT NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100','2430101003')) CREDITOS,

			(SELECT ISNULL(SUM(AK2_VALOR),0) FROM %table:AK2% AK2
			WHERE AK2_FILIAL=%xFilial:AK2% AND AK2_ORCAME=%Exp:orc% AND AK2_VERSAO=%Exp:ver%
			AND AK2_CO IN (%Exp:cLastCT2%)
			AND AK2_PERIOD>=%Exp:dinicio% AND AK2_PERIOD<=%Exp:dfim%
			AND AK2.%NotDel% AND AK2_CC>=%Exp:cci% and AK2_CC<=%Exp:ccf%
			AND AK2_CO NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100','2430101003')
			)OCAMENTO

			from %table:CT2% CT2
			WHERE  CT2_FILIAL>=%Exp:MV_PAR12% AND CT2_FILIAL<=%Exp:MV_PAR13%  AND CT2_DEBITO  IN (%Exp:cLastCT2%)  AND
			SUBSTRING(CT2_DATA,1,4)=SUBSTRING(%Exp:MV_PAR05%,1,4)  AND CT2.%NotDel%
			AND CT2_CCD>=%Exp:cci% AND CT2_CCD<=%Exp:ccf%  AND CT2_CREDIT<>'2430101003'  AND CT2_DEBITO NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100')
			EndSql
		  ENDIF
		else
		  IF LEN(alltrim(cSqlinc))>7
			BeginSql Alias cAliasSTC
			select isnull(SUM(CT2_VALOR),0) DEBITOS,

			(select isnull(SUM(CT2_VALOR),0) from %table:CT2% CT2B
			WHERE  CT2_FILIAL>=%Exp:MV_PAR12% AND CT2_FILIAL<=%Exp:MV_PAR13%  AND CT2_CREDIT  IN (%Exp:cLastCT2%)
			AND CT2_DATA>=%Exp:dinicio% AND CT2_DATA<=%Exp:dfim%
			AND CT2B.%NotDel% AND  %Exp:cSqlinc% AND CT2_DEBITO<>'2430101003' AND CT2_CREDIT NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100','2430101003')) CREDITOS,

			(SELECT ISNULL(SUM(AK2_VALOR),0) FROM %table:AK2% AK2
			WHERE AK2_FILIAL=%xFilial:AK2% AND AK2_ORCAME=%Exp:orc% AND AK2_VERSAO=%Exp:ver%
			AND AK2_CO IN (%Exp:cLastCT2%)
			AND AK2_PERIOD>=%Exp:dinicio% AND AK2_PERIOD<=%Exp:dfim%
			AND AK2.%NotDel% AND AK2_CC>=%Exp:cci% and AK2_CC<=%Exp:ccf%
			AND AK2_CO NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100','2430101003')
			)OCAMENTO

			from %table:CT2% CT2
			WHERE  CT2_FILIAL>=%Exp:MV_PAR12% AND CT2_FILIAL<=%Exp:MV_PAR13%  AND CT2_DEBITO  IN (%Exp:cLastCT2%)
			AND CT2_DATA>=%Exp:dinicio% AND CT2_DATA<=%Exp:dfim%  AND CT2.%NotDel%
			AND  %Exp:cSqlind%  AND CT2_CREDIT<>'2430101003'  AND CT2_DEBITO NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100')
			EndSql
		  ELSE
		    BeginSql Alias cAliasSTC
			select isnull(SUM(CT2_VALOR),0) DEBITOS,

			(select isnull(SUM(CT2_VALOR),0) from %table:CT2% CT2B
			WHERE  CT2_FILIAL>=%Exp:MV_PAR12% AND CT2_FILIAL<=%Exp:MV_PAR13%  AND CT2_CREDIT  IN (%Exp:cLastCT2%)
			AND CT2_DATA>=%Exp:dinicio% AND CT2_DATA<=%Exp:dfim%
			AND CT2B.%NotDel% AND CT2_CCC>=%Exp:cci% AND CT2_CCC<=%Exp:ccf% AND CT2_DEBITO<>'2430101003' AND CT2_CREDIT NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100','2430101003')) CREDITOS,

			(SELECT ISNULL(SUM(AK2_VALOR),0) FROM %table:AK2% AK2
			WHERE AK2_FILIAL=%xFilial:AK2% AND AK2_ORCAME=%Exp:orc% AND AK2_VERSAO=%Exp:ver%
			AND AK2_CO IN (%Exp:cLastCT2%)
			AND AK2_PERIOD>=%Exp:dinicio% AND AK2_PERIOD<=%Exp:dfim%
			AND AK2.%NotDel% AND AK2_CC>=%Exp:cci% and AK2_CC<=%Exp:ccf%
			AND AK2_CO NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100','2430101003')
			)OCAMENTO

			from %table:CT2% CT2
			WHERE  CT2_FILIAL>=%Exp:MV_PAR12% AND CT2_FILIAL<=%Exp:MV_PAR13%  AND CT2_DEBITO  IN (%Exp:cLastCT2%)
			AND CT2_DATA>=%Exp:dinicio% AND CT2_DATA<=%Exp:dfim%  AND CT2.%NotDel%
			AND  CT2_CCD>=%Exp:cci% AND CT2_CCD<=%Exp:ccf%  AND CT2_CREDIT<>'2430101003'  AND CT2_DEBITO NOT IN ('4010101099','4010202099','4210201100','4210202100','4210301100')
			EndSql
		  ENDIF	
		endif
	ENDIF
	dbselectArea(cAliasSTC)
	(cAliasSTC)->(dbgotop())
	aret:=(cAliasSTC)->(DEBITOS - CREDITOS - OCAMENTO)

	if tp==2
		aret:=aret /(iif((cAliasSTC)->(OCAMENTO)==0,aret,(cAliasSTC)->(OCAMENTO)))
		aret:=aret * 100
	endif
	dbclosearea(cAliasSTC)
Return(aret)

Static Function ValidPerg(cPerg)
	PutSX1(cPerg,"01","Orcamento  ?"    , "", "", "mv_ch1", "C", 15,00,00,"G",""    ,"   ","","","mv_par01")
	PutSX1(cPerg,"02","Versao  ?"       , "", "", "mv_ch2", "C", 4 ,00,00,"G",""    ,"   ","","","mv_par02")
	PutSX1(cPerg,"03","Conta Orc. de  ?", "", "", "mv_ch3", "C", 12,00,00,"G",""    ,"   ","","","mv_par03")
	PutSX1(cPerg,"04","Conta Orc. Ate ?", "", "", "mv_ch4", "C", 12,00,00,"G",""    ,"   ","","","mv_par04")
	PutSX1(cPerg,"05","Ano Referencia ?", "", "", "mv_ch5", "C", 4 ,00,00,"G",""    ,"   ","","","mv_par05")
	PutSX1(cPerg,"06","Somente Orçado ?", "", "", "mv_ch6", "N", 1 ,00,00,"C",""    ,"   ","","","mv_par06","Sim","Si","Yes","","Nâo","Non","No")
	PutSX1(cPerg,"07","Por C.de Custo ?", "", "", "mv_ch7", "N", 1 ,00,00,"C",""    ,"   ","","","mv_par07","Sim","Si","Yes","","Nâo","Non","No")
	PutSX1(cPerg,"08","C.Custo de  ?"   , "", "", "mv_ch8", "C", 9 ,00,00,"G",""    ,"CTT","","","mv_par08")
	PutSX1(cPerg,"09","C.Custo Ate ?"   , "", "", "mv_ch9", "C", 9 ,00,00             ,"G",""    ,"CTT","",""    ,"mv_par09")
	PutSX1(cPerg,"10","AnoMes(aaaamm) p/ Analise?"   , "", "", "mv_cha", "C", 6 ,00,00,"G",""    ,""   ,"",""    ,"mv_par10")
	PutSX1(cPerg,"11","Sintetico ou Analitico ?", "", "", "mv_chb", "N", 1 ,00,00     ,"C",""    ,"   ",""       ,"","mv_par011","Sintetico","Sintetico","Sintetico","","Analitico","Analitico","Analitico")
	PutSX1(cPerg,"12","Filial de  ?"           , "" , "", "mv_chc", "C", 2,00,00      ,"G",""    ,"   ",""       ,"","mv_par12")
	PutSX1(cPerg,"13","Filial Ate ?"           , "" , "", "mv_chd", "C", 2,00,00     ,"G",""    ,"    ",""       ,"","mv_par13")
	PutSX1(cPerg,"14","Faixa de C.Custo Cred. ?"   , "", "", "mv_che", "C", 60 ,00,00,"R",""    ,"CTT" ,"CT2_CCC","","mv_par14")
	PutSX1(cPerg,"15","Faixa de C.Custo Deb.?"   , "", "", "mv_chf", "C", 60 ,00,00  ,"R",""    ,"CTT" ,"CT2_CCD","","mv_par15")
Return Nil 