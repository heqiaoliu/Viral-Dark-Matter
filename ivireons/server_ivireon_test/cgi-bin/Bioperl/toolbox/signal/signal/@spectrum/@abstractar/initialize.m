function initialize(this, order)
%INITIALIZE   Set common AR properties.
%    If ORDER is not specified use default values. 

%   Author(s): P. Pacheco
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/08/11 15:48:23 $

if nargin < 2,
    order = 4;
end
set(this,'Order',order);

% [EOF]
