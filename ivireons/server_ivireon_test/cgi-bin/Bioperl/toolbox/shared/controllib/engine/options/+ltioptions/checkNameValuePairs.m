function checkNameValuePairs(pvpairs)
% Checks that name/value pairs are properly formatted.

%   Copyright 1986-2009 The MathWorks, Inc.
%	$Revision: 1.1.8.1 $  $Date: 2009/11/09 16:34:24 $
ni = length(pvpairs);
if ~(rem(ni,2)==0 && all(cellfun(@ischar,pvpairs(1:2:ni))))
   errID = 'Control:general:OptionHelper1';
   throwAsCaller(MException(errID,ctrlMsgUtils.message(errID)))
end
