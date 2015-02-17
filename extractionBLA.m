function [BLA,meanPeriodError] = extractionBLA(DUT,ExcitedHarm,N,T,P,M)
F = max(ExcitedHarm);
Rall = zeros(M, F);                     % reference spectrum for all realisations
Uall = zeros(M, P, F);                  % input spectrum for all realisations and all periods
Yall = zeros(M, P, F);                  % output spectrum for all realisations and all periods

for mm = 1:M
    r = CalcMultisine(ExcitedHarm, N); % Make a new MS realization 
    R = fft(r)./sqrt(N);
    Rall(mm,:) = R(2:F+1);
    
    u = repmat(r,T+P,1);    % make multiple periods
    y = feval(DUT,u);          % pass trough system

    u = u(T*N+1:end);       % remove transients
    y = y(T*N+1:end);       
    
    u = reshape(u,N,[]);
    y = reshape(y,N,[]);
    
    % Check transient removal   
    diff_periods = zeros(N,1);
    for pp = 1:P-1;
        diff_periods = ( y(:,pp+1)-y(:,pp) )/P  + diff_periods; 
    end
    meanPeriodError = mean(diff_periods.^2);
    
    Y0 = fft(y)./sqrt(N);
    U0 = fft(u)./sqrt(N);
    

    Uall(mm,:,:) = U0(2:F+1,:).';
    Yall(mm,:,:) = Y0(2:F+1,:).';

end
[BLA,~,~,~] = Robust_NL_Anal(Yall, Uall,Rall);
