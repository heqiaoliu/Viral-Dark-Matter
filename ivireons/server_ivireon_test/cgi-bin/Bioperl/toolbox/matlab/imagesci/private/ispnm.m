function tf = ispnm(filename)
%ISPBM Returns true for a PNM file (PBM, PGM, or PPM).
%   TF = ISPBM(FILENAME)

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/03/09 19:22:23 $

fid = fopen(filename, 'r', 'ieee-le');
if (fid < 0)
    tf = false;
else
    [sig, count] = fread(fid, 3, 'uint8');
    fclose(fid);
	if ( count ~= 3 )
		tf = false;
		return
	end
    tf = ((isequal(sig(1:2), [80;49])  || ...  % PBM
           isequal(sig(1:2), [80;52])) || ...  % PBM
          (isequal(sig(1:2), [80;50])  || ...  % PGM
           isequal(sig(1:2), [80;53])) || ...  % PGM
          (isequal(sig(1:2), [80;51])  || ...  % PPM
           isequal(sig(1:2), [80;54]))) && ... % PPM
         (isequal(sig(3), 10) || ...  % \n
          isequal(sig(3), 13) || ...  % \r
          isequal(sig(3), 35) || ...  % "#"
          isequal(sig(3), 9)  || ...  % \t
          isequal(sig(3), 32));       % space
end
