function varargout = step(obj, varargin)
%Embedded MATLAB Library function.
% Implement step function for System objects.

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/05/20 02:16:15 $
%#eml

eml_allow_mx_inputs;
eml_must_inline;

obj = obj;  %#ok<ASGSL> % To have this variable exist in debug mode

if isa(obj, 'function_handle')
    if nargout == 0
        obj('step',varargin{:});
    elseif nargout == 1
        varargout{1} = obj('step',varargin{:});
    elseif nargout == 2
        [varargout{1}, varargout{2}] = obj('step',varargin{:});
    elseif nargout == 3
        [varargout{1}, varargout{2}, varargout{3}] = obj('step',varargin{:});
    elseif nargout == 4
        [varargout{1}, varargout{2}, varargout{3}, varargout{4}] = obj('step',varargin{:});
    elseif nargout == 5
        [varargout{1}, varargout{2}, varargout{3}, varargout{4}, varargout{5}] = obj('step',varargin{:});
    elseif nargout == 6
        [varargout{1}, varargout{2}, varargout{3}, varargout{4}, varargout{5}, varargout{6}] = obj('step',varargin{:});
    elseif nargout == 7
        [varargout{1}, varargout{2}, varargout{3}, varargout{4}, varargout{5}, varargout{6}, varargout{7}] = obj('step',varargin{:});
    elseif nargout == 8
        [varargout{1}, varargout{2}, varargout{3}, varargout{4}, varargout{5}, varargout{6}, varargout{7}, varargout{8}] = obj('step',varargin{:});
    elseif nargout == 9
        [varargout{1}, varargout{2}, varargout{3}, varargout{4}, varargout{5}, varargout{6}, varargout{7}, varargout{8}, varargout{9}] = obj('step',varargin{:});
    elseif nargout == 10
        [varargout{1}, varargout{2}, varargout{3}, varargout{4}, varargout{5}, varargout{6}, varargout{7}, varargout{8}, varargout{9}, varargout{10}] = obj('step',varargin{:});
    elseif nargout == 11
        [varargout{1}, varargout{2}, varargout{3}, varargout{4}, varargout{5}, varargout{6}, varargout{7}, varargout{8}, varargout{9}, varargout{10}, varargout{11}] = obj('step',varargin{:});
    elseif nargout == 12
        [varargout{1}, varargout{2}, varargout{3}, varargout{4}, varargout{5}, varargout{6}, varargout{7}, varargout{8}, varargout{9}, varargout{10}, varargout{11}, varargout{12}] = obj('step',varargin{:});
    end
    return;
end

% These lines need to be before eml_sea_get_obj. This is to make
% sure we have a System object before trying to get the object.
if eml_const(~isa(obj,'matlab.system.SystemBase'))
       eml_assert(false, 'step method is reserved for System objects.');
end

comp = eml_sea_get_obj(obj);

if eml_const(feval('isa', comp, 'matlab.system.SFunCore')) % mcos comp
    numinputs  = eml_const(feval('numInputs',  comp));
    numoutputs = eml_const(feval('numOutputs', comp));
    if ~eml_const(feval('isLocked', comp))
        % The DeployableVideoPlayer needs to know the size of the input.
        if eml_const(feval('isa', comp, 'video.DeployableVideoPlayer'))
            if nargin >= 2
                inputSize = size(varargin{1});
            else
                inputSize = [];
            end
            eml_const(feval('setVideoSize', comp, inputSize));
        end
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
for i=eml.unroll(1:nargin-1)
  if ~eml_ambiguous_types
    eml_assert(eml_is_const(class(varargin{i})) && ...
        (isnumeric(varargin{i}) || islogical(varargin{i}) || isfi(varargin{i})), ...
      ['Inputs to the step method must be either numeric or logical variables or fi objects. ' ...
       'Inputs cannot be MATLAB types from extrinsic functions.']);
  end
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

