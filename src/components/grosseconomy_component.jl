using Mimi

@defcomp grosseconomy begin
    regions = Index()
    countries = Index()

    YGROSS = Variable(index=[time, regions]) # Gross world product GROSS of abatement and damages (trillions 2005 USD per year)
    K = Variable(index=[time, regions]) # Capital stock (trillions 2005 US dollars)

    al = Parameter(index=[time, regions]) # Level of total factor productivity
    l = Parameter(index=[time, regions]) # Level of population and labor
    I = Parameter(index=[time, regions]) # Investment (trillions 2005 USD per year)
    gama = Parameter() # Capital elasticity in production function
    dk = Parameter(index=[regions]) # Depreciation rate on capital (per year)
    k0 = Parameter(index=[regions]) # Initial capital value (trill 2005 USD)

    #     # NEW: COUNTRY-LEVEL
    YGROSSctry = Variable(index=[time, countries]) # Gross domestic product GROSS of abatement and damages (trillions 2005 USD per year)
    gdpshare = Parameter(index=[countries]) # GDP share of a country relative to the region GDP
    inregion = Parameter(index=[countries]) # attributing a country to the region it belongs to

    # TODO remove this, just a temporary output trick
    L = Variable(index=[time, regions])

    function run_timestep(p, v, d, t)
        #Define function for K
        for r in d.regions
            if is_first(t)
                v.K[t,r] = p.k0[r]
            else
                v.K[t,r] = (1 - p.dk[r])^10 * v.K[t-1,r] + 10 * p.I[t-1,r] # how do I get region-level investment
            end
        end

        #Define function for YGROSS
        for r in d.regions
            v.YGROSS[t,r] = (p.al[t,r] * (p.l[t,r]/1000)^(1-p.gama)) * (v.K[t,r]^p.gama)
            # println(v.YGROSS[t,r])
            # println(r)
        end

        #Define function for YGROSSctry
        for c in d.countries
            if p.inregion[c] == 1
                v.YGROSSctry[t,c] = v.YGROSS[t,1] * p.gdpshare[c]
            elseif p.inregion[c] == 2
                v.YGROSSctry[t,c] = v.YGROSS[t,2] * p.gdpshare[c]
            elseif p.inregion[c] == 3
                v.YGROSSctry[t,c] = v.YGROSS[t,3] * p.gdpshare[c]
            elseif p.inregion[c] == 4
                v.YGROSSctry[t,c] = v.YGROSS[t,4] * p.gdpshare[c]
            elseif p.inregion[c] == 5
                v.YGROSSctry[t,c] = v.YGROSS[t,5] * p.gdpshare[c]
            elseif p.inregion[c] == 6
                v.YGROSSctry[t,c] = v.YGROSS[t,6] * p.gdpshare[c]
            elseif p.inregion[c] == 7
                v.YGROSSctry[t,c] = v.YGROSS[t,7] * p.gdpshare[c]
            elseif p.inregion[c] == 8
                v.YGROSSctry[t,c] = v.YGROSS[t,8] * p.gdpshare[c]
            elseif p.inregion[c] == 9
                v.YGROSSctry[t,c] = v.YGROSS[t,9] * p.gdpshare[c]
            elseif p.inregion[c] == 10
                v.YGROSSctry[t,c] = v.YGROSS[t,10] * p.gdpshare[c]
            elseif p.inregion[c] == 11
                v.YGROSSctry[t,c] = v.YGROSS[t,11] * p.gdpshare[c]
            elseif p.inregion[c] == 12
                v.YGROSSctry[t,c] = v.YGROSS[t,12] * p.gdpshare[c]
            else
                println("country does not belong to any region")
            end
        end


        # TODO remove this, just a temporary output trick
        for r in d.regions
            v.L[t,r] = p.l[t,r]
        end
    end
end
