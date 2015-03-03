function y = SYS_W(u)

    [b1,a1] = cheby1(1,1,2*1/15); % G1:  3th order , 1 dB ripple , 1/15 of Nyquist
    
    x = filter(b1,a1,u);    %
    y = 5*tanh(x/5);           % Pass it trough system (noiseless)
end

