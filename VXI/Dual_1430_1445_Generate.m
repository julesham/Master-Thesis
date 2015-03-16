function Dual_1430_1445_Generate(Signal, Vrms)
% load the generator signal
AWG_SetAWGOn('g1','OFF');   % Turn AWG off
AWG_SetWave('g1',Signal);   % Store input Signal

%// Signal is normalised to an amplitude close to 1 to be loaded in the
%// generator. To get the requested RMS value, the signal is normalised to
%// RMS = 1 by dividing by the RMS value of the loaded signal ( = std)
AWG_SetVMax('g1',Vrms/std(Signal)*max(abs(Signal))) % AWG_SetVMax('g1',Vrms)
AWG_SetAWGOn('g1','ON')     % Turn AWG ON
%// AUTORANGE THE ADC
ACQ_SetRange('*',9) % Input Range is 9 Volts
