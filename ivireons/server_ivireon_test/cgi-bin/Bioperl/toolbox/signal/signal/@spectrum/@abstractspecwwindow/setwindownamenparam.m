function setwindownamenparam(this,varargin)
%SETWINDOWNAMENPARAM   Sets the WindowName and parameter if specified.
%   This functions allows us to use either a string or cell array to
%   set the WindowName property.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:17:25 $

winName = varargin{1};
if iscell(winName), % Window parameter specified.
    this.WindowName = winName{1};
    paramName = propstoaddtospectrum(this.Window);
    for k=1:min(length(paramName),length(winName)-1), 
        set(this,paramName{k},winName{k+1});
    end
else
    this.WindowName = winName;
end

% [EOF]
