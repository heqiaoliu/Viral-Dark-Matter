function mCodeInfo = getMCodeInfo(this)
%GETMCODEINFO Get the mCodeInfo.
%   OUT = GETMCODEINFO(ARGS) <long description>

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:29:18 $

laState = get(this, 'LastAppliedState');
specs   = getSpecs(this, laState);

% Convert the specification to a cell of specs
spec = getSpecification(this, laState);
specCell = textscan(spec, '%s', 'delimiter', ',');
specCell = specCell{1};

% Convert the cell of specs to variable names and vals.
vars  = cell(length(specCell)+1, 1);
vals  = vars;

vars{1} = 'B';
vals{1} = num2str(specs.Band{1});

for indx = 1:length(specCell)
    switch lower(specCell{indx})
        case 'tw'
            vars{indx+1} = 'TW';
            vals{indx+1} = num2str(specs.TransitionWidth);
        case 'n'
            vars{indx+1} = 'N';
            vals{indx+1} = num2str(specs.Order);
        case 'ast'
            vars{indx+1} = 'Astop';
            vals{indx+1} = num2str(specs.Astop);
    end
end

mCodeInfo.Variables = vars;
mCodeInfo.Values    = vals;
mCodeInfo.Inputs    = {vars{1}, ...
    sprintf('''%s''', getSpecification(this, laState)), vars{2:end}};

% [EOF]
