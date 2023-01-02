#include "rwmake.ch"        // incluido pelo assistente de conversao do AP6 IDE em 16/07/02

User Function bzinv00()       

SetPrvt("AREAANT,CSAVROW,CSAVCOL,CSAVCOR,CSAVSCR,CSAVEMENUH")
SetPrvt("CCURSOR,CCADASTRO,AROTINA,")

AreaAnt    := Alias()
cCadastro  := "Digitacao de Inventario"

aRotina := {{ "Pesquisa","AxPesqui"                    , 0 , 1},;
            { "Visualizar",'ExecBlock("bzinv04")'      , 0 , 2},;
            { "1a Contagem",'ExecBlock("bzinv01")'     , 0 , 3},;
            { "2a Contagem",'ExecBlock("bzinv01a")'    , 0 , 4},;
            { "3a Contagem",'ExecBlock("bzinv01b")'    , 0 , 4},;
            { "Conf.Invent.",'ExecBlock("bzinv05a")'   , 0 , 10, 20},; 
            { "Conf.Inv.Excell",'ExecBlock("COMPINV")'  , 0 , 10, 20},;             
            { "Saldo Valorizado",'ExecBlock("bzinv10")', 0 , 4},;            
            { "Conf.Digitacao",'ExecBlock("bzinv07")'  , 0 , 9, 20 },;
            { "Limpar Ficha",'ExecBlock("_bzinv08")'    , 0 , 6, 20 },;
            { "Legenda"    , "U_ZILEG1"   ,0,5 }}
            
            //{ "Altera",'ExecBlock("bzinv02")', 0 , 6, 20 },;
            //{ "Exclui",'ExecBlock("bzinv03")', 0 , 7, 20 },;

            //aCores := {{'LEFT(ZU_TIME,3)=="IMP"','ENABLE' } ,{'EMPTY(ZU_TIME)','BR_AZUL'},{'LEFT(ZU_TIME,1)=="C"','BR_VERMELHO'}}
            aCores := {{'ZU_ULTCONT==1','ENABLE' } ,{'ZU_ULTCONT==2','BR_AMARELO'},{'ZU_ULTCONT==3','BR_AZUL'}}



mBrowse(04,00,22,79,"SZU",,,,,,aCores)

dbSelectArea(AreaAnt)

Return nil

User Function ZILEG1()
/*
BrwLegenda("Status de Impressao","Legenda",{{"ENABLE"     ,"Etq.Impressa" },;
{"BR_AZUL","Nao Impressa" },;
{"BR_VERMELHO","Cancelada" } } )
*/
BrwLegenda("Status de Impressao","Legenda",{{"ENABLE"     ,"1a.Contagem" },;
											{"BR_AMARELO" ,"2a.Contagem" },;
											{"BR_AZUL"    ,"3a.Contagem" } } )

Return(.T.)