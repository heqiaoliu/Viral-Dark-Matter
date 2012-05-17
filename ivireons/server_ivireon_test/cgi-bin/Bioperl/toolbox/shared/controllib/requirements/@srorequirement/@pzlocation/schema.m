function schema 
% SCHEMA  pzlocation object schema
%
 
% Author(s): A. Stothert 11-Apr-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:09 $

%Package
pk = findpackage('srorequirement');

%Class
c = schema.class(pk,'pzlocation',findclass(pk,'piecewiselinear'));

%Native Properties
if (isempty(findtype('polezero_type')))
   schema.EnumType('polezero_type',{'pole','zero','both'});
end
p = schema.prop(c,'polezero','polezero_type');
p.FactoryValue = 'pole';
p = schema.prop(c,'FeedbackSign','double');
p.FactoryValue = 0;
p.SetFunction  = @localFeedbackSet; 

%--------------------------------------------------------------------------
function valueStored = localFeedbackSet(this, Value)

if (Value ~= 1) && (Value ~= 0) && (Value ~= -1)
   ctrlMsgUtils.error('Controllib:graphicalrequirements:errFeedbackSignWithOpenLoop')
end
valueStored = Value;
