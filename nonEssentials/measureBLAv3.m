function [Uall,Yall,Rall,U_ref_all,transientError] = measureBLA(DUT,ExcitedHarm,rms,N,T,P,M)
%% Measures the BLA of the DUT function the robust method (noiseless).
%  * Syntax * 
%
%   [BLA,Y_BLA,U_BLA,meanPeriodError] = measureBLA(DUT,ExcitedHarm,AmplitudeSpectrum,N,T,P,M);
%
% ** Arguments **
%
% * System *
%   * DUT : function handle or text with function name of system
%
% * Input Signal *
%   * ExcitedHarm : F x 1 vector containg all excited bin frequencies
%   * rms : rms of input MS
%   * N : length of input signal (To/Ts), fs/fo
%
% * Experiment *
%   * T : # of transient periods
%   * P : # of measurement periods
%   * M : # of realizations
%
% * Output *
%   * BLA,Y_BLA,U_BLA : Output of the function Robust_Nl_Anal
%   * meanPeriodError : error between periods, verify to steady state
% See also ROBUST_NL_ANAL.

%
% v2 -> v3 : Measure in one long run
% v1 -> v2 : Other output arguments, now saves the data
F = length(ExcitedHarm);                % # of Excited Harmonics
N_meas = (T+P)*N;                       % # of points of one realization
% Initialisation 
Rall = zeros(M, F);                     % reference spectrum for all realisations
Uall = zeros(M, P, F);                  % input spectrum for all realisations and all periods
Yall = zeros(M, P, F);                  % output spectrum for all realisations and all periods
U_ref_all = zeros(M, P, F);             % Total Reference Spectrum
r_total = zeros(M*(T+P)*N,1);           % All measurements concatenated

BLA_Measurements.u = zeros(M, P, N);
BLA_Measurements.y = zeros(M, P, N);
BLA_Measurements.r = zeros(M,N);

h = figure;
for mm = 1:M
    r = rms*CalcMultisine(ExcitedHarm, N); % Make a new MS realization (size of ExcitedHarm)
    R = fft(r)./sqrt(N);
    Rall(mm,:) = R(ExcitedHarm+1);
    r_total((mm-1)*N_meas+1:mm*N_meas) = repmat(r,T+P,1);                % make multiple periods , transient + measurement periods
end
    [y,u] = feval(DUT,r_total);          % pass trough system (can add noise!)
    
    u = reshape(u,N_meas,[]);
    y = reshape(y,N_meas,[]);
    
    u = u(T*N+1:end,:);       % remove transients
    y = y(T*N+1:end,:);     
    
    un = zeros(P,N,M);          % discriminate between periods
    yn = zeros(P,N,M);
    for pp = 1:P
       un(pp,:,:) = u((pp-1)*N+1:pp*N,:); 
       yn(pp,:,:) = y((pp-1)*N+1:pp*N,:); 
    end
    
    transientError = mean(var(yn(:,:,1),[],1));
    
    un = permute(un,[3 1 2]);       % from (P, N, M) to (M,P,N) 
    yn = permute(yn,[3 1 2]);  
    
    %%%
    % Save Everything
    %%%
    
%     BLA_Measurements.u(mm, :, :) = u.'; 
%     BLA_Measurements.y(mm, :, :) = y.'; 
%     BLA_Measurements.r(mm,:) = r;
    
    % Perform FFT
    Y = fft(yn,[],3)./sqrt(N);
    U = fft(un,[],3)./sqrt(N);
    % Use only bands of interest
    Uall = U(:,:,ExcitedHarm+1);
    Yall = Y(:,:,ExcitedHarm+1);
    for pp = 1:P
        U_ref_all(:,pp,:) = Rall;
    end
close(h)
