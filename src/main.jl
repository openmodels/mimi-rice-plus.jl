using Mimi
using DelimitedFiles
using CSVFiles
using DataFrames
using CSV

include("rice2010.jl")
using .Rice2010

m = getrice()
run(m)

explore(m)


# NEW: export model output

# set output directory
dir_output = "C:/Users/simon/Google Drive/Uni/LSE Master/02_Dissertation/10_Modelling/damage-regressions/data/mimi-rice-output/"

# export variable values
writedlm(string(dir_output, "damfractatm.csv"), m[:damages, :DAMFRACTATM], ",") #DAMFRACTATM
