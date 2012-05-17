function fid = analyze75open(filename, ext, mode, defaultByteOrder)
% Open an Analyze 7.5 file.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:30:43 $



% Ensure that filename has a .hdr extension
[pname, fname, passedExt] = fileparts(filename);

if ~isempty(passedExt)
    switch lower(passedExt)
    case {'.hdr','.img'}
        % The file has the correct extension.
            
    otherwise
        eid = 'Images:analyze75info:invalidFileFormat';
        error(eid, 'Invalid format "%s". Valid formats include "hdr" and "img".', passedExt);
        
    end  % switch
end  % if

filename = fullfile(pname, [fname '.' ext]);

if (nargin < 4)
    defaultByteOrder = 'ieee-be';
end

% Open the file with the default ByteOrder.
fid = fopen(filename, mode, defaultByteOrder);

if (fid == -1)
    eid = 'Images:isanalyze75:hdrFileOpen';
    if ~isempty(dir(filename))
        error(eid, ['Unable to open file "%s" for reading;\n' ...
              ' you may not have read permission.'], filename);
    else
        error(eid, 'File "%s" does not exist.', filename);
    end  % if

end
