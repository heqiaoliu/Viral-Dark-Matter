function watchoff(figNumber)
%WATCHOFF Sets the current figure pointer to the arrow.
%   WATCHOFF(figNumber) will set the figure figNumber's pointer
%   to an arrow. If no argument is given, figNumber is taken to
%   be the current figure.
%
%   See also WATCHON.

%   Ned Gulley, 6-21-93
%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 5.8.4.3 $  $Date: 2009/10/24 19:17:44 $

if nargin<1
    figNumber=gcf;
end

% If watchon is used before a window has been opened, it will set the
% figNumber to the flag NaN.  In addition it is generally desirable to not
% error if the window has been closed between calls to watchon and
% watchoff.  ishghandle handles both of these cases.
if ishghandle(figNumber)
    set(figNumber,'Pointer','arrow');
end
