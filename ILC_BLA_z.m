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
% DUT = 'SYS_SNL';

%% Measurement Of BLA

%%%%
% Design of Input Signal
%%%%
% Band Of Interest
fmaxBLA = 1/5; % Excited frequency / f_nyquist
F_BLA = floor(fmaxBLA*N/2);
ExcitedHarmBLA = 1:F_BLA;

AmplitudeSpectrum = zeros(N,1);
AmplitudeSpectrum(ExcitedHarmBLA+1) = 1;

% % Tickler

% TickledHarm = (F_BLA+1):(N/2-1);
% AmplitudeSpectrum(TickledHarm+1) = 1e-4;
% ExcitedHarmBLA = union(ExcitedHarmBLA,TickledHarm);
% F_BLA = max(ExcitedHarmBLA);

%%%
% Parameters BLA Measurement
%%%
T = 1;                                  % Transients Periods
P = 2;                                  % number of consecutive periods multisine
M = 25;                                % number of independent repeated experiments

%%%
% Measure BLA
%%%

[BLA,Y_BLA,U_BLA,transientError]  = measureBLA(DUT,ExcitedHarmBLA,AmplitudeSpectrum,N,T,P,M);

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
    
%%%
% Estimate BLA Parameters in z domain
%%%

naBla = 4;  % # of poles 
nbBla = 4;  % # of zeros

[B_BLA, A_BLA, Cost] = estimateBLA(BLA,ExcitedHarmBLA,N,naBla,nbBla);

% Validation of result

z = exp(1j*2*pi*ExcitedHarmBLA/N);
estBLA = polyval(B_BLA,z)./polyval(A_BLA,z);

figure;
freq = ExcitedHarmBLA/N;
plot(freq,db(estBLA),freq,db(BLA.mean),freq,db(estBLA-BLA.mean));
legend('Estimated BLA', 'FRF','');
%% ILC

iterationsILC = 5e2;

% Make Desired Output by passing an input trough BLA
fmax = 1/200; % Excited frequency / f_nyquist
F = floor(fmax*N/2);
ExcitedHarm = 1:F;
u_ref = CalcMultisine(ExcitedHarm, N).';

U = fft(u_ref);

Y_ref = zeros(1,N);
Y_ref(2:F_BLA+1) = BLA.mean.*U(2:F_BLA+1);
y_ref = 2*real(ifft(Y_ref)); % desired output

uj = u_ref; % first try
invG = BLA.mean.^-1;

meanError = zeros(1,iterationsILC);
for i = 1:iterationsILC
        clc;
        fprintf('%g %%\n',i/iterationsILC*100);
        
        yj = feval(DUT,uj);
        % Compute error
        e = y_ref-yj;
        meanError(i) = mean(e.^2);
        % ILC rule : u_j+1 = u_j + G_BLA^-1*ej;
        E = fft(e);
        dU = zeros(1,N);
        dU(2:F_BLA+1) = invG.*E(2:F_BLA+1);
        du = 2*real(ifft(dU)); 
        Q  = 1; L =  1;
        uj = Q*(uj + L*du);
       
end

%% Time Domain Plots  
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
    plot(db(fft(y_ref)/N),'-');
    plot(db(fft(yj)/N),'.');
    xlabel('freq'); ylabel('Amplitude');
    legend('y_d','yj');
    title('Comparison y_d and y_j ');

subplot(212);
    plot(db(fft(e)),'.'); xlabel('freq'); ylabel('error');
    title('y_d - y_j') ;
 %% Print Outputs  
   
fprintf('System used = %s \n',DUT);  
fprintf('MSE between periods of y = %E\n',transientError);  
fprintf('L = %g \nMSE : %g dB \n',L,db(meanError(end)));  
fprintf('Script ended in %g sec.\n',toc);