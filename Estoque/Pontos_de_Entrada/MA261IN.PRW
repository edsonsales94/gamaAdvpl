/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Ponto Entr³ MA261IN  ³ Por: Adalberto Moreno Batista ³ Data ³03.01.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Preenche valores de campos na tela de estorno              ³±±
±±³          ³ Localizado nas funcoes A261Visual(), A261Inclui() e        ³±±
±±³          ³ A261Estorn().                                              ³±±
±±³          ³ Chamado apos a montagem do array aCols com as linhas do    ³±±
±±³          ³ browse das transferencias, nas rotinas de visualizacao e   ³±±
±±³          ³ estorno de transferencias. Pode ser utilizado para preen-  ³±±
±±³          ³ chimento dos valores de campos que o usuario queira apre-  ³±±
±±³          ³ sentar na tela.Nao esquecer de verificar a posicao correta ³±±
±±³          ³ do campo a ter o valor atribuido no array aCols. A melhor  ³±±
±±³          ³ forma de fazer isto e verificando a posicao correta atraves³±±
±±³          ³ de pesquisa no array aHeader.                              ³±±
±±³          ³                                                            ³±±
±±³          ³ Pontos de entrada Relacionados: MA261CPO e MA261D3         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Brasitech                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
#include "Protheus.ch"

User Function MA261IN()
Local aArea			:= GetArea()
Local aAreaSD3		:= SD3->(GetArea())
Local nPosOBSERVA	:= aScan( aHeader, { |x| AllTrim( Upper( x[2] ) ) == 'D3_OBSERVA' } )
Local nPosNUMSEQ	:= aScan( aHeader, { |x| AllTrim( Upper( x[2] ) ) == 'D3_NUMSEQ' } )

SD3->( dbSetOrder(4) )		//D3_FILIAL+D3_NUMSEQ+D3_CHAVE+D3_COD
SD3->( dbSeek( xFilial("SD3") + aCols[ Len( aCols ), nPosNUMSEQ ] ) )

aCols[ Len( aCols ), nPosOBSERVA ]		:= SD3->D3_OBSERVA

RestArea(aAreaSD3)
RestArea(aArea)
Return()
