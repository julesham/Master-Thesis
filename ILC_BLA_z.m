%%%
% Simulation of ILC using BLA
% Jules Hammenecker, Vrije Universiteit Brussel
%%%

clear; close all; clc; tic;
%% Definitions

%%%
% Definition of time and frequency
%%%
N = 2^12;
time = 0:N-1;
normFreq = time/N;
normAngFreq = 2*pi*time;

%%%
% Definition of System
%  r=u      x      z       y
%  -> G1 --> NL --> G2 -> 
%%%

[b1,a1] = cheby1(2,1,1/15); % G1:  3th order , 1 dB ripple , 1/15 normalised freq
NL = '5*tanh(x/5)';
[b2,a2] = cheby1(1,1,1/20); % G2:  1th order , 1 dB ripple , 1/20 normalised freq

%% Measure Of BLA

%%%%
% Design of Input Signal
%%%%
fmax = 1/10; % Excited frequency / f_nyquist
F = floor(fmax*N/2);
ExcitedHarm = 1:F;
r = CalcMultisine(ExcitedHarm, N);
R = fft(r)/sqrt(N);

% figure;
% subplot(211); stairs(time,r); title('Input of system'); xlabel('time');
% subplot(212); plot(2*normFreq,db(R),'x'); xlabel('frequency (x\pi rad/sample)')

%%%
% Parameters experiment
%%%
P = 2;                                  % number of consecutive periods multisine
M = 25;                                 % number of independent repeated experiments
Rall = zeros(M, F);                     % reference spectrum for all realisations
Uall = zeros(M, P, F);                  % input spectrum for all realisations and all periods
Yall = zeros(M, P, F);                  % output spectrum for all realisations and all periods

%%%
% Measure BLA
%%%
for mm = 1:M
    r = CalcMultisine(ExcitedHarm, N); % Make a new MS realization 
    
    R = fft(r)./sqrt(N);
    Rall(mm,:) = R(2:F+1);
    u = r;
    x = filter(b1,a1,u);    %
    z = eval(NL);           % Pass it trough system (noiseless)
    y = filter(b2,a2,z);    %

    Y0 = fft(y)./sqrt(N);
    U0 = fft(u)./sqrt(N);
    
    for pp = 1:P
        Uall(mm,pp,:) = U0(2:F+1);
        Yall(mm,pp,:) = Y0(2:F+1);
    end
    
end
[BLA,Y,U,~] = Robust_NL_Anal(Yall, Uall,Rall);
Plot_Robust_NL_Anal(BLA,Y,U,ExcitedHarm);
% figure;
% hold all;
% plot(ExcitedHarm/N,db(BLA.mean),'kx');
% plot(ExcitedHarm/N,db(BLA.stds),'bx');
% plot(ExcitedHarm/N,db(BLA.stdNL),'rx');
% plot(ExcitedHarm/N,db(BLA.stdn),'gx');
% legend('BLA','NL w.r.t one real','total variance','noise variance','location','Best')

%% ILC

    u_ref = CalcMultisine(ExcitedHarm, N).';    
    
    U = fft(u_ref);
    Y_ref = zeros(1,N);
    Y_ref(2:F+1) = BLA.mean.*U(2:F+1);
    y_ref = 2*real(ifft(Y_ref)); % desired output
    
    uj = u_ref; % first try
    invG = BLA.mean.^-1;
    
    iterationsILC = 30;
    meanError = zeros(1,iterationsILC);
    
    for i = 1:iterationsILC
    
            x = filter(b1,a1,uj);   %
            z = eval(NL);           % Pass it trough system (noiseless)
            yj = filter(b2,a2,z);   %
            % Compute error
            e = y_ref-yj;
            meanError(i) = mean(e.^2);
            % ILC rule : u_j+1 = u_j + G_BLA^-1*ej;
            E = fft(e);
            dU = zeros(1,N);
            dU(2:F+1) = invG.*E(2:F+1);
            du = 2*real(ifft(dU)); 
            
            Q  = 1;
            L =  1;
            uj = Q*(uj + L*du);
    end
    
figure;
subplot(311);
    plot(db(meanError),'x'); xlabel('Iteration'); ylabel('db(MSE)');
    title('MSE of y_d - y_j');
subplot(312); 
    hold all;
    i = 50:250;
    plot(y_ref(i),'-');
    plot(yj(i),'x');
    xlabel('time'); ylabel('Amplitude');
    legend('y_d','yj');
    title('Comparison y_d and y_j ');
subplot(313);
    plot(e,'x'); xlabel('time'); ylabel('error');
    title('y_d - y_j');

    fprintf('L = %g \nMSE : %g dB \n',L,db(meanError(end)));

figure;

subplot(211); hold all;
    i = 50:250;
    plot(db(fft(y_ref)),'-');
    plot(db(fft(yj)),'x');
    xlabel('freq'); ylabel('Amplitude');
    legend('y_d','yj');
    title('Comparison y_d and y_j ');

subplot(212);
    plot(db(fft(e)),'x'); xlabel('freq'); ylabel('error');
    title('y_d - y_j') ;
fprintf('Script ended in %g sec.\n',toc);