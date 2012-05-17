function [Type, Form, TimeDomain, SampleTime, IntMethod, DerMethod, ...
    P_Blk, I_Blk, D_Blk, N_Blk, b_Blk, c_Blk] = utPIDgetBlockParameters(blkh)
% PID helper function

% This function returns PID block configurations

% Author(s): R. Chen
% Copyright 2009-2010 The MathWorks, Inc.
% $Revision: 1.1.10.4 $ $Date: 2010/03/31 18:59:14 $

% get block configuration contents
h = handle(blkh);
BlockTypeContents = h.getPropAllowedValues('Controller');
BlockFormContents = h.getPropAllowedValues('Form');
BlockTimeDomainContents = h.getPropAllowedValues('TimeDomain');
BlockIntMethodContents = h.getPropAllowedValues('IntegratorMethod');
BlockDerMethodContents = h.getPropAllowedValues('FilterMethod');
% type
idx = strmatch(get_param(blkh,'Controller'),BlockTypeContents,'exact');
switch idx
    case 1
        Type = 'pidf';
    case 2
        Type = 'pi';
    case 3
        Type = 'pdf';
    case 4
        Type = 'p';
    case 5
        Type = 'i';
end
% form
idx = strmatch(get_param(blkh,'Form'),BlockFormContents,'exact');
switch idx
    case 1
        Form = 'ideal';
    case 2
        Form = 'parallel';
end
% time domain
idx = strmatch(get_param(blkh,'TimeDomain'),BlockTimeDomainContents,'exact');
switch idx
    case 1
        TimeDomain = 'continuous-time';
    case 2
        TimeDomain = 'discrete-time';
end
% integrator method
idx = strmatch(get_param(blkh,'IntegratorMethod'),BlockIntMethodContents,'exact');
switch idx
    case 1
        IntMethod = 'forward euler';
    case 2
        IntMethod = 'backward euler';
    case 3
        IntMethod = 'trapezoidal';
end
% filter method
idx = strmatch(get_param(blkh,'FilterMethod'),BlockDerMethodContents,'exact');
switch idx
    case 1
        DerMethod = 'forward euler';
    case 2
        DerMethod = 'backward euler';
    case 3
        DerMethod = 'trapezoidal';
end
% sample time
SampleTime = slResolve(get_param(blkh,'SampleTime'),blkh,'expression');
% gains
P_Blk = slResolve(get_param(blkh,'P'),blkh,'expression');
I_Blk = slResolve(get_param(blkh,'I'),blkh,'expression');
D_Blk = slResolve(get_param(blkh,'D'),blkh,'expression');
N_Blk = slResolve(get_param(blkh,'N'),blkh,'expression');
if strcmp(get(blkh,'MaskType'),'PID 1dof')               
    b_Blk = 1;
    c_Blk = 1;
else
    b_Blk = slResolve(get_param(blkh,'b'),blkh,'expression');
    c_Blk = slResolve(get_param(blkh,'c'),blkh,'expression');
end
