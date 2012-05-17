function PrepareAcceleratorAndSFunction(h)
%   PREPAREACCELERATORANDSFUNCTION  prepare for accelerator mode and
%   s-function target.
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2008/07/18 18:45:43 $


% need to know where it's got called (from simprm, accel, or ssgen<x>, etc)
callerName = LocTDisplayCallerInfo(h, '');

% determine if we need to set the start time to be zero
resetToZero = 0;

% switch off RTWCodeReuse for the s-function target
h.CodeReuse = rtwprivate('RTWCodeReuse');
if any(findstr(get_param(h.ModelHandle, 'RTWSystemTargetFile'), 'rtwsfcn.tlc'))
    rtwprivate('RTWCodeReuse',0);
end

% accelerator mode simulation, need to set
if ~isempty(findstr(callerName, 'simprm')) && ...
	( isempty(findstr(get_param(h.ModelHandle, 'RTWSystemTargetFile'), ...
    		'rtwsfcn.tlc')) && ...
    isempty(findstr(get_param(h.ModelHandle, 'RTWSystemTargetFile'), ...
			'rsim.tlc')) )
    resetToZero = 1;
end

if (str2double(get_param(h.ModelHandle, 'StartTime')) ~= 0 &&...
    (resetToZero == 1))
    buttonName = questdlg(...
	['Start time must be zero for a real time system. ' ...
	 'Do you want Real-Time Workshop to generate code with start ' ...
	 'time zero? '], 'Build question', 'Yes', 'No', 'Yes');
    switch buttonName
     case 'Yes',
      h.cleanChange('parameter', 'StartTime', '0');
      feval(h.DispHook{:},[sprintf('\n'), '### Setting start time to zero.']);
     case 'No',
      % warn user
      warnStatus = [warning; warning('query','backtrace')];
      warning off backtrace;
      warning on; %#ok<WNON>
      DAStudio.warning('RTW:buildProcess:nonZeroStartTime');
      warning(warnStatus); %#ok<WNTAG>
    end
end
