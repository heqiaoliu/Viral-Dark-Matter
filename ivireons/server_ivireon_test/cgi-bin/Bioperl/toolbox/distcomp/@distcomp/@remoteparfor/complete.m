function complete(obj)
; %#ok Undocumented

%   Copyright 2007-2008 The MathWorks, Inc.

%   $Revision: 1.1.6.2 $  $Date: 2008/05/19 22:45:19 $


delete(obj.ObjectBeingDestroyedListener);
obj.ObjectBeingDestroyedListener = [];

% We get into this function both during normal parfor execution as well as when
% the user code throws an error.  In both cases, this is our one and only chance
% to flush partial lines that may be pending in the command window output.

% Function to display the Strings in a Java String array.
dispStringArray = @(msgs) cellfun(@(msg) disp(char(msg)), cell(msgs));
output = obj.ParforController.getDrainableOutput;
dispStringArray(output.drainAllOutput());
