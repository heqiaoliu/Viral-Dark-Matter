function h = specsfsspecifier(defaultUnits, defaultFs)
%SPECSFSSPECIFIER Custom fsspecifier for specs frames

%   Author(s): Z. Mecklai
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2007/12/14 15:20:02 $

error(nargchk(0,2,nargin,'struct'));

% Call builtin constructor
h = siggui.specsfsspecifier;

% Determine list of all possible units
allUnits = set(h, 'Units');

if nargin < 1 , defaultUnits = allUnits{2}; end
if nargin < 2 , defaultFs    = '48000';     end

% Set the defaults
set(h, 'Version', 1.0);
set(h, 'Units', defaultUnits);
set(h, 'Value', defaultFs);

settag(h);

% [EOF]
