function sysnew = utRateConversion(this,sysold,ts_new,options)
% UTRATECONVERSION  Convert the sample times of a system based on the
% linearization options.
 
% Author(s): John W. Glass 26-Feb-2009
% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/05/23 08:19:55 $

% Get the starting sample time
ts_old = sysold.Ts;

% Get the sampling methodology
RateConvMethod = options.RateConversionMethod;
if strcmp(RateConvMethod,'upsampling_zoh')
    RateConvMethod = 'zoh';
    UpSample = true;
elseif strcmp(RateConvMethod,'upsampling_tustin')
    RateConvMethod = 'tustin';
    UpSample = true;
elseif strcmp(RateConvMethod,'upsampling_prewarp')
    RateConvMethod = 'prewarp';
    UpSample = true;
else
    UpSample = false;
end

if strcmp(RateConvMethod,'prewarp')
    RateConvMethodArg = {RateConvMethod,evalScalarParam(this,options.PreWarpFreq)};
else
    RateConvMethodArg = {RateConvMethod};
end

% Convert the rates of the current sample rate
if ts_old ~= 0
    hw = ctrlMsgUtils.SuspendWarnings;
    if ts_new ~= 0
        ts_factor = ts_old/ts_new;
        if UpSample && (floor(ts_factor) == ts_factor)
            sysnew = upsample(sysold,ts_factor);
        else
            sysnew = d2d(sysold,ts_new,RateConvMethodArg{:});
        end
    else
        try
            sysnew = d2c(sysold,RateConvMethodArg{:});
        catch Ex_d2c
            if strcmp(Ex_d2c.identifier,'Control:transformation:ZOHConversion1')
                ctrlMsgUtils.error('Slcontrol:linutil:ZOHD2CPoleAtZero',bdroot)
            else
                delete(hw);
                rethrow(Ex_d2c)
            end
        end
    end
    delete(hw);
else
    sysnew = c2d(sysold,ts_new,RateConvMethodArg{:});
end