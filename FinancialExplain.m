% ========================================================================
% Clustering and Classification of FDI Networks
% ========================================================================
% This script analyzes Foreign Direct Investment (FDI) networks by applying 
% clustering methods and evaluating their effectiveness using classification models. 
% It assesses within-cluster and between-cluster distances across different 
% network partitioning methods.
%
% The script performs the following tasks:
% - Loads network partition data from 'Partizioni.mat' and 'ZIP_RegressionResults.mat'.
% - Processes FDI time series from 'FDI_03-07-2024 13-39-27-47_timeSeries.csv'.
% - Maps country codes using 'countries_codes_and_coordinates.csv'.
% - Standardizes country abbreviations using 'fmcountryabbrev.pdf' (processed text).
% - Associates FDI data with network partitions from 2000 to 2020.
% - Computes within-cluster and between-cluster distances using Euclidean, 
%   Cosine, and Correlation metrics.
% - Trains classification models (LDA, ECOC, Decision Trees) on network partitions.
% - Evaluates classification performance with Precision, Recall, AUROC, and Accuracy.
%
% ------------------------------------------------------------------------
% Usage:
% - Ensure the required data files are in the working directory.
% - Run the script in MATLAB.
% ------------------------------------------------------------------------
%
% Outputs:
% - Classification performance metrics: Precision, Recall, AUROC, Accuracy.
% - Within-cluster and between-cluster distance matrices.
% - Visualizations and statistical analysis of clustering quality.
%
% Additional Features:
% - Supports multiple clustering and distance metrics.
% - Evaluates the stability and separability of network partitions.
% - Provides insights into FDI network structures over time.
%
% ========================================================================

clc; clearvars; close all
%% addpath
addpath('Data')
addpath("RegressionResults")
%% read results
load Partizioni.mat
load('ZIP_RegressionResults.mat','NodiFin');
FDI=readtable('FDI_03-07-2024 13-39-27-47_timeSeries.csv');
chiave=readtable('countries_codes_and_coordinates.csv');
%% paesi
str = extractFileText('fmcountryabbrev.pdf');
newStr = splitlines(str);
newStr=erase(newStr,'COUNTRY ABBREVIATIONS');
newStr=erase(newStr,'International Monetary Fund | April 2018 ');
newStr=erase(newStr,'International Monetary Fund | April 2018');
newStr=erase(newStr,'91');
newStr=erase(newStr,'92');
newStr=erase(newStr,'FISCAL MONITOR: CAPITALIZING ON GOOD TIMES');
newStr=erase(newStr," ");
newStr(newStr=="")=[];
newStr(newStr==" ")=[];
chi1=find(strcmp(newStr,'Code'));
chi2=find(strcmp(newStr,'Countryname'));
abbre=[];
interi=[];
for i =1:size(chi1,1)
    abbre=[abbre;newStr(chi1(i)+1:chi2(i)-1)];
    if i<4
        interi=[interi;newStr(chi2(i)+1:chi1(i+1)-1)];
    else
        interi=[interi;newStr(chi2(i)+1:end)];
    end
end
%% a mano
interi(164)="Thailand";
interi(6)="Armenia,Rep.of";
interi(10)="Azerbaijan,Rep.of";
interi(18)="Bahamas,The";
interi(17)="Bahrain,Kingdomof";
interi(20)="Belarus,Rep.of";
interi(28)="CentralAfricanRep.";
interi(32)="China,P.R.:Mainland";
interi(38)="Comoros,Unionofthe";
interi(35)="Congo,Dem.Rep.ofthe";
interi(36)="Congo,Rep.of";
interi(33)="Côted'Ivoire";
interi=replace(interi,"Croatia","Croatia,Rep.of");
interi=replace(interi,"Republic","Rep.");
interi(50)="Egypt,ArabRep.of";
interi(51)="Eritrea,TheStateof";
interi(53)="Estonia,Rep.of";
interi(54)="Ethiopia,TheFederalDem.Rep.of";
interi(56)="Fiji,Rep.of";
interi(64)="Gambia,The";
interi(66)="EquatorialGuinea,Rep.of";
interi(71)="China,P.R.:HongKong";
interi(79)="Iran,IslamicRep.of";
interi(80)="Iran,IslamicRep.of";
interi(87)="Kazakhstan,Rep.of";
interi(93)="Korea,Rep.of";
interi(95)="LaoPeople'sDem.Rep.";
interi(101)="Lesotho,Kingdomof";
interi(107)="Madagascar,Rep.of";
interi(110)="MarshallIslands,Rep.ofthe";
interi(118)="Mauritania,IslamicRep.of";
interi(106)="Moldova,Rep.of";
interi(111)="NorthMacedonia,Republicof";
interi(117)="Mozambique,Rep.of";
interi(126)="Netherlands,The";
interi(137)="Poland,Rep.of";
interi(142)="RussianFederation";
interi(153)="Serbia,Rep.of";
interi(161)="SyrianArabRep.";
interi(154)="SãoToméandPríncipe,Dem.Rep.of";
interi(165)="Tajikistan,Rep.of";
interi(174)="Tanzania,UnitedRep.of";
interi(167)="Timor-Leste,Dem.Rep.of";
interi(179)="Uzbekistan,Rep.of";
interi(181)="Venezuela,Rep.Bolivarianade";
interi(185)="Yemen,Rep.of";
%% FDI
NomiFDI=string(FDI.Var1);
NomiFDI=NomiFDI(2:end,:);
NomiFDIUnici=unique(NomiFDI);
NomiFDIUnici=erase(NomiFDIUnici," ");

VariabiliFDI=string(FDI.Var3);
VariabiliFDI=VariabiliFDI(2:end);
VariabiliFDIUniche=unique(VariabiliFDI);

ValoriFDI=table2array(FDI(2:end,6:end));
ValoriFDI=[ValoriFDI(:,1),ValoriFDI];

FDI_dati=zeros(length(NomiFDIUnici),size(ValoriFDI,2),9);
for t=1:9
    chi1=find(strcmp(VariabiliFDI,VariabiliFDIUniche(t)));
    ValoriFDI_aus=ValoriFDI(chi1,:);
    Nomi=NomiFDI(chi1);
    [Nomi,pos]=sort(Nomi);
    FDI_dati(:,:,t)=ValoriFDI_aus(pos,:);
end

[NomiF,A,B]=intersect(Nomi,interi);
FDI_dati=FDI_dati(A,:,:);
NomiAbb=abbre(B);
%% main
Tempi=2000:2020;
PREC_1=zeros(21,4);
PREC_2=zeros(21,4);
PREC_3=zeros(21,4);
PREC_C=zeros(21,4);

REC_1=zeros(21,4);
REC_2=zeros(21,4);
REC_3=zeros(21,4);
REC_C=zeros(21,4);

AUROC_1=zeros(21,4);
AUROC_2=zeros(21,4);
AUROC_3=zeros(21,4);
AUROC_C=zeros(21,4);


ACC_1=zeros(21,4);
ACC_2=zeros(21,4);
ACC_3=zeros(21,4);
ACC_C=zeros(21,4);

Within=zeros(21,3);
Between=zeros(21,3);
%% main loop
for t=1:21
    nomi=NodiFin{t};
    partizione=Partition{t};
    [AA,BB,CC]=intersect(nomi,NomiAbb);

    partizione=partizione(BB);
    FDI_datiFin=FDI_dati(CC,t,:);
    FDI_datiFin=reshape(FDI_datiFin,size(FDI_datiFin,1),size(FDI_datiFin,3));
    PP=cell(1,max(partizione));
    for c=1:max(partizione)
        PP{c}=FDI_datiFin(partizione==c,:);
    end

    partizione2=PartitionOT{t,2};
    [AA,BB,CC]=intersect(nomi,NomiAbb);

    partizione2=partizione2(BB);
    FDI_datiFin=FDI_dati(CC,t,:);
    FDI_datiFin=reshape(FDI_datiFin,size(FDI_datiFin,1),size(FDI_datiFin,3));
    PP2=cell(1,max(partizione2));
    for c=1:max(partizione2)
        PP2{c}=FDI_datiFin(partizione2==c,:);
    end

    partizione3=PartitionOT{t,3};
    [AA,BB,CC]=intersect(nomi,NomiAbb);

    partizione3=partizione3(BB);
    FDI_datiFin=FDI_dati(CC,t,:);
    FDI_datiFin=reshape(FDI_datiFin,size(FDI_datiFin,1),size(FDI_datiFin,3));
    PP3=cell(1,max(partizione3));
    for c=1:max(partizione3)
        PP3{c}=FDI_datiFin(partizione3==c,:);
    end
    % within between
    MM=squareform(pdist(FDI_datiFin(:,[2 3 4 6 7 8]),'euclidean'));
    [r,m1,m2] = community_distance_ratio(MM, partizione3);
    Within(t,1)=m1;
    Between(t,1) = m2;

    MM=squareform(pdist(FDI_datiFin(:,[2 3 4 6 7 8]),'cosine'));
    [r,m1,m2] = community_distance_ratio(MM, partizione3);
    Within(t,2)=m1;
    Between(t,2) = m2;

    MM=squareform(pdist(FDI_datiFin(:,[2 3 4 6 7 8]),'correlation'));
    [r,m1,m2] = community_distance_ratio(MM, partizione3);
    Within(t,3)=m1;
    Between(t,3) = m2;

    %
    Mdl = fitcdiscr(FDI_datiFin(:,[2 3 4 6 7 8]),partizione2);
    [pred, scores]=predict(Mdl,FDI_datiFin(:,[2 3 4 6 7 8]));
    accuracy = sum(partizione2 == pred,'all')/numel(pred);
    ACC_2(t,1)=accuracy;
    [m,order]=confusionmat(partizione2,pred);
    Diagonal=diag(m);
    sum_rows=sum(m,2);
    Precision=Diagonal./sum_rows;
    PREC_2(t,1)=mean(Precision);
    Diagonal=diag(m);
    sum_rows=sum(m,1);
    Precision=Diagonal./sum_rows';
    REC_2(t,1)=nanmean(Precision);
    rocObj = rocmetrics(partizione2,scores,Mdl.ClassNames);
    [FPR,TPR,Thresholds,AUC] = average(rocObj,"weighted");
    AUROC_2(t,1)=AUC;

    Mdl = fitcecoc(FDI_datiFin(:,[2 3 4 6 7 8]),partizione2);
    [pred, scores]=predict(Mdl,FDI_datiFin(:,[2 3 4 6 7 8]));
    accuracy = sum(partizione2 == pred,'all')/numel(pred);
    ACC_2(t,2)=accuracy;
    [m,order]=confusionmat(partizione2,pred);
    Diagonal=diag(m);
    sum_rows=sum(m,2);
    Precision=Diagonal./sum_rows;
    PREC_2(t,2)=mean(Precision);
    Diagonal=diag(m);
    sum_rows=sum(m,1);
    Precision=Diagonal./sum_rows';
    REC_2(t,2)=nanmean(Precision);
    rocObj = rocmetrics(partizione2,scores,Mdl.ClassNames);
    [FPR,TPR,Thresholds,AUC] = average(rocObj,"weighted");
    AUROC_2(t,2)=AUC;

    Mdl = fitctree(FDI_datiFin(:,[2 3 4 6 7 8]),partizione2);
    [pred, scores]=predict(Mdl,FDI_datiFin(:,[2 3 4 6 7 8]));
     accuracy = sum(partizione2 == pred,'all')/numel(pred);
    ACC_2(t,3)=accuracy;
    [m,order]=confusionmat(partizione2,pred);
    Diagonal=diag(m);
    sum_rows=sum(m,2);
    Precision=Diagonal./sum_rows;
    PREC_2(t,3)=mean(Precision);
    Diagonal=diag(m);
    sum_rows=sum(m,1);
    Precision=Diagonal./sum_rows';
    REC_2(t,3)=nanmean(Precision);
    rocObj = rocmetrics(partizione2,scores,Mdl.ClassNames);
    [FPR,TPR,Thresholds,AUC] = average(rocObj,"weighted");
    AUROC_2(t,3)=AUC;
    % 
    partizione1=PartitionOT{t,1};
    partizione1=partizione1(BB);
    Mdl = fitcdiscr(FDI_datiFin(:,[2 3 4 6 7 8]),partizione1);
    [pred, scores]=predict(Mdl,FDI_datiFin(:,[2 3 4 6 7 8]));
    accuracy = sum(partizione1 == pred,'all')/numel(pred);
    ACC_1(t,1)=accuracy;
    [m,order]=confusionmat(partizione1,pred);
    Diagonal=diag(m);
    sum_rows=sum(m,2);
    Precision=Diagonal./sum_rows;
    PREC_1(t,1)=mean(Precision);
    Diagonal=diag(m);
    sum_rows=sum(m,1);
    Precision=Diagonal./sum_rows';
    REC_1(t,1)=nanmean(Precision);
    rocObj = rocmetrics(partizione1,scores,Mdl.ClassNames);
    [FPR,TPR,Thresholds,AUC] = average(rocObj,"weighted");
    AUROC_1(t,1)=AUC;

    Mdl = fitcecoc(FDI_datiFin(:,[2 3 4 6 7 8]),partizione1);
    [pred, scores]=predict(Mdl,FDI_datiFin(:,[2 3 4 6 7 8]));
    accuracy = sum(partizione1 == pred,'all')/numel(pred);
    ACC_1(t,2)=accuracy;
    [m,order]=confusionmat(partizione1,pred);
    Diagonal=diag(m);
    sum_rows=sum(m,2);
    Precision=Diagonal./sum_rows;
    PREC_1(t,2)=mean(Precision);
    Diagonal=diag(m);
    sum_rows=sum(m,1);
    Precision=Diagonal./sum_rows';
    REC_1(t,2)=nanmean(Precision);
    rocObj = rocmetrics(partizione1,scores,Mdl.ClassNames);
    [FPR,TPR,Thresholds,AUC] = average(rocObj,"weighted");
    AUROC_1(t,2)=AUC;

    Mdl = fitctree(FDI_datiFin(:,[2 3 4 6 7 8]),partizione1);
    [pred, scores]=predict(Mdl,FDI_datiFin(:,[2 3 4 6 7 8]));
     accuracy = sum(partizione1 == pred,'all')/numel(pred);
    ACC_1(t,3)=accuracy;
    [m,order]=confusionmat(partizione1,pred);
    Diagonal=diag(m);
    sum_rows=sum(m,2);
    Precision=Diagonal./sum_rows;
    PREC_1(t,3)=mean(Precision);
    Diagonal=diag(m);
    sum_rows=sum(m,1);
    Precision=Diagonal./sum_rows';
    REC_1(t,3)=nanmean(Precision);
    rocObj = rocmetrics(partizione1,scores,Mdl.ClassNames);
    [FPR,TPR,Thresholds,AUC] = average(rocObj,"weighted");
    AUROC_1(t,3)=AUC;
    %
    partizione3=PartitionOT{t,3};
    partizione3=partizione3(BB);
    Mdl = fitcdiscr(FDI_datiFin(:,[2 3 4 6 7 8]),partizione3);
    [pred, scores]=predict(Mdl,FDI_datiFin(:,[2 3 4 6 7 8]));
    accuracy = sum(partizione3 == pred,'all')/numel(pred);
    ACC_3(t,1)=accuracy;
    [m,order]=confusionmat(partizione3,pred);
    Diagonal=diag(m);
    sum_rows=sum(m,2);
    Precision=Diagonal./sum_rows;
    PREC_3(t,1)=mean(Precision);
    Diagonal=diag(m);
    sum_rows=sum(m,1);
    Precision=Diagonal./sum_rows';
    REC_3(t,1)=nanmean(Precision);
    rocObj = rocmetrics(partizione3,scores,Mdl.ClassNames);
    [FPR,TPR,Thresholds,AUC] = average(rocObj,"weighted");
    AUROC_3(t,1)=AUC;

    Mdl = fitcecoc(FDI_datiFin(:,[2 3 4 6 7 8]),partizione3);
    [pred, scores]=predict(Mdl,FDI_datiFin(:,[2 3 4 6 7 8]));
    accuracy = sum(partizione3 == pred,'all')/numel(pred);
    ACC_3(t,2)=accuracy;
    [m,order]=confusionmat(partizione3,pred);
    Diagonal=diag(m);
    sum_rows=sum(m,2);
    Precision=Diagonal./sum_rows;
    PREC_3(t,2)=mean(Precision);
    Diagonal=diag(m);
    sum_rows=sum(m,1);
    Precision=Diagonal./sum_rows';
    REC_3(t,2)=nanmean(Precision);
    rocObj = rocmetrics(partizione3,scores,Mdl.ClassNames);
    [FPR,TPR,Thresholds,AUC] = average(rocObj,"weighted");
    AUROC_3(t,2)=AUC;

    Mdl = fitctree(FDI_datiFin(:,[2 3 4 6 7 8]),partizione3);
    [pred, scores]=predict(Mdl,FDI_datiFin(:,[2 3 4 6 7 8]));
     accuracy = sum(partizione3 == pred,'all')/numel(pred);
    ACC_3(t,3)=accuracy;
    [m,order]=confusionmat(partizione3,pred);
    Diagonal=diag(m);
    sum_rows=sum(m,2);
    Precision=Diagonal./sum_rows;
    PREC_3(t,3)=mean(Precision);
    Diagonal=diag(m);
    sum_rows=sum(m,1);
    Precision=Diagonal./sum_rows';
    REC_3(t,3)=nanmean(Precision);
    rocObj = rocmetrics(partizione3,scores,Mdl.ClassNames);
    [FPR,TPR,Thresholds,AUC] = average(rocObj,"weighted");
    AUROC_3(t,3)=AUC;

    % classico 
    Mdl = fitcdiscr(FDI_datiFin(:,[2 3 4 6 7 8]),partizione);
    [pred, scores]=predict(Mdl,FDI_datiFin(:,[2 3 4 6 7 8]));
    accuracy = sum(partizione == pred,'all')/numel(pred);
    ACC_C(t,1)=accuracy;
    [m,order]=confusionmat(partizione,pred);
    Diagonal=diag(m);
    sum_rows=sum(m,2);
    Precision=Diagonal./sum_rows;
    PREC_C(t,1)=mean(Precision);
    Diagonal=diag(m);
    sum_rows=sum(m,1);
    Precision=Diagonal./sum_rows';
    REC_C(t,1)=nanmean(Precision);
    rocObj = rocmetrics(partizione,scores,Mdl.ClassNames);
    [FPR,TPR,Thresholds,AUC] = average(rocObj,"weighted");
    AUROC_C(t,1)=AUC;

  

    Mdl = fitcecoc(FDI_datiFin(:,[2 3 4 6 7 8]),partizione);
    [pred, scores]=predict(Mdl,FDI_datiFin(:,[2 3 4 6 7 8]));
    accuracy = sum(partizione == pred,'all')/numel(pred);
    ACC_C(t,2)=accuracy;
    [m,order]=confusionmat(partizione,pred);
    Diagonal=diag(m);
    sum_rows=sum(m,2);
    Precision=Diagonal./sum_rows;
    PREC_C(t,2)=mean(Precision);
    Diagonal=diag(m);
    sum_rows=sum(m,1);
    Precision=Diagonal./sum_rows';
    REC_C(t,2)=nanmean(Precision);
    rocObj = rocmetrics(partizione,scores,Mdl.ClassNames);
    [FPR,TPR,Thresholds,AUC] = average(rocObj,"weighted");
    AUROC_C(t,2)=AUC;

    Mdl = fitctree(FDI_datiFin(:,[2 3 4 6 7 8]),partizione);
    [pred, scores]=predict(Mdl,FDI_datiFin(:,[2 3 4 6 7 8]));
    accuracy = sum(partizione == pred,'all')/numel(pred);
    ACC_C(t,3)=accuracy;
    [m,order]=confusionmat(partizione,pred);
    Diagonal=diag(m);
    sum_rows=sum(m,2);
    Precision=Diagonal./sum_rows;
    PREC_C(t,3)=mean(Precision);
    Diagonal=diag(m);
    sum_rows=sum(m,1);
    Precision=Diagonal./sum_rows';
    REC_C(t,3)=nanmean(Precision);
    rocObj = rocmetrics(partizione,scores,Mdl.ClassNames);
    [FPR,TPR,Thresholds,AUC] = average(rocObj,"weighted");
    AUROC_C(t,3)=AUC;

    % figure
    % boxplotGroup(PP3,'groupLines',true,'PrimaryLabels',string(1:length(PP3)),'SecondaryLabels',VariabiliFDIUniche,'groupLabelType','Vertical')
    % title(Tempi(t))
    % xlabel('Communities')

    
end
%% plot
tt={'Discriminant Analysis','Support Vector Machine','Tree'};
gamma=[0.0001 0.001 0.01];
legString=strings(length(gamma),1);
for i =1:length(legString)  
    legString(i)=strcat("OT-gravity \gamma= ",num2str(gamma(i)));
end

F_score1=2*REC_1.*PREC_1./(REC_1+PREC_1);
F_score2=2*REC_2.*PREC_2./(REC_2+PREC_2);
F_score3=2*REC_3.*PREC_3./(REC_3+PREC_3);
F_scoreC=2*REC_C.*PREC_C./(REC_C+PREC_C);
figure
for k=1:3
    subplot(3,1,k)
    bar([(F_score1(:,k)-F_scoreC(:,k))./F_scoreC(:,k)*100,...
        (F_score2(:,k)-F_scoreC(:,k))./F_scoreC(:,k)*100,...
        (F_score3(:,k)-F_scoreC(:,k))./F_scoreC(:,k)*100])
    title(tt(k))
    ylabel('% \Delta F1-score')
    legend(legString,'Location','best')
   axis tight
   grid on
set(findall(gcf,'-property','FontSize'),'FontSize',12)
axis tight
grid on
xticks(1:length(Tempi))
xticklabels(Tempi)
end
colororder("sail")

figure
subplot(3,1,1)
bar([Within(:,1),Between(:,1)])
axis tight
grid on
set(findall(gcf,'-property','FontSize'),'FontSize',11)
legend('Within','Between')
xticks(1:length(Tempi))
xticklabels(Tempi)
title('Euclidean')

subplot(3,1,2)
bar([Within(:,2),Between(:,2)])
axis tight
grid on
set(findall(gcf,'-property','FontSize'),'FontSize',11)
legend('Within','Between')
xticks(1:length(Tempi))
xticklabels(Tempi)
title('Cosine')

subplot(3,1,3)
bar([Within(:,3),Between(:,3)])
axis tight
grid on
set(findall(gcf,'-property','FontSize'),'FontSize',11)
legend('Within','Between')
xticks(1:length(Tempi))
xticklabels(Tempi)
title('Correlation')

% Initialize table variables
TestNames = ["Kolmogorov-Smirnov", "t-test", "Mann-Whitney U"];
Columns = ["Euclidean", "Cosine", "Correlation"];
Stats = zeros(3,3);
P_values = zeros(3,3);

% Perform tests for each variable
for i = 1:3
    % Kolmogorov-Smirnov test
    [~, P_values(1,i), ks_stat] = kstest2(Within(:,i), Between(:,i));
    Stats(1,i) = ks_stat;  % KS test statistic (max difference between CDFs)
    
    % Two-sample t-test
    [~, P_values(2,i), ~, stats_t] = ttest2(Within(:,i), Between(:,i));
    Stats(2,i) = stats_t.tstat;  % Store t-test statistic
    
    % Mann-Whitney U test
    [P_values(3,i), ~, stats_u] = ranksum(Within(:,i), Between(:,i));
    Stats(3,i) = stats_u.ranksum; % Store Mann-Whitney U statistic
end

% Reshape data to have statistics in odd rows and p-values in even rows
TableData = [Stats(1,:); P_values(1,:);...
    Stats(2,:); P_values(2,:);...
    Stats(3,:); P_values(3,:)];

% Create row labels (Alternating statistic and p-value)
RowLabels = reshape([TestNames + " Statistic"; TestNames + " p-value"], [], 1);

% Create table
ResultsTable = array2table(TableData, ...
    'VariableNames', Columns, ...
    'RowNames', RowLabels);

% Display results
disp(ResultsTable)
