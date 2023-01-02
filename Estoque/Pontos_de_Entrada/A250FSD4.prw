#Include "PROTHEUS.Ch"

/*/{Protheus.doc} A250FSD4
    O Ponto de entrada e executado na tela de atualizacao do MATA250. 
    Utilizado para filtrar as requisições empenhadas na atualização do mesmo. 
    Um retorno logico (.T.) confirma a requisicao do empenho e um retorno falso não empenha o produto. 
    Se o retorno nao for logico o sistema ira assumir .T.(verdadeiro).
    Eventos
    @type  Function
    @author joni.santos
    @since 19/03/2021
    /*/


User Function A250FSD4()

Local lRet := .T.
Local cTipo := Posicione('SB1',1,xFilial('SB1')+SD4->D4_COD,'B1_TIPO')

IF cTipo$'BN'
	lRet:= .f.
Endif

Return lRet 
