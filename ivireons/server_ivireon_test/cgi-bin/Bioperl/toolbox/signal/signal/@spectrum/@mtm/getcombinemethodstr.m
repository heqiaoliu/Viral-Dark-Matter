function combineMethodStr = getcombinemethodstr(this)
%GETCOMBINEMETHODSTR   Get string accepted by the pmtm function.
%
% This is a private method.

%   Author(s): P. Pacheco
%   Copyright 2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:17:26 $

% Convert CombineMethod enum type to strings accepted by the function.
combinemethod = lower(this.CombineMethod);
if strcmpi(combinemethod,'adaptive'),
    combineMethodStr = 'adapt';
    
elseif strcmpi(combinemethod,'unity'),
    combineMethodStr = 'unity';
    
elseif strcmpi(combinemethod,'eigenvector'),
    combineMethodStr = 'eigen';
end

% [EOF]
