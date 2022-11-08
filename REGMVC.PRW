#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
 
//Variáveis Estáticas
Static cTitulo := "Regras para envio de boletos"
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} REGMVC
Rotina para cadastro de Regras para envio de boletos em MVC

https://terminaldeinformacao.com/2015/08/26/exemplos-de-rotinas-mvc-em-advpl/

@author    	Rogerio Oliveira
@version   	1.0
@since      24/09/2022
/*/
//-------------------------------------------------------------------------------------
 
User Function REGMVC()
    Local aArea   := GetArea()
    Local cFunBkp := FunName()
    Local oBrowse

    Private cAliasPai     := "ZD1"
    Private cAliasFilho   := "ZD2" 
    Private cSeq          := 000

    SetFunName("REGMVC")
         
    //Atualizando o dicionario de dados
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias(cAliasPai)
    oBrowse:SetDescription(cTitulo)
    oBrowse:Activate()

    SetFunName(cFunBkp)
    RestArea(aArea)

Return Nil
 
/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Rogerio Oliveira                                                |
 | Data:  24/09/2022                                                   |
 | Desc:  Criação do menu MVC                                          |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function MenuDef()
    Local aRot := {}
     
    //Adicionando opções
    ADD OPTION aRot TITLE 'Pesquisar'     ACTION 'PesqBrw'           OPERATION 1                      ACCESS 0 
    ADD OPTION aRot TITLE 'Visualizar'    ACTION 'VIEWDEF.REGMVC' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 
    ADD OPTION aRot TITLE 'Incluir'       ACTION 'VIEWDEF.REGMVC' OPERATION MODEL_OPERATION_INSERT ACCESS 0 
    ADD OPTION aRot TITLE 'Alterar'       ACTION 'VIEWDEF.REGMVC' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 
    ADD OPTION aRot TITLE 'Excluir'       ACTION 'VIEWDEF.REGMVC' OPERATION MODEL_OPERATION_DELETE ACCESS 0 
 
Return aRot
 
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Rogerio Oliveira                                                |
 | Data:  24/09/2022                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function ModelDef()
     
    //Criação da estrutura de dados utilizada na interface
    Local oModel     := Nil
    Local oStruPai   := FWFormStruct(1, cAliasPai)
    Local oStruFilho := FWFormStruct(1, cAliasFilho)
    Local aZD2Rel    := {}
    //Local aAux       := {}

    //aAux := FWStruTrigger('ZD1_PERVIG', 'ZD2_PERVIG', 'M->ZD1_PERVIG', 'ZD2')
    //oStruPai:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])
    

    //Criando o modelo e os relacionamentos
    oModel := MPFormModel():New('REGMVCM')
    oModel:AddFields('ZD1MASTER',/*cOwner*/,oStruPai)
    oModel:AddGrid('ZD2DETAIL','ZD1MASTER',oStruFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence

    //Fazendo o relacionamento entre o Pai e Filho
    aAdd(aZD2Rel, {'ZD2_FILIAL',    'ZD1_FILIAL'} )
    aAdd(aZD2Rel, {'ZD2_PERVIG',    'ZD1_PERVIG'}) 

    oModel:SetRelation('ZD2DETAIL', aZD2Rel, ZD2->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
    oModel:GetModel('ZD2DETAIL'):SetUniqueLine({"ZD2_FILIAL","ZD2_DATAVI","ZD2_SEQ"})    //Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
    oModel:SetPrimaryKey({})

    
    //Editando caracteristicas do dicionario
    oStruPai:SetProperty('ZD1_FILIAL', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.'))
    oStruPai:SetProperty('ZD1_FILIAL', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'xFilial("ZD1")'))
    oStruPai:SetProperty('ZD1_MES', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.'))

    //oStruFilho:SetProperty('ZD2_SEQ', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'U_GERASEQ()'))
    oStruFilho:SetProperty('ZD2_PERVIG', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'U_PREENCHEPERVIG("ZD1MASTER","ZD1_PERVIG")'))
    //oStruFilho:SetProperty('ZD2_PERVIG', MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN, '.F.'))
    
              
    //Setando as descrições
    oModel:SetDescription("Regras para envio de boletos - Mod. 3")
    oModel:GetModel('ZD1MASTER'):SetDescription('Modelo Regra')
    oModel:GetModel('ZD2DETAIL'):SetDescription('Modelo Itens da Regra')


Return oModel
 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Rogerio Oliveira                                                |
 | Data:  08/04/2021                                                   |
 | Desc:  Criação da visão MVC                                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
 
Static Function ViewDef()

    Local oView        := Nil
    Local oModel       := FWLoadModel('REGMVC')
    Local oStPai       := FWFormStruct(2, cAliasPai)
    Local oStFilho     := FWFormStruct(2, cAliasFilho)
        
    
    //Criando a View
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    //Adicionando os campos do cabeçalho e o grid dos filhos
    oView:AddField('VIEW_ZD1',oStPai,'ZD1MASTER')
    oView:AddGrid('VIEW_ZD2',oStFilho,'ZD2DETAIL')
     
    //Setando o dimensionamento de tamanho
    oView:CreateHorizontalBox('CABEC',30)
    oView:CreateHorizontalBox('GRID',70)
     
    //Amarrando a view com as box
    oView:SetOwnerView('VIEW_ZD1','CABEC')
    oView:SetOwnerView('VIEW_ZD2','GRID')
     
    //Habilitando título
    oView:EnableTitleView('VIEW_ZD1','Regra')
    oView:EnableTitleView('VIEW_ZD2','Itens')

Return oView

/*---------------------------------------------------------------------*
 | Func:  geraSeq                                                      |
 | Autor: Rogerio Oliveira                                             |
 | Data:  27/09/2022                                                   |
 | Desc:  Gera sequencial                                              |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/

User Function geraSeq()

    Local oModelDad  	:= FWModelActive()
	Local oModelGrid 	:= oModelDad:GetModel('ZD2DETAIL')
    Local dData         := FwFldGet("ZD2_DATAVI")
	local _nB           := 0
    Local nSeq          := 0
	

	For _nB := 1 To oModelGrid:Length()
		oModelGrid:GoLine( _nB )
        If dData = oModelGrid:GetValue('ZD2_DATAVI') .AND. !oModelGrid:IsDeleted(_nB)
            nSeq++
        Endif
    Next _nB


Return Strzero(nSeq,3)


/*---------------------------------------------------------------------*
 | Func:  preenchePervig                                               |
 | Autor: Rogerio Oliveira                                             |
 | Data:  29/10/2022                                                   |
 | Desc:  Preenche Periodo Vigencia                                    |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/

User Function preenchePervig(cMaster, cCampo)

    Local oModel := FwModelActive()
    Local _Valor := oModel:GetValue( cMaster, cCampo )
    /*você pode incluir outras validações*/
    
Return _Valor


/*---------------------------------------------------------------------*
 | Func:  retMes                                                       |
 | Autor: Rogerio Oliveira                                             |
 | Data:  30/10/2022                                                   |
 | Desc:  Retorna Mes                                                  |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/

User Function retMes(cParam)

    Local cDig := SubStr(cParam, 1, 2)
    Local cRet := ''

    IF cDig = '01'
        cRet := 'JANEIRO'
    ELSEIF cDig = '02'
        cRet := 'FEVEREIRO'
    ELSEIF cDig = '03'
        cRet := 'MARÇO'
    ELSEIF cDig = '04'
        cRet := 'ABRIL'
    ELSEIF cDig = '05'
        cRet := 'MAIO'
    ELSEIF cDig = '06'
        cRet := 'JUNHO'
    ELSEIF cDig = '07'
        cRet := 'JULHO'
    ELSEIF cDig = '08'
        cRet := 'AGOSTO'
    ELSEIF cDig = '09'
        cRet := 'SETEMBRO'
    ELSEIF cDig = '10'
        cRet := 'OUTUBRO'
    ELSEIF cDig = '11'
        cRet := 'NOVEMBRO'
    ELSEIF cDig = '12'
        cRet := 'DEZEMBRO'
    ELSE
        MsgAlert("Preencha corretamente o mês de vigencia!","Atenção")
    ENDIF
    
Return cRet

/*---------------------------------------------------------------------*
 | Func:  validaData                                                   |
 | Autor: Rogerio Oliveira                                             |
 | Data:  05/11/2022                                                   |
 | Desc:  Valida data                                                  |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/

User Function validaData()

    Local dData := FwFldGet("ZD2_DATAVI")
    Local cPer  := Alltrim(FwFldGet("ZD1_PERVIG"))
    Local cData := ''
    Local lRet  := .F.

    cData := DTOS(dData)
    If(SUBSTR(cData,5,2)+SUBSTR(cData,1,4) == cPer)
        lRet := .T.
    Else
        MsgAlert("Preencha corretamente a data!","Atenção")
    Endif

Return lRet


User Function validaValorDe()

	Local oModelDad  	:= FWModelActive()
	Local oModelGrid 	:= oModelDad:GetModel('ZD2DETAIL')
    Local nVlrDe        := FwFldGet("ZD2_VLRDE")
    Local dData         := FwFldGet("ZD2_DATAVI")
	local _nB           := 0
    Local lRet          := .T.
    Local aLinhas       := FWSaveRows()
	

	For _nB := 1 To oModelGrid:Length()
		oModelGrid:GoLine( _nB )
        If dData = oModelGrid:GetValue('ZD2_DATAVI')
            If nVlrDe >= oModelGrid:GetValue('ZD2_VLRDE') .AND. nVlrDe <= oModelGrid:GetValue('ZD2_VLRATE')
                lRet := .F.
                MsgAlert("Preencha corretamente o valor!","Atenção")
                Exit
            Endif
        Else
            Loop
        Endif
        //oModelGrid:SetValue('ZD2_VLRDE', nVlrDe)
    Next _nB

    FWRestRows(aLinhas)
    //oModelGrid:SetValue('ZD2_VLRDE', nVlrDe)

Return lRet


/*---------------------------------------------------------------------*
 | Func:  validaValor                                                  |
 | Autor: Rogerio Oliveira                                             |
 | Data:  05/11/2022                                                   |
 | Desc:  Valida valor ate                                             |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/

User Function 1validaValorAte()

    Local oModelDad  	:= FWModelActive()
	Local oModelGrid 	:= oModelDad:GetModel('ZD2DETAIL')
    Local nVlrAte       := FwFldGet("ZD2_VLRATE")
    Local dData         := FwFldGet("ZD2_DATAVI")
	local _nB           := 0
    Local aLinhas       := FWSaveRows()
    Local lRet          := .T.
	

	For _nB := 1 To oModelGrid:Length()
		oModelGrid:GoLine( _nB )
        If dData = oModelGrid:GetValue('ZD2_DATAVI')
            If _nB <> oModelGrid:Length()
                If nVlrAte >= oModelGrid:GetValue('ZD2_VLRDE') .AND. nVlrAte <= oModelGrid:GetValue('ZD2_VLRATE')
                    lRet := .F.
                    MsgAlert("Preencha corretamente o valor!","Atenção")
                    //oModelGrid:SetValue('ZD2_VLRATE', nVlrAte)
                    Exit
                Endif
            Endif
        Else
            Loop
        Endif
        //oModelGrid:SetValue('ZD2_VLRATE', nVlrAte)
    Next _nB

    FWRestRows(aLinhas)

Return lRet
