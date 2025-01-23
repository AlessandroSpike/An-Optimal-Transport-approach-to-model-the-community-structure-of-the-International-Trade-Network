% ========================================================================
% Gravity Model Estimation for Trade Networks
% ========================================================================
% This script estimates trade flows using different gravity model 
% specifications. It evaluates trade relationships by applying 
% Ordinary Least Squares (OLS), Poisson regression, Zero-Inflated Poisson (ZIP), 
% and Fixed Effects models, including binned fixed effects.
%
% The script performs the following tasks:
% - Loads processed trade data from 'DatiProcessati.mat'.
% - Defines the gravity model type (OLS, Poisson, ZIP, Fixed, Fixed Bin).
% - Iterates through years, estimating gravity models for each period.
% - Computes trade flow predictions and extracts model coefficients.
% - Computes standard errors using Conley standard error correction.
% - Saves regression results, including fitted trade matrices.
%
% ------------------------------------------------------------------------
% Usage:
% - Ensure 'DatiProcessati.mat' is available in the 'Data' folder.
% - Run the script in MATLAB.
% ------------------------------------------------------------------------
%
% Outputs:
% - Estimated coefficients for each gravity model type.
% - Fitted trade matrices over time.
% - Standard errors computed using Conley correction.
% - Processed covariates and country-specific trade data.
%
% Additional Features:
% - Supports multiple gravity model specifications.
% - Uses R scripts for ZIP and Fixed Effects estimation.
% - Removes invalid observations (e.g., infinite values).
% - Saves final results in '[GravType]_RegressionResults.mat'.
%
% ========================================================================

clc; clearvars; close all; 
%% addpath
addpath('Data')
addpath('Utilities')
%% read data
load DatiProcessati.mat
%% gravity type
GravType='FIXED_BIN'; %OLS POISSON ZIP FIXED FIXED_BIN
%% Contenitori
Coefficienti=nan(15,length(Anni)-1);
StandardErr=nan(15,length(Anni)-1);
NodiFin=cell(length(Anni)-1,1);
MatriciFit=cell(length(Anni)-1,1);
MatriciTrade=cell(length(Anni)-1,1);
Covariate=cell(length(Anni)-1,2);
%% main loop
for t=1:length(Anni)-1
    disp(Anni(t))
    % prepare data
    [Y,X,Adj,PaeExp,PaeImp,Nodi,distanza] = filter_and_prepare_data(MatriceEx, MatriceTardeAgg, ...
        GDP, Popolazione, Area, LandLock, MatriceColonial, ...
        MatriceCommonLanguage, MatriceContiguity, ...
        MatriceDistanza, MatriceValuta, PaesiBaci, t);
    % regressions
    switch GravType
        case 'OLS'
            Y1=log(Y);
            X1=X;
            tolgo1=isinf(Y1);
            Y1(tolgo1)=0;
            X1(tolgo1,:)=0; 
            modello = fitlm(X1,Y1);
            yhat1=predict(modello,X);
            yhat1(yhat1<0)=0;
            yhat=reshape(exp(yhat1),size(Adj));
            yhat=yhat-diag(diag(yhat));
            Coefficienti(:,t)=table2array(modello.Coefficients(1:15,1));

            conley_se = compute_conley_se1(Y1, yhat1, X, PaeExp, PaeImp, distanza);
            StandardErr(:,t)=conley_se;
        case 'POISSON'
            Y1=(Y);
            X1=X;
            tolgo1=isinf(sum(X,2));
            Y1(tolgo1)=[];
            X1(tolgo1,:)=[]; 
            modello = fitglm(X1,Y1,'Distribution','poisson');
            yhat1=predict(modello,X);
            yhat=reshape(yhat1,size(Adj));
            yhat=yhat-diag(diag(yhat));
            Coefficienti(:,t)=table2array(modello.Coefficients(1:15,1));

            conley_se = compute_conley_se2(Y, yhat1, X, PaeExp, PaeImp, distanza);
            StandardErr(:,t)=conley_se;
       case 'ZIP'
            writetable(array2table([round(Y) X]),'DatiR.csv') 
            RunRcode('E:\NullModel\Codici\final\FinalMagari\Soc_Net\Utilities\ZIP1.R')
            pause(.5)
            Coeff=readtable('Coeff.csv');
            Coefficienti(:,t)=table2array(Coeff(1:15,2)); 
            yhat_aus=readtable('Fit.csv');
            yhat1=yhat_aus.x;
            yhat=reshape(yhat1,size(Adj));
            yhat=yhat-diag(diag(yhat));
            conley_se = compute_conley_se2(Y, yhat1, X, PaeExp, PaeImp, distanza);
            StandardErr(:,t)=conley_se;
            pause(.5)
            delete Fit.csv
            delete Coeff.csv
            delete DatiR.csv
      case 'FIXED' 
            aus1=array2table([PaeExp,PaeImp]);
            aus1.Properties.VariableNames={'Exp','Imp'};
            writetable([aus1,array2table([round(Y) X])],'DatiR.csv')
            RunRcode('E:\NullModel\Codici\final\FinalMagari\Soc_Net\Utilities\PPML_R.R') 
            pause(.5)
            yhat_aus=readtable('Fit.csv');
            yhat1=yhat_aus.x;
            yhat=reshape(yhat1,size(Adj));
            yhat=yhat-diag(diag(yhat));
            Coeff=readtable('Coeff.csv');
            posit=char(string(Coeff.Var1));
            posit(:,1:3)=[];
            posit=str2double(string(posit));
            Coefficienti(posit,t)=table2array(Coeff(:,2));
            conley_se = compute_conley_se3(Y, yhat1, X, PaeExp, PaeImp, distanza,posit);
            StandardErr(posit,t)=conley_se;
            pause(.5)
            delete Fit.csv
            delete DatiR.csv        
            delete Coeff.csv
        case 'FIXED_BIN'
            aus1=array2table([PaeExp,PaeImp]);
            aus1.Properties.VariableNames={'Exp','Imp'};
            writetable([aus1,array2table([round(Y) X])],'DatiR.csv')
            RunRcode('E:\NullModel\Codici\final\FinalMagari\Soc_Net\Utilities\PPML_R2.R') 
            pause(.5)
            yhat_aus=readtable('Fit.csv');
            yhat1=yhat_aus.x;
            yhat=reshape(yhat1,size(Adj));
            yhat=yhat-diag(diag(yhat));
            Coeff=readtable('Coeff.csv');
            posit=char(string(Coeff.Var1));
            posit(:,1:3)=[];
            posit=str2double(string(posit));
            Coefficienti(posit,t)=table2array(Coeff(:,2));

            conley_se = compute_conley_se4(Y, yhat1, X, PaeExp, PaeImp, distanza,posit);
            StandardErr(posit,t)=conley_se;

            pause(.5)
            delete Fit.csv
            delete DatiR.csv        
            delete Coeff.csv        
    end
    NodiFin{t}=Nodi;
    MatriciTrade{t}=Adj;
    MatriciFit{t}=yhat;
    Covariate{t,1}=X;
    Covariate{t,2}=Y;
end
%% save all
filename=([GravType,'_RegressionResults.mat']);
save(filename,'NodiFin','MatriciTrade',...
    'MatriciFit','Coefficienti','StandardErr','Covariate')