#Include 'Protheus.ch'


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} IGJUROS
Função que possibilita escolher forma de considerar o campo E4_ACRSFIN (JUROS SIMPLES OU JUROS COMPOSTOS)

@author    	Rogerio Oliveira
@version   	1.0
@since      18/06/2021

montante/v original -  1
/*/
//-------------------------------------------------------------------------------------

User Function IGJUROS()

Local aAreaAnt  := GetArea()
Local aAreaSE4  := SE4->(GetArea())
Local oOk       := LoadBitmap(GetResources(),"LBOK")
Local oNo       := LoadBitmap(GetResources(),"LBNO")
Local aListaJur	:= {}
Local lOk		:= .f.
Local oDlg
Local oList
Local cList
Local nI
Local nDias     := {}

Local oModel    := FWModelActive()
Local oModelE4  := oModel:GetModel("SE4MASTER")
Local oView     := FWViewActive()

aAdd(aListaJur,{.f.,"Juros simples", "001" })
aAdd(aListaJur,{.f.,"Juros compostos", "002" })

nDias := STRTOKARR(M->E4_COND, ",")


DEFINE MSDIALOG oDlg TITLE "Selecionar Tipo de Juros" FROM 000,000 TO 240,500 OF oMainWnd PIXEL

@ 010,010 LISTBOX oList VAR cList Fields HEADER "","Descrição" SIZE 230,080 ON DBLCLICK(unClick(aListaJur),aListaJur[oList:nAt,1]:=!aListaJur[oList:nAt,1],oList:Refresh()) NoScroll OF oDlg PIXEL
bLine := {|| {If(aListaJur[oList:nAt,1],oOk,oNo),aListaJur[oList:nAt,2]}}
oList:SetArray(aListaJur)
oList:bLine := bLine

@ 100,160 BUTTON "Confirmar" SIZE 035,010 FONT oDlg:oFont ACTION (ajustaAcrsFin(aListaJur[oList:nAt]), oDlg:End()) OF oDlg PIXEL
@ 100,205 BUTTON "Cancelar"  SIZE 035,010 FONT oDlg:oFont ACTION (.t., oDlg:End()) OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTERED


RestArea(aAreaAnt)
RestArea(aAreaSE4)

Return .T.




//-------------------------------------------------------------------------------------
/*/{Protheus.doc} unClick
Função para desmarcar os demais elementos do listbox

@author Rogerio Oliveira
@version   	1.0
@since 22/06/2021
/*/
//-------------------------------------------------------------------------------------
Static Function unClick(aListaJur)

For nI:=1 to Len(aListaJur)

	aListaJur[nI, 1] := .F.

Next nI

Return .T.



//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ajustaAcrsFin
Função para ajustar o cálculo de juros informado pelo usuario

@author Rogerio Oliveira
@version   	1.0
@since 22/06/2021
/*/
//-------------------------------------------------------------------------------------

Static Function ajustaAcrsFin(aListaJur)

Local vJur        := M->E4_ACRSFIN
Local cCod        := M->E4_CODIGO
Local dRef        := Date()
Local consValor   := 100.00
Local nVenc       := Condicao(consValor, cCod, 0, dRef, 0)

Local qntMeses    := 0.00


qntMeses := DateDiffDay(dRef, nVenc[len(nVenc)][1])
qntMeses := qntMeses/30

If(aListaJur[3] == "001")
    return .T.
Else
    oModelE4:LoadValue( "E4_ACRSFIN", 0.0 )
    oView:Refresh()

    vJur := Round( ( ((1 + (vJur/100)) ^ qntMeses) -1 ) * 100, 2 )
    M->E4_ACRSFIN   := vJur
    oModelE4:LoadValue( "E4_ACRSFIN", vJur )

    oView:Refresh()
Endif

return .T.

