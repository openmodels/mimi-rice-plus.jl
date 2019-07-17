using Mimi

@defcomp welfare begin
    regions = Index()

    PERIODU = Variable(index=[time, regions]) # One period utility function         --> utility of an individual in a given period (without discounting)
    CEMUTOTPER = Variable(index=[time, regions]) # Period utility                   --> sum of all individuals' utilities (i.e. regional/country utility) in a given period (with discounting)
    REGCUMCEMUTOTPER = Variable(index=[time, regions]) # Cumulative period utility  --> cumulative regional utility over time
    REGUTILITY = Variable(index=[regions]) # Welfare Function                       --> rescaled cumulative regional utility over time (in the last period)
    UTILITY = Variable() # Total aggregate utility                                  --> sum of rescaled cumulative regional utility over time

    CPC = Parameter(index=[time, regions]) # Per capita consumption (thousands 2005 USD per year)
    l = Parameter(index=[time, regions]) # Level of population and labor
    elasmu = Parameter(index=[regions]) # Elasticity of marginal utility of consumption
    rr = Parameter(index=[time, regions]) # Average utility social discount rate
    scale1 = Parameter(index=[regions]) # Multiplicative scaling coefficient
    scale2 = Parameter(index=[regions]) # Additive scaling coefficient
    alpha = Parameter(index=[time, regions])

                # NEW: WORLD-LEVEL
                UTILITYctryagg = Variable()

                # NEW: COUNTRY-LEVEL
                PERIODUctry = Variable(index=[time, countries]) # One period utility function
                CEMUTOTPERctry = Variable(index=[time, countries]) # Period utility
                REGCUMCEMUTOTPERctry = Variable(index=[time, countries]) # Cumulative period utility
                REGUTILITYctry = Variable(index=[countries]) # Welfare Function

                CPCctry = Parameter(index=[time, countries]) # Per capita consumption (thousands 2005 USD per year)
                lctry = Parameter(index=[time, countries]) # Level of population and labor

                inregion = Parameter(index=[countries]) # attributing a country to the region it belongs to

                UTILITYctryaggnorescale = Variable()
                REGUTILITYctrynorescale = Variable(index=[countries]) # Welfare Function

                # NEW: NO NEGISHI WEIGHTS & NO RESCALING
                PERIODUNOnegishi = Variable(index=[time, regions]) # One period utility function
                CEMUTOTPERNOnegishi = Variable(index=[time, regions]) # Period utility
                REGCUMCEMUTOTPERNOnegishi = Variable(index=[time, regions]) # Cumulative period utility
                REGUTILITYNOnegishiNOrescale = Variable(index=[regions]) # Welfare Function
                UTILITYNOnegishiNOrescale = Variable() # Total aggregate utility

                PERIODUctryNOnegishi = Variable(index=[time, countries]) # One period utility function
                CEMUTOTPERctryNOnegishi = Variable(index=[time, countries]) # Period utility
                REGCUMCEMUTOTPERctryNOnegishi = Variable(index=[time, countries]) # Cumulative period utility
                REGUTILITYctryNOnegishiNOrescale = Variable(index=[countries]) # Welfare Function
                UTILITYctryaggNOnegishiNOrescale = Variable() # Total aggregate utility

                # NEW: NO NEGISHI WEIGHTS & NO RESCALING - PER CAPITA
                CEMUTOTPERNOnegishiPC = Variable(index=[time, regions]) # Period utility
                REGCUMCEMUTOTPERNOnegishiPC = Variable(index=[time, regions]) # Cumulative period utility
                REGUTILITYNOnegishiNOrescalePC = Variable(index=[regions]) # Welfare Function
                UTILITYNOnegishiNOrescalePC = Variable() # Total aggregate utility

                CEMUTOTPERctryNOnegishiPC = Variable(index=[time, countries]) # Period utility
                REGCUMCEMUTOTPERctryNOnegishiPC = Variable(index=[time, countries]) # Cumulative period utility
                REGUTILITYctryNOnegishiNOrescalePC = Variable(index=[countries]) # Welfare Function
                UTILITYctryaggNOnegishiNOrescalePC = Variable() # Total aggregate utility

    function run_timestep(p, v, d, t)

########################################################################################################################################################
#### PERIODU - utility of an individual in a given period (without discounting) ########################################################################
########################################################################################################################################################


        #Define function for PERIODU #NEED TO ADD IF STATEMENT LIKE IN JUMP MODEL OR IS THAT ONLY ISSUES WHEN ELASMU = 1.0?
        for r in d.regions
            if p.elasmu[r]==1.
                v.PERIODU[t,r] = log(p.CPC[t,r]) * p.alpha[t,r]
            else
                v.PERIODU[t,r] = ((1. / (1. - p.elasmu[r])) * (p.CPC[t,r])^(1. - p.elasmu[r]) + 1.) * p.alpha[t,r]
            end
        end

                                    # NEW: Define function for PERIODU without NEGISHI weights
                                    for r in d.regions
                                        if p.elasmu[r]==1.
                                            v.PERIODUNOnegishi[t,r] = log(p.CPC[t,r])
                                        else
                                            v.PERIODUNOnegishi[t,r] = ((1. / (1. - p.elasmu[r])) * (p.CPC[t,r])^(1. - p.elasmu[r]) + 1.)
                                        end
                                    end

                    # NEW: COUNTRY-LEVEL - Define function for PERIODU #NEED TO ADD IF STATEMENT LIKE IN JUMP MODEL OR IS THAT ONLY ISSUES WHEN ELASMU = 1.0?
                    for c in d.countries
                        if p.inregion[c] == 1
                            if p.elasmu[1]==1
                                v.PERIODUctry[t,c] = log(p.CPCctry[t,c]) * p.alpha[t,1]
                            else
                                v.PERIODUctry[t,c] = ((1. / (1. - p.elasmu[1])) * (p.CPCctry[t,c])^(1. - p.elasmu[1]) + 1.) * p.alpha[t,1]
                            end
                        elseif p.inregion[c] == 2
                            if p.elasmu[2]==1
                                v.PERIODUctry[t,c] = log(p.CPCctry[t,c]) * p.alpha[t,2]
                            else
                                v.PERIODUctry[t,c] = ((1. / (1. - p.elasmu[2])) * (p.CPCctry[t,c])^(1. - p.elasmu[2]) + 1.) * p.alpha[t,2]
                            end
                        elseif p.inregion[c] == 3
                            if p.elasmu[2]==1
                                v.PERIODUctry[t,c] = log(p.CPCctry[t,c]) * p.alpha[t,2]
                            else
                                v.PERIODUctry[t,c] = ((1. / (1. - p.elasmu[3])) * (p.CPCctry[t,c])^(1. - p.elasmu[3]) + 1.) * p.alpha[t,3]
                            end
                        elseif p.inregion[c] == 4
                            if p.elasmu[2]==1
                                v.PERIODUctry[t,c] = log(p.CPCctry[t,c]) * p.alpha[t,2]
                            else
                                v.PERIODUctry[t,c] = ((1. / (1. - p.elasmu[4])) * (p.CPCctry[t,c])^(1. - p.elasmu[4]) + 1.) * p.alpha[t,4]
                            end
                        elseif p.inregion[c] == 5
                            if p.elasmu[2]==1
                                v.PERIODUctry[t,c] = log(p.CPCctry[t,c]) * p.alpha[t,2]
                            else
                                v.PERIODUctry[t,c] = ((1. / (1. - p.elasmu[5])) * (p.CPCctry[t,c])^(1. - p.elasmu[5]) + 1.) * p.alpha[t,5]
                            end
                        elseif p.inregion[c] == 6
                            if p.elasmu[2]==1
                                v.PERIODUctry[t,c] = log(p.CPCctry[t,c]) * p.alpha[t,2]
                            else
                                v.PERIODUctry[t,c] = ((1. / (1. - p.elasmu[6])) * (p.CPCctry[t,c])^(1. - p.elasmu[6]) + 1.) * p.alpha[t,6]
                            end
                        elseif p.inregion[c] == 7
                            if p.elasmu[2]==1
                                v.PERIODUctry[t,c] = log(p.CPCctry[t,c]) * p.alpha[t,2]
                            else
                                v.PERIODUctry[t,c] = ((1. / (1. - p.elasmu[7])) * (p.CPCctry[t,c])^(1. - p.elasmu[7]) + 1.) * p.alpha[t,7]
                            end
                        elseif p.inregion[c] == 8
                            if p.elasmu[2]==1
                                v.PERIODUctry[t,c] = log(p.CPCctry[t,c]) * p.alpha[t,2]
                            else
                                v.PERIODUctry[t,c] = ((1. / (1. - p.elasmu[8])) * (p.CPCctry[t,c])^(1. - p.elasmu[8]) + 1.) * p.alpha[t,8]
                            end
                        elseif p.inregion[c] == 9
                            if p.elasmu[2]==1
                                v.PERIODUctry[t,c] = log(p.CPCctry[t,c]) * p.alpha[t,2]
                            else
                                v.PERIODUctry[t,c] = ((1. / (1. - p.elasmu[9])) * (p.CPCctry[t,c])^(1. - p.elasmu[9]) + 1.) * p.alpha[t,9]
                            end
                        elseif p.inregion[c] == 10
                            if p.elasmu[2]==1
                                v.PERIODUctry[t,c] = log(p.CPCctry[t,c]) * p.alpha[t,2]
                            else
                                v.PERIODUctry[t,c] = ((1. / (1. - p.elasmu[10])) * (p.CPCctry[t,c])^(1. - p.elasmu[10]) + 1.) * p.alpha[t,10]
                            end
                        elseif p.inregion[c] == 11
                            if p.elasmu[2]==1
                                v.PERIODUctry[t,c] = log(p.CPCctry[t,c]) * p.alpha[t,2]
                            else
                                v.PERIODUctry[t,c] = ((1. / (1. - p.elasmu[11])) * (p.CPCctry[t,c])^(1. - p.elasmu[11]) + 1.) * p.alpha[t,11]
                            end
                        elseif p.inregion[c] == 12
                            if p.elasmu[2]==1
                                v.PERIODUctry[t,c] = log(p.CPCctry[t,c]) * p.alpha[t,2]
                            else
                                v.PERIODUctry[t,c] = ((1. / (1. - p.elasmu[12])) * (p.CPCctry[t,c])^(1. - p.elasmu[12]) + 1.) * p.alpha[t,12]
                            end
                        else
                            println("country does not belong to any region")
                        end
                    end


                                    # NEW: COUNTRY-LEVEL - Define function for PERIODU without NEGISHI weights
                                    for c in d.countries
                                        if p.inregion[c] == 1
                                            if p.elasmu[1]==1
                                                v.PERIODUctryNOnegishi[t,c] = log(p.CPCctry[t,c])
                                            else
                                                v.PERIODUctryNOnegishi[t,c] = ((1. / (1. - p.elasmu[1])) * (p.CPCctry[t,c])^(1. - p.elasmu[1]) + 1.)
                                            end
                                        elseif p.inregion[c] == 2
                                            if p.elasmu[2]==1
                                                v.PERIODUctryNOnegishi[t,c] = log(p.CPCctry[t,c])
                                            else
                                                v.PERIODUctryNOnegishi[t,c] = ((1. / (1. - p.elasmu[2])) * (p.CPCctry[t,c])^(1. - p.elasmu[2]) + 1.)
                                            end
                                        elseif p.inregion[c] == 3
                                            if p.elasmu[2]==1
                                                v.PERIODUctryNOnegishi[t,c] = log(p.CPCctry[t,c])
                                            else
                                                v.PERIODUctryNOnegishi[t,c] = ((1. / (1. - p.elasmu[3])) * (p.CPCctry[t,c])^(1. - p.elasmu[3]) + 1.)
                                            end
                                        elseif p.inregion[c] == 4
                                            if p.elasmu[2]==1
                                                v.PERIODUctryNOnegishi[t,c] = log(p.CPCctry[t,c])
                                            else
                                                v.PERIODUctryNOnegishi[t,c] = ((1. / (1. - p.elasmu[4])) * (p.CPCctry[t,c])^(1. - p.elasmu[4]) + 1.)
                                            end
                                        elseif p.inregion[c] == 5
                                            if p.elasmu[2]==1
                                                v.PERIODUctryNOnegishi[t,c] = log(p.CPCctry[t,c])
                                            else
                                                v.PERIODUctryNOnegishi[t,c] = ((1. / (1. - p.elasmu[5])) * (p.CPCctry[t,c])^(1. - p.elasmu[5]) + 1.)
                                            end
                                        elseif p.inregion[c] == 6
                                            if p.elasmu[2]==1
                                                v.PERIODUctryNOnegishi[t,c] = log(p.CPCctry[t,c])
                                            else
                                                v.PERIODUctryNOnegishi[t,c] = ((1. / (1. - p.elasmu[6])) * (p.CPCctry[t,c])^(1. - p.elasmu[6]) + 1.)
                                            end
                                        elseif p.inregion[c] == 7
                                            if p.elasmu[2]==1
                                                v.PERIODUctryNOnegishi[t,c] = log(p.CPCctry[t,c])
                                            else
                                                v.PERIODUctryNOnegishi[t,c] = ((1. / (1. - p.elasmu[7])) * (p.CPCctry[t,c])^(1. - p.elasmu[7]) + 1.)
                                            end
                                        elseif p.inregion[c] == 8
                                            if p.elasmu[2]==1
                                                v.PERIODUctryNOnegishi[t,c] = log(p.CPCctry[t,c])
                                            else
                                                v.PERIODUctryNOnegishi[t,c] = ((1. / (1. - p.elasmu[8])) * (p.CPCctry[t,c])^(1. - p.elasmu[8]) + 1.)
                                            end
                                        elseif p.inregion[c] == 9
                                            if p.elasmu[2]==1
                                                v.PERIODUctryNOnegishi[t,c] = log(p.CPCctry[t,c])
                                            else
                                                v.PERIODUctryNOnegishi[t,c] = ((1. / (1. - p.elasmu[9])) * (p.CPCctry[t,c])^(1. - p.elasmu[9]) + 1.)
                                            end
                                        elseif p.inregion[c] == 10
                                            if p.elasmu[2]==1
                                                v.PERIODUctryNOnegishi[t,c] = log(p.CPCctry[t,c])
                                            else
                                                v.PERIODUctryNOnegishi[t,c] = ((1. / (1. - p.elasmu[10])) * (p.CPCctry[t,c])^(1. - p.elasmu[10]) + 1.)
                                            end
                                        elseif p.inregion[c] == 11
                                            if p.elasmu[2]==1
                                                v.PERIODUctryNOnegishi[t,c] = log(p.CPCctry[t,c])
                                            else
                                                v.PERIODUctryNOnegishi[t,c] = ((1. / (1. - p.elasmu[11])) * (p.CPCctry[t,c])^(1. - p.elasmu[11]) + 1.)
                                            end
                                        elseif p.inregion[c] == 12
                                            if p.elasmu[2]==1
                                                v.PERIODUctryNOnegishi[t,c] = log(p.CPCctry[t,c])
                                            else
                                                v.PERIODUctryNOnegishi[t,c] = ((1. / (1. - p.elasmu[12])) * (p.CPCctry[t,c])^(1. - p.elasmu[12]) + 1.)
                                            end
                                        else
                                            println("country does not belong to any region")
                                        end
                                    end


########################################################################################################################################################
#### CEMUTOTPER - sum of all individuals' utilities (i.e. regional/country utility) in a given period (with discounting) ###############################
########################################################################################################################################################


        #Define function for CEMUTOTPER
        for r in d.regions
            if t.t != 60
                v.CEMUTOTPER[t,r] = v.PERIODU[t,r] * p.l[t,r] * p.rr[t,r]
            else
                v.CEMUTOTPER[t,r] = v.PERIODU[t,r] * p.l[t,r] * p.rr[t,r] / (1. - ((p.rr[t-1,r] / (1. + 0.015)^10) / p.rr[t-1,r]))
            end
        end

                                    for r in d.regions
                                        if t.t != 60
                                            v.CEMUTOTPERNOnegishi[t,r] = v.PERIODUNOnegishi[t,r] * p.l[t,r] * p.rr[t,r]
                                        else
                                            v.CEMUTOTPERNOnegishi[t,r] = v.PERIODUNOnegishi[t,r] * p.l[t,r] * p.rr[t,r] / (1. - ((p.rr[t-1,r] / (1. + 0.015)^10) / p.rr[t-1,r]))
                                        end
                                    end

                                    # PER CAPITA (i.e. not multiplied with the population)
                                    for r in d.regions
                                        if t.t != 60
                                            v.CEMUTOTPERNOnegishiPC[t,r] = v.PERIODUNOnegishi[t,r] * p.rr[t,r]
                                        else
                                            v.CEMUTOTPERNOnegishiPC[t,r] = v.PERIODUNOnegishi[t,r] * p.rr[t,r] / (1. - ((p.rr[t-1,r] / (1. + 0.015)^10) / p.rr[t-1,r]))
                                        end
                                    end

                    # NEW: COUNTRY- LEVEL: Define function for CEMUTOTPER
                    for c in d.countries
                        if p.inregion[c] == 1
                            if t.t != 60
                                v.CEMUTOTPERctry[t,c] = v.PERIODUctry[t,c] * p.lctry[t,c] * p.rr[t,1]
                            else
                                v.CEMUTOTPERctry[t,c] = v.PERIODUctry[t,c] * p.lctry[t,c] * p.rr[t,1] / (1. - ((p.rr[t-1,1] / (1. + 0.015)^10) / p.rr[t-1,1]))
                            end
                        elseif p.inregion[c] == 2
                            if t.t != 60
                                v.CEMUTOTPERctry[t,c] = v.PERIODUctry[t,c] * p.lctry[t,c] * p.rr[t,2]
                            else
                                v.CEMUTOTPERctry[t,c] = v.PERIODUctry[t,c] * p.lctry[t,c] * p.rr[t,2] / (1. - ((p.rr[t-1,2] / (1. + 0.015)^10) / p.rr[t-1,2]))
                            end
                        elseif p.inregion[c] == 3
                            if t.t != 60
                                v.CEMUTOTPERctry[t,c] = v.PERIODUctry[t,c] * p.lctry[t,c] * p.rr[t,3]
                            else
                                v.CEMUTOTPERctry[t,c] = v.PERIODUctry[t,c] * p.lctry[t,c] * p.rr[t,3] / (1. - ((p.rr[t-1,3] / (1. + 0.015)^10) / p.rr[t-1,3]))
                            end
                        elseif p.inregion[c] == 4
                            if t.t != 60
                                v.CEMUTOTPERctry[t,c] = v.PERIODUctry[t,c] * p.lctry[t,c] * p.rr[t,4]
                            else
                                v.CEMUTOTPERctry[t,c] = v.PERIODUctry[t,c] * p.lctry[t,c] * p.rr[t,4] / (1. - ((p.rr[t-1,4] / (1. + 0.015)^10) / p.rr[t-1,4]))
                            end
                        elseif p.inregion[c] == 5
                            if t.t != 60
                                v.CEMUTOTPERctry[t,c] = v.PERIODUctry[t,c] * p.lctry[t,c] * p.rr[t,5]
                            else
                                v.CEMUTOTPERctry[t,c] = v.PERIODUctry[t,c] * p.lctry[t,c] * p.rr[t,5] / (1. - ((p.rr[t-1,5] / (1. + 0.015)^10) / p.rr[t-1,5]))
                            end
                        elseif p.inregion[c] == 6
                            if t.t != 60
                                v.CEMUTOTPERctry[t,c] = v.PERIODUctry[t,c] * p.lctry[t,c] * p.rr[t,6]
                            else
                                v.CEMUTOTPERctry[t,c] = v.PERIODUctry[t,c] * p.lctry[t,c] * p.rr[t,6] / (1. - ((p.rr[t-1,6] / (1. + 0.015)^10) / p.rr[t-1,6]))
                            end
                        elseif p.inregion[c] == 7
                            if t.t != 60
                                v.CEMUTOTPERctry[t,c] = v.PERIODUctry[t,c] * p.lctry[t,c] * p.rr[t,7]
                            else
                                v.CEMUTOTPERctry[t,c] = v.PERIODUctry[t,c] * p.lctry[t,c] * p.rr[t,7] / (1. - ((p.rr[t-1,7] / (1. + 0.015)^10) / p.rr[t-1,7]))
                            end
                        elseif p.inregion[c] == 8
                            if t.t != 60
                                v.CEMUTOTPERctry[t,c] = v.PERIODUctry[t,c] * p.lctry[t,c] * p.rr[t,8]
                            else
                                v.CEMUTOTPERctry[t,c] = v.PERIODUctry[t,c] * p.lctry[t,c] * p.rr[t,8] / (1. - ((p.rr[t-1,8] / (1. + 0.015)^10) / p.rr[t-1,8]))
                            end
                        elseif p.inregion[c] == 9
                            if t.t != 60
                                v.CEMUTOTPERctry[t,c] = v.PERIODUctry[t,c] * p.lctry[t,c] * p.rr[t,9]
                            else
                                v.CEMUTOTPERctry[t,c] = v.PERIODUctry[t,c] * p.lctry[t,c] * p.rr[t,9] / (1. - ((p.rr[t-1,9] / (1. + 0.015)^10) / p.rr[t-1,9]))
                            end
                        elseif p.inregion[c] == 10
                            if t.t != 60
                                v.CEMUTOTPERctry[t,c] = v.PERIODUctry[t,c] * p.lctry[t,c] * p.rr[t,10]
                            else
                                v.CEMUTOTPERctry[t,c] = v.PERIODUctry[t,c] * p.lctry[t,c] * p.rr[t,10] / (1. - ((p.rr[t-1,10] / (1. + 0.015)^10) / p.rr[t-1,10]))
                            end
                        elseif p.inregion[c] == 11
                            if t.t != 60
                                v.CEMUTOTPERctry[t,c] = v.PERIODUctry[t,c] * p.lctry[t,c] * p.rr[t,11]
                            else
                                v.CEMUTOTPERctry[t,c] = v.PERIODUctry[t,c] * p.lctry[t,c] * p.rr[t,11] / (1. - ((p.rr[t-1,11] / (1. + 0.015)^10) / p.rr[t-1,11]))
                            end
                        elseif p.inregion[c] == 12
                            if t.t != 60
                                v.CEMUTOTPERctry[t,c] = v.PERIODUctry[t,c] * p.lctry[t,c] * p.rr[t,12]
                            else
                                v.CEMUTOTPERctry[t,c] = v.PERIODUctry[t,c] * p.lctry[t,c] * p.rr[t,12] / (1. - ((p.rr[t-1,12] / (1. + 0.015)^10) / p.rr[t-1,12]))
                            end
                        else
                            println("country does not belong to any region")
                        end
                    end

                                    # NEW: COUNTRY- LEVEL: Define function for CEMUTOTPER without NEGISHI weights
                                    for c in d.countries
                                        if p.inregion[c] == 1
                                            if t.t != 60
                                                v.CEMUTOTPERctryNOnegishi[t,c] = v.PERIODUctryNOnegishi[t,c] * p.lctry[t,c] * p.rr[t,1]
                                            else
                                                v.CEMUTOTPERctryNOnegishi[t,c] = v.PERIODUctryNOnegishi[t,c] * p.lctry[t,c] * p.rr[t,1] / (1. - ((p.rr[t-1,1] / (1. + 0.015)^10) / p.rr[t-1,1]))
                                            end
                                        elseif p.inregion[c] == 2
                                            if t.t != 60
                                                v.CEMUTOTPERctryNOnegishi[t,c] = v.PERIODUctryNOnegishi[t,c] * p.lctry[t,c] * p.rr[t,2]
                                            else
                                                v.CEMUTOTPERctryNOnegishi[t,c] = v.PERIODUctryNOnegishi[t,c] * p.lctry[t,c] * p.rr[t,2] / (1. - ((p.rr[t-1,2] / (1. + 0.015)^10) / p.rr[t-1,2]))
                                            end
                                        elseif p.inregion[c] == 3
                                            if t.t != 60
                                                v.CEMUTOTPERctryNOnegishi[t,c] = v.PERIODUctryNOnegishi[t,c] * p.lctry[t,c] * p.rr[t,3]
                                            else
                                                v.CEMUTOTPERctryNOnegishi[t,c] = v.PERIODUctryNOnegishi[t,c] * p.lctry[t,c] * p.rr[t,3] / (1. - ((p.rr[t-1,3] / (1. + 0.015)^10) / p.rr[t-1,3]))
                                            end
                                        elseif p.inregion[c] == 4
                                            if t.t != 60
                                                v.CEMUTOTPERctryNOnegishi[t,c] = v.PERIODUctryNOnegishi[t,c] * p.lctry[t,c] * p.rr[t,4]
                                            else
                                                v.CEMUTOTPERctryNOnegishi[t,c] = v.PERIODUctryNOnegishi[t,c] * p.lctry[t,c] * p.rr[t,4] / (1. - ((p.rr[t-1,4] / (1. + 0.015)^10) / p.rr[t-1,4]))
                                            end
                                        elseif p.inregion[c] == 5
                                            if t.t != 60
                                                v.CEMUTOTPERctryNOnegishi[t,c] = v.PERIODUctryNOnegishi[t,c] * p.lctry[t,c] * p.rr[t,5]
                                            else
                                                v.CEMUTOTPERctryNOnegishi[t,c] = v.PERIODUctryNOnegishi[t,c] * p.lctry[t,c] * p.rr[t,5] / (1. - ((p.rr[t-1,5] / (1. + 0.015)^10) / p.rr[t-1,5]))
                                            end
                                        elseif p.inregion[c] == 6
                                            if t.t != 60
                                                v.CEMUTOTPERctryNOnegishi[t,c] = v.PERIODUctryNOnegishi[t,c] * p.lctry[t,c] * p.rr[t,6]
                                            else
                                                v.CEMUTOTPERctryNOnegishi[t,c] = v.PERIODUctryNOnegishi[t,c] * p.lctry[t,c] * p.rr[t,6] / (1. - ((p.rr[t-1,6] / (1. + 0.015)^10) / p.rr[t-1,6]))
                                            end
                                        elseif p.inregion[c] == 7
                                            if t.t != 60
                                                v.CEMUTOTPERctryNOnegishi[t,c] = v.PERIODUctryNOnegishi[t,c] * p.lctry[t,c] * p.rr[t,7]
                                            else
                                                v.CEMUTOTPERctryNOnegishi[t,c] = v.PERIODUctryNOnegishi[t,c] * p.lctry[t,c] * p.rr[t,7] / (1. - ((p.rr[t-1,7] / (1. + 0.015)^10) / p.rr[t-1,7]))
                                            end
                                        elseif p.inregion[c] == 8
                                            if t.t != 60
                                                v.CEMUTOTPERctryNOnegishi[t,c] = v.PERIODUctryNOnegishi[t,c] * p.lctry[t,c] * p.rr[t,8]
                                            else
                                                v.CEMUTOTPERctryNOnegishi[t,c] = v.PERIODUctryNOnegishi[t,c] * p.lctry[t,c] * p.rr[t,8] / (1. - ((p.rr[t-1,8] / (1. + 0.015)^10) / p.rr[t-1,8]))
                                            end
                                        elseif p.inregion[c] == 9
                                            if t.t != 60
                                                v.CEMUTOTPERctryNOnegishi[t,c] = v.PERIODUctryNOnegishi[t,c] * p.lctry[t,c] * p.rr[t,9]
                                            else
                                                v.CEMUTOTPERctryNOnegishi[t,c] = v.PERIODUctryNOnegishi[t,c] * p.lctry[t,c] * p.rr[t,9] / (1. - ((p.rr[t-1,9] / (1. + 0.015)^10) / p.rr[t-1,9]))
                                            end
                                        elseif p.inregion[c] == 10
                                            if t.t != 60
                                                v.CEMUTOTPERctryNOnegishi[t,c] = v.PERIODUctryNOnegishi[t,c] * p.lctry[t,c] * p.rr[t,10]
                                            else
                                                v.CEMUTOTPERctryNOnegishi[t,c] = v.PERIODUctryNOnegishi[t,c] * p.lctry[t,c] * p.rr[t,10] / (1. - ((p.rr[t-1,10] / (1. + 0.015)^10) / p.rr[t-1,10]))
                                            end
                                        elseif p.inregion[c] == 11
                                            if t.t != 60
                                                v.CEMUTOTPERctryNOnegishi[t,c] = v.PERIODUctryNOnegishi[t,c] * p.lctry[t,c] * p.rr[t,11]
                                            else
                                                v.CEMUTOTPERctryNOnegishi[t,c] = v.PERIODUctryNOnegishi[t,c] * p.lctry[t,c] * p.rr[t,11] / (1. - ((p.rr[t-1,11] / (1. + 0.015)^10) / p.rr[t-1,11]))
                                            end
                                        elseif p.inregion[c] == 12
                                            if t.t != 60
                                                v.CEMUTOTPERctryNOnegishi[t,c] = v.PERIODUctryNOnegishi[t,c] * p.lctry[t,c] * p.rr[t,12]
                                            else
                                                v.CEMUTOTPERctryNOnegishi[t,c] = v.PERIODUctryNOnegishi[t,c] * p.lctry[t,c] * p.rr[t,12] / (1. - ((p.rr[t-1,12] / (1. + 0.015)^10) / p.rr[t-1,12]))
                                            end
                                        else
                                            println("country does not belong to any region")
                                        end
                                    end

                                        # NEW: COUNTRY- LEVEL: Define function for CEMUTOTPER without NEGISHI weights & PER CAPITA
                                        for c in d.countries
                                            if p.inregion[c] == 1
                                                if t.t != 60
                                                    v.CEMUTOTPERctryNOnegishiPC[t,c] = v.PERIODUctryNOnegishi[t,c] * p.rr[t,1]
                                                else
                                                    v.CEMUTOTPERctryNOnegishiPC[t,c] = v.PERIODUctryNOnegishi[t,c] * p.rr[t,1] / (1. - ((p.rr[t-1,1] / (1. + 0.015)^10) / p.rr[t-1,1]))
                                                end
                                            elseif p.inregion[c] == 2
                                                if t.t != 60
                                                    v.CEMUTOTPERctryNOnegishiPC[t,c] = v.PERIODUctryNOnegishi[t,c] * p.rr[t,2]
                                                else
                                                    v.CEMUTOTPERctryNOnegishiPC[t,c] = v.PERIODUctryNOnegishi[t,c] * p.rr[t,2] / (1. - ((p.rr[t-1,2] / (1. + 0.015)^10) / p.rr[t-1,2]))
                                                end
                                            elseif p.inregion[c] == 3
                                                if t.t != 60
                                                    v.CEMUTOTPERctryNOnegishiPC[t,c] = v.PERIODUctryNOnegishi[t,c] * p.rr[t,3]
                                                else
                                                    v.CEMUTOTPERctryNOnegishiPC[t,c] = v.PERIODUctryNOnegishi[t,c] * p.rr[t,3] / (1. - ((p.rr[t-1,3] / (1. + 0.015)^10) / p.rr[t-1,3]))
                                                end
                                            elseif p.inregion[c] == 4
                                                if t.t != 60
                                                    v.CEMUTOTPERctryNOnegishiPC[t,c] = v.PERIODUctryNOnegishi[t,c] * p.rr[t,4]
                                                else
                                                    v.CEMUTOTPERctryNOnegishiPC[t,c] = v.PERIODUctryNOnegishi[t,c] * p.rr[t,4] / (1. - ((p.rr[t-1,4] / (1. + 0.015)^10) / p.rr[t-1,4]))
                                                end
                                            elseif p.inregion[c] == 5
                                                if t.t != 60
                                                    v.CEMUTOTPERctryNOnegishiPC[t,c] = v.PERIODUctryNOnegishi[t,c] * p.rr[t,5]
                                                else
                                                    v.CEMUTOTPERctryNOnegishiPC[t,c] = v.PERIODUctryNOnegishi[t,c] * p.rr[t,5] / (1. - ((p.rr[t-1,5] / (1. + 0.015)^10) / p.rr[t-1,5]))
                                                end
                                            elseif p.inregion[c] == 6
                                                if t.t != 60
                                                    v.CEMUTOTPERctryNOnegishiPC[t,c] = v.PERIODUctryNOnegishi[t,c] * p.rr[t,6]
                                                else
                                                    v.CEMUTOTPERctryNOnegishiPC[t,c] = v.PERIODUctryNOnegishi[t,c] * p.rr[t,6] / (1. - ((p.rr[t-1,6] / (1. + 0.015)^10) / p.rr[t-1,6]))
                                                end
                                            elseif p.inregion[c] == 7
                                                if t.t != 60
                                                    v.CEMUTOTPERctryNOnegishiPC[t,c] = v.PERIODUctryNOnegishi[t,c] * p.rr[t,7]
                                                else
                                                    v.CEMUTOTPERctryNOnegishiPC[t,c] = v.PERIODUctryNOnegishi[t,c] * p.rr[t,7] / (1. - ((p.rr[t-1,7] / (1. + 0.015)^10) / p.rr[t-1,7]))
                                                end
                                            elseif p.inregion[c] == 8
                                                if t.t != 60
                                                    v.CEMUTOTPERctryNOnegishiPC[t,c] = v.PERIODUctryNOnegishi[t,c] * p.rr[t,8]
                                                else
                                                    v.CEMUTOTPERctryNOnegishiPC[t,c] = v.PERIODUctryNOnegishi[t,c] * p.rr[t,8] / (1. - ((p.rr[t-1,8] / (1. + 0.015)^10) / p.rr[t-1,8]))
                                                end
                                            elseif p.inregion[c] == 9
                                                if t.t != 60
                                                    v.CEMUTOTPERctryNOnegishiPC[t,c] = v.PERIODUctryNOnegishi[t,c] * p.rr[t,9]
                                                else
                                                    v.CEMUTOTPERctryNOnegishiPC[t,c] = v.PERIODUctryNOnegishi[t,c] * p.rr[t,9] / (1. - ((p.rr[t-1,9] / (1. + 0.015)^10) / p.rr[t-1,9]))
                                                end
                                            elseif p.inregion[c] == 10
                                                if t.t != 60
                                                    v.CEMUTOTPERctryNOnegishiPC[t,c] = v.PERIODUctryNOnegishi[t,c] * p.rr[t,10]
                                                else
                                                    v.CEMUTOTPERctryNOnegishiPC[t,c] = v.PERIODUctryNOnegishi[t,c] * p.rr[t,10] / (1. - ((p.rr[t-1,10] / (1. + 0.015)^10) / p.rr[t-1,10]))
                                                end
                                            elseif p.inregion[c] == 11
                                                if t.t != 60
                                                    v.CEMUTOTPERctryNOnegishiPC[t,c] = v.PERIODUctryNOnegishi[t,c] * p.rr[t,11]
                                                else
                                                    v.CEMUTOTPERctryNOnegishiPC[t,c] = v.PERIODUctryNOnegishi[t,c] * p.rr[t,11] / (1. - ((p.rr[t-1,11] / (1. + 0.015)^10) / p.rr[t-1,11]))
                                                end
                                            elseif p.inregion[c] == 12
                                                if t.t != 60
                                                    v.CEMUTOTPERctryNOnegishiPC[t,c] = v.PERIODUctryNOnegishi[t,c] * p.rr[t,12]
                                                else
                                                    v.CEMUTOTPERctryNOnegishiPC[t,c] = v.PERIODUctryNOnegishi[t,c] * p.rr[t,12] / (1. - ((p.rr[t-1,12] / (1. + 0.015)^10) / p.rr[t-1,12]))
                                                end
                                            else
                                                println("country does not belong to any region")
                                            end
                                        end

########################################################################################################################################################
#### REGCUMCEMUTOTPER -  cumulative region-level / country-level utility over time #####################################################################
########################################################################################################################################################


        #Define function for REGCUMCEMUTOTPER
        for r in d.regions
            if is_first(t)
                v.REGCUMCEMUTOTPER[t,r] = v.CEMUTOTPER[t,r]
            else
                v.REGCUMCEMUTOTPER[t,r] = v.REGCUMCEMUTOTPER[t-1, r] + v.CEMUTOTPER[t,r]
            end
        end

                                    #Define function for REGCUMCEMUTOTPER (without NEGISHI weights)
                                    for r in d.regions
                                        if is_first(t)
                                            v.REGCUMCEMUTOTPERNOnegishi[t,r] = v.CEMUTOTPERNOnegishi[t,r]
                                        else
                                            v.REGCUMCEMUTOTPERNOnegishi[t,r] = v.REGCUMCEMUTOTPERNOnegishi[t-1, r] + v.CEMUTOTPERNOnegishi[t,r]
                                        end
                                    end

                                    #Define function for REGCUMCEMUTOTPER (without NEGISHI weights) - PER CAPITA
                                    for r in d.regions
                                        if is_first(t)
                                            v.REGCUMCEMUTOTPERNOnegishiPC[t,r] = v.CEMUTOTPERNOnegishiPC[t,r]
                                        else
                                            v.REGCUMCEMUTOTPERNOnegishiPC[t,r] = v.REGCUMCEMUTOTPERNOnegishiPC[t-1, r] + v.CEMUTOTPERNOnegishiPC[t,r]
                                        end
                                    end

                    # NEW: COUNTRY-LEVEL - Define function for REGCUMCEMUTOTPER
                    for c in d.countries
                        if is_first(t)
                            v.REGCUMCEMUTOTPERctry[t,c] = v.CEMUTOTPERctry[t,c]
                        else
                            v.REGCUMCEMUTOTPERctry[t,c] = v.REGCUMCEMUTOTPERctry[t-1, c] + v.CEMUTOTPERctry[t,c]
                        end
                    end

                                    # NEW: COUNTRY-LEVEL - Define function for REGCUMCEMUTOTPER (without NEGISHI weights)
                                    for c in d.countries
                                        if is_first(t)
                                            v.REGCUMCEMUTOTPERctryNOnegishi[t,c] = v.CEMUTOTPERctryNOnegishi[t,c]
                                        else
                                            v.REGCUMCEMUTOTPERctryNOnegishi[t,c] = v.REGCUMCEMUTOTPERctryNOnegishi[t-1, c] + v.CEMUTOTPERctryNOnegishi[t,c]
                                        end
                                    end

                                    # NEW: COUNTRY-LEVEL - Define function for REGCUMCEMUTOTPER (without NEGISHI weights)  - PER CAPITA
                                    for c in d.countries
                                        if is_first(t)
                                            v.REGCUMCEMUTOTPERctryNOnegishiPC[t,c] = v.CEMUTOTPERctryNOnegishiPC[t,c]
                                        else
                                            v.REGCUMCEMUTOTPERctryNOnegishiPC[t,c] = v.REGCUMCEMUTOTPERctryNOnegishiPC[t-1, c] + v.CEMUTOTPERctryNOnegishiPC[t,c]
                                        end
                                    end


########################################################################################################################################################
#### REGUTILITY - (rescaled) cumulative regional utility over time (in the LAST PERIOD) ################################################################
#### UTILITY - sum of rescaled cumulative regional utility over time                    ################################################################
########################################################################################################################################################


        if t.t == 60
            #Define function for REGUTILITY
            for r in d.regions
                v.REGUTILITY[r] = 10 * p.scale1[r] * v.REGCUMCEMUTOTPER[t,r] + p.scale2[r]
            end
            #Define function for UTILITY
            v.UTILITY = sum(v.REGUTILITY[:])
        end

                    # NEW: COUNTRY-LEVEL
                    if t.t == 60
                        #Define function for REGUTILITY
                        for c in d.countries
                            if p.inregion[c] == 1
                                v.REGUTILITYctry[c] = 10 * p.scale1[1] * v.REGCUMCEMUTOTPERctry[t,c] + p.scale2[1]
                            elseif p.inregion[c] == 2
                                v.REGUTILITYctry[c] = 10 * p.scale1[2] * v.REGCUMCEMUTOTPERctry[t,c] + p.scale2[2]
                            elseif p.inregion[c] == 3
                                v.REGUTILITYctry[c] = 10 * p.scale1[3] * v.REGCUMCEMUTOTPERctry[t,c] + p.scale2[3]
                            elseif p.inregion[c] == 4
                                v.REGUTILITYctry[c] = 10 * p.scale1[4] * v.REGCUMCEMUTOTPERctry[t,c] + p.scale2[4]
                            elseif p.inregion[c] == 5
                                v.REGUTILITYctry[c] = 10 * p.scale1[5] * v.REGCUMCEMUTOTPERctry[t,c] + p.scale2[5]
                            elseif p.inregion[c] == 6
                                v.REGUTILITYctry[c] = 10 * p.scale1[6] * v.REGCUMCEMUTOTPERctry[t,c] + p.scale2[6]
                            elseif p.inregion[c] == 7
                                v.REGUTILITYctry[c] = 10 * p.scale1[7] * v.REGCUMCEMUTOTPERctry[t,c] + p.scale2[7]
                            elseif p.inregion[c] == 8
                                v.REGUTILITYctry[c] = 10 * p.scale1[8] * v.REGCUMCEMUTOTPERctry[t,c] + p.scale2[8]
                            elseif p.inregion[c] == 9
                                v.REGUTILITYctry[c] = 10 * p.scale1[9] * v.REGCUMCEMUTOTPERctry[t,c] + p.scale2[9]
                            elseif p.inregion[c] == 10
                                v.REGUTILITYctry[c] = 10 * p.scale1[10] * v.REGCUMCEMUTOTPERctry[t,c] + p.scale2[10]
                            elseif p.inregion[c] == 11
                                v.REGUTILITYctry[c] = 10 * p.scale1[11] * v.REGCUMCEMUTOTPERctry[t,c] + p.scale2[11]
                            elseif p.inregion[c] == 12
                                v.REGUTILITYctry[c] = 10 * p.scale1[12] * v.REGCUMCEMUTOTPERctry[t,c] + p.scale2[12]
                            else
                                println("country does not belong to any region")
                            end
                        end
                        #Define function for UTILITY
                        v.UTILITYctryagg = sum(v.REGUTILITYctry[:])
                    end


                                                if t.t == 60
                                                    #Define function for REGUTILITY (NO NEGISHI WEIGHTS & NO RESCALING)
                                                    for r in d.regions
                                                        v.REGUTILITYNOnegishiNOrescale[r] = v.REGCUMCEMUTOTPERNOnegishi[t,r]
                                                    end
                                                    #Define function for UTILITY
                                                    v.UTILITYNOnegishiNOrescale = sum(v.REGUTILITYNOnegishiNOrescale[:])
                                                end

                                                if t.t == 60
                                                    #Define function for REGUTILITY (NO NEGISHI WEIGHTS & NO RESCALING) - PER CAPITA
                                                    for r in d.regions
                                                        v.REGUTILITYNOnegishiNOrescalePC[r] = v.REGCUMCEMUTOTPERNOnegishiPC[t,r]
                                                    end
                                                    #Define function for UTILITY
                                                    v.UTILITYNOnegishiNOrescalePC = sum(v.REGUTILITYNOnegishiNOrescalePC[:])
                                                end


                                                # NEW: COUNTRY-LEVEL
                                                if t.t == 60
                                                    #Define function for REGUTILITY (NO NEGISHI WEIGHTS & NO RESCALING)
                                                    for c in d.countries
                                                        if p.inregion[c] == 1
                                                            v.REGUTILITYctryNOnegishiNOrescale[c] = v.REGCUMCEMUTOTPERctryNOnegishi[t,c]
                                                        elseif p.inregion[c] == 2
                                                            v.REGUTILITYctryNOnegishiNOrescale[c] = v.REGCUMCEMUTOTPERctryNOnegishi[t,c]
                                                        elseif p.inregion[c] == 3
                                                            v.REGUTILITYctryNOnegishiNOrescale[c] = v.REGCUMCEMUTOTPERctryNOnegishi[t,c]
                                                        elseif p.inregion[c] == 4
                                                            v.REGUTILITYctryNOnegishiNOrescale[c] = v.REGCUMCEMUTOTPERctryNOnegishi[t,c]
                                                        elseif p.inregion[c] == 5
                                                            v.REGUTILITYctryNOnegishiNOrescale[c] = v.REGCUMCEMUTOTPERctryNOnegishi[t,c]
                                                        elseif p.inregion[c] == 6
                                                            v.REGUTILITYctryNOnegishiNOrescale[c] = v.REGCUMCEMUTOTPERctryNOnegishi[t,c]
                                                        elseif p.inregion[c] == 7
                                                            v.REGUTILITYctryNOnegishiNOrescale[c] = v.REGCUMCEMUTOTPERctryNOnegishi[t,c]
                                                        elseif p.inregion[c] == 8
                                                            v.REGUTILITYctryNOnegishiNOrescale[c] = v.REGCUMCEMUTOTPERctryNOnegishi[t,c]
                                                        elseif p.inregion[c] == 9
                                                            v.REGUTILITYctryNOnegishiNOrescale[c] = v.REGCUMCEMUTOTPERctryNOnegishi[t,c]
                                                        elseif p.inregion[c] == 10
                                                            v.REGUTILITYctryNOnegishiNOrescale[c] = v.REGCUMCEMUTOTPERctryNOnegishi[t,c]
                                                        elseif p.inregion[c] == 11
                                                            v.REGUTILITYctryNOnegishiNOrescale[c] = v.REGCUMCEMUTOTPERctryNOnegishi[t,c]
                                                        elseif p.inregion[c] == 12
                                                            v.REGUTILITYctryNOnegishiNOrescale[c] = v.REGCUMCEMUTOTPERctryNOnegishi[t,c]
                                                        else
                                                            println("country does not belong to any region")
                                                        end
                                                    end
                                                    #Define function for UTILITY
                                                    v.UTILITYctryaggNOnegishiNOrescale = sum(v.REGUTILITYctryNOnegishiNOrescale[:])
                                                end


                                                # NEW: COUNTRY-LEVEL
                                                if t.t == 60
                                                    #Define function for REGUTILITY (NO NEGISHI WEIGHTS & NO RESCALING) - PER CAPITA
                                                    for c in d.countries
                                                        if p.inregion[c] == 1
                                                            v.REGUTILITYctryNOnegishiNOrescalePC[c] = v.REGCUMCEMUTOTPERctryNOnegishiPC[t,c]
                                                        elseif p.inregion[c] == 2
                                                            v.REGUTILITYctryNOnegishiNOrescalePC[c] = v.REGCUMCEMUTOTPERctryNOnegishiPC[t,c]
                                                        elseif p.inregion[c] == 3
                                                            v.REGUTILITYctryNOnegishiNOrescalePC[c] = v.REGCUMCEMUTOTPERctryNOnegishiPC[t,c]
                                                        elseif p.inregion[c] == 4
                                                            v.REGUTILITYctryNOnegishiNOrescalePC[c] = v.REGCUMCEMUTOTPERctryNOnegishiPC[t,c]
                                                        elseif p.inregion[c] == 5
                                                            v.REGUTILITYctryNOnegishiNOrescalePC[c] = v.REGCUMCEMUTOTPERctryNOnegishiPC[t,c]
                                                        elseif p.inregion[c] == 6
                                                            v.REGUTILITYctryNOnegishiNOrescalePC[c] = v.REGCUMCEMUTOTPERctryNOnegishiPC[t,c]
                                                        elseif p.inregion[c] == 7
                                                            v.REGUTILITYctryNOnegishiNOrescalePC[c] = v.REGCUMCEMUTOTPERctryNOnegishiPC[t,c]
                                                        elseif p.inregion[c] == 8
                                                            v.REGUTILITYctryNOnegishiNOrescalePC[c] = v.REGCUMCEMUTOTPERctryNOnegishiPC[t,c]
                                                        elseif p.inregion[c] == 9
                                                            v.REGUTILITYctryNOnegishiNOrescalePC[c] = v.REGCUMCEMUTOTPERctryNOnegishiPC[t,c]
                                                        elseif p.inregion[c] == 10
                                                            v.REGUTILITYctryNOnegishiNOrescalePC[c] = v.REGCUMCEMUTOTPERctryNOnegishiPC[t,c]
                                                        elseif p.inregion[c] == 11
                                                            v.REGUTILITYctryNOnegishiNOrescalePC[c] = v.REGCUMCEMUTOTPERctryNOnegishiPC[t,c]
                                                        elseif p.inregion[c] == 12
                                                            v.REGUTILITYctryNOnegishiNOrescalePC[c] = v.REGCUMCEMUTOTPERctryNOnegishiPC[t,c]
                                                        else
                                                            println("country does not belong to any region")
                                                        end
                                                    end
                                                    #Define function for UTILITY
                                                    v.UTILITYctryaggNOnegishiNOrescalePC = sum(v.REGUTILITYctryNOnegishiNOrescalePC[:])
                                                end


                    # NEW: COUNTRY-LEVEL - WITHOUT RESCALING
                    if t.t == 60
                        #Define function for REGUTILITY
                        for c in d.countries
                            if p.inregion[c] == 1
                                v.REGUTILITYctrynorescale[c] = v.REGCUMCEMUTOTPERctry[t,c]
                            elseif p.inregion[c] == 2
                                v.REGUTILITYctrynorescale[c] = v.REGCUMCEMUTOTPERctry[t,c]
                            elseif p.inregion[c] == 3
                                v.REGUTILITYctrynorescale[c] = v.REGCUMCEMUTOTPERctry[t,c]
                            elseif p.inregion[c] == 4
                                v.REGUTILITYctrynorescale[c] = v.REGCUMCEMUTOTPERctry[t,c]
                            elseif p.inregion[c] == 5
                                v.REGUTILITYctrynorescale[c] = v.REGCUMCEMUTOTPERctry[t,c]
                            elseif p.inregion[c] == 6
                                v.REGUTILITYctrynorescale[c] = v.REGCUMCEMUTOTPERctry[t,c]
                            elseif p.inregion[c] == 7
                                v.REGUTILITYctrynorescale[c] = v.REGCUMCEMUTOTPERctry[t,c]
                            elseif p.inregion[c] == 8
                                v.REGUTILITYctrynorescale[c] = v.REGCUMCEMUTOTPERctry[t,c]
                            elseif p.inregion[c] == 9
                                v.REGUTILITYctrynorescale[c] = v.REGCUMCEMUTOTPERctry[t,c]
                            elseif p.inregion[c] == 10
                                v.REGUTILITYctrynorescale[c] = v.REGCUMCEMUTOTPERctry[t,c]
                            elseif p.inregion[c] == 11
                                v.REGUTILITYctrynorescale[c] = v.REGCUMCEMUTOTPERctry[t,c]
                            elseif p.inregion[c] == 12
                                v.REGUTILITYctrynorescale[c] = v.REGCUMCEMUTOTPERctry[t,c]
                            else
                                println("country does not belong to any region")
                            end
                        end
                        #Define function for UTILITY
                        v.UTILITYctryaggnorescale = sum(v.REGUTILITYctrynorescale[:])
                    end
    end
end
