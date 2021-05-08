%% ambil data
tabelfile = {'Hasil Simulasi IGWO 1'
    'Hasil Simulasi IGWO 2'
    'Hasil Simulasi IGWO 3'
    'Hasil Simulasi IGWO 4'
    'Hasil Simulasi IGWO 5'
    'Hasil Simulasi IGWO 6'
    'Hasil Simulasi IGWO 7'
    'Hasil Simulasi IGWO 8'
    'Hasil Simulasi IGWO 9'
    'Hasil Simulasi IGWO 10'
    'Hasil Simulasi IGWO 11'
    'Hasil Simulasi IGWO 12'
    'Hasil Simulasi IGWO 13'
    'Hasil Simulasi IGWO 14'
    'Hasil Simulasi IGWO 15'
    'Hasil Simulasi IGWO 16'
    'Hasil Simulasi IGWO 17'
    'Hasil Simulasi IGWO 18'
    'Hasil Simulasi IGWO 19'
    'Hasil Simulasi IGWO 20'
    'Hasil Simulasi IGWO 21'
    'Hasil Simulasi IGWO 22'
    'Hasil Simulasi IGWO 23'
    'Hasil Simulasi IGWO 24'
    'Hasil Simulasi IGWO 25'};

[banyakcase,~] = size(tabelfile);
hasilcs = zeros(banyakcase,35);

%% hasil simulasi
for kk = 1:banyakcase
    hasilCGWO = xlsread(char(tabelfile(kk)),'IGWO','B2:AE10');
    hasilGWO = xlsread(char(tabelfile(kk)),'GWO','B2:AE10');
    hasilCSA = xlsread(char(tabelfile(kk)),'CSA','B2:AE10');
    hasilALO = xlsread(char(tabelfile(kk)),'ALO','B2:AE10');
    hasilAPSO = xlsread(char(tabelfile(kk)),'APSO','B2:AE10');
    
    averageCGWO = mean(hasilCGWO(3,:)); %% 3 for MAE, 6 for MAPE, 7 for
%     MASE, 8 for R2
    averageGWO = mean(hasilGWO(3,:));
    averageCSA = mean(hasilCSA(3,:));
    averageALO = mean(hasilALO(3,:));
    averageAPSO = mean(hasilAPSO(3,:));
    
    stdevCGWO = std(hasilCGWO(3,:)); %% 3 for MAE, 6 for MAPE, 7 for
%     MASE, 8 for R2
    stdevGWO = std(hasilGWO(3,:));
    stdevCSA = std(hasilCSA(3,:));
    stdevALO = std(hasilALO(3,:));
    stdevAPSO = std(hasilAPSO(3,:));
    
    [bestCGWOmae,bestCGWOind] = min(hasilCGWO(3,:)); %% 3 for MAE, 6 for MAPE, 7 for
%     MASE, 8 for R2. skip 2 line after this line to change metric
    bestCGWOgam = hasilCGWO(1,bestCGWOind);
    bestCGWOsig = hasilCGWO(2,bestCGWOind);
    [bestGWOmae,bestGWOind] = min(hasilGWO(3,:));
    bestGWOgam = hasilGWO(1,bestGWOind);
    bestGWOsig = hasilGWO(2,bestGWOind);
    [bestCSAmae,bestCSAind] = min(hasilCSA(3,:));
    bestCSAgam = hasilCSA(1,bestCSAind);
    bestCSAsig = hasilCSA(2,bestCSAind);
    [bestALOmae,bestALOind] = min(hasilALO(3,:));
    bestALOgam = hasilALO(1,bestALOind);
    bestALOsig = hasilALO(2,bestALOind);
    [bestAPSOmae,bestAPSOind] = min(hasilAPSO(3,:));
    bestAPSOgam = hasilAPSO(1,bestAPSOind);
    bestAPSOsig = hasilAPSO(2,bestAPSOind);
    
    timeaverageCGWO = mean(hasilCGWO(4,:));
    timeaverageGWO = mean(hasilGWO(4,:));
    timeaverageCSA = mean(hasilCSA(4,:));
    timeaverageALO = mean(hasilALO(4,:));
    timeaverageAPSO = mean(hasilAPSO(4,:));
    
    timestdevCGWO = std(hasilCGWO(4,:));
    timestdevGWO = std(hasilGWO(4,:));
    timestdevCSA = std(hasilCSA(4,:));
    timestdevALO = std(hasilALO(4,:));
    timestdevAPSO = std(hasilAPSO(4,:));
    
    dataCGWO = [bestCGWOgam bestCGWOsig bestCGWOmae averageCGWO stdevCGWO ...
        timeaverageCGWO timestdevCGWO];
    dataGWO = [bestGWOgam bestGWOsig bestGWOmae averageGWO stdevGWO ...
        timeaverageGWO timestdevGWO];
    dataCSA = [bestCSAgam bestCSAsig bestCSAmae averageCSA stdevCSA ...
        timeaverageCSA timestdevCSA];
    dataALO = [bestALOgam bestALOsig bestALOmae averageALO stdevALO ...
        timeaverageALO timestdevALO];
    dataAPSO = [bestAPSOgam bestAPSOsig bestAPSOmae averageAPSO stdevAPSO ...
        timeaverageAPSO timestdevAPSO];
    
    hasilcs(kk,:) = [dataCGWO dataGWO dataCSA dataALO dataAPSO];
    
end
xlswrite('Rangkuman Simulasi',hasilcs,'Resume','C4');

%%display various error measure on 1 table
hasilerr = zeros(banyakcase+4,20);
for kk = 1:banyakcase
    hasilCGWO = xlsread(char(tabelfile(kk)),'IGWO','B2:AE9');
    hasilGWO = xlsread(char(tabelfile(kk)),'GWO','B2:AE9');
    hasilCSA = xlsread(char(tabelfile(kk)),'CSA','B2:AE9');
    hasilALO = xlsread(char(tabelfile(kk)),'ALO','B2:AE9');
    hasilAPSO = xlsread(char(tabelfile(kk)),'APSO','B2:AE9');
    
    hasilerr(kk,1) = mean(hasilCGWO(3,:));
    hasilerr(kk,2) = mean(hasilGWO(3,:));
    hasilerr(kk,3) = mean(hasilCSA(3,:));
    hasilerr(kk,4) = mean(hasilALO(3,:));
    hasilerr(kk,5) = mean(hasilAPSO(3,:));
    hasilerr(kk,6) = mean(hasilCGWO(6,:));
    hasilerr(kk,7) = mean(hasilGWO(6,:));
    hasilerr(kk,8) = mean(hasilCSA(6,:));
    hasilerr(kk,9) = mean(hasilALO(6,:));
    hasilerr(kk,10) = mean(hasilAPSO(6,:));
    hasilerr(kk,11) = mean(hasilCGWO(7,:));
    hasilerr(kk,12) = mean(hasilGWO(7,:));
    hasilerr(kk,13) = mean(hasilCSA(7,:));
    hasilerr(kk,14) = mean(hasilALO(7,:));
    hasilerr(kk,15) = mean(hasilAPSO(7,:));
    hasilerr(kk,16) = mean(hasilCGWO(8,:));
    hasilerr(kk,17) = mean(hasilGWO(8,:));
    hasilerr(kk,18) = mean(hasilCSA(8,:));
    hasilerr(kk,19) = mean(hasilALO(8,:));
    hasilerr(kk,20) = mean(hasilAPSO(8,:));
end
for kk = 1:20
    hasilerr(26,kk) = mean(hasilerr(1:25,kk));
    hasilerr(27,kk) = std(hasilerr(1:25,kk));
    hasilerr(28,kk) = median(hasilerr(1:25,kk));
    persentil1 = prctile(hasilerr(1:25,kk),25);
    persentil3 = prctile(hasilerr(1:25,kk),75);
    hasilerr(29,kk) = median(hasilerr(1:25,kk))-(1.57*(persentil3-persentil1)/sqrt(25));
    hasilerr(30,kk) = median(hasilerr(1:25,kk))+(1.57*(persentil3-persentil1)/sqrt(25));
end
xlswrite('Multiple Error Measure Table',hasilerr,'Error Measure','C4');

%% pengujian friedman
averagetable = [-1*hasilerr(1:25,16:20)]; % 1:5 MAE, 6:10 MAPE, 11:15 MASE, 16:20 R^2. multiply -1 for R^2
[pval,table,stat] = friedman(averagetable,1,'on');
% boxplot(averagetable,{'I-GWO','GWO','CSA','ALO','APSO'},'Notch','marker');%boxplot
averagetable = [averagetable; stat.meanranks];

xlswrite('Rangkuman Simulasi R2',averagetable,'Friedman','C4');
xlswrite('Rangkuman Simulasi R2',[table{2,5};pval],'Friedman','J4');

%% post hoc shaffer
unadjposthoc = zeros(10,1);
posthoctext = {'IGWO vs GWO';
    'IGWO vs CSA';
    'IGWO vs ALO';
    'IGWO vs APSO';
    'GWO vs CSA';
    'GWO vs ALO';
    'GWO vs APSO';
    'CSA vs ALO';
    'CSA vs APSO';
    'ALO vs APSO'};
counter = 0;
for ii=1:4
    for jj = ii+1:5
        counter = counter+1;
        unadjposthoc(counter,1) = (stat.meanranks(ii) - stat.meanranks(jj))*sqrt(6*banyakcase/(6*5));
    end
end
unadjposthoc = normpdf(unadjposthoc,0,1);
[unadjposthoc,index] = sort(unadjposthoc);
newposthoctext = {};
for ii = 1:10
    newposthoctext{ii} = posthoctext{index(ii)};
end
posthoctext = newposthoctext';
posthoc = zeros(10,1);
shaffermult = [10; 6; 6; 6; 6; 4; 4; 3; 2; 1];
for ii = 1:10
    for jj = 1:ii
        posthoc(ii) = max(posthoc(ii),shaffermult(jj)*unadjposthoc(jj));
    end
end
posthoc = min(posthoc,ones(10,1));

xlswrite('Rangkuman Simulasi R2',posthoctext,'Post-Hoc','B4');
xlswrite('Rangkuman Simulasi R2',posthoc,'Post-Hoc','C4');