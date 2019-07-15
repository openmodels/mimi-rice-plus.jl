using Mimi
using DelimitedFiles
using CSVFiles
using DataFrames
using CSV

include("rice2010.jl")
using .Rice2010


# Set the model version manually in the following components:
# 1) grosseconomy

        # OLD: # SET MODEL VERSION
        # global modelversion = "region"      # "region" (default), "country", "original"


######################################################################################################################
####  Orginal Model  #################################################################################################
######################################################################################################################

m = getrice()

marginalemission = 0    # 1 = additional emission pulse; 0 otherwise
set_param!(m,:emissions,:marginalemission,marginalemission)

run(m)

# extract out the total welfare --> save it to a variable
# reproduce ln 10-11 --> BUT change initial CO2 concentration --> then run it


        damagebase = m[:damages,:DAMAGES]
        println("damagebase")
        println(damagebase)

        damagebasectryagg = m[:damages,:DAMAGESctryagg]
        println("damagebasectryagg")
        println(damagebasectryagg)

        damagebaseOLD = m[:damages,:DAMAGESOLD]
        println("damagebaseOLD")
        println(damagebaseOLD)

explore(m)


######################################################################################################################
####  Model with additional emission pulse  ##########################################################################
######################################################################################################################

m = getrice()

marginalemission = 1    # 1 = additional emission pulse; 0 otherwise
set_param!(m,:emissions,:marginalemission,marginalemission)

run(m)


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

        for t in 1:1:60
            df[t] = 1/(1+0.03)^10t
        end
        println("df")
        println(df)

        SCC = sum(df .* global_marginal_damages * 10)  # currently implemented as a 10year step function; so each timestep of discounted marginal damages is multiplied by 10
        println("SCC Burke regions")
        println(SCC)

        println("SCC with return")
        return scc


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

        SCCctryagg = sum(df .* global_marginal_damagesctryagg * 10)  # currently implemented as a 10year step function; so each timestep of discounted marginal damages is multiplied by 10
        println("SCCctryagg Burke regions")
        println(SCCctryagg)

        println("SCCctryagg with return")
        return scc


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

        SCCOLD = sum(df .* global_marginal_damagesOLD * 10)  # currently implemented as a 10year step function; so each timestep of discounted marginal damages is multiplied by 10
        println("SCCOLD Burke regions")
        println(SCCOLD)

        println("SCCOLD with return")
        return scc


explore(m)



        # Tried to implement it like Anthoff but didn't work
            # function getmarginal_rice_models(;emissionyear=2015,datafile=joinpath(@__DIR__, "..", "data", "RICE_2010_base_000_v1.1s.xlsm"))



                # m = getrice()
                #
                #                     # p[:marginalemission] = 1
                #                     # set_param!(m, :emissions, :marginalemission, p[:marginalemission])
                #                     #
                #                     # function getrice2010parameters(filename)
                #                     #     p = Dict{Symbol,Any}()
                #                     #
                #                     #     p[:marginalemission] = 1
                #                     #     set_param!(m, :emissions, :marginalemission, p[:marginalemission])                                #
                #                     #     return p
                #                     # end
                #
                #
                #
                #                     # add_comp!(m, Mimi.adder, :marginalemission, before=:co2cycle)
                #                     #
                #                     # time = Mimi.dimension(m, :time)
                #                     # addem = zeros(length(60))
                #                     # addem[time[2015]] = 1000000000000000000.0
                #                     #
                #                     # set_param!(m,:marginalemission,:add,addem)
                #                     # connect_param!(m,:marginalemission,:input,:emissions,:E)
                #                     # connect_param!(m, :co2cycle,:E,:marginalemission,:output)
                #
                # run(m)
                #
                # explore(m)

            # end


# NEW: export model output to make graphs

# set output directory
dir_output = "C:/Users/simon/Google Drive/Uni/LSE Master/02_Dissertation/10_Modelling/damage-regressions/data/mimi-rice-output/"

# export variable values
writedlm(string(dir_output, "damfractatm.csv"), m[:damages, :DAMFRACTATM], ",") #DAMFRACTATM
