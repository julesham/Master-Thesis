function [uj,yj,y1,meanError,e,ILC_Measurements]= ilcFRF(DUT,y_ref,u_ref,iterationsILC,Q,L,BLA,transientPeriods)
% applies ilc algorithm to find an input that generates the wanted output
totalPeriods = transientPeriods+1;
F_BLA = length(BLA); 
N = length(y_ref);
invG = BLA.^-1;
meanError = zeros(1,iterationsILC);
uj = u_ref;
[yj, ~ ] = feval(DUT, repmat(uj,totalPeriods,1) );  % 
yj = yj(transientPeriods*N+1:totalPeriods*N);       % Transient 
y1 = yj;


ILC_Measurements.uj = zeros(iterationsILC,N);
ILC_Measurements.um = zeros(iterationsILC,N);
ILC_Measurements.yj = zeros(iterationsILC,N);
ILC_Measurements.y_ref = y_ref;
ILC_Measurements.u_ref = u_ref;

for i = 1:iterationsILC
        
        fprintf('%g %%\n',i/iterationsILC*100);  
        % Compute error
        e = y_ref-yj;
        meanError(i) = mean(e.^2);
        
        % ILC rule : u_j+1 = u_j + G_BLA^-1*ej;
        E = fft(e);
        dU = zeros(N,1);
        dU(2:F_BLA+1) = (invG.').*E(2:F_BLA+1);
        du = 2*real(ifft(dU)); 
        uj = Q*(uj + L*du);
      
      [yj, um ]  = feval(DUT, repmat(uj,totalPeriods,1) );
      yj = yj(transientPeriods*N+1:totalPeriods*N);
      um = um(transientPeriods*N+1:totalPeriods*N);

      %%%
      % Save Everything
      %%%
      ILC_Measurements.uj(i,:) = uj;
      ILC_Measurements.um(i,:) = um;
      ILC_Measurements.yj(i,:) = yj;
end
        