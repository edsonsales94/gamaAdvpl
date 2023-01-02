/*/{Protheus.doc} User Function F677USERMENU
    (Ponto de entrada para acrescentar botões no menu da rotian FINA677)
    @type  Function
    @author AOliveira
    @since 07/04/2022
    @version 1.0
/*/
User Function F677USERMENU()
Local aRet := {}

aadd(aRet,{"Reenvio WF-RDV","u_XWF677D()" , 0 , 3,0,NIL})

Return aRet
