function [BLA,Y_BLA,U_BLA,meanPeriodError] = measureBLA_Tickler(DUT,ExcitedHarm,AmplitudeSpectrum,N,T,P,M)
%% Measures the BLA of the DUT function the robust method (noiseless).
%  * Syntax * 
%
%   [BLA,Y_BLA,U_BLA,meanPeriodError] = measureBLA(DUT,ExcitedHarm,AmplitudeSpectrum,N,T,P,M);
%
% ** Arguments **
%
% * System *
%   * DUT : function handle or text with function name
%
% * Input Signal *
%   * ExcitedHarm : F x 1 vector containg all excited bin frequencies
%   * Amplitude Spectrum : F x 1 vector containg amplitude of input MS
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

F = floor(N/2)-1;                % # of Excited Harmonics
% Initialisation 
Rall = zeros(M, F);                     % reference spectrum for all realisations
Uall = zeros(M, P, F);                  % input spectrum for all realisations and all periods
Yall = zeros(M, P, F);                  % output spectrum for all realisations and all periods

for mm = 1:M
    r = CalcMultisine(ExcitedHarm, N,AmplitudeSpectrum); % Make a new MS realization with rms = 1
%   ONLY DIFFERENCE WITH NO TICKLER   
    tickler = 1*CalcMultisine( (max(ExcitedHarm)+1):floor(N/2)-1 , N);
    r = r + tickler;
%     
    R = fft(r)./sqrt(N);
    Rall(mm,:) = R(2:F+1);
    
    u = repmat(r,T+P,1);    % make multiple periods
    y = feval(DUT,u);          % pass trough system
    
    u = u(T*N+1:end);       % remove transients
    y = y(T*N+1:end);       
    u = reshape(u,N,[]);
    y = reshape(y,N,[]);
    
%     plot(db( fft(y)./sqrt(length(y)) ) ); title('Output spectrum of BLA MS measurement')
%     Check transient removal   
    diff_periods = zeros(N,1);
    for pp = 1:P-1;
        diff_periods = ( y(:,pp+1)-y(:,pp) )  + diff_periods; 
    end
    meanPeriodError = mean(diff_periods.^2)/P;
    
    Y0 = fft(y)./sqrt(N);
    U0 = fft(u)./sqrt(N);
    

    Uall(mm,:,:) = U0(2:F+1,:).';
    Yall(mm,:,:) = Y0(2:F+1,:).';

end
[BLA,Y_BLA,U_BLA,~] = Robust_NL_Anal(Yall, Uall,Rall);
