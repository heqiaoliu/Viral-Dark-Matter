function success = action(hEH)
%ACTION Perform the action of the Export Header Dialog

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.7.4.3 $  $Date: 2004/04/13 00:23:04 $

if validate_filename(hEH),
    success = true;
    
    % Create the header file
    createcfile(hEH, generate_exportdata(hEH));
    
else
    success = false;
end

% [EOF]
