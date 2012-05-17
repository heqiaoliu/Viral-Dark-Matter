function mCodeInfo = getMCodeInfo(this)
%GETMCODEINFO Get the mCodeInfo.
%   OUT = GETMCODEINFO(ARGS) <long description>

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:29:21 $

laState = get(this, 'LastAppliedState');
specs   = getSpecs(this, laState);

variables = {'B', 'N', 'F0'};
values    = {num2str(specs.BandsPerOctave), num2str(specs.Order), ...
    num2str(specs.F0)};
descs     = {'Bands per octave', '', 'Center frequency'};
inputs    = {'B', '''Class 0''', '''N,F0''', 'N', 'F0'};

mCodeInfo.Variables    = variables;
mCodeInfo.Values       = values;
mCodeInfo.Inputs       = inputs;
mCodeInfo.Descriptions = descs;

% [EOF]
