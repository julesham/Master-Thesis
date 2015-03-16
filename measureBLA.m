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

F = length(ExcitedHarm);                % # of Excited Harmonics
% Initialisation 
Rall = zeros(M, F);                     % reference spectrum for all realisations
Uall = zeros(M, P, F);                  % input spectrum for all realisations and all periods
Yall = zeros(M, P, F);                  % output spectrum for all realisations and all periods
U_ref_all = zeros(M, P, F);             % Total Reference Spectrum

BLA_Measurements.u = zeros(M, P, N);
BLA_Measurements.y = zeros(M, P, N);
BLA_Measurements.r = zeros(M,N);

h = figure;
for mm = 1:M
    r = rms*CalcMultisine(ExcitedHarm, N); % Make a new MS realization (size of ExcitedHarm)
    R = fft(r)./sqrt(N);
    Rall(mm,:) = R(ExcitedHarm+1);
    
    rr = repmat(r,T+P,1);           % make multiple periods , transient + measurement periods
    [y,u] = feval(DUT,rr);          % pass trough system (can add noise!)
    
    figure(h);
    subplot(2,2,1); plot(r); title('Reference');
    subplot(2,2,2); plot(u); title('Input');
    subplot(2,2,3:4); plot(y); title('Output');

    u = u(T*N+1:end);       % remove transients
    y = y(T*N+1:end);  

    u = reshape(u,N,P);     % organise by periods
    y = reshape(y,N,P);
    
    transientError = mean(var(y,[],2));
    
    
    %%%
    % Save Everything
    %%%
    
    BLA_Measurements.u(mm, :, :) = u.'; 
    BLA_Measurements.y(mm, :, :) = y.'; 
    BLA_Measurements.r(mm,:) = r;
    
    
    Y = fft(y)./sqrt(N);
    U = fft(u)./sqrt(N);
    Uall(mm,:,:) = U(ExcitedHarm+1,:).';
    Yall(mm,:,:) = Y(ExcitedHarm+1,:).';
    
    u_ref = repmat(r,P,1);
    u_ref = reshape(u_ref,N,P);
    U_ref = fft(u_ref)./sqrt(N);
    U_ref_all(mm,:,:) = U_ref(ExcitedHarm+1,:).';
end
close(h)
