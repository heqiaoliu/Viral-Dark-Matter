function abstract_thisrender(this, varargin)
%ABSTRACT_THISRENDER Render the default options frame.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2004/04/13 00:27:11 $

pos = parserenderinputs(this, varargin{:});

hFig = get(this, 'FigureHandle');

% Determine positions for the frame
if isempty(pos),
    pos = getDefaultPosition(this);
end

hTxtOpts = getcomponent(this, '-class', 'siggui.textOptionsFrame');
if isempty(hTxtOpts),
    hTxtOpts = siggui.textOptionsFrame({'', xlate('There are no optional parameters for this destination.')});
    addcomponent(this, hTxtOpts);
end

% Render a default frame
render(hTxtOpts, hFig, pos);

% % Add contextsensitive help
% cshelpcontextmenu(this, 'fdatool_ExportWDefaultOpts');

%---------------------------------------------------------------------
function pos = getDefaultPosition(this)

sz = gui_sizes(this);

% Default frame width and height
sz.fw = 150*sz.pixf; 
sz.fh = 100*sz.pixf;        

pos = [sz.ffs sz.ffs sz.fw sz.fh];

% [EOF]
