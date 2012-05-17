function Values = getUncertainValues(this) 
% GETUNCERTAINVALUES  return values of an uncertain parameter spec
%
 
% Author(s): A. Stothert 29-Jun-2006
% Copyright 2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 14:00:43 $

if this.EvaluateMinMaxOnly
   Values = {this.Minimum; this.Maximum};
else
   Values = get(this,'UncertainValues');
   Values = vertcat(Values,this.Minimum);
   Values = vertcat(Values,this.Maximum);
end
