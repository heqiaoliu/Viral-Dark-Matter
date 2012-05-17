function specs = whichspecs(h)
%WHICHSPECS Determine which specs are required for this class.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:11:12 $


specs(1) = cell2struct({'DesignType','magnyquistDesignType','Normal',...
        [],'magspec'},specfields(h),2);

% specs(end+1) = cell2struct({'Decay','udouble',0,...
%         [],'magspec'},specfields(h),2);

