%% Add Data
matriksdata = xlsread('Data Beban Harian.xlsx','Sheet1','D3:AA296');
liburdata = xlsread('Data Hari Libur.xlsx','Sheet1','D3:AA296');
[banyakrow,banyakcol] = size(matriksdata);
barisdata = [];
harilibur = [];
% weekend = [];
awalhari = 246; %% starting day for TRAINING data (Data Beban Harian and Data Hari Libur)
panjangdata = 5*7; %%5 minggu -> 4 minggu data forecast + 1 minggu input
akhirhari = panjangdata+awalhari-1;
for i = awalhari:akhirhari %%1:35
    barisdata = [barisdata,matriksdata(i,:)];
    %     weekend = [weekend,ones(1,24)*liburdata(i,1)];
    harilibur = [harilibur,ones(1,24)*liburdata(i,2)];
end
barisdata = barisdata';
% weekend = weekend';
harilibur = harilibur';
%% Windowize data
predictrange = 24*7;
lagend = 29*24; %%7 hari input+1 output
lagstep = 24*7;
datatable = windowize(barisdata,1:lagstep:lagend); %%Y part might be filled by indices
Xtraindata = datatable(:,1:end-1); %%input training
Ytraindata = datatable(:,end); %%output training
prevload = Ytraindata(end); %%previous data for naive forecast
% datatable = windowize(weekend,1:lagstep:lagend);
% Xtraindata = [Xtraindata,datatable(:,1)];
datatable = windowize(harilibur,1:lagstep:lagend);
Xtraindata = [Xtraindata,datatable(:,1:end)];
%% create Xtestdata and Ytestdata
awalhari = akhirhari-27; %%
panjangdata = 5*7; %%2 minggu -> 1 input 1 output
akhirhari = panjangdata+awalhari-1;
barisdata = [];
harilibur = [];
% weekend = [];
for i = awalhari:akhirhari %% 7 dari 7 hari atau 24*7 jam
    barisdata = [barisdata,matriksdata(i,:)];
    %     weekend = [weekend,ones(1,24)*liburdata(i,1)];
    harilibur = [harilibur,ones(1,24)*liburdata(i,2)];
end
barisdata = barisdata';
% weekend = weekend';
harilibur = harilibur';
datatable = windowize(barisdata,1:lagstep:lagend); %%Y part might be filled by indices
Xtestdata = datatable(:,1:end-1); %%input training
Ytestdata = datatable(:,end); %%output training
% datatable = windowize(weekend,1:lagstep:lagend);
% Xtestdata = [Xtestdata,datatable(:,1)];
datatable = windowize(harilibur,1:lagstep:lagend);
Xtestdata = [Xtestdata,datatable(:,1:end)];
%% Start 4-fold CV tuning. Error function MAE. Optimization Method Coupled SA then Nelder-Mead Simplex Algorithm
%% tunelssvm tuning is based on CSA. add igwo for I-GWO, gwo for GWO, alo for ALO, and apso for APSO in the back for another algorithms
%% Local search by Nelder Mead has been removed
tic;
[gam,sig2] = tunelssvmigwo({Xtraindata,Ytraindata,'f',[],[],'RBF_kernel'},'simplex','crossvalidatelssvm',{4,'mae'});
waktusim = toc;
%% Get Alpha Beta from best tuning
[alpha,b] = trainlssvm({Xtraindata,Ytraindata,'f',gam,sig2,'RBF_kernel'});
%% Start Prediction
prediction = simlssvm({Xtraindata,Ytraindata,'f',gam,sig2,'RBF_kernel'},{alpha,b},Xtestdata);
plot([prediction Ytestdata]);
MAEerror = mean(abs(Ytestdata - prediction));
MAPEerror = mean(abs(100*(Ytestdata-prediction)./Ytestdata));
%% Get Naive Forecast Error
naive = zeros(length(Ytestdata),1);
for nn = 1:length(Ytestdata)
    if nn == 1
        naive(nn,1) = Ytestdata(nn,1) - prevload;
    else
        naive(nn,1) = Ytestdata(nn,1) - Ytestdata(nn-1,1);
    end
end
MAEnaive = mean(abs(naive));
%% Get scaled error
% Get denominator
naiveA = zeros(length(Ytestdata)-1,1);
for nn = 1:length(Ytestdata)-1
    naiveA(nn,1) = Ytestdata(nn+1,1) - Ytestdata(nn,1);
end
denom = mean(abs(naiveA));
MASEerror = mean(abs((Ytestdata - prediction)./denom));
Rsquared = corr(prediction,Ytestdata);