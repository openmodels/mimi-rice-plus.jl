using Mimi

@defcomp damages begin
    regions = Index()

    DAMFRAC = Variable(index=[time, regions]) # Damages as % of GDP
    DAMAGES = Variable(index=[time, regions]) # Damages (trillions 2005 USD per year)

    TATM = Parameter(index=[time]) # Increase temperature of atmosphere (degrees C from 1900)
    YGROSS = Parameter(index=[time, regions]) # Gross world product GROSS of abatement and damages (trillions 2005 USD per year)
    SLRDAMAGES = Parameter(index=[time, regions])
    a1 = Parameter(index=[regions]) # Damage linear term
    a2 = Parameter(index=[regions]) # Damage quadratic term
    a3 = Parameter(index=[regions]) # Damage exponent

        # changes
    f1 = Parameter(index=[regions]) # Damage intercept
    f2 = Parameter(index=[regions]) # Damage linear term
    f3 = Parameter(index=[regions]) # Damage quadratic term

    function run_timestep(p, v, d, t)

            # changes
        # NEW - Define function for DAMFRAC (based on Burke damages relative to Burke temperature baseline)

        # Notes:
        # not devided by 100 as the function already gives damages as a fraction of 1
        # (-) because the function gives damages that are negative but we want a positive DAMFRAC
        # -0.75 adjusts the TATM to the temperature increase relative to Burke baseline (1980-2010) rather then 1900 bseline
                # WARNING: may still need to adjust this

        for r in d.regions
            v.DAMFRAC[t,r] = -((p.f1[r] + p.f2[r] * (p.TATM[t] - 0.75)) + (p.f3[r] * (p.TATM[t] - 0.75)^p.a3[r])) + (p.SLRDAMAGES[t,r] / 100)
        end


        #OLD - Define function for DAMFRAC
        #for r in d.regions
        #    v.DAMFRAC[t,r] = (((p.a1[r] * p.TATM[t]) + (p.a2[r] * p.TATM[t]^p.a3[r])) / 100) + (p.SLRDAMAGES[t,r] / 100)
        #end

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
