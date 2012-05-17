function disp(this,short)
%DISP Display extension configuration (Config)

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2009/10/29 16:08:04 $

sigutils.dispContent(this, 1, {'Type', 'Name', 'Enable'});
if nargin<2, short=false; end
if ~short && ~isempty(this.PropertyDb)
    disp(this.PropertyDb);
end

% [EOF]
