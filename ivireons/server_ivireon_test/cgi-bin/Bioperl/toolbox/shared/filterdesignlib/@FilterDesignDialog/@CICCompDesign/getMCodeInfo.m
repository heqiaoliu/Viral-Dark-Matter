function mCodeInfo = getMCodeInfo(this)
%GETMCODEINFO Get the mCodeInfo.
%   OUT = GETMCODEINFO(ARGS) <long description>

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:28:11 $

laState = get(this, 'LastAppliedState');
specs   = getSpecs(this, laState);

% Convert the specification to a cell of specs
spec = getSpecification(this, laState);
specCell = textscan(spec, '%s', 'delimiter', ',');
specCell = specCell{1};

% Convert the cell of specs to variable names and vals.
vars  = cell(length(specCell)+2, 1);
vals  = vars;
descs = vars;

vars{1}  = 'delay';
vals{1}  = num2str(specs.DifferentialDelay);
descs{1} = 'Differential Delay';

vars{2}  = 'NSecs';
vals{2}  = num2str(specs.NumberOfSections);
descs{2} = 'Number of Sections';


for indx = 1:length(specCell)
    switch lower(specCell{indx})
        case 'n'
            vars{indx+2} = 'N';
            vals{indx+2} = num2str(specs.Order);
        case 'ast'
            vars{indx+2} = 'Astop';
            vals{indx+2} = num2str(specs.Astop);
        case 'fp'
            vars{indx+2} = 'Fpass';
            vals{indx+2} = num2str(specs.Fpass);
        case 'fst'
            vars{indx+2} = 'Fstop';
            vals{indx+2} = num2str(specs.Fstop);
        case 'fc'
            vars{indx+2} = 'F6dB';
            vals{indx+2} = num2str(specs.F6dB);
        case 'ap'
            vars{indx+2} = 'Apass';
            vals{indx+2} = num2str(specs.Apass);
        case 'ast'
            vars{indx+2} = 'Astop';
            vals{indx+2} = num2str(specs.Astop);
    end
end

mCodeInfo.Variables    = vars;
mCodeInfo.Values       = vals;
mCodeInfo.Inputs       = {vars{1:2}, ...
    sprintf('''%s''', getSpecification(this, laState)), vars{3:end}};
mCodeInfo.Descriptions = descs;

% [EOF]
