function y = steadyStateResponse(model,u)

N = length(u);

switch model.type
    %%%%%%%%%
    % Wiener
    %%%%%%%%
    case 'Wiener' % u -- |BLA| -- |SNL| -- y 
        % Extract useful Parameters
        ExcitedHarm = model.ExcitedHarm;
        orderBLA    = length(ExcitedHarm);
        BLA = model.parameters(1:orderBLA);
        p   = model.parameters(orderBLA+1:end).';
        % Compute Response
        
        % BLA Response
        W = zeros(N,1);
        U = fft(u);
        W(ExcitedHarm+1)= BLA.*U(ExcitedHarm+1);
        w = 2*real(ifft(W));
       
        % Response of SNL
        y = polyval(p,w);
        
    %%%%%%%%%
    % Wiener FIR
    %%%%%%%%    
    case 'WFIR' % u -- |FIR| -- |SNL| -- y 
        h = model.parameters(1:model.orderH);
        p = model.parameters(model.orderH+1:end).';
        % Response of FIR
        w = conv( h,repmat(u,2,1) );
        w = w(N+1:2*N); % eliminate transients
        % Response of SNL
        y = polyval(p,w);
    %%%%%%%%%
    % Hammerstein FIR
    %%%%%%%%    
    case 'HFIR' % u -- |SNL| -- |FIR| -- y 
        h = model.parameters(1:model.orderH);
        p = model.parameters(model.orderH+1:end).';
        % Response of SNL
        w = polyval(p,u);
        % Response of FIR
        y = conv( h,repmat(w,2,1) );
        y = y(N+1:2*N); % eliminate transients  
    otherwise
      error('Unknown Model Type \n');
end

end
