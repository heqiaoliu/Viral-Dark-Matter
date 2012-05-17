function mCodeInfo = getMCodeInfo(this)
%GETMCODEINFO Get the mCodeInfo.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/05/20 03:03:16 $

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
        case 'n'
            vars{indx} = 'N';
            vals{indx} = num2str(specs.Order);
        case 'q'
            vars{indx} = 'Q';
            vals{indx} = num2str(specs.Q);
        case 'bw'
            vars{indx} = 'BW';
            vals{indx} = num2str(specs.BW);
        case 'gbw'
            vars{indx} = 'GBW';
            vals{indx} = num2str(specs.GBW);
        case 'l'
            vars{indx} = 'L';
            vals{indx} = num2str(specs.NumPeaksOrNotches);
        case 'nsh'
            vars{indx} = 'Nsh';
            vals{indx} = num2str(specs.ShelvingFilterOrder);
            
    end
end

mCodeInfo.Variables = vars;
mCodeInfo.Values    = vals;
mCodeInfo.Inputs    = {['''' this.CombType ''''] ...
    sprintf('''%s''', getSpecification(this, laState)), vars{:}};

% [EOF]
