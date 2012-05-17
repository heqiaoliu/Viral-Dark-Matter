function wk1wrec(fid, rectype, vreclen)
%WK1WREC Write a WK1 record header.
%   WK1WREC(FID, RECTYPE, VRECLEN) writes out the WK1 record header
%   where RECTYPE(1) contains the record type, and RECTYPE(2) = -1
%   for fixed length records.
%   VRECLEN is the length for variable length records.
%
%   WK1WREC will be removed in a future release. 
%
%   See also WK1WRITE, WK1READ.

%   Brian M. Bourgault 10/22/93
%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 5.8.4.2 $  $Date: 2009/11/16 22:26:52 $

%
%   Write out the record type
%
fwrite(fid, rectype(1), 'ushort');

%
%   Write out the record length
%
if rectype(2) ~= -1
    % fixed length records
    fwrite(fid, rectype(2), 'ushort');
else
    % variable length records
    fwrite(fid, vreclen, 'ushort');
end

