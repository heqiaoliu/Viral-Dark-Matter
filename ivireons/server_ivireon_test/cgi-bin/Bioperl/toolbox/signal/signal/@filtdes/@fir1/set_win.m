function win = set_win(h,win)
%SET_WIN Set the window property.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2007/12/14 15:12:32 $

error(nargchk(2,2,nargin,'struct'));


if ~isempty(findprop(h,'orderMode')) & isdynpropenab(h,'orderMode'),
    ordMode = get(h,'orderMode');
    
    % If trying to set window other than kaiser in minimum mode, error
    if strcmpi(ordMode,'minimum') & ~strcmpi(win,'kaiser'),
        error(generatemsgid('NotSupported'),'Minimum order is not supported for that window.');
    end
end

