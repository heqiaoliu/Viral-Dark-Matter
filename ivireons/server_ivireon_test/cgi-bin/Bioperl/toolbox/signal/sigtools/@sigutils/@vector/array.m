function a = array(this)
%ARRAY Convert the vector to an array
%   H.ARRAY Converts the vector to an array, if possible.  If we have mixed
%   numbers and characters, the numbers will be converted to characters.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:46:06 $

try,
    a = [this.Data{:}];
catch
    error(generatemsgid('ValuesNotSameType'), ...
        'All values in vector must be of the same type to convert to an array.');
end

% [EOF]
