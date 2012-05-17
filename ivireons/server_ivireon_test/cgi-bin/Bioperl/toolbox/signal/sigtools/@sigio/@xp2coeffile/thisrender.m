function thisrender(this, varargin)
%THISRENDER   

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/12/28 04:36:04 $

pos = parserenderinputs(this, varargin{:});

hFig = get(this, 'Parent');

sz = gui_sizes(this);
if isempty(pos)
    pos = [10 10 200 50]*sz.pixf;
else
    pos(4) = pos(4)+8*sz.pixf;
end

hPanel = uipanel('Parent', hFig, ...
    'Title', 'Options', ...
    'Units', 'Pixels', ...
    'Visible', 'Off', ...
    'Position', pos);

set(this, 'Container', hPanel);

rendercontrols(this, hPanel, {'format'});

setPopupStrings(this, 'format', {'Decimal', 'Hexadecimal', 'Binary'}, ...
    {fdatoolmessage('DecimalEntry'), fdatoolmessage('HexadecimalEntry'), fdatoolmessage('BinaryEntry')});

% [EOF]
