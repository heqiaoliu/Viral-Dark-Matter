function nlsys = datapropcopy(nlsys, data)
%DATAPROPCOPY  Copy properties of iddata object to an idnlmodel object.
%
%   NLSYS = DATAPROPCOPY(NLSYS, DATA);
%
%   NLSYS is an idnlmodel object and DATA is an iddata object.
%
%   If the properties InputName, InputUnit, OutputName, OutputUnit, Ts,
%   TimeUnit of NLSYS are default values, then copy the information from
%   DATA to NLSYS.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2008/10/02 18:54:29 $
%   Written by Qinghua Zhang.

%   Note 1: this function must be called after datacheck which checks
%           model-data dimension consistency.
%   Note 2: this function must be revised if the default values in
%           idnlmodel are changed.

% Check that the function is called with two arguments.
error(nargchk(2, 2, nargin, 'struct'));

% Check that NLSYS is an IDNLGREY object.
if ~isa(nlsys, 'idnlmodel')
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch','datapropcopy','IDNLMODEL')
end

% Just return in case DATA is not an iddata object.
if ~isa(data, 'iddata')
    return;
end

[ny, nu] = size(nlsys);
EmptyStr = {''};

% Inputs.

if isequal(pvget(nlsys, 'InputName'), defnum({}, 'u', nu))
    try %because iddata channel name is allowed to be empty
        nlsys = pvset(nlsys, 'InputName', pvget(data, 'InputName'));
    end
end

if isequal(pvget(nlsys, 'InputUnit'), EmptyStr(ones(nu, 1), 1))
    nlsys = pvset(nlsys, 'InputUnit', pvget(data, 'InputUnit'));
end

% Outputs.
if isequal(pvget(nlsys, 'OutputName'), defnum({}, 'y', ny))
    try
        nlsys = pvset(nlsys, 'OutputName', pvget(data, 'OutputName'));
    end
end

if isequal(pvget(nlsys, 'OutputUnit'), EmptyStr(ones(ny, 1), 1))
    nlsys = pvset(nlsys, 'OutputUnit', pvget(data, 'OutputUnit'));
end

% Ts.
if (pvget(nlsys, 'Ts') == 1)
    Ts = get(data, 'Ts');
    if (iscell(Ts) && ~isempty(Ts))
        Ts = Ts{1};
    end
    nlsys = pvset(nlsys, 'Ts', Ts);
end
if isempty(pvget(nlsys, 'TimeUnit'))
    nlsys = pvset(nlsys, 'TimeUnit', pvget(data, 'TimeUnit'));
end
