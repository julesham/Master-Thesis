function [BLA_RO,Y_BLA,U_BLA] = processBLA(BLA_Measurements)    % Process the raw data
%[BLA_RO,Y_BLA,U_BLA] = processBLA(BLA_Measurements)
[Yall,Uall,Rall,U_ref_all]  = getSpectra(BLA_Measurements);
% Compute Input -> output BLA
[BLA_IO,Y_BLA,U_BLA,CYU]    = Robust_NL_Anal(Yall, Uall,Rall);
% Compute Reference -> output BLA
BLA_RO                      = Robust_NL_Anal(Yall,U_ref_all);
