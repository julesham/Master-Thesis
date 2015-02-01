function main
clc; close all;
tic
%% Definitions
% Process
%                z
%   P(z) =      ---
%            (z - 0.9)^2
p.num =  [0,1,0]; p.den = [1,-1.8,0.81];
% Time
N = 50;         % # samples
n = 0:(N-1);      % time axis

% ILC parameters
Q = 1; L = 0.5; % Q filter and  Learning Filter
J = 200;        % # iterations

% Input
f = 1/N;           % freqency of input
yd = 5*sin(2*pi*f*n).'; % desired output


%% ILC
ILC(p.num,p.den,Q,L,yd,J,false); % without noise
%ILC(p.num,p.den,Q,L,yd,J,true); % with noise

fprintf('Script ended in %g s \n',toc);
end
