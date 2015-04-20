function eTot = modelCost(model,parameters,ILC_Measurements)
model.parameters = parameters;
y_ref = ILC_Measurements.y_ref.'; % N x ilcM
[~, ilcM] = size(y_ref);
uj    = squeeze( ILC_Measurements.uj(:,end,:) ).';
eTot = [];

for mm = 1:ilcM
    ujModel = steadyStateResponse(model,y_ref(:,mm));
    e = uj(:,mm) - ujModel;
end

eTot  = [eTot;e];