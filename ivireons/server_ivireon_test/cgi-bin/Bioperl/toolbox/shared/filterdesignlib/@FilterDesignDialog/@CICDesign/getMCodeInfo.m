function mCodeInfo = getMCodeInfo(this)
%GETMCODEINFO Get the mCodeInfo.
%   OUT = GETMCODEINFO(ARGS) <long description>

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:28:17 $

laState = get(this, 'LastAppliedState');
specs   = getSpecs(this, laState);

variables = {'D', 'Fpass', 'Astop'};
values    = {num2str(specs.DifferentialDelay), num2str(specs.Fpass), ...
    num2str(specs.Astop)};
descs     = {'Differential delay', '', ''};
inputs    = {'D', '''Fp,Ast''', 'Fpass', 'Astop'};

mCodeInfo.Variables    = variables;
mCodeInfo.Values       = values;
mCodeInfo.Inputs       = inputs;
mCodeInfo.Descriptions = descs;

% [EOF]
