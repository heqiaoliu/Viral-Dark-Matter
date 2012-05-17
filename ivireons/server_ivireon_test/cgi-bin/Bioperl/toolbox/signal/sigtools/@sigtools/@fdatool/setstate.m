function setstate(this,s)
%SETSTATE Sets the state of FDATool.
%   SETSTATE(this,S) assigns to the fields of S (the saved state) the 
%   UserData of the session of FDATool specified by this.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.37.4.8 $ $Date: 2009/02/18 02:25:34 $

error(nargchk(2,2,nargin,'struct'));

% Assign a default version number (for R12 sessions)
if ~isfield(s,'version'),
    s.version = 0;
end

if any(s.version == [0 1])
    s = r12p1_to_r13(this, s);
end

fields2remove = setR13FDAToolState(this, s);

% Set FDATool's filter and do not update the GUI
options.update = 1;
if isfield(s, 'currentFs'),
    if isstruct(s.currentFs),
        if strncmpi(s.currentFs.units, 'normalized', 10),
            s.currentFs = [];
        else
            s.currentFs = convertfrequnits(s.currentFs.value, s.currentFs.units, 'Hz');
        end
    end
    options.fs = s.currentFs;
    fields2remove{end+1} = 'currentFs';
end
if isfield(s, 'mcode'),
    options.mcode = s.mcode;
    options.resetmcode = true;
    fields2remove{end+1} = 'mcode';
end
if isfield(s, 'currentName')
    options.name = s.currentName;
    fields2remove{end+1} = 'currentName';
end
this.setfilter(s.current_filt,options);
fields2remove{end+1} = 'current_filt';
if isfield(s, 'sosreorderdlg')
    % Apply the sos reorder dialog last because setting the filter undoes
    % any scale/reorder settings we may apply.
    hsos = getcomponent(this, 'siggui.sosreorderdlg');
    if ~isempty(hsos)
        setstate(hsos, s.sosreorderdlg);
        fields2remove{end+1} = 'sosreorderdlg';
    end
end

if isfield(s, 'version');
    fields2remove{end+1} = 'version';
end

s = rmfield(s, fields2remove);
set(this, 'LastLoadState', s);

%--------------------------------------------------------------------
function s = r12p1_to_r13(this, s)

s.sidebar.design = s.fdspecs;
s.sidebar.import = s.import_specs;
if isfield(s,'quantize_specs'),
    oldquantize = true;
    s.sidebar.quantize = s.quantize_specs;
    if isfield(s,'quantizationswitch'),
        s.sidebar.quantize.switch = s.quantizationswitch;
    end
else
    oldquantize = false;
end

switch s.mode.current
case 1,
    mode = 'design';
case 2,
    mode = 'import';
case 3,
    if oldquantize
        mode = 'design';
    else
        mode = 'quantize';
    end
end

% Don't go to the quantization panel if we have old data.
s.sidebar.currentpanel = mode;

s.export = s.export_specs;

if strcmpi(s.analysis_mode, 'filterresponsespecs'),
    s.analysis_mode = '';
    sr = 'on';
else
    sr = 'off';
end

s.sidebar.design.StaticResponse = sr;

s.fvtool.currentAnalysis = s.analysis_mode;
s.convert                = s.convert_specs;


%--------------------------------------------------------------------
function fields2remove = setR13FDAToolState(this,s)

fields2remove = {};

% Remove the CFI information.  It is not useful and should not have been
% saved in the first place.
if isfield(s, 'cfi')
    s = rmfield(s, 'cfi');
end

hC = allchild(this);

for hindx = hC
    lbl = get(hindx.classhandle, 'Name');
    if isfield(s, lbl) && ~strcmpi(lbl, 'sosreorderdlg'),
        try
            setstate(hindx, s.(lbl));
        catch ME %#ok<NASGU>
            sendwarning(this, 'Not all data could be loaded.');
        end
        
        % Remove the field to trim down the extra state information.
        fields2remove{end+1} = lbl;
    end
end

% The FILTERMANAGER may not be there, but we still want to load its
% settings.
if ~any(strcmp(fields2remove, 'filtermanager')) && ...
        isfield(s, 'filtermanager')
    h = getcomponent(this, '-class', 'siggui.filtermanager');
    if isempty(h)
        h = filtermanager(this, 'init');
        setstate(h, s.filtermanager);
    end
    fields2remove{end+1} = 'filtermanager';
end

if isfield(s, 'filterMadeBy')
    fields2remove{end+1} = 'filterMadeBy';
end
s = getVersionSpecs(s);
set(this,'filterMadeBy',s.filterMadeBy);


%--------------------------------------------------------------------
function s = getVersionSpecs(s)
% Get session version specific information.

switch s.version,
case 0,  % R12
    % String indicating where the filter was created by
    s.filterMadeBy = getR12filterMadeBy(s);
    
    % Current Sampling Frequency structure in FDATool
    s.currentFs    = getR12currentFs(s);
    
case 1,  % R12.1
    s.filterMadeBy = s.mode.filtermadeby;
    s.currentFs    = s.currentFs;
end


%--------------------------------------------------------------------
function filterMadeBy = getR12filterMadeBy(s)
% This is the R12 way we stored filterMadeBy (as a number)

filterMadeBy = s.mode.filtermadeby;
switch filterMadeBy,
case 1,  filterMadeBy = 'Designed';
case 2,  filterMadeBy = 'Imported';
end


%--------------------------------------------------------------------
function currentFs = getR12currentFs(s)
% This is the R12 way we stored the sampling frequency 

switch s.mode.filtermadeby
case 1,
    type = s.fdspecs.type;
    switch type
    case {'hp','lp','bp','bs','nyquist','rcos','halfband'}
        path = 'freq';
    otherwise
        path = 'freqmag';
    end
    currentFs.value = str2num(s.fdspecs.(path).(type).fs);
    currentFs.units = s.fdspecs.(path).(type).units;
    
case 2,
    currentFs.value = str2num(s.import_specs.fs.Fs);
    currentFs.units = s.import_specs.fs.freqUnits;
end

% [EOF]
