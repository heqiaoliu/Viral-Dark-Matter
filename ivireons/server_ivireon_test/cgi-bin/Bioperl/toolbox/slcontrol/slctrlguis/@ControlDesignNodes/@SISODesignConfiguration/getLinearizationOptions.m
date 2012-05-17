function opt = getLinearizationOptions(this) 
% GETLINEARIZATIONOPTIONS Get the options to linearize a model for
% compensator design
%
 
% Author(s): John W. Glass 11-Sep-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2010/02/17 19:07:55 $

opt = linoptions;
SCDTaskOptions = getSCDTaskOptions(this);
if isempty(this.sisodb)
    op = getOperPoint(this);
    ts = computeSampleTime(linutil,SCDTaskOptions.SampleTime);
    if ts == -1
        if isempty(op.States)
            opt.SampleTime = 0;
        else
            sampletimes_cell = get(op.States,'Ts');
            sampletimes = cat(1,sampletimes_cell{:});
            opt.SampleTime = max(sampletimes(:,1));
        end
    else
        opt.SampleTime = ts;
    end
else
    opt.SampleTime = this.sisodb.LoopData.Ts;
end

opt.RateConversionMethod = SCDTaskOptions.RateConversionMethod;
opt.PreWarpFreq = SCDTaskOptions.PreWarpFreq;