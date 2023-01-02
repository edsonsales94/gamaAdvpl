#INCLUDE "MATR105.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � Matr105  � Autor �  Edson Maricate       � Data �02.12.1998���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao das Solicitacoes ao Almoxarifado  			      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MATR105(ExpL1,ExpA1)                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpL1 = (DEFAULT = .T.) Se passado .F. grava conteudo das  ���
���          �   perguntas do relat.em SX1, conf. prox.parametro, se array���
���          � ExpA1 = array com conteudo das perguntas do grupo do relat.���
���          �      [1] = Data da S.A.  (alimenta faixas inicial e final) ���
���          �      [2] = Numero da S.A.(alimenta faixas inicial e final) ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum		                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function MATR105(lMTR105,aPerg)

Local oReport

Private cAliasQRY := "SCP"
Private aRetCQ	:= {}

If FindFunction("TRepInUse") .And. TRepInUse()
	//������������������������������������������������������������������������Ŀ
	//�Interface de impressao                                                  �
	//��������������������������������������������������������������������������
	oReport := ReportDef(lMTR105,aPerg)
	oReport:PrintDialog()
Else
	MATR105R3(lMTR105,aPerg)
EndIf

Return





/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Ricardo Berti 		� Data �24.05.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relatorio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR105                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef(lMTR105,aPerg)

Local oReport 
Local oSection 
Local oCell         
Local cPerg	:= "MTR105"

If !lMTR105 .And. ValType(aPerg) ==  "A"
	AjustaSX1(cPerg,aPerg)
EndIf

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
If !lMTR105 .And. ValType(aPerg) ==  "A"
	oReport := TReport():New("MATR105",STR0001,"", {|oReport| ReportPrint(oReport)},STR0002+" "+STR0003)  //"  Este relatorio lista a posicao das SA's de acordo com os para-"##"metros selecionados." 
Else
	oReport := TReport():New("MATR105",STR0001,cPerg, {|oReport| ReportPrint(oReport)},STR0002+" "+STR0003)  //"  Este relatorio lista a posicao das SA's de acordo com os para-"##"metros selecionados." 
EndIf
If TamSX3("CP_PRODUTO")[1] > 15
	oReport:SetLandScape()
Else	
	oReport:SetPortrait()
EndIf
//������������������������������������������������������������������������Ŀ
//� Verifica as Perguntas Seleciondas                                      �
//� mv_par01  -  Da data      ?                                            �
//� mv_par02  -  Ate a data   ?                                            �
//� mv_par03  -  Numero de    ?                                            �
//� mv_par04  -  Numero Ate   ?                                            �
//��������������������������������������������������������������������������
Pergunte(cPerg,.F.)

If !lMTR105 .And. ValType(aPerg) ==  "A"
	MV_PAR01:= aPerg[1]
	MV_PAR02:= aPerg[1]
	MV_PAR03:= aPerg[2]
	MV_PAR04:= aPerg[2]	 
EndIf
oSection := TRSection():New(oReport,STR0013,{"SCP"}) //"Solicita��es ao armazem"
oSection:SetHeaderPage()

TRCell():New(oSection,"CP_NUM","SCP",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"CP_ITEM","SCP",STR0014) // "Item"
TRCell():New(oSection,"CP_PRODUTO","SCP")
TRCell():New(oSection,"CP_DESCRI","SCP")
TRCell():New(oSection,"CP_EMISSAO","SCP")
TRCell():New(oSection,"CP_QUANT","SCP")

// Celula CALCULO1 somente para resolver funcao externa CA100RetCQ()
//TRCell():New(oSection,"CALCULO1","",,,,,{|| aRetCQ:=ca100RetCQ((cAliasQRY)->CP_NUM,(cAliasQRY)->CP_ITEM) })

TRCell():New(oSection,"SALDO",""	,STR0009,PesqPict("SCP","CP_QUANT"),TamSx3("CP_QUANT")[1],,{|| (cAliasQRY)->(CP_QUANT-CP_QUJE)})
TRCell():New(oSection,"QENTREGUE","",STR0010,PesqPict("SCP","CP_QUANT"),TamSx3("CP_QUANT")[1],,{|| (cAliasQRY)->CP_QUJE})
TRCell():New(oSection,"REQUIS",""	,STR0011,PesqPict("SD3","D3_DOC")  ,TamSx3("D3_DOC")[1]  ,,{|| (cAliasQRY)->CP_QUANT})
TRCell():New(oSection,"CP_CC","SCP")
TRCell():New(oSection,"CP_SOLICIT","SCP",,"@X")

Return(oReport)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor � Ricardo Berti 		� Data �24.05.2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport)

Local oSection  := oReport:Section(1)
#IFNDEF TOP
	Local cCondicao := ""
#ENDIF

dbSelectArea("SCP")
dbSetOrder(1)
//������������������������������������������������������������������������Ŀ
//�Filtragem do relat�rio                                                  �
//��������������������������������������������������������������������������
#IFDEF TOP
	//������������������������������������������������������������������������Ŀ
	//�Transforma parametros Range em expressao SQL                            �	
	//��������������������������������������������������������������������������
	MakeSqlExpr(oReport:uParam)
	//������������������������������������������������������������������������Ŀ
	//�Query do relat�rio da secao 1                                           �
	//��������������������������������������������������������������������������
	oReport:Section(1):BeginQuery()	
	
	cAliasQRY := GetNextAlias()
	
	BeginSql Alias cAliasQRY
	SELECT CP_FILIAL,CP_NUM,CP_ITEM,CP_PRODUTO,CP_DESCRI,CP_EMISSAO,CP_QUANT,CP_QUJE,CP_CC,CP_SOLICIT
	
	FROM %table:SCP% SCP
	
	WHERE CP_FILIAL = %xFilial:SCP% AND 
		CP_NUM   >= %Exp:mv_par03% AND 
		CP_NUM   <= %Exp:mv_par04% AND 
		CP_EMISSAO >= %Exp:Dtos(mv_par01)% AND 
		CP_EMISSAO <= %Exp:Dtos(mv_par02)% AND 
		CP_QUANT-CP_QUJE>0 AND 
		SCP.%NotDel%
	ORDER BY %Order:SCP%
			
	EndSql 
	//������������������������������������������������������������������������Ŀ
	//�Metodo EndQuery ( Classe TRSection )                                    �
	//�                                                                        �
	//�Prepara o relat�rio para executar o Embedded SQL.                       �
	//�                                                                        �
	//�ExpA1 : Array com os parametros do tipo Range                           �
	//�                                                                        �
	//��������������������������������������������������������������������������
	oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

	// Necessario, devido 'a funcao externa ca100RetCQ(), que utiliza outros campos de SCP
	TRPosition():New(oSection,"SCP",1,{|| xFilial("SCP")+(cAliasQRY)->CP_NUM+(cAliasQRY)->CP_ITEM })

#ELSE
	//������������������������������������������������������������������������Ŀ
	//�Transforma parametros Range em expressao Advpl                          �
	//��������������������������������������������������������������������������
	MakeAdvplExpr(oReport:uParam)

	cCondicao := 'CP_FILIAL == "'+xFilial("SCP")+'".And.' 
	cCondicao += 'CP_NUM >= "'+mv_par03+'".And.CP_NUM <="'+mv_par04+'".And.'
	cCondicao += 'Dtos(CP_EMISSAO) >= "'+Dtos(mv_par01)+'".And.Dtos(CP_EMISSAO) <="'+Dtos(mv_par02)+'"'
	
	oReport:Section(1):SetFilter(cCondicao,IndexKey())

#ENDIF		

//������������������������������������������������������������������������Ŀ
//�Inicio da impressao do fluxo do relat�rio                               �
//��������������������������������������������������������������������������

//oSection:Cell("CALCULO1"):Hide()
//oSection:Cell("CALCULO1"):HideHeader()
nLinBar := 0.60
		

cCode := (cAliasQRY)->CP_NUM
oReport:PrintText("")
MSBAR3("CODE128",nLinBar,13,Trim(cCode),@oReport:oPrint,Nil,Nil,Nil,Nil ,1 ,Nil,Nil,Nil,.F.)
oSection:Print()

/*
oPrn := tNewMSPrinter():New( 'Teste msBar' )
msBar3( 'CODE128', 2 , 08, '1234567', oPrn, .F., , .T., 0.025, 0.8, .F., 'TAHOMA', 'B', .F. )
oPrn:Preview()
*/


Return NIL



/*           
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � AjustaSX1 � Autor � Ricardo Berti      � Data � 24/05/2006 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Preenche conteudo das perguntas no SX1                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � AjustaSX1(ExpC1,ExpA1)             	                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Grupo do pergunte 		                          ���
���          � ExpA1 = Array com conteudo das perguntas                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MATR105                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function AjustaSX1(cPerg,aPerg)

Local nTamSX1 := Len(SX1->X1_GRUPO)
// Preenche a pergunta ref a data
dbSelectArea("SX1")
dbSetOrder(1)
If dbSeek(PADR(cPerg,nTamSX1)+"01")
	RecLock("SX1",.F.)
	Replace X1_CNT01 With DTOC(aPerg[1])
	MsUnLock()
EndIf
If dbSeek(PADR(cPerg,nTamSX1)+"02")
	RecLock("SX1",.F.)
	Replace X1_CNT01 With DTOC(aPerg[1])
	MsUnLock()
EndIf
// Preenche a pergunta ref. ao numero
If dbSeek(PADR(cPerg,nTamSX1)+"03")
	RecLock("SX1",.F.)
	Replace X1_CNT01 With aPerg[2]
	MsUnLock()
EndIf
If dbSeek(PADR(cPerg,nTamSX1)+"04")
	RecLock("SX1",.F.)
	Replace X1_CNT01 With aPerg[2]
	MsUnLock()
EndIf
Return Nil
          


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �Matr105R3 � Autor �  Edson Maricate       � Data �02.12.1998���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao das Solicitacoes ao Almoxarifado.                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Void MATR105                                                ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Patricia Sal�13/03/00�003022�Inclus. campos:Centro de Custo/Solicitante���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function MATR105R3(lMTR105,aPerg)

//������������������������������������������������������������������������Ŀ
//�Define Variaveis                                                        �
//��������������������������������������������������������������������������
Local Titulo  := OemToAnsi(STR0001) //"Posicao das Solicitacoes ao Almox."  // Titulo do Relatorio
Local cDesc1  := OemToAnsi(STR0002) //"  Este relatorio lista a posicao das SA's de acordo com os para-"  // Descricao 1
Local cDesc2  := OemToAnsi(STR0003) //"metros selecionados."  // Descricao 2
Local cDesc3  := ""  // Descricao 3
Local cString := "SCP"  // Alias utilizado na Filtragem
Local lDic    := .F. // Habilita/Desabilita Dicionario
Local lComp   := .T. // Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro := .T. // Habilita/Desabilita o Filtro
Local wnrel   := "MATR105"  // Nome do Arquivo utilizado no Spool
Local nomeprog:= "MATR105"  // nome do programa

Private Tamanho := "G" // P/M/G
Private Limite  := 220 // 80/132/220
Private aOrdem  := {}  // Ordem do Relatorio
Private cPerg   := "MTR105"  // Pergunta do Relatorio
Private aReturn := { STR0005, 1,STR0006, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
//[1] Reservado para Formulario
//[2] Reservado para N� de Vias
//[3] Destinatario
//[4] Formato => 1-Comprimido 2-Normal
//[5] Midia   => 1-Disco 2-Impressora
//[6] Porta ou Arquivo 1-LPT1... 4-COM1...
//[7] Expressao do Filtro
//[8] Ordem a ser selecionada
//[9]..[10]..[n] Campos a Processar (se houver)

Private lEnd    := .F.// Controle de cancelamento do relatorio
Private m_pag   := 1  // Contador de Paginas
Private nLastKey:= 0  // Controla o cancelamento da SetPrint e SetDefault

lMTR105 := If(ValType(lMTR105)#"L",.T.,lMTR105)

If !lMTR105 .And. ValType(aPerg) ==  "A"
	AjustaSX1(cPerg,aPerg)
EndIf
//������������������������������������������������������������������������Ŀ
//� Verifica as Perguntas Seleciondas                                      �
//� mv_par01  -  Da data      ?                                            �
//� mv_par02  -  Ate a data   ?                                            �
//� mv_par03  -  Numero de    ?                                            �
//� mv_par04  -  Numero Ate   ?                                            �
//��������������������������������������������������������������������������
Pergunte(cPerg,.F.)
If !lMTR105 .And. ValType(aPerg) ==  "A"
	MV_PAR01:= aPerg[1]
	MV_PAR02:= aPerg[1]
	MV_PAR03:= aPerg[2]
	MV_PAR04:= aPerg[2]
	//������������������������������������������������������������������������Ŀ
	//�Envia para a SetPrinter                                                 �
	//��������������������������������������������������������������������������
	wnrel:=SetPrint(cString,wnrel,"",@titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro)	
Else
	//������������������������������������������������������������������������Ŀ
	//�Envia para a SetPrinter                                                 �
	//��������������������������������������������������������������������������
	wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,lFiltro)
EndIf
If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	Set Filter to
	Return
Endif
SetDefault(aReturn,cString)
If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	Set Filter to
	Return
Endif
RptStatus({|lEnd| A105ImpDet(@lEnd,wnRel,cString,nomeprog,Titulo)},Titulo)

Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Program   �A105ImpDet� Autor �  Edson Maricate       � Data �02.12.1998���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime a linha detalhe do Relatorio.                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Matr105                                                    ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function A105ImpDet(lEnd,wnrel,cString,nomeprog,Titulo)

Local li      := 100 // Contador de Linhas
Local lImp    := .F. // Indica se algo foi impresso
Local cbCont  := 0   // Numero de Registros Processados
Local aRetCQ
Local cbText  := ""  // Mensagem do Rodape

Local cCabec1 := STR0008 //   "Numero  Item  Codigo             Descricao                        Emissao            Quantidade              Saldo        Qtd.Entregue   Requisicao    Centro de Custo    Solicitante"
Local cCabec2:=  ""      //    123456   12   123456789012345    123456789012345678901234567890   99/99/9999       999.999.999,99    999.999.999,99     999.999.999,99       123456    123456789012345     1234567890
//                              0         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
//                              01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
                                                                                                                                                                       
dbSelectArea(cString)
SetRegua(LastRec())
dbSetOrder(1)
dbSeek(xFilial()+mv_par03,.T.)

While (!Eof() .And. xFilial()==SCP->CP_FILIAL .And. SCP->CP_NUM >= mv_par03 .And. SCP->CP_NUM <= mv_par04)
	lImp := .T.
	If !(SCP->CP_EMISSAO >= mv_par01 .And. SCP->CP_EMISSAO <= mv_par02)
		dbSkip()
		loop
	EndIf
	If lEnd
		@ Prow()+1,001 PSAY STR0007 //"CANCELADO PELO OPERADOR"
		Exit
	EndIf
	If ( li > 60 )
		li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,If(aReturn[4]==1,15,18))
		li++
	Endif
	aRetCQ := ca100RetCQ(SCP->CP_NUM,SCP->CP_ITEM)
	@ li,000 PSay SCP->CP_NUM
	@ li,009 PSay SCP->CP_ITEM
	@ li,014 PSay SCP->CP_PRODUTO
	@ li,033 PSay Pad(SCP->CP_DESCRI, 30)
	@ li,066 PSay SCP->CP_EMISSAO
	@ li,083 PSay SCP->CP_QUANT	Picture PesqPict("SCP","CP_QUANT")
	@ li,102 PSay aRetCQ[1]		Picture PesqPict("SCP","CP_QUANT")
	@ li,121 PSay aRetCQ[7] 	Picture PesqPict("SCP","CP_QUANT")
	@ li,If(cPaisLoc$"BRA",141,136) PSay aRetCQ[6]
	@ li,151 PSay Padl(Alltrim(SCP->CP_CC),20)
	@ li,176 PSay SCP->CP_SOLICIT
	li++
	dbSelectArea(cString)
	dbSkip()
	cbCont++
	IncRegua()
EndDo

If ( lImp )
	Roda(cbCont,cbText,Tamanho)
EndIf
dbSelectArea(cString)
dbClearFilter()
dbSetOrder(1)
Set Printer To
If ( aReturn[5] = 1 )
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()
Return(.T.)