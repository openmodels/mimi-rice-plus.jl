using Mimi

@defcomp damages begin
    regions = Index()
    countries = Index() # NEW: COUNTRY-LEVEL

    DAMFRAC = Variable(index=[time, regions]) # Damages as % of GDP
    DAMAGES = Variable(index=[time, regions]) # Damages (trillions 2005 USD per year)

    # NEW: REGION-LEVEL - to seperate temperature damages and SLR damages
    DAMFRACTATM = Variable(index=[time, regions]) # Damages from temperature change as % of GDP (Burke et al. component)
    DAMFRACSLR = Variable(index=[time, regions]) # Damages from sea level rise as % of GDP

    # NEW: COUNTRY-LEVEL - only temperature damages on a country-level
    DAMFRACTATMCTRY = Variable(index=[time, countries])

    # OLD: REGION-LEVEL - orginal RICE damage function
    DAMFRACTATMOLD = Variable(index=[time, regions]) # Damages from temperature change as % of GDP
    DAMFRACSLROLD = Variable(index=[time, regions]) # Damages from sea level rise as % of GDP
    DAMFRACOLD = Variable(index=[time, regions]) # Damages as % of GDP

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

    function run_timestep(p, v, d, t)

        # NEW: REGION-LEVEL - Define function for DAMFRAC (based on Burke damages relative to Burke temperature baseline)
            # Notes:
            # not devided by 100 as the function already gives damages as a fraction of 1
            # (-) because the function gives damages that are negative but we want a positive DAMFRAC
            # -0.75 adjusts the TATM to the temperature increase relative to Burke baseline (1980-2010) rather then 1900 bseline
                # WARNING: will still need to adjust this
        for r in d.regions
            v.DAMFRACTATM[t,r] = -((p.f1[r] + p.f2[r] * (p.TATM[t] - 0.75)) + (p.f3[r] * (p.TATM[t] - 0.75)^p.a3[r])) # DAMFRAC from temperature changes
            v.DAMFRACSLR[t,r] = (p.SLRDAMAGES[t,r] / 100)   # DAMFRAC from SLR
            v.DAMFRAC[t,r] = v.DAMFRACTATM[t,r] + v.DAMFRACSLR[t,r] # Total DAMFRAC
        end

        # NEW: COUNTRY-LEVEL - Define function for country-level DAMFRAC (based on Burke damages relative to Burke temperature baseline)
        for c in d.countries
            v.DAMFRACTATMCTRY[t,c] = -((p.n1[c] + p.n2[c] * (p.TATM[t] - 0.75)) + (p.n3[c] * (p.TATM[t] - 0.75)^2)) # still need to implement SLRDamages
        end


        #OLD - Define original function for DAMFRAC
        for r in d.regions
            v.DAMFRACTATMOLD[t,r] = (((p.a1[r] * p.TATM[t]) + (p.a2[r] * p.TATM[t]^p.a3[r])) / 100) # DAMFRAC from temperature changes
            v.DAMFRACSLROLD[t,r] = (p.SLRDAMAGES[t,r] / 100)   # DAMFRAC from SLR
            v.DAMFRACOLD[t,r] = v.DAMFRACTATMOLD[t,r] + v.DAMFRACSLROLD[t,r] # Total DAMFRAC
        end

        #Define function for DAMAGES
        for r in d.regions
            if is_first(t)
                v.DAMAGES[t,r] = p.YGROSS[t,r] * (1 - 1 / (1+v.DAMFRAC[t,r]))
            else
                v.DAMAGES[t,r] = (p.YGROSS[t,r] * v.DAMFRAC[t,r]) / (1. + v.DAMFRAC[t,r]^10)
            end
        end
    end
end
