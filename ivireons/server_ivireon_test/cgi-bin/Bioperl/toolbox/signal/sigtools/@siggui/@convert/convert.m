function hConvert = convert(varargin)
%CONVERT Create a convert dialog object

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.8.4.3 $  $Date: 2007/12/14 15:18:14 $

% Parse the inputs
[filtobj, WindowStyle, dspMode, msg] = parse_inputs(varargin{:});
if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

% Instantiate the convert dialog object
hConvert = siggui.convert;

% Set the reference filter
hConvert.Filter = filtobj;

% Set up the object
fstruct = get(filtobj, 'FilterStructure');
set(hConvert, 'TargetStructure', fstruct);
set(hConvert, 'WindowStyle', WindowStyle);
set(hConvert, 'Version', 1);
set(hConvert, 'DSPMode', dspMode);

% set(hConvert, 'isApplied', 1);

% ----------------------------------------------------------------
function [filtobj, windowStyle, dspMode, msg] = parse_inputs(varargin)

windowStyle = 'normal';
dspMode     = 0;
msg         = nargchk(1,3,nargin);

if ~isempty(msg), return; end

filtobj = varargin{1};

for i = 2:length(varargin)
    if ischar(varargin{i}),
        windowStyle = varargin{i};
    elseif isnumeric(varargin{i}),
        dspMode = varargin{i};
    else
        msg = 'Second input argument must be a handle.';
    end
end

% [EOF]
