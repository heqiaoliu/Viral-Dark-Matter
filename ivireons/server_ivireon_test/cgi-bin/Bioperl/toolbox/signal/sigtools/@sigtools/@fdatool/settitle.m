function settitle(hFDA,varargin)
%SETTITLE Changes the title of FDATool.
%   SETTITLE(HFDA, SUBTITLE) Changes the title of the FDATool session
%   specified by HFDA.  The new subtitle (everything to the left of the
%   delimiter) is specified by SUBTITLE.  If SUBTITLE is empty, FDATool
%   will use the default title (the filename), for example:
%
%   'Filter Design & Analysis Tool - [filename.fda]'
%
%   SETTITLE(HFDA, SUBTITLE, FIGTITLE) The new Figure title is 
%   specified by FIGTITLE.  If FIGTITLE is an empty string, FDATool
%   will use the default title ('Filter Design & Analysis Tool - ').
%
%   See also GETTITLE

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.3 $  $Date: 2007/12/14 15:21:26 $ 

error(nargchk(1,3,nargin,'struct'));

% If there is no input title, use ''.  This will change the title back to its default.
switch nargin
case 1,
    set(hFDA, 'FigureTitle', '');
    set(hFDA, 'SubTitle', '');
case 2,
    set(hFDA, 'SubTitle', strrep(varargin{1}, char(10), ' '));
case 3,
    set(hFDA, 'SubTitle', strrep(varargin{1}, char(10), ' '));
    set(hFDA, 'FigureTitle', strrep(varargin{2}, char(10), ' '));
end

% [EOF]
