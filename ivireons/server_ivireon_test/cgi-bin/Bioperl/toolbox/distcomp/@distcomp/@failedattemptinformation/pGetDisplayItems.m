function cellargout = pGetDisplayItems(obj, inStruct)
; %#ok Undocumented
% gets the common display structure. Outputs a cell arrays of inStructs.

% Copyright 2008 The MathWorks, Inc.

% $Revision: 1.1.6.1 $  $Date: 2008/05/19 22:44:53 $

cellargout = cell(1, 1); % initialise number of output arguments
mainStruct = inStruct;

mainStruct.Type = 'failedattemptinformation';
mainStruct.Header = 'Failed Attempt';
mainStruct.Names = {'StartTime', 'ErrorIdentifier', 'ErrorMessage', ...
                    'CommandWindowOutput', 'Worker'};
mainStruct.Values = {obj.StartTime, obj.ErrorIdentifier, obj.ErrorMessage, ...
                     obj.CommandWindowOutput, obj.Worker};

cellargout{1} = mainStruct;

                 