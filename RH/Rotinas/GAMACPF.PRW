#INCLUDE "RWMAKE.CH"

User Function VerCpf()
area := Getarea()

DbselectArea("SRA")
DbsetOrder(5)

DbgoTop()

Dbseek(xFilial("SRA")+M->RA_CIC)

If Found() .and. RA_SITFOLH <> "D"

ALERT("ATENCAO -> Funcionario com CPF ja cadastrado...")
   Return(.F.)
Endif

RestArea(area)

Return(.T.)



