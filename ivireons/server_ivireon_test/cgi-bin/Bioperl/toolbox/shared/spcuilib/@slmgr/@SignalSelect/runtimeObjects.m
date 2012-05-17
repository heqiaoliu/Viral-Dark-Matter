function [driver,errMsg] = runtimeObjects(this)
%RuntimeObjects Return structure containing runtime objects
%  Get all nonvirtual drivers of the selected signal
%
% Returns driver structure:
%        .porth
%        .portIdx
%        .porttype:  string, 'outport','inport','trigger', etc
%        .blkh
%        .rto

% Copyright 2004-2010 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2010/03/08 21:44:07 $

% The runtime object for virtual (subsystem implementations) comes up
% empty.
% It is up to us to chase down the internal non-virtual driver of the desired
% outport.

% Note that if the signal is output from a Bus Selector or Demux,
% we must do things carefully.

% Get non-virtual port that drives output port
% Get handle to block(s) that owns this non-virtual output port,
% and port type/index for each
%
% Note: don't use vectorized get's, as it will return
%       cell-arrays and we want "nicer" vectors

errMsg = '';

for indx=1:numel(this)

    blkh    = this(indx).Block;
    portIdx = this(indx).PortIndex;
    porth   = this(indx).Port;
    
    % Loop over each port
    % Find non-virtual driver of this signal
    %
    [driver(indx),errMsg] = get_one_nonvirtual_driver_from_oport(porth.handle);  %#ok xxx
    
    % Verify that driver was found (perhaps block was deleted?)
    if isempty(driver(1).rto) || ~isempty(errMsg)
        return
    end
    
    % At this point, we only do a few things
    %   1 - unify to cell-arrays if scalars
    %   2 - chase down bus-selector input and modify accordingly
    %   3 - error for demux
    %   4 - error if not output ports
    
    % xxx Bug Fix:  BusSelector
    %
    % If the original line was from a Bus Selector, 
    %  AND the source was a bus-expanded block,
    %    THEN the bug is that the full bus is returned
    %    i.e., multiple RTO objects.  Only one RTO should
    %    have been returned.
    %
    % Fix: manually down-select to the appropriate
    %    run-time object from the non-virtual source,
    %    but only if the source was bus-expanded.
    %
    isBusSelector = strcmpi(get(blkh,'blocktype'),'busselector');
    if isBusSelector
        rto = driver(indx).rto;
        if numel(rto)>1        % if >1 RTO returned => bus-expanded
            driver(indx).rto = rto(portIdx);  %#ok just the one we wanted
        end
    end

    % xxx Bug Fix: Demux
    %
    % nonvirt method won't walk back through demux
    isDemux = strcmpi(get(blkh,'blocktype'),'demux');
    if isDemux,
        errMsg = sprintf(['Demux blocks are not supported.\n\n' ...
                          'Tip: Use Bus Creator and Bus Selector blocks']);
        srcInfo.blkh=[];  % no blocks selected
        return
    end
    
    % Scalar fixup: place scalars in cell-arrays, to match
    % the same cell-array format used for vector signals
    % (no need to do .porth)
    %
    Nj = numel(driver(indx).porth);  % # drivers of this signal
    if Nj==1
        driver(indx).portIdx  = {driver(indx).portIdx}; %#ok
        driver(indx).porttype = {driver(indx).porttype}; %#ok
        driver(indx).blkh     = {driver(indx).blkh}; %#ok
        driver(indx).rto      = {driver(indx).rto}; %#ok
    end

    % Display driver info to command window,
    % if it differs from graphical block
    %
    if 0 
        if ~isequal(driver(indx).blkh, blkh) %#ok
            fprintf('Actual signal driver:\n');
            if Nj==1
                fprintf('\t%d: Block "%s", %s(%d)\n', ...
                    indx, ...
                    getfullname(driver(indx).blkh{1}), ...
                    driver(indx).porttype{1}, driver(indx).portIdx{1} );
            else
                for jndx=1:Nj
                    fprintf('\t%d.%d: Block "%s", %s(%d)\n', ...
                        indx,j, ...
                        getfullname(driver(indx).blkh{jndx}), ...
                        driver(indx).porttype{jndx}, driver(indx).portIdx{jndx} );
                end
            end
        end
    end
    
    % Error if driver is not an output port
    % Only doing this because we manually call OutputPort
    % method on the RTO later on
    %
    for jndx=1:Nj
        if ~strcmpi(driver(indx).porttype{jndx},'outport'),
            errMsg = sprintf(['Driver signal #%d driven by port type "%s"\n' ...
                           'Can only connect to signals driven by Output ports'], ...
                          indx, driver(indx).porttype{jndx});
            return
        end
    end
end

% -------------------------------------------------------
function [driver,errMsg] = get_one_nonvirtual_driver_from_oport(port_i)
% Return one driver structure filled with data
% from chasing non-virtual source back to its actual source

errMsg = '';
if ~ishandle(port_i)
    % Failure
    errMsg = 'Invalid Simulink port description.';
    driver.porth    = [];
    driver.portIdx  = [];
    driver.porttype = '';
    driver.blkh     = [];
    driver.rto      = [];  % this is the indicator of failure
else
    % Use "AtomicNonVirtualSrcPorts", and not "NonVirtualSrcPorts"
    % The new "Atomic" version stops backtracking when it reaches
    % an atomic subsystem, whereas the non-Atomic version keeps going.
    % This is important for for-loop subsystems, otherwise we see the
    % result of each iteration instead of after all iterations finish.
    % Also important for enabled subsystems, so we see the held value
    % even when the system is disabled.
    %
    % Keep this as numeric handles, not objects, for convenience
    src_port_i = get_param(port_i,'AtomicNonVirtualSrcPorts');
    if isempty(src_port_i)
        % no nonvirtual driver ... this block is it:
        src_port_i = port_i;
    end
    
    % The following code block addresses: g320758. It handles cases when
    % MPLAY is connected to subsystems outports. This includes the case
    % when an outport backtrack is connected to multiple inports and at
    % least one is the outport of a subsystem.
    blk = cell(numel(src_port_i), 1);
   
    for I = 1:numel(src_port_i)
        blk_i = get_param(src_port_i(I),'parent'); % block driving non-virt port
  
        % Check the parent block in case it was removed
        try
            get_param(blk_i,'handle'); % translate string to handle
        catch e %#ok
            driver.blkh = [];
            driver.rto = [];
            errMsg = {'Driver block no longer present.'};
            return;
        end

        % Workaround for g255469. Check the block type. If the data field of
        % the subsystem rto is empty, there will be no data available for
        % display in the MPlay that is attached to outport of the subsystem.
        if strcmpi(get_param(blk_i, 'BlockType'), 'SubSystem')
            hports = get_param(blk_i, 'PortHandles');
            hport = hports.Outport(get_param(src_port_i(I),'portnumber'));
            hline = get_param(hport, 'Line');
            if hline ~= -1
                src_i = get_param(hline, 'NonVirtualSrcPorts');
                blk_i = get_param(src_i,'parent');
                src_port_i(I) = src_i;
            end
        end
        blk{I, 1} = blk_i;
    end
    
    if numel(src_port_i) > 1
        blk_i = blk;
    end
    
    driver.porth    = src_port_i;
    driver.portIdx  = get_param(src_port_i,'portnumber');
    driver.porttype = get_param(src_port_i,'porttype');

    driver.blkh = [];
    driver.rto = [];
    
    % An error would be improperly thrown here if a block, to which MPlay
    % was previously attached, is removed and the model re-run
    try
        driver.blkh = get_param(blk_i,'handle'); % translate string to handle
    catch e %#ok
        errMsg = {'Driver block no longer present.'};
        return
    end

    % Getting the RTO could fail if the block was reduced
    % or otherwise removed via optimization
    try
        driver.rto = get_param(blk_i,'runtimeobject');
    catch e %#ok
        errMsg = {'No data available for signal.  Consider turning off ', ...
                  'block reduction optimization for the model.'};
        return
    end
	
	% problem for virtual blocks (selector block, etc)
	if isempty(driver.rto)
		errMsg = sprintf(['Simulink is unable to display the output signal of a virtual ''%s'' block.\n\n'...
						'Connect to a block or signal that supports display.'],...
						get_param(blk_i, 'BlockType'));
	end
end

% [EOF]
