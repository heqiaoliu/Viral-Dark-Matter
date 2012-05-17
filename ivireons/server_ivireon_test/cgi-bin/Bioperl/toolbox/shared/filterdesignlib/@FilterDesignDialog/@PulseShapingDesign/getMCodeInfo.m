function mCodeInfo = getMCodeInfo(this)
%GETMCODEINFO Get the mCodeInfo.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/05/23 08:10:56 $

laState = get(this, 'LastAppliedState');

specs = getSpecs(this, laState);

vars = {'SPS'};
vals = {mat2str(specs.SamplesPerSymbol)};
desc = {'Samples per Symbol'};

singleRateFlag = 0;
if strncmpi(this.FilterType, 'single', 6)
    vars = [vars 'PulseShape'];
    vals = [vals sprintf('''%s''', this.PulseShape)];
    desc = [desc 'Pulse shape'];
    singleRateFlag = 1;
end
spec = getSpecification(this);

switch lower(spec)
    case 'ast,beta'
        specvars = {'Astop', 'Beta'};
        vals = [vals, {mat2str(specs.Astop), mat2str(specs.Beta)}];
        desc = [desc, {'Stopband Attenuation', 'Rolloff Factor'}];
    case 'nsym,beta'
        specvars = {'Nsym', 'Beta'};
        vals = [vals, {mat2str(specs.NumberOfSymbols), mat2str(specs.Beta)}];
        desc = [desc, {'Number of Symbols', 'Rolloff Factor'}];
    case 'n,beta'
        specvars = {'N', 'Beta'};
        vals = [vals, {mat2str(specs.Order), mat2str(specs.Beta)}];
        desc = [desc, {'Filter Order', 'Rolloff Factor'}];
    case 'nsym,bt'
        specvars = {'Nsym', 'BT'};
        vals = [vals, {mat2str(specs.NumberOfSymbols), mat2str(specs.BT)}];
        desc = [desc, {'Number of Symbols', 'Bandwidth-Time Product'}];
    otherwise
        fprintf('Finish %s', spec);
end

mCodeInfo.Variables    = [vars specvars];
mCodeInfo.Values       = vals;
mCodeInfo.Descriptions = desc;
if ~singleRateFlag
    mCodeInfo.Inputs   = [{'SPS', sprintf('''%s''', spec)}, specvars];
else
    mCodeInfo.Inputs   = [{'SPS', 'PulseShape', sprintf('''%s''', spec)}, specvars];
end
% [EOF]
