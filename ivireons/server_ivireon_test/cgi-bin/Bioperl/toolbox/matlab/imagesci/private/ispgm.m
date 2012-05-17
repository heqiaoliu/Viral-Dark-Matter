function tf = ispgm(filename)
%ISPGM Returns true for a PGM file.
%   TF = ISPGM(FILENAME)

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/03/09 19:22:22 $

fid = fopen(filename, 'r', 'ieee-le');
if (fid < 0)
    tf = false;
else
    [sig,count] = fread(fid, 3, 'uint8');
    fclose(fid);
	if ( count ~= 3 )
		tf = false;
		return
	end
    tf = (isequal(sig(1:2), [80;50]) || isequal(sig(1:2), [80;53])) && ...
         (isequal(sig(3), 10) || ...  % \n
          isequal(sig(3), 13) || ...  % \r
          isequal(sig(3), 35) || ...  % "#"
          isequal(sig(3), 9)  || ...  % \t
          isequal(sig(3), 32));       % space
end
