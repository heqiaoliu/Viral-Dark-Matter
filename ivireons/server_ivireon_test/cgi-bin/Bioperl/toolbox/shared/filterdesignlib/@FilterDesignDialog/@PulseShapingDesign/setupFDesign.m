function [success, msg] = setupFDesign(this, varargin)
%SETUPFDESIGN Setup the FDesign

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/10/16 06:38:55 $

success = true;
msg     = false;

hd = get(this, 'FDesign');

spec = getSpecification(this, varargin{:});
set(hd, 'PulseShape', this.PulseShape);
% In the Simulink operating mode the saved specs could require a Filter
% Design Toolbox license that may not be available (read-only mode)
setSpecsSafely(this, hd, spec);

if nargin > 1 && ~isempty(varargin{1})
    source = varargin{1};
else
    source = this;
end

% Evaluate the specifications
try
    specs = getSpecs(this, source);

    if strncmpi(source.FrequencyUnits, 'normalized', 10)
        normalizefreq(hd);
    else
        normalizefreq(hd, false, specs.InputSampleRate);
    end

    switch spec
        case 'ast,beta'
            setspecs(hd, specs.SamplesPerSymbol, specs.Astop, specs.Beta);
        case 'n,beta'
            setspecs(hd, specs.SamplesPerSymbol, specs.Order, specs.Beta);
        case 'nsym,beta'
            setspecs(hd, specs.SamplesPerSymbol, specs.NumberOfSymbols, specs.Beta);
        case 'nsym,bt'
            setspecs(hd, specs.SamplesPerSymbol, specs.NumberOfSymbols, specs.BT);
        otherwise
            fprintf('Finish %s\n', spec);
    end
catch e 
    success = false;
    msg     = cleanerrormsg(e.message);
end

% [EOF]
