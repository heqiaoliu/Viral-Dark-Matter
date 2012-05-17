function [Props,AsgnVals] = pnames(sys,flag)
%PNAMES  All public properties and their assignable values
%
%   [PROPS,ASGNVALS] = PNAMES(SYS) returns the list PROPS of
%   public properties of the IDNLARX object SYS, as well as the
%   assignable values ASGNVALS for these properties.  Both
%   PROPS and ASGNVALS are cell vector of strings, and PROPS
%   contains the true case-sensitive property names, including
%   the parent's properties.
%
%   Note: The order of properties shown in the list GET(SYS) is
%   determined by PNAMES(SYS). The parent's propeties are divided
%   into two parts (top and bottom) to be listed before and after
%   the IDNLARX-specific properties.
%
%   PROPS = PNAMES(SYS,'specific') returns only the IDNLARX-specific
%   public properties of SYS, without those of the parent object.
%
%   PNAMES(SYS,'readonly') returns the read-only properties only.
%
%   Note: the properties of the parent (IDNLMODEL) are all settable,
%   PNAMES(SYS,'readonly') concerns only IDNLHW-specific properties.
%
%   See also  GET, SET.

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2008/10/02 18:53:18 $

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

% IDNLARX-specific public properties
Props = {'na';
    'nb';
    'nk';
    'CustomRegressors';
    'NonlinearRegressors';
    'Nonlinearity';
    'Focus';
    'Algorithm';
    % 'CovarianceMatrix';
    'EstimationInfo'};
if readonlyflag
    Props = Props(end);
end


if no>1
    AsgnVals = {'Ny-by-Ny integer matrix (Ny: number of outputs)';
        'Ny-by-Nu integer matrix (Ny, Nu: numbers of outputs and inputs)';
        'Ny-by-Nu integer matrix (Ny, Nu: numbers of outputs and inputs)';
        'CUSTOMREG object or cell array of CUSTOMREG objects';
        'Integer vector or cell array of integer vectors';
        'IDNLFUN object';
        '''Prediction''|''Simulation'' (Estimation focus)';
        'Structure containing algorithm details';
        %  'Covariance matrix of model parameter estimate';
        'Structure containing estimation information (read-only)'};
    if readonlyflag
        AsgnVals = AsgnVals(end);
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

% FILE END
