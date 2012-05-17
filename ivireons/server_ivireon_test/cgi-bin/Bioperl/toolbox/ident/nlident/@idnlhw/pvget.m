function [Value,ValStr] = pvget(sys,Property)
%PVGET  Get values of public IDNLHW properties.
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
% $Revision: 1.1.8.3 $ $Date: 2007/12/14 14:48:27 $

% Author(s): Qinghua Zhang

if nargin==2
  % Value of single property
  switch Property
    case [pnames(sys, 'specific'); {'Btail'; 'ncind'; 'CovarianceMatrix'; 'InitialState'}] 
      % IDNLHW specific properties and private properties
      switch Property
        % Made-up properties
        case 'nb'
          Value = cellfun(@length, sys.Btail);
        case 'nf'
          Value = cellfun(@length, sys.f)-1;
        case 'b'
          nk = sys.nk;
          Value = sys.Btail;
          for ka=1:numel(nk)
            Value{ka} = [zeros(1,nk(ka)), Value{ka}]; % Add leading zeros for delays
          end     
        case 'LinearModel'
          Value = getlinmod(sys);
          
        % Standard properties 
        otherwise
          Value = sys.(Property);
      end

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