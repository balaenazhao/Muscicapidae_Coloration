#### download data from GBIF, human observations
#### download data for Muscicapidae

#### select only the species, coordinates, date, month, and year
cat GBIF_20240307.csv | awk -v FS='\t' -v OFS='\t' '{print $10,$22,$23,$31,$32,$33}' > All_GBIF.csv
cat GBIF_additional.txt | awk -v FS='\t' -v OFS='\t' '{print $202,$98,$99,$69,$68,$67}' > additional.csv

#### remove occurrences that have empty entries
sed -i '' "/\t\t/d" All_GBIF.csv
sed -i '' "/\t\t/d" additional.csv

#### remove duplicates
awk '!seen[$0]++' All_GBIF.csv > All_GBIF_uniq.csv
awk '!seen[$0]++' additional.csv > additional_uniq.csv

#### get taxon info and mark unwanted species
cat All_GBIF.csv | awk -v FS='\t' -v OFS='\t' '{print $1}' | awk '!seen[$0]++' > taxa.csv
cat additional_uniq.csv | awk -v FS='\t' -v OFS='\t' '{print $1}' | awk '!seen[$0]++' > add_taxa.csv

#### reconcile taxon names, and find those missing data
#### download additional data for Cercotrichas, Chamaetylas_fuelleborni, Alethe, etc.
#### repeat from above until all sampled taxa have associated occurrence data
#### download data from eBird for those that keep missing from GBIF
cat All_GBIF_uniq.csv additional_uniq.csv Oenanthe_melanoleuca.csv > GBIF_data.csv
awk '!seen[$0]++' GBIF_data.csv > GBIF_uniq.csv
#### reconcile GBIF names to match eBird 2023
./remove_unsampled.sh
./reconcile_gbif.sh
awk '!seen[$0]++' GBIF_uniq.csv > GBIF_uniq2.csv
### remove lines that had no taxon name in BBEDIT


#### process eBird data
cat eBird.add.txt | awk -v FS='\t' -v OFS='\t' '{print $7,$29,$30,$31}' > eBird.csv
awk '!seen[$0]++' eBird.csv > eBird_uniq.csv
sed -i '' "/\t\t/d" eBird_uniq.csv
### change year-month-date to date \t month \t year in BBEDIT


#### combine everything together
cat GBIF_processed/GBIF_uniq.csv eBird/eBird_uniq.csv > occurrences_data.csv
cat occurrences_data.csv | awk -v FS='\t' -v OFS='\t' '{print $1}' | awk '!seen[$0]++' > taxa.txt
awk '!seen[$0]++' occurrences_data.csv > Muscicapidae_occurrences_data.csv

