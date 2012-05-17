function varargout = validateSource(this, source)
%VALIDATESOURCE Validate the source

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/05/20 03:08:12 $

if nargin < 2
    source = this.Application.DataSource;
end
b = true;
exception = MException.empty;
maxDims = getMaxDimensions(source);
if size(maxDims) < 3 
    varargout = {b, exception};
    return;
end

nInputs = getNumInputs(source);


if nInputs == 3  
    % For 3x2 data, if there are more than 2 columns of data in any dimension, then this is not a video signal.
    % Or for 1x3 data, if there are more than 3 columns in the dimension, then this is not a videl signal    
    if (size(maxDims, 1) == 3 && (size(maxDims, 2) > 2 && any(maxDims(:, 3) ~= 1))) || ...
            size(maxDims, 1) == 1 && (numel(maxDims) > 3 || (maxDims(3) ~= 1 && maxDims(3) ~= 3))
        b = false;
        exception = MException('Spcuilib:Video:InvalidSignalDimensions', 'There must be exactly 1 or 3 components selected for video signals');
    end
    
    % When we have more than 1 input, make sure that all the datatypes make
    % sense together.
    dataTypes = getDataTypes(source);
    if numel(unique(dataTypes)) > 1
        b = false;
        exception = MException('Spcuilib:Video:DataTypeMismatch', 'Video signals must all be the same data type.');
    end
    
    maxDims = unique(maxDims, 'rows');
    if size(maxDims, 1) ~= 1
        b = false;
        exception = MException('Spcuilib:Video:InvalidSignalDimensions', 'There must be exactly 1 or 3 components selected for video signals');
    end
elseif nInputs == 1
    if numel(maxDims) > 2
        
        if numel(maxDims) > 3 || (maxDims(3) ~= 1 && maxDims(3) ~= 3)
            b = false;
            exception = MException('Spcuilib:Video:InvalidSignalDimensions', 'There must be exactly 1 or 3 components selected for video signals');
        end
    end
else
    b = false;
    exception = MException('Spcuilib:Video:InvalidSignalDimensions', 'There must be exactly 1 or 3 components selected for video signals');
end

if nargout
    varargout = {b, exception};
elseif ~b
    throw(exception);
end

% [EOF]
