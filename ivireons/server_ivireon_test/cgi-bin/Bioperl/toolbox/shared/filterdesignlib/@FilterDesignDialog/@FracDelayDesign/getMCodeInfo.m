function mCodeInfo = getMCodeInfo(this)
%GETMCODEINFO Get the mCodeInfo.
%   OUT = GETMCODEINFO(ARGS) <long description>

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:28:25 $

laState = get(this, 'LastAppliedState');
specs   = getSpecs(this, laState);

mCodeInfo.Variables    = {'delay', 'N'};
mCodeInfo.Values       = {num2str(specs.FracDelay), num2str(specs.Order)};
mCodeInfo.Descriptions = {'Fractional Delay', ''};
mCodeInfo.Inputs       = {'delay', '''n''', 'N'};

% [EOF]
