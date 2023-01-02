#include "rwmake.ch"
#include "protheus.ch"                                                                       	
/*/
———————————————————————————————————————————————————————————————————————————————
@function		Mt120FIL                                                     /@
@type			Ponto de entrada                                             /@
@date			26/11/2021                                                   /@
@description	utilizado para inserir um novo menu "FollowUp" no menu de    /@   
@               pedido de compras na qual chama o pedido posicionado na tela /@
@               e permite fazer apenas alterações em alguns campos.          /@
@               Funcão criada para atender a necessidade de manutenção de    /@
@               pedido de compras sem alterar o STATUS do PD para bloqueado. /@                                                                /@
@author			Ronaldo Silva                                                /@
@use			Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/

User Function MT120FIL()

Local lRet := .F.

If !( Alltrim(__cUserID) $ GetMv("BR_PCBLQ") ) 
	//Aviso("Usuário sem Acesso", "Usuário sem permissão para alterar Pedidos Aprovados!!!" , {"Ok"}, 2)
	lRet := .F.
Else
    aadd( aRotina,   { "FollowUp Pedido de Compras"      ,'ExecBlock("FollowUp",.F.,.F.)' , 0, 4} )
    lRet := .T.
Endif

Return( lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FollowUp  ºAutor  ³Ronaldo Silva       º Data ³  25/11/21   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de Follow Up Customizado.                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACOM                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function FollowUp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criação de variaveis                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nY := 1
Local _ni := 1
Local nUsado:= 0
Local aArea :=GetArea()
Local _nPrd    := 0
Local _nUm     := 0
Local _nPrf    := 0
Local _nQtd    := 0
Local _nPrc    := 0
Local _nLocal  := 0
Local _nTotal  := 0
Local _nNaturez:= 0
Local _nObs    := 0
Local _nCC     := 0    
Local _nConta  := 0     
Local _nTes    := 0  
Local cItem    := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcao de acesso para o Modelo 2                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// 3,4 Permitem alterar getdados e incluir linhas
// 6 So permite alterar getdados e nao incluir linhas
// Qualquer outro numero so visualiza
nOpcx:=4
                                                         	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando aHeader                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SC7")
nUsado:=0
aHeader:={}

While !Eof() .And. (x3_arquivo == "SC7")
    IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
   	   nUsado:=nUsado+1
       AADD(aHeader,{ TRIM(x3_titulo), AllTrim(x3_campo), x3_picture,;
            x3_tamanho, x3_decimal,".T.",;
      	  	x3_usado, x3_tipo, x3_arquivo, x3_context } )
    ENDIF                                 	
    dbSkip()
End
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montando aCols                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC7")
dbSetOrder(1)
cNumPed := SC7->C7_NUM
dbSeek(xFilial("SC7")+cNumPed)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis do Cabecalho do Modelo 2                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cNumPC   := SC7->C7_NUM
cForne   := SC7->C7_FORNECE
cLoja    := SC7->C7_LOJA
dData    := SC7->C7_EMISSAO
//ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÀÄÄÄÄÄÄÄÄÄ
aCols := {}
While !EOF() .AND. cNumPed==SC7->C7_NUM
	AADD(aCols,Array(nUsado+1))
	For _ni:=1 to nUsado
		//If Upper(AllTrim(aHeader[_ni,10])) != "V" // Campo Real
	        aCols[Len(aCols),_ni]:=FieldGet(FieldPos(aHeader[_ni,2]))
        //Else // Campo Virtual
        //    aCols[Len(aCols),_ni]:=CriaVar(aHeader[_ni,2])
        //Endif
     Next 
	aCols[Len(aCols),nUsado+1]:=.F.
	dbSkip()
EndDo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis do Rodape do Modelo 2                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLinGetD:=0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Titulo da Janela                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo:="FollowUp Pedido de Compras"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com descricao dos campos do Cabecalho do Modelo 2      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aC:={}
// aC[n,1] = Nome da Variavel Ex.:"cCliente"
// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aC[n,3] = Titulo do Campo
// aC[n,4] = Picture
// aC[n,5] = Validacao
// aC[n,6] = F3
// aC[n,7] = Se campo e' editavel .t. se nao .f.

AADD(aC,{"cNumPc"	,{15,10} ,"Numero Pedido"	,"@!"			,,,})
AADD(aC,{"cForne"	,{15,100} ,"Cod. do Fornecedor"	,"@!"			,,"SA2",})
AADD(aC,{"cLoja"	,{15,200},"Loja"			,"@!"			,,,})
AADD(aC,{"dData"	,{27,10} ,"Data de Emissao"	,				,,,})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com descricao dos campos do Rodape do Modelo 2         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aR:={}
// aR[n,1] = Nome da Variavel Ex.:"cCliente"
// aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
// aR[n,3] = Titulo do Campo
// aR[n,4] = Picture
// aR[n,5] = Validacao
// aR[n,6] = F3
// aR[n,7] = Se campo e' editavel .t. se nao .f.
AADD(aR,{"nLinGetD"	,{10,10},"Linha na GetDados"	,"@E 999",,,.F.})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array com coordenadas da GetDados no modelo2                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCGD:={34,5,118,315}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacoes na GetDados da Modelo 2                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cLinhaOk:=".T."
cTudoOk:=".T."
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chamada da Modelo2                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// lRetMod2 = .t. se confirmou 
// lRetMod2 = .f. se cancelou
lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpcx,cLinhaOk,cTudoOk)
// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
// objeto Getdados Corrente

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Coletando dados dos aHeader                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_nNumero := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_NUM"})
_nItem   := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_ITEM"})
_nSeq    := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_SEQUEN"})
_nPrd    := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRODUTO"})
_nUm     := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_UM"})
_nPrf    := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_DATPRF"})
_nQtd    := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_QUANT"})
_nPrc    := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRECO"})
_nLocal  := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_LOCAL"})
_nTotal  := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_TOTAL"})
_nNaturez:= aScan(aHeader,{|x| AllTrim(x[2]) == "C7_NATUREZ"}) 
_nObs    := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_OBS"})
_nCC     := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_CC"})   
_nConta  := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_CONTA"})    
_nTes    := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_TES"}) 


If lRetMod2
	For nY := 1 To Len(aCols)
        If !aCols[nY][Len(aHeader)+1]
            dbSelectArea("SC7")
            dbSetOrder(1)
		    If !dbSeek(xFilial("SC7")+cNumPed+aCols[nY,_nItem]) 
			    RecLock("SC7",.T.)
                SC7->C7_FILIAL  := xFilial("SC7")
                SC7->C7_NUM     := cNumPed
                SC7->C7_ITEM    := cItem
                SC7->C7_UM      := Posicione("SB1",1,XFILIAL("SB1")+aCols[nY,_nPrd],"SB1->B1_UM")
                SC7->C7_CONTA   := Posicione("SB1",1,XFILIAL("SB1")+aCols[nY,_nPrd],"SB1->B1_CONTA")
            Else
                RecLock("SC7",.F.)
            Endif
            SC7->C7_PRODUTO := aCols[nY,_nPrd]
			SC7->C7_DATPRF  := aCols[nY,_nPrf]
            SC7->C7_QUANT   := aCols[nY,_nQtd]
			SC7->C7_PRECO   := aCols[nY,_nPrc]
			SC7->C7_TOTAL   := aCols[nY,_nTotal]
			SC7->C7_LOCAL   := aCols[nY,_nLocal]
            SC7->C7_OBS     := aCols[nY,_nObs]
			SC7->C7_CC      := aCols[nY,_nCC]
            SC7->C7_TES     := aCols[nY,_nTes]
            
            cItem := Soma1(aCols[nY,_nItem], TamSX3("C7_ITEM")[1])
		    
            MsUnLock()
        Else
            //Exclusão de linhas deletadas 
            dbSelectArea("SC7")
            dbSetOrder(1)
			If dbSeek(xFilial("SC7")+aCols[nY,_nNumero]+aCols[nY,_nItem]+aCols[nY,_nSeq])
                RecLock("SC7",.F.)
                dbDelete()
                MsUnLock()
            Endif
        EndIf
    Next nY
    RestArea(aArea)
	Alert("Operacao finalizada com sucesso!")
Else
	Alert("Voce abortou a operacao!")
Endif

Return
