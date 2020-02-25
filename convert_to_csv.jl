using DataFrames, XLSX, CSV

Trigger_NA = DataFrame(XLSX.readtable("data/all_paper_data.xlsx", "Trigger_NA")...)
Trigger_Ave = DataFrame(XLSX.readtable("data/all_paper_data.xlsx", "Trigger_Ave")...)
Trigger_Other = DataFrame(XLSX.readtable("data/all_paper_data.xlsx", "Trigger Other")...)
Follow_Up = DataFrame(XLSX.readtable("data/all_paper_data.xlsx", "Follow Up")...)
Follow_Up_Other = DataFrame(XLSX.readtable("data/all_paper_data.xlsx", "Follow Up Other")...)
Codebook = DataFrame(XLSX.readtable("data/all_paper_data.xlsx", "Codebook")...)

CSV.write("data/Trigger_NA.csv", Trigger_NA)
CSV.write("data/Trigger_Ave.csv", Trigger_Ave)
CSV.write("data/Trigger_Other.csv", Trigger_Other)
CSV.write("data/Follow_Up.csv", Follow_Up)
CSV.write("data/Follow_Up_Other.csv", Follow_Up_Other)
CSV.write("data/Codebook.csv", Codebook)
