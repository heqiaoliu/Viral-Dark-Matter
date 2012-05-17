function h = firlpnormoptsframe(varargin)
% Constructor for the firlpnormOptsFrame

%   Author(s): Z. Mecklai
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2003/03/02 10:27:22 $

% Call the builton constructor
h = siggui.firlpnormoptsframe;

% Set the version
set(h, 'version', 1.0);
settag(h);  %Set the tag using the SIGGUI method

% [EOF]
