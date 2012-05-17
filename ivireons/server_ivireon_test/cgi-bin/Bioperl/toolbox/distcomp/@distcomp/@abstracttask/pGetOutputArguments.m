function val = pGetOutputArguments(task, val, RETHROW_ERROR)
; %#ok Undocumented
%pGetOutputArguments 
%
%  VAL = pGetOutputArguments(TASK, VAL)

%  Copyright 2005-2007 The MathWorks, Inc.

%  $Revision: 1.1.10.4 $    $Date: 2008/02/02 12:59:40 $ 

if nargin < 3
    RETHROW_ERROR = false;
end

serializer = task.Serializer;

if ~isempty(serializer)
    try
        val = serializer.getField(task, 'argsout');
    catch exception
        if RETHROW_ERROR
            rethrow(exception)
        end
        % This method must return a cell array.
        val = cell(1, 0);    
    end
end