function [y,u] = SYS_SNL(u)

    y = 5*tanh(u/5);           % Pass it trough system (noiseless)

end