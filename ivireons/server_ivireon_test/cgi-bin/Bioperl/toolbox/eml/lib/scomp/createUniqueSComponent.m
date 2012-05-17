function flag = createUniqueSComponent(dummysize,dummytype,dummyisreal,packageName,className,varargin)
%Embedded MATLAB Library function.

%#eml
%   Copyright 2002-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/11/16 22:24:31 $

eml.allowpcode('plain');
eml_allow_mx_inputs;
eml_transient;
eml_must_inline;

eml_assert(nargin > 4, 'Not enough input arguments.'); % At least 5 inputs
packageClassName = eml_const([packageName, '.', className]);

% Is this a valid System object?
eml_assert(eml_const(feval('matlab.system.isSystemObjectName',packageClassName)), ...
                     [packageClassName, ' is not a valid System object class.']);

errMsg = eml_const(['The ', packageClassName, ' System object does not support code generation.']);
% Error if a System object doesn't support code generation
eml_assert(eml_const(feval([packageClassName '.generatesCode'])), errMsg);
eml_const(dummysize); % needed so that dummy is not ignored
eml_const(dummytype); % needed so that dummy is not ignored
eml_const(dummyisreal); % needed so that dummy is not ignored

% Check that arguments are constants, error out if they are not.
% Doing so here prevents the user from receiving a confusing error
% when the object is created, below.

eml.extrinsic('num2str');
for ix = 1:length(varargin)
    eml_assert(eml_is_const(varargin{ix}),...
        ['Argument index ', eml_const(num2str(ix)), ' to this System object ' ...
        'constructor is not a constant. All arguments to a System object '...
        'constructor in Embedded MATLAB must be constants.']);
end
[errid, createErr, obj] = eml_const(feval('eml_try_catch',packageClassName, varargin{:}));

eml_assert(isempty(errid), createErr);

eml_const(feval('setInternalToolboxUse', obj, true));

flag = eml_sea_set_obj(obj);

