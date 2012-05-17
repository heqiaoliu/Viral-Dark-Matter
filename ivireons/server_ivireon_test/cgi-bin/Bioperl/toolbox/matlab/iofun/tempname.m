function tmp_name = tempname(dirname)
%TEMPNAME Get temporary file.
%   TEMPNAME returns a unique name, starting with the directory returned by 
%   TEMPDIR, suitable for use as a temporary file.
%
%   TMP_NAME = TEMPNAME(DIRNAME) uses DIRNAME as the directory instead of
%   TEMPDIR.
%
%   Note: When running MATLAB without the JVM, the filename that tempname 
%   generates is not guaranteed to be absolutely unique.
%
%   See also TEMPDIR.

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 5.12.4.1 $  $Date: 2007/05/23 18:54:38 $

if nargin == 0
    dirname = tempdir;
elseif ~ischar(dirname) || size(dirname, 1) ~= 1
    error('MATLAB:tempname:MustBeString', 'The input argument to TEMPNAME must be a string row vector.');
end

if usejava('jvm')
    tmp_name = fullfile(dirname, ['tp' strrep(char(java.util.UUID.randomUUID),'-','_')]);
else
    tmp_name = fullfile(dirname,['tp' num2str(feature('timing','cpucount'))]);
end