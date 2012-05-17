function specs = whichspecs(h)
%WHICHSPECS Determine which specs are required for this class.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:14:42 $

% Prop name, data type, default value, listener callback
specs(1) = cell2struct({'DesignType','magrcosDesignType','normal',[],'magspec'},specfields(h),2);

