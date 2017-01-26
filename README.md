# KafeenDiffStatistics
Generate data summary reports for and between Kafeen vcf output files

# To use this program:
  1. You will need to have SQLite3 installed.
  2. Download KafeenDiffStatistics to your local machine.
  3. There are two run options:
      1. Gather statistics on one file
        bash vcfComp.sh /path/to/yourfilename.vcf
      2. Gather statistics between two files
        bash vcfComp.sh /path/to/yourOldData.vcf path/to/yourNewData.vcf

# Output
There will be several csv output files with the collected data that can be reviewed in excel.


