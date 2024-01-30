* Lecture 1 ;

libname c "C:\Users\bbsstudent\Desktop\Stats\Data_sets";

proc contents data=c.unico;
run;

proc cluster data = c.unico method = single;
var d10_1-d10_8;
run;
proc tree; run;

* Lecture 2 ;
proc cluster data = c.unico method = ward;
var d10_1-d10_8;
run;
proc tree; run;

proc cluster data = c.unico method = ward outtree=c.tree noprint;
id id;
var d10_1-d10_8;
run;
proc tree data = c.tree ncl = 3 out=c.cluster noprint; 
id id;
run;

proc sort data = c.unico; by id; run;
proc sort data = c.cluster; by id; run;
data c.unico_1; merge c.unico c.cluster;
by id;
run;

proc freq data = c.unico_1;
table sex*cluster / expected chisq; run;

*Lecture 3*; 
proc means data = c.unico_1;
    var d10_1-d10_8;
    class cluster; run;
    
    *fake dataset to do ttest;
    data c.unico_fake; set c.unico_1;
    cluster = 4; run;
    data c.unico_append; set c.unico_1 c.unico_fake;
    run;
    
    *description of cluster1;
    proc ttest data = c.unico_append;
    where cluster = 1 or cluster = 4;
    var d10_1-d10_8; 
    class cluster;
    run;

    *description of cluster3;
proc ttest data=c.unico_append;
where cluster=3 or cluster=4;
var d10_1-d10_8;
class cluster;
run;

proc corr data=c.unico_1;
    var d10_1-d10_8;
    run;

*Lecture 4*;

proc princomp data=c.unico;
var d10_1-d10_8;
run;
proc princomp data=c.unico out=c.coord;
var d10_1-d10_8;
run;
data c.unit_1_84; set c.coord;
if id = 1 or id = 84;
run;

data c.coord_1; set c.coord;
avgi = mean(of d10_1-d10_8);
run;
proc corr data = c.coord_1;
var avgi prin1;
run;

*break*;

data c.sz_unico; set c.unico;
avgi=mean(of d10_1-d10_8);
maxi=max(of d10_1-d10_8);
mini=min(of d10_1-d10_8);
if d10_1>avgi then new_1=(d10_1-avgi)/(maxi-avgi);
if d10_1<avgi then new_1=(d10_1-avgi)/(avgi-mini);
if d10_1=avgi then new_1=0;
if d10_1=. then new_1=0;
run;

*this must be repeated for other attributes;
data c.sz_unico_1; set c.unico;
avgi=mean(of d10_1-d10_8);
maxi=max(of d10_1-d10_8);
mini=min(of d10_1-d10_8);
array a1 d10_1-d10_8;
array a2 new_1-new_8;
do over a2;
if a1>avgi then a2=(a1-avgi)/(maxi-avgi);
if a1<avgi then a2=(a1/avgi)/(avgi-mini);
if a1=avgi then a2=0;
if a1=. then a2=0;
end;
label new_1='leisure';
label new_2='schemas';
label new_3='new_fans';
label new_4='usual_friends';
label new_5='work';
label new_6='show';
label new_7='suffer';
label new_8='time';
run;

proc means data=c.sz_unico min max mean;
var d10_: new_: ; run;

proc princomp data = c.sz_unico out = sz_unico_1;
var new_:;
run;

*Lecture 5*;

proc cluster data=c.sz_unico_1 
method=ward 
outtree=c.sz_tree;
var prin1-prin4;
id id; run;
proc tree data=c.sz_tree; run; 

proc tree data=c.sz_tree noprint
nclusters = 6 
out=c.sz_cluster;
id id; run; 

proc sort data = c.sz_cluster; by id; run;
proc sort data = c.sz_unico_1; by id; run;
data c.sz_unico_2; merge c.sz_unico_1 c.sz_cluster;
by id;
run;

*qualitative var ;
proc freq data=c.sz_unico_2;
table sex*cluster / expected all;
run;

*cluster 1 represents 50% of our women;
*we have a clear correspondence bw our data and independence model*;
* my partition in clusters is not related to genders*;

*quantitative var *;
data c.sz_unico_fake; set c.sz_unico_2;
cluster = 7; run;
data c.sz_unico_long; set c.sz_unico_2 c.sz_unico_fake;
run;

*macro to produce 6 analysis of our 6 clusters;
%macro do_k_cluster;
    %do k=1 %to 6;
    proc ttest data=c.sz_unico_long;
    where cluster=&k or cluster=7;
    class cluster;
    var new:;
    ods output ttests=c.cl_ttest_&k (where=( method='Satterthwaite') 
    rename=(tvalue=tvalue_&k) rename=(probt=prob_&k));
    run;
    %end;
    %mend do_k_cluster;
    %do_k_cluster;

data c.ttest_all;
merge c.cl_ttest1 c.cl_ttest2 c.cl_ttest3 c.cl_ttest4 c.cl_ttest5 c.cl_ttest6;
by variable;
run;

proc contents data=c.sz_unico_long out=c.contents;   *to discover the content of our file;
run; 

data c.contents; set c.contents;
rename name=variable;
run;

data c.ttest_all_1;
merge c.ttest_all (in=a) c.contents(in=b);
by variable;
if a; 
run;

