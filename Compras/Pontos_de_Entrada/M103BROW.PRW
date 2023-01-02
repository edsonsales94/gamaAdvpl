#include "rwmake.ch"

/*/

———————————————————————————————————————————————————————————————————————————————
@function		MT103BROW                                                     /@
@type				Ponto de Entrada                                              /@
@date				11/05/2015                                                    /@
@description	                                                              /@
@author			Vescio Pereira de Moura                                       /@
@use				Específico Brasitech                                          /@
———————————————————————————————————————————————————————————————————————————————

/*/
USER FUNCTION M103BROW()
AAdd( aRotina, {OemToAnsi("Incluir AR"), "U_SELEAR", 0, 4} ) 
Return