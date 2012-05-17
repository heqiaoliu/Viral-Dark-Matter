function varargout = fdesignblkfcn(hBlk, classname)
%FDESIGNBLKFCN   Gateway for Filter Design blocks.

%   Author(s): J. Schickler
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.14 $  $Date: 2010/03/15 23:30:37 $

if nargout
    [varargout{1:nargout}] = feval(classname{1}, hBlk, classname{2:end});
else
    feval(classname{1}, hBlk, classname{2:end});
end

% ------------------------------------------------------------------
function h = OpenFcn(hBlk, classname) %#ok
% hBlk - Handle to the block we are opening.
% classname - constructor to the design object.


if isLockedModel(hBlk)
    h = FilterDesignDialog.DesignBlock(hBlk, classname);
    % Suppress meaningless UDD errors from FDESIGN
    return;
end

hDesigner = getObject(hBlk);

% If the dialog is disabled and the block type can be used without a Filter
% Design Toolbox license, ask the user if he/she wants to reset the block
% to get a fully editable version.
if ~isfdtbxinstalled && hDesigner.isResetable && ~hDesigner.Enabled
    title = DAStudio.message('FilterDesignLib:FilterDesignDialog:fbQuestionDialogTitle');
    str = DAStudio.message('FilterDesignLib:FilterDesignDialog:fbQuestionDialogStr');
    keepUsingStr = DAStudio.message('FilterDesignLib:FilterDesignDialog:fbKeepUsingStr');
    resetStr = DAStudio.message('FilterDesignLib:FilterDesignDialog:fbResetStr');
    switch questdlg(str, title, keepUsingStr, resetStr, keepUsingStr);
        case keepUsingStr
            % No op.
        case resetStr
            % The copy is needed to go through load and enable the dialog.
            hDesigner = copy(feval(hDesigner.class,'OperatingMode','Simulink'));
            Hd = design(hDesigner);
            generateFilter(hBlk, Hd);
            setObject(hBlk, hDesigner);
    end
end

if isempty(hDesigner) || ~isa(hDesigner, 'FilterDesignDialog.AbstractDesign')
    h = FilterDesignDialog.DesignBlock(hBlk, classname);
    hDesigner = h.CurrentDesigner;
    setObject(hBlk, hDesigner);
else
    h = FilterDesignDialog.DesignBlock(hBlk, hDesigner);
end

% Attach a listener to the DialogApplied event of the designer.  This event
% will "dirty" the block and attempt to refresh the contained system.
l = handle.listener(hDesigner, 'DialogApplied', @(hSrc, ed) dialogApplied(hBlk, hDesigner));
if ~isprop(h, 'DialogAppliedListener')
    schema.prop(h, 'DialogAppliedListener', 'handle.listener');
end
set(h, 'DialogAppliedListener', l);


% ------------------------------------------------------------------
function CopyFcn(hBlk) %#ok

set(hBlk, 'ReferenceBlock', '');

% ------------------------------------------------------------------
function InitFcn(hBlk,ApplyDialog)

if nargin<2,
    ApplyDialog = false;
end

% h is empty by default to save load time.  The contained block is
% generated already so we do not need to call REALIZEMDL again.  It is also
% normalized, which means that we do not need to check the sample rate.
h = getObject(hBlk);
if isempty(h)
    return;
end

% Check the sample rates and warn if they do not match.
checkSampleRates(hBlk, h);

% The design was not modified. 
if ~ApplyDialog,
    return;
end

try
    [Hd, same] = design(h);    
catch e

    % same must be defined to avoid assertions.
    same = true;

    % Cache the last error string.
    errStr = cleanerrormsg(e.message);

    error(errStr);
end

% The design() may change the "LastAppliedSpec"
% We need update this change to block object.
setObject(hBlk, h);

% If the design is the same, there is no reason to continue because the
% model should already be up to date.
if same
    return;
end

generateFilter(hBlk, Hd);

% -------------------------------------------------------------------------
function generateFilter(hBlk, Hd)

% Get the block info
blkName = 'Generated Filter Block';
sysName = sprintf('%s/%s', get(hBlk, 'Path'), get(hBlk, 'Name'));

% Suppress REALIZEMDL warnings
w = warning('off'); %#ok
[lstr, lid] = lastwarn;

if isa(Hd, 'dfilt.abstractsos')
    set(Hd, 'OptimizeScaleValues', false);
end

try
    if isa(Hd,'dfilt.farrowfd'),
        % Turn optimizations on because there are no tunable parameters for
        % this block
        realizemdl(Hd, 'OverwriteBlock', 'on', ...
        'OptimizeZeros', 'on', ...
        'OptimizeOnes', 'on', ...
        'OptimizeDelayChains', 'on', ...
        'OptimizeNegOnes', 'on', ...
        'Destination', sysName, ...
        'BlockName',   blkName);
    else
        % Generate a new block.
        realizemdl(Hd, 'OverwriteBlock', 'on', ...
        'OptimizeZeros', 'off', ...
        'OptimizeOnes', 'off', ...
        'OptimizeDelayChains', 'off', ...
        'OptimizeNegOnes', 'off', ...
        'Destination', sysName, ...
        'BlockName',   blkName);
    end
catch e
    lastwarn(lstr, lid);
    warning(w);
    throwAsCaller(e);
end

lastwarn(lstr, lid);
warning(w);

% -------------------------------------------------------------------------
function dialogApplied(hBlk, hDesigner)

if ~hDesigner.Enable,
    return
end

try
    setObject(hBlk, hDesigner);
    InitFcn(hBlk,true);
catch e
    error(cleanerrormsg(e.message));
end

% -------------------------------------------------------------------------
function checkSampleRates(hBlk, h)

if ~strncmpi(h.FrequencyUnits, 'normalized', 10)

    blk_Ts = get_param(hBlk,'CompiledSampleTime');

    blk_Ts = blk_Ts(1);

    if blk_Ts ~= 0
        design_Ts = 1/convertfrequnits(evaluatevars(h.InputSampleRate), ...
            h.FrequencyUnits, 'Hz');
        if design_Ts ~= blk_Ts
            warning(generatemsgid('inputSampleRateMismatch'), ...
                'The input sample rate specified in ''%s'' does not match the input sample time.', get(hBlk, 'Name'));
        end
    end
end

%---------------------------------------------------------------
function setObject(hBlk, hDesigner)

set(hBlk, 'UserData', saveobj(hDesigner));

%---------------------------------------------------------------
function hDesigner = getObject(hBlk)

ud = get(hBlk, 'UserData');

if isstruct(ud)
    hDesigner = feval([ud.class '.load'], ud);
else
    hDesigner = ud;
end

%---------------------------------------------------------------
function boolflag = isLockedModel(hBlk)
%ISLOCKEDMODEL returns 1 for a locked model and 0 for an unlocked model
% Input can be either hBlk or hFDA.

% Get the handle to the model and get its locked status.
hModel = bdroot(hBlk);

boolflag = strcmpi(get_param(hModel, 'lock'), 'on');

% [EOF]
