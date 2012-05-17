function Status = CheckRequirementValue(this,Value,Type) 
% CHECKREQUIREMENTVALUE   private utility method to perform basic checks on 
%                         requirement data
%
% Input:
%     this    - requirement object
%     Value   - proposed new value
%     Type    - property being checked (currently only supports x,y data)
%
% Output: 
%     Status  - structure with fields warn and error containing cell arrays
%     of warning and error messages
 
% Author(s): A. Stothert 28-Apr-2005
%   Copyright 2005-2009 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/10/16 06:36:29 $

Status.error = {};
Status.warn  = {};

szV = size(Value);
if ~(isnumeric(Value)) || ~(all(isfinite(Value(:))))
   Status.error = vertcat(Status.error,...
      sprintf('data should be numeric and finite'));
end
if szV(2) > 2 || numel(szV) > 2
   Status.error = vertcat(Status.error,...
      sprintf('data should be at most an nx2 vector'));
end

switch Type(1)
   case 'X'
      if szV(1) ~= size(this.getY,1)
         Status.error = vertcat(Status.error,...
            sprintf('new x-data may be incompatible with current y-data'));
      end
   case 'Y'
      if szV(1) ~= size(this.getX,1)
         Status.error = vertcat(Status.error,...
            sprintf('new y-data may be incompatible with current x-data'));
      end
end

