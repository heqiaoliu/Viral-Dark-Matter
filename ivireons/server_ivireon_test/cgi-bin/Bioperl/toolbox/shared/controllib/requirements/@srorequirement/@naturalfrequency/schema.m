function schema 
% SCHEMA  Schema for naturalfrequency class
%
 
% Author(s): A. Stothert 31-May-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:35:13 $

%Package
pk = findpackage('srorequirement');

%Class
c = schema.class(pk,'naturalfrequency',findclass(pk,'scalar'));

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
