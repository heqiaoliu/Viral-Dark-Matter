function this = DesignBlock(hBlk, designer)
%DESIGNBLOCK   Construct a DESIGNBLOCK object.

%   Author(s): J. Schickler
%   Copyright 2005-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/10/16 06:38:38 $

error(nargchk(2,2,nargin,'struct'));

this = FilterDesignDialog.DesignBlock(hBlk);

set(this, 'Block', hBlk);
if ischar(designer) || isa(designer, 'function_handle')
    designer = feval(designer, 'OperatingMode', 'Simulink');
end
set(this, 'CurrentDesigner', designer);

% [EOF]
