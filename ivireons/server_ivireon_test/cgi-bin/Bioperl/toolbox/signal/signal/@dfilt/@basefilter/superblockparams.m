function [lib, srcblk, s] = superblockparams(Hd, mapstates, link2obj, varname)
%SUPERBLOCKPARAMS   

%   Author(s): R. Losada
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/02/14 20:37:56 $

try
    [lib, srcblk] = blocklib(Hd);
catch
    error(generatemsgid('noBlock'),'The filter %s does not support the BLOCK command.',varname);
end

if strcmpi(link2obj,'on'),    
    s = objblockparams(Hd, varname);   
else
    s = blockparams(Hd, mapstates);
end

% [EOF]
