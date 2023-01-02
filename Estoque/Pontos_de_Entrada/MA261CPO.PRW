/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Ponto Entr³ MA261CPO ³ Por: Adalberto Moreno Batista ³ Data ³03.01.2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Adiciona campos no aHeader. Localizado nas funcoes         ³±±
±±³          ³ A261Visual(), A261Inclui() e A261Estorn()                  ³±±
±±³          ³ Chamado logo apos a criacao do array aHeader que controla  ³±±
±±³          ³ quais campos aparecerao no browse das transferencias. Pode ³±±
±±³          ³ ser utilizado para inclusao de campos no array ja menciona-³±±
±±³          ³ do, permitindo ao usuario incluir mais campos p/digitacao. ³±±
±±³          ³ O array aHeader e montado baseado em campos do arquivo SD3.³±±
±±³          ³                                                            ³±±
±±³          ³ Pontos de entrada Relacionados: MA261D3 e MA261IN          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico Brasitech                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
#include "Protheus.ch"

User Function MA261CPO()
Local aTam	 := TamSX3('D3_OBSERVA')
Local cUsado := Chr(0) + Chr(0) + Chr(1)

if SD3->( FieldPos('D3_OBSERVA') ) > 0
	aAdd(aHeader, {'Observacao' , 'D3_OBSERVA' , PesqPict('SD3', 'D3_OBSERVA' , aTam[1]) , aTam[1], aTam[2], '', cUsado, 'C', 'SD3', ''})
endif

Return()
