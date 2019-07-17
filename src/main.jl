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


######################################################################################################################
####  Orginal Model  #################################################################################################
######################################################################################################################

m = getrice()

marginalemission = 0    # 1 = additional emission pulse; 0 otherwise
set_param!(m,:emissions,:marginalemission,marginalemission)

marginalconsumption = 0    # 1 = additional consumption pulse; 0 otherwise
set_param!(m,:neteconomy,:marginalconsumption,marginalconsumption)

run(m)

# extract out the total welfare --> save it to a variable

        damagebase = m[:damages,:DAMAGES]
        println("damagebase")
        println(damagebase)

        damagebasectryagg = m[:damages,:DAMAGESctryagg]
        println("damagebasectryagg")
        println(damagebasectryagg)

        damagebaseOLD = m[:damages,:DAMAGESOLD]
        println("damagebaseOLD")
        println(damagebaseOLD)


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

                discountingbegin2005 = 2015
                dr = 0.03      # manually set the discount rate here
                df = zeros(1, 60)

                if discountingbegin2005 == 2005
                        for t in 1:1:60
                                df[t] = 1/(1+dr)^(10(t-1))
                        end
                elseif discountingbegin2005 == 2015
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
        println("damageadd")
        println(damageadd)

        marginal_damages = (damageadd.-damagebase) *10^(-9) * 10^12 * 12/44 # convert from trillion $/Gt C to $/ton CO2 (10^-9: Gt C -> tons C; 10^12: trillon $ -> $; 12/44: C -> CO2)
        println("marginaldamage")
        println(marginal_damages)

        global_marginal_damages = dropdims(sum(marginal_damages, dims = 2), dims=2)
        println("global_marginal_damages")
        println(global_marginal_damages)

        SCC = zeros(1,1)
        SCC = sum(df * global_marginal_damages * 10)  # currently implemented as a 10year step function; so each timestep of discounted marginal damages is multiplied by 10
        println("SCC Burke regions")
        println(SCC)


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
        println("damageaddctryagg")
        println(damageaddctryagg)

        marginal_damagesctryagg = (damageaddctryagg.-damagebasectryagg) *10^(-9) * 10^12 * 12/44 # convert from trillion $/Gt C to $/ton CO2 (10^-9: Gt C -> tons C; 10^12: trillon $ -> $; 12/44: C -> CO2)
        println("marginaldamage")
        println(marginal_damagesctryagg)

        global_marginal_damagesctryagg = dropdims(sum(marginal_damagesctryagg, dims = 2), dims=2)
        println("global_marginal_damagesctryagg")
        println(global_marginal_damagesctryagg)

        SCCctryagg = zeros(1,1)
        SCCctryagg = sum(df * global_marginal_damagesctryagg * 10)  # currently implemented as a 10year step function; so each timestep of discounted marginal damages is multiplied by 10
        println("SCCctryagg Burke countries")
        println(SCCctryagg)

        # println("SCCctryagg with return")
        # return scc


#### SCC based on OLD damage function ############################################################################################################################

        damageaddOLD = m[:damages,:DAMAGESOLD]
        println("damageaddOLD")
        println(damageaddOLD)

        marginal_damagesOLD = (damageaddOLD.-damagebaseOLD) *10^(-9) * 10^12 * 12/44 # convert from trillion $/Gt C to $/ton CO2 (10^-9: Gt C -> tons C; 10^12: trillon $ -> $; 12/44: C -> CO2)
        println("marginaldamage")
        println(marginal_damagesOLD)

        global_marginal_damagesOLD = dropdims(sum(marginal_damagesOLD, dims = 2), dims=2)
        println("global_marginal_damagesOLD")
        println(global_marginal_damagesOLD)

        SCCOLD = zeros(1,1)
        SCCOLD = sum(df * global_marginal_damagesOLD * 10)  # currently implemented as a 10year step function; so each timestep of discounted marginal damages is multiplied by 10
        println("SCCOLD Burke regions")
        println(SCCOLD)

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



# NEW: export model output to make graphs

# set output directory
dir_output = "C:/Users/simon/Google Drive/Uni/LSE Master/02_Dissertation/10_Modelling/damage-regressions/data/mimi-rice-output/"

# export variable values
writedlm(string(dir_output, "damfractatm.csv"), m[:damages, :DAMFRACTATM], ",") #DAMFRACTATM
