function nlsys = idnlmodel(ny, nu, Ts)
%IDNLMODEL Constructor for the IDNLMODEL class.
%
%   NLSYS = IDNLMODEL(NY, NU) creates an IDNLMODEL object with NY outputs
%   and NU inputs.
%
%   NLSYS = IDNLMODEL(NY, NU, TS) creates an IDNLMODEL object with NY
%   outputs,  NU inputs, and sample time TS. 
%
%   Note: This function is not intended for users.
%         Use IDNLARX, IDNLHW ot IDNLGREY to specify IDNLMODEL models.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.10.5 $ $Date: 2008/10/02 18:54:32 $
%   Written by Qinghua Zhang.

% Check that the function is called with no, one, two or three arguments.
nin = nargin;
error(nargchk(0, 3, nin, 'struct'));

% Define default property values.
if ((nin == 1) && strcmp(ny, 'idnlmodel'))
    nlsys = ny;
    return;
end

% IDNLGREY should be superior to IDDATA.
superiorto('iddata')

% Default settings.
if (nin < 1)
    ny = 0;
elseif ~isIntScalar(ny, 0, Inf, true)
    ctrlMsgUtils.error('Ident:idnlmodel:IODimCheck','NY')
end
if (nin < 2)
    nu = 0;
elseif isempty(nu)
    nu = 0;
elseif ~isIntScalar(nu, 0, Inf, true)
    ctrlMsgUtils.error('Ident:idnlmodel:IODimCheck','NU')
end
if (nin < 3)
    Ts = 1;
elseif isempty(Ts)
    Ts = 1;
elseif ~isRealScalar(Ts, 0, Inf, true)
    ctrlMsgUtils.error('Ident:idnlmodel:TsCheck')
end

% Create the IDNLMODEL structure.
EmptyStr = {''};
nlsys = struct('Name',             '',                           ...
               'Ts',               Ts,                           ...
               'TimeUnit',         '',                           ...
               'TimeVariable',     't',                          ...
               'InputName',        {defnum({}, 'u', nu)},        ...
               'InputUnit',        {EmptyStr(ones(nu, 1), 1)},   ...
               'OutputName',       {defnum({}, 'y', ny)},        ...
               'OutputUnit',       {EmptyStr(ones(ny, 1), 1)},   ...
               'NoiseVariance',    eye(ny, ny),                  ...
               'Notes',            {{}},                         ...
               'UserData',         [],                           ...
               'Utility',          [],                           ...
               'Estimated',        0,                            ...
               'OptimMessenger',   [],                           ...
               'Version',          idutils.ver               ...
              ); %version was 1.0 before R2008a

% Label NLSYS as an object of class IDNLMODEL.
nlsys = class(nlsys, 'idnlmodel');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Local functions.                                                               %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function result = isIntScalar(value, low, high, islimited)
% Check that value is an integer in the specified range.
result = true;
if (ndims(value) ~= 2)
    result = false;
elseif ~isnumeric(value)
    result = false;
elseif ~all(size(value) == [1 1])
    result = false;
elseif (~isreal(value) || isnan(value))
    result = false;
elseif (isfinite(value) && (rem(value, 1) ~= 0))
    result = false;
elseif (islimited && ~isfinite(value))
    result = false;
elseif (value < low)
    result = false;
elseif (value > high)
    result = false;
end

function result = isRealScalar(value, low, high, islimited)
% Check that value is a real scalar in the specified range.
result = true;
if (ndims(value) ~= 2)
    result = false;
elseif ~isnumeric(value)
    result = false;
elseif ~all(size(value) == [1 1])
    result = false;
elseif (~isreal(value) || isnan(value))
    result = false;
elseif (islimited && ~isfinite(value))
    result = false;
elseif (value < low)
    result = false;
elseif (value > high)
    result = false;
end
