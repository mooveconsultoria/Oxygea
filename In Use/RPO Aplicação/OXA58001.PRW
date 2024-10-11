#INCLUDE "TOTVS.CH"
#Include "Topconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} OXA58001
ROTINA AUTOMATIZAÇÃO DE VERBA PREV '542'
@author  MOOVE - ELIELSON
@since   05/2024
@version 1.0
/*/
//-------------------------------------------------------------------
USER FUNCTION OXA58001(cAlias)

    Local nPosVerFn     := Ascan(Aheader,{|x| AllTrim(x[2]) == "RGB_PD" })
    Local nPosValFn     := Ascan(Aheader,{|x| AllTrim(x[2]) == "RGB_VALOR" })
    Local nPosQtdFn     := Ascan(Aheader,{|x| AllTrim(x[2]) == "RGB_HORAS" }) 
    Local nPosVerFx     := Ascan(Aheader,{|x| AllTrim(x[2]) == "RG1_PD" })
    Local nPosValFx     := Ascan(Aheader,{|x| AllTrim(x[2]) == "RG1_VALOR" })
    Local nPosQtdFx     := Ascan(Aheader,{|x| AllTrim(x[2]) == "RG1_REFER" })     
    Local nSalario      := 0
    Local lRet          := .T.
    Local aArea         := {}
    Local aSalario      := {}


    If cAlias == 'RGB'

        //Acao apenas para a verba LP 542 (definido pelo usuario)
        If aCols[N][nPosVerFn] == '542'

            //Guarda area de trabalho
            aArea   := GetArea()

            //Finaliza eventual area aberta
            If Select("cQry1") > 0
                cQry1->(DbCloseArea()) 
            EndIf

            //Pesquisa aumento de salario mais recente
            cQry := ""
            cQry += " SELECT SR3.R3_VALOR "
            cQry += " FROM SR3010 SR3 "
            cQry += " WHERE SR3.D_E_L_E_T_  = '' "
            cQry += " AND SR3.R3_MAT        = '"+cMat+"' "
            cQry += " AND SR3.R3_DATA       = "
            cQry += " ( "
            cQry += " SELECT MAX(SR31.R3_DATA)  FROM SR3010 SR31 "
            cQry += " WHERE SR31.D_E_L_E_T_ = '' "
            cQry += " AND SR31.R3_MAT       = '"+cMat+"' "
            cQry += " ) "

            TcQuery cQry Alias "cQry1" New        

            dbSelectArea("cQry1")
            cQry1->(dbgotop())

            //Armazena aumento de salario mais recente, se houver
            While cQry1->(!Eof())
                aadd(aSalario, cQry1->(R3_VALOR))
                cQry1->(dbskip())
            EndDo

            If !Empty(aSalario)
                nSalario    := aSalario[1]
            Else
                //Se nao houver historico de aumento de salario, pesquisa salario no cadastro do colaborador
                DbSelectArea('SRA')
                DbSetOrder(1)
                If DbSeek(xFilial("SRA")+cMat)
                    nSalario := SRA->RA_SALARIO
                Else
                    //Se nao hovuer salario no cadastro do colaborador, emite aviso
                    Help(NIL, NIL, "OXA58001", NIL, "Colaborador "+cMat+" não possui salário informado.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o campo Salávio do Cadastro de Funcionário."})
                    lRet      := .F.
                EndIf
            EndIf

            //Caso o campo acionado seja RGB_HORAS, faz o calculo do valor x horas
            If __READVAR == 'M->RGB_HORAS'

                If M->RGB_HORAS > 0
                    aCols[N][nPosValFn]   := nSalario * M->RGB_HORAS/100
                Else
                    //Se nao hovuer horas informada, emite aviso
                    Help(NIL, NIL, "OXA58001", NIL, "Quantidade de Horas inválida.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Informe um valor de Horas maior que '0'"})
                    lRet      := .F.
                EndIf

            //Caso o campo acionado seja RGB_VALOR, atualiza com o valor original nao permitindo valor nao calculado pela regra automatiada
            ElseIf __READVAR == 'M->RGB_VALOR'
                    aCols[N][nPosValFn] := nSalario * aCols[N][nPosQtdFn]/100
                    M->RGB_VALOR        := nSalario * aCols[N][nPosQtdFn]/100
            EndIf

        EndIf

    ElseIf cAlias == 'RG1'

        //Acao apenas para a verba 542 (definido pelo usuario)
        If aCols[N][nPosVerFx] == '542'

            //Guarda area de trabalho
            aArea   := GetArea()

            //Finaliza eventual area aberta
            If Select("cQry1") > 0
                cQry1->(DbCloseArea()) 
            EndIf

            //Pesquisa aumento de salario mais recente
            cQry := ""
            cQry += " SELECT SR3.R3_VALOR "
            cQry += " FROM SR3010 SR3 "
            cQry += " WHERE SR3.D_E_L_E_T_  = '' "
            cQry += " AND SR3.R3_MAT        = '"+cMat+"' "
            cQry += " AND SR3.R3_DATA       = "
            cQry += " ( "
            cQry += " SELECT MAX(SR31.R3_DATA)  FROM SR3010 SR31 "
            cQry += " WHERE SR31.D_E_L_E_T_ = '' "
            cQry += " AND SR31.R3_MAT       = '"+cMat+"' "
            cQry += " ) "

            TcQuery cQry Alias "cQry1" New        

            dbSelectArea("cQry1")
            cQry1->(dbgotop())

            //Armazena aumento de salario mais recente, se houver
            While cQry1->(!Eof())
                aadd(aSalario, cQry1->(R3_VALOR))
                cQry1->(dbskip())
            EndDo

            If !Empty(aSalario)
                nSalario    := aSalario[1]
            Else
                //Se nao houver historico de aumento de salario, pesquisa salario no cadastro do colaborador
                DbSelectArea('SRA')
                DbSetOrder(1)
                If DbSeek(xFilial("SRA")+cMat)
                    nSalario := SRA->RA_SALARIO
                Else
                    //Se nao hovuer salario no cadastro do colaborador, emite aviso
                    Help(NIL, NIL, "OXA58001", NIL, "Colaborador "+cMat+" não possui salário informado.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o campo Salávio do Cadastro de Funcionário."})
                    lRet      := .F.
                EndIf
            EndIf

            //Caso o campo acionado seja RG1_REFER, faz o calculo do valor x horas
            If __READVAR == 'M->RG1_REFER'

                If M->RG1_REFER > 0
                    aCols[N][nPosValFx]   := nSalario * M->RG1_REFER/100
                Else
                    //Se nao hovuer horas informada, emite aviso
                    Help(NIL, NIL, "OXA58001", NIL, "Quantidade de Horas inválida.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Informe um valor de Horas maior que '0'"})
                    lRet      := .F.
                EndIf

            //Caso o campo acionado seja RGB_VALOR, atualiza com o valor original nao permitindo valor nao calculado pela regra automatiada
            ElseIf __READVAR == 'M->RG1_VALOR'
                    aCols[N][nPosValFx] := nSalario * aCols[N][nPosQtdFx]/100
                    M->RGB_VALOR        := nSalario * aCols[N][nPosQtdFx]/100
            EndIf

        EndIf

        //Restaura area de trabalho
        RestArea(aArea)

    EndIf

Return lRet

