#include "protheus.ch"     

/*/
———————————————————————————————————————————————————————————————————————————————
@function	CN120ESY                                                     /@
@type		Ponto de entrada                                             /@
@date		23/10/2021                                                   /@
@description	Permite modificar query de pesquisa pata consulta padrão de 
                contratos na inclusão de medição.                            /@
@author		Adalberto Moreno Batista (amoreno@opcaoum.com.br)
		Opção Um Tecnologia                                          /@
@use		Brasitech                                                    /@
———————————————————————————————————————————————————————————————————————————————
/*/
User Function CN120ESY()
Local cQuery    := ParamIXB[1]
Local lPedVenda := IsInCallStack('A410KeyF9') .And. !Empty(M->C5_CLIENTE)
Local nPos      := At("UNION", Upper(cQuery)) 
Local cCod      := RetCodUsr()
Local cGrps     := ""
Local aGrp, nX

//———————————————————————————————————————————————————————————————————————————————
// Modifica a query de consulta dos contratos, adicionando o objeto do contrato
// Por: Adalberto Moreno Batista (Opção Um) em /10/2021
//———————————————————————————————————————————————————————————————————————————————
if !lPedVenda .and. nPos > 0 .and. CN9->(FieldPos("CN9_XOBJET")) > 0 .and. CN9->(FieldPos("CN9_XCNPJ")) > 0

    //———————————————————————————————————————————————————————————————————————————————
    // Carrega Grupos do usuario
    //———————————————————————————————————————————————————————————————————————————————
    aGrp := UsrRetGrp(UsrRetName(cCod))

    For nX:=1 to len(aGrp)
        cGrps += "'" + aGrp[nX] + "',"
    Next
    cGrps := SubStr(cGrps, 1, Len(cGrps)-1)

    cQuery :=   "SELECT CN9_NUMERO, MAX(CN9_REVISA) AS CN9_REVISA, CN9_FILCTR, CN9_XOBJET, CN9_XCNPJ " +;
                "FROM " +   RetSQLName("CN9") + " CN9, " +;
                            RetSQLName("CN1") + " CN1, " +;
                            RetSQLName("CNN") + " CNN, " +;
                            RetSQLName("CPD") + " CPD " +;
                "WHERE CN9.CN9_SITUAC = '05'  " +;
                        "AND CN9.CN9_FILCTR <> '  '  " +;
                        "AND CN9.CN9_REVATU = '   '  " +;
                        "AND CPD.CPD_FILAUT = '" + cFilAnt + "' " +; 
                        "AND CPD.CPD_FILIAL = CN9.CN9_FILIAL  " +;
                        "AND CPD.CPD_CONTRA = CN9.CN9_NUMERO  " +;
                        "AND ('" + DToS(dDataBase) + "' BETWEEN CN9_DTINIC AND CN9_DTFIM ) " +; 
                        "AND CNN.CNN_FILIAL = CN9_FILIAL  " +;
                        "AND CNN.CNN_CONTRA = CN9_NUMERO  " +;
                        "AND CN9_VLDCTR ='2'  " +;
                        "AND CNN.D_E_L_E_T_ = ' '  " +;
                        "AND CN9.D_E_L_E_T_ = ' '  " +;
                        "AND CPD.D_E_L_E_T_ = ' '  " +;
                "GROUP BY CN9_NUMERO, CN9_FILCTR, CN9_XOBJET, CN9_XCNPJ " +;
                "UNION " +;
                "SELECT CN9_NUMERO, MAX(CN9_REVISA) AS CN9_REVISA, CN9_FILCTR, CN9_XOBJET, CN9_XCNPJ " +;
                "FROM " +   RetSQLName("CN9") + " CN9, " +;
                            RetSQLName("CN1") + " CN1, " +;
                            RetSQLName("CNN") + " CNN, " +;
                            RetSQLName("CPD") + " CPD " +;
                "WHERE CN9.CN9_SITUAC = '05' " +;
                        "AND CN9.CN9_FILCTR <> '  ' " +;
                        "AND CN9.CN9_REVATU = '   ' " +;
                        "AND CPD.CPD_FILAUT = '" + cFilAnt + "' " +;
                        "AND CPD.CPD_FILIAL = CN9.CN9_FILIAL " +;
                        "AND CPD.CPD_CONTRA = CN9.CN9_NUMERO " +;
                        "AND ('" + DToS(dDataBase) + "' BETWEEN CN9_DTINIC AND CN9_DTFIM ) " +;
                        "AND CNN.CNN_FILIAL = CN9_FILIAL " +;
                        "AND CNN.CNN_CONTRA = CN9_NUMERO " +;
                        "AND CN9_VLDCTR IN(' ','1') " +;
                        "AND (CNN.CNN_USRCOD = '"+ cCod +"' " + iIf(Len(aGrp) > 0, " OR CNN.CNN_GRPCOD IN ("+ cGrps +")) ", ") ") +;
                        "AND CNN.D_E_L_E_T_ = ' ' " +;
                        "AND CN9.D_E_L_E_T_ = ' ' " +;
                        "AND CPD.D_E_L_E_T_ = ' ' " +;
                "GROUP BY CN9_NUMERO, CN9_FILCTR, CN9_XOBJET, CN9_XCNPJ " +;
                "ORDER BY CN9_NUMERO, CN9_REVISA, CN9_FILCTR "
endif

Return(cQuery)
