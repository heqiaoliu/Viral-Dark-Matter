function build_bus_hierarchy(subsysH, nameTree, isRootInportNonVirtual)

%   Copyright 2008-2009 The MathWorks, Inc.

    % Layout constants
    inportWidth   = 24;
    inportHeight  = 12;
    inportVertSep = 24;
    muxWidth      = 5;
    mux2muxSep    = 96;
    winBufferH    = 90;
    winBufferV    = 150;
    inGroupSep    = 12;

    % Global Variables
    nextInportIndex = 1;
    groupCnt = 0;
    allInputPorts = [];
    inputPortBusIdx = [];

    [lastBusH, rightPos] = build_subbus_hierarchy(subsysH, '', nameTree, 1, isRootInportNonVirtual);
    left = rightPos+mux2muxSep;

    outportPos = [left winBufferH left+inportWidth winBufferH+inportHeight];
    outH = add_block('built-in/Outport', [getfullname(subsysH) '/Out'], 'Position',outportPos);
    add_line(subsysH, [get_param(lastBusH,'Name') '/1'],'Out/1');
    portHorzAlign(outH);
    tweak_input_ports();
    eliminate_diagonal_input_lines(lastBusH);
    
    function [blockH, blockRightPos, busIdx] = build_subbus_hierarchy(sysH, parentPath, subTree, busIdx, isRootInportNonVirtual) %#ok<INUSL>
        thisBusIdx = busIdx;
        busIdx = busIdx+1;
        leafCnt = length(subTree)-1;
        sourceBlocks = zeros(1,leafCnt);
        blocksRight = zeros(1,leafCnt);
        sigLabels = cell(1,leafCnt);

        parentPath = subTree{1}.SignalPath;  
        
        for leafIdx=1:leafCnt
            if iscell(subTree{leafIdx+1})
                [sourceBlocks(leafIdx), blocksRight(leafIdx), busIdx] = build_subbus_hierarchy(sysH, parentPath, subTree{leafIdx+1}, busIdx, isRootInportNonVirtual);
                signalNames = sldvshareprivate('util_get_signal_parts',subTree{leafIdx+1}{1}.SignalPath);
                sigLabels{leafIdx} = signalNames{end};
            else
                % Create an input block
                inputBlockInfo = subTree{leafIdx+1};
                signalNames = sldvshareprivate('util_get_signal_parts',inputBlockInfo.SignalLabels);
                thisName = signalNames{end};
                blockName = [parentPath '.' thisName];
                blockTop = winBufferV + ((nextInportIndex-1)*(inportHeight+inportVertSep)) + ...
                           groupCnt*inGroupSep;

                blockPos = [winBufferH ...
                            blockTop ...
                            winBufferH + inportWidth ...
                            blockTop + inportHeight];

                blocksRight(leafIdx) = winBufferH + inportWidth;

                blkH = add_block('built-in/Inport',  [getfullname(sysH) '/' blockName], ...
                                 'Position',              blockPos, ...
                                 'NamePlacement',    'Alternate' );

                sourceBlocks(leafIdx) = blkH;
                nextInportIndex = nextInportIndex + 1;
                sigLabels{leafIdx} = thisName;
                allInputPorts = [allInputPorts blkH];               %#ok<AGROW>
                inputPortBusIdx = [inputPortBusIdx thisBusIdx];     %#ok<AGROW>
            end
        end

        groupCnt = groupCnt + 1;

        % Create the bus creator
        busLeft = max(blocksRight) + mux2muxSep;
        blockRightPos = busLeft + muxWidth;
        busTop = winBufferH;
        busBottom = busTop + leafCnt*(inportHeight+inportVertSep);
        busPos = [busLeft busTop blockRightPos busBottom];

        blockH = add_block('built-in/BusCreator',  [getfullname(sysH) '/' parentPath], ...
                         'Position',              busPos, ...
                         'Inputs',                num2str(leafCnt), ...
                         'ShowName',              'off' );
        connect_blocks(sysH, sourceBlocks, blockH);
        portHorzAlign(blockH);

        set_param(blockH,'UseBusObject','on');
        set_param(blockH,'BusObject',subTree{1}.BusObject);
        if isRootInportNonVirtual
            set_param(blockH,'NonVirtualBus','on');
        else
            set_param(blockH,'NonVirtualBus','off');
        end
        
        % Label the signals
        blkPorts = get_param(blockH,'PortHandles');
        for idx = 1:leafCnt
            set_param(get_param(blkPorts.Inport(idx),'Line'),'Name',sigLabels{idx});
        end
    end


    function connect_blocks(sysH, srcBlks, destBlks)
        singleSrc = length(srcBlks)==1;
        singleDest = length(destBlks)==1;

        if singleSrc
            cnt = length(destBlks);
        else
            cnt = length(srcBlks);
        end

        for idx = 1:cnt
            if singleSrc
                srcIdx = idx;
                srcBlkH = srcBlks(1);
            else
                srcIdx = 1;
                srcBlkH = srcBlks(idx);
            end

            if singleDest
                destIdx = idx;
                destBlkH = destBlks(1);
            else
                destIdx = 1;
                destBlkH = destBlks(idx);
            end

            srcPorts = get_param(srcBlkH, 'PortHandles');
            destPorts = get_param(destBlkH, 'PortHandles');

            add_line(sysH, srcPorts.Outport(srcIdx), destPorts.Inport(destIdx), ...
                    'autorouting','off');

        end
    end


    function portHorzAlign(blockH)
        blkPorts = get_param(blockH,'PortHandles');
        blkStartPos = get_param(blockH,'Position');

        inPort1Pos = get_param(blkPorts.Inport(1),'Position');
        srcPort1 = get_param(get_param(blkPorts.Inport(1),'Line'),'SrcPortHandle');
        srcPort1Pos = get_param(srcPort1,'Position');

        if (length(blkPorts.Inport)>1)

            inPortNPos = get_param(blkPorts.Inport(end),'Position');
            srcPortN = get_param(get_param(blkPorts.Inport(end),'Line'),'SrcPortHandle');
            srcPortNPos = get_param(srcPortN,'Position');

            growFactor = (srcPortNPos(2) - srcPort1Pos(2)) / (inPortNPos(2) - inPort1Pos(2));

            blockHeight = blkStartPos(4) - blkStartPos(2);
            newHeight = blockHeight * growFactor;

            % Resize the block so the ports are directly scaled correctly
            set_param(blockH,'Position', [blkStartPos(1:3) blkStartPos(2)+newHeight]);

            inPort1Pos = get_param(blkPorts.Inport(1),'Position');
        else
            newHeight = blkStartPos*[0 -1 0 1]';
        end

        % Translate the blocks so the ports are directly across from one another
        moveDown = srcPort1Pos(2) - inPort1Pos(2);

        finalPosition = [blkStartPos(1), ...
                         blkStartPos(2) + moveDown, ...
                         blkStartPos(3), ...
                         blkStartPos(2) + moveDown + newHeight];

        set_param(blockH,'Position', finalPosition);
    end


    
    function tweak_input_ports
        % The first block should always be ok
        bufferWidth = 4;
        posBlk1 = get_param(allInputPorts(1),'Position');
        portTopConstraint = posBlk1(end) + bufferWidth + inportHeight/2;

        for idx=2:length(allInputPorts)
            blkPorts = get_param(allInputPorts(idx),'PortHandles');
            portPos = get_param(blkPorts.Outport(1),'Position');
            blkStartPos = get_param(allInputPorts(idx),'Position');
            connectionPos = get_param(get_param(get_param(blkPorts.Outport(1), ...
                            'Line'),'DstPortHandle'),'Position');

            nextConsIdx = idx + find(inputPortBusIdx((idx+1):end)-inputPortBusIdx(idx));
            if isempty(nextConsIdx)
                portBotConstraint = inf;
            else
                nextConsIdx = nextConsIdx(1);
                consblkPorts = get_param(allInputPorts(nextConsIdx),'PortHandles');
                consPortPos = get_param(consblkPorts.Outport(1),'Position');
                portBotConstraint = consPortPos(2) - (nextConsIdx-idx)*(bufferWidth+inportHeight);
                
                if (nextConsIdx>(idx+1))
                    portBotConstraint = portBotConstraint - (nextConsIdx-idx-1)*inportVertSep;
                end
            end

            if connectionPos(2)>portTopConstraint && connectionPos(2)<portBotConstraint
                deltaH = connectionPos(2) - portPos(2);
                set_param(allInputPorts(idx),'Position',blkStartPos+[0 1 0 1]*deltaH);
                portTopConstraint = connectionPos(2) + bufferWidth + inportHeight;
            else
                portTopConstraint = portPos(2) + bufferWidth + inportHeight;
            end

        end
    end


    function eliminate_diagonal_input_lines(blockH)
        blkPorts = get_param(blockH,'PortHandles');
        inputCnt = length(blkPorts.Inport);

        inputLines = zeros(1,inputCnt);
        destX = zeros(1,inputCnt);
        srcX = zeros(1,inputCnt);
        destY = zeros(1,inputCnt);
        srcY = zeros(1,inputCnt);
        srcBlocks = zeros(1,inputCnt);

        for idx=1:inputCnt
            inputLines(idx) = get_param(blkPorts.Inport(idx),'Line');
            srcPort = get_param(inputLines(idx),'SrcPortHandle');
            srcBlocks(idx) = get_param(get_param(srcPort,'Parent'),'Handle');
            srcPortPos = get_param(srcPort,'Position');
            srcX(idx) = srcPortPos(1);
            srcY(idx) = srcPortPos(2);
            portPos = get_param(blkPorts.Inport(idx),'Position');
            destX(idx) = portPos(1);
            destY(idx) = portPos(2);
        end

        needsAdjust = srcY~=destY;

        if any(needsAdjust)
            overlapsNext = ((srcY(2:end) < destY(1:(end-1))) | (srcY(1:(end-1)) > destY(2:end)));
            
            % Find the edges of overlapping sets
            ov = [false overlapsNext false];
            setPts = find(ov(1:(end-1))~=ov(2:end));
            missingIdx = needsAdjust & ~([overlapsNext false] | [false overlapsNext]);
            
            indSingles = num2cell(find(missingIdx));
            setCnt = length(setPts)/2;
            indSets = cell(1,setCnt);

            for j=1:setCnt
                indSets{j} = (setPts(2*j-1)):(setPts(2*j));
            end

            indSets = [indSets indSingles];
            

            for setIdx = 1:length(indSets)
                thisSet = indSets{setIdx};
                setCnt = length(thisSet);

                for elmIdx = 1:setCnt
                    ratio = elmIdx/(setCnt+1);
                    idx = thisSet(elmIdx);

                    if srcY(idx)<destY(idx)
                        deltaDest = ratio*mux2muxSep;
                    else
                        deltaDest = (1-ratio)*mux2muxSep;
                    end

                    midX = muxWidth + destX(idx) - deltaDest;
                    points = [ ...
                        srcX(idx) srcY(idx); ...
                        midX srcY(idx); ...
                        midX destY(idx); ...
                        destX(idx) destY(idx)];
                    set_param(inputLines(idx),'Points',points);
                end
            end
        end


        % Recurse to blocks that feed this
        for idx=1:inputCnt
            eliminate_diagonal_input_lines(srcBlocks(idx));
        end
    end
end
