function [uj, yj,meanError,e]= ilcFRF(DUT,y_ref,u0,iterationsILC,Q,L,BLA)
% applies ilc algorithm to find an input that generates the wanted output

F_BLA = length(BLA); 
N = length(y_ref);
invG = BLA.^-1;
meanError = zeros(1,iterationsILC);
uj = u0;
yj = feval(DUT,u0);
for i = 1:iterationsILC
        clc;
        fprintf('%g %%\n',i/iterationsILC*100);  
        % Compute error
        e = y_ref-yj;
        meanError(i) = mean(e.^2);
        
        % ILC rule : u_j+1 = u_j + G_BLA^-1*ej;
        E = fft(e);
        dU = zeros(1,N);
        dU(2:F_BLA+1) = invG.*E(2:F_BLA+1);
        du = 2*real(ifft(dU)); 
        uj = Q*(uj + L*du);
        yj = feval(DUT,uj);
end
        