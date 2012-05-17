function addFcnCallGenerator(obj)

%   Copyright 2010 The MathWorks, Inc.

    if obj.PortInfo.numOfTriggerPorts > 0
        strPorts = Sldv.SubSystemExtract.getPorts(obj.SubSystemH);
        triggOffset = 0;
        for i = 1:obj.PortInfo.numOfInports
            triggOffset = triggOffset + portTotal(obj.PortInfo.Inport{i});
        end
        for i = 1:obj.PortInfo.numOfEnablePorts
            triggOffset = triggOffset + portTotal(obj.PortInfo.Enable{i});
        end

        rootMdlInports = find_system(obj.ModelH,'searchdepth',1,'BlockType','Inport');

        for trigIdx = 1:obj.PortInfo.numOfTriggerPorts
            trigInfo = obj.PortInfo.Trigger{trigIdx};
            if Sldv.SubSystemExtract.checkSSportInfo(...
                    trigInfo,@Sldv.SubSystemExtract.isFcnCallPort) 
                rootIndex = trigIdx + triggOffset;
                rootPortH = rootMdlInports(rootIndex);
                add_fcn_call_converter(rootPortH,strPorts.hasFcnCalledTriggerPeriodicBlock,trigInfo);
            end
        end
    end
end

% Function: portTotal ===================================================
% Abstract:
%   This function returns total number of inport blocks that are combined
%   with a bus creator into a bus signal. If there is no bus signal it
%   returns 1. Please refer to the bus structure given in
%   matlab/toolbox/rtw/rtw/private/slbus.m for the representation of a bus
%   signal in strucBus
%
function out = portTotal(strucBus)
    if strucBus.type == 2 && ~strucBus.node.hasBusObject
        out = busLength(strucBus);
    else
        out = 1;
    end
end

function out = busLength(strucBus)
    out = 0;
    if strucBus.type == 2 && ~strucBus.node.hasBusObject
        numInports = length(strucBus.node.leafe);
        for i=1:numInports
            out = out + busLength(strucBus.node.leafe{i});
        end
    elseif strucBus.type == 1 || strucBus.node.hasBusObject
        out = 1;
    else
        disp('WARNING: Unknown type of node');
    end
end

function add_fcn_call_converter(origBlk, isPeriodic, strucBus)    

    parentPath = getfullname(get_param(origBlk,'Parent'));
    parentH = get_param(parentPath,'Handle');
    
    ports = get_param(origBlk,'PortHandles');
    outportH = ports.Outport;
    lineH = get_param(outportH,'Line');

    if ~isempty(lineH)
        destPrtH = get_param(lineH,'DstPortHandle');
        delete_line(lineH);
    else
        destPrtH = [];
    end

    wideFcnCall = false;
    if isPeriodic        
        SLLib = 'simulink';
        if isempty(find_system('SearchDepth', 0, 'Name', SLLib))
            load_system(SLLib);
        end
        cnvrtH = get_param('simulink/Ports & Subsystems/Function-Call Generator','Handle');
        newBlkH = add_cnvrt(cnvrtH, origBlk, parentPath);
    else
        cnvrtH = cmp_libblkmgr;
        [newBlkH wideFcnCall] =  add_cnvrt_in_ss(cnvrtH, origBlk, parentPath, strucBus);
    end                
                 
    newPorts = get_param(newBlkH,'PortHandles');
    if isempty(newPorts.Inport)
        sampleTime = get_param(origBlk,'SampleTime');
        set_param(newBlkH,'sample_time',sampleTime);
        delete_block(getfullname(origBlk));
    else
        add_line(parentH, outportH, newPorts.Inport, 'autorouting', 'on');
    end

    if ~isempty(destPrtH)
        add_line(parentH, newPorts.Outport, destPrtH, 'autorouting', 'on');
        if wideFcnCall
            subsystemExtraced = get_param(destPrtH,'Parent');
            rtwSystemCode = get_param(subsystemExtraced,'RTWSystemCode');
            if any(strcmp(rtwSystemCode,{'Auto','Inline'}))
                set_param(subsystemExtraced,'RTWSystemCode','Function');
            end
        end
    end     
end

function [newBlkH wideFcnCall]=  add_cnvrt_in_ss(cnvrtH, origBlk, parentPath, strucBus)
    width = getFunctionCallPortWidth(strucBus);    
    if width==1
        wideFcnCall = false;
        
        newBlkH = add_cnvrt(cnvrtH, origBlk, parentPath);               
    else                
        wideFcnCall = true;
        
        newBlkHSS = add_cnvrt(cnvrtH, origBlk, parentPath, true);
        
        [~, cnvrtHeight, cnvrtWidth] = getBlockPosWidthHeight(cnvrtH);                
        
        newBlkhPath = getfullname(newBlkHSS);
        
        inportH = add_block('built-in/Inport',[newBlkhPath '/In1']);
        outportH = add_block('built-in/Outport',[newBlkhPath '/Out1']);
        
        muxH = add_block('built-in/Mux',[newBlkhPath '/Mux'],'ShowName','off');
        demuxH = add_block('built-in/Demux',[newBlkhPath '/Demux'],'ShowName','off');
        
        set_param(demuxH,'Outputs',num2str(width));
        set_param(muxH,'Inputs',num2str(width));
        
        inportPos = getBlockPosWidthHeight(inportH);
        outportPos = getBlockPosWidthHeight(outportH);
        muxPos = getBlockPosWidthHeight(muxH);
        [demuxPos, ~, demuxWidth] = getBlockPosWidthHeight(demuxH);
        
        shiftx = demuxWidth*5;
        shifty = cnvrtHeight*width;
        newdemuxPos = [demuxPos(1)+shiftx  demuxPos(2) demuxPos(3)+shiftx demuxPos(4)+shifty];
        
        shiftx = demuxWidth*11;
        shifty = cnvrtHeight*width;
        newmuxPos = [muxPos(1)+shiftx  muxPos(2) muxPos(3)+shiftx muxPos(4)+shifty];
        
        shifty = (newdemuxPos(4)-newdemuxPos(2))/2;
        shiftx = demuxWidth*18;
        newinportPos = [inportPos(1) inportPos(2)+shifty inportPos(3) inportPos(4)+shifty];
        newoutportPos = [outportPos(1)+shiftx outportPos(2)+shifty outportPos(3)+shiftx outportPos(4)+shifty];                                
        
        set_param(inportH,'Position',newinportPos);
        set_param(outportH,'Position',newoutportPos);
        set_param(muxH,'Position',newmuxPos);
        set_param(demuxH,'Position',newdemuxPos);
        
        inputPorts = get_param(inportH,'PortHandles');
        outputPorts = get_param(outportH,'PortHandles');
        muxPorts = get_param(muxH,'PortHandles');
        demuxPorts = get_param(demuxH,'PortHandles');
        
        add_line(newBlkHSS, inputPorts.Outport, demuxPorts.Inport, 'autorouting', 'on');
        add_line(newBlkHSS, muxPorts.Outport, outputPorts.Inport, 'autorouting', 'on');
        
        startx = newdemuxPos(3)+(newmuxPos(1)-newdemuxPos(3))/2;
        starty = newdemuxPos(2)+cnvrtHeight/2;
        fcn_call_genPos = [startx starty startx+cnvrtWidth starty+cnvrtHeight];
        blockpath = [newBlkhPath '/' get_param(cnvrtH,'Name')];
        for i=1:width
           fcnCallGenH = add_block(getfullname(cnvrtH),[blockpath '_' num2str(i)],...
               'Position',fcn_call_genPos,'ShowName','off');   
           fcnCallGenPorts = get_param(fcnCallGenH,'PortHandles');
           add_line(newBlkHSS, demuxPorts.Outport(i), fcnCallGenPorts.Inport,'autorouting', 'on');
           add_line(newBlkHSS, fcnCallGenPorts.Outport,muxPorts.Inport(i),'autorouting', 'on');
           fcn_call_genPos = fcn_call_genPos+[0 1 0 1]*cnvrtHeight;
        end
        
        newBlkH = newBlkHSS;
    end    
end

function newBlkH = add_cnvrt(cnvrtH, origBlk, parentPath, addSS)

    if nargin<4
        addSS = false;
    end
    
    [~, cnvrtHeight, cnvrtWidth] = getBlockPosWidthHeight(cnvrtH);
    
    origPos = get_param(origBlk,'Position');

    horzmid = [0 .5 0 .5]*origPos';
    delta = 25;

    newLeft = origPos(3)+delta;
    newBlkPos = [newLeft horzmid-(cnvrtHeight*0.5) newLeft+cnvrtWidth horzmid+(cnvrtHeight*0.5)];           

    blockpath = [parentPath '/' get_param(cnvrtH,'Name')];
    blockpath = Sldv.SubSystemExtract.findUniquePath(blockpath);
    
    if addSS
        newBlkH = add_block('built-in/Subsystem',blockpath,'Position',newBlkPos,'ShowName','off');    
    else
        newBlkH = add_block(getfullname(cnvrtH),blockpath,'Position',newBlkPos,'ShowName','off');    
    end
end

function width = getFunctionCallPortWidth(strucBus)
    if strucBus.type == 1         
        width = prod(strucBus.prm.CompiledPortDimensions);
    else
        % It should have a single leaf
        width = getFunctionCallPortWidth(strucBus.node.leafe{1});
    end  
end

function [blockPos, blockHeight, blockWidth] = getBlockPosWidthHeight(blockH)
    blockPos = get_param(blockH,'Position');
    blockHeight = [0 -1 0 1]*blockPos';
    blockWidth = [-1 0 1 0]*blockPos';
end

function blkH = cmp_libblkmgr

    mdlName = 'sldvextractlib';
    
    try
        get_param(mdlName,'Handle');
    catch Mex %#ok<NASGU>
        load_system(mdlName);
    end    

    blockName = 'Fcn Call Generator';
    try
        blkH = get_param([mdlName '/' blockName],'Handle');
    catch Mex  
        error('SLDV:EXTRACT:BlockPath', 'Block path "%s" not found',blockName);
    end   
end
% LocalWords:  SLDV autorouting searchdepth sldvextractlib
