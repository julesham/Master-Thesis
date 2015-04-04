function [uj,yj,y1,meanError,e,ILC_Measurements]= ilcFRF(DUT,y_ref,u_ref,iterationsILC,BLA,transientPeriods,ExcitedHarmILC,ExcitedHarmBLA)
% applies ilc algorithm to find an input that generates the wanted output
totalPeriods = transientPeriods+1;
N    = length(y_ref);
invG = BLA.^-1;

meanError = zeros(iterationsILC,1);

uj = u_ref;                     % first iteration is reference input
rr = repmat(uj,totalPeriods,1); 
[yj, um ] = feval(DUT,  rr);    % Pass trough system
yj = yj(transientPeriods*N+1:totalPeriods*N);       % Transient removal
y1 = yj;    % Save initial response to compare zith later


ILC_Measurements.uj = zeros(iterationsILC,N);
ILC_Measurements.um = zeros(iterationsILC,N);
ILC_Measurements.yj = zeros(iterationsILC,N);
ILC_Measurements.y_ref = y_ref;
ILC_Measurements.u_ref = u_ref;
ILC_Measurements.ExcitedHarm = ExcitedHarmILC;
for ii = 1:iterationsILC
        
        fprintf('ILC Iteration : %g/%g\n',ii,iterationsILC);  
        % Compute error
        e = y_ref-yj;
        meanError(ii) = mean(e.^2);
        
        % ILC rule : u_j+1 = u_j + G_BLA^-1*ej;
        E = fft(e);
        dU = zeros(N,1);
        dU(ExcitedHarmBLA+1) = (invG.').*E(ExcitedHarmBLA+1);
        du = 2*real(ifft(dU)); 
        uj = uj + du;
        
      rr = repmat(uj,totalPeriods,1);
      [yj, um ]  = feval(DUT, rr );
      yj = yj(transientPeriods*N+1:totalPeriods*N); % transient removal
      um = um(transientPeriods*N+1:totalPeriods*N);
      
      %%%
      % Delay Compensation
      %%%
      
      if strcmp(DUT,'SYS_VXI')
          if ii == 1
              % We first save the first realization, and will synchronize the
              % following ones with this one.
              u_first = um;
              r_first = uj;
          else
              [um,yj] = compensateAWGDelay(um,yj,uj,u_first,r_first,ExcitedHarmILC);
          end
      end

      %%%
      % Save Everything
      %%%
      ILC_Measurements.uj(ii,:) = uj;   %reference input
      ILC_Measurements.um(ii,:) = um;   % measured input
      ILC_Measurements.yj(ii,:) = yj;   % measured output
end
        