function h = copy(this)
%COPY    Copy the eye diagram measurement setup object THIS and return in H
%
%   See also COMMSCOPE, COMMSCOPE.EYEMEASUREMENTSETUP,
%   COMMSCOPE.EYEMEASUREMENTSETUP/DISP, COMMSCOPE.EYEMEASUREMENTSETUP/RESET.
%
%   @commscope/@eyemeasurementsetup
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/10 21:20:00 $

% Define fields that should not be copied.  Listeners should not be copied, 
% instead they should be created for each new object.
excludedFields = {'PrivPropertyListener'};

% Copy the object
h = baseCopy(this, excludedFields);

%-------------------------------------------------------------------------------
% [EOF]
