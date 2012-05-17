function createcfile(h, s)
%CREATECFILE Create a cfile given the data in s

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.3.4.5 $  $Date: 2004/12/26 22:21:15 $

fid = fopen(s.file,'wt');
if fid == -1,
    error(generatemsgid('invalidFid'), ...
        'It appears that you do not have permission to write to the specified directory.  Try changing directories.');
end
tbx = 'signal';
if isfdtbxinstalled && isprop(h.Filter, 'Arithmetic')
    if ~strcmpi(h.Filter.Arithmetic, 'double')
        tbx = 'filterdesign';
    end
end

exportcoeffgen(s, fid, tbx);
fclose(fid);

sendstatus(h, 'C file generated');

% [EOF]
