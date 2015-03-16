
%%%
% Simulation of ILC using BLA
% Jules Hammenecker, Vrije Universiteit Brussel
%%%

clear; close all; clc; tic;
%% Definitions
% Definition of time 
N = 2^14;       % Datapoints
% Definition of System

 DUT = 'SYS_WH';
%DUT = 'SYS_SNL';
% DUT = 'SYS_W' 

%% Measurement Of BLA

%%%%
% Design of Input Signal
%%%%

% Band Of Interest
fmaxBLA = 1/5; % Excited frequency / f_nyquist
F_BLA = floor(fmaxBLA*N/2);
ExcitedHarmBLA = (1:F_BLA).';
AmplitudeSpectrum = ones(F_BLA,1);  % Uniform Spectrum

%%%
% Parameters BLA Measurement
%%%
T = 2;                                  % Transients Periods
P = 2;                                  % number of consecutive periods multisine
M = 50;                                 % number of independent repeated experiments

%%%
% Measure BLA
%%%

[BLA,Y_BLA,U_BLA,transientError]  = measureBLA(DUT,ExcitedHarmBLA,AmplitudeSpectrum,N,T,P,M);
% [BLAT,YT_BLA,UT_BLA,transientErrorT]  = measureBLA_Tickler(DUT,ExcitedHarmBLA,AmplitudeSpectrum,N,T,P,M);
ExcitedHarmTickler = 1:N/2-1;
% % 
% figure;
% hold all;
% plot(db(BLA.mean));     plot(db(BLA.stdNL.^2));
% plot(db(BLAT.mean));    plot(db(BLAT.stdNL.^2));
% plot(db(BLA.mean-BLAT.mean(ExcitedHarmBLA)));
% legend('w/o tickler','w/o tickler total var','w/ tickler','w/ tickler var','complex difference')
%%%
% Estimate BLA Parameters in z domain
%%%
% 
% naBla = 4;  % # of poles 
% nbBla = 4;  % # of zeros
% 
% [B_BLA, A_BLA, Cost] = estimateBLA(BLA,ExcitedHarmBLA,N,naBla,nbBla);
% 
% % Validation of result
% 
% z = exp(1j*2*pi*ExcitedHarmBLA/N);
% estBLA = polyval(B_BLA,z)./polyval(A_BLA,z);

%% ILC
% Desired output = multisine trough BLA (no NL dist)

fmax = 1/20;               % Excited frequency / f_nyquist
F = floor(fmax*N/2);        % Max frequency bin
ExcitedHarmILC = 1:F;          % Select all freq bins from 1 - F
u_ref = CalcMultisine(ExcitedHarmILC, N).';

FRF = BLA.mean;
F_BLA = length(FRF);
U = fft(u_ref);
Y_ref = zeros(1,N);
Y_ref(2:F_BLA+1) = FRF.*U(2:F_BLA+1);
y_ref = 2*real(ifft(Y_ref)); % desired output

% ILC Parameters
 Q = 1; L = 1;
 iterationsILC = 100;
 
% Test of stability
z = exp(1j*2*pi*ExcitedHarmBLA/N);
zLP = z.*L.*FRF.';
stdF = BLA.stdNL.*Q*L; % standard deviation of Q(1-zLP)

figure('name','ILC Stability and Performance');
freq = ExcitedHarmBLA/N;
subplot(2,2,1:2);
hold all;
plot(freq,db(Q*(1-zLP)));
plot([min(freq) max(freq)], db([1 1]));
plot(freq,db(stdF));
legend('Q(1-zLP)','0 dB line');


% Performance
Einf = zeros(N,1);
Einf(ExcitedHarmBLA+1) = (1-Q)/(1-Q*(1-zLP)).*Y_ref(ExcitedHarmBLA+1);
subplot(2,2,3); stem((0:N-1)/N,db(Einf)); title('E_{\infty} ');
subplot(2,2,4); plot(0:N-1,real(ifft(Einf))); title('e_{\infty} ');


[uj,yj,meanError,e] = ilcFRF(DUT,y_ref,u_ref,iterationsILC,Q,L,BLA.mean);

%  [uj,yj,meanError,e] = ilcFRF(DUT,y_ref,u_ref,iterationsILC,Q,L,BLAT.mean);

%% Figures
figure;
subplot(2,2,1:2);
    hold all;
    x = ExcitedHarmBLA/N;
    plot(x,db(BLA.mean),'k',x,db(BLA.stds),'b');
    plot(x,db(BLA.stdNL),'r',x,db(BLA.stdn),'g');
    legend('BLA','NL w.r.t one real','total variance','noise variance','location','BestOutside')
subplot(2,2,3);
    hold all;
    x = ExcitedHarmBLA/N;
    plot(x,db(U_BLA.mean),'k',x,db(U_BLA.stdNL),'r');
    title('Input Spectrum')
subplot(2,2,4);
    hold all;
    x = ExcitedHarmBLA/N;
    plot(x,db(Y_BLA.mean),'k',x,db(Y_BLA.stdNL),'r');
    title('Output Spectrum')
    
% figure;
% freq = ExcitedHarmBLA/N;
% plot(freq,db(estBLA),freq,db(BLA.mean),freq,db(estBLA.'-BLA.mean));
% legend('Estimated BLA', 'FRF','');

% Time Domain Plots  

figure;
subplot(311);
    plot(db(meanError),'x'); xlabel('Iteration'); ylabel('db(MSE)');
    title('MSE of y_d - y_j');
subplot(312); 
    hold all;
    plot(y_ref,'-');
    plot(yj,'x');
    xlabel('time'); ylabel('Amplitude');
    legend('y_d','yj');
    title('Comparison y_d and y_j ');
subplot(313);
    plot(e,'x'); xlabel('time'); ylabel('error');
    title('y_d - y_j');

%% Frequency Domain Plots  

figure;

subplot(211); hold all;
    freq = (0:N-1)/N;
    plot(freq,db(fft(y_ref)/N),'-');
    plot(freq,db(fft(yj)/N),'.');
    xlabel('freq'); ylabel('Amplitude');
    legend('y_d','yj');
    title('Comparison y_d and y_j ');

subplot(212);
    plot(freq,db(fft(e)/sqrt(N)),'.'); xlabel('freq'); ylabel('error');
    title('y_d - y_j') ;
 % Print Outputs  
   
fprintf('System used = %s \n',DUT);  
fprintf('MSE between periods of y = %E\n',transientError);  
fprintf('L = %g \nMSE : %g dB \n',L,db(meanError(end)));  
E = fft(e)/sqrt(N);
MSEBLA = mean( 2*real(ifft(E(ExcitedHarmBLA+1))).^2 );
fprintf('MSE over BLA freq = %g dB \n',db(MSEBLA));
fprintf('Script ended in %g sec.\n',toc);