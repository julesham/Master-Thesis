%%%
% Simulation of ILC using BLA
% Jules Hammenecker, Vrije Universiteit Brussel
%%%

clear; close all; clc; tic;
 startupK6
% VXI_Init
%  cd('Z:\MA2\Master Thesis');
% pause;
%% Definitions
% Definition of time 
N = 4096;       % DEFAULT 2^12 , if changed, also change in VXI System Parameters

% Definition of System
% DUT = 'SYS_VXI';          % Actuates the system
% DUT = 'SYS_WH';           % Simulation
% DUT = 'SYS_SNL';          % Simulation
DUT = 'SYS_W';             % Simulation

% Frequency bands of interest
rmsInput = 0.5;
fmaxBLA = 1/5;  % Excited frequency / f_nyquist
fmaxILC = 1/10; % Excited frequency / f_nyquist

% BLA Parameters
T = 1;  % Transients Periods
P = 2;  % number of consecutive periods multisine
M = 10; % number of independent repeated experiments

% ILC Parameters
iterationsILC = 10;
ilcM = 10; % Number of realizarions to measure ILC'er

fs = 10e6/2^2;
ts = 1/fs;
t0 = N*ts;
f0 = 1/t0;

fprintf('Expected Measurement Time :\nBLA : %g sec \nILC : %g sec ',M*(T+P)*t0,iterationsILC*(T+P)*t0)
%% Measurement Of BLA

%%%%
% Design of Input Signal
%%%%
% Band Of Interest
F_BLA = floor(fmaxBLA*N/2);
ExcitedHarmBLA = (1:F_BLA).';

%%%
% Measure BLA
%%%

fprintf('Starting BLA Measurement..\n');

[Uall,Yall,Rall,U_ref_all,transientError,BLA_Measurements] = measureBLA(DUT,ExcitedHarmBLA,rmsInput,N,T,P,M);

% Analysis of BLA

[BLA_IO,Y_BLA,U_BLA,~] = Robust_NL_Anal(Yall, Uall,Rall);   % Input -> output BLA
BLA_RO = Robust_NL_Anal(Yall,U_ref_all);                    % Reference -> output BLA

plotBLA;shg;
save('BLA_Info')
%% ILC
fprintf('Starting ILC Compensation..\n');

%%%
% Create Desired Output (BLA*MS)
%%%

FRF = BLA_RO.mean;                  % FRF used to compute ideal response and used in ILC algo
F = floor(fmaxILC*N/2);            % Max frequency bin
ExcitedHarmILC = (1:F).';          % Select all freq bins from 1 - F
%%% Measure u -> uj parameters
 ilc_DPD.u_ref = nan(ilcM,2,N);
 ilc_DPD.uj = nan(ilcM,2,N);
 ilc_DPD.yj = nan(ilcM,2,N);
for ii = 1:ilcM 
  
    u_ref = rmsInput*CalcMultisine(ExcitedHarmILC, N);  % reference input
        if strcmp(DUT,'SYS_VXI')
            while max(abs(u_ref)) > 5
                warning('Overloading System, recomputing Multisine. ');
                u_ref = rmsInput*CalcMultisine(ExcitedHarmILC, N);  % reference input
            end
        end

    y_ref = filterFRF(FRF,ExcitedHarmBLA,u_ref);% filter trough BLA

    %%%
    % ILC Learning Phase 
    %%%
    [uj,yj,y1,meanError,e,ILC_Measurements] = ilcFRF(DUT,y_ref,u_ref,iterationsILC,FRF,T,ExcitedHarmILC,ExcitedHarmBLA);

    ilc_DPD.u_ref(ii,:,:) = repmat(u_ref.',2,1);
    ilc_DPD.uj(ii,:,:)= repmat(uj.',2,1);
    ilc_DPD.yj(ii,:,:) = repmat(yj.',2,1);
end

U_ref = fft(ilc_DPD.u_ref,[],3)/sqrt(N);
Uj    =  fft(ilc_DPD.uj,[],3)/sqrt(N);
U_ref = U_ref(:,:,ExcitedHarmILC+1);
Uj = Uj(:,:,ExcitedHarmILC+1);

BLA_DPD = Robust_NL_Anal(Uj,U_ref); 
% Figures and Plots
plotILC; shg;

% Print Text Info  
printOutput;

% Dump (hihi) workspace when measuring with VXI
if strcmp(DUT,'SYS_VXI') % if we are measuring
    filename = 'PA';
    dumpWorkspace;
end