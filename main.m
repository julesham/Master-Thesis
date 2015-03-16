%%%
% Simulation of ILC using BLA
% Jules Hammenecker, Vrije Universiteit Brussel
%%%


clear; close all; clc; tic;
% startupK6
% VXI_Init
%% Definitions
% Definition of time 
N = 2^12;       % DEFAULT 2^12 , if changed, also change in VXI System Parameters

% Definition of System
DUT = 'SYS_VXI'; 
% DUT = 'SYS_WH';
% DUT = 'SYS_SNL';
% DUT = 'SYS_W' 

% Frequency bands of interest
rms = 0.3;
fmaxBLA = 1/5;  % Excited frequency / f_nyquist
fmaxILC = 1/20; % Excited frequency / f_nyquist

% BLA Parameters
T = 2;  % Transients Periods
P = 2;  % number of consecutive periods multisine
M = 10; % number of independent repeated experiments

% ILC Parameters
iterationsILC = 10;
 
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
% [BLA_IO,BLA_RO,Y_BLA,U_BLA,transientError,BLA_Measurements]  = measureBLA(DUT,ExcitedHarmBLA,rms,N,T,P,M);
[Uall,Yall,Rall,U_ref_all,transientError,BLA_Measurements] = measureBLA(DUT,ExcitedHarmBLA,rms,N,T,P,M);

%% Analysis of BLA

[BLA_IO,Y_BLA,U_BLA,~] = Robust_NL_Anal(Yall, Uall,Rall);   % Input -> output BLA
BLA_RO = Robust_NL_Anal(Yall,U_ref_all);                    % Reference -> output BLA

%% ILC
fprintf('Starting ILC Compensation..\n');

%%%
% Create Desired Output (BLA*MS)
%%%

F = floor(fmaxILC*N/2);            % Max frequency bin
ExcitedHarmILC = (1:F).';          % Select all freq bins from 1 - F

u_ref = rms*CalcMultisine(ExcitedHarmILC, N);

    FRF = BLA_RO.mean.';
    U = fft(u_ref);
    Y_ref = zeros(N,1);
    Y_ref(ExcitedHarmBLA+1) = FRF.*U(ExcitedHarmBLA+1);

y_ref = 2*real(ifft(Y_ref)); % desired output

%%%
% ILC Learning Phase 
%%%

 Q = 1; L = 1;

[uj,yj,y1,meanError,e,ILC_Measurements] = ilcFRF(DUT,y_ref,u_ref,iterationsILC,Q,L,BLA_RO.mean,T);


%% Figures and Plots

mainPlots;

% Print Outputs  
   
fprintf('System used = %s \n',DUT);  
fprintf('MSE between periods of y = %E\n',transientError);  
fprintf('Iterations ILC = %g \n',iterationsILC);  
E = fft(e)/sqrt(N);
MSEBLA = mean( 2*real(ifft(E(ExcitedHarmBLA+1))*sqrt(N)).^2 );
fprintf('MSE over BLA freq = %g dB \n',db(MSEBLA));
fprintf('Script ended in %g sec.\n',toc);

%% Dump (hihi) workspace when measuring
if strcmp(DUT,'SYS_VXI') % if we are measuring
    ii = 0;
    while exist(['measurement',num2str(ii),'.mat'],'file') == 2 % If file exists
        ii = ii+1; 
    end % Don't Overwrite Existing File
    dateAndTime = datestr(now);
    save(['measurement',num2str(ii)]);
end