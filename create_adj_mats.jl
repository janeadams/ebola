using DataFrames, CSV

c = DataFrame(CSV.read("data/census.csv"))
for col in [2, 3, 4]
	name = names(c)[col]
	labels = unique(c, col)[col]
	dims = length(labels)
	adjMat = one(zeros(Int64, dims, dims))
	for i in 1:dims
		println("\n\n$(labels[i]) is connected to...")
		println("=======================================")
		for j in i:dims
			i == j && continue
			println("$(labels[j])?")
			input = parse(Int, chomp(readline()))
			if  input == 1
				adjMat[i, j] = 1
				adjMat[j, i] = 1
			elseif input == -1
				break
			end
		end
	end
	CSV.write("data/adjacency_$(name).csv", DataFrame(adjMat))
end