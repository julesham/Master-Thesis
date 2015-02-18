%% Measurement Of BLA

DUT = 'SYS_WH';
%%%%
% Design of Input Signal
%%%%
N = 1024;
% Band Of Interest
fmaxBLA = 1/5; % Excited frequency / f_nyquist
F_BLA = floor(fmaxBLA*N/2);
ExcitedHarmBLA = 1:F_BLA;

AmplitudeSpectrum = zeros(N,1);
AmplitudeSpectrum(ExcitedHarmBLA+1) = 1;

% % Tickler
AmplitudeSpectrumT = zeros(N,1);
AmplitudeSpectrumT(ExcitedHarmBLA+1) = 1;
TickledHarm = (F_BLA+1):(N/2-1);
AmplitudeSpectrumT(TickledHarm+1) = 0;
ExcitedHarmBLAT = union(ExcitedHarmBLA,TickledHarm);
F_BLAT = max(ExcitedHarmBLA);

%%%
% Parameters BLA Measurement
%%%

T = 1;                                  % Transients Periods
P = 2;                                  % number of consecutive periods multisine
M = 25;                                % number of independent repeated experiments

%%%
% Measure BLA
%%%

[BLA,~,~,~]  = measureBLA(DUT,ExcitedHarmBLA,AmplitudeSpectrum,N,T,P,M);
[BLAT,~,~,~]  = measureBLA(DUT,ExcitedHarmBLAT,AmplitudeSpectrumT,N,T,P,M);

figure;
x1 = ExcitedHarmBLA/N;
x2 = ExcitedHarmBLAT/N;
plot(x1,db(BLA.mean),x2,db(BLAT.mean),x1,db(BLA.mean-BLAT.mean(ExcitedHarmBLA)));

