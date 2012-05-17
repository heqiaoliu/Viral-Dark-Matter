function tf = isppm(filename)
%ISPPM Returns true for a PPM file.
%   TF = ISPPM(FILENAME)

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/03/09 19:22:24 $

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
    tf = (isequal(sig(1:2), [80;51]) || isequal(sig(1:2), [80;54])) && ...
         (isequal(sig(3), 10) || ...  % \n
          isequal(sig(3), 13) || ...  % \r
          isequal(sig(3), 35) || ...  % "#"
          isequal(sig(3), 9)  || ...  % \t
          isequal(sig(3), 32));
end
