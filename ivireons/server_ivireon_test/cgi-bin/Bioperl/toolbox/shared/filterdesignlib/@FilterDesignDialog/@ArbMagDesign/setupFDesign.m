function [success, msg] = setupFDesign(this, varargin)
%SETUPFDESIGN   Setup the contained FDesign.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/10/16 06:38:25 $

success = true;
msg     = '';

hd = get(this, 'FDesign');

% Check that the FDesign matches the response type and update if it doesnt.
if strcmpi(this.ResponseType, 'amplitudes')
    if ~isa(hd, 'fdesign.arbmag')
        hd = fdesign.arbmag;
        set(this, 'FDesign', hd);
    end
else
    if ~isa(hd, 'fdesign.arbmagnphase')
        hd = fdesign.arbmagnphase;
        set(this, 'FDesign', hd);
    end
end

if nargin > 1 && ~isempty(varargin{1})
    source = varargin{1};
else
    source = this;
end

spec = getSpecification(this, source);

% In the Simulink operating mode the saved specs could require a Filter
% Design Toolbox license that may not be available (read-only mode)
setSpecsSafely(this, hd, spec);

if isprop(hd, 'NBands')
    set(hd, 'NBands', source.NumberOfBands+1);
end

% Evaluate the specifications.  If any of the evaluations fail, leave early
% and only update the Specification.
try
    specs = getSpecs(this, source);

    if strncmpi(specs.FrequencyUnits, 'normalized', 10)
        normalizefreq(hd);
    else
        normalizefreq(hd, false, specs.InputSampleRate);
    end

    switch spec
        case 'N,F,A'
            setspecs(hd, specs.Order, specs.Band1.Frequencies, specs.Band1.Amplitudes);
        case 'Nb,Na,F,A'
            setspecs(hd, specs.Order, specs.DenominatorOrder, ...
                specs.Band1.Frequencies, specs.Band1.Amplitudes);
        case 'N,B,F,A'

            inputs = cell(1, 2+2*specs.NumberOfBands);
            inputs{1} = specs.Order;
            inputs{2} = specs.NumberOfBands;
            for indx = 1:specs.NumberOfBands
                band_str = sprintf('Band%d', indx);
                inputs{2*indx+1} = specs.(band_str).Frequencies;
                inputs{2*indx+2} = specs.(band_str).Amplitudes;
            end
            setspecs(hd, inputs{:});

        case 'Nb,Na,B,F,A'

            inputs = cell(1, 3+2*specs.NumberOfBands);
            inputs{1} = specs.Order;
            inputs{2} = specs.DenominatorOrder;
            inputs{3} = specs.NumberOfBands;
            for indx = 1:specs.NumberOfBands
                band_str = sprintf('Band%d', indx);
                inputs{2*indx+2} = specs.(band_str).Frequencies;
                inputs{2*indx+3} = specs.(band_str).Amplitudes;
            end
            setspecs(hd, inputs{:});
        case 'N,F,H'
            inputs = {specs.Order, specs.Band1.Frequencies, specs.Band1.FreqResp};
            setspecs(hd, inputs{:});
        case 'Nb,Na,F,H'
            inputs = {specs.Order, specs.DenominatorOrder, ...
                specs.Band1.Frequencies, specs.Band1.FreqResp};
            setspecs(hd, inputs{:});
        case 'N,B,F,H'

            inputs = cell(1, 2+2*specs.NumberOfBands);

            inputs{1} = specs.Order;
            inputs{2} = specs.NumberOfBands;
            for indx = 1:specs.NumberOfBands
                inputs{2*indx+1} = specs.(sprintf('Band%d', indx)).Frequencies;
                inputs{2*indx+2} = specs.(sprintf('Band%d', indx)).FreqResp;
            end
            setspecs(hd, inputs{:});

        case 'Nb,Na,B,F,H'

            inputs = cell(1, 3+2*specs.NumberOfBands);
            inputs{1} = specs.Order;
            inputs{2} = specs.DenominatorOrder;
            inputs{3} = specs.NumberOfBands;

            for indx = 1:specs.NumberOfBands
                inputs{2*indx+2} = specs.(sprintf('Band%d', indx)).Frequencies;
                inputs{2*indx+3} = specs.(sprintf('Band%d', indx)).FreqResp;
            end
            setspecs(hd, inputs{:});
        otherwise
            disp(sprintf('Finish %s', spec));
    end
catch e 
    success = false;
    msg     = cleanerrormsg(e.message);
end

% [EOF]
