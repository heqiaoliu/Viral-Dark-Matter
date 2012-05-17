function output = target_methods(method, targetId, varargin)
%   status = target_methods(targetId, method, varargin)

% This is the bottleneck/dispatch function for the target API.
% Perform some basic argument sanity checking, figure out which
% target function to invoke, and dispatch to it.

%   Copyright 1995-2010 The MathWorks, Inc.
%   $Revision: 1.7.2.8 $  $Date: 2010/02/25 08:40:10 $

% sanity check arg numbers, types, etc
method = lower(method);
switch method
case 'name'
    % Return the name of the class of target.
    % The first created target in the class will be given this name; 
    % subsequent targets will be given uniquified names.
    % This distinction is nil for sfun and rtw targets because we only 
    % permit one target of each class.
    % This method is used, among other purposes, to sanity check whether
    % a function is really a target function.
    check_varargs(nargin,2,nargout,1);
case 'namechange'
    % Initialize target properties at target creation time.
    check_varargs(nargin,2,nargout,1);
    
	output = [];
    % set coder flag to defaults given in 'codeflags' method
    flags = target_methods('codeflags',targetId);
    target_code_flags('set',targetId,{flags.name},{flags.defaultValue});    
    return;    
case 'initialize'
    % Initialize target properties at target creation time.
    check_varargs(nargin,2,nargout,1);
    
	output = [];
    % set coder flag to defaults given in 'codeflags' method
    flags = target_methods('codeflags',targetId);
    target_code_flags('set',targetId,{flags.name},{flags.defaultValue});    
case 'language'
    % Return the name of the language (C, Ada, VHDL, etc.) generated via this target.
    check_varargs(nargin,2,nargout,1);
case 'machineheadertop'
    % Return a string to be inserted near the top of the machine header file.
    % For example, use this method to add required #include files.
    check_varargs(nargin,2,nargout,1);
case 'buildcommands'
    % Return a data structure describing the build commands this target can execute.
    % Intended for setting up gui uicontrols for building.
    
    % target_methods('buildcommands', targetId)
    check_varargs(nargin,2,nargout,1);
case 'build'
    % Execute one of the target's build commands.
    % Command is specified as in integer index; corresponds to index into 
    % array returned by 'buildcommands' method.
    
    % target_methods('build', targetId, buildNum)
    % buildNum is index into array returned by 'buildcommands'
    check_varargs(nargin,3,nargout,0);
case 'targetproperties'
    % Return a structure describing the target properties used by this target.
    % Used to set up a dialog for modifying target data dictionary properties.
    
    % target_methods('targetproperties', targetId)
    check_varargs(nargin,2,nargout,1);
case 'setcodeflags'
    % set coder flag to defaults given in 'codeflags' method
    flags = varargin{1};
    target_code_flags('set',targetId,flags);
    output = flags;
    return;
case 'codeflags'
    % Return a structure describing the option flags supported by this target.
    % Used to set up a dialog for specifying flags.
    
    % target_methods('codeflags', targetId)
    check_varargs(nargin,2,nargout,1);
case 'codeflagdefaultvalue'
    % Returns the default value of a codeflag for a target
    check_varargs(nargin,3,nargout,1);
    flagName = varargin{1};

    flags = target_methods('codeflags',targetId);
    flagNames = {flags.name};
    index = find(strcmp(flagNames,flagName));
    if(~isempty(index))
        output = flags(index(1)).defaultValue;
    else
        output = 0;
    end
    return;
    % target_methods('codeflags', targetId,flagname)
case {'preparse','postparse','precode','postcode','make'}
    check_varargs(nargin,3,nargout,1);

otherwise
    error('Stateflow:UnexpectedError',['unknown method ' method ' in private/target_methods()']);
end

% figure out which target function to use
targetName = sf('get',targetId,'target.name');
parentTargetFcn = 'default_target_methods';
switch targetName
case 'sfun'
    parentTargetFcn = 'sfun_target_methods';
    targetFcn = 'sfun_target_methods';
case 'rtw'
    targetFcn = 'rtw_target_methods';
case {'slhdlc'}
    targetFcn = 'hdl_target_methods';
otherwise
    % See if the target has a target function specified on it;
    % if not, use the default target function.
    targetFcn = sf('get',targetId,'target.targetFunction');
	if isempty(targetFcn)
        targetFcn = parentTargetFcn;
	elseif exist(targetFcn,'file')~=2 && exist(targetFcn,'file')~=6
		str = sprintf('Error in target_methods(): %s is not a valid target function.',targetFcn);
        disp(str);
        targetFcn = parentTargetFcn;
	end
end

if(~strcmp(targetFcn,parentTargetFcn))
    supportedMethods = which('-subfun',targetFcn);
    if(~any(strcmp(supportedMethods,method)))
        targetFcn = parentTargetFcn;
    end
end

    
if(~strcmp(targetFcn,parentTargetFcn))
    switch(method)
    case 'codeflags'            
        output = feval(parentTargetFcn,method, targetId,varargin{:});
        varargin{1} = output;
    end
end

try
	output = feval(targetFcn,method, targetId,varargin{:});   
catch ME
	msg = sprintf('Error in target_methods() while calling %s( ''%s'', %d, ... )\n',...
		targetFcn, method, targetId);
	error('Stateflow:UnexpectedError',[msg ME.message]);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function check_varargs(inActual,inExpected,outActual,outExpected)
if inActual > inExpected
    error('Stateflow:UnexpectedError','target_methods: too many input arguments');
elseif inActual < inExpected
    error('Stateflow:UnexpectedError','target_methods: too few input arguments');
elseif outActual > outExpected
    error('Stateflow:UnexpectedError','target_methods: too many output arguments');
end

