function result = callperl(varargin)
%CALLPERL calls perl script using appropriate operating system.
%
%   ***** NOTE: THIS FUNCTION IS OBSOLETE - use PERL instead *****
%
%   CALLPERL(PERLFILE) calls perl script specified by the file PERLFILE
%   using appropriate perl executable.
%
%   CALLPERL(PERLFILE,ARG1,ARG2,...) passes the arguments ARG1,ARG2,...
%   to the perl script file PERLFILE, and calls it by using appropriate
%   perl executable.
%
%   RESULT=CALLPERL(...) outputs the result of attempted perl call.
%
%   See also PERL

%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.5.2.2 $

cmdString = ''; %#ok

% Pre-process input arguments before calling MATLAB's perl command.
% (If an argument refers to a file on the MATLAB path, use full file path.)
for i = 1:nargin
  thisArg = varargin{i};
  if isempty(thisArg) || ~ischar(thisArg)
    DAStudio.error('Simulink:dialog:AllInpMustBeStrs');
  elseif exist(thisArg, 'file')==2
    % This is a valid file on the MATLAB path
    if isempty(dir(thisArg))
      % Not complete file specification
      % - file is not in current directory
      % - OR filename specified without extension
      % ==> get full file path
      thisArg = which(thisArg);
    end
  elseif i==1
    % First input argument is PerlFile - it must be a valid file
    DAStudio.error('Simulink:dialog:UnableToFindPerlFile', thisArg);
  end
  varargin{i} = thisArg;
end

% Call MATLAB's perl command.
result = perl(varargin{:});

% EOF
