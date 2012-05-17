function [e, x0] = pe(varargin)
%PE  Computes the prediction errors of an IDNLMODEL model.
%
%        E  = PE(NLSYS, DATA);
%   [E, X0] = PE(NLSYS, DATA, INIT);
%
%   NLSYS: The IDNLMODEL
%   DATA: Time domain IDDATA object.
%
%   INIT specifies the initial state.
%       For nonlinear black box models (IDNLARX and IDNLHW), see the help
%       on IDNLARX/PREDICT and IDNLHW/PREDICT for handling of INIT.
%       For nonlinear grey box models, see help on IDNLGREY/PE.
%
%   If pe is called without an output argument, then the prediction
%   error(s) will be shown in a plot window.
%
%  See also PE, IDNLGREY/PE, PREDICT, IDNLARX/PREDICT, IDNLHW/PREDICT.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $ $Date: 2008/10/02 18:54:33 $
%   Written by Peter Lindskog.

% Retrieve the number of outputs.
no = nargout;

% First test consistency of the model
nlsys = [];
kd = 2;
for k = 1:2
    if isa(varargin{k}, 'idnlmodel')
        nlsys = varargin{k};
        if (k == 2)
            data = varargin{1};
            kd = 1;
        else
            data = varargin{2};
            kd = 2;
        end
    end
end
if isempty(nlsys)
    ctrlMsgUtils.error('Ident:general:objectTypeMismatch','pe','IDNLMODEL')
end
if isa(nlsys,'idnlgrey')
    [errmsg, data] = checkgetiddata(data, nlsys, 'pe');
    error(errmsg)
end
varargin{kd} = data;

% Call utpe.
if (no == 0)
    utpe(varargin{:});
elseif (no == 1)
    e = utpe(varargin{:});
elseif (no == 2)
    [e, x0] = utpe(varargin{:});
end
