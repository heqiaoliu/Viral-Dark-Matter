classdef SLUtils
    % For Mathworks internal use only.

    %   Copyright 2009-2010 The MathWorks, Inc.

    methods(Static)

        function lineH = addLine(block1, n1, block2, n2)
            % Adds a line from port n1 of block1 to port n2 of block2.

            lineH = add_line(get_param(block1, 'Parent'), ...
                [get_param(block1, 'Name') '/' num2str(n1)], ...
                [get_param(block2, 'Name') '/' num2str(n2)]);
        end
        
        function ensureConnection(src, srcNum, dest, destNum, soleConnection)
            % Ensure that the srcNum^th port of src is connected to
            % destNum^th port of dest.

            % Whether we require the src block to solely be connected to
            % dest, not anything else.
            if nargin < 5 || isempty(soleConnection)
                soleConnection = 0;
            end

            lineHandles = get_param(dest, 'LineHandles');
            
            % figure out the line connected to the dstNum port of dst
            % block.
            if isa(destNum, 'double')
                lineH = lineHandles.Inport(destNum);
            else
                lineH = lineHandles.(destNum);
            end
            if ~ishandle(lineH)
                lineH = [];
            end

            % find the line connected to the srcNum^th line of the src
            % block.
            srcLineHandles = get_param(src, 'LineHandles');
            if isa(srcNum, 'double')
                srcLineH = srcLineHandles.Outport(srcNum);
            else
                srcLineH = srcLineHandles.(srcNum);
            end
            if ~ishandle(srcLineH)
                srcLineH = [];
            end
            
            % If dst is not yet connected to anything, then just connect to
            % source. We are done.
            if isempty(lineH)
                if soleConnection && ~isempty(srcLineH)
                    delete_line(srcLineH);
                end
                Stateflow.SLUtils.addLine(src, srcNum, dest, destNum);
                return;
            end
            
            % Otherwise verify that dst is connected to src.
            srcPortHandles = get_param(src, 'PortHandles');
            if isa(srcNum, 'double')
                srcPortH = srcPortHandles.Outport(srcNum);
            else
                srcPortH = srcPortHandles.(srcNum);
            end
            
            if get_param(lineH, 'SrcPortHandle') ~= srcPortH
                delete_line(lineH);
                lineH = [];
            end
            
            if isempty(lineH)
                if soleConnection && ~isempty(srcLineH)
                    delete_line(srcLineH);
                end
                Stateflow.SLUtils.addLine(src, srcNum, dest, destNum);
            end
        end
        
        function compactInputsToMerge(mergeH)
            % Reduces the number of input ports of a merge block to match
            % the number of valid input connections. It takes care to move
            % the existing connections to the merge to the top so that they
            % do not get disconnected.
            
            lineHandles = get_param(mergeH, 'LineHandles');
            lineHandles = lineHandles.Inport;
            validLineIdx = find(ishandle(lineHandles));
            if validLineIdx(end) ~= length(validLineIdx)
                for i=1:length(validLineIdx)
                    lineH = lineHandles(validLineIdx(i));
                    srcPortH = get_param(lineH, 'SrcPortHandle');
                    srcPortNum = get_param(srcPortH, 'PortNumber');
                    srcBlockH = get_param(lineH, 'SrcBlockHandle');
                    
                    Stateflow.SLUtils.ensureConnection(srcBlockH, srcPortNum, mergeH, i, true);
                end
            end
            set_param(mergeH, 'Inputs', num2str(length(validLineIdx)));
        end
        
        function handles = findSystem(simBlockH, varargin)
            % Finds a block immediately underneath a subsystem.

            simBlockH = get_param(simBlockH, 'Handle');
            handles = find_system(simBlockH, 'LookUnderMasks', 'on', 'FollowLinks', 'on', 'SearchDepth', 1, varargin{:});
            % remove simBlockH itself. This prevents bugs such as g513389
            % where we inadvertently process the simBlockH itself in
            % addition to its children.
            if ~isempty(handles)
                handles(handles == simBlockH) = [];
            end
        end
        
        function blockH = addBlock(subsysH, src, dest, varargin)
            % Add a block to a subsystem

            subsysPath = getfullname(subsysH);
            blockH = add_block(src, [subsysPath '/' dest], varargin{:});
        end
        
        function err = setNameSafely(blockH, origName)
            % Sets the name of a block. Like the 'MakeNameUnique' option to
            % add_block, it uniquifies the name if a block with the same
            % name already exists.
            
            err = false;
            if strcmp(get_param(blockH, 'Name'), origName)
                return
            end
            
            suffixNum = regexp(origName, '\d+$', 'match');
            if ~isempty(suffixNum)
                origPrefix = origName(1:end-length(suffixNum{1}));
                suffixNum = str2double(suffixNum{1});
            else
                origPrefix = origName;
                suffixNum = [];
            end
            
            while true
                name = [origPrefix num2str(suffixNum)];
                try
                    set_param(blockH, 'Name', name);
                    break
                catch ME
                    err = true;
                    if ~strcmp(ME.identifier, 'Simulink:blocks:DupBlockName')
                        rethrow(ME);
                    end
                    
                    % Increment the trailing number. If there was no number
                    % to start with, then start with 1.
                    if ~isempty(suffixNum)
                        suffixNum = suffixNum + 1;
                    else
                        suffixNum = 1;
                    end
                end
            end
        end
        
        function deleteAllLines(blockH)
            % Delete all lines emanating from a block.

            lineHandles = get_param(blockH, 'LineHandles');

            types = fieldnames(lineHandles);
            for i=1:length(types)
                deleteLines(lineHandles.(types{i}));
            end

            function deleteLines(handles)
                for j=1:length(handles)
                    if ishandle(handles(j))
                        delete_line(handles(j));
                    end
                end
            end
            
        end
        
        function setPosition(blockH, x, y, w, h)
            % A more convenient way to set a block's position.

            set_param(blockH, 'Position', [x, y, x+w, y+h]);
        end
        
        function yn = isOnClipboard(blockH)
            % Is this block on the Simulink_DELETE graph?

            try
                get_param(get_param(blockH, 'Parent'), 'Handle');
                yn = false;
            catch ME %#ok<NASGU>
                yn = true;
            end
        end

        function deleteAllInvalidLines(blockH)
            % Delete all "invalid" lines emanating from a block.
            %
            % An invalid line is one which is not connected to another
            % block.

            lineHandles = get_param(blockH, 'LineHandles');

            types = fieldnames(lineHandles);
            for i=1:length(types)
                deleteInvalidLinesHelper(lineHandles.(types{i}));
            end

            function deleteInvalidLinesHelper(handles)

                for j=1:length(handles)
                    if ishandle(handles(j)) && Stateflow.SLUtils.isLineHandleInvalid(handles(j))
                        delete_line(handles(j));
                    end
                end

            end

        end

        function yn = isAnyPortDisconnected(blockH)
            % Any line connected to the block is disconnected?

            lineHandles = get_param(blockH, 'LineHandles');
            types = fieldnames(lineHandles);
            for ii=1:length(types)
                yn = isAnyInvalidHandle(lineHandles.(types{ii}));
                if yn
                    return
                end
            end
            
            yn = false;
            
            function yn = isAnyInvalidHandle(handles)
                % Any of line handles are invalid?

                for i=1:length(handles)
                    yn = Stateflow.SLUtils.isLineHandleInvalid(handles(i));
                    if yn == true
                        return
                    end
                end
                yn = false;

            end

        end

        function yn = isLineHandleInvalid(handle)
            % Is this line invalid?

            if ~ishandle(handle)
                yn = true;
                return
            end
            % a line being connected to a port doesn't imply that the line
            % itself has a valid source or destination. Note that a forked
            % line can have multiple destinations.
            portHandles = [get_param(handle, 'SrcPortHandle'); get_param(handle, 'DstPortHandle')];
            for j=1:length(portHandles)
                if ~ishandle(portHandles(j))
                    yn = true;
                    return
                end
            end
            yn = false;
        end
        
        function deleteToClipboard(blockH)
            % Delete a block to the Simulink clipboard buffer.
            %
            % Unlike delete_block, using this means that the block can be
            % brought back later.

            % close blockH just in case gcs is actually blockH. This will
            % ensure that the gcs before we delete is still valid after the
            % deletion.
            close_system(blockH);
            cursys = gcs;
            builtin('slInternal', 'delete_to_clipboard', blockH);
            set_param(0, 'CurrentSystem', cursys);
        end
        
        function copyToCopyBuffer(blockH)
            % Copies the block over to the Simulink_SCRAP graph. This is
            % used by Simulink when a paste operation is carried out.

            cursys = gcs;
            builtin('slInternal', 'copy_to_copy_buffer', blockH);
            set_param(0, 'CurrentSystem', cursys);
        end
        
        function flushSimulinkClipboard()
            % Copies the block over to the Simulink_SCRAP graph. This is
            % used by Simulink when a paste operation is carried out.

            cursys = gcs;
            builtin('slInternal', 'copy_to_copy_buffer', []);
            set_param(0, 'CurrentSystem', cursys);
        end
        
        function gotoLibraryLink(blockH)
            % Navigate to the library link for a given linked block. Note
            % that this works even for blocks which are implicit links
            % and blocks for which LinkStatus is 'inactive'.
            
            builtin('slInternal', 'gotoLibraryLink', blockH);
        end

        function prevLock = unlockModel(modelH)
            prevLock = get_param(modelH, 'lock');
            set_param(modelH, 'lock', 'off');
        end
        
        function yn = isFunction(sfH)
            yn = isa(sfH, 'Stateflow.Function') || isa(sfH, 'Stateflow.TruthTable') || isa(sfH, 'Stateflow.SLFunction') || isa(sfH, 'Stateflow.EMFunction');
        end
        
        function yn = isContainer(sfH)
            yn = isa(sfH, 'Stateflow.State') || isa(sfH, 'Stateflow.Box') || Stateflow.SLUtils.isFunction(sfH);
        end

        function proto = getGenericPrototype(fcnName, inputNames, outputNames)
            % A generic prototype maker.

            if length(outputNames) < 1
                str1 = '%s%s';
            elseif length(outputNames) == 1
                str1 = '%s = %s';
            else
                str1 = '[%s] = %s';
            end
            if length(inputNames) < 1
                str2 = '%s';
            else
                str2 = '(%s)';
            end
            formatStr = strcat(str1, str2);
            if isempty(fcnName)
                fcnName = 'simfcn';
            end

            proto = sprintf(formatStr, strjoin(outputNames, ','), fcnName, strjoin(inputNames, ','));

            function strj = strjoin(strs, sep)
                % Joins a cell array of strings with a separator.

                if isempty(strs)
                    strj = '';
                    return;
                end
                total_strs = cell(2*length(strs)-1, 1);
                for i=1:length(strs)
                    if i > 1
                        total_strs{2*i-2} = sep;
                    end
                    total_strs{2*i-1} = strs{i};
                end
                strj = strcat(total_strs{:});
            end
        end

        function destroyDeletedBlock(blockH)
            builtin('slInternal', 'destroy_deleted_block', blockH);
        end
    
        function yn = isStateflowBlock(blockH)
            blockH = get_param(blockH, 'Handle');
            yn = ~isempty(blockH) && ...
                ishandle(blockH) && ...
                strcmpi(get_param(blockH, 'Type'), 'Block') && ...
                strcmpi(get_param(blockH, 'BlockType'), 'Subsystem') && ...
                strcmpi(get_param(blockH, 'MaskType'), 'Stateflow');
        end
        
        function yn = isBuiltinParam(dataName)
            persistent builtinParamNames
            if isempty(builtinParamNames)
                builtinParamNames = fieldnames(get_param('built-in/Subsystem', 'ObjectParameters'));
            end
            yn = any(strcmpi(dataName, builtinParamNames));
        end
    end

end
