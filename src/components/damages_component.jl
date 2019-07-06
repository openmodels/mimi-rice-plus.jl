using Mimi

@defcomp damages begin
    regions = Index()
    countries = Index() # NEW: COUNTRY-LEVEL

    DAMFRAC = Variable(index=[time, regions]) # Damages as % of GDP
    DAMAGES = Variable(index=[time, regions]) # Damages (trillions 2005 USD per year)

    # NEW: REGION-LEVEL - to seperate temperature damages and SLR damages
    DAMFRACTATM = Variable(index=[time, regions]) # Damages from temperature change as % of GDP (Burke et al. component)
    DAMFRACSLR = Variable(index=[time, regions]) # Damages from sea level rise as % of GDP
    DAMAGESTATM = Variable(index=[time, regions]) # Damages from temperature change (in trillions 2005 USD per year) (Burke et al. component)
    DAMAGESSLR = Variable(index=[time, regions]) # Damages from sea level rise (in trillions 2005 USD per year)

    # NEW: COUNTRY-LEVEL - only temperature damages on a country-level
    DAMFRACTATMCTRY = Variable(index=[time, countries])


    # NEW: NOT USED: 1900 baseline
    DAMFRAC1900 = Variable(index=[time, regions]) # Damages as % of GDP - 1900 baseline
    DAMAGES1900 = Variable(index=[time, regions]) # Damages (trillions 2005 USD per year) - 1900 baseline
    DAMFRACTATM1900 = Variable(index=[time, regions]) # Damages from temperature change as % of GDP (Burke et al. component)  - 1900 baseline
    DAMFRACSLR1900 = Variable(index=[time, regions]) # Damages from sea level rise as % of GDP  - 1900 baseline
    DAMAGESTATM1900 = Variable(index=[time, regions]) # Damages from temperature change (in trillions 2005 USD per year) (Burke et al. component) - 1900 baseline
    DAMAGESSLR1900 = Variable(index=[time, regions]) # Damages from sea level rise (in trillions 2005 USD per year) - 1900 baseline
    DAMFRACTATMCTRY1900 = Variable(index=[time, countries]) # COUNTRY-LEVEL - Damages as % of GDP - only temperature damages on a country-level - 1900 baseline

    # OLD: REGION-LEVEL - orginal RICE damage function
    DAMFRACTATMOLD = Variable(index=[time, regions]) # Damages from temperature change as % of GDP
    DAMFRACSLROLD = Variable(index=[time, regions]) # Damages from sea level rise as % of GDP
    DAMFRACOLD = Variable(index=[time, regions]) # Damages as % of GDP
    DAMAGESTATMOLD = Variable(index=[time, regions]) # Damages from temperature change (in trillions 2005 USD per year) (Burke et al. component)
    DAMAGESSLROLD = Variable(index=[time, regions]) # Damages from sea level rise (in trillions 2005 USD per year)
    DAMAGESOLD = Variable(index=[time, regions]) # Damages (trillions 2005 USD per year)

    TATM = Parameter(index=[time]) # Increase temperature of atmosphere (degrees C from 1900)
    YGROSS = Parameter(index=[time, regions]) # Gross world product GROSS of abatement and damages (trillions 2005 USD per year)
    SLRDAMAGES = Parameter(index=[time, regions])

    # a1 and a2 are not used anymore
    a1 = Parameter(index=[regions]) # Damage linear term
    a2 = Parameter(index=[regions]) # Damage quadratic term
    a3 = Parameter(index=[regions]) # Damage exponent

        # NEW: REGION-LEVEL - Damage coefficients
    f1 = Parameter(index=[regions]) # Damage intercept
    f2 = Parameter(index=[regions]) # Damage linear term
    f3 = Parameter(index=[regions]) # Damage quadratic term

        # NEW: COUNTRY-LEVEL - Damage coefficients
    n1 = Parameter(index=[countries]) # Damage intercept (countries)
    n2 = Parameter(index=[countries]) # Damage linear term (countries)
    n3 = Parameter(index=[countries]) # Damage quadratic term (countries)

#-- DAMFRAC --
    function run_timestep(p, v, d, t)

        # NEW: REGION-LEVEL - Define function for DAMFRAC (based on Burke damages relative to PS temperature baseline)
            # Notes:
            # not devided by 100 as the function already gives damages as a fraction of 1
            # (-) because the function gives damages that are negative but we want a positive DAMFRAC
            # -0.70 adjusts the TATM to the temperature increase relative to Burke baseline (1980-2010) rather then 1900 bseline
                # WARNING: will still need to adjust this
        for r in d.regions
            v.DAMFRACTATM[t,r] = -((p.f1[r] + p.f2[r] * (p.TATM[t] - 0.70)) + (p.f3[r] * (p.TATM[t] - 0.70)^p.a3[r])) # DAMFRAC from temperature changes
            v.DAMFRACSLR[t,r] = (p.SLRDAMAGES[t,r] / 100)   # DAMFRAC from SLR
            v.DAMFRAC[t,r] = v.DAMFRACTATM[t,r] + v.DAMFRACSLR[t,r] # Total DAMFRAC
        end

        # NEW: COUNTRY-LEVEL - Define function for country-level DAMFRAC (based on Burke damages relative to PS temperature baseline)
        for c in d.countries
            v.DAMFRACTATMCTRY[t,c] = -((p.n1[c] + p.n2[c] * (p.TATM[t] - 0.70)) + (p.n3[c] * (p.TATM[t] - 0.70)^2)) # still need to implement SLRDamages (only add them after DAMFRACTATMCTRY is aggregated to regions again)
        end

        # NOT USED
        # NEW: REGION-LEVEL - Define function for DAMFRAC (based on Burke damages relative to 1900 temperatures)
        for r in d.regions
            v.DAMFRACTATM1900[t,r] = -((p.f1[r] + p.f2[r] * (p.TATM[t])) + (p.f3[r] * (p.TATM[t])^p.a3[r])) # DAMFRAC from temperature changes
            v.DAMFRACSLR1900[t,r] = (p.SLRDAMAGES[t,r] / 100)   # DAMFRAC from SLR
            v.DAMFRAC1900[t,r] = v.DAMFRACTATM1900[t,r] + v.DAMFRACSLR1900[t,r] # Total DAMFRAC
        end

        # NOT USED
        # NEW: COUNTRY-LEVEL - Define function for country-level DAMFRAC (based on Burke damages relative to 1900 temperatures)
        for c in d.countries
            v.DAMFRACTATMCTRY1900[t,c] = -((p.n1[c] + p.n2[c] * (p.TATM[t])) + (p.n3[c] * (p.TATM[t])^2)) # still need to implement SLRDamages (only add them after DAMFRACTATMCTRY is aggregated to regions again)
        end


        #OLD - Define original function for DAMFRAC
        for r in d.regions
            v.DAMFRACTATMOLD[t,r] = (((p.a1[r] * p.TATM[t]) + (p.a2[r] * p.TATM[t]^p.a3[r])) / 100) # OLD DAMFRAC from temperature changes
            v.DAMFRACSLROLD[t,r] = (p.SLRDAMAGES[t,r] / 100)   # OLD DAMFRAC from SLR
            v.DAMFRACOLD[t,r] = v.DAMFRACTATMOLD[t,r] + v.DAMFRACSLROLD[t,r] # OLD Total DAMFRAC
        end

#-- DAMAGES --
        #NEW: Define function for DAMAGES
        for r in d.regions
            if is_first(t)
                v.DAMAGESTATM[t,r] = p.YGROSS[t,r] * (1 - 1 / (1+v.DAMFRACTATM[t,r])) # DAMAGES from temperature changes
                v.DAMAGESSLR[t,r] = p.YGROSS[t,r] * (1 - 1 / (1+v.DAMFRACSLR[t,r])) # DAMAGES from SLR
                v.DAMAGES[t,r] = v.DAMAGESTATM[t,r] + v.DAMAGESSLR[t,r] # Total DAMAGES
            else
                v.DAMAGESTATM[t,r] = (p.YGROSS[t,r] * v.DAMFRACTATM[t,r]) / (1. + v.DAMFRACTATM[t,r]^10) # DAMAGES from temperature changes
                v.DAMAGESSLR[t,r] = (p.YGROSS[t,r] * v.DAMFRACSLR[t,r]) / (1. + v.DAMFRACSLR[t,r]^10) # DAMAGES from SLR
                v.DAMAGES[t,r] = v.DAMAGESTATM[t,r] + v.DAMAGESSLR[t,r] # Total DAMAGES
            end
        end


        #NOT USED
        #Define function for DAMAGES (with 1900 baseline)
        for r in d.regions
            if is_first(t)
                v.DAMAGESTATM1900[t,r] = p.YGROSS[t,r] * (1 - 1 / (1+v.DAMFRACTATM1900[t,r])) # DAMAGES from temperature changes
                v.DAMAGESSLR1900[t,r] = p.YGROSS[t,r] * (1 - 1 / (1+v.DAMFRACSLR1900[t,r])) # DAMAGES from SLR
                v.DAMAGES1900[t,r] = v.DAMAGESTATM1900[t,r] + v.DAMAGESSLR1900[t,r] # Total DAMAGES
            else
                v.DAMAGESTATM1900[t,r] = (p.YGROSS[t,r] * v.DAMFRACTATM1900[t,r]) / (1. + v.DAMFRACTATM1900[t,r]^10) # DAMAGES from temperature changes
                v.DAMAGESSLR1900[t,r] = (p.YGROSS[t,r] * v.DAMFRACSLR1900[t,r]) / (1. + v.DAMFRACSLR1900[t,r]^10) # DAMAGES from SLR
                v.DAMAGES1900[t,r] = v.DAMAGESTATM1900[t,r] + v.DAMAGESSLR1900[t,r] # Total DAMAGES
            end
        end

        #OLD - Define function for DAMAGES
        for r in d.regions
            if is_first(t)
                v.DAMAGESTATMOLD[t,r] = p.YGROSS[t,r] * (1 - 1 / (1+v.DAMFRACTATMOLD[t,r])) # DAMAGES from temperature changes
                v.DAMAGESSLROLD[t,r] = p.YGROSS[t,r] * (1 - 1 / (1+v.DAMFRACSLROLD[t,r])) # DAMAGES from SLR
                v.DAMAGESOLD[t,r] = v.DAMAGESTATMOLD[t,r] + v.DAMAGESSLROLD[t,r] # Total DAMAGES
            else
                v.DAMAGESTATMOLD[t,r] = (p.YGROSS[t,r] * v.DAMFRACTATMOLD[t,r]) / (1. + v.DAMFRACTATMOLD[t,r]^10) # DAMAGES from temperature changes
                v.DAMAGESSLROLD[t,r] = (p.YGROSS[t,r] * v.DAMFRACSLROLD[t,r]) / (1. + v.DAMFRACSLROLD[t,r]^10) # DAMAGES from SLR
                v.DAMAGESOLD[t,r] = v.DAMAGESTATMOLD[t,r] + v.DAMAGESSLROLD[t,r] # Total DAMAGES
            end
        end
    end
end
