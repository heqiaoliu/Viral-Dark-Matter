function ext = ptxext(all)

%   Copyright 2010 The MathWorks, Inc.

persistent exts;
persistent archs;

if isempty(exts) 
    exts  = {'ptxglx' 'ptxa64'  'ptxmaci' 'ptxmaci64' 'ptxw32' 'ptxw64'};
    archs = {'glnx86' 'glnxa64' 'maci'    'maci64'    'win32'  'win64'};
end

if nargin == 0 
    ext = exts{strcmp(archs, dct_arch)};
elseif nargin > 0 && ischar(all) && strcmp(all, 'all')
    ext = struct('ext', exts, 'arch', archs);
else
    error('parallel:gpu:InvalidInput', 'Input must be ''all''');
end
