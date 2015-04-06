function [BLA_IO,BLA_RO,Y_BLA,U_BLA,meanPeriodError,BLA_Measurements] = measureBLAv1(DUT,ExcitedHarm,rms,N,T,P,M)
% ARCHIVE
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

for mm = 1:M
    r = rms*CalcMultisine(ExcitedHarm, N); % Make a new MS realization with rms 
    R = fft(r)./sqrt(N);
    Rall(mm,:) = R(ExcitedHarm+1);
    
    rr = repmat(r,T+P,1);           % make multiple periods , transient + measurement periods
    [y,u] = feval(DUT,rr);          % pass trough system (can add noise!)
    
    u = u(T*N+1:end);       % remove transients
    y = y(T*N+1:end);       
    u = reshape(u,N,P);     % organise by periods
    y = reshape(y,N,P);
    
    %%%
    % Save Everything
    %%%
    BLA_Measurements.u(mm, :, :) = u.'; 
    BLA_Measurements.y(mm, :, :) = y.'; 
    BLA_Measurements.r(mm,:) = r.';
    
%     plot(db( fft(y)./sqrt(length(y)) ) ); title('Output spectrum of BLA MS measurement')
%     Check transient removal   
    diff_periods = zeros(N,1);
    for pp = 1:P-1;
        diff_periods = ( y(:,pp+1)-y(:,pp) )  + diff_periods; 
    end
    meanPeriodError = mean(diff_periods.^2)/P;
    
    Y = fft(y)./sqrt(N);
    U = fft(u)./sqrt(N);
    Uall(mm,:,:) = U(ExcitedHarm+1,:).';
    Yall(mm,:,:) = Y(ExcitedHarm+1,:).';
    
    u_ref = repmat(r,P,1);
    u_ref = reshape(u_ref,N,P);
    U_ref = fft(u_ref)./sqrt(N);
    U_ref_all(mm,:,:) = U_ref(ExcitedHarm+1,:).';
end

[BLA_IO,Y_BLA,U_BLA,~] = Robust_NL_Anal(Yall, Uall,Rall);
BLA_RO = Robust_NL_Anal(Yall, U_ref_all);
