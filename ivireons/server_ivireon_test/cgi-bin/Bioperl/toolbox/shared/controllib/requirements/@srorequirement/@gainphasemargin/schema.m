function schema

% Author: A. Stothert
% Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:34:53 $

%Package
pk = findpackage('srorequirement');

%Class
c = schema.class(pk,'gainphasemargin',findclass(pk,'scalar'));

%Native Properties
p = schema.prop(c,'FeedbackSign','double');
p.FactoryValue = 1;
p.SetFunction  = @localFeedbackSet; 

%--------------------------------------------------------------------------
function valueStored = localFeedbackSet(this, Value)

if (Value ~= 1) && (Value ~= -1)
   ctrlMsgUtils.error('Controllib:graphicalrequirements:errFeedbackSign')
end
valueStored = Value;




