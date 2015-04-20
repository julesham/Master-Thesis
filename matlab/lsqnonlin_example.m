paramInit = fParse(model);
modelData = model;
signalData.u = u(:,1:Mest,[1 5]);
signalData.y = y(:,1:Mest,[1 5]);
e=fCostModel(paramInit,modelData,signalData);
optLSQ = optimset('TolX',1e-15,'TolFun',1e-15,'MaxIter',1e4,'MaxFunEvals',1000*N,'PlotFcns',@fOptimPlotResNorm,...
    'Jacobian','off','Algorithm','levenberg-marquardt','DerivativeCheck','off');
func = @(parameters)fCostModel(parameters,modelData,signalData);
parameters = lsqnonlin(func,paramInit,[],[],optLSQ);
modelOpt = model;
modelOpt = fDeParse(modelOpt,parameters);