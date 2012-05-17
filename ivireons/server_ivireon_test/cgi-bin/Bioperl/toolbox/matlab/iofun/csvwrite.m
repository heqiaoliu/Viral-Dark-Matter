function csvwrite(filename, m, r, c)
%CSVWRITE Write a comma separated value file.
%   CSVWRITE(FILENAME,M) writes matrix M into FILENAME as 
%   comma separated values.
%
%   CSVWRITE(FILENAME,M,R,C) writes matrix M starting at offset 
%   row R, and column C in the file.  R and C are zero-based,
%   that is R=C=0 specifies first number in the file.
%
%   See also CSVREAD, DLMREAD, DLMWRITE.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 5.10.4.4.4.1 $  $Date: 2010/06/24 19:34:33 $

%
% test for proper filename
%
if ~ischar(filename)
    error('MATLAB:csvwrite:FileNameMustBeString',...
        'FILENAME must be a string.');
end

%
% Call dlmwrite with a comma as the delimiter
%
if nargin < 3
    r = 0;
end
if nargin < 4
    c = 0;
end
dlmwrite(filename, m, ',', r, c);
