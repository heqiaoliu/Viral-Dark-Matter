function setfilter(this, filt, varargin)
%SETFILTER Sets the current filter and the reference filter (optional) in FDATool.
%   hFDA.SETFILTER(FILT) sets the filter object, FILT, as the current
%   filter in FDATool.  FILT must be a DFILT object.
%
%   hFDA.SETFILTER(FILT, OPTS) uses the structure OPTS to determine how to
%   set the filter.
%
%   Fields of OPTS
%       source      - String containing the source.
%       filedirty   - Boolean flag which will make the file dirty if true.
%       update      - Boolean flag which will cause the 'FilterUpdated'
%                     event to be sent.
%       fs          - Sampling Frequency of the filter.  [] is normalized.
%       name        - String to name the filter.
%
%   See also GETFILTER.

%   Author(s): P. Pacheco, V. Pellissier, J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.33.4.16 $  $Date: 2009/07/27 20:32:23 $

% Check number of inputs
error(nargchk(2,3,nargin,'struct'));
error(validate_inputs(filt));

% Parse optional inputs
[options, msg] = parse_optional_inputs(this, varargin{:});
if ~isempty(msg), error(generatemsgid('SigErr'),msg); end

if options.filedirty
    sendfiledirty(this);
else
    set(this, 'FileDirty', false);
end

% Not every call to set filter sets a new source
if ~isempty(options.source), set(this,'filterMadeBy',options.source); end

% Save the MCode before setting the filter in case quantize is on.
% Quantize will intercept the filter and add its own mcode.
savemcode(this, options);

% Set filter
if ~strcmp(class(filt), 'dfilt.dfiltwfs'),
    filt = dfilt.dfiltwfs(filt, options.fs, options.name);
end
this.Filter = filt;

% Update GUI
if options.update,
    if options.fastupdate
        send(this,'FastFilterUpdated',handle.EventData(this,'FastFilterUpdated'));
    else
        send(this,'FilterUpdated',handle.EventData(this,'FilterUpdated'));
    end
    if ~strcmpi(get(this.figurehandle, 'tag'), 'initializing') && options.default
        send(this, 'DefaultAnalysis', handle.EventData(this, 'DefaultAnalysis'));
    end
end

%----------------------------------------------------------------------
function savemcode(this, options)

% Save any mcode information.
if isfield(options, 'mcode') && ~isempty(options.mcode),
    if isempty(this.MCode), this.MCode = sigcodegen.mcodebuffer; end
    if isequal(this.MCode, options.mcode)
        return;
    end
    if options.resetmcode
        this.MCode.clear;
    end
    if ~iscell(options.mcode), options.mcode = {options.mcode}; end
    this.MCode.cr;
    this.MCode.add(options.mcode);
else
    if isfield(options, 'mcode') && isequal(this.MCode, options.mcode)
        return;
    end
    if isempty(this.MCode),
        if isempty(ishandle(this.MCode)),
            % Create an empty buffer, don't leave a null there.  null
            % means the user hasn't done anything and the generated code
            % will be for the default filter.
            this.MCode = sigcodegen.mcodebuffer;
        end
    else
        this.MCode.clear;
    end
end

%----------------------------------------------------------------------
function [defaultopts, msg] = parse_optional_inputs(h, options)
%PARSE_OPTIONAL_INPUTS Parse the optional inputs to SETFILTER

% Defaults
oldfilt = get(h, 'Filter');
if isempty(oldfilt)
    fs   = [];
    name = '';
else
    fs   = get(oldfilt, 'fs');
    name = get(oldfilt, 'name');
end

defaultopts = struct('update', true, ...
    'default', true, ...
    'source', '', ...
    'fastupdate', false, ...
    'resetmcode', false, ...
    'name', name, ...
    'fs', fs, ...
    'filedirty', 1);

msg = '';
if nargin > 1,
    if ~isstruct(options),
        msg = 'Optional inputs must be a structure and/or a filter object.';
    else
        defaultopts = setstructfields(defaultopts, options);
    end
end

%----------------------------------------------------------------------
function msg = validate_inputs(filt)
%VALIDATE_INPUTS Validate the inputs

msg = [];

if ~isa(filt, 'dfilt.basefilter') && ~isa(filt, 'dfilt.dfiltwfs'),
    msg = 'Second input must be a filter object';
end

if isa(filt, 'adaptfilt.baseclass'),
    msg = ['FDATool does not support importing Adaptive filters.   ', ...
        'Use FVTool to analyze the filter.'];
end

if isa(filt, 'dfilt.statespace')
    msg = ['FDATool does not support importing State-Space filters.  ', ...
        'Use FVTool to analyze the filter.'];
end

if isa(filt, 'dfilt.farrowfd') || isa(filt, 'dfilt.farrowlinearfd') || ...
        isa(filt, 'mfilt.farrowsrc')
    msg = ['FDATool does not support importing Farrow filters.  ', ...
        'Use FVTool to analyze the filter.'];
end

% [EOF]
