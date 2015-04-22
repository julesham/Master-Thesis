function [y,u] = SYS_W(r)

    [b,a] = cheby1(3,1,2*1/20); % G2:  1th order , 1 dB ripple , 1/20 of Nyquist
    z = 5*tanh(r/1);           % Pass it trough system (noiseless)
    y = filter(b,a,z);    
    
%     Add noise
%      u = r;
     u = r + 3e-3*randn(size(r));
     y = y + 3e-3*randn(size(r));
end