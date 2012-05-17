function [m,d] = avifinfo(filename)
%AVIFINFO Text description of AVI-file contents.
%   AVIFINFO will be removed in a future release. Use MMREADER
%   instead.


% Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/07/27 20:16:14 $

warning('MATLAB:avifinfo:FunctionToBeRemoved', ...
    'AVIFINFO will be removed in a future release. Use MMREADER instead.'); 

try
    d = evalc('disp(aviinfo(filename))');
    m = 'AVI-File';
catch exception
    d = '';
    m = exception.message;
end
