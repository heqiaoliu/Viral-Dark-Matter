function specs = whichspecs(h)
%WHICHSPECS Determine which specs are required for this class.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 00:11:33 $



% Call super's method
specs = fn_whichspecs(h);

specs(end+1) = cell2struct({'TransitionMode','freqrcosTransitionMode','rolloff',...
        {'PropertyPreSet',@transmode_listener},'filtdes.freqrollnyq'},specfields(h),2);

specs(end+1) = cell2struct({'bandwidth','udouble',0.5,...
        [],'freqspec'},specfields(h),2);

specs(end+1) = cell2struct({'rolloff','double0t1',0.5,...
        [],'rolloff'},specfields(h),2);
