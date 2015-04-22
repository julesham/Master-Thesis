function [b,a] = draft()
%
% Measure with Tickler Tone
%
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
% BLAMeasurementEnabled = true;
% Definition of time
time.N = 4096;       % DEFAULT 2^12 , if changed, also change in VXI System Parameters
N = time.N;
time.fs = 10e6/2^2;
rmsInput = 0.3; fmaxBLA = 1/5;
% rmsInput = 0.5; fmaxBLA = 1/5;
ratioTickler = db2mag(-10);
% Global Measurements Parameters
T = 1;  % Transients Periods
P = 2;  % number of consecutive periods multisine
% BLA Measurement Parameters
M = 10; % number of independent repeated experiments


% Derived Parameters

time.ts = 1/time.fs;
time.t0 = time.N*time.ts;
time.f0 = 1/time.t0;
fmaxBLA     = floor(fmaxBLA*time.N/2);
fOutofBand  = floor(1/2*time.N)-1;


%%%
% Input Signal Parameters
%%%

ExcitedHarmBLA = (2:2:fmaxBLA)'; % even harmonics in band of interest
if iseven(fmaxBLA); fmaxBLA = fmaxBLA +1; end
ExcitedHarmOutofBand = (fmaxBLA:2:fOutofBand)';% odd harmonics out of band
ExcitedHarm = [ExcitedHarmBLA;ExcitedHarmOutofBand];
% F = length(ExcitedHarm);

%%%
% BLA Measurements 
%%%

[BLA_Measurements]      = measureBLATickler(DUT,ExcitedHarmBLA,ExcitedHarmOutofBand,rmsInput,N,T,P,M,ratioTickler);
[BLA_Measurements_BB1]  = measureBLATickler(DUT,ExcitedHarmBLA,ExcitedHarmOutofBand,rmsInput,N,T,P,M,0);
[BLA_Measurements_BB2]  = measureBLATickler(DUT,ExcitedHarmBLA,ExcitedHarmOutofBand,rmsInput,N,T,P,M,0);

%%%
% BLA Processing 
%%%

[BLA_RO_BB1,~,~] = processBLA(BLA_Measurements_BB1);
[BLA_RO_BB2,~,~] = processBLA(BLA_Measurements_BB2);
[BLA_RO,~,~]           = processBLA(BLA_Measurements);

%%%
% BLA Plots 
%%%

% plotBLA(N,ExcitedHarm,BLA_RO,U_BLA,Y_BLA);
figure;
hold all;
plot(db(BLA_RO.mean));          plot(db(BLA_RO.stds));
plot(db(BLA_RO_BB1.mean),'+');  plot(db(BLA_RO_BB1.stds),'+');
plot(db(BLA_RO_BB2.mean),'+');  plot(db(BLA_RO_BB2.stds),'+');

cI = ~isnan(BLA_RO_BB1.stds);
fprintf('Normal diff = %g ',db( norm(BLA_RO_BB1.stds(cI) - BLA_RO_BB2.stds(cI) ) ));
fprintf('BB to Tick diff = %g ',db( norm(BLA_RO_BB1.stds(cI) - BLA_RO.stds(cI) ) ));

%%%
% Model Estimation and Selection 
%%%

[b,a] = modelSelection(BLA_RO,ExcitedHarm,time.N,[0:5],[0:5]);


end
%
% Subfunctions
%
function b = iseven(x)
b = not(mod(x,2));
end