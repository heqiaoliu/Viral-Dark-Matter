function map_signal_ranges(modelH,covdata,informerObj)

% Copyright 2003-2008 The MathWorks, Inc.

    % Function to put signal range information on all lines
    lineHandles = find_system(modelH,'findall','on','LookUnderMasks','all','FollowLinks','on','type','line','SegmentType','trunk');
    srcBlockH = get_param(lineHandles ,'SrcBlockHandle');
    
    % Filter line handles that don't have valid src blocks
    if ~iscell(srcBlockH)
        srcBlockH = {srcBlockH};
    end
    
    srcBlockVectH = [srcBlockH{:}]';
    NotValid = srcBlockVectH==-1;
    lineHandles(NotValid) = [];
    srcBlockH(NotValid) = [];
    
    % Get port handles
    srcPortH = get_param(lineHandles ,'SrcPortHandle');
    if ~iscell(srcPortH)
        srcPortH = {srcPortH};
    end

    srcPortIdx = get_param([srcPortH{:}]', 'PortNumber');
    if ~iscell(srcPortIdx)
        srcPortIdx = {srcPortIdx};
    end

    isVirtual = strcmp(get_param([srcBlockH{:}]','Virtual'),'on');
    isConnection = strcmp(get_param([srcPortH{:}]','PortType'),'connection');
    
    lineCnt = length(lineHandles);
    
    % Remap virtual blocks to their non-virtual sources.
    virtualIdx = find(isVirtual & ~isConnection);
    for lineIdx = virtualIdx(:)'
        srcPorts = get_param(lineHandles(lineIdx),'NonVirtualSrcPorts');
        % In certain situations this can return -1 one known example is
        % disconnected lines going through configurable subsystems
        if ~any(srcPorts==-1)
            portCnt = length(srcPorts);
            thisSrcBlock = zeros(portCnt);
            thisSrcPortIdx = zeros(portCnt);

            for i = 1:portCnt
                porti = srcPorts(i);
                linei = get_param(porti,'Line');
                thisSrcBlock(i) = get_param(linei ,'SrcBlockHandle');
                thisSrcPortIdx(i) = get_param(porti,'PortNumber');
            end

            srcBlockH{lineIdx} = thisSrcBlock;
            srcPortIdx{lineIdx} = thisSrcPortIdx;
        end
    end

    for i=1:lineCnt
        if ~isConnection(i)
            map_single_signal_ranges(informerObj, lineHandles(i), srcBlockH{i}, srcPortIdx{i}, covdata, modelH);
        end
    end

function labelstr = formatted_block_name(blockH, mdlNameLength)
    maxStrLength = 45;
    maxParentLength = 14;

    blkPath = getfullname(blockH);
    dispPath = blkPath((mdlNameLength+1):end);
    dispPath = strrep(dispPath,char(10),' ');
    
    % Carefully choose the format of the block path to display the most
    % meaningful data that can fit in the limited space.
    if length(dispPath)<=maxStrLength
        % Option 1:  /blockname or /sys/block or /sys/subsys/block
        labelstr = dispPath;
    else
        parentH = get_param(get_param(blockH,'Parent'),'Handle');
        if (parentH == bdroot(blockH))
            % Option 2 /verylongblocknametruncatedwith...
            labelstr = [dispPath(1:(maxStrLength-3)) '...'];
        else
            grandParentH = get_param(get_param(parentH,'Parent'),'Handle');
            parentName = get_param(parentH,'Name');
            
            if (grandParentH == bdroot(blockH))
                if (length(parentName)>maxParentLength)
                    % Option 3: /parent.../blockname   
                    labelstr = ['/' parentName(1:(maxParentLength-3)) '.../' get_param(blockH,'Name')];
                else
                    % Option 4: /parent/blockname... 
                    labelstr = dispPath;
                end    
            else
                if (length(parentName)>maxParentLength)
                    % Option 5: /../parent.../blockname
                    labelstr = ['/../' parentName(1:(maxParentLength-3)) '.../' get_param(blockH,'Name')];
                else
                    % Option 6: /../parent/blockname...
                    labelstr =  ['/../' parentName '/' get_param(blockH,'Name')];
                end    
            end
            
            if(length(labelstr)>maxStrLength)
                labelstr = [labelstr(1:(maxStrLength-3)) '...'];
            end
        end
    end



function map_single_signal_ranges(informerObj, lineHandle, blocks, ports, covdata, modelH)

    % XXX - Temporarily make the assumption that all of the
    % elements from an outport appear in the line.  This may
    % not be true for lines that have virtual blocks as the 
    % graphical source.
    
    % WISH - We need to implement an efficient way to prune the
    % display for large vectorized or bus signals.

	% Return early if nay of the source blocks had coverage disabled
	if isempty(blocks) || any(strcmp(get_param(blocks(:,1),'DisableCoverage'),'on'))
		return;
	end


    lineUdi = get_param(lineHandle,'LineOwner');
    
    allNames = {};
    allMins = [];
    allMaxs = [];
    allVarDims = [];
    
    modelNameLength = length(get_param(modelH,'Name'));
    
    
    try
        for i = 1:length(blocks)
            name = {formatted_block_name(blocks(i),modelNameLength)};
            [mins,maxs] = sigrangeinfo(covdata,blocks(i),ports(i));
           %[mins,maxs, vardims] = sigrangeinfo(covdata,blocks(i),ports(i));
            allNames = [allNames  name(ones(1,length(mins)))];     %#ok
            allMins = [allMins mins]; %#ok
            allMaxs = [allMaxs maxs]; %#ok
            %allVarDims = [allVarDims vardims];
        end
    
        tableData.allNames = allNames;
        tableData.allMins = allMins;
        tableData.allMaxs = allMaxs;
        if ~isempty(allVarDims)
            tableData.allVarDims = allVarDims;
        end
        totalWidth = length(allMins);
        dispRows = min([totalWidth 20]);
    
        if isempty(allVarDims)
        template = {'$<B>Idx</B>', '$<B>Source Block</B>','$<B>Min</B>', '$<B>Max</B>', '\n', ...
                      {'ForN', dispRows, ...
                        '@1', {'#allNames','@1'}, {'#allMins','@1'}, {'#allMaxs','@1'}, '\n'} ...
                   };
        else
          template = {'$<B>Idx</B>', '$<B>Source Block</B>','$<B>Min</B>', '$<B>Max</B>', '$<B>VarDims</B>', '\n', ...
                      {'ForN', dispRows, ...
                        '@1', {'#allNames','@1'}, {'#allMins','@1'}, {'#allMaxs','@1'}, {'#allVarDims','@1'},'\n'} ...
                   };
        end
    
        systableInfo.cols(1).align = 'LEFT';
        systableInfo.cols(2).align = 'LEFT';
        if ~isempty(allVarDims)
        systableInfo.cols(3).align = 'CENTER';
            systableInfo.table = ' CELLPADDING="3" CELLPADDING="2" CELLSPACING="1"';
        else
        systableInfo.table = '  CELLPADDING="2" CELLSPACING="1"';
        end
        systableInfo.textSize = 4;
    
        tableStr = cv('Private','html_table',tableData,template,systableInfo);
        if ~isempty(informerObj)
            informerObj.mapData(lineUdi,['<big> <BR> ' tableStr '</big>']);
        end
    catch
    end
    
    
    