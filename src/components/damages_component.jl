using Mimi
using DelimitedFiles
using CSVFiles
using DataFrames
using CSV
using Distributions

# define the output directory
#dir_output = "C:/Users/simon/Google Drive/Uni/LSE Master/02_Dissertation/10_Modelling/damage-regressions/data/mimi-rice-output/"

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
    DAMAGESTATMctryagg = Variable(index=[time, regions]) # REGION-LEVEL - CTRY level SLR damages aggregated back up to regions (trillions 2005 USD per year)
    DAMAGESSLRctryagg = Variable(index=[time, regions]) # REGION-LEVEL - CTRY level SLR damages aggregated back up to regions (trillions 2005 USD per year)
    DAMAGESctryagg = Variable(index=[time, regions]) # Damages (trillions 2005 USD per year)

    # NEW: COUNTRY-LEVEL - only temperature damages on a country-level
    DAMFRACTATMCTRY = Variable(index=[time, countries]) # COUNTRY-LEVEL - Damages as % of GDP
    DAMAGESTATMCTRY = Variable(index=[time, countries]) # COUNTRY-LEVEL - Damages (trillions 2005 USD per year)
    DAMFRACSLRCTRY = Variable(index=[time, countries]) # COUNTRY-LEVEL - SLR Damages as % of GDP
    DAMFRACSLRCTRYcoastalpop = Variable(index=[time, countries]) # COUNTRY-LEVEL - SLR Damages as % of GDP
    DAMFRACSLRCTRYreverse = Variable(index=[time, countries]) # COUNTRY-LEVEL - SLR Damages as % of GDP
    DAMAGESSLRCTRYcoastalpop = Variable(index=[time, countries]) # COUNTRY-LEVEL - SLR Damages (trillions 2005 USD per year)
    DAMAGESSLRCTRY = Variable(index=[time, countries]) # COUNTRY-LEVEL - SLR Damages (trillions 2005 USD per year)
    DAMAGESCTRY = Variable(index=[time, countries]) # COUNTRY-LEVEL - Damages (trillions 2005 USD per year)
    DAMFRACCTRY = Variable(index=[time, countries]) # COUNTRY-LEVEL - Damages as % of GDP

    # NEW: NOT USED: Damage function specification based on temperature increase relative to Projection System baseline (1981-2015)
    DAMFRAC1998 = Variable(index=[time, regions]) # Damages as % of GDP - Projection System baseline (1981-2015) baseline
    DAMAGES1998 = Variable(index=[time, regions]) # Damages (trillions 2005 USD per year) - Projection System baseline (1981-2015) baseline
    DAMFRACTATM1998 = Variable(index=[time, regions]) # Damages from temperature change as % of GDP (Burke et al. component)  - Projection System baseline (1981-2015) baseline
    DAMFRACSLR1998 = Variable(index=[time, regions]) # Damages from sea level rise as % of GDP  - Projection System baseline (1981-2015) baseline
    DAMAGESTATM1998 = Variable(index=[time, regions]) # Damages from temperature change (in trillions 2005 USD per year) (Burke et al. component) - Projection System baseline (1981-2015) baseline
    DAMAGESSLR1998 = Variable(index=[time, regions]) # Damages from sea level rise (in trillions 2005 USD per year) - Projection System baseline (1981-2015) baseline
    DAMFRACTATMCTRY1998 = Variable(index=[time, countries]) # COUNTRY-LEVEL - Damages as % of GDP - only temperature damages on a country-level - Projection System baseline (1981-2015) baseline
    DAMAGESTATMCTRY1998 = Variable(index=[time, countries]) # COUNTRY-LEVEL - Damages (trillions 2005 USD per year) - Projection System baseline (1981-2015) baseline

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

    # NEW: COUNTRY-LEVEL - YGROSSCTRY
    YGROSSCTRY = Parameter(index=[time, countries]) # Gross domestic product GROSS of abatement and damages (trillions 2005 USD per year)

    # NEW: COUNTRY-LEVEL - Coastal population share to calculate country-level SLR damages
    coastalpopshare = Parameter(index=[countries]) # Coastal population share
    inregion = Parameter(index=[countries]) # attributing a country to the region it belongs to
    gdpshare = Parameter(index=[countries]) # GDP share of a country relative to the region GDP

    compoundshare = Variable(index=[countries])
    compoundshareregionsum = Variable(index=[regions])

    # a1 and a2 are not used anymore (a3 is still used)
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

    #     # NEW: COUNTRY-LEVEL - GDP share
    # gdpshare = Parameter(index=[countries]) # GDP share of a country relative to the region GDP


#############################################################################################################################################
##### DAMFRAC ###############################################################################################################################
#############################################################################################################################################

    function run_timestep(p, v, d, t)

        for c in d.countries
            v.compoundshare[c] = p.coastalpopshare[c] * p.gdpshare[c]
        end

        # NEW: REGION-LEVEL - Define function for DAMFRAC (based on Burke damages relative to 1900 temperatures)
            # Notes:
            # not devided by 100 as the function already gives damages as a fraction of 1
            # (-) because the function gives damages that are negative but we want a positive DAMFRAC
        for r in d.regions
            v.DAMFRACTATM[t,r] = -((p.f1[r] + p.f2[r] * (p.TATM[t])) + (p.f3[r] * (p.TATM[t])^p.a3[r])) # DAMFRAC from temperature changes
            v.DAMFRACSLR[t,r] = (p.SLRDAMAGES[t,r] / 100)   # DAMFRAC from SLR
            v.DAMFRAC[t,r] = v.DAMFRACTATM[t,r] + v.DAMFRACSLR[t,r] # Total DAMFRAC
        end

        # NEW: COUNTRY-LEVEL - Define function for country-level DAMFRAC (based on Burke damages relative to 1900 temperatures)
        for c in d.countries
            v.DAMFRACTATMCTRY[t,c] = -((p.n1[c] + p.n2[c] * (p.TATM[t])) + (p.n3[c] * (p.TATM[t])^2)) # SLR DAMFRAC is calculated below
        end

        # NOT USED:
        # NEW: REGION-LEVEL - Define function for DAMFRAC (based on Burke damages relative to PS temperature baseline)
            # Notes:
            # -0.70 adjusts the TATM to the temperature increase relative to Burke baseline (1980-2010) rather then 1900 bseline
        for r in d.regions
            v.DAMFRACTATM1998[t,r] = -((p.f1[r] + p.f2[r] * (p.TATM[t] - 0.70)) + (p.f3[r] * (p.TATM[t] - 0.70)^p.a3[r])) # DAMFRAC from temperature changes
            v.DAMFRACSLR1998[t,r] = (p.SLRDAMAGES[t,r] / 100)   # DAMFRAC from SLR
            v.DAMFRAC1998[t,r] = v.DAMFRACTATM1998[t,r] + v.DAMFRACSLR1998[t,r] # Total DAMFRAC
        end

        # NOT USED:
        # NEW: COUNTRY-LEVEL - Define function for country-level DAMFRAC (based on Burke damages relative to PS temperature baseline)
        for c in d.countries
            v.DAMFRACTATMCTRY1998[t,c] = -((p.n1[c] + p.n2[c] * (p.TATM[t] - 0.70)) + (p.n3[c] * (p.TATM[t] - 0.70)^2)) # still need to implement SLRDamages (only add them after DAMFRACTATMCTRY is aggregated to regions again)
        end


        #OLD - Define original function for DAMFRAC
        for r in d.regions
            v.DAMFRACTATMOLD[t,r] = (((p.a1[r] * p.TATM[t]) + (p.a2[r] * p.TATM[t]^p.a3[r])) / 100) # OLD DAMFRAC from temperature changes
            v.DAMFRACSLROLD[t,r] = (p.SLRDAMAGES[t,r] / 100)   # OLD DAMFRAC from SLR
            v.DAMFRACOLD[t,r] = v.DAMFRACTATMOLD[t,r] + v.DAMFRACSLROLD[t,r] # OLD Total DAMFRAC
        end


##############################################################################################################################################
##### DAMAGES ################################################################################################################################
##############################################################################################################################################

        #Define function for DAMAGES (with 1900 baseline)
        for r in d.regions
            if is_first(t)
                v.DAMAGESTATM[t,r] = p.YGROSS[t,r] * (1 - 1 / (1+v.DAMFRACTATM[t,r])) # DAMAGES from temperature changes
                v.DAMAGESSLR[t,r] = p.YGROSS[t,r] * (1 - 1 / (1+v.DAMFRACSLR[t,r])) # DAMAGES from SLR
                v.DAMAGES[t,r] = v.DAMAGESTATM[t,r] + v.DAMAGESSLR[t,r] # Total DAMAGES
            else
                v.DAMAGESTATM[t,r] = (p.YGROSS[t,r] * v.DAMFRACTATM[t,r]) / (1. + v.DAMFRACTATM[t,r]) # DAMAGES from temperature changes
                v.DAMAGESSLR[t,r] = (p.YGROSS[t,r] * v.DAMFRACSLR[t,r]) / (1. + v.DAMFRACSLR[t,r]) # DAMAGES from SLR
                v.DAMAGES[t,r] = v.DAMAGESTATM[t,r] + v.DAMAGESSLR[t,r] # Total DAMAGES
            end
        end

        # NEW: COUNTRY-LEVEL - Define function for country-level DAMAGES (with 1900 baseline) (calculated with a constant GDP share (as in 2016) of countries of the total region GDP)
        for c in d.countries
            if is_first(t)
                v.DAMAGESTATMCTRY[t,c] = p.YGROSSCTRY[t,c] * (1 - 1 / (1+v.DAMFRACTATMCTRY[t,c])) # DAMAGES from temperature changes
                # v.DAMAGESSLR[t,r] = p.YGROSS[t,r] * (1 - 1 / (1+v.DAMFRACSLR[t,r])) # DAMAGES from SLR
                # v.DAMAGES[t,r] = v.DAMAGESTATM[t,r] + v.DAMAGESSLR[t,r] # Total DAMAGES
            else
                v.DAMAGESTATMCTRY[t,c] = (p.YGROSSCTRY[t,c] * v.DAMFRACTATMCTRY[t,c]) / (1. + v.DAMFRACTATMCTRY[t,c]) # DAMAGES from temperature changes
                # v.DAMAGESSLR[t,r] = (p.YGROSS[t,r] * v.DAMFRACSLR[t,r]) / (1. + v.DAMFRACSLR[t,r]) # DAMAGES from SLR
                # v.DAMAGES[t,r] = v.DAMAGESTATM[t,r] + v.DAMAGESSLR[t,r] # Total DAMAGES
            end
        end

##### SLR DAMAGES - Approach #1: weighting based only on coastalpopshare  #########################################################################################

        # NEW: COUNTRY-LEVEL - Define function function for country-level SLR DAMAGES (Approach #1: calculated with a constant coastalpopshare)
        for c in d.countries
            if p.inregion[c] == 1
                v.DAMAGESSLRCTRYcoastalpop[t,c] = v.DAMAGESSLR[t,1] * p.coastalpopshare[c]
            elseif p.inregion[c] == 2
                v.DAMAGESSLRCTRYcoastalpop[t,c] = v.DAMAGESSLR[t,2] * p.coastalpopshare[c]
            elseif p.inregion[c] == 3
                v.DAMAGESSLRCTRYcoastalpop[t,c] = v.DAMAGESSLR[t,3] * p.coastalpopshare[c]
            elseif p.inregion[c] == 4
                v.DAMAGESSLRCTRYcoastalpop[t,c] = v.DAMAGESSLR[t,4] * p.coastalpopshare[c]
            elseif p.inregion[c] == 5
                v.DAMAGESSLRCTRYcoastalpop[t,c] = v.DAMAGESSLR[t,5] * p.coastalpopshare[c]
            elseif p.inregion[c] == 6
                v.DAMAGESSLRCTRYcoastalpop[t,c] = v.DAMAGESSLR[t,6] * p.coastalpopshare[c]
            elseif p.inregion[c] == 7
                v.DAMAGESSLRCTRYcoastalpop[t,c] = v.DAMAGESSLR[t,7] * p.coastalpopshare[c]
            elseif p.inregion[c] == 8
                v.DAMAGESSLRCTRYcoastalpop[t,c] = v.DAMAGESSLR[t,8] * p.coastalpopshare[c]
            elseif p.inregion[c] == 9
                v.DAMAGESSLRCTRYcoastalpop[t,c] = v.DAMAGESSLR[t,9] * p.coastalpopshare[c]
            elseif p.inregion[c] == 10
                v.DAMAGESSLRCTRYcoastalpop[t,c] = v.DAMAGESSLR[t,10] * p.coastalpopshare[c]
            elseif p.inregion[c] == 11
                v.DAMAGESSLRCTRYcoastalpop[t,c] = v.DAMAGESSLR[t,11] * p.coastalpopshare[c]
            elseif p.inregion[c] == 12
                v.DAMAGESSLRCTRYcoastalpop[t,c] = v.DAMAGESSLR[t,12] * p.coastalpopshare[c]
            else
                println("country does not belong to any region")
            end
        end


##### SLR DAMAGES - Approach #2: weighting based on coastalpopshare and gdpshare #################################################################################

        # NEW: COUNTRY-LEVEL - Define function function for country-level SLR DAMAGES (Approach #2: weighted with coastalpopshare and gdpshare)

        # set initial value of compoundshareregionsum to 0
        v.compoundshareregionsum[1] = 0
        v.compoundshareregionsum[2] = 0
        v.compoundshareregionsum[3] = 0
        v.compoundshareregionsum[4] = 0
        v.compoundshareregionsum[5] = 0
        v.compoundshareregionsum[6] = 0
        v.compoundshareregionsum[7] = 0
        v.compoundshareregionsum[8] = 0
        v.compoundshareregionsum[9] = 0
        v.compoundshareregionsum[10] = 0
        v.compoundshareregionsum[11] = 0
        v.compoundshareregionsum[12] = 0

        for c in d.countries
            if p.inregion[c] == 1
                global v.compoundshareregionsum[1] = v.compoundshareregionsum[1] + v.compoundshare[c]
            elseif p.inregion[c] == 2
                global v.compoundshareregionsum[2] = v.compoundshareregionsum[2] + v.compoundshare[c]
            elseif p.inregion[c] == 3
                global v.compoundshareregionsum[3] = v.compoundshareregionsum[3] + v.compoundshare[c]
            elseif p.inregion[c] == 4
                global v.compoundshareregionsum[4] = v.compoundshareregionsum[4] + v.compoundshare[c]
            elseif p.inregion[c] == 5
                global v.compoundshareregionsum[5] = v.compoundshareregionsum[5] + v.compoundshare[c]
            elseif p.inregion[c] == 6
                global v.compoundshareregionsum[6] = v.compoundshareregionsum[6] + v.compoundshare[c]
            elseif p.inregion[c] == 7
                global v.compoundshareregionsum[7] = v.compoundshareregionsum[7] + v.compoundshare[c]
            elseif p.inregion[c] == 8
                global v.compoundshareregionsum[8] = v.compoundshareregionsum[8] + v.compoundshare[c]
            elseif p.inregion[c] == 9
                global v.compoundshareregionsum[9] = v.compoundshareregionsum[9] + v.compoundshare[c]
            elseif p.inregion[c] == 10
                global v.compoundshareregionsum[10] = v.compoundshareregionsum[10] + v.compoundshare[c]
            elseif p.inregion[c] == 11
                global v.compoundshareregionsum[11] = v.compoundshareregionsum[11] + v.compoundshare[c]
            elseif p.inregion[c] == 12
                global v.compoundshareregionsum[12] = v.compoundshareregionsum[12] + v.compoundshare[c]
            else
                println("country does not belong to any region")
            end
        end


        # NEW: COUNTRY-LEVEL - Define function function for country-level SLR DAMAGES (calculated with a constant coastalpopshare)
        for c in d.countries
            if p.inregion[c] == 1
                v.DAMAGESSLRCTRY[t,c] = v.DAMAGESSLR[t,1] * (v.compoundshare[c] / v.compoundshareregionsum[1])
            elseif p.inregion[c] == 2
                v.DAMAGESSLRCTRY[t,c] = v.DAMAGESSLR[t,2] * (v.compoundshare[c] / v.compoundshareregionsum[2])
            elseif p.inregion[c] == 3
                v.DAMAGESSLRCTRY[t,c] = v.DAMAGESSLR[t,3] * (v.compoundshare[c] / v.compoundshareregionsum[3])
            elseif p.inregion[c] == 4
                v.DAMAGESSLRCTRY[t,c] = v.DAMAGESSLR[t,4] * (v.compoundshare[c] / v.compoundshareregionsum[4])
            elseif p.inregion[c] == 5
                v.DAMAGESSLRCTRY[t,c] = v.DAMAGESSLR[t,5] * (v.compoundshare[c] / v.compoundshareregionsum[5])
            elseif p.inregion[c] == 6
                v.DAMAGESSLRCTRY[t,c] = v.DAMAGESSLR[t,6] * (v.compoundshare[c] / v.compoundshareregionsum[6])
            elseif p.inregion[c] == 7
                v.DAMAGESSLRCTRY[t,c] = v.DAMAGESSLR[t,7] * (v.compoundshare[c] / v.compoundshareregionsum[7])
            elseif p.inregion[c] == 8
                v.DAMAGESSLRCTRY[t,c] = v.DAMAGESSLR[t,8] * (v.compoundshare[c] / v.compoundshareregionsum[8])
            elseif p.inregion[c] == 9
                v.DAMAGESSLRCTRY[t,c] = v.DAMAGESSLR[t,9] * (v.compoundshare[c] / v.compoundshareregionsum[9])
            elseif p.inregion[c] == 10
                v.DAMAGESSLRCTRY[t,c] = v.DAMAGESSLR[t,10] * (v.compoundshare[c] / v.compoundshareregionsum[10])
            elseif p.inregion[c] == 11
                v.DAMAGESSLRCTRY[t,c] = v.DAMAGESSLR[t,11] * (v.compoundshare[c] / v.compoundshareregionsum[11])
            elseif p.inregion[c] == 12
                v.DAMAGESSLRCTRY[t,c] = v.DAMAGESSLR[t,12] * (v.compoundshare[c] / v.compoundshareregionsum[12])
            else
                println("country does not belong to any region")
            end
        end


##### NEW: Aggregate back up to regions #################################################################################################################

##### Temperature Damages

        # set initial value of DAMAGESTATMctryagg to 0
        v.DAMAGESTATMctryagg[t,1] = 0
        v.DAMAGESTATMctryagg[t,2] = 0
        v.DAMAGESTATMctryagg[t,3] = 0
        v.DAMAGESTATMctryagg[t,4] = 0
        v.DAMAGESTATMctryagg[t,5] = 0
        v.DAMAGESTATMctryagg[t,6] = 0
        v.DAMAGESTATMctryagg[t,7] = 0
        v.DAMAGESTATMctryagg[t,8] = 0
        v.DAMAGESTATMctryagg[t,9] = 0
        v.DAMAGESTATMctryagg[t,10] = 0
        v.DAMAGESTATMctryagg[t,11] = 0
        v.DAMAGESTATMctryagg[t,12] = 0

        for c in d.countries
            if p.inregion[c] == 1
                global v.DAMAGESTATMctryagg[t,1] = v.DAMAGESTATMctryagg[t,1] + v.DAMAGESTATMCTRY[t,c]
            elseif p.inregion[c] == 2
                global v.DAMAGESTATMctryagg[t,2] = v.DAMAGESTATMctryagg[t,2] + v.DAMAGESTATMCTRY[t,c]
            elseif p.inregion[c] == 3
                global v.DAMAGESTATMctryagg[t,3] = v.DAMAGESTATMctryagg[t,3] + v.DAMAGESTATMCTRY[t,c]
            elseif p.inregion[c] == 4
                global v.DAMAGESTATMctryagg[t,4] = v.DAMAGESTATMctryagg[t,4] + v.DAMAGESTATMCTRY[t,c]
            elseif p.inregion[c] == 5
                global v.DAMAGESTATMctryagg[t,5] = v.DAMAGESTATMctryagg[t,5] + v.DAMAGESTATMCTRY[t,c]
            elseif p.inregion[c] == 6
                global v.DAMAGESTATMctryagg[t,6] = v.DAMAGESTATMctryagg[t,6] + v.DAMAGESTATMCTRY[t,c]
            elseif p.inregion[c] == 7
                global v.DAMAGESTATMctryagg[t,7] = v.DAMAGESTATMctryagg[t,7] + v.DAMAGESTATMCTRY[t,c]
            elseif p.inregion[c] == 8
                global v.DAMAGESTATMctryagg[t,8] = v.DAMAGESTATMctryagg[t,8] + v.DAMAGESTATMCTRY[t,c]
            elseif p.inregion[c] == 9
                global v.DAMAGESTATMctryagg[t,9] = v.DAMAGESTATMctryagg[t,9] + v.DAMAGESTATMCTRY[t,c]
            elseif p.inregion[c] == 10
                global v.DAMAGESTATMctryagg[t,10] = v.DAMAGESTATMctryagg[t,10] + v.DAMAGESTATMCTRY[t,c]
            elseif p.inregion[c] == 11
                global v.DAMAGESTATMctryagg[t,11] = v.DAMAGESTATMctryagg[t,11] + v.DAMAGESTATMCTRY[t,c]
            elseif p.inregion[c] == 12
                global v.DAMAGESTATMctryagg[t,12] = v.DAMAGESTATMctryagg[t,12] + v.DAMAGESTATMCTRY[t,c]
            else
                println("country does not belong to any region")
            end
        end


##### SLR DAMAGES

        # set initial value of DAMAGESSLRctryagg to 0
        v.DAMAGESSLRctryagg[t,1] = 0
        v.DAMAGESSLRctryagg[t,2] = 0
        v.DAMAGESSLRctryagg[t,3] = 0
        v.DAMAGESSLRctryagg[t,4] = 0
        v.DAMAGESSLRctryagg[t,5] = 0
        v.DAMAGESSLRctryagg[t,6] = 0
        v.DAMAGESSLRctryagg[t,7] = 0
        v.DAMAGESSLRctryagg[t,8] = 0
        v.DAMAGESSLRctryagg[t,9] = 0
        v.DAMAGESSLRctryagg[t,10] = 0
        v.DAMAGESSLRctryagg[t,11] = 0
        v.DAMAGESSLRctryagg[t,12] = 0

        for c in d.countries
            if p.inregion[c] == 1
                global v.DAMAGESSLRctryagg[t,1] = v.DAMAGESSLRctryagg[t,1] + v.DAMAGESSLRCTRY[t,c]
            elseif p.inregion[c] == 2
                global v.DAMAGESSLRctryagg[t,2] = v.DAMAGESSLRctryagg[t,2] + v.DAMAGESSLRCTRY[t,c]
            elseif p.inregion[c] == 3
                global v.DAMAGESSLRctryagg[t,3] = v.DAMAGESSLRctryagg[t,3] + v.DAMAGESSLRCTRY[t,c]
            elseif p.inregion[c] == 4
                global v.DAMAGESSLRctryagg[t,4] = v.DAMAGESSLRctryagg[t,4] + v.DAMAGESSLRCTRY[t,c]
            elseif p.inregion[c] == 5
                global v.DAMAGESSLRctryagg[t,5] = v.DAMAGESSLRctryagg[t,5] + v.DAMAGESSLRCTRY[t,c]
            elseif p.inregion[c] == 6
                global v.DAMAGESSLRctryagg[t,6] = v.DAMAGESSLRctryagg[t,6] + v.DAMAGESSLRCTRY[t,c]
            elseif p.inregion[c] == 7
                global v.DAMAGESSLRctryagg[t,7] = v.DAMAGESSLRctryagg[t,7] + v.DAMAGESSLRCTRY[t,c]
            elseif p.inregion[c] == 8
                global v.DAMAGESSLRctryagg[t,8] = v.DAMAGESSLRctryagg[t,8] + v.DAMAGESSLRCTRY[t,c]
            elseif p.inregion[c] == 9
                global v.DAMAGESSLRctryagg[t,9] = v.DAMAGESSLRctryagg[t,9] + v.DAMAGESSLRCTRY[t,c]
            elseif p.inregion[c] == 10
                global v.DAMAGESSLRctryagg[t,10] = v.DAMAGESSLRctryagg[t,10] + v.DAMAGESSLRCTRY[t,c]
            elseif p.inregion[c] == 11
                global v.DAMAGESSLRctryagg[t,11] = v.DAMAGESSLRctryagg[t,11] + v.DAMAGESSLRCTRY[t,c]
            elseif p.inregion[c] == 12
                global v.DAMAGESSLRctryagg[t,12] = v.DAMAGESSLRctryagg[t,12] + v.DAMAGESSLRCTRY[t,c]
            else
                println("country does not belong to any region")
            end
        end


#### SLR DAMFRAC ######################################################################################################################################################

        # NEW: COUNTRY-LEVEL - Define function function for country-level SLR DAMFRAC
        for c in d.countries
                v.DAMFRACSLRCTRYcoastalpop[t,c] = v.DAMAGESSLRCTRYcoastalpop[t,c] / p.YGROSSCTRY[t,c]
        end

        # NEW: COUNTRY-LEVEL - Define function function for country-level SLR DAMFRAC
        for c in d.countries
                v.DAMFRACSLRCTRY[t,c] = v.DAMAGESSLRCTRY[t,c] / p.YGROSSCTRY[t,c]
        end

        # NEW: COUNTRY-LEVEL - Attempt to reverse calculate the DAMFRAC --> weird results
        for c in d.countries
                v.DAMFRACSLRCTRYreverse[t,c] = (v.DAMAGESSLRCTRYcoastalpop[t,c] / p.YGROSSCTRY[t,c]) / (1. - (v.DAMAGESSLRCTRYcoastalpop[t,c] / p.YGROSSCTRY[t,c]))
        end


#### Summing up SLR and Temperature damages/damage fractions to get TOTAL damages/damage fractions #####################################################################

        # for regions
        for r in d.regions
                v.DAMAGESctryagg[t,r] = v.DAMAGESTATMctryagg[t,r] + v.DAMAGESSLRctryagg[t,r] # Total region-level DAMAGES from country-to-region aggregation
        end

        # for countries
        for c in d.countries
                v.DAMAGESCTRY[t,c] = v.DAMAGESTATMCTRY[t,c] + v.DAMAGESSLRCTRY[t,c] # Total country-level DAMAGES
                v.DAMFRACCTRY[t,c] = v.DAMFRACTATMCTRY[t,c] + v.DAMFRACSLRCTRY[t,c] # Total country-level DAMAGES
        end


#### OLD / NOT USED ####################################################################################################################################################

        # NOT USED:
        # NEW: REGION-LEVEL - Define function for DAMAGES (relative to Projection System Baseline (1981-2015))
        for r in d.regions
            if is_first(t)
                v.DAMAGESTATM1998[t,r] = p.YGROSS[t,r] * (1 - 1 / (1+v.DAMFRACTATM1998[t,r])) # DAMAGES from temperature changes
                v.DAMAGESSLR1998[t,r] = p.YGROSS[t,r] * (1 - 1 / (1+v.DAMFRACSLR1998[t,r])) # DAMAGES from SLR
                v.DAMAGES1998[t,r] = v.DAMAGESTATM1998[t,r] + v.DAMAGESSLR1998[t,r] # Total DAMAGES
            else
                v.DAMAGESTATM1998[t,r] = (p.YGROSS[t,r] * v.DAMFRACTATM1998[t,r]) / (1. + v.DAMFRACTATM1998[t,r]) # DAMAGES from temperature changes
                v.DAMAGESSLR1998[t,r] = (p.YGROSS[t,r] * v.DAMFRACSLR1998[t,r]) / (1. + v.DAMFRACSLR1998[t,r]) # DAMAGES from SLR
                v.DAMAGES1998[t,r] = v.DAMAGESTATM1998[t,r] + v.DAMAGESSLR1998[t,r] # Total DAMAGES
            end
        end

        # NOT USED:
        # NEW: COUNTRY-LEVEL - Define function for country-level DAMAGES (relative to Projection System Baseline (1981-2015)) (calculated with a constant GDP share (as in 2016) of countries of the total region GDP)
        for c in d.countries
            if is_first(t)
                v.DAMAGESTATMCTRY1998[t,c] = p.YGROSSCTRY[t,c] * (1 - 1 / (1+v.DAMFRACTATMCTRY1998[t,c])) # DAMAGES from temperature changes
                # v.DAMAGESSLR[t,r] = p.YGROSS[t,r] * (1 - 1 / (1+v.DAMFRACSLR[t,r])) # DAMAGES from SLR
                # v.DAMAGES[t,r] = v.DAMAGESTATM[t,r] + v.DAMAGESSLR[t,r] # Total DAMAGES
            else
                v.DAMAGESTATMCTRY1998[t,c] = (p.YGROSSCTRY[t,c] * v.DAMFRACTATMCTRY1998[t,c]) / (1. + v.DAMFRACTATMCTRY1998[t,c]) # DAMAGES from temperature changes
                # v.DAMAGESSLR[t,r] = (p.YGROSS[t,r] * v.DAMFRACSLR[t,r]) / (1. + v.DAMFRACSLR[t,r]) # DAMAGES from SLR
                # v.DAMAGES[t,r] = v.DAMAGESTATM[t,r] + v.DAMAGESSLR[t,r] # Total DAMAGES
            end
        end


        #OLD - Define function for DAMAGES
        for r in d.regions
            if is_first(t)
                v.DAMAGESTATMOLD[t,r] = p.YGROSS[t,r] * (1 - 1 / (1+v.DAMFRACTATMOLD[t,r])) # DAMAGES from temperature changes
                v.DAMAGESSLROLD[t,r] = p.YGROSS[t,r] * (1 - 1 / (1+v.DAMFRACSLROLD[t,r])) # DAMAGES from SLR
                v.DAMAGESOLD[t,r] = v.DAMAGESTATMOLD[t,r] + v.DAMAGESSLROLD[t,r] # Total DAMAGES
            else
                v.DAMAGESTATMOLD[t,r] = (p.YGROSS[t,r] * v.DAMFRACTATMOLD[t,r]) / (1. + v.DAMFRACTATMOLD[t,r]) # DAMAGES from temperature changes
                v.DAMAGESSLROLD[t,r] = (p.YGROSS[t,r] * v.DAMFRACSLROLD[t,r]) / (1. + v.DAMFRACSLROLD[t,r]) # DAMAGES from SLR
                v.DAMAGESOLD[t,r] = v.DAMAGESTATMOLD[t,r] + v.DAMAGESSLROLD[t,r] # Total DAMAGES
            end
        end


        # only old attempts

        # # Export csv-file for selected years
        # for r in d.regions
        #     if is_first(t)
        #         writedlm("DAMFRACTATM.csv",  v.DAMFRACTATM[t,r], ',')
        #     else
        #         writedlm("DAMFRACTATM.csv",  v.DAMFRACTATM[t,r], ',')
        #     end
        # end

        # for r in d.regions
        #     if is_first(t)
        #         writedlm(string(dir_output, "damfractatm", "_year", string(time), ".csv"),
        #                          [permutedims(regions); v.DAMFRACTATM[t,r]], ",")
        #     else
        #         writedlm(string(dir_output, "damfractatm", "_year", string(time), ".csv"),
        #                          [permutedims(regions); v.DAMFRACTATM[t,r]], ",")
        #     end
        # end
        #
        # CSV.write(string(dir_output, "damfractatm.csv"), v.DAMFRACTATM)

    end
end
