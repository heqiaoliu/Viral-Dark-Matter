function out = dct_arch
%DCT_ARCH - return the architecture directory component
%   arch = DCT_ARCH returns the current computer architecture.

% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2006/06/27 22:33:12 $


persistent cachedValue

if isempty( cachedValue )
    if ispc
        switch computer
          case 'PCWIN'
            cachedValue = 'win32';
          case 'PCWIN64'
            cachedValue = 'win64';
          otherwise
            error( 'distcomp:dct_arch:unknownarch', ...
                   'The output "%s" from "computer" was unknown', computer );
        end
    else
        cachedValue = lower( computer );
    end
end
out = cachedValue;