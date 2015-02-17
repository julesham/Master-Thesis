function y = SYS_WH(u)

    [b1,a1] = cheby1(2,1,1/30); % G1:  3th order , 1 dB ripple , 1/15 normalised freq
    [b2,a2] = cheby1(1,1,1/20); % G2:  1th order , 1 dB ripple , 1/20 normalised freq
    
    x = filter(b1,a1,u);    %
    z = 5*tanh(x/5);           % Pass it trough system (noiseless)
    y = filter(b2,a2,z);    %

end