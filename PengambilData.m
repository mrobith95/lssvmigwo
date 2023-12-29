%% Add Data
matriksdata = xlsread('Data Beban Harian.xlsx','Sheet1','D3:AA296');
liburdata = xlsread('Data Hari Libur.xlsx','Sheet1','D3:AA296');
[banyakrow,banyakcol] = size(matriksdata);
matriksawalhari = [85 92 99 106 113 120 127 134 141 148 155 162 169 176 183 190 197 204 211 218 225 232 239 246 253];
%% banyakcase=numel(matriksawalhari);
namafile = {'Hasil Simulasi IGWO 1';
    'Hasil Simulasi IGWO 2';
    'Hasil Simulasi IGWO 3';
    'Hasil Simulasi IGWO 4';
    'Hasil Simulasi IGWO 5';
    'Hasil Simulasi IGWO 6';
    'Hasil Simulasi IGWO 7';
    'Hasil Simulasi IGWO 8';
    'Hasil Simulasi IGWO 9';
    'Hasil Simulasi IGWO 10';
    'Hasil Simulasi IGWO 11';
    'Hasil Simulasi IGWO 12';
    'Hasil Simulasi IGWO 13';
    'Hasil Simulasi IGWO 14';
    'Hasil Simulasi IGWO 15';
    'Hasil Simulasi IGWO 16';
    'Hasil Simulasi IGWO 17';
    'Hasil Simulasi IGWO 18';
    'Hasil Simulasi IGWO 19';
    'Hasil Simulasi IGWO 20';
    'Hasil Simulasi IGWO 21';
    'Hasil Simulasi IGWO 22';
    'Hasil Simulasi IGWO 23';
    'Hasil Simulasi IGWO 24';
    'Hasil Simulasi IGWO 25'};
% hasilsimulasi = zeros(4,30);
ndata = 30; % how many times an algorithm should run for each study case
hasilsimulasi = zeros(8,ndata);
for jj = 1:25
    %% I-GWO
    starting = matriksawalhari(jj);
    hasilsimulasi = zeros(8,ndata);
    for k = 1:ndata %% ambil data ndata kali
        %% susun data yang diregress
        barisdata = [];
        %         harilibur = [];
        % weekend = [];
        awalhari = starting;
        panjangdata = 5*7; %%5 minggu -> 4 minggu data forecast + 1 minggu input
        akhirhari = panjangdata+awalhari-1;
        for i = awalhari:akhirhari %%1:35
            barisdata = [barisdata,matriksdata(i,:)];
            %     weekend = [weekend,ones(1,24)*liburdata(i,1)];
            %             harilibur = [harilibur,ones(1,24)*liburdata(i,2)];
        end
        barisdata = barisdata';
        % weekend = weekend';
        %         harilibur = harilibur';
        %% Windowize data
        predictrange = 24*7;
        lagend = 29*24; %%7 hari input+1 output
        lagstep = 24*7;
        datatable = windowize(barisdata,1:lagstep:lagend); %%Y part might be filled by indices
        Xtraindata = datatable(:,1:end-1); %%input training
        Ytraindata = datatable(:,end); %%output training
        skala = 0;
        for ss = 2:168 %% for computing MASE
            skala = skala + abs(Ytraindata(ss) - Ytraindata(ss-1));
        end
        skala = skala/(168-1);
        % datatable = windowize(weekend,1:lagstep:lagend);
        % Xtraindata = [Xtraindata,datatable(:,1)];
        %         datatable = windowize(harilibur,1:lagstep:lagend);
        %         Xtraindata = [Xtraindata,datatable(:,1:end)];
        %% create Xtestdata and Ytestdata
        awalhari = akhirhari-27; %%
        panjangdata = 5*7; %%2 minggu -> 1 input 1 output
        akhirhari = panjangdata+awalhari-1;
        barisdata = [];
        %         harilibur = [];
        % weekend = [];
        for i = awalhari:akhirhari %% 7 dari 7 hari atau 24*7 jam
            barisdata = [barisdata,matriksdata(i,:)];
            %     weekend = [weekend,ones(1,24)*liburdata(i,1)];
            %             harilibur = [harilibur,ones(1,24)*liburdata(i,2)];
        end
        barisdata = barisdata';
        % weekend = weekend';
        %         harilibur = harilibur';
        datatable = windowize(barisdata,1:lagstep:lagend); %%Y part might be filled by indices
        Xtestdata = datatable(:,1:end-1); %%input training
        Ytestdata = datatable(:,end); %%output training
        % datatable = windowize(weekend,1:lagstep:lagend);
        % Xtestdata = [Xtestdata,datatable(:,1)];
        %         datatable = windowize(harilibur,1:lagstep:lagend);
        %         Xtestdata = [Xtestdata,datatable(:,1:end)];
        %% Start 4-fold CV tuning. Error function MAE. Optimization Method Coupled SA then Nelder-Mead Simplex Algorithm
        tic;
        [gam,sig2] = tunelssvmigwo({Xtraindata,Ytraindata,'f',[],[],'RBF_kernel'},'simplex','crossvalidatelssvm',{4,'mae'});
        waktusim = toc;
        %% Get Alpha Beta from best tuning
        [alpha,b] = trainlssvm({Xtraindata,Ytraindata,'f',gam,sig2,'RBF_kernel'});
        %% Start Prediction
        prediction = simlssvm({Xtraindata,Ytraindata,'f',gam,sig2,'RBF_kernel'},{alpha,b},Xtestdata);
        %     plot([prediction Ytestdata]);
        errorMAE = mean(abs(prediction-Ytestdata)); %Forecast error MAE
        errorMAPE = mean(abs(100*(prediction-Ytestdata)./Ytestdata)); %MAPE
        errorMASE = mean(abs((prediction-Ytestdata)./skala)); %error MASE
        [errorR,RPval] = corr(prediction,Ytestdata); %korelasi
        hasilsimulasi(:,k) = [gam;sig2;errorMAE;waktusim;errorMAPE;errorMASE;errorR^2;RPval];
    end
    %     xlswrite(char(namafile(jj)),hasilsimulasi,'GWO','B2');
    xlswrite(char(namafile(jj)),hasilsimulasi,'IGWO','B2');
    % %% GWO
    hasilsimulasi = zeros(8,ndata);
    for k = 1:ndata %% ambil data ndata kali
        %% susun data yang diregress
        barisdata = [];
        %         harilibur = [];
        % weekend = [];
        awalhari = starting;
        panjangdata = 5*7; %%5 minggu -> 4 minggu data forecast + 1 minggu input
        akhirhari = panjangdata+awalhari-1;
        for i = awalhari:akhirhari %%1:35
            barisdata = [barisdata,matriksdata(i,:)];
            %     weekend = [weekend,ones(1,24)*liburdata(i,1)];
            %             harilibur = [harilibur,ones(1,24)*liburdata(i,2)];
        end
        barisdata = barisdata';
        % weekend = weekend';
        %         harilibur = harilibur';
        %% Windowize data
        predictrange = 24*7;
        lagend = 29*24; %%7 hari input+1 output
        lagstep = 24*7;
        datatable = windowize(barisdata,1:lagstep:lagend); %%Y part might be filled by indices
        Xtraindata = datatable(:,1:end-1); %%input training
        Ytraindata = datatable(:,end); %%output training
        skala = 0;
        for ss = 2:168 %% for computing MASE
            skala = skala + abs(Ytraindata(ss) - Ytraindata(ss-1));
        end
        skala = skala/(168-1);
        % datatable = windowize(weekend,1:lagstep:lagend);
        % Xtraindata = [Xtraindata,datatable(:,1)];
        %         datatable = windowize(harilibur,1:lagstep:lagend);
        %         Xtraindata = [Xtraindata,datatable(:,1:end)];
        %% create Xtestdata and Ytestdata
        awalhari = akhirhari-27; %%
        panjangdata = 5*7; %%2 minggu -> 1 input 1 output
        akhirhari = panjangdata+awalhari-1;
        barisdata = [];
        %         harilibur = [];
        % weekend = [];
        for i = awalhari:akhirhari %% 7 dari 7 hari atau 24*7 jam
            barisdata = [barisdata,matriksdata(i,:)];
            %     weekend = [weekend,ones(1,24)*liburdata(i,1)];
            %             harilibur = [harilibur,ones(1,24)*liburdata(i,2)];
        end
        barisdata = barisdata';
        % weekend = weekend';
        %         harilibur = harilibur';
        datatable = windowize(barisdata,1:lagstep:lagend); %%Y part might be filled by indices
        Xtestdata = datatable(:,1:end-1); %%input training
        Ytestdata = datatable(:,end); %%output training
        % datatable = windowize(weekend,1:lagstep:lagend);
        % Xtestdata = [Xtestdata,datatable(:,1)];
        %         datatable = windowize(harilibur,1:lagstep:lagend);
        %         Xtestdata = [Xtestdata,datatable(:,1:end)];
        %% Start 4-fold CV tuning. Error function MAE. Optimization Method Coupled SA then Nelder-Mead Simplex Algorithm
        tic;
        [gam,sig2] = tunelssvmgwo({Xtraindata,Ytraindata,'f',[],[],'RBF_kernel'},'simplex','crossvalidatelssvm',{4,'mae'});
        waktusim = toc;
        %% Get Alpha Beta from best tuning
        [alpha,b] = trainlssvm({Xtraindata,Ytraindata,'f',gam,sig2,'RBF_kernel'});
        %% Start Prediction
        prediction = simlssvm({Xtraindata,Ytraindata,'f',gam,sig2,'RBF_kernel'},{alpha,b},Xtestdata);
        %     plot([prediction Ytestdata]);
        errorMAE = mean(abs(prediction-Ytestdata)); %Forecast error MAE
        errorMAPE = mean(abs(100*(prediction-Ytestdata)./Ytestdata)); %MAPE
        errorMASE = mean(abs((prediction-Ytestdata)./skala)); %error MASE
        [errorR,RPval] = corr(prediction,Ytestdata); %korelasi
        hasilsimulasi(:,k) = [gam;sig2;errorMAE;waktusim;errorMAPE;errorMASE;errorR^2;RPval];
    end
    xlswrite(char(namafile(jj)),hasilsimulasi,'GWO','B2');
    % %% CSA
    hasilsimulasi = zeros(8,ndata);
    for k = 1:ndata %% ambil data ndata kali
        %% susun data yang diregress
        barisdata = [];
        %         harilibur = [];
        % weekend = [];
        awalhari = starting;
        panjangdata = 5*7; %%5 minggu -> 4 minggu data forecast + 1 minggu input
        akhirhari = panjangdata+awalhari-1;
        for i = awalhari:akhirhari %%1:35
            barisdata = [barisdata,matriksdata(i,:)];
            %     weekend = [weekend,ones(1,24)*liburdata(i,1)];
            %             harilibur = [harilibur,ones(1,24)*liburdata(i,2)];
        end
        barisdata = barisdata';
        % weekend = weekend';
        %         harilibur = harilibur';
        %% Windowize data
        predictrange = 24*7;
        lagend = 29*24; %%7 hari input+1 output
        lagstep = 24*7;
        datatable = windowize(barisdata,1:lagstep:lagend); %%Y part might be filled by indices
        Xtraindata = datatable(:,1:end-1); %%input training
        Ytraindata = datatable(:,end); %%output training
        skala = 0;
        for ss = 2:168 %% for computing MASE
            skala = skala + abs(Ytraindata(ss) - Ytraindata(ss-1));
        end
        skala = skala/(168-1);
        % datatable = windowize(weekend,1:lagstep:lagend);
        % Xtraindata = [Xtraindata,datatable(:,1)];
        %         datatable = windowize(harilibur,1:lagstep:lagend);
        %         Xtraindata = [Xtraindata,datatable(:,1:end)];
        %% create Xtestdata and Ytestdata
        awalhari = akhirhari-27; %%
        panjangdata = 5*7; %%2 minggu -> 1 input 1 output
        akhirhari = panjangdata+awalhari-1;
        barisdata = [];
        %         harilibur = [];
        % weekend = [];
        for i = awalhari:akhirhari %% 7 dari 7 hari atau 24*7 jam
            barisdata = [barisdata,matriksdata(i,:)];
            %     weekend = [weekend,ones(1,24)*liburdata(i,1)];
            %             harilibur = [harilibur,ones(1,24)*liburdata(i,2)];
        end
        barisdata = barisdata';
        % weekend = weekend';
        %         harilibur = harilibur';
        datatable = windowize(barisdata,1:lagstep:lagend); %%Y part might be filled by indices
        Xtestdata = datatable(:,1:end-1); %%input training
        Ytestdata = datatable(:,end); %%output training
        % datatable = windowize(weekend,1:lagstep:lagend);
        % Xtestdata = [Xtestdata,datatable(:,1)];
        %         datatable = windowize(harilibur,1:lagstep:lagend);
        %         Xtestdata = [Xtestdata,datatable(:,1:end)];
        %% Start 4-fold CV tuning. Error function MAE. Optimization Method Coupled SA then Nelder-Mead Simplex Algorithm
        tic;
        [gam,sig2] = tunelssvm({Xtraindata,Ytraindata,'f',[],[],'RBF_kernel'},'simplex','crossvalidatelssvm',{4,'mae'});
        waktusim = toc;
        %% Get Alpha Beta from best tuning
        [alpha,b] = trainlssvm({Xtraindata,Ytraindata,'f',gam,sig2,'RBF_kernel'});
        %% Start Prediction
        prediction = simlssvm({Xtraindata,Ytraindata,'f',gam,sig2,'RBF_kernel'},{alpha,b},Xtestdata);
        %     plot([prediction Ytestdata]);
        errorMAE = mean(abs(prediction-Ytestdata)); %Forecast error MAE
        errorMAPE = mean(abs(100*(prediction-Ytestdata)./Ytestdata)); %MAPE
        errorMASE = mean(abs((prediction-Ytestdata)./skala)); %error MASE
        [errorR,RPval] = corr(prediction,Ytestdata); %korelasi
        hasilsimulasi(:,k) = [gam;sig2;errorMAE;waktusim;errorMAPE;errorMASE;errorR^2;RPval];
    end
    xlswrite(char(namafile(jj)),hasilsimulasi,'CSA','B2');
    % %% ALO
    hasilsimulasi = zeros(8,ndata);
    for k = 1:ndata %% ambil data ndata kali
        %% susun data yang diregress
        barisdata = [];
        %         harilibur = [];
        % weekend = [];
        awalhari = starting;
        panjangdata = 5*7; %%5 minggu -> 4 minggu data forecast + 1 minggu input
        akhirhari = panjangdata+awalhari-1;
        for i = awalhari:akhirhari %%1:35
            barisdata = [barisdata,matriksdata(i,:)];
            %     weekend = [weekend,ones(1,24)*liburdata(i,1)];
            %             harilibur = [harilibur,ones(1,24)*liburdata(i,2)];
        end
        barisdata = barisdata';
        % weekend = weekend';
        %         harilibur = harilibur';
        %% Windowize data
        predictrange = 24*7;
        lagend = 29*24; %%7 hari input+1 output
        lagstep = 24*7;
        datatable = windowize(barisdata,1:lagstep:lagend); %%Y part might be filled by indices
        Xtraindata = datatable(:,1:end-1); %%input training
        Ytraindata = datatable(:,end); %%output training
        skala = 0;
        for ss = 2:168 %% for computing MASE
            skala = skala + abs(Ytraindata(ss) - Ytraindata(ss-1));
        end
        skala = skala/(168-1);
        % datatable = windowize(weekend,1:lagstep:lagend);
        % Xtraindata = [Xtraindata,datatable(:,1)];
        %         datatable = windowize(harilibur,1:lagstep:lagend);
        %         Xtraindata = [Xtraindata,datatable(:,1:end)];
        %% create Xtestdata and Ytestdata
        awalhari = akhirhari-27; %%
        panjangdata = 5*7; %%2 minggu -> 1 input 1 output
        akhirhari = panjangdata+awalhari-1;
        barisdata = [];
        %         harilibur = [];
        % weekend = [];
        for i = awalhari:akhirhari %% 7 dari 7 hari atau 24*7 jam
            barisdata = [barisdata,matriksdata(i,:)];
            %     weekend = [weekend,ones(1,24)*liburdata(i,1)];
            %             harilibur = [harilibur,ones(1,24)*liburdata(i,2)];
        end
        barisdata = barisdata';
        % weekend = weekend';
        %         harilibur = harilibur';
        datatable = windowize(barisdata,1:lagstep:lagend); %%Y part might be filled by indices
        Xtestdata = datatable(:,1:end-1); %%input training
        Ytestdata = datatable(:,end); %%output training
        % datatable = windowize(weekend,1:lagstep:lagend);
        % Xtestdata = [Xtestdata,datatable(:,1)];
        %         datatable = windowize(harilibur,1:lagstep:lagend);
        %         Xtestdata = [Xtestdata,datatable(:,1:end)];
        %% Start 4-fold CV tuning. Error function MAE. Optimization Method Coupled SA then Nelder-Mead Simplex Algorithm
        tic;
        [gam,sig2] = tunelssvmalo({Xtraindata,Ytraindata,'f',[],[],'RBF_kernel'},'simplex','crossvalidatelssvm',{4,'mae'});
        waktusim = toc;
        %% Get Alpha Beta from best tuning
        [alpha,b] = trainlssvm({Xtraindata,Ytraindata,'f',gam,sig2,'RBF_kernel'});
        %% Start Prediction
        prediction = simlssvm({Xtraindata,Ytraindata,'f',gam,sig2,'RBF_kernel'},{alpha,b},Xtestdata);
        %     plot([prediction Ytestdata]);
        errorMAE = mean(abs(prediction-Ytestdata)); %Forecast error MAE
        errorMAPE = mean(abs(100*(prediction-Ytestdata)./Ytestdata)); %MAPE
        errorMASE = mean(abs((prediction-Ytestdata)./skala)); %error MASE
        [errorR,RPval] = corr(prediction,Ytestdata); %korelasi
        hasilsimulasi(:,k) = [gam;sig2;errorMAE;waktusim;errorMAPE;errorMASE;errorR^2;RPval];
    end
    xlswrite(char(namafile(jj)),hasilsimulasi,'ALO','B2');
    % %% APSO
    hasilsimulasi = zeros(8,ndata);
    for k = 1:ndata %% ambil data ndata kali
        %% susun data yang diregress
        barisdata = [];
        %         harilibur = [];
        % weekend = [];
        awalhari = starting;
        panjangdata = 5*7; %%5 minggu -> 4 minggu data forecast + 1 minggu input
        akhirhari = panjangdata+awalhari-1;
        for i = awalhari:akhirhari %%1:35
            barisdata = [barisdata,matriksdata(i,:)];
            %     weekend = [weekend,ones(1,24)*liburdata(i,1)];
            %             harilibur = [harilibur,ones(1,24)*liburdata(i,2)];
        end
        barisdata = barisdata';
        % weekend = weekend';
        %         harilibur = harilibur';
        %% Windowize data
        predictrange = 24*7;
        lagend = 29*24; %%7 hari input+1 output
        lagstep = 24*7;
        datatable = windowize(barisdata,1:lagstep:lagend); %%Y part might be filled by indices
        Xtraindata = datatable(:,1:end-1); %%input training
        Ytraindata = datatable(:,end); %%output training
        skala = 0;
        for ss = 2:168 %% for computing MASE
            skala = skala + abs(Ytraindata(ss) - Ytraindata(ss-1));
        end
        skala = skala/(168-1);
        % datatable = windowize(weekend,1:lagstep:lagend);
        % Xtraindata = [Xtraindata,datatable(:,1)];
        %         datatable = windowize(harilibur,1:lagstep:lagend);
        %         Xtraindata = [Xtraindata,datatable(:,1:end)];
        %% create Xtestdata and Ytestdata
        awalhari = akhirhari-27; %%
        panjangdata = 5*7; %%2 minggu -> 1 input 1 output
        akhirhari = panjangdata+awalhari-1;
        barisdata = [];
        %         harilibur = [];
        % weekend = [];
        for i = awalhari:akhirhari %% 7 dari 7 hari atau 24*7 jam
            barisdata = [barisdata,matriksdata(i,:)];
            %     weekend = [weekend,ones(1,24)*liburdata(i,1)];
            %             harilibur = [harilibur,ones(1,24)*liburdata(i,2)];
        end
        barisdata = barisdata';
        % weekend = weekend';
        %         harilibur = harilibur';
        datatable = windowize(barisdata,1:lagstep:lagend); %%Y part might be filled by indices
        Xtestdata = datatable(:,1:end-1); %%input training
        Ytestdata = datatable(:,end); %%output training
        % datatable = windowize(weekend,1:lagstep:lagend);
        % Xtestdata = [Xtestdata,datatable(:,1)];
        %         datatable = windowize(harilibur,1:lagstep:lagend);
        %         Xtestdata = [Xtestdata,datatable(:,1:end)];
        %% Start 4-fold CV tuning. Error function MAE. Optimization Method Coupled SA then Nelder-Mead Simplex Algorithm
        tic;
        [gam,sig2] = tunelssvmapso({Xtraindata,Ytraindata,'f',[],[],'RBF_kernel'},'simplex','crossvalidatelssvm',{4,'mae'});
        waktusim = toc;
        %% Get Alpha Beta from best tuning
        [alpha,b] = trainlssvm({Xtraindata,Ytraindata,'f',gam,sig2,'RBF_kernel'});
        %% Start Prediction
        prediction = simlssvm({Xtraindata,Ytraindata,'f',gam,sig2,'RBF_kernel'},{alpha,b},Xtestdata);
        %     plot([prediction Ytestdata]);
        errorMAE = mean(abs(prediction-Ytestdata)); %Forecast error MAE
        errorMAPE = mean(abs(100*(prediction-Ytestdata)./Ytestdata)); %MAPE
        errorMASE = mean(abs((prediction-Ytestdata)./skala)); %error MASE
        [errorR,RPval] = corr(prediction,Ytestdata); %korelasi
        hasilsimulasi(:,k) = [gam;sig2;errorMAE;waktusim;errorMAPE;errorMASE;errorR^2;RPval];
    end
    xlswrite(char(namafile(jj)),hasilsimulasi,'APSO','B2');
end
beep
