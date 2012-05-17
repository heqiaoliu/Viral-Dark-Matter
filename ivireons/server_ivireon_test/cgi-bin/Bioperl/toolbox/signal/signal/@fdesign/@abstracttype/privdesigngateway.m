function varargout = privdesigngateway(this, method, varargin)
%PRIVDESIGNGATEWAY   Gateway for all of the design methods.
%   PRIVDESIGNGATEWAY(H, METHOD, PV-pairs)

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2007/12/14 15:11:05 $

% We assume here that "method" is valid.

% Force a single output from THISDESIGN.
n = nargout;

if isdesignmethod(this, method)
    [varargout{1:n}] = thisdesign(this, method, varargin{:});
else
    errid = generatemsgid('invalidMethod');
    errmsg    = sprintf('%s is not defined for specification type: ''%s''.', ...
        upper(method), this.Specification);
    error(errid,errmsg);
end

% Store fdesign obj in dfilt
setfdesign(varargout{1},this);

% Store the design method string
setdesignmethod(varargout{1},method);

if ~nargout
    Hd = varargout{1};
    varargout = {};
    if this.NormalizedFrequency,
        inputs = {'NormalizedFrequency', 'On'};
    else
        inputs = {'Fs', this.Fs};
    end
    inputs = {inputs{:}, 'DesignMask', 'on'};
    fvtool(Hd, inputs{:});
end

% [EOF]
