function [y,u] = SYS_WH(r)

    [b1,a1] = cheby1(1,1,2*1/15); % G1:  3th order , 1 dB ripple , 1/15 of Nyquist
    [b2,a2] = cheby1(3,1,2*1/20); % G2:  1th order , 1 dB ripple , 1/20 of Nyquist
  
  
    x = filter(b1,a1,r);    %
    z = 5*tanh(x/1.2);           % Pass it trough system (noiseless)
    y = filter(b2,a2,z);    
    
%     Add noise
     u = r + 3e-3*randn(size(r));
     y = y + 3e-3*randn(size(r));
end