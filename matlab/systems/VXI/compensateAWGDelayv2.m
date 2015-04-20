function [delay] = compensateAWGDelayv2(u,r,u_first,r_first,ExcitedHarm)
% [delay] = compensateAWGDelayv2(u,r,u_first,r_first,ExcitedHarm)
% delay is the uncertain +1,0,-1 sample delay introduced by the AWG over
% different measurements
%
% To compensate for this delay, all measured signals (except the reference) should
% be compensated with:
% u_out = circshift(u,[-delay 0 ]);
% See also : circshift.
    N = length(u);
    
    %%%
    % Computing the R./U Transfer function
    % First Realisation
    %%%
    
    UR_1 = fft(u_first)./fft(r_first);
    UR_1 = UR_1(ExcitedHarm+1);         % trim unwanted frequencies
    phase_first = unwrap( angle(UR_1) );
    
    %%%
    % Computing the R./U Transfer function
    % Current Realisation
    %%%
    
    UR_c = fft(u)./fft(r);
    UR_c = UR_c(ExcitedHarm+1);            % trim unwanted frequencies                   
    phase_c = unwrap( angle(UR_c) );       
    
    %%%
    % The phase difference will be (normalised angular frequency) x (delay
    % in samples)
    %%%
    
    phaseDiff = phase_first - phase_c;
    % the slope of this curve gives the delay (mostly -1, 0 , +1 sample)
    p         = polyfit(ExcitedHarm/N*2*pi,phaseDiff,1);        
    delay     = round(p(1));
    fprintf('Delay Compensation : %g\n',delay)
end

% compensate for delay
% u_out = circshift(u,[-delay 0 ]);
% y_out = circshift(y,[-delay 0]);