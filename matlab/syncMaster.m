%%
% Create Sync Master, all subsequent measurements will be synchronised to
% this realisation
%%

clc; clear; close all;

% Definitions
fs = 10e6/2^2;  % Sample frequency 2.5 MHz
N  = 2^12;      % Samples per period 4096
rms = 0.2;      % rms of input signal

% Creation of Input Signal
ExcitedHarm = ( 1:N/2-1 ).';
r = CalcMultisine(ExcitedHarm,N);

signal = rms*r;
% Measurement 
% VXI_Init;

[y,u] = SYS_VXI(signal);

save('syncMaster3.mat','u','y','signal');

%%
load syncMaster3;
U = fft(u); R = fft(signal);
U = U(ExcitedHarm+1);
R = R(ExcitedHarm+1);
hold all;
subplot(2,1,1); plot(ExcitedHarm/N*fs,db(U./R));
subplot(2,1,2); plot(ExcitedHarm/N*fs,unwrap(angle(U./R)));