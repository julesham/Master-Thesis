function [B, A, Cost] = estimateBLA(BLA,ExcitedHarm,N,naBla,nbBla)
% [B, A, Cost] = estimateBLA(BLA,ExcitedHarm,N,naBla,nbBla)
% Estimate parametric TF from FRF Measurements Given by NL_Robust_
    F = max(ExcitedHarm);
    
    data.Y		=	BLA.mean(ExcitedHarm); % ny x F 
    data.U		=	ones(F,1).'; % nu x F 
    data.freq	=	ExcitedHarm; 
    data.Ts		=	1/N;
    data.CY		=	zeros(1,1,F); % ny x ny x F
    data.CY(1,1,:) = BLA.stdNL(ExcitedHarm).^2;
    data.CU     =   zeros(1,1,F); % nu x nu x F 
    data.CYU    =   zeros(1,1,F); % ny x nu x F 
    
    Sel = struct('A',ones(1,naBla+1),'B',ones(1,1,nbBla+1), 'Ig', 0);
    ModelVar = struct('Transient', 0, 'PlantPlane', 'z', 'NoisePlane', 'z', 'Struct','OE', 'RecipPlant', 0);

    [Theta0, smax, smin, wscale] = MIMO_WGTLS(data, Sel, ModelVar);

    IterVar = struct('LM', 1, 'MaxIter', 100, 'TolParam', 1e-15, 'TolCost', 1e-15, 'TraceOn', 1);
    [Theta, Cost, smax, smin, wscale] = MIMO_ML(data, Sel, Theta0, ModelVar, IterVar);

    % check how well pole estimates match true ones
    % [[roots(aFront1); roots(aFront2); roots(aBack1); roots(aBack2)] roots(Theta.A)]

    B = squeeze(Theta.B);
    A = squeeze(Theta.A);

    % % Validation of result
    % 
    % z = exp(1j*2*pi*ExcitedHarmBLA/N);
    % estBLA = polyval(B_BLA,z)./polyval(A_BLA,z);

end