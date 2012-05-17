function [scribelayer varargin] = findScribeLayer(varargin)
% Given a list of input arguments, find the scribe axes. If there is no
% "Parent" property and no existing scribe axes, create one:

%   Copyright 2006-2010 The MathWorks, Inc.

% Deal with parenting properly:
fig = [];
if (nargin == 0) || ischar(varargin{1})
    parind = find(strcmpi(varargin,'parent'));
    if ~isempty(parind)
        fig = get(varargin{parind(end)+1},'Parent');
    end
else
    [fig,varargin,nargs] = graph2dhelper('hgcheck','figure',varargin{:}); %#ok<NASGU>
end
if isempty(fig)
    fig = gcf;
end

if ~feature('HGUsingMATLABClasses')
    % if no scribelayer for this figure create one.
    scribelayer = handle(findall(fig,'Type','axes','Tag','scribeOverlay','-depth',1));
    if isempty(scribelayer)
        scribelayer = scribe.scribeaxes(fig);
    end
else
    scribelayer = getDefaultCamera(fig,'overlay');
end