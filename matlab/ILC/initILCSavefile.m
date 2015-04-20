% create ILC_Measurements File

ILC_Measurements.BLAInfo.ExcitedHarmBLA= BLA_Measurements.ExcitedHarm;
ILC_Measurements.BLAInfo.BLA_RO       = BLA_RO;
ILC_Measurements.DUT           = DUT;
ILC_Measurements.ExcitedHarmILC= ExcitedHarmILC;
ILC_Measurements.ilcM          = ilcM;
ILC_Measurements.T             = BLA_Measurements.T;
ILC_Measurements.iterations    = iterationsILC;
ILC_Measurements.u_ref         = nan(ilcM,time.N);
ILC_Measurements.y_ref         = nan(ilcM,time.N);
ILC_Measurements.um            = nan(ilcM,iterationsILC,time.N);
ILC_Measurements.uj            = nan(ilcM,iterationsILC,time.N);
ILC_Measurements.yj            = nan(ilcM,iterationsILC,time.N);
ILC_Measurements.error = nan(ilcM,iterationsILC,time.N);
