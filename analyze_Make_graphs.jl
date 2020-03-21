using CSV, DataFrames, Missings
using Statistics, StatsBase, CurveFit
using Plots, StatsPlots, Interact
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

function line_of_best_fit(x, y)
	x = Float64.(x)
	y = Float64.(y)
	r = cor(x, y)
	fit = curve_fit(LinearFit, x, y)
	return (x -> fit(x), r)
end

function make_plots(title, hover, pop_total, pop_male, pop_female, conf_total, conf_male, conf_female, susp_total, susp_male, susp_female)
	p1 = plot(pop_total, conf_total, hover=hover, title="Total",
		label=nothing, xlabel="Population", ylabel="# Cases",
		markersize=4, seriestype=:scatter)
	f, r = line_of_best_fit(pop_total, conf_total)
	plot!(p1, f, label="r=$(r)")
	savefig(p1, "htmlGraphs/$(title)_total_conf.html")
	
	p2 = plot(pop_total, conf_total .+ susp_total, hover=hover, title="Total+",
		label=nothing, xlabel="Population", ylabel="# Cases",
		markersize=4, seriestype=:scatter)
	f, r = line_of_best_fit(pop_total, conf_total .+ susp_total)
	plot!(p2, f, label="r=$(r)")
	savefig(p2, "htmlGraphs/$(title)_total_conf+.html")
	


	p3 = plot(pop_male, conf_male, hover=hover, title="Male",
		label=nothing, xlabel="Population", ylabel="# Cases",
		markersize=4, seriestype=:scatter)
	f, r = line_of_best_fit(pop_male, conf_male)
	plot!(p3, f, label="r=$(r)")
	savefig(p3, "htmlGraphs/$(title)_male_conf.html")
	
	p4 = plot(pop_male, conf_male .+ susp_male, hover=hover, title="Male+",
		label=nothing, xlabel="Population", ylabel="# Cases",
		markersize=4, seriestype=:scatter)
	f, r = line_of_best_fit(pop_male, conf_male .+ susp_male)
	plot!(p4, f, label="r=$(r)")
	savefig(p4, "htmlGraphs/$(title)_male_conf+.html")
	


	p5 = plot(pop_female, conf_female, hover=hover, title="Female",
		label=nothing, xlabel="Population", ylabel="# Cases",
		markersize=4, seriestype=:scatter)
	f, r = line_of_best_fit(pop_female, conf_female)
	plot!(p5, f, label="r=$(r)")
	savefig(p5, "htmlGraphs/$(title)_female_conf.html")
	
	p6 = plot(pop_female, conf_female .+ susp_female, hover=hover, title="Female+",
		label=nothing, xlabel="Population", ylabel="# Cases",
		markersize=4, seriestype=:scatter)
	f, r = line_of_best_fit(pop_female, conf_female .+ susp_female)
	plot!(p6, f, label="r=$(r)")
	savefig(p6, "htmlGraphs/$(title)_female_conf+.html")

	plot(p1, p2, p3, p4, p5, p6, titleloc = :left, titlefont = font(10), legend=true, layout=(3,2), size=(1200, 900))
	savefig("htmlGraphs/$(title)_all.html")
end

#=function plot_rank(prefix, title, districts, ratio, df)
	ranks = Dict(); for i in 1:length(districts) ranks[ratio[i]] = [] end
	idx = sortperm(ratio)
	@show districts
	@show ranks

	for i in 1:length(districts)
		for j in 1:length(districts)
			if i != j && df[i, j] == 1
				push!(ranks[ratio[i]], ratio[j])
			end
		end
	end

	hover = districts[idx]
	x = ratio[idx]
	y = []
	for k in sort(collect(keys(ranks)))
		push!(y, mean(ranks[k]))
	end

	p = plot(x, y, hover=hover, title="$(title)",
		label=nothing, xlabel="# Cases", ylabel="Mean cases of neighbors",
		markersize=4, seriestype=:scatter)
	f, r = line_of_best_fit(x, y)
	plot!(p, f, label="r=$(r)")
	savefig(p, "htmlGraphs/$(prefix)_spatial_$(title).html")
	return p
end=#

function plot_rank(prefix, title, data, ratio, df)
	ranks = Dict(); for i in 1:length(data) ranks[data[i]] = Vector{Float64}() end

	for i in 1:length(data)
		for j in 1:length(data)
			if i != j && df[i, j] == 1
				push!(ranks[data[i]], ratio[j])
			end
		end
	end

	hover = data
	x = ratio
	y = []
	keep_idx = []
	for i in 1:length(data)
		if ranks[data[i]] == Vector{Float64}()
			nothing
		else
			push!(keep_idx, i)
			push!(y, mean(ranks[data[i]]))
		end
	end
	hover = hover[keep_idx]
	x = ratio[keep_idx]

	p = plot(x, y, hover=hover, title="$(title)",
		label=nothing, xlabel="# Cases", ylabel="Mean cases of neighbors",
		markersize=4, seriestype=:scatter)
	f, r = line_of_best_fit(x, y)
	plot!(p, f, label="r=$(r)")
	savefig(p, "htmlGraphs/$(prefix)_spatial_$(title).html")
	return p
end

c_df = DataFrame(CSV.read("data/census.csv"))
ad_df = DataFrame(CSV.read("data/adjacency_District.csv"))
ac_df = DataFrame(CSV.read("data/adjacency_Chiefdom.csv"))
conf_df = DataFrame(CSV.read("data/lab_confirmed_cases.csv"))
susp_df = DataFrame(CSV.read("data/suspected_cases.csv"))




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
make_plots("Chiefdom", chiefdoms, pop_total, pop_male, pop_female, conf_total, conf_male, conf_female, susp_total, susp_male, susp_female)

ratio_conf = conf_total ./ pop_total
p1 = plot_rank("Chiefdom", "Total", chiefdoms, ratio_conf, ac_df);

ratio_conf_susp = (conf_total .+ susp_total) ./ pop_total
p2 = plot_rank("Chiefdom", "Total+", chiefdoms, ratio_conf_susp, ac_df);

ratio_male_conf = conf_male ./ pop_male
p3 = plot_rank("Chiefdom", "Male", chiefdoms, ratio_male_conf, ac_df);

ratio_male_conf_susp = (conf_male .+ susp_male) ./ pop_male
p4 = plot_rank("Chiefdom", "Male+", chiefdoms, ratio_male_conf_susp, ac_df);

ratio_female_conf = conf_female ./ pop_female
p5 = plot_rank("Chiefdom", "Female", chiefdoms, ratio_female_conf, ac_df);

ratio_female_conf_susp = (conf_female .+ susp_female) ./ pop_female
p6 = plot_rank("Chiefdom", "Female+", chiefdoms, ratio_female_conf_susp, ac_df);

plot(p1, p2, p3, p4, p5, p6, titleloc = :left, titlefont = font(10), legend=true, layout=(3,2), size=(1200, 900));
savefig("htmlGraphs/Chiefdom_Spatial_all.html");




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
make_plots("District", districts, pop_total, pop_male, pop_female, conf_total, conf_male, conf_female, susp_total, susp_male, susp_female)


ratio_conf = conf_total ./ pop_total
p1 = plot_rank("District", "Total", districts, ratio_conf, ad_df);

ratio_conf_susp = (conf_total .+ susp_total) ./ pop_total
p2 = plot_rank("District", "Total+", districts, ratio_conf_susp, ad_df);

ratio_male_conf = conf_male ./ pop_male
p3 = plot_rank("District", "Male", districts, ratio_male_conf, ad_df);

ratio_male_conf_susp = (conf_male .+ susp_male) ./ pop_male
p4 = plot_rank("District", "Male+", districts, ratio_male_conf_susp, ad_df);

ratio_female_conf = conf_female ./ pop_female
p5 = plot_rank("District", "Female", districts, ratio_female_conf, ad_df);

ratio_female_conf_susp = (conf_female .+ susp_female) ./ pop_female
p6 = plot_rank("District", "Female+", districts, ratio_female_conf_susp, ad_df);

plot(p1, p2, p3, p4, p5, p6, titleloc = :left, titlefont = font(10), legend=true, layout=(3,2), size=(1200, 900));
savefig("htmlGraphs/District_Spatial_all.html");










