using DataFrames, XLSX

Trigger_NA = DataFrame(XLSX.readtable("data/all_paper_data.xlsx", "Trigger_NA")...)
Trigger_Ave = DataFrame(XLSX.readtable("data/all_paper_data.xlsx", "Trigger_Ave")...)
Trigger_Other = DataFrame(XLSX.readtable("data/all_paper_data.xlsx", "Trigger Other")...)
Follow_Up = DataFrame(XLSX.readtable("data/all_paper_data.xlsx", "Follow Up")...)
Follow_Up_Other = DataFrame(XLSX.readtable("data/all_paper_data.xlsx", "Follow_Up_Other")...)
Codebook = DataFrame(XLSX.readtable("data/all_paper_data.xlsx", "Codebook")...)