create table oldTmp(variation, gene, pathogenicity, disease, comments, reason, pmid, sift, hdiv, lrt, mut, gerp, phylop2);
create table oldTable(variation varchar(20), gene varchar(20), pathogenicity varchar(20), disease, comments, reason, pmid, sift, hdiv, lrt, mut, gerp, phylop2);

.mode tabs
.import oldFile.tsv oldTmp

INSERT INTO oldTable (variation, gene, pathogenicity, disease, comments, reason, pmid, sift, hdiv, lrt, mut, gerp, phylop2) SELECT * FROM oldTmp;

drop table oldTmp;


.mode csv
.output pathogenicityChangesSummary.csv
.headers on

select g.gene as gene,IFNULL(num_old_var,0) AS num_old_var, IFNULL(old_num_path, 0) AS num_path, IFNULL(old_num_lp, 0) AS num_lp, IFNULL(old_num_us, 0) AS num_us, IFNULL(old_num_lb, 0) AS num_lb, IFNULL(old_num_b, 0) AS num_b, IFNULL(old_num_bs, 0) AS num_bs   
from 
(select distinct gene from (select distinct gene from oldTable)) g
left join
(select gene, count(*) as num_old_var from oldTable group by gene) ot
on g.gene=ot.gene
left join
(select gene, count(*) as old_num_path from oldTable where pathogenicity="Pathogenic" group by gene) pno
on g.gene=pno.gene
left join
(select gene, count(*) as old_num_lp from oldTable where pathogenicity="Likely pathogenic" group by gene) lpno
on g.gene=lpno.gene
left join
(select gene, count(*) as old_num_us from oldTable where pathogenicity="Unknown significance" group by gene) usno
on g.gene=usno.gene
left join
(select gene, count(*) as old_num_lb from oldTable where pathogenicity="Likely benign" group by gene) lbno
on g.gene=lbno.gene
left join
(select gene, count(*) as old_num_b from oldTable where pathogenicity="Benign" group by gene) bno
on g.gene=bno.gene
left join
(select gene, count(*) as old_num_bs from oldTable where pathogenicity="Benign*" group by gene) bsno
on g.gene=bsno.gene;





select "Total",IFNULL(num_old_var,0) AS num_old_var, IFNULL(old_num_path, 0) AS num_path, IFNULL(old_num_lp, 0) AS num_lp, IFNULL(old_num_us, 0) AS num_us, IFNULL(old_num_lb, 0) AS num_lb, IFNULL(old_num_b, 0) AS num_b, IFNULL(old_num_bs, 0) AS num_bs 
from 
(select count(*) as num_old_var from oldTable) ot
left join
(select count(*) as old_num_path from oldTable where pathogenicity="Pathogenic") pno
left join
(select count(*) as old_num_lp from oldTable where pathogenicity="Likely pathogenic") lpno
left join
(select count(*) as old_num_us from oldTable where pathogenicity="Unknown significance") usno
left join
(select count(*) as old_num_lb from oldTable where pathogenicity="Likely benign") lbno
left join
(select count(*) as old_num_b from oldTable where pathogenicity="Benign") bno
left join
(select count(*) as old_num_bs from oldTable where pathogenicity="Benign*") bsno
;


