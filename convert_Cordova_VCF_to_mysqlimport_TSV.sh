##
# Convert DVD VCF to mysqlimport TSV
#
# NOTE: In the map file, any lines beginning with a # will be ignored.
#
# Example usage:
#   ./convert_DVD_VCF_to_mysqlimport_TSV.sh DVD.vcf > DVD.tsv
##
infile=$1
vcf2dvd_map='VCF2DVD_cadiVersion.map.txt'

# Import VCF -> TSV map
# - Column 1: VCF info tags to query
# - Column 2: TSV column names (which will be used as MySQL column names)
vcf_info_fields=$(awk -F'\t' '($0 ~ /^[^#]/){printf "%s%%%s",sep,$1; sep="\t"}' $vcf2dvd_map) #=> %FIELD1   %FIELD2   %FIELD3   ...
output_header=$(awk -F'\t' '($0 ~ /^[^#]/){printf "%s%s",sep,$2; sep="\t"}' $vcf2dvd_map)     #=> db_column1   db_column2   db_column3   ...

# Print header
echo $output_header

# Print data
#bcftools query -r 13:20761603-20767114 -f "$vcf_info_fields\n" $infile \
/Your/Path/To/bcftools query -f "$vcf_info_fields\n" $infile \
  | awk '
        BEGIN{
          FS="\t"
          OFS="\t"
        }
        {
          # Unencode URI strings
          gsub("%20", " ")
          gsub("%3B", ";")
          gsub("%3D", "=")
          gsub("%2C", ",")
                                                                                
          for (i = 1; i <= NF; i++) {
            # Replace "." with "\N"
            if ($i == ".") {
              $i = " "
            }
          }
              
          # Print final record
          print
        }
        '
