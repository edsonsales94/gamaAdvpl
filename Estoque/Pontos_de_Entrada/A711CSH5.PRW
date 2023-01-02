#Include 'Protheus.ch' 
/*-
/*-------------------------------------------------------------------------------------
 ponto de entrada para manipulacao dos itens a serem gerados no mrp
 criado: Claudio Almeida	
 Data : 28/04/2015
 Objetivo: Analise de itens opcionais (os mesmo nao devem agregar necessidade 
--------------------------------------------------------------------------------------*/
User Function A711CSH5()
 Local dDataOri  :=PARAMIXB[1] 
 Local cProduto  :=PARAMIXB[2] 
 Local cOpc      :=PARAMIXB[3] 
 Local cRevisao  :=PARAMIXB[4] 
 Local cAliasMov :=PARAMIXB[5] 
 Local nRecno    :=PARAMIXB[6] 
 Local cDoc      :=PARAMIXB[7] 
 Local cItem     :=PARAMIXB[8] 
 Local cDocKey   :=PARAMIXB[9] 
 Local nQuant    :=PARAMIXB[10]
 Local cTipo711  :=PARAMIXB[11]
 Local lAddTree  :=PARAMIXB[12]
 Local lRevisao  :=PARAMIXB[13]
 Local cAliasTop :=PARAMIXB[14]
 //Aviso ("Aviso", "Ponto de Entrada: A711CSH5 ",{"Ok"}) //.. Customizacao do cliente

Return {dDataOri,cProduto,cOpc,cRevisao,cAliasMov,nRecno,cDoc,cItem,cDocKey,nQuant,cTipo711,lAddTree,lRevisao,cAliasTop}

