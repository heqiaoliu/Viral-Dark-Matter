function thisrender(this,varargin)
%RENDER Render the entire filter order GUI component.
% Render the frame and uicontrols

%   Author(s): Z. Mecklai, J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.5.4.6 $  $Date: 2006/11/19 21:46:27 $

pos  = parserenderinputs(this, varargin{:});

if isempty(pos),
    sz  = gui_sizes(this);
    pos = sz.pixf*[217 188 178 72];
end

framewlabel(this,pos,'Filter Order');

rendercontrols(this, pos);

cshelpcontextmenu(this, 'fdatool_numden_filterorder_specs');

% [EOF]
