function varargout = screenMsg(this, varargin)
%SCREENMSG  Display a text message centered in the scope window
%  screenMsg('text') turns on and display 'text' in the
%     center of the MPlay window
%  screenMsg(false) and screenMsg(true) turn off and on the
%     current screen message.
%  y = this.screenMsg returns true if screen message is on

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/08/24 15:07:10 $

hVis = get(this, 'Visual');
if isempty(hVis)
    
    % If there is no visual, display the message to the command line.
    if nargin > 1 && iscell(varargin{1})
        message = sprintf('%s ', varargin{1}{:});
        disp(message);
    end
    if nargout
        varargout{1} = false;
    end
else
    [varargout{1:nargout}] = hVis.screenMsg(varargin{:});
end

% [EOF]
