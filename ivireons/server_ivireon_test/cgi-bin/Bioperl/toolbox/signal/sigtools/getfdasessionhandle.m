function h = getfdasessionhandle(hFig)
%GETFDASESSIONHANDLE  Return the handle to an FDATool session.

%   Author(s): R. Losada
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2009/01/05 17:59:49 $ 

if isempty(hFig) || ~ishghandle(hFig),
    h = [];
else
    h = siggetappdata(hFig, 'fdatool', 'handle');
end

% [EOF]
