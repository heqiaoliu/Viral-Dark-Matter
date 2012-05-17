function varargout = capturewarnings(varargin)
%CAPTUREWARNINGS   Capture and rethrow multiple warnings.
%   CAPTUREWARNINGS(STR) Capture all warnings thrown by the evaluation of
%   STR.  All of these warnings will be rethrown as a single warning.
%
%   CAPTUREWARNINGS(STR, INPUT1, INPUT2, ...) evaluate the function and
%   pass it INPUT1, INPUT2, ... .
%
%   % Example
%   
%   % Should throw no warnings
%   Hd = capturewarnings('dfilt.dffir');
%   set(Hd, 'Arithmetic', 'fixed');
%
%   % Throws 2 warnings
%   block(hd);
%
%   % LASTWARN only remembers 1.
%   lastwarn
%
%   % Throws multiple warnings
%   capturewarnings('block', Hd);
%
%   % LASTWARN remembers all the warnings
%   lastwarn
%
%   See also LASTWARN, WARNING.

%   Author(s): J. Schickler
%   Copyright 2005-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2010/05/20 03:10:23 $

% Make sure that warnings are turned on.
w_state = warning('on'); %#ok

% Turn the backtrace off, because we want simple warning strings.
w_backtrace = warning('off', 'backtrace');

try
    [output_str, varargout{1:nargout}] = evalc('lcleval(varargin{:});');
catch ME
    
    % If the statement that was given to this function errors, reset the
    % warning state and rethrow the error.
    warning(w_state);
    warning(w_backtrace);
    throwAsCaller(ME);
end

% Reset the warning and the backtrace state.
warning(w_state);
warning(w_backtrace);

if isempty(output_str)
    return;
end

% extract the warnings from the output using the hidden sentinels
captured_warnings = regexp(output_str, '(?<={\b).*?(?=}\b)', 'match');

% strip the warnings of the Warning label
captured_warnings = regexprep(captured_warnings, [xlate('Warning:') '\s*'], '');

if numel(captured_warnings) > 1
    % Remove all existing newlines from the warnings.  These may be
    % dependent on the width of the command window.  Add two extra new
    % lines feeds only to the end of the warnings, but exclude the last.
    for indx = 1:numel(captured_warnings)-1
        captured_warnings{indx} = strrep(captured_warnings{indx}, sprintf('\n'), ' ');
        captured_warnings{indx} = sprintf('%s\n\n', captured_warnings{indx});
    end
end

% reissue the concatenated warning
captured_warnings = [captured_warnings{:}];
if ~isempty(captured_warnings)
    warning(captured_warnings);
end

% -------------------------------------------------------------------------
function varargout = lcleval(fcn, varargin) %#ok

[varargout{1:nargout}] = feval(fcn, varargin{:});

% [EOF]
