function mCodeInfo = getMCodeInfo(this)
%GETMCODEINFO Get the mCodeInfo.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/04/11 20:36:40 $

laState = get(this, 'LastAppliedState');
specs   = getSpecs(this, laState);

% Convert the specification to a cell of specs
spec = getSpecification(this, laState);
specCell = textscan(spec, '%s', 'delimiter', ',');
specCell = specCell{1};

% Convert the cell of specs to variable names and vals.
vars  = cell(length(specCell), 1);
vals  = vars;

for indx = 1:length(specCell)
    switch lower(specCell{indx})
        case 'tw'
            vars{indx} = 'TW';
            vals{indx} = num2str(specs.TransitionWidth);
        case 'n'
            vars{indx} = 'N';
            vals{indx} = num2str(specs.Order);
        case 'ast'
            vars{indx} = 'Astop';
            vals{indx} = num2str(specs.Astop);
    end
end

mCodeInfo.Variables = vars;
mCodeInfo.Values    = vals;
mCodeInfo.Inputs    = {'''Type''', ['''' this.Type ''''] ...
    sprintf('''%s''', getSpecification(this, laState)), vars{:}};

% [EOF]
