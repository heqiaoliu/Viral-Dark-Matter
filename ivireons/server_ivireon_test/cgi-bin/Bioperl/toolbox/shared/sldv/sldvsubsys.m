function sldvsubsys(method, varargin)
%sldvsubsys - Utility function to manage the verification subsystem
%

%   Copyright 2007-2008 The MathWorks, Inc.

    if nargin<1
        method = 'init';
    end

    if nargin<2
        blockH = gcbh;
    else
        blockH = varargin{1};
    end

    switch lower(method)
      case 'check'
        consistency_check(blockH);

      case 'copy'
        refBlk = get_param(blockH, 'ReferenceBlock');
        if ~isempty(refBlk)
            libName = bdroot(refBlk);
            if (strcmpi(libName,'sldvlib'))
                set_param(blockH,'LinkStatus','none');

                % Remove the default description that is
                % used by the Simulink browser
                set_param(blockH,'Description','');
            end
        end

      case 'maskinit'
        modelH = bdroot(blockH);
        xlateMode = get_param(modelH,'RTWExternMdlXlate');

        if xlateMode == 1
            set_param(blockH,'SimViewingDevice','off');
        else
            set_param(blockH,'SimViewingDevice','on');
        end


      otherwise
        error('SLDV:SldvSubSys:UnknownMethod', 'Unknown method');
    end


function consistency_check(blockH)
% Block should be an atomic subsystem
    atomic = get_param(blockH,'TreatAsAtomicUnit');
    if ~strcmp(atomic,'on')
        config_error(blockH,'enable "treat as atomic unit"');
    end

    % MaskType should be 'VerificationSubsystem'
    maskType = get_param(blockH,'MaskType');
    if ~strcmp(maskType,'VerificationSubsystem')
        config_error(blockH,'set Mask Type to  "VerificationSubsystem"');
    end

    % Should not have output ports
    portHandles = get_param(blockH,'PortHandles');
    if ~isempty(portHandles.Outport)
        config_error(blockH,'remove all output ports');
    end

function config_error(blockH, msg)
    title = 'Configuration Error';
    blockName = get_param(blockH,'Name');
    details = ['The block "' blockName '" is not configured as a valid ' ...
               'Verification Subsystem.  You should ' msg ' to correct ' ...
               'the configuration.  Please do this before saving the model'];

    set_param(blockH,'HiliteAncestors','error');
    h = warndlg(details,title);

    ePath = escape_path(blockH);
    close_cb = sprintf('set_param(sprintf(''%s''),''HiliteAncestors'',''none'');', ePath);
    set(h,'DeleteFcn',close_cb);

function out = escape_path(blockH)
    out = getfullname(blockH);
    out = strrep(out, '\','\\');
    out = strrep(out, sprintf('\n'),'\n');
    out = strrep(out, sprintf('\t'),'\t');
