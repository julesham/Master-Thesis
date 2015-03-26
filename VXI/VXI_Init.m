%% Generate a sine and performs a test measurements
% Jules Hammenecker
% 09-Mar-2015 

% U : 128  (DAQ)
% Y : 104 (DAQ)
% R : 85 (AWG)
clear all
close all
clc

%% Init
defpath
addpath('D:\ANNA_Rev1\ZZ_Applications')
oldFolder = cd('Z:\MA2\Master Thesis\VXI\');
Jules_Dual_1430_1445
cd(oldFolder)
anna_init

cd('Z:\MA2\Master Thesis\VXI\');



% use internal reconstruction filter of AWG.
HPE1445_FiltSetBand(G_Dev(retrieve('g1','AWG')).session,[],0,250e3) % LowFreq = 0 Hz / HighFreq = 250kHz
[LowFreq,HighFreq] = HPE1445_FiltGetBand(G_Dev(retrieve('g1','AWG')).session);

 %% Input Signal Parameters (DOES NOT CHANGE VXI PARAM!)
% Input Signal
fClock = 10e6;
DivFac = 2^2;
fs = fClock/DivFac; % sampling frequency

% Signal Parameters
N = 2^12; % number of points in one period
P = 1; % number of periods to measure

%% Load Input Signals
f0 = fs/N;
T0 = 1/f0;
t = 0:1/fs:T0-1/fs;
signal = sin(2*pi*f0.*t);
signalRMS = 2;
% Adapt and Load Signal Into AWG
Jules_Dual_1430_1445_Generate(signal, signalRMS); 
% Measurement
pause(0.3); % Wait to remove eventual transient in system
[u,y] = Dual_1430_1445_Measure(N,P,[]); % measurements aquisition 

%% Plot data
figure('Name','Test of VXI');
subplot(211); hold all; plot(u,'x'); plot(signal*signalRMS/rms(signal.'),'o'); 
legend('input','reference'); 
title(['rms of input = ',num2str(rms(u.'))]);
subplot(212); plot(y,'x-');
