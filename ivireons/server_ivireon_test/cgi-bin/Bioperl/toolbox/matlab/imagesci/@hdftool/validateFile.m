function success = validateFile(filename)
%VALIDATEFILE Validates that the specified file is indeed a HDF file.
%   This function should be used prior to opening an HDF file.
%
%   Function arguments
%   ------------------
%   FILENAME: the name of the file to validate.

%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/11/15 01:10:52 $

    % Find and open the file
    fid = fopen(filename,'r');
    if (fid == -1)
        error('MATLAB:hdftool:fileOpen', ...
            'Can''t open file "%s" for reading;\n it may not exist, or you may not have read permission.', ...
            filename);
    else
        filename = fopen(fid);
        fclose(fid);
    end

    % Determine if the file is HDF.
    success = hdfh('ishdf',filename);

end

