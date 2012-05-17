function valid = validateValue(this, name, valueCell, minValue, maxValue, ...
        exclude, bIntegral, bFinite)
%VALIDATEVALUE attempt to validate a value.
%   If the value is invalid, then an error dialog will be displayed.
%
%   Function arguments
%   ------------------
%   NAME: the name by which the value will be referred to
%     in the error dialog (in case the value is not valid).
%   VALUE: the value for which validation is requested.
%   MIN: The minimum value for the value.
%   MAX: The maximum value for the value.
%   EXCLUDE: A list of values which the value may not take on.
%   BINTEGRAL: Indicates whether the value is a discrete integer.
%   BFINITE: Indicates whether the value is permitted to be infinite.

%   Copyright 2005-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/11/09 20:34:04 $
    valid=1;
    
    if nargin <= 7
        bFinite = true;
        if nargin <= 6
            bIntegral = true;
            if nargin <= 5
                exclude = [];
            end
        end
    end
    bNonEmpty = true;
    value = [valueCell{:}];

    % Potentially translate the name
    name = xlate(name);
    
    % Check the lower bound
    if any(value < minValue)
        doError( sprintf('Subset selection parameter %s must not be less than %s.',... 
            name, num2str(minValue)));     
    end

    % Check the upper bound
    if any(value > maxValue)
        doError( sprintf('Subset selection parameter %s must not be greater than %s.',... 
            name, num2str(maxValue)));
    end

    % Check the exclusion list
    for i=1:length(value)
        if any(value(i) == exclude)
            doError( sprintf('Subset selection parameter %s must not be equal to %s.',... 
                name, num2str(value)));
        end
    end

    % Determine if the value is required to be integral
    if bIntegral && any(fix(value) ~= value)
        doError( sprintf('Subset selection parameter %s must be an integer.',name));
    end

    % Determine if the value is required to be finite
    if bFinite && any(isinf(value))
        doError( sprintf('Subset selection parameter %s must be finite.',name));
    end

    % Determine if the value is required to be non-empty
    empty = cellfun('isempty', valueCell);
    if bNonEmpty && any(empty(:))
        doError( sprintf('Subset selection parameter %s must be non-empty.',name));
    end

    % Finally, thow an error which the caller should catch.
    if ~valid
        error('MATLAB:hdftool:validateValue:invalidValue', ...
              'At least one value is not valid.');
    end
    
    function doError( message )
        % If this is the first error, display it.
        if valid
            errordlg( message, 'Invalid subset selection parameter' );
            valid = 0;
        end
    end
end

