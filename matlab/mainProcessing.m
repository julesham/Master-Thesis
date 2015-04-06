%% Processing and Analysis of BLA

% Process the raw data
[Yall,Uall,Rall,U_ref_all]  = processBLAMeasurements(BLA_Measurements); 

% Compute Input -> output BLA
[BLA_IO,Y_BLA,U_BLA,CYU]    = Robust_NL_Anal(Yall, Uall,Rall); 

% Compute Reference -> output BLA
BLA_RO                      = Robust_NL_Anal(Yall,U_ref_all);           

plotBLA;shg;    % Plot Results