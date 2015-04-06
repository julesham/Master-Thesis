function [u_out,y_out] = compensateAWGDelay(u,y,r,u_first,r_first,ExcitedHarm)
% [u_out,y_out] = compensateAWGDelay(u,y,r,u_first,r_first,ExcitedHarm)
% This functions compensates for the variable delay of the AWG by synchronizing u,y
% with the first realisations u_first, r_first
    N = length(u);
    % We first save the first realization, and will synchronize the
    % following ones with this one.
    UR_first = fft(u_first(:,1))./fft(r_first);
    UR_first = UR_first(ExcitedHarm+1);
    phase_Ref_Input_first = unwrap( angle(UR_first) );
    

    UR = fft(u(:,1))./fft(r);                               % Compute actuator Transfer Function
    UR = UR(ExcitedHarm+1);                                 % Select Excited Frequencies
    phase_Ref_Input_curr = unwrap( angle(UR) );             % Consider the phase
    
    phaseDiff = phase_Ref_Input_first - phase_Ref_Input_curr;    % Compute phase difference with the TF measured the first time
    p = polyfit(ExcitedHarm/N*2*pi,phaseDiff,1);        % the slope of this curve gives the delay (mostly -1, 0 , +1 sample)
    delay = round(p(1));
    fprintf('Delay Compensation : %g\n',delay)


% compensate for delay
u_out = circshift(u,[-delay 0 ]);
y_out = circshift(y,[-delay 0]);