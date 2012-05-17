function [validStructures, defaultStructure] = getValidStructures(this, flag)
%GETVALIDSTRUCTURES   Get the validStructures.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2009/10/16 06:38:14 $

validStructures = {};
defaultStructure = '';

% setup the FDesign appropriately based on the updated object.
setupFDesign(this);

% In the Simulink operating mode the saved specs could require a Filter
% Design Toolbox license that may not be available (read-only mode)
hd = get(this, 'FDesign');
setSpecsSafely(this, hd, getSpecification(this));

% Convert the FDesign to the appropriate multirate object.
hd = createMultiRateVersion(this, hd, this.FilterType, ...
    evaluatevars(this.Factor), evaluatevars(this.SecondFactor));

% Make sure the design method is valid
methodEntries = getValidMethods(this, 'short');
method = getSimpleMethod(this);
if any(strcmpi(method,methodEntries)),
    dopts = designoptions(hd, method);
    validStructures  = dopts.FilterStructure;
    defaultStructure = dopts.DefaultFilterStructure;
    
    % Remove unsupported structures
    if strcmpi(this.OperatingMode, 'Simulink')
        validStructures = setdiff(validStructures, {'fftfir', 'fftfirinterp'});
    end
    
    if nargin > 1 && strcmpi(flag, 'full')
        for indx = 1:length(validStructures)
            validStructures{indx} = convertStructure(this, validStructures{indx});
        end
        defaultStructure = convertStructure(this, defaultStructure);
    end
end


% [EOF]
