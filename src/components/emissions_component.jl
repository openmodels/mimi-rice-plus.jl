using Mimi

@defcomp emissions begin
    regions = Index()
    countries = Index()

    E = Variable(index=[time]) # Total CO2 emissions (GtC per year)
    EIND = Variable(index=[time, regions]) # Industrial emissions (GtC per year)
    CCA = Variable(index=[time]) # Cumulative indiustrial emissions
    ABATECOST = Variable(index=[time, regions]) # Cost of emissions reductions  (trillions 2005 USD per year)
    MCABATE = Variable(index=[time, regions]) # Marginal cost of abatement (2005$ per ton CO2)
    CPRICE = Variable(index=[time, regions]) # Carbon price (2005$ per ton of CO2)

    sigma = Parameter(index=[time, regions]) # CO2-equivalent-emissions output ratio
    YGROSS = Parameter(index=[time, regions]) # Gross world product GROSS of abatement and damages (trillions 2005 USD per year)
    etree = Parameter(index=[time]) # Emissions from deforestation
    cost1 = Parameter(index=[time, regions]) # Adjusted cost for backstop
    expcost2 = Parameter(index=[regions]) # Exponent of control cost function
    partfract = Parameter(index=[time, regions]) # Fraction of emissions in control regime
    pbacktime = Parameter(index=[time, regions]) # Backstop price
    MIU = Parameter(index=[time, regions]) # Emission control rate GHGs

    # NEW: COUNTRY-LEVEL
    ABATECOSTctry = Variable(index=[time, countries]) # Cost of emissions reductions  (trillions 2005 USD per year)
    YGROSSctry = Parameter(index=[time, countries]) # Gross world product GROSS of abatement and damages (trillions 2005 USD per year)
    inregion = Parameter(index=[countries]) # attributing a country to the region it belongs to

    # NEW: Marginal emission for SCC calculation
    marginalemission = Parameter() # "1" if there is an additional marginal emissions pulse, "0" otherwise


    function run_timestep(p, v, d, t)

        #Define function for EIND
        for r in d.regions
            v.EIND[t,r] = p.sigma[t,r] * p.YGROSS[t,r] * (1-p.MIU[t,r])
        end

        #Define function for E
        if p.marginalemission == 0
            v.E[t] = sum(v.EIND[t,:]) + p.etree[t]
        elseif p.marginalemission == 1
            if t.t == 2
                v.E[t] = sum(v.EIND[t,:]) + p.etree[t] + 1 # additional emissions pulse of 1 Gt in 2015 (period 2)
            else
                v.E[t] = sum(v.EIND[t,:]) + p.etree[t]
            end
        else
            println("no marginal emissions")
        end

        #Define function for CCA
        if is_first(t)
            v.CCA[t] = sum(v.EIND[t,:]) * 10.
        else
            v.CCA[t] =  v.CCA[t-1] + (sum(v.EIND[t,:]) * 10.)
        end

        #Define function for ABATECOST
        for r in d.regions
            v.ABATECOST[t,r] = p.YGROSS[t,r] * p.cost1[t,r] * (p.MIU[t,r]^p.expcost2[r]) * (p.partfract[t,r]^(1 - p.expcost2[r]))
        end

        # NEW: COUNTRY-LEVEL: Define function for ABATECOST
        for c in d.countries
            if p.inregion[c] == 1
                v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,1] * (p.MIU[t,1]^p.expcost2[1]) * (p.partfract[t,1]^(1 - p.expcost2[1]))
            elseif p.inregion[c] == 2
                v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,2] * (p.MIU[t,2]^p.expcost2[2]) * (p.partfract[t,2]^(1 - p.expcost2[2]))
            elseif p.inregion[c] == 3
                v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,3] * (p.MIU[t,3]^p.expcost2[3]) * (p.partfract[t,3]^(1 - p.expcost2[3]))
            elseif p.inregion[c] == 4
                v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,4] * (p.MIU[t,4]^p.expcost2[4]) * (p.partfract[t,4]^(1 - p.expcost2[4]))
            elseif p.inregion[c] == 5
                v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,5] * (p.MIU[t,5]^p.expcost2[5]) * (p.partfract[t,5]^(1 - p.expcost2[5]))
            elseif p.inregion[c] == 6
                v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,6] * (p.MIU[t,6]^p.expcost2[6]) * (p.partfract[t,6]^(1 - p.expcost2[6]))
            elseif p.inregion[c] == 7
                v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,7] * (p.MIU[t,7]^p.expcost2[7]) * (p.partfract[t,7]^(1 - p.expcost2[7]))
            elseif p.inregion[c] == 8
                v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,8] * (p.MIU[t,8]^p.expcost2[8]) * (p.partfract[t,8]^(1 - p.expcost2[8]))
            elseif p.inregion[c] == 9
                v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,9] * (p.MIU[t,9]^p.expcost2[9]) * (p.partfract[t,9]^(1 - p.expcost2[9]))
            elseif p.inregion[c] == 10
                v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,10] * (p.MIU[t,10]^p.expcost2[10]) * (p.partfract[t,10]^(1 - p.expcost2[10]))
            elseif p.inregion[c] == 11
                v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,11] * (p.MIU[t,11]^p.expcost2[11]) * (p.partfract[t,11]^(1 - p.expcost2[11]))
            elseif p.inregion[c] == 12
                v.ABATECOSTctry[t,c] = p.YGROSSctry[t,c] * p.cost1[t,12] * (p.MIU[t,12]^p.expcost2[12]) * (p.partfract[t,12]^(1 - p.expcost2[12]))
            else
                println("country does not belong to any region")
            end
        end

        #Define function for MCABATE
        for r in d.regions
            v.MCABATE[t,r] = p.pbacktime[t,r] * p.MIU[t,r]^(p.expcost2[r] - 1)
        end

        #Define function for CPRICE
        # This I can change to an increasing carbon price
        for r in d.regions
            v.CPRICE[t,r] = p.pbacktime[t,r] * 1000 * p.MIU[t,r]^(p.expcost2[r] - 1)
        end
    end

end
