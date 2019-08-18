using Mimi
using DelimitedFiles
using CSVFiles
using DataFrames
using CSV

include("rice2010.jl")
using .Rice2010


# Set the model version manually in the following components:
# 1) grosseconomy
# 2) neteconomy

# set output directory
dir_output = "C:/Users/simon/Google Drive/Uni/LSE Master/02_Dissertation/10_Modelling/damage-regressions/data/mimi-rice-output/temporary/"


######################################################################################################################
####  Orginal Model  #################################################################################################
######################################################################################################################

m = getrice()

marginalemission = 0    # 1 = additional emission pulse; 0 otherwise
set_param!(m,:emissions,:marginalemission,marginalemission)

marginalconsumption = 0    # 1 = additional consumption pulse; 0 otherwise
set_param!(m,:neteconomy,:marginalconsumption,marginalconsumption)

run(m)

# NEW: export model output to make graphs

############################################################################
#### Export variable values ################################################
############################################################################

# Climate Dynamics
writedlm(string(dir_output, "TATM.csv"), m[:climatedynamics, :TATM], ",")

# DAMAGES
writedlm(string(dir_output, "DAMAGES.csv"), m[:damages, :DAMAGES], ",")
writedlm(string(dir_output, "DAMAGESCTRY.csv"), m[:damages, :DAMAGESCTRY], ",")
writedlm(string(dir_output, "DAMAGESctryagg.csv"), m[:damages, :DAMAGESctryagg], ",")
writedlm(string(dir_output, "DAMAGESOLD.csv"), m[:damages, :DAMAGESOLD], ",")

writedlm(string(dir_output, "DAMAGESSLR.csv"), m[:damages, :DAMAGESSLR], ",")
writedlm(string(dir_output, "DAMAGESSLRCTRY.csv"), m[:damages, :DAMAGESSLRCTRY], ",")

writedlm(string(dir_output, "DAMAGESTATM.csv"), m[:damages, :DAMAGESTATM], ",")
writedlm(string(dir_output, "DAMAGESTATMCTRY.csv"), m[:damages, :DAMAGESTATMCTRY], ",")
writedlm(string(dir_output, "DAMAGESTATMctryagg.csv"), m[:damages, :DAMAGESTATMctryagg], ",")
writedlm(string(dir_output, "DAMAGESTATMOLD.csv"), m[:damages, :DAMAGESTATMOLD], ",")

# Damage Fraction
writedlm(string(dir_output, "DAMFRAC.csv"), m[:damages, :DAMFRAC], ",")
writedlm(string(dir_output, "DAMFRACCTRY.csv"), m[:damages, :DAMFRACCTRY], ",")
writedlm(string(dir_output, "DAMFRACOLD.csv"), m[:damages, :DAMFRACOLD], ",")

writedlm(string(dir_output, "DAMFRACSLR.csv"), m[:damages, :DAMFRACSLR], ",")
writedlm(string(dir_output, "DAMFRACSLRCTRY.csv"), m[:damages, :DAMFRACSLRCTRY], ",")
writedlm(string(dir_output, "DAMFRACSLROLD.csv"), m[:damages, :DAMFRACSLROLD], ",")

writedlm(string(dir_output, "DAMFRACTATM.csv"), m[:damages, :DAMFRACTATM], ",")
writedlm(string(dir_output, "DAMFRACTATMCTRY.csv"), m[:damages, :DAMFRACTATMCTRY], ",")
writedlm(string(dir_output, "DAMFRACTATMOLD.csv"), m[:damages, :DAMFRACTATMOLD], ",")

writedlm(string(dir_output, "n1.csv"), m[:damages, :n1], ",")
writedlm(string(dir_output, "n2.csv"), m[:damages, :n2], ",")
writedlm(string(dir_output, "n3.csv"), m[:damages, :n3], ",")

writedlm(string(dir_output, "f1.csv"), m[:damages, :f1], ",")
writedlm(string(dir_output, "f2.csv"), m[:damages, :f2], ",")
writedlm(string(dir_output, "f3.csv"), m[:damages, :f3], ",")

writedlm(string(dir_output, "a1.csv"), m[:damages, :a1], ",")
writedlm(string(dir_output, "a2.csv"), m[:damages, :a2], ",")

# Gross Economy
writedlm(string(dir_output, "YGROSS.csv"), m[:grosseconomy, :YGROSS], ",")
writedlm(string(dir_output, "YGROSSctry.csv"), m[:grosseconomy, :YGROSSctry], ",")
writedlm(string(dir_output, "gdpshare.csv"), m[:grosseconomy, :gdpshare], ",")

# Net Economy
writedlm(string(dir_output, "C.csv"), m[:neteconomy, :C], ",")
writedlm(string(dir_output, "Cctry.csv"), m[:neteconomy, :Cctry], ",")
writedlm(string(dir_output, "CPC.csv"), m[:neteconomy, :CPC], ",")
writedlm(string(dir_output, "CPCctry.csv"), m[:neteconomy, :CPCctry], ",")
writedlm(string(dir_output, "Y.csv"), m[:neteconomy, :Y], ",")
writedlm(string(dir_output, "Yctry.csv"), m[:neteconomy, :Yctry], ",")

# SLR
writedlm(string(dir_output, "TOTALSLR.csv"), m[:sealevelrise, :TOTALSLR], ",")

# Welfare
writedlm(string(dir_output, "CEMUTOTPERNOnegishi.csv"), m[:welfare, :CEMUTOTPERNOnegishi], ",")
writedlm(string(dir_output, "CEMUTOTPERNOnegishiPC.csv"), m[:welfare, :CEMUTOTPERNOnegishiPC], ",")
writedlm(string(dir_output, "CEMUTOTPERctryNOnegishi.csv"), m[:welfare, :CEMUTOTPERctryNOnegishi], ",")
writedlm(string(dir_output, "CEMUTOTPERctryNOnegishiPC.csv"), m[:welfare, :CEMUTOTPERctryNOnegishiPC], ",")

writedlm(string(dir_output, "PERIODUNOnegishi.csv"), m[:welfare, :PERIODUNOnegishi], ",")
writedlm(string(dir_output, "PERIODUctryNOnegishi.csv"), m[:welfare, :PERIODUctryNOnegishi], ",")

writedlm(string(dir_output, "REGCUMCEMUTOTPERNOnegishi.csv"), m[:welfare, :REGCUMCEMUTOTPERNOnegishi], ",")
writedlm(string(dir_output, "REGCUMCEMUTOTPERNOnegishiPC.csv"), m[:welfare, :REGCUMCEMUTOTPERNOnegishiPC], ",")
writedlm(string(dir_output, "REGCUMCEMUTOTPERctryNOnegishi.csv"), m[:welfare, :REGCUMCEMUTOTPERctryNOnegishi], ",")
writedlm(string(dir_output, "REGCUMCEMUTOTPERctryNOnegishiPC.csv"), m[:welfare, :REGCUMCEMUTOTPERctryNOnegishiPC], ",")

writedlm(string(dir_output, "REGUTILITYNOnegishiNOrescale.csv"), m[:welfare, :REGUTILITYNOnegishiNOrescale], ",")
writedlm(string(dir_output, "REGUTILITYNOnegishiNOrescalePC.csv"), m[:welfare, :REGUTILITYNOnegishiNOrescalePC], ",")
writedlm(string(dir_output, "REGUTILITYctryNOnegishiNOrescale.csv"), m[:welfare, :REGUTILITYctryNOnegishiNOrescale], ",")
writedlm(string(dir_output, "REGUTILITYctryNOnegishiNOrescalePC.csv"), m[:welfare, :REGUTILITYctryNOnegishiNOrescalePC], ",")

writedlm(string(dir_output, "UTILITYNOnegishiNOrescale.csv"), m[:welfare, :UTILITYNOnegishiNOrescale], ",")
writedlm(string(dir_output, "UTILITYctryaggNOnegishiNOrescale.csv"), m[:welfare, :UTILITYctryaggNOnegishiNOrescale], ",")

# Population
writedlm(string(dir_output, "lctry.csv"), m[:neteconomy, :lctry], ",")
writedlm(string(dir_output, "l.csv"), m[:neteconomy, :l], ",")
writedlm(string(dir_output, "popshare.csv"), m[:neteconomy, :popshare], ",")


# Calculate the baseline variables for SCC calculation

        damagebase = m[:damages,:DAMAGES]
        # println("damagebase")
        # println(damagebase)

        damagebasectryagg = m[:damages,:DAMAGESctryagg]
        # println("damagebasectryagg")
        # println(damagebasectryagg)

        damagebaseOLD = m[:damages,:DAMAGESOLD]
        # println("damagebaseOLD")
        # println(damagebaseOLD)


        consumptionbase = m[:neteconomy,:C]
        # println("consumptionbase")
        # println(consumptionbase)

        consumptionbasectry = m[:neteconomy,:Cctry]
        # println("consumptionbasectry")
        # println(consumptionbasectry)

        # welfarebase = m[:welfare,:REGUTILITYNOnegishiNOrescale]
        # println("welfarebase")
        # println(welfarebase)
        #
        # consumptionbase = m[:neteconomy,:C2015]
        # println("consumptionbase")
        # println(consumptionbase)

explore(m)


######################################################################################################################
####  Model with additional emission pulse  ##########################################################################
######################################################################################################################

m = getrice()

marginalemission = 1    # 1 = additional emission pulse; 0 otherwise
set_param!(m,:emissions,:marginalemission,marginalemission)

marginalconsumption = 0    # 1 = additional consumption pulse; 0 otherwise
set_param!(m,:neteconomy,:marginalconsumption,marginalconsumption)

run(m)


#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!! Manually set the discount rate and compute the discount factor !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

                discountingbegin = 2015
                dr = 0.03      # manually set the discount rate here
                df = zeros(1, 60)

                if discountingbegin == 2005
                        for t in 1:1:60
                                df[t] = 1/(1+dr)^(10(t-1))
                        end
                elseif discountingbegin == 2015
                        for t in 1:1:60
                            if t == 1
                                df[t] = 1
                            else
                                df[t] = 1/(1+dr)^(10(t-2))
                            end
                        end
                end
                println("df")
                print(df)

                                # # Ramsey discounting - only the start --> left it in there should I want to implement it
                                #         global_c = dropdims(sum(m[:neteconomy, :C], dims = 2), dims=2)
                                #         println("global_c")
                                #         println(global_c)
                                #         global_pop = dropdims(sum(m[:neteconomy, :l], dims = 2), dims=2)
                                #         println("global_pop")
                                #         println(global_pop)
                                #         global_cpc = 1000 .* global_c ./ global_pop
                                #         println("global_cpc")
                                #         println(global_cpc)

#### SCC based on region damages ##############################################################################################################################

        damageadd = m[:damages,:DAMAGES]
        # println("damageadd")
        # println(damageadd)

        marginal_damages = (damageadd.-damagebase) *10^(-9) * 10^12 * 12/44 # convert from trillion $/Gt C to $/ton CO2 (10^-9: Gt C -> tons C; 10^12: trillon $ -> $; 12/44: C -> CO2)
        # println("marginaldamage")
        # println(marginal_damages)

        global_marginal_damages = dropdims(sum(marginal_damages, dims = 2), dims=2)
        println("global_marginal_damages")
        println(global_marginal_damages)

        SCC_damageBurke_regions = zeros(1,1)
        SCC_damageBurke_regions = sum(df * global_marginal_damages * 10)  # currently implemented as a 10year step function; so each timestep of discounted marginal damages is multiplied by 10
        println("SCC_damageBurke_regions")
        println(SCC_damageBurke_regions)

#### SCC based on reduced region consumption

        consumptionadd = m[:neteconomy,:C]
        # println("consumptionadd")
        # println(consumptionadd)

        marginal_consumption_region = (consumptionadd.-consumptionbase) * 10^(-9) * 10^12 * 12/44 * -1 # convert from trillion $/Gt C to $/ton CO2 (10^-9: Gt C -> tons C; 10^12: trillon $ -> $; 12/44: C -> CO2); ; multiply by -1 to get positive value for damages
        println("marginal_consumption_region")
        println(marginal_consumption_region)

        # CSV.write("C:/Users/simon/Google Drive/Uni/LSE Master/02_Dissertation/10_Modelling/damage-regressions/data/mimi-rice-output/marginal.consumption.csv", marginal_consumption)

                        # regional SCC -> NOT WORKING
                        # SCC_consumption_region = zeros(1,12)
                        # SCC_consumption_region = sum(df * marginal_consumption * 10)  # currently implemented as a 10year step function; so each timestep of discounted marginal damages is multiplied by 10
                        # println("SCC_consumption_region")
                        # println(SCC_consumption_region)

        global_marginal_consumption_region = dropdims(sum(marginal_consumption_region, dims = 2), dims=2)
        println("global_marginal_consumption_region")
        println(global_marginal_consumption_region)

        SCC_consumption_region = zeros(1,1)
        SCC_consumption_region = sum(df * global_marginal_consumption_region * 10)  # currently implemented as a 10year step function; so each timestep of discounted marginal damages is multiplied by 10
        println("SCC_consumption_region")
        println(SCC_consumption_region)

        writedlm(string(dir_output, "SCC_marginal_consumption_region.csv"), marginal_consumption_region, ',')
        writedlm(string(dir_output, "SCC_global_marginal_consumption_region.csv"), global_marginal_consumption_region, ',')
        writedlm(string(dir_output, "SCC_SCC_consumption_region.csv"), SCC_consumption_region, ',')



                # SCC based on welfare is not working -> leave it

                        # welfareadd_emissions = m[:welfare,:REGUTILITYNOnegishiNOrescale]
                        # println("welfareadd_emissions")
                        # println(welfareadd_emissions)
                        #
                        # welfare_change_emissions = welfarebase.-welfareadd_emissions
                        # println("welfare_change_emissions")
                        # println(welfare_change_emissions)

                        # println("SCC with return")
                        # return scc


#### SCC based on aggregated country damages ##################################################################################################################

        damageaddctryagg = m[:damages,:DAMAGESctryagg]
        # println("damageaddctryagg")
        # println(damageaddctryagg)

        marginal_damagesctryagg = (damageaddctryagg.-damagebasectryagg) *10^(-9) * 10^12 * 12/44 # convert from trillion $/Gt C to $/ton CO2 (10^-9: Gt C -> tons C; 10^12: trillon $ -> $; 12/44: C -> CO2)
        # println("marginal_damagesctryagg")
        # println(marginal_damagesctryagg)

        global_marginal_damagesctryagg = dropdims(sum(marginal_damagesctryagg, dims = 2), dims=2)
        println("global_marginal_damagesctryagg")
        println(global_marginal_damagesctryagg)

        SCC_damageBurke_ctryagg = zeros(1,1)
        SCC_damageBurke_ctryagg = sum(df * global_marginal_damagesctryagg * 10)  # currently implemented as a 10year step function; so each timestep of discounted marginal damages is multiplied by 10
        println("SCC_damageBurke_ctryagg")
        println(SCC_damageBurke_ctryagg)


#### SCC based on reduced country consumption ##################################################################################################################

        consumptionaddctry = m[:neteconomy,:Cctry]
        # println("consumptionaddctry")
        # println(consumptionaddctry)

        marginal_consumption_ctry = (consumptionaddctry.-consumptionbasectry) *10^(-9) * 10^12 * 12/44 * -1 # convert from trillion $/Gt C to $/ton CO2 (10^-9: Gt C -> tons C; 10^12: trillon $ -> $; 12/44: C -> CO2); multiply by -1 to get positive value for damages
        # println("marginal_consumptionctry")
        # println(marginal_consumptionctry)

        global_marginal_consumption_ctry = dropdims(sum(marginal_consumption_ctry, dims = 2), dims=2)
        println("global_marginal_consumption_ctry")
        println(global_marginal_consumption_ctry)

        SCC_consumption_countries = zeros(1,1)
        SCC_consumption_countries = sum(df * global_marginal_consumption_ctry * 10)  # currently implemented as a 10year step function; so each timestep of discounted marginal consumption is multiplied by 10
        println("SCC_consumption_countries")
        println(SCC_consumption_countries)

        writedlm(string(dir_output, "SCC_marginal_consumption_ctry.csv"), marginal_consumption_ctry, ',')
        writedlm(string(dir_output, "SCC_global_marginal_consumption_ctry.csv"), global_marginal_consumption_ctry, ',')
        writedlm(string(dir_output, "SCC_SCC_consumption_countries.csv"), SCC_consumption_countries, ',')

        # println("SCCctry with return")
        # return scc


#### SCC based on OLD damage function ############################################################################################################################

        damageaddOLD = m[:damages,:DAMAGESOLD]
        # println("damageaddOLD")
        # println(damageaddOLD)

        marginal_damagesOLD = (damageaddOLD.-damagebaseOLD) *10^(-9) * 10^12 * 12/44 # convert from trillion $/Gt C to $/ton CO2 (10^-9: Gt C -> tons C; 10^12: trillon $ -> $; 12/44: C -> CO2)
        # println("marginal_damagesOLD")
        # println(marginal_damagesOLD)

        global_marginal_damagesOLD = dropdims(sum(marginal_damagesOLD, dims = 2), dims=2)
        println("global_marginal_damagesOLD")
        println(global_marginal_damagesOLD)

        SCC_damageOLD_regions = zeros(1,1)
        SCC_damageOLD_regions = sum(df * global_marginal_damagesOLD * 10)  # currently implemented as a 10year step function; so each timestep of discounted marginal damages is multiplied by 10
        println("SCC_damageOLD_regions")
        println(SCC_damageOLD_regions)

        # println("SCCOLD with return")
        # return scc


explore(m)


                        # This SCC calculation based on the consumption pulse is not giving plausible results

                        # ######################################################################################################################
                        # ####  Model with additional consumption pulse  #######################################################################
                        # ######################################################################################################################
                        #
                        #
                        # m = getrice()
                        #
                        # marginalemission = 0    # 1 = additional emission pulse; 0 otherwise
                        # set_param!(m,:emissions,:marginalemission,marginalemission)
                        #
                        # marginalconsumption = 1    # 1 = additional consumption pulse; 0 otherwise
                        # set_param!(m,:neteconomy,:marginalconsumption,marginalconsumption)
                        #
                        # run(m)
                        #
                        #
                        # #### SCC based on region welfare ##############################################################################################################################
                        #
                        #         welfareadd_consumption = m[:welfare,:REGUTILITYNOnegishiNOrescale]
                        #         println("welfareadd_consumption")
                        #         println(welfareadd_consumption)
                        #
                        #         welfare_change_consumption = welfareadd_consumption.-welfarebase
                        #         println("welfare_change_consumption")
                        #         println(welfare_change_consumption)
                        #
                        #         SCC_welfare = ((welfare_change_emissions * 10^(-9)) ./ (welfare_change_consumption * 10^(-6))) * 12/44
                        #         println("SCC_welfare")
                        #         println(SCC_welfare)
