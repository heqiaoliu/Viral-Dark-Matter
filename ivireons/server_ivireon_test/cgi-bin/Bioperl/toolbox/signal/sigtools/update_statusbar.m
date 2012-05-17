function update_statusbar(hFig, str, varargin)
%UPDATE_STATUSBAR Update the status of the status bar
%   UPDATE_STATUSBAR(hFIG, STR) Update the status to the string STR.
%
%   See also RENDER_STATUSBAR.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.7 $  $Date: 2009/01/05 17:59:55 $ 

error(nargchk(2,inf,nargin,'struct'));

if rem(length(varargin), 2),
    error(generatemsgid('Nargchk'),'Too many input arguments.');
end

msg = [];
if ~ishghandle(hFig, 'figure')
    msg = 'The first input must be a figure handle';
end
if ~ischar(str), 
    msg = 'The second input argument must be a string';
end
if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

% Make sure the string is only one line of text.
str(find(str == char(10))) = ' ';
str = str';
str = str(:)';

h = siggetappdata(hFig, 'siggui', 'StatusBar');
if ~isempty(h),
    set(h, varargin{:}, 'String', str);
    drawnow;
end

% [EOF]
