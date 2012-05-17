function mCodeInfo = getMCodeInfo(this)
%GETMCODEINFO Get the mCodeInfo.
%   OUT = GETMCODEINFO(ARGS) <long description>

%   Author(s): J. Schickler
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/04/11 20:36:37 $

laState = get(this, 'LastAppliedState');

specs = getSpecs(this, laState);

switch lower(getSpecification(this, laState))
    case 'n,f,a'
        vars = {'N', 'F', 'A'};
        vals = {num2str(specs.Order), mat2str(specs.Band1.Frequencies), ...
            mat2str(specs.Band1.Amplitudes)};
    case 'nb,na,f,a'
        vars = {'Nb', 'Na', 'F', 'A'};
        vals = {num2str(specs.Order), num2str(specs.DenominatorOrder), ...
            mat2str(specs.Band1.Frequencies), mat2str(specs.Band1.Amplitudes)};
    case 'n,b,f,a'
        
        vars = cell(2+specs.NumberOfBands*2, 1);
        vals = vars;
        
        vars(1:2) = {'N', 'B'};
        vals(1:2) = {num2str(specs.Order), num2str(specs.NumberOfBands)};
              
        for indx = 1:specs.NumberOfBands
            band = specs.(sprintf('Band%d', indx));
            vars{2+2*indx-1} = sprintf('F%d', indx);
            vars{2+2*indx} = sprintf('A%d', indx);
            vals{2+2*indx-1} = mat2str(band.Frequencies);
            vals{2+2*indx} = mat2str(band.Amplitudes);
        end
    case 'nb,na,b,f,a'
        vars = cell(3+specs.NumberOfBands*2, 1);
        vals = vars;
        
        vars(1:3) = {'Nb', 'Na', 'B'};
        vals(1:3) = {num2str(specs.Order), num2str(specs.DenominatorOrder), ...
            num2str(specs.NumberOfBands)};
        
        for indx = 1:specs.NumberOfBands
            band = specs.(sprintf('Band%d', indx));
            vars{3+2*indx-1} = sprintf('F%d', indx);
            vars{3+2*indx} = sprintf('A%d', indx);
            vals{3+2*indx-1} = mat2str(band.Frequencies);
            vals{3+2*indx} = mat2str(band.Amplitudes);
        end
    case 'n,f,h'
        vars = {'N', 'F', 'H'};
        vals = {num2str(specs.Order), mat2str(specs.Band1.Frequencies), ...
            mat2str(specs.Band1.FreqResp)};
        
    case 'nb,na,f,h'
        vars = {'NB', 'Na', 'F', 'H'};
        vals = {num2str(specs.Order), num2str(specs.DenominatorOrder), ...
            mat2str(specs.Band1.Frequencies), mat2str(specs.Band1.FreqResp)};
    case 'n,b,f,h'
        vars = cell(2+specs.NumberOfBands*2, 1);
        vals = vars;

        vars(1:2) = {'N', 'B'};
        vals(1:2) = {num2str(specs.Order), num2str(specs.NumberOfBands)};
        
        for indx = 1:specs.NumberOfBands
            band = specs.(sprintf('Band%d', indx));
            
            vars{2+2*indx-1} = sprintf('F%d', indx);
            vals{2+2*indx-1} = mat2str(band.Frequencies);

            vars{2+2*indx} = sprintf('H%d', indx);
            vals{2+2*indx} = mat2str(band.FreqResp);
        end
end

mCodeInfo.Variables = vars(:);
mCodeInfo.Values    = vals(:);

% [EOF]
