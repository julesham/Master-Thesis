function [y,u] = SYS_VXI(r)
% [y,u] = SYS_VXI(r)
%   Measures the system connected to the VXI
%   y,u,r are column vectors

% Adapt Signal
signalRMS = rms(r);
signal = r./max(max(abs(r))); % The input should be scaled to be between (-1, 1)


% Measurement
Jules_Dual_1430_1445_Generate(signal, signalRMS); % Load signal in AWG
% pause(0.2); % Wait to remove eventual transient in system and AWG
[u,y] = Dual_1430_1445_Measure(length(r),1,[]); 
% measurements acquisition, only considering one period because the
% multiple periods are already in 'r'.


% VXI Outputs row vectors, but column vectors are wanted.
u = u.'; 
y = y.';

