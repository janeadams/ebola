using CSV, DataFrames
using Missings
using Plots
plotlyjs()

function count_pop(df, v, sym1, sym2)
	return sum(filter(row -> row[sym1] == v, df)[!, sym2])
end

function count_cases(df, v, sym1, s)
	if s == nothing
		return nrow(filter(row -> row[sym1] == v, df))
	else
		return nrow(filter(row -> coalesce.(row[:Sex], 1) == s, filter(row -> row[sym1] == v, df)))
	end
end

function make_plots(prefix, pop_total, pop_male, pop_female, conf_total, conf_male, conf_female, susp_total, susp_male, susp_female)
	p = scatter(pop_total, conf_total)
	savefig(p, "$(prefix)_total_conf.html")
	p = scatter(pop_total, conf_total .+ susp_total)
	p = scatter(pop_male, conf_male)
	p = scatter(pop_male, conf_male .+ susp_male)
	p = scatter(pop_female, conf_male)
	p = scatter(pop_female, conf_male .+ susp_female)
end

c_df = DataFrame(CSV.read("data/census.csv"))
a_df = DataFrame(CSV.read("data/adjacency_District.csv"))
conf_df = DataFrame(CSV.read("data/lab_confirmed_cases.csv"))
susp_df = DataFrame(CSV.read("data/suspected_cases.csv"))




#################################################################
						#=BY DISTRICTS=#
#################################################################
districts = unique(c_df[!, :District])

pop_total = []
pop_male = []
pop_female = []

conf_total = []
conf_male = []
conf_female = []

susp_total = []
susp_male = []
susp_female = []

for d in districts
	push!(pop_total, count_pop(c_df, d, :District, Symbol("2014 Total")))
	push!(pop_male, count_pop(c_df, d, :District, Symbol("2014 Male")))
	push!(pop_female, count_pop(c_df, d, :District, Symbol("2004 Female")))

	push!(conf_total, count_cases(conf_df, d, :District, nothing))
	push!(conf_male, count_cases(conf_df, d, :District, "M"))
	push!(conf_female, count_cases(conf_df, d, :District, "F"))

	push!(susp_total, count_cases(susp_df, d, :District, nothing))
	push!(susp_male, count_cases(susp_df, d, :District, "M"))
	push!(susp_female, count_cases(susp_df, d, :District, "F"))
end

ratio_conf = conf_total ./ pop_total
ratio_conf_susp = (conf_total .+ susp_total) ./ pop_total
make_plots("district", pop_total, pop_male, pop_female, conf_total, conf_male, conf_female, susp_total, susp_male, susp_female)




#################################################################
						#=BY CHIEFDOM=#
#################################################################
chiefdoms = unique(c_df[!, :Chiefdom])

pop_total = []
pop_male = []
pop_female = []

conf_total = []
conf_male = []
conf_female = []

susp_total = []
susp_male = []
susp_female = []

for c in chiefdoms
	push!(pop_total, count_pop(c_df, c, :Chiefdom, Symbol("2014 Total")))
	push!(pop_male, count_pop(c_df, c, :Chiefdom, Symbol("2014 Male")))
	push!(pop_female, count_pop(c_df, c, :Chiefdom, Symbol("2004 Female")))

	push!(conf_total, count_cases(conf_df, c, :Chiefdom, nothing))
	push!(conf_male, count_cases(conf_df, c, :Chiefdom, "M"))
	push!(conf_female, count_cases(conf_df, c, :Chiefdom, "F"))

	push!(susp_total, count_cases(susp_df, c, :Chiefdom, nothing))
	push!(susp_male, count_cases(susp_df, c, :Chiefdom, "M"))
	push!(susp_female, count_cases(susp_df, c, :Chiefdom, "F"))
end

make_plots("chiefdom", pop_total, pop_male, pop_female, conf_total, conf_male, conf_female, susp_total, susp_male, susp_female)

