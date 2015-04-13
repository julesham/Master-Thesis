%%%
% Simulation of ILC using BLA
% Jules Hammenecker, Vrije Universiteit Brussel
%%%

clear; close all; clc; tic; 
% startupK6;
% VXI_Init
% cd('Z:\MA2\Master Thesis\matlab');
% pause;

%% Definitions

% Definition of System

% DUT = 'SYS_VXI';          % Actuates the system
DUT = 'SYS_WH';           % Simulation
% DUT = 'SYS_SNL';          % Simulation
% DUT = 'SYS_W';             % Simulation

BLAMeasurementEnabled = true;

% Definition of time 
time.N = 4096;       % DEFAULT 2^12 , if changed, also change in VXI System Parameters
time.fs = 10e6/2^2;

% Frequency bands of interest (Normalised with respect to Nyquist Freq) and
% rms

rmsInput = 0.3; fmaxBLA = 1/5;  
% rmsInput = 0.5; fmaxBLA = 1/5;  

% Global Measurements Parameters 
T = 1;  % Transients Periods
P = 2;  % number of consecutive periods multisine

% BLA Measurement Parameters
M = 10; % number of independent repeated experiments


% Derived Parameters
time.ts = 1/time.fs;
time.t0 = time.N*time.ts;
time.f0 = 1/time.t0;


    %% Measurement Of BLA
    
    % Without Tickler
    ExcitedHarmBLA = (1: floor(fmaxBLA*time.N/2) ).';
    AmplitudeSpectrum = ones(size(ExcitedHarmBLA));
    % With Tickler
%     ExcitedHarmBLA = ( 1:floor(time.N/2)-1 ).';
%     NmaxBLA = floor( fmaxBLA*time.N/2 );
%     AmplitudeSpectrum = [ones(NmaxBLA,1); db2mag(-20)*ones(max(ExcitedHarmBLA)-NmaxBLA,1)];
    % 3 cases Possible : 
    % 1) Measurement is enabled : BLA is measured and data is saved
    % 2) Measurement is not enabled and it's the VXI : user has to choose
    % BLA data to use
    % 3) Other : Error

    if BLAMeasurementEnabled
        fprintf('Starting BLA Measurement..\n');
        [BLA_Measurements] = measureBLA(DUT,ExcitedHarmBLA,AmplitudeSpectrum,rmsInput,time.N,T,P,M);
        
        if strcmp(DUT,'SYS_VXI')
            
            filenameBLA = ['BLA_PA_',datestr(now,'dd_mmm_HH'),'h',datestr(now,'MM')];
            save(filenameBLA,'time','BLA_Measurements');
        end
        
    elseif strcmp(DUT,'SYS_VXI') % if BLA Measurement is not enabled, choose a measurement file.
            clear;
            filenameBLA = uigetfile('*.mat','Select the BLA you want to use for ILC Compensation.');
            load(filenameBLA);
    else
        error('No data available to create BLA.')
    end % if BLAMeasurementEnabled

    %%%
    % Processing Measurements (FOR ALL CASES)
    %%%

    % Process the raw data
    [Yall,Uall,Rall,U_ref_all]  = processBLAMeasurements(BLA_Measurements); 

    % Compute Input -> output BLA
    [BLA_IO,Y_BLA,U_BLA,CYU]    = Robust_NL_Anal(Yall, Uall,Rall); 

    % Compute Reference -> output BLA
    BLA_RO                      = Robust_NL_Anal(Yall,U_ref_all);           

    plotBLA;shg;    % Plot


%  naBla = 4;
%  nbBla = 2;
% [B, A, Cost] = estimateParamBLA(BLA_RO,ExcitedHarmBLA,time.N,naBla,nbBla);

%% ILC
fprintf('Starting ILC Compensation..\n');

% ILC Measurement Parameters

fmaxILC = 1/20; % Best for Simulations
% fmaxILC = 1/10; % Better for VXI

iterationsILC = 10;
ilcM = 7; % Number of realisations to measure ILC'er
rmsInput = BLA_Measurements.rms;
DUT = BLA_Measurements.DUT;
%%%
% Create Desired Output (BLA*MS)
%%%

F = floor(fmaxILC*time.N/2);        % Max frequency bin
ExcitedHarmILC = (1:F).';           % Select all freq bins from 1 - F
 ILC_Measurements.BLAInfo.ExcitedHarmBLA= BLA_Measurements.ExcitedHarm;
 ILC_Measurements.BLAInfo.BLA_RO       = BLA_RO;
 ILC_Measurements.DUT           = DUT;
 ILC_Measurements.ExcitedHarmILC= ExcitedHarmILC;
 ILC_Measurements.ilcM          = ilcM;
 ILC_Measurements.T             = BLA_Measurements.T;
 ILC_Measurements.iterations    = iterationsILC;
 ILC_Measurements.u_ref         = nan(ilcM,time.N);
 ILC_Measurements.y_ref         = nan(ilcM,time.N);
 ILC_Measurements.um            = nan(ilcM,iterationsILC,time.N);
 ILC_Measurements.uj            = nan(ilcM,iterationsILC,time.N);
 ILC_Measurements.yj            = nan(ilcM,iterationsILC,time.N);
 ILC_Measurements.error = nan(ilcM,iterationsILC,time.N);
 
for mm = 1:ilcM 
    fprintf('Starting ILC Realisation %g/%g\n',mm,ilcM)
    u_ref = rmsInput*CalcMultisine(ExcitedHarmILC, time.N);  % reference input
        if strcmp(DUT,'SYS_VXI')
            while max(abs(u_ref)) > 5
                warning('Overloading System, recomputing Multisine. ');
                u_ref = rmsInput*CalcMultisine(ExcitedHarmILC, time.N);  % reference input
            end
        end

    y_ref = filterFRF(BLA_RO.mean,ExcitedHarmBLA,u_ref);% filter trough BLA

    ILC_Measurements.u_ref(mm,:) = u_ref;
    ILC_Measurements.y_ref(mm,:) = y_ref;
    %%%
    % ILC Learning Phase 
    %%%
    [ILC_Measurements] = ilcFRF(ILC_Measurements,mm);
% uj,yj,y1,meanError,e,ILC_Measurements
    
end



% Figures and Plots
plotILC; shg;

% Print Text Info  
printOutput;

% Dump (hihi) workspace when measuring with VXI
if strcmp(DUT,'SYS_VXI') % if we are measuring
     filename = ['ILC_PA_',datestr(now,'dd_mmm_HH'),'h',datestr(now,'MM')];
     save(filename,'time','ILC_Measurements','filenameBLA');

end