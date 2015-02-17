%%%
% Simulation of ILC using BLA
% Jules Hammenecker, Vrije Universiteit Brussel
%%%

clear; close all; clc; tic;
%% Definitions

%%%
% Definition of time and frequency
%%%
N = 2^14;
time = 0:N-1;
normFreq = time/N;
normAngFreq = 2*pi*time;

%%%
% Definition of System
%  r=u      x      z       y
%  -> G1 --> NL --> G2 -> 
%%%

% DUT = 'SYS_WH';
 DUT = 'SYS_SNL';

%% Measure Of BLA

%%%%
% Design of Input Signal
%%%%
fmax = 1/20; % Excited frequency / f_nyquist

F = floor(fmax*N/2);
ExcitedHarm = 1:F;
r = CalcMultisine(ExcitedHarm, N);
R = fft(r)/sqrt(N);

% figure;
% subplot(211); stairs(time,r); title('Input of system'); xlabel('time');
% subplot(212); plot(2*normFreq,db(R),'x'); xlabel('frequency (x\pi rad/sample)')

%%%
% Parameters BLA Measurement
%%%
T = 1;                                  % Transients
P = 2;                                  % number of consecutive periods multisine
M = 100;                                 % number of independent repeated experiments
Rall = zeros(M, F);                     % reference spectrum for all realisations
Uall = zeros(M, P, F);                  % input spectrum for all realisations and all periods
Yall = zeros(M, P, F);                  % output spectrum for all realisations and all periods

%%%
% Measure BLA
%%%
% 
% for mm = 1:M
%     r = CalcMultisine(ExcitedHarm, N); % Make a new MS realization 
%     R = fft(r)./sqrt(N);
%     Rall(mm,:) = R(2:F+1);
%     
%     u = repmat(r,T+P,1);    % make multiple periods
%     y = feval(DUT,u);          % pass trough system
% 
%     u = u(T*N+1:end);       % remove transients
%     y = y(T*N+1:end);       
%     
%     u = reshape(u,N,[]);
%     y = reshape(y,N,[]);
%     
%     % Check transient removal   
%     diff_periods = zeros(N,1);
%     for pp = 1:P-1;
%         diff_periods = ( y(:,pp+1)-y(:,pp) )/P  + diff_periods; 
%     end
%     meanPeriodError = mean(diff_periods.^2);
%     
%     Y0 = fft(y)./sqrt(N);
%     U0 = fft(u)./sqrt(N);
%     
% 
%     Uall(mm,:,:) = U0(2:F+1,:).';
%     Yall(mm,:,:) = Y0(2:F+1,:).';
% 
% end
% [BLA,Y,~,~] = Robust_NL_Anal(Yall, Uall,Rall);

BLA = extractionBLA(DUT,ExcitedHarm,N,T,P,M);
figure;
hold all;
plot(ExcitedHarm/N,db(BLA.mean),'kx');
plot(ExcitedHarm/N,db(BLA.stds),'bx');
plot(ExcitedHarm/N,db(BLA.stdNL),'rx');
plot(ExcitedHarm/N,db(BLA.stdn),'gx');
legend('BLA','NL w.r.t one real','total variance','noise variance','location','Best')

%% ILC

    u_ref = CalcMultisine(ExcitedHarm, N).';    
    
    U = fft(u_ref);
    Y_ref = zeros(1,N);
    Y_ref(2:F+1) = BLA.mean.*U(2:F+1);
    y_ref = 2*real(ifft(Y_ref)); % desired output
    
    uj = u_ref; % first try
    invG = BLA.mean.^-1;
    
    iterationsILC = 100;
    meanError = zeros(1,iterationsILC);
    
    for i = 1:iterationsILC
    
            yj = feval(DUT,uj);
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
            %uj = Q*(uj + e);
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
    
fprintf('System used = %s \n',DUT);  
fprintf('MSE between periods of y = %g\n',meanPeriodError);  
fprintf('L = %g \nMSE : %g dB \n',L,db(meanError(end)));  
fprintf('Script ended in %g sec.\n',toc);