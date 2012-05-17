function checkFilename(filename)
%checkFilename checks that the given variable is a MATLAB char array.   

% Copyright 2009 The MathWorks, Inc.

    if (~ischar(filename))
        throw(MException('MATLAB:editor:NotAFilename', 'File name should be a MATLAB char array.'));
    end
end