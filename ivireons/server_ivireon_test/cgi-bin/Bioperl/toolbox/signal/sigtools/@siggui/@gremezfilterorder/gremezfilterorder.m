function h = gremezfilterorder(mode,isMinOrd,ord)
%FILTERORDER Constructor for the filterOrder object.
%   Inputs:
%      defaultMode - render with specify/minimum selected.
%      isMinOrd    - enable/disable minimum order.
%      ord         - default value for specify order.

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:18:52 $

% Do input error checking
error(nargchk(0,3,nargin,'struct'));

% Use built-in constructor
h = siggui.gremezfilterorder;

% Set additional inputs/defaults
if nargin > 0, set(h,'mode',mode); end
if nargin > 1, set(h,'isMinOrd',isMinOrd); end
if nargin > 2, set(h,'order',ord); end

% Set version
set(h,'version',1.0);

% Set tag
settag(h);

% [EOF]
