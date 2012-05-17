function pos = parserenderinputs(this, varargin)
%PARSERENDERINPUTS Parse for the inputs to render
%   PARSERENDERINPUTS Parse for the inputs to render (hFig, position)

%   Author(s): J. Schickler
%   Copyright 1988-2010 The MathWorks, Inc.
%   $Revision: 1.3.4.6 $  $Date: 2010/05/20 03:10:39 $

hFig = -1;
pos = [];

for i = 1:length(varargin)
    if numel(varargin{i}) == 1 && ...
            (ishghandle(varargin{i}, 'figure') || ...
            ishghandle(varargin{i}, 'uipanel') || ...
            ishghandle(varargin{i}, 'uicontainer'))
        hFig = varargin{i};
    elseif isnumeric(varargin{i}) && length(varargin{i}) == 4,
        pos = varargin{i};
    end
end

if ~ishghandle(hFig),
    if ishghandle(this.Parent, 'figure') || ...
            ishghandle(this.Parent, 'uipanel') || ...
            ishghandle(this.Parent, 'uicontainer')
        hFig = this.Parent;
    else
        hFig = gcf;
    end
end

set(this, 'Parent', hFig);

% [EOF]
