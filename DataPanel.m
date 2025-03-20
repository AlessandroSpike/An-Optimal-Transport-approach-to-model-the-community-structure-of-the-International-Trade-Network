
clc; clearvars; close all; 
%% addpath
addpath('Data')
addpath('Utilities')
%% read data
load DatiProcessati.mat
%% main loop
DD=[];
lunghezza=nan(length(Anni)-1,1);
for t=1:length(Anni)-1
    disp(Anni(t))
    % prepare data
    [Y,X,Adj,PaeExp,PaeImp,Nodi,distanza] = filter_and_prepare_data(MatriceEx, MatriceTardeAgg, ...
        GDP, Popolazione, Area, LandLock, MatriceColonial, ...
        MatriceCommonLanguage, MatriceContiguity, ...
        MatriceDistanza, MatriceValuta, PaesiBaci, t);
    lunghezza(t)=length(Adj);
    aus1=array2table([PaeExp,PaeImp]);
    aus1.Properties.VariableNames={'Exp','Imp'};
    aus2=array2table((repmat(Anni(t),size(Y))));
    aus2.Properties.VariableNames={'Anni'};
    dati=[aus1,aus2,array2table([round(Y) X])];
    DD=[DD;dati];
end
%% do regression
MatriciFit=cell(length(Anni)-1,1);
writetable(DD,'DatiRPanel.csv')
RunRcode('E:\NullModel\Codici\final\FinalMagari\Soc_Net\Utilities\PanelGravity.R') 
pause(.5)
yhat_aus=readtable('FitPanel.csv');
yhat1=yhat_aus.x;
anno=DD.Anni;
for t=1:length(Anni)-1
    yhat=reshape(yhat1(anno==Anni(t)),lunghezza(t),lunghezza(t));
    yhat=yhat-diag(diag(yhat));
    MatriciFit{t}=yhat;
end
Coeff=readtable('CoeffPanel.csv');
posit=char(string(Coeff.Var1));
posit(:,1:3)=[];
posit=str2double(string(posit));
Coefficienti(posit)=table2array(Coeff(:,2));
%% save
save('Panel.mat',"Coefficienti","MatriciFit")
