function fs = evaluatefs(str)
%EVALUATEFS  Evaluate sampling frequency input.
%   FS = EVALUATEFS(STR) evaluates user input string STR and returns
%   scalar FS.  An error message is given if FS is negative, zero,
%   not numeric, or not a scalar.

%   Author: T. Bryan
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2007/12/14 15:15:42 $

[fs,errmsg] = evaluatevars(str);
if ~isempty(errmsg), error(generatemsgid('SigErr'),errmsg); end
if ~isnumeric(fs)
  error(generatemsgid('MustBeNumeric'),'Fs must be numeric.')
end
if isempty(fs) | length(fs)>1
  error(generatemsgid('InvalidDimensions'),'Fs must be a scalar.');
end
if fs<=0
  error(generatemsgid('MustBePositive'),'Fs must be positive.')
end

% [EOF] evaluatefs.m
