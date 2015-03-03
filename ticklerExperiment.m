%% Measurement Of BLA
clc; clear; close all;
DUT = 'SYS_WH';
%%%%
% Design of Input Signal
%%%%
N = 1024;
% Band Of Interest
fmaxBLA = 1/5; % Excited frequency / f_nyquist
F_BLA = floor(fmaxBLA*N/2);
ExcitedHarmBLA = (1:F_BLA).';

AmplitudeSpectrum = ones(F_BLA,1);

% % Tickler
TickledHarm =  ( (F_BLA+1):floor(N/2-1) ).';                                % rest of band
AmplitudeSpectrumT = zeros(length(TickledHarm)+length(ExcitedHarmBLA),1);   % init

AmplitudeSpectrumT(ExcitedHarmBLA) = 1;
AmplitudeSpectrumT(TickledHarm)    = 1e-2;
ExcitedHarmBLAT = [ExcitedHarmBLA ; TickledHarm];

% Adapt Tickler such that band of interest has the same energy
%%%
% Parameters BLA Measurement
%%%

T = 2;                                  % Transients Periods
P = 2;                                  % number of consecutive periods multisine
M = 1e2;                                % number of independent repeated experiments

%%%
% Measure BLA
%%%

[BLA,~,~,~]  = measureBLA(DUT,ExcitedHarmBLA,AmplitudeSpectrum,N,T,P,M);
[BLAT,~,~,~]  = measureBLA(DUT,ExcitedHarmBLAT,AmplitudeSpectrumT,N,T,P,M);

figure;
x1 = ExcitedHarmBLA/N;
x2 = ExcitedHarmBLAT/N;
plot(x1,db(BLA.mean),'.',x2,db(BLAT.mean),'.',x1,db(BLA.mean-BLAT.mean(ExcitedHarmBLA)));
legend('BLA without tickler','with tickler','difference');
