function [Props,AsgnVals] = pnames(sys, flag)
%PNAMES  All public properties and their assignable values
%
%   [PROPS,ASGNVALS] = PNAMES(SYS) returns the list PROPS of
%   public properties of the IDNLHW object SYS, as well as the
%   assignable values ASGNVALS for these properties.  Both
%   PROPS and ASGNVALS are cell vector of strings, and PROPS
%   contains the true case-sensitive property names, including
%   the parent's properties.
%   Note: The order of properties shown in the list GET(SYS) is
%   determined by PNAMES(SYS). The parent's propeties are divided
%   into two parts (top and bottom) to be listed before and after
%   the IDNLHW-specific properties.
%
%   PNAMES(SYS,'specific') returns only the IDNLHW-specific
%   public properties of SYS, without those of the parent object.
%
%   PNAMES(SYS,'readonly') returns the read-only properties only.
%
%   Note: the properties of the parent (IDNLMODEL) are all settable,
%   PNAMES(SYS,'readonly') concerns only IDNLHW-specific properties.
%
%   See also  GET, SET.

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:54:19 $

% Author(s): Qinghua Zhang

ni = nargin;
no = nargout;

specificflag = false;
readonlyflag = false;
if ni>1 && ischar(flag)
  if strcmpi(flag, 'specific')
    specificflag = true;
  elseif strcmpi(flag, 'readonly')
    specificflag = true; % exclude parent's properties which are all settable.
    readonlyflag = true;
  else
    ctrlMsgUtils.error('Ident:general:wrongPnamesFlag2')
  end
end

% IDNLHW-specific public properties
Props = {'nb';
         'nf';
         'nk';
         'b';
         'f';
         'LinearModel';       % Read-only
         'InputNonlinearity';
         'OutputNonlinearity';
         'Algorithm';
  %       'CovarianceMatrix';
         'EstimationInfo'};   % Read-only
       
if readonlyflag
  Props = Props([6 10]); % Note: be careful with these values when changing properties.
end

if no>1
  AsgnVals = ...
        {'Orders of the B-polynomials (ny-by-nu matrix)';
         'Orders of the F-polynomials (ny-by-nu matrix)';
         'Input delay matrix (ny-by-nu matrix)';
         'B-polynomials (ny-by-nu cellarray of row vectors)';
         'F-polynomials (ny-by-nu cellarray of row vectors)';
         'Linear model object (read-only)';
         'Differentiable nonlinearity estimator or unitgain object';
         'Differentiable nonlinearity estimator or unitgain object';
         'Structure containing algorithm details';
  %       'Covariance matrix of model parameter estimate';
         'Structure containing estimation information (read-only)'};  
       
  if readonlyflag
    AsgnVals = AsgnVals([6 10]); % Note: be careful with these values when changing properties.
  end
end

% Add public parent's properties unless otherwise requested
if ~specificflag 
  [propsParent, valsParent, top, bottom] = pnames(sys.idnlmodel);
  Props = [propsParent(top); Props; propsParent(bottom)];
  if no>1
    AsgnVals = [valsParent(top); AsgnVals; valsParent(bottom)];
  end
end

% END of file

