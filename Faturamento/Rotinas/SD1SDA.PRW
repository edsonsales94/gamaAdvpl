#include 'Protheus.ch'

//*****************************
/*/{Protheus.doc} ACOM016
Rotina para gerar endereçamento automatico para o produto.

@author Lucas
@since 24/03/2017F
@version 1.0

@param cOpc, characters, Opções I = Incluir | D = Deletar

@type function
/*/
//*****************************
User Function ACOM016( cOpc )

do case
case cOpc == 'I'
ACOM016I()
// fim case

case cOpc == 'D'
If ApMsgYesNo('Deseja realmente estornar os endereçamentos?', 'Documento de Entrada')
ACOM016D()
endif
// fim case
endcase

Return

//*****************************
/*/{Protheus.doc} ACOM016I
Utiliza a opção de endereçar do MATA265 padrão.

@author Lucas
@since 28/03/2017
@version 1.0

@type function
/*/
//*****************************
Static Function ACOM016I()

Local cAlias := ''
Local aCabSDA := {}
Local aItSDB := {}
Local aItensSDB := {}
Local nCount := 0

Private lMsErroAuto := .F.

cAlias := getNextAlias()
BeginSql Alias cAlias
SELECT
SD1.D1_COD, SDA.DA_NUMSEQ, SD1.D1_ENDER, SDA.DA_LOCAL,
SD1.D1_QUANT, SDA.DA_SALDO
FROM
%TABLE:SD1% SD1
INNER JOIN %TABLE:SDA% SDA ON
SDA.DA_FILIAL = SD1.D1_FILIAL
AND SDA.DA_DOC = SD1.D1_DOC
AND SDA.DA_SERIE = SD1.D1_SERIE
AND SDA.DA_CLIFOR = SD1.D1_FORNECE
AND SDA.DA_LOJA = SD1.D1_LOJA
AND SDA.DA_LOCAL = SD1.D1_LOCAL
AND SDA.DA_ORIGEM = %EXP:'SD1'%
AND SDA.DA_SALDO > %EXP:0%
AND SDA.%NOTDEL%
WHERE
SD1.D1_FILIAL = %EXP:SF1->F1_FILIAL%
AND SD1.D1_DOC = %EXP:SF1->F1_DOC%
AND SD1.D1_SERIE = %EXP:SF1->F1_SERIE%
AND SD1.D1_FORNECE = %EXP:SF1->F1_FORNECE%
AND SD1.D1_LOJA = %EXP:SF1->F1_LOJA%
AND SD1.D1_ENDER <> %EXP:SPACE(TAMSX3('D1_ENDER')[1])%
AND SD1.%NOTDEL%
EndSQl

(cAlias)->(dbEval( { || nCount++ } ))
(cAlias)->(dbGoTop())

if nCount == 0
alert('Sem itens disponíveis para o endereçamento!')
else
dbSelectArea('SDA')
SDA->(dbSetOrder(1))

ProcRegua( nCount )
processMessage()

while !(cAlias)->(EOF())
incProc('Produto: ' + allTrim((cAlias)->D1_COD) + ' – Sequencial: ' + (cAlias)->DA_NUMSEQ )
processMessage()

SDA->(dbGoTop()) // posiciona o cabeçalho
if SDA->(dbSeek( xfilial('SDA') + (cAlias)->D1_COD + (cAlias)->DA_LOCAL + (cAlias)->DA_NUMSEQ + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ))
if SDA->DA_SALDO > 0
lMsErroAuto := .F.

aCabSDA := {}
aAdd( aCabSDA, {'DA_PRODUTO' ,SDA->DA_PRODUTO, Nil} )
aAdd( aCabSDA, {'DA_NUMSEQ' ,SDA->DA_NUMSEQ , Nil} )

aItSDB := {}
aAdd( aItSDB, {'DB_ITEM' , '0001' , Nil} )
aAdd( aItSDB, {'DB_ESTORNO', ' ' , Nil} )
aAdd( aItSDB, {'DB_LOCALIZ', (cAlias)->D1_ENDER, Nil} )
aAdd( aItSDB, {'DB_DATA' , dDataBase , Nil} )
aAdd( aItSDB, {'DB_QUANT' , SDA->DA_SALDO , Nil} )

aItensSDB := {}
aadd( aItensSDB, aitSDB )
MATA265( aCabSDA, aItensSDB, 3)
endif
endif

(cAlias)->(dbSkip())
enddo
endif
(cAlias)->(dbCloseArea())

Return

//*****************************
/*/{Protheus.doc} ACOM016D
Realiza o estorno se houver algo a estornar

@author Lucas
@since 28/03/2017
@version 1.0

@type function
/*/
//*****************************
Static Function ACOM016D()

Local cAlias := ''
Local aCabSDA := {}
Local aItSDB := {}
Local aItensSDB := {}
Local nCount := 0

Private lMsErroAuto := .F.

cAlias := getNextAlias()
BeginSql Alias cAlias
SELECT
SD1.D1_COD, SDA.DA_NUMSEQ, SDB.DB_LOCALIZ,
SDB.DB_QUANT, SDB.DB_ITEM, SDB.DB_NUMSEQ,
SDA.DA_LOCAL
FROM
%TABLE:SD1% SD1
INNER JOIN %TABLE:SDA% SDA ON
SDA.DA_FILIAL = SD1.D1_FILIAL
AND SDA.DA_DOC = SD1.D1_DOC
AND SDA.DA_SERIE = SD1.D1_SERIE
AND SDA.DA_CLIFOR = SD1.D1_FORNECE
AND SDA.DA_LOJA = SD1.D1_LOJA
AND SDA.DA_LOCAL = SD1.D1_LOCAL
AND SDA.DA_ORIGEM = %EXP:'SD1'%
AND SDA.%NOTDEL%
INNER JOIN %TABLE:SDB% SDB ON
SDB.DB_FILIAL = SDA.DA_FILIAL
AND SDB.DB_PRODUTO = SDA.DA_PRODUTO
AND SDB.DB_DOC = SDA.DA_DOC
AND SDB.DB_SERIE = SDA.DA_SERIE
AND SDB.DB_CLIFOR = SDA.DA_CLIFOR
AND SDB.DB_LOJA = SDA.DA_LOJA
AND SDB.DB_ESTORNO = %EXP:' '%
AND SDB.%NOTDEL%
WHERE
SD1.D1_FILIAL = %EXP:SF1->F1_FILIAL%
AND SD1.D1_DOC = %EXP:SF1->F1_DOC%
AND SD1.D1_SERIE = %EXP:SF1->F1_SERIE%
AND SD1.D1_FORNECE = %EXP:SF1->F1_FORNECE%
AND SD1.D1_LOJA = %EXP:SF1->F1_LOJA%
AND SD1.%NOTDEL%
EndSQl

(cAlias)->(dbEval( { || nCount++ } ))
(cAlias)->(dbGoTop())

if nCount == 0
alert('Sem itens disponíveis para o estorno!')
else
dbSelectArea('SDA')
SDA->(dbSetOrder(1))

dbSelectArea('SDB')
SDB->(dbSetOrder(1))

ProcRegua( nCount )
processMessage()

while !(cAlias)->(EOF())
incProc('Produto: ' + allTrim((cAlias)->D1_COD) + ' – Sequencia: ' + allTrim( (cAlias)->DA_NUMSEQ ) + ' – Item: ' + allTrim( (cAlias)->DB_ITEM ) )
processMessage()

SDA->(dbGoTop()) // posiciona o cabeçalho
if SDA->(dbSeek( xfilial('SDA') + (cAlias)->D1_COD + (cAlias)->DA_LOCAL + (cAlias)->DA_NUMSEQ + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA ))

SDB->(dbGoTop()) // posiciona o item
if SDB->( dbSeek( xfilial('SDB') + (cAlias)->D1_COD + (cAlias)->DA_LOCAL + (cAlias)->DB_NUMSEQ + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA + (cAlias)->DB_ITEM ) )
lMsErroAuto := .F.

aCabSDA := {}
aAdd( aCabSDA, {'DA_PRODUTO' ,(cAlias)->D1_COD , Nil} )
aAdd( aCabSDA, {'DA_NUMSEQ' ,(cAlias)->DA_NUMSEQ , Nil} )

aItSDB := {}
aAdd( aItSDB, {'DB_ITEM' , (cAlias)->DB_ITEM , Nil} )
aAdd( aItSDB, {'DB_ESTORNO', 'S' , Nil} )
aAdd( aItSDB, {'DB_LOCALIZ', (cAlias)->DB_LOCALIZ, Nil} )
aAdd( aItSDB, {'DB_DATA' , dDataBase , Nil} )
aAdd( aItSDB, {'DB_QUANT' , (cAlias)->DB_QUANT , Nil} )

aItensSDB := {}
aadd( aItensSDB, aitSDB )
MATA265( aCabSDA, aItensSDB, 4)
endif
endif

(cAlias)->(dbSkip())
enddo
endif
(cAlias)->(dbCloseArea())

Return

