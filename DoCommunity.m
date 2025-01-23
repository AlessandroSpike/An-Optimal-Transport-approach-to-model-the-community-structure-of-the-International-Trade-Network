% ========================================================================
% Optimal Transport and Modularity Analysis in Trade Networks
% ========================================================================
% This script analyzes trade networks using modularity-based community 
% detection and optimal transport (OT) methods. It evaluates how community 
% structures change over time and compares classical modularity to OT-based 
% modularity.
%
% The script performs the following tasks:
% - Loads trade network data from 'POISSON_RegressionResults.mat'.
% - Defines the entropy regularization parameters (gamma) for OT.
% - Computes modularity scores for classical and OT-based methods.
% - Evaluates community structure differences using mutual information 
%   and variation of information metrics.
% - Generates visualizations of modularity, information metrics, and 
%   community distributions.
%
% ------------------------------------------------------------------------
% Usage:
% - Ensure 'POISSON_RegressionResults.mat' is available in the 'Data' folder.
% - Run the script in MATLAB.
% ------------------------------------------------------------------------
%
% Outputs:
% - Modularity scores for classical and OT-based methods.
% - Community partitions over time.
% - Comparison metrics: Mutual Information and Variation of Information.
% - Graphical representations of modularity and community structure.
%
% Additional Features:
% - Implements entropy-regularized OT via the Sinkhorn algorithm.
% - Uses directed modularity maximization for community detection.
% - Compares OT-based and classical modularity using violin plots.
% - Highlights differences in community structure with information metrics.
%
% ========================================================================
clc; clearvars; close all
%% addpath
addpath('Utilities')
addpath('Data')
%% read results
load POISSON_RegressionResults.mat
%% init variables
Tempi=2000:2020;
%% entropy OT
gamma=[0.0001 0.001 0.01];
%% container
ModulOT=zeros(length(Tempi),length(gamma));
Modul=zeros(length(Tempi),1);
VariationInfoMetrics=zeros(length(Tempi),length(gamma));
MutualInfoMetrics=zeros(length(Tempi),length(gamma));
PartitionOT=cell(length(Tempi),length(gamma));
Partition=cell(length(Tempi),1);
%% main loop
for t=1:length(Tempi)
    % extract adj and fitted adj by gravity
    Adj=MatriciTrade{t};
    Adj=Adj/sum(sum(Adj));
    Fitted=MatriciFit{t};
    Fitted(isnan(Fitted))=0;
    % do costs
    C=1./Fitted;
    % C(isinf(C))=0;
    %C=C-diag(diag(C));
    % do in out strength
    InStr=sum(Adj); 
    InStr=InStr/sum(InStr);
    OutStr=sum(Adj,2); 
    OutStr=OutStr/sum(OutStr);
    % trovo coupling
    for k =1:length(gamma)
        [T,a,b,Err,disto] = Sinkhorn_OT(C,gamma(k),OutStr,InStr',10^-5,100);
        % do modularity max
        [CiOT,QOT]=OTmodularity_dir(Adj,1,T);
        ModulOT(t,k)=QOT;
        PartitionOT{t,k}=CiOT;
        aa=OutStr*(InStr);
        corr(T(:),aa(:))
    end
    %classical modularity
    [Ci,Q]= modularity_dir(Adj,1);
    Modul(t)=Q;
    Partition{t}=Ci;
    for k =1:length(gamma)
        % compare
        [VIn, MIn] = partition_distance(Partition{t}, PartitionOT{t,k});
        VariationInfoMetrics(t,k)=VIn;
        MutualInfoMetrics(t,k)=MIn;
    end
    
end


%% Modularity
legString=strings(length(gamma)+1,1);
for i =1:length(legString)
    if i==length(legString)
        legString(i)="Newman-Girvan";
    else
        legString(i)=strcat("OT-gravity \gamma= ",num2str(gamma(i)));
    end

end

figure
subplot(3,1,[1 2])
plot(ModulOT,'LineWidth',1.5)
hold on
plot(Modul,'ko--','LineWidth',2)
axis tight
grid on
xticks(1:length(Tempi))
xticklabels(Tempi)
ylabel('Modularity')
title('Modularity Metric')
legend(legString,'Location','best')
set(findall(gcf,'-property','FontSize'),'FontSize',12)
subplot(3,1,3)
for i = 1:length(gamma)
    stem(Modul-ModulOT(:,i),"LineWidth", 2, "MarkerSize", 8)
    hold on
    axis tight
    grid on
    xticks(1:length(Tempi))
    xticklabels(Tempi)
    ylabel('\Delta Modularity')
end
set(findall(gcf,'-property','FontSize'),'FontSize',12)
colororder("sail")
%% information
figure
subplot(2,1,1)
plot(MutualInfoMetrics,'Marker','o','LineWidth',1.5)
title('Normalized Mutual Information')
axis tight
grid on
xticks(1:length(Tempi))
xticklabels(Tempi)
set(findall(gcf,'-property','FontSize'),'FontSize',12)
legend(legString(1:end-1),'Location','best')
ylabel('Mutual Info.')
subplot(2,1,2)
plot(VariationInfoMetrics,'Marker','o','LineWidth',1.5)
title('Normalized Variation of Information')
axis tight
grid on
xticks(1:length(Tempi))
xticklabels(Tempi)
ylabel('Variation Info.')
legend(legString(1:end-1),'Location','best')
set(findall(gcf,'-property','FontSize'),'FontSize',12)
colororder("sail")
%%
PartitionNew=cell(size(Partition));
PartitionNewOT=cell(size(PartitionOT));
for u=1:size(Partition,1)
    [GA,GB]=groupcounts(Partition{u});
    [GA,pos]=sort(GA);
    GB=GB(pos);
    B=repelem(GB,GA);
    PartitionNew{u}=B;
    for uu=1:3
         [GA,GB]=groupcounts(PartitionOT{u,uu});
        [GA,pos]=sort(GA);
        GB=GB(pos);
        B=repelem(GB,GA);
        PartitionNewOT{u,uu}=B;
    end

end


figure
tiledlayout(4,1,'TileSpacing','none')
nexttile
violin(PartitionNew','facealpha',.4,'facecolor',[0.6350 0.0780 0.1840])
axis tight
grid on
xticks(1:length(Tempi))
xticklabels(strings(size(Tempi)))
ylabel('Comm. Num.')
%TextLocation('Newman-Girvan','Location','best');
nexttile
violin(PartitionNewOT(:,1)','facealpha',.4,'facecolor',[0 0.4470 0.7410])
axis tight
grid on
ylabel('Comm. Num.')
TextLocation('OT-gravity \gamma=0.0001','Location','best');
xticks(1:length(Tempi))
xticklabels(strings(size(Tempi)))
nexttile
violin(PartitionNewOT(:,2)','facealpha',.4,'facecolor',[0.8500 0.3250 0.0980])
axis tight
grid on
ylabel('Comm. Num.')
TextLocation('OT-gravity \gamma=0.001','Location','best');
xticks(1:length(Tempi))
xticklabels(strings(size(Tempi)))
nexttile
violin(PartitionNewOT(:,3)','facealpha',.4,'facecolor',[0.9290 0.6940 0.1250])
axis tight
grid on
ylabel('Comm. Num.')
TextLocation('OT-gravity \gamma=0.01','Location','best');
xticks(1:length(Tempi))
xticklabels(Tempi)
sgtitle('Community Distributions')
set(findall(gcf,'-property','FontSize'),'FontSize',12)

