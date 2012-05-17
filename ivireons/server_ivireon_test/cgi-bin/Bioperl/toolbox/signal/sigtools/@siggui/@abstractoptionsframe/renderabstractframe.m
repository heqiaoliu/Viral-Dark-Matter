function renderabstractframe(this, varargin)
%RENDERABSTRACTFRAME  Render the abstract frame

%   Author(s): Z. Mecklai
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.7 $  $Date: 2009/01/20 15:36:03 $

pos  = parserenderinputs(this, varargin{:});

% Set/get defaults
if isempty(pos),
    sz = gui_sizes(this);
    pos = sz.pixf.*[217 55 178 133-(sz.vffs/sz.pixf)];
end

framewlabel(this, pos, get(this, 'Name'));

% Check for existence of additional parameters
if ~isempty(getbuttonprops(this))
    renderactionbtn(this, pos, 'More options ...', 'editadditionalparameters');
end

% [EOF]
