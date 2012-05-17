function schema
%SCHEMA for settlingtime class

% Author(s): A. Stothert 04-Apr-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:55 $

%Package
pk = findpackage('srorequirement');

%Class
c = schema.class(pk,'settlingtime',findclass(pk,'scalar'));

%Native Properties
p = schema.prop(c,'FeedbackSign','double');
p.FactoryValue = 0;
p.SetFunction  = @localFeedbackSet; 

%--------------------------------------------------------------------------
function valueStored = localFeedbackSet(this, Value)

if (Value ~= 1) && (Value ~= 0) && (Value ~= -1)
   ctrlMsgUtils.error('Controllib:graphicalrequirements:errFeedbackSignWithOpenLoop')
end
valueStored = Value;


