create table oldTmp(variation, gene, pathogenicity, disease, comments, reason, pmid, sift, hdiv, lrt, mut, gerp, phylop2);
create table newTmp(variation, gene, pathogenicity, disease, comments, reason, pmid, sift, hdiv, lrt, mu
t, gerp, phylop2);
create table oldTable(variation varchar(20), gene varchar(20), pathogenicity varchar(20), disease, comments, reason, pmid, sift, hdiv, lrt, mut, gerp, phylop2);
create table newTable(variation varchar(20), gene varchar(20), pathogenicity varchar(20), disease, comments, reason, pmid, sift, hdiv, lrt, mut, gerp, phylop2);

.mode tabs
.import oldFile.tsv oldTmp
.import newFile.tsv newTmp

INSERT INTO oldTable (variation, gene, pathogenicity, disease, comments, reason, pmid, sift, hdiv, lrt, mut, gerp, phylop2) SELECT * FROM oldTmp;
insert into newTable (variation, gene, pathogenicity, disease, comments, reason, pmid, sift, hdiv, lrt, mut, gerp, phylop2) select * from newTmp;

drop table oldTmp;
drop table newTmp;

create view commonVariants AS select ot.variation, ot.gene, ot.pathogenicity as old_path, nt.pathogenicity as new_path, ot.disease, nt.disease, ot.comments, nt.comments, ot.reason, nt.reason, ot.pmid, nt.pmid, ot.sift, nt.sift, ot.hdiv, nt.hdiv, ot.lrt, nt.lrt, ot.mut, nt.mut, ot.gerp, nt.gerp, ot.phylop2, nt.phylop2 from oldTable ot join newTable nt where ot.variation=nt.variation;

.mode csv
.output pathogenicityChangesSummary.csv
.headers on

select g.gene as gene,IFNULL(num_old_var,0) AS num_old_var, IFNULL(num_new_var,0) AS num_new_var, IFNULL(added,0) AS added, IFNULL(dropped,0) AS dropped, IFNULL(num_path, 0) AS num_path, IFNULL(num_lp, 0) AS num_lp, IFNULL(num_us, 0) AS num_us, IFNULL(num_lb, 0) AS num_lb, IFNULL(num_b, 0) AS num_b, IFNULL(num_bs, 0) AS num_bs, IFNULL(old_num_path, 0) AS old_num_path, IFNULL(old_num_lp, 0) AS old_num_lp, IFNULL(old_num_us, 0) AS old_num_us, IFNULL(old_num_lb, 0) AS old_num_lb, IFNULL(old_num_b, 0) AS old_num_b, IFNULL(old_num_bs, 0) AS old_num_bs, IFNULL(changed,0) AS changed, IFNULL(unchanged,0) AS unchanged, IFNULL(num_p_to_lp,0) AS num_p_to_lp, IFNULL(num_p_to_us,0) AS num_p_to_us, IFNULL(num_p_to_lb,0) AS num_p_to_lb, IFNULL(num_p_to_b,0) AS num_p_to_b, IFNULL(num_p_to_bs,0) AS num_p_to_bs, IFNULL(num_lp_to_p,0) AS num_lp_to_p, IFNULL(num_lp_to_us,0) AS num_lp_to_us, IFNULL(num_lp_to_lb,0) AS num_lp_to_lb, IFNULL(num_lp_to_b,0) AS num_lp_to_b, IFNULL(num_lp_to_bs,0) AS num_lp_to_bs, IFNULL(num_us_to_p,0) AS num_us_to_p, IFNULL(num_us_to_lp,0) AS num_us_to_lp, IFNULL(num_us_to_lb,0) AS num_us_to_lb, IFNULL(num_us_to_b,0) AS num_us_to_b, IFNULL(num_us_to_bs,0) AS num_us_to_bs, IFNULL(num_lb_to_p,0) AS num_lb_to_p, IFNULL(num_lb_to_lp,0) AS num_lb_to_lp, IFNULL(num_lb_to_us,0) AS num_lb_to_us, IFNULL(num_lb_to_b,0) AS num_lb_to_b, IFNULL(num_lb_to_bs,0) AS num_lb_to_bs, IFNULL(num_b_to_p,0) AS num_b_to_p, IFNULL(num_b_to_lp,0) AS num_b_to_lp, IFNULL(num_b_to_us,0) AS num_b_to_us, IFNULL(num_b_to_lb,0) AS num_b_to_lb, IFNULL(num_b_to_bs,0) AS num_b_to_bs, IFNULL(num_bs_to_p,0) AS num_bs_to_p, IFNULL(num_bs_to_lp,0) AS num_bs_to_lp, IFNULL(num_bs_to_us,0) AS num_bs_to_us, IFNULL(num_bs_to_lb,0) AS num_bs_to_lb, IFNULL(num_bs_to_b,0) AS num_bs_to_b 
from 
(select distinct gene from (select distinct gene from oldTable union select distinct gene from newTable)) g
left join
(select gene, count(*) as num_old_var from oldTable group by gene) ot
on g.gene=ot.gene
left join
(select gene, count(*) as num_new_var from newTable group by gene) nt
on g.gene=nt.gene
left join
(select gene, count(*) as added from newTable where variation not in (select variation from commonVariants) group by gene) a
on g.gene=a.gene
left join
(select gene, count(*) as dropped from oldTable where variation not in (select variation from commonVariants) group by gene) d
on g.gene=d.gene
left join
(select gene, count(*) as num_path from newTable where pathogenicity="Pathogenic" group by gene) pn
on g.gene=pn.gene
left join
(select gene, count(*) as num_lp from newTable where pathogenicity="Likely pathogenic" group by gene) lpn
on g.gene=lpn.gene
left join
(select gene, count(*) as num_us from newTable where pathogenicity="Unknown significance" group by gene) usn
on g.gene=usn.gene
left join
(select gene, count(*) as num_lb from newTable where pathogenicity="Likely benign" group by gene) lbn
on g.gene=lbn.gene
left join
(select gene, count(*) as num_b from newTable where pathogenicity="Benign" group by gene) bn
on g.gene=bn.gene
left join
(select gene, count(*) as num_bs from newTable where pathogenicity="Benign*" group by gene) bsn
on g.gene=bsn.gene
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
on g.gene=bsno.gene
left join
(select gene, count(*) as changed from commonVariants where old_path != new_path group by gene) c
on g.gene=c.gene
left join
(select gene, count(*) as unchanged from commonVariants where old_path = new_path group by gene) u
on g.gene=u.gene
left join
(select gene, count(*) as num_p_to_lp from commonVariants where old_path="Pathogenic" and new_path="Likely pathogenic" group by gene) t1
on g.gene=t1.gene
left join
(select gene, count(*) as num_p_to_us from commonVariants where old_path="Pathogenic" and new_path="Unknown significance" group by gene) t2
on g.gene = t2.gene
left join
(select gene, count(*) as num_p_to_lb from commonVariants where old_path="Pathogenic" and new_path="Likely benign" group by gene) t3
on g.gene = t3.gene
left join
(select gene, count(*) as num_p_to_b from commonVariants where old_path="Pathogenic" and new_path="Benign" group by gene) t4
on g.gene = t4.gene
left join
(select gene, count(*) as num_p_to_bs from commonVariants where old_path="Pathogenic" and new_path="Benign*" group by gene) t5
on g.gene = t5.gene
left join
(select gene, count(*) as num_lp_to_p from commonVariants where old_path="Likely pathogenic" and new_path="Pathogenic" group by gene) t6
on g.gene = t6.gene
left join
(select gene, count(*) as num_lp_to_us from commonVariants where old_path="Likely pathogenic" and new_path="Unknown significance" group by gene) t7
on g.gene = t7.gene
left join
(select gene, count(*) as num_lp_to_lb from commonVariants where old_path="Likely pathogenic" and new_path="Likely benign" group by gene) t8
on g.gene = t8.gene
left join
(select gene, count(*) as num_lp_to_b from commonVariants where old_path="Likely pathogenic" and new_path="Benign" group by gene) t9
on g.gene = t9.gene
left join
(select gene, count(*) as num_lp_to_bs from commonVariants where old_path="Likely pathogenic" and new_path="Benign*" group by gene) t10
on g.gene = t10.gene
left join
(select gene, count(*) as num_us_to_p from commonVariants where old_path="Unknown significance" and new_path="Pathogenic" group by gene) t11
on g.gene = t11.gene
left join
(select gene, count(*) as num_us_to_lp from commonVariants where old_path="Unknown significance" and new_path="Likely pathogenic" group by gene) t12
on g.gene = t12.gene
left join
(select gene, count(*) as num_us_to_lb from commonVariants where old_path="Unknown significance" and new_path="Likely benign" group by gene) t13
on g.gene = t13.gene
left join
(select gene, count(*) as num_us_to_b from commonVariants where old_path="Unknown significance" and new_path="Benign" group by gene) t14
on g.gene = t14.gene
left join
(select gene, count(*) as num_us_to_bs from commonVariants where old_path="Unknown significance" and new_path="Benign*" group by gene) t15
on g.gene = t15.gene
left join
(select gene, count(*) as num_lb_to_p from commonVariants where old_path="Likely benign" and new_path="Pathogenic" group by gene) t16
on g.gene = t16.gene
left join
(select gene, count(*) as num_lb_to_lp from commonVariants where old_path="Likely benign" and new_path="Likely pathogenic" group by gene) t17
on g.gene = t17.gene
left join
(select gene, count(*) as num_lb_to_us from commonVariants where old_path="Likely benign" and new_path="Unknown significance" group by gene) t18
on g.gene = t18.gene
left join
(select gene, count(*) as num_lb_to_b from commonVariants where old_path="Likely benign" and new_path="Benign" group by gene) t19
on g.gene = t19.gene
left join
(select gene, count(*) as num_lb_to_bs from commonVariants where old_path="Likely benign" and new_path="Benign*" group by gene) t20
on g.gene = t20.gene
left join
(select gene, count(*) as num_b_to_p from commonVariants where old_path="Benign" and new_path="Pathogenic" group by gene) t21
on g.gene = t21.gene
left join
(select gene, count(*) as num_b_to_lp from commonVariants where old_path="Benign" and new_path="Likely pathogenic" group by gene) t22
on g.gene = t22.gene
left join
(select gene, count(*) as num_b_to_us from commonVariants where old_path="Benign" and new_path="Unknown significance" group by gene) t23
on g.gene = t23.gene
left join
(select gene, count(*) as num_b_to_lb from commonVariants where old_path="Benign" and new_path="Likely benign" group by gene) t24
on g.gene = t24.gene
left join
(select gene, count(*) as num_b_to_bs from commonVariants where old_path="Benign" and new_path="Benign*" group by gene) t25
on g.gene = t25.gene
left join
(select gene, count(*) as num_bs_to_p from commonVariants where old_path="Benign*" and new_path="Pathogenic" group by gene) t26
on g.gene = t26.gene
left join
(select gene, count(*) as num_bs_to_lp from commonVariants where old_path="Benign*" and new_path="Likely pathogenic" group by gene) t27
on g.gene = t27.gene
left join
(select gene, count(*) as num_bs_to_us from commonVariants where old_path="Benign*" and new_path="Unknown significance" group by gene) t28
on g.gene = t28.gene
left join
(select gene, count(*) as num_bs_to_lb from commonVariants where old_path="Benign*" and new_path="Likely benign" group by gene) t29
on g.gene = t29.gene
left join
(select gene, count(*) as num_bs_to_b from commonVariants where old_path="Benign*" and new_path="Benign" group by gene) t30
on g.gene = t30.gene;





select "Total",IFNULL(num_old_var,0) AS num_old_var, IFNULL(num_new_var,0) AS num_new_var, IFNULL(added,0) AS added, IFNULL(dropped,0) AS dropped, IFNULL(num_path, 0) AS num_path, IFNULL(num_lp, 0) AS num_lp, IFNULL(num_us, 0) AS num_us, IFNULL(num_lb, 0) AS num_lb, IFNULL(num_b, 0) AS num_b, IFNULL(num_bs, 0) AS num_bs, IFNULL(old_num_path, 0) AS old_num_path, IFNULL(old_num_lp, 0) AS old_num_lp, IFNULL(old_num_us, 0) AS old_num_us, IFNULL(old_num_lb, 0) AS old_num_lb, IFNULL(old_num_b, 0) AS old_num_b, IFNULL(old_num_bs, 0) AS old_num_bs, IFNULL(changed,0) AS changed, IFNULL(unchanged,0) AS unchanged, IFNULL(num_p_to_lp,0) AS num_p_to_lp, IFNULL(num_p_to_us,0) AS num_p_to_us, IFNULL(num_p_to_lb,0) AS num_p_to_lb, IFNULL(num_p_to_b,0) AS num_p_to_b, IFNULL(num_p_to_bs,0) AS num_p_to_bs, IFNULL(num_lp_to_p,0) AS num_lp_to_p, IFNULL(num_lp_to_us,0) AS num_lp_to_us, IFNULL(num_lp_to_lb,0) AS num_lp_to_lb, IFNULL(num_lp_to_b,0) AS num_lp_to_b, IFNULL(num_lp_to_bs,0) AS num_lp_to_bs, IFNULL(num_us_to_p,0) AS num_us_to_p, IFNULL(num_us_to_lp,0) AS num_us_to_lp, IFNULL(num_us_to_lb,0) AS num_us_to_lb, IFNULL(num_us_to_b,0) AS num_us_to_b, IFNULL(num_us_to_bs,0) AS num_us_to_bs, IFNULL(num_lb_to_p,0) AS num_lb_to_p, IFNULL(num_lb_to_lp,0) AS num_lb_to_lp, IFNULL(num_lb_to_us,0) AS num_lb_to_us, IFNULL(num_lb_to_b,0) AS num_lb_to_b, IFNULL(num_lb_to_bs,0) AS num_lb_to_bs, IFNULL(num_b_to_p,0) AS num_b_to_p, IFNULL(num_b_to_lp,0) AS num_b_to_lp, IFNULL(num_b_to_us,0) AS num_b_to_us, IFNULL(num_b_to_lb,0) AS num_b_to_lb, IFNULL(num_b_to_bs,0) AS num_b_to_bs, IFNULL(num_bs_to_p,0) AS num_bs_to_p, IFNULL(num_bs_to_lp,0) AS num_bs_to_lp, IFNULL(num_bs_to_us,0) AS num_bs_to_us, IFNULL(num_bs_to_lb,0) AS num_bs_to_lb, IFNULL(num_bs_to_b,0) AS num_bs_to_b 
from 
(select count(*) as num_old_var from oldTable) ot
left join
(select count(*) as num_new_var from newTable) nt
left join
(select count(*) as added from newTable where variation not in (select variation from commonVariants)) a
left join
(select count(*) as dropped from oldTable where variation not in (select variation from commonVariants)) d
left join
(select count(*) as num_path from newTable where pathogenicity="Pathogenic") pn
left join
(select count(*) as num_lp from newTable where pathogenicity="Likely pathogenic") lpn
left join
(select count(*) as num_us from newTable where pathogenicity="Unknown significance") usn
left join
(select count(*) as num_lb from newTable where pathogenicity="Likely benign") lbn
left join
(select count(*) as num_b from newTable where pathogenicity="Benign") bn
left join
(select count(*) as num_bs from newTable where pathogenicity="Benign*") bsn
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
left join
(select count(*) as changed from commonVariants where old_path != new_path) c
left join
(select count(*) as unchanged from commonVariants where old_path = new_path) u
left join
(select count(*) as num_p_to_lp from commonVariants where old_path="Pathogenic" and new_path="Likely pathogenic") t1
left join
(select count(*) as num_p_to_us from commonVariants where old_path="Pathogenic" and new_path="Unknown significance") t2
left join
(select count(*) as num_p_to_lb from commonVariants where old_path="Pathogenic" and new_path="Likely benign") t3
left join
(select count(*) as num_p_to_b from commonVariants where old_path="Pathogenic" and new_path="Benign") t4
left join
(select count(*) as num_p_to_bs from commonVariants where old_path="Pathogenic" and new_path="Benign*") t5
left join
(select count(*) as num_lp_to_p from commonVariants where old_path="Likely pathogenic" and new_path="Pathogenic") t6
left join
(select count(*) as num_lp_to_us from commonVariants where old_path="Likely pathogenic" and new_path="Unknown significance") t7
left join
(select count(*) as num_lp_to_lb from commonVariants where old_path="Likely pathogenic" and new_path="Likely benign") t8
left join
(select count(*) as num_lp_to_b from commonVariants where old_path="Likely pathogenic" and new_path="Benign") t9
left join
(select count(*) as num_lp_to_bs from commonVariants where old_path="Likely pathogenic" and new_path="Benign*") t10
left join
(select count(*) as num_us_to_p from commonVariants where old_path="Unknown significance" and new_path="Pathogenic") t11
left join
(select count(*) as num_us_to_lp from commonVariants where old_path="Unknown significance" and new_path="Likely pathogenic") t12
left join
(select count(*) as num_us_to_lb from commonVariants where old_path="Unknown significance" and new_path="Likely benign") t13
left join
(select count(*) as num_us_to_b from commonVariants where old_path="Unknown significance" and new_path="Benign") t14
left join
(select count(*) as num_us_to_bs from commonVariants where old_path="Unknown significance" and new_path="Benign*") t15
left join
(select count(*) as num_lb_to_p from commonVariants where old_path="Likely benign" and new_path="Pathogenic") t16
left join
(select count(*) as num_lb_to_lp from commonVariants where old_path="Likely benign" and new_path="Likely pathogenic") t17
left join
(select count(*) as num_lb_to_us from commonVariants where old_path="Likely benign" and new_path="Unknown significance") t18
left join
(select count(*) as num_lb_to_b from commonVariants where old_path="Likely benign" and new_path="Benign") t19
left join
(select count(*) as num_lb_to_bs from commonVariants where old_path="Likely benign" and new_path="Benign*") t20
left join
(select count(*) as num_b_to_p from commonVariants where old_path="Benign" and new_path="Pathogenic") t21
left join
(select count(*) as num_b_to_lp from commonVariants where old_path="Benign" and new_path="Likely pathogenic") t22
left join
(select count(*) as num_b_to_us from commonVariants where old_path="Benign" and new_path="Unknown significance") t23
left join
(select count(*) as num_b_to_lb from commonVariants where old_path="Benign" and new_path="Likely benign") t24
left join
(select count(*) as num_b_to_bs from commonVariants where old_path="Benign" and new_path="Benign*") t25
left join
(select count(*) as num_bs_to_p from commonVariants where old_path="Benign*" and new_path="Pathogenic") t26
left join
(select count(*) as num_bs_to_lp from commonVariants where old_path="Benign*" and new_path="Likely pathogenic") t27
left join
(select count(*) as num_bs_to_us from commonVariants where old_path="Benign*" and new_path="Unknown significance") t28
left join
(select count(*) as num_bs_to_lb from commonVariants where old_path="Benign*" and new_path="Likely benign") t29
left join
(select count(*) as num_bs_to_b from commonVariants where old_path="Benign*" and new_path="Benign") t30
;






.output pathDemoted.csv
.headers on
select * from commonVariants where old_path="Pathogenic" and new_path="Likely pathogenic";
select * from commonVariants where old_path="Pathogenic" and new_path="Unknown significance";
select * from commonVariants where old_path="Pathogenic" and new_path="Likely benign";
select * from commonVariants where old_path="Pathogenic" and new_path="Benign";
select * from commonVariants where old_path="Pathogenic" and new_path="Benign*";
.headers on
--add pathogenic dropped, variants in old table with path="Pathogenic, that dont exsist in new table
select * from oldTable where pathogenicity="Pathogenic" and variation not in (select variation from newTable);

.output likelyPathDemoted.csv

select * from commonVariants where old_path="Likely pathogenic" and new_path="Unknown significance";
.header off
select * from commonVariants where old_path="Likely pathogenic" and new_path="Likely benign";
select * from commonVariants where old_path="Likely pathogenic" and new_path="Benign";
select * from commonVariants where old_path="Likely pathogenic" and new_path="Benign*";

.header on
--add likely pathogenic dropped, a variant in the old table with path = lp, that doesnt exsist in the new table
select * from oldTable where pathogenicity="Likely pathogenic" and variation not in (select variation from newTable);

.output pathPromoted.csv
select * from commonVariants where old_path="Likely pathogenic" and new_path="Pathogenic";
.header off
select * from commonVariants where old_path="Unknown significance" and new_path="Pathogenic";
select * from commonVariants where old_path="Likely benign" and new_path="Pathogenic";
select * from commonVariants where old_path="Benign" and new_path="Pathogenic";
select * from commonVariants where old_path="Benign" and new_path="Benign*";

.header on
.output likelyPathPromoted.csv
select * from commonVariants where old_path="Unknown significance" and new_path="Likely pathogenic";
.header off
select * from commonVariants where old_path="Likely benign" and new_path="Likely pathogenic";
select * from commonVariants where old_path="Benign" and new_path="Likely pathogenic";
select * from commonVariants where old_path="Benign*" and new_path="Likely pathogenic";

.header on
.output geneVarNumChange_addedVariants.csv
--select severything from the new table that is not in the old table, but the gene is
select * from newTable where variation not in (select variation from commonVariants) and gene in (select gene from commonVariants);

.output geneVarNumChange_droppedVariants.csv
--select everything from old table that is not in the new table, but the gene is
select * from oldTable where variation not in (select variation from commonVariants) and gene in (select gene from commonVariants);





