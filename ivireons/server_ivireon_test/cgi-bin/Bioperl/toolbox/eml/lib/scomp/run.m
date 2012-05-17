function varargout = run(obj, varargin)
%Embedded MATLAB Library function.
% Implement run function for System objects.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2009/11/16 22:24:38 $
%#eml

eml_allow_mx_inputs;
eml_must_inline;

obj = obj;  %#ok<ASGSL> % To have this variable exist in debug mode
% These lines need to be before eml_sea_get_obj. This is to make
% sure we have a System object before trying to get the object.
if eml_const(~isa(obj,'matlab.system.SystemBase'))
       eml_assert(false, 'run method is reserved for System objects.');
end

comp = eml_sea_get_obj(obj);

if eml_const(feval('isa', comp, 'matlab.system.SFunCore')) % mcos comp
    numinputs  = eml_const(feval('numInputs',  comp));
    numoutputs = eml_const(feval('numOutputs', comp));
    if ~eml_const(feval('isLocked', comp))
        eml_sea_method_call('uddAllowGetAccess', obj);
        eml_const(feval('setParameters', comp));
        eml_sea_method_call('uddDisAllowGetAccess', obj);
    end
else
    eml_assert(false, 'This System object is not supported in Embedded MATLAB.');
end

eml.extrinsic('num2str');

eml_assert((nargin-1) == numinputs, eml_const(['Expected number of inputs: ' num2str(numinputs), ', Actual number of inputs: ' num2str(nargin-1)]));
eml_assert(nargout <= numoutputs, eml_const(['Requested ' num2str(nargout), ' output(s), when only ' num2str(numoutputs) ' output(s) are available.']));

% Check for variable size
for i=1:numinputs
  eml_assert(eml_is_const(size(varargin{i})), 'Variable size inputs are not supported for System objects.');
end

if numoutputs == 0
    eml_sea_method_call('process',obj,varargin{:});
elseif numoutputs == 1
    varargout{1} = eml_sea_method_call('process', obj, varargin{:});
elseif numoutputs == 2
    [varargout{1}, varargout{2}] = eml_sea_method_call('process', obj, varargin{:});
elseif numoutputs == 3
    [varargout{1}, varargout{2}, varargout{3}] = eml_sea_method_call('process', obj, varargin{:});
elseif numoutputs == 4
    [varargout{1}, varargout{2}, varargout{3}, varargout{4}] = eml_sea_method_call('process', obj, varargin{:});
elseif numoutputs == 5
    [varargout{1}, varargout{2}, varargout{3}, varargout{4}, varargout{5}] = eml_sea_method_call('process', obj, varargin{:});
elseif numoutputs == 6
    [varargout{1}, varargout{2}, varargout{3}, varargout{4}, varargout{5}, varargout{6}] = eml_sea_method_call('process', obj, varargin{:});
elseif numoutputs == 7
    [varargout{1}, varargout{2}, varargout{3}, varargout{4}, varargout{5}, varargout{6}, varargout{7}] = eml_sea_method_call('process', obj, varargin{:});
elseif numoutputs == 8
    [varargout{1}, varargout{2}, varargout{3}, varargout{4}, varargout{5}, varargout{6}, varargout{7}, varargout{8}] = eml_sea_method_call('process', obj, varargin{:});
elseif numoutputs == 9
    [varargout{1}, varargout{2}, varargout{3}, varargout{4}, varargout{5}, varargout{6}, varargout{7}, varargout{8}, varargout{9}] = eml_sea_method_call('process', obj, varargin{:});
elseif numoutputs == 10
    [varargout{1}, varargout{2}, varargout{3}, varargout{4}, varargout{5}, varargout{6}, varargout{7}, varargout{8}, varargout{9}, varargout{10}] = eml_sea_method_call('process', obj, varargin{:});
elseif numoutputs == 11
    [varargout{1}, varargout{2}, varargout{3}, varargout{4}, varargout{5}, varargout{6}, varargout{7}, varargout{8}, varargout{9}, varargout{10}, varargout{11}] = eml_sea_method_call('process', obj, varargin{:});
elseif numoutputs == 12
    [varargout{1}, varargout{2}, varargout{3}, varargout{4}, varargout{5}, varargout{6}, varargout{7}, varargout{8}, varargout{9}, varargout{10}, varargout{11}, varargout{12}] = eml_sea_method_call('process', obj, varargin{:});
end
