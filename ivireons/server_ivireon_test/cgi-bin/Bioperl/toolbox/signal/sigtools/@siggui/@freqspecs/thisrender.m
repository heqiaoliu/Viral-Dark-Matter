function thisrender(this, varargin)
%RENDER Render the frequency specifications GUI component.
% Render the frame and uicontrols

%   Author(s): R. Losada, Z. Mecklai
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.14.4.4 $  $Date: 2004/04/13 00:23:44 $

pos = parserenderinputs(this, varargin{:});
if isempty(pos), pos = 'freq'; end

% Call the super classes render method
super_render(this, pos);

pos = getpixelpos(this, 'framewlabel', 1);

% Render the FSSpecifier
render(getcomponent(this, 'siggui.specsfsspecifier'), this.FigureHandle, pos);

% Make the labels and values line up with fsspecifier 
sz  = gui_sizes(this);

% Render the LabelsAndValues class
render(getcomponent(this, 'siggui.labelsandvalues'), this.FigureHandle, ...
    [pos(1)+2*sz.hfus pos(2)+1.5*sz.hfus pos(3)-2*sz.hfus-17*sz.pixf pos(4)-90*sz.pixf]);

%  Add contextsensitive help
cshelpcontextmenu(this, 'fdatool_ALL_freq_specs_frame');

% [EOF]
