function [B, A, Cost] = estimateParamBLA(BLA,ExcitedHarm,N,naBla,nbBla)
% [B, A, Cost] = estimateBLA(BLA,ExcitedHarm,N,naBla,nbBla)
% Estimate parametric TF from FRF Measurements Given by NL_Robust_Anal

    % Convert Data to output error problem
    F           = length(ExcitedHarm);
    data.Y		=	BLA.mean; % ny x F 
    data.U		=	ones(F,1).'; % nu x F 
    data.freq	=	ExcitedHarm; 
    data.Ts		=	1/N;
    data.CY		=	zeros(1,1,F); % ny x ny x F
    data.CY(1,1,:) = BLA.stdNL.^2;
    data.CU     =   zeros(1,1,F); % nu x nu x F 
    data.CYU    =   zeros(1,1,F); % ny x nu x F 
    
    % Parameters of Identification
    Sel = struct('A',ones(1,naBla+1),'B',ones(1,1,nbBla+1), 'Ig', 0);
    ModelVar = struct('Transient', 0, 'PlantPlane', 'z', 'NoisePlane', 'z', 'Struct','OE', 'RecipPlant', 0);
    
    % Starting Value With LS
    [Theta0, ~, ~, ~] = MIMO_WGTLS(data, Sel, ModelVar);
    
    % Optimise Value with Maximum Likelihood Estimator
    IterVar = struct('LM', 1, 'MaxIter', 100, 'TolParam', 1e-15, 'TolCost', 1e-15, 'TraceOn', 1);
    [Theta, Cost, ~, ~,  ~] = MIMO_ML(data, Sel, Theta0, ModelVar, IterVar);

    B = squeeze(Theta.B).';
    A = squeeze(Theta.A);


end