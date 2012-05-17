function s = utPIDgetmetrics(OLsys, CLsys)
% PID helper function

% This function returns performance and robustness metrics in a structure

% Author(s): R. Chen
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.10.4 $ $Date: 2010/03/26 17:21:36 $

hw = ctrlMsgUtils.SuspendWarnings; %#ok<NASGU>
s = struct;
% time domain
s.RiseTime = NaN;
s.SettlingTime = NaN;
s.Overshoot = NaN;
s.Peak = NaN;
if ~isa(OLsys,'frd') && isproper(CLsys) && ~isempty(CLsys)
    try %#ok<*TRYNC>
        StepInfo = stepinfo(CLsys);
        s.RiseTime = StepInfo.RiseTime;
        s.SettlingTime = StepInfo.SettlingTime;
        s.Overshoot = StepInfo.Overshoot;
        s.Peak = StepInfo.Peak;
    end
end
% frequency domain
[GM PM WCG WCP] = margin(OLsys);
s.GainMargin = GM;
s.GainMarginAt = WCG;
s.PhaseMargin = PM;
s.PhaseMarginAt = WCP;
