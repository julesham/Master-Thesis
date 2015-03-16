function [y,u] = SYS_WH(r)

    [b1,a1] = cheby1(1,1,2*1/15); % G1:  3th order , 1 dB ripple , 1/15 of Nyquist
    [b2,a2] = cheby1(3,1,2*1/20); % G2:  1th order , 1 dB ripple , 1/20 of Nyquist
  
  
    x = filter(b1,a1,r);    %
    z = 5*tanh(x/5);           % Pass it trough system (noiseless)
%   z = x - 0.01*x.^3;
    y = filter(b2,a2,z);    
    
%     Add noise
     u = r + 1e-4*randn(size(r));
     y = y + 1e-4*randn(size(r));
end