function this = shuttlectrl(varargin)
%SHUTTLECTRL Construct a Comm GUI Shuttle Control object

%   @commgui/@shuttlectrl
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/10 21:19:10 $

this = commgui.shuttlectrl;

% Set default prop values
this.Type = 'GUI Shuttle Control';

% Initialize based on the arguments
if nargin ~= 0
    initPropValuePairs(this, varargin{:});
end

% Render the shuttle control
render(this);

%-------------------------------------------------------------------------------
% [EOF]
