function h = numdenfilterorder(defaultNum,defaultDen)
%ARBMAGFILTERORDER Constructor for the filterOrder object.
%   Inputs:
%      defaultNum - Default value for Numerator order.
%      defaultDen - Default value for Denominator order.

%   Author(s): Z. Mecklai
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.2 $  $Date: 2009/03/09 19:35:35 $

% Do input error checking
error(nargchk(0,2,nargin,'struct'));

% Use built-in constructor
h = siggui.numdenfilterorder;

% Set default properties based on number of inputs

if nargin < 1, defaultNum = '8'; end
if nargin < 2, defaultDen = '8'; end

% Set additional inputs/defaults
% Set the default numerator
set(h,'NumOrder',defaultNum);

% Set the default denominator
set(h,'DenOrder',defaultDen);

% Set version
set(h,'version',1.0);

settag(h);

% [EOF]
