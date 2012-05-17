function [Value,ValStr] = pvget(sys,Property)
%PVGET  Get values of public IDNLARX properties.
%
%   VALUES = PVGET(SYS) returns all public values in a cell
%   array VALUES.
%
%   [VALUES,VALSTR] = PVGET(SYS) also returns a cell array 
%   of strings VALSTR containing formatted property value
%   info to be displayed by GET(SYS).  The formatting is done
%   using PVFORMAT. 
%
%   VALUE = PVGET(SYS,PROPERTY) returns the value of the
%   single property with name PROPERTY.  The string property
%   must contain the true property name.
%
%   See also GET.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2006/12/27 20:58:41 $

% Author(s): Qinghua Zhang

if nargin==2
   % Value of single property
   switch Property
     case pnames(sys, 'specific')
       Value = sys.(Property);
     case 'CovarianceMatrix' % Private property
       Value = sys.CovarianceMatrix;
       
     otherwise % Parent's property
       Value = pvget(sys.idnlmodel,Property);      
   end
   
else
   % Return all public property values  
   propAll = pnames(sys);
   Value = cell(size(propAll));
   for kp=1:length(Value)
     Value{kp} = pvget(sys, propAll{kp});
   end
   if nargout==2
     ValStr = idpvformat(Value);
   end
end

% FILE END
