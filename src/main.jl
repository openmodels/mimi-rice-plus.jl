using Mimi
using DelimitedFiles
using CSVFiles
using DataFrames
using CSV

include("rice2010.jl")
using .Rice2010

m = getrice()
run(m)

# Set the model version manually in the following components:
# 1) grosseconomy

# # SET MODEL VERSION
# global modelversion = "region"      # "region" (default), "country", "original"

# extract out the total welfare --> save it to a variable
# repreduce ln 10-11 --> BUT change initial CO2 concentartion --> then run it

explore(m)


# NEW: export model output to make graphs

# set output directory
dir_output = "C:/Users/simon/Google Drive/Uni/LSE Master/02_Dissertation/10_Modelling/damage-regressions/data/mimi-rice-output/"

# export variable values
writedlm(string(dir_output, "damfractatm.csv"), m[:damages, :DAMFRACTATM], ",") #DAMFRACTATM
