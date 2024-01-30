/* Setting of the SAS library */
LIBNAME sas_proj 'C:\Users\bbsstudent\Desktop\YouTube_Project';

/* Reading the form CSV data */
proc import 
   datafile="C:\Users\bbsstudent\Desktop\YouTube_Project\yt_dataset.csv" 
   out=sas_proj.yt_dataset
   dbms=csv
   replace;
run;

/* Print the dataset */
proc print data=sas_proj.yt_dataset;
run;

proc cluster data=sas_proj.yt_dataset method=ward; /*method=single;*/ 
    var d10_1-d10_8;
run;

proc tree;
run;

/* 
Creation of uncorrelated variables (principal components),
it is applied to identify patterns by using the principal components
as they capture the most important data
*/
proc princomp data=sas_proj.yt_dataset;
    var d10_1-d10_8;
run;

/* Storing the principal components in a new dataset yt_coord  */
proc princomp data=sas_proj.yt_dataset out=sas_proj.yt_coord;
    var d10_1-d10_8;
run;

/* Setting a column with the means of each of the cluster variables */
data sas_proj.yt_coord_1; set sas_proj.yt_coord;
    avgi=mean(of d10_1-d10_8);
run;

/* Running the correlation between the first princomp with the avgi to check for the presence of size effect*/
proc corr data=sas_proj.yt_coord_1;
    var avgi prin1-prin8;
run;

data sas_proj.sz_yt; set sas_proj.yt_dataset;
    avgi=mean(of d10_1-d10_8);
    mini=min(of d10_1-d10_8);
    maxi=max(of d10_1-d10_8);
    /* Active variables array */
    array a1 d10_1-d10_8; /* Input array */
    array a2 new_1-new_8; /* Output array */
    /* Conditions to be checked SAS for loop*/
    do over a2;
    if a1 > avgi then a2=(a1-avgi)/(maxi-avgi);
    if a1 < avgi then a2=(a1-avgi)/(avgi-mini);
    if a1 = avgi then a2=0;
    if a1 =. then a2=0;
    end;
    /* Adding labels */
    label new_1='w_sports';
    label new_2='w_educative';
    label new_3='l_music';
    label new_4='w_vlogs';
    label new_5='w_diy';
    label new_6='w_gaming';
    label new_7='imp_duration';
    label new_8='imp_thumbnail';
run;

/* Calculating mean of cluster variables and the newly labelled variables */
proc means data=sas_proj.sz_yt min max mean;
    var d10_: new_: ;
run;

/* Running princomp on the newly labelled variables */
proc princomp data=sas_proj.sz_yt out=sas_proj.sz_yt_1;
    var new_:; 
run;

/* Creation of dendrogram on newly labelled variables */
proc cluster data=sas_proj.sz_yt_1 method=ward outtree=sas_proj.sz_tree;
    var prin1-prin4;
    id id;
run;

proc tree data=sas_proj.sz_tree; run;

/* Performing cluster analysis - setting 4 clusters due to the number of gaps between long vertical lines and spaces */
proc tree data=sas_proj.sz_tree noprint nclusters=4 out=sas_proj.sz_cluster;
    id id;
run;

/* Sorting the data before merging */
proc sort data=sas_proj.sz_cluster; by id; run;
proc sort data=sas_proj.sz_yt_1; by id; run;
/* Merging of the data */
data sas_proj.sz_yt_2; merge sas_proj.sz_yt_1 sas_proj.sz_cluster;
    by id;
run;

/* Run the various statistical tests on the newly merged dataset */
proc freq data=sas_proj.sz_yt_2;
    /* All - considers all statistical tests */
    table gender*cluster / expected all;
run;

/* Run the various statistical tests on the newly merged dataset */
proc freq data=sas_proj.sz_yt_2;
    /* All - considers all statistical tests */
    table age*cluster / expected all;
run;

/* Run the various statistical tests on the newly merged dataset */
proc freq data=sas_proj.sz_yt_2;
    /* All - considers all statistical tests */
    table occupation*cluster / expected all;
run;

/* Creation of new fake dataset */
data sas_proj.sz_yt_fake; set sas_proj.sz_yt_2;
    cluster=5;
run;

/* New dataset made of original and fake dataset */
data sas_proj.sz_yt_long; set sas_proj.sz_yt_2 sas_proj.sz_yt_fake;
run;

/**
* 
*/
/* Macro to produce 5 descriptions of our 5 clusters */
%macro do_k_cluster;
    %do k=1 %to 4;
    proc ttest data=sas_proj.sz_yt_long;
        where cluster=&k or cluster=5;
        class cluster;
        var new:;
        /* ttests => name of output test result
        Naming standard increments for each new value (&k)*/
        ods output ttests=sas_proj.cl_ttest_&k (where=(method='Satterthwaite')
        rename=(tvalue=tvalue_&k) rename=(probt=prob_&k));
    run;
    %end;
    %mend do_k_cluster;
    %do_k_cluster;
    run;
run;

proc sort data=sas_proj.cl_ttest_1;
    by variable;
run;

proc sort data=sas_proj.cl_ttest_2;
    by variable;
run;

proc sort data=sas_proj.cl_ttest_3;
    by variable;
run;

proc sort data=sas_proj.cl_ttest_4;
    by variable;
run;

data sas_proj.cl_ttest_all; merge 
    sas_proj.cl_ttest_1 
    sas_proj.cl_ttest_2 
    sas_proj.cl_ttest_3 
    sas_proj.cl_ttest_4;
    by variable;
    run;
run;

%macro do_k_cluster;
    %do k=1 %to 4;
    proc ttest data=sas_proj.sz_yt_long;
        where cluster=&k or cluster=5;
        class cluster;
        var dev_usage;
        /* ttests => name of output test result
        Naming standard increments for each new value (&k)*/
        ods output ttests=sas_proj.dev_usage&k (where=(method='Satterthwaite')
        rename=(tvalue=tvalue_&k) rename=(probt=prob_&k));
    run;
    %end;
    %mend do_k_cluster;
    %do_k_cluster;
    run;
run;
    
%macro do_k_cluster;
    %do k=1 %to 4;
    proc ttest data=sas_proj.sz_yt_long;
        where cluster=&k or cluster=5;
        class cluster;
        var yt_usage;
        /* ttests => name of output test result
        Naming standard increments for each new value (&k)*/
        ods output ttests=sas_proj.yt_usage&k (where=(method='Satterthwaite')
        rename=(tvalue=tvalue_&k) rename=(probt=prob_&k));
    run;
    %end;
    %mend do_k_cluster;
    %do_k_cluster;
    run;
run;

/* Creation of labels - data identity card */
proc contents data=sas_proj.sz_yt_long out=sas_proj.yt_contents;
run;

/* Change dataset column name */
data sas_proj.yt_contents; set sas_proj.yt_contents;
    rename name=variable;
run;

/* Merge column labels from diff tables */
data sas_proj.cl_ttest_all_1;
    merge sas_proj.cl_ttest_all (in=a) sas_proj.yt_contents(in=b);
        by variable;
        if a;
run;