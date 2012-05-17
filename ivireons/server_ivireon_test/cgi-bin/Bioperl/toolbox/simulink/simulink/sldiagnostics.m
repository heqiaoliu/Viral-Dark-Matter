function [textout,report] = sldiagnostics(sys, varargin)
%SLDIAGNOSTICS count blocks, sizes, time, and memory used in update diagram
%
%   [TXTRPT, SRPT] = SLDIAGNOSTICS(SYS,'CountBlocks') counts the blocks in 
%   SYS and produces both a textual report and a structure array with
%   fields 'ismask', 'type', and 'count' for the block count calculation.
%   The block count gives the number of each unique type of block or mask
%   found in a system, including hidden blocks.  This effectively reports 
%   all the blocks Simulink is processing when it operates on SYS.
%
%   The system does not have to be currently loaded as long as it is
%   on the MATLAB path.  The search continues into masked subsystems to
%   any search depth.  Special accounting is used for Stateflow, Truth
%   Table, and Embedded MATLAB blocks.
%
%   SLDIAGNOSTICS(SYS,OPTIONS) performs each operation listed in
%   OPTIONS. Valid choices for OPTIONS are given below.
%
%   Notes:
%   - Library Links ARE followed during the analysis.
%   - Model References ARE NOT followed during the analysis.
%   - Not all options are supported when SYS is a subsystem rather than the
%     model root. In these cases the analysis is performed upon the model
%     root, and a warning is issued.
%   - When called upon a Simulink library any analysis that requires the
%     model to be compiled (update diagram) will not be performed.
%
%   Options:
%
%   'All'         - performs all diagnostics
%  
%   'CountBlocks' - returns a textual report giving the number of
%                   unique block and mask types found in a system.
%                   The system does not have to be currently loaded 
%                   as long as it is on the MATLAB path.  The search
%                   looks into masked subsystems to any search depth.
%                   Can also return a data structure in the second
%                   return value.
%
%   'CountSF'     - returns a textual report giving the number of
%                   Stateflow objects of each type. Can also return
%                   a data structure in the second return value.
%
%   'CompileStats'- returns a textual report of the time and 
%                   additional memory used for each compilation 
%                   phase of MDL.  Running this before running the 
%                   model for the first time will show higher memory 
%                   usage; subsequent compilestats runs return a lower 
%                   amount of differential memory usage for MDL.
%
%                   The compiled statistics (CStat's) are displayed for
%                   each of the significant stage of Simulink block
%                   diagram compilation. This information is typically
%                   provided to MathWorks when helping customers
%                   troubleshoot model compilation speed and/or memory
%                   issues. Items like the computed memory usage let 
%                   us see how much memory a particular stage of model
%                   compilation is taking. It can also return a data 
%                   structure in the second return value.
% 
%   'RTWBuildStats'-returns a textual report of the 'CompileStats', and 
%                   two data structures in the second return value--one 
%                   is 'CompileStats' report, and the other is 'RTWBuild-
%                   Stats' report.
%                  
%   'Sizes'       - returns a textual report of the number of states, 
%                   inputs, outputs, sampletimes, and a flag indicating
%                   direct feedthrough.  Can also return a data 
%                   structure in the second return value.
%
%   'Libs'       - returns a textual report of libraries referenced 
%                  in the model. The report contains the number of 
%                  libraries, their names, the names of the referenced 
%                  blocks from each library and the number of instances 
%                  of each referenced block.  
%
%   'Verbose'     - Unused option. All output from compileStats is now
%                   shown in the command window and in the report by
%                   default. Using this option will result in a warning
%                   being shown.
%
%   See also FIND_SYSTEM, GET_PARAM
%

%   Copyright 1990-2010 The MathWorks, Inc.
%   $Revision: 1.8.2.18.2.2 $  $Date: 2010/07/06 14:42:09 $
    
    OldValue = prepareForSldiagnostics();
    try
        if nargin == 1
            [textout, report] = loc_sldiagnostics(sys);
        else
            [textout, report] = loc_sldiagnostics(sys, varargin{:});
        end % if
    catch myException
        prepareForSldiagnostics(OldValue);
        rethrow(myException);
    end % try/catch
    prepareForSldiagnostics(OldValue);
end % sldiagnostics


function [textout,report] = loc_sldiagnostics(sys, varargin)
% --- determine the action(s) specified
  if nargin == 1
    doCountBlocks   = true;
    doCountSF       = true;
    doCompileStats  = true;
    doRTWBuildStats = false;
    doReportSizes   = true;
    doCountLibs     = true;
  else    
    doCountBlocks   = false;
    doCountSF       = false;
    doCompileStats  = false;
    doRTWBuildStats = false;
    doReportSizes   = false;
    doCountLibs     = false;
    for k=1:length(varargin)
      if ischar(varargin{k})
        switch lower(varargin{k})
         case 'countblocks'
          doCountBlocks  = true;
         case 'countsf'
          doCountSF      = true;
         case 'compilestats'
          doCompileStats = true;
         case 'rtwbuildstats'
          doCompileStats = true;
          doRTWBuildStats= true;
         case 'verbose'
          DAStudio.warning('Simulink:utility:sldDiagnosticsVerboseStatsDeprecated')
         case 'sizes'
          doReportSizes  = true;
         case 'libs'
          doCountLibs    = true;
         case 'all'
          doCountBlocks  = true;
          doCountSF      = true;
          doCompileStats = true;
          doRTWBuildStats= true;
          doReportSizes  = true;
          doCountLibs    = true;
         otherwise
          DAStudio.error('Simulink:utility:sldDiagnosticsUnknownOption')
        end
      else
        DAStudio.error('Simulink:utility:sldDiagnosticsUnknownOption')
      end
    end
  end
  
  % --- find the model to work on, load it if it is not loaded. We could
  % use "wasLoaded" to determine if sldiagnostics has opened this model
  % and close it once we have finished. However, that would not close any
  % libraries that had been opened due to the model being opened, some of
  % which could be in use by other models and contain unsaved changes, etc.
  [mdl, sys, isSubSystem, wasLoaded] = checkopen(sys);  %#ok<NASGU>
  
  % Compatibility checks:
  
  % Is this a library? Certain operations cannot be performed on a
  % library since they require the model to be compiled:
  if strcmp( get_param(mdl, 'libraryType'), 'BlockLibrary' ),
      if doCompileStats,
          DAStudio.warning('Simulink:utility:sldDiagnosticsUnsupportedForLibraries', ...
              'CompileStats')
          doCompileStats = false;
      end
      if doRTWBuildStats,
           DAStudio.warning('Simulink:utility:sldDiagnosticsUnsupportedForLibraries', ...
               'RTWBuildStats')
          doRTWBuildStats = false;
      end
      if doReportSizes,
          DAStudio.warning('Simulink:utility:sldDiagnosticsUnsupportedForLibraries', ...
              'Sizes')
          doReportSizes = false;
      end          
  end
  
  % countblocks, countsf, libs : can be given a subsystem
  % compilestats, rtwbuildstats, sizes : only work at bdroot
  if isSubSystem,
      % We have been given a subsystem to analyze. Check for unsupported
      % options.
      if doCompileStats,
          DAStudio.warning('Simulink:utility:sldDiagnosticsCompilesStatsGivenSys', ...
              'CompileStats')
      end
      if doRTWBuildStats,
          DAStudio.warning('Simulink:utility:sldDiagnosticsCompilesStatsGivenSys', ...
              'RTWBuildStats')
      end
      if doReportSizes,
          DAStudio.warning('Simulink:utility:sldDiagnosticsCompilesStatsGivenSys', ...
              'Sizes')
      end
  end
  
  % --- Initialize outputs  
  textout  = '';
  blockrpt   = [];
  sfrpt      = [];
  sizerpt    = [];
  librpt     = [];
  compilerpt = [];
  rtwrpt     = [];

  if ( ~doCountBlocks && ~doReportSizes && ~doCountLibs && ~doCountSF && ...
          ~doCompileStats && ~doRTWBuildStats) && (nargout > 1)
      DAStudio.error('Simulink:utility:sldDiagnosticsStructureOutputNotValid')
  end

  
  % ==== Process commands
  if doCountBlocks,  %----------------------------------------------------
    
    % --- get the raw list of blocks then get unique lists
    
    s = find_system(sys, 'FollowLinks','on','LookUnderMasks','all');
    total = numel(s) - 1;

    % --- build the empty report structure
    
    rptStruct    = struct('isMask',[],'type',[],'count',[]);
    blockrpt     = repmat( rptStruct, 1, 1 );

    blockrpt(1).isMask = 0;
    blockrpt(1).type   = [ sys, ' Total blocks' ];
    blockrpt(1).count  = 0;
    maxNameWidth       = length( blockrpt(1).type );
    
    % --- collect raw BlockType and MaskType lists
    
    sBlockTypes = get_param(s(2:end),'BlockType');
    blockTypes  = unique(sBlockTypes);
    
    try
        sMaskTypes  = get_param(s(2:end),'MaskType');
        maskTypes   = unique(sMaskTypes);
        if strcmp(maskTypes{1}, ''),
            maskTypes = maskTypes(2:end);
        end
        numMaskTypes = numel(maskTypes);    
    catch E_ignored %#ok<NASGU>
        numMaskTypes = 0;
    end
    
    numRecs      = length(blockTypes) + numMaskTypes;
    blockrpt     = [ blockrpt; repmat(rptStruct, numRecs, 1) ];
    
    % --- get info for each unique block type and mask type found in the model
    
    ssLocIdx     = [];
    sfcnLocIdx   = [];
    sfLocIdx     = [];
    
    for k=1:length(blockTypes)
        blockrpt(k+1).isMask = 0;
        
        blockrpt(k+1).type   = blockTypes{k};
        maxNameWidth         = max( length(blockTypes{k})+1, maxNameWidth );
        
        isOfBlockType        = strcmp( sBlockTypes, blockTypes{k} );
        blockrpt(k+1).count  = sum( isOfBlockType );

        if isempty(ssLocIdx) && strcmp(blockTypes{k},'SubSystem'),
            ssLocIdx = k+1;
        end
        if isempty(sfcnLocIdx) && strcmp(blockTypes{k}, 'S-Function'),
            sfcnLocIdx = k+1;
        end
    end

    b = k+1;
    
    for k=1:numMaskTypes
        blockrpt(b+k).isMask = 1;
        
        blockrpt(b+k).type   = maskTypes{k};
        maxNameWidth         = max( length(maskTypes{k})+1, maxNameWidth);
        
        isOfMaskType         = strcmp( sMaskTypes, maskTypes{k} );
        blockrpt(b+k).count  = sum( isOfMaskType );

        % --- Special case for the 'Stateflow' mask type
        
        if strcmp(maskTypes{k}, 'Stateflow'),
            blockrpt(b+k).isMask       = 0;
            sfLocIdx                   = b+k;
            numSF                      = blockrpt(sfLocIdx).count;
            
            % --- SubSystem and S-Function counts exist and have some SF
            blockrpt(ssLocIdx).count   = blockrpt(ssLocIdx).count - numSF;
            blockrpt(sfcnLocIdx).count = blockrpt(sfcnLocIdx).count - numSF;
            total = total - numSF;
            
            % --- find any Stateflow blocks that are eML or Truth Table blocks
            sfBlkList = find_system(sys, ...
                'FollowLinks','on', ...
                'LookUnderMasks','all', ...
                'MaskType', 'Stateflow');
            numEml = sum( ...
                locSfBlockType( get_param(sfBlkList,'handle'), 'EMChart' ));
            numTT  = sum( ...
                locSfBlockType( get_param(sfBlkList,'handle'), 'TruthTable' ));
            
            blockrpt(sfLocIdx).count = numSF - numEml - numTT;
        end
            
    end

    % --- If present, insert Stateflow, Truth Table and eML blocks into 
    %     the count at the right spot(s)
    
    if exist('sfLocIdx','var') && ~isempty(sfLocIdx),
        blockIdx  = 2:b;
        blockBlks = [blockrpt(blockIdx); blockrpt(sfLocIdx)];
        
        % --- add eML blocks
        
        if exist('numEml','var') && numEml > 0
            emlStruct = blockrpt(sfLocIdx); % clone
            emlStruct.type  = 'EmbeddedMATLABFunction';
            emlStruct.count = numEml;
            blockBlks   = [blockBlks; emlStruct];
        end
        
        % --- add Truth Table blocks
        
        if exist('numTT','var') && numTT > 0
            ttStruct = blockrpt(sfLocIdx); % clone
            ttStruct.type  = 'TruthTable';
            ttStruct.count = numTT;
            blockBlks   = [blockBlks; ttStruct];
        end

        % --- clean up list with a re-sort, put masks at the end
        
        [dummy,idx] = sort( { blockBlks.type } ); %#ok
        maskIdx     = (b+1):(sfLocIdx-1);
        if sfLocIdx < length(blockrpt),
            maskIdx = [ maskIdx, (sfLocIdx+1):length(blockrpt) ];
        end
        blockrpt    = [ blockrpt(1); blockBlks(idx); blockrpt(maskIdx) ];
    end

    % --- Set total count
    %     Stateflow blocks are made of S-fcn + SubSystem, 
    %     don't count them multiple times
    
    blockrpt(1).count = total;
    
    % --- Output conversion for text
    line1 = i_msg('sldDiagnosticsCountSummaryLine1', sys);
    line2 = i_msg('sldDiagnosticsCountSummaryLine2', sprintf('%d',total));
    line3 = i_msg('sldDiagnosticsCountSummaryCountNote');
    line = sprintf('%s\n%s\n\n%s\n', line1, line2, line3);
    
    % --- text version of output
    
    textout = cell(numRecs+1,1);
    textout{1} = sprintf('%s\n', line);
    
    fmtStr = [ '%1s %', sprintf('%d',maxNameWidth+2), 's : %5d\n' ];
    NoteChars = ' M';
    for k = 1:length(blockrpt),
        if blockrpt(k).count > 0,
            maskNote     = NoteChars(1+blockrpt(k).isMask);
            textout{k+1} = sprintf( fmtStr, maskNote, ...
                blockrpt(k).type, blockrpt(k).count);
        end
    end
    
    textout = [textout{:}];
    
  end

  
  if doCountSF,  %--------------------------------------------------------
    
    % --- Report all the Stateflow sizes
    
    find_system(sys, 'FollowLinks','on','LookUnderMasks','all');
    
    % Don't count EmlChart objects as Stateflow, they are Simulink Blocks
    sfObjectTypeList = {'Chart', 'GroupedState', 'State', 'Box', ...
                   'EMFunction', 'EMChart', 'Function', 'LinkChart', ...
                   'TruthTable', 'Note', 'Transition', 'Junction', ...
                   'Event', 'Data', 'Target', 'Machine', 'SLFunction', ...
                   'AtomicSubchart'};
    numItems    = length(sfObjectTypeList);
    kg          = strmatch( 'GroupedState', sfObjectTypeList, 'exact' );

    rt = sfroot;
    m  = rt.find('-isa', 'Stateflow.Machine', '-and', 'Name', mdl);
    sfrpt = struct('class', [], 'count', []);
    sfrpt = repmat(sfrpt, numItems, 1);
    sfobjtxt = repmat('', numItems, 1);
    
    groupedCount = 0;
        
    for k = 1:numItems,
      if ishandle(m),
          % Get list of Stateflow objects of this type:
          Hobjs = findDeep(m, sfObjectTypeList{k});            
          if isSubSystem,
              % Prune the list to remove items that are not within the
              % hierarchy determined by sys:
              Hobjs_ind = true(size(Hobjs));
              for kk=1:numel(Hobjs),
                  Hobjs_ind(kk) = strncmp(Hobjs(kk).Path, sys, numel(sys));
              end
              Hobjs = Hobjs(Hobjs_ind);
          end
          % Get the number of items of this type:
          count = length(Hobjs);
      else
          count = 0;
      end

      if strcmp(sfObjectTypeList{k}, 'State'),
        % --- Count grouped states separately
        for j = 1:count,
          if get(Hobjs(j), 'IsGrouped'),
            groupedCount = groupedCount + 1;
          end
        end
        count = count - groupedCount;

        sfrpt(kg).class = sfObjectTypeList{kg};
        sfrpt(kg).count = groupedCount;

        sfobjtxt{kg} = sprintf('%25s : %4d', sfObjectTypeList{kg}, groupedCount);
      end
      
      sfrpt(k).class = sfObjectTypeList{k};
      sfrpt(k).count = count;

      sfobjtxt{k} = sprintf('%25s : %4d', sfObjectTypeList{k}, count);
      
    end  
    
    % Reconcile Chart and AtomicSubchart counts:
    ind_chart = strmatch('Chart', sfObjectTypeList, 'exact');
    ind_asubchart = strmatch('AtomicSubchart', sfObjectTypeList, 'exact');
    sfrpt(ind_chart).count = sfrpt(ind_chart).count - ...
        sfrpt(ind_asubchart).count;
    
    sftextout = sprintf('\n%s', ...
        i_position_string( i_msg('sldiagnosticsStateflowCount') ));
    sftextout = sprintf('%s\n%s\n', sftextout, sfobjtxt{:});
    sftextout = sprintf('%s%s\n', sftextout, ...
        i_position_string( i_msg('sldiagnosticsEndStateflowCount') ));
    
    textout = [textout, sftextout];
  end
  
  
  if doReportSizes,  %----------------------------------------------------
      
      % --- get the model sizes

      try
          [~, stats] = evalc([get_param(mdl,'Name'),'([],[],[],0)']); 
      catch E
          DAStudio.warning(...
              'Simulink:utility:sldiagnosticsFailedToGetSizes', E.message)
          stats = zeros(7,1);
      end
      
      sizesMsgCell = { ...
          i_msg('sldiagnosticsNumberContinuousStates'), ...
          i_msg('sldiagnosticsNumberDiscreteStates'), ...
          i_msg('sldiagnosticsNumberOutputs'), ...
          i_msg('sldiagnosticsNumberInputs'), ...
          i_msg('sldiagnosticsFlagFeedThrough'), ...
          i_msg('sldiagnosticsNumberSampleTimes') ...
          };
      % Pad the strings to ensure they align with right justification:
      sizesMsgCell = i_right_justify(sizesMsgCell);

      textout=sprintf('%s\n\n%s',textout, ...
          i_position_string( i_msg('sldiagnosticsModelSizes') ));

      NumContStates  = stats(1);
      NumDiscStates  = stats(2);
      NumOutputs     = stats(3);
      NumInputs      = stats(4);
      DirFeedthrough = stats(6);
      NumSampleTimes = stats(7);

      textout=sprintf('%s\n%s\t\t%d',textout,sizesMsgCell{1},NumContStates);
      textout=sprintf('%s\n%s\t\t%d',textout,sizesMsgCell{2},NumDiscStates);
      textout=sprintf('%s\n%s\t\t%d',textout,sizesMsgCell{3},NumOutputs);
      textout=sprintf('%s\n%s\t\t%d',textout,sizesMsgCell{4},NumInputs);
      textout=sprintf('%s\n%s\t\t%d',textout,sizesMsgCell{5},DirFeedthrough);
      textout=sprintf('%s\n%s\t\t%d',textout,sizesMsgCell{6},NumSampleTimes);
      
      textout=sprintf('%s\n%s\n',textout, ...
          i_position_string( i_msg('sldiagnosticsModelSizesEnd') ));
      
      sizerpt=struct('NumContStates',  NumContStates,  ...
                     'NumDiscStates',  NumDiscStates,  ...
                     'NumOutputs',     NumOutputs,     ...
                     'NumInputs',      NumInputs,      ...
                     'DirFeedthrough', DirFeedthrough, ...
                     'NumSampleTimes', NumSampleTimes);
  end

  
  if doCountLibs   %------------------------------------------------------
                         
    textout=sprintf('%s\n%s',textout, ...
          i_position_string( i_msg('sldiagnosticsLibraryUsageStatistics') ));                
                    
    library_blocks = libinfo(sys);
    
    if isempty(library_blocks)
        textout = sprintf('%s\n%s%s', textout, ...
            i_msg('sldiagnosticsNoLibraryUsed', sys));
    else
        libListLen = length(library_blocks);
        [libList{1:libListLen}] = deal(library_blocks.Library);
        [refList{1:libListLen}] = deal(library_blocks.ReferenceBlock);
    
        [uLibList, noDups] = findUniqueObjs(libList);
        textout = sprintf('%s\n%s\n', textout, i_msg('sldiagnosticsListUniqueLibs'));
        for i=1:length(uLibList)
            textout = sprintf('%s   %s\n',textout, uLibList{i});
        end
    
        textout = sprintf('%s\n\n%s', textout, ...
            i_msg('sldiagnosticsLibBlocksAndCounts'));
        % Preallocate:
        librpt = repmat(struct('libName', [], 'numLinksToLib', []), ...
            1, length(uLibList));
        for i=1:length(uLibList)
            textout = sprintf('%s\n\n  %s %s', textout, ...
                i_msg('sldiagnosticsLibrary'), uLibList{i});
            textout = sprintf('%s [%s %d]', textout, ...
                i_msg('sldiagnosticsNumLinksToLib'), noDups(i));
            librpt(i).libName       = uLibList(i); 
            librpt(i).numLinksToLib = noDups(i);  
            
            % finding all instances of referenced blocks that are from a particular library           
            refBlkList = refList(ismember(libList, uLibList(i)));

            % finding unique instances of referenced library blocks
            [uRefBlkList noRefDups] = findUniqueObjs(refBlkList);

            for j=1:length(uRefBlkList)
                tmp4    = regexprep(uRefBlkList{j}, '\n', ' '); % replace new lines with space for block name
                if noRefDups(j) == 1
                    instStr =  i_msg('sldiagnosticsInstance', noRefDups(j));
                else
                    instStr =  i_msg('sldiagnosticsInstances', noRefDups(j));
                end
                                
                textout = sprintf('%s\n    %s %s\n           [%s]', ...
                    textout, i_msg('sldiagnosticsBlock'), tmp4, instStr); 
                librpt(i).refBlocks(j).blockName    = tmp4;
                librpt(i).refBlocks(j).numInstances = noRefDups(j);
            end
        end
    end
    textout=sprintf('%s\n\n%s\n',textout, ...
        i_position_string( i_msg('sldiagnosticsLibraryUsageStatisticsEnd') ));                    
  end
 
  
  if doCompileStats,  %---------------------------------------------------
    
    % --- Compile block diagram with compilestats turned on    
    
    % Try "compile" first, as this gives the most information:
    try % compile
        scsOriginal = get_param(mdl,'DisplayCompileStats');
        set_param( mdl, 'DisplayCompileStats', 'on' );
        stats = [ ...
            evalc( 'feval(mdl,[],[],[],''compile'');' ), ...
            evalc( 'feval(mdl,[],[],[],''term'');' ) ];
    catch actualLastError
        % That failed. Try "compileForSizes", which does not call mdlStart:
        try % compileForSizes
            stats = [ ...
                evalc( 'feval(mdl,[],[],[],''compileForSizes'');' ), ...
                evalc( 'feval(mdl,[],[],[],''term'');' ) ];
            % That worked ok. Let the user know what happened since the
            % will get slightly different information to what they might
            % expect:
            DAStudio.warning(...
                'Simulink:utility:sldDiagnosticsRanReducedCompileStats', ...
                actualLastError.message)
        catch E_ignore
            % That failed as well. Tidy up before rethrowing the original,
            % and hence likely to be most useful, error:
            if ~strcmp(get_param(mdl,'SimulationStatus'),'stopped')
                try
                    evalc( 'feval(mdl,[],[],[],''term'');');
                catch E_ignored %#ok<NASGU>
                    %
                end
            end
            try
                set_param( mdl, 'DisplayCompileStats', scsOriginal );
            catch E_ignored %#ok<NASGU>
                %
            end
            newExc = MException('Simulink:utility:ErrorFoundDuringCompileStats', ...
                i_msg('sldDiagnosticsCompileStatsFailed'));
            newExc = newExc.addCause(actualLastError);
            throw(newExc);
        end % compileForSizes
    end % compile
    
    
    % Get the statistics:
    compilerpt = get_param(mdl, 'CompileStatistics');
    % Clean-up:
    set_param( mdl, 'DisplayCompileStats', scsOriginal );
            
    % --- 'stats' is a text stream: convert to lines of text
    if isempty(textout)
        textout = stats;
    else
        textout = sprintf('%s\n%s\n%s', textout,...
            i_position_string( i_msg('sldiagnosticsCompilationStats') ),...
            stats);
    end        
  end
      
 if doRTWBuildStats   %------------------------------------------------------
    try
        if license('test','real-time_workshop')
            scsOriginal = get_param(mdl,'DisplayCompileStats');
            set_param( mdl, 'DisplayCompileStats', 'on' );
            slbuild(mdl);
            rtwrpt = slprivate('slbuild_profile', mdl, 'get', true, 'NONE'); 
            set_param( mdl, 'DisplayCompileStats', scsOriginal );
        else
            rtwrpt = '';
        end
    catch actualLastError
        newExc = MException('Simulink:utility:ErrorFoundDuringRTWBuildStats', ...
            i_msg('sldDiagnosticsRTWBuildStatsFailed'));
        newExc = newExc.addCause(actualLastError);
        throw(newExc);
    end
  end
   

  % --- figure out which item(s) to output -------------------------------
 
  if (~isempty(blockrpt) + ~isempty(sfrpt) + ...
      ~isempty(sizerpt) + ~isempty(librpt) + ...
      ~isempty(compilerpt) + ~isempty(rtwrpt)) >= 2
    
     % --- have 2 or more report items
     report = struct(...
         'blocks', [], ...
         'sizes', [], ...
         'links', [], ...
         'stateflow', [], ...
         'compilestats', [], ...
         'rtwbuild', [] ...
         );
     if ~isempty(blockrpt)
       report.blocks = blockrpt;
     end
     if ~isempty(sizerpt)
       report.sizes = sizerpt;
     end
     if ~isempty(librpt)
       report.links = librpt;
     end
     if ~isempty(sfrpt)
       report.stateflow = sfrpt;
     end
     if ~isempty(compilerpt)
       report.compilestats = compilerpt;
     end
     if ~isempty(rtwrpt)
       report.rtwbuild = rtwrpt;
     end
  else
    
     % --- only have 1 report item, don't make a structure     
     if ~isempty(librpt)
       report = librpt;
     elseif ~isempty(sfrpt)
       textout = sftextout;
       report = sfrpt;
     elseif ~isempty(sizerpt)
       report = sizerpt;
     elseif ~isempty(compilerpt)
       report = compilerpt;
     elseif ~isempty(rtwrpt)
       report = rtwrpt;
     else
       report = blockrpt;
     end
 end

 end % loc_sldiagnostics


%=========================================================================
function [mdl, sys, isSubSystem, isloaded] = checkopen(sys)
% Determine if we've been given a model name or a subsystem path. Load the
% model. Convert the given subsystem name to the one used by Simulink.

  if isempty(sys),
      DAStudio.error('Simulink:utility:sldDiagnosticsNoModelSpecified')
  end
  
  % Get the model root, even if sys is a path to a subsystem.
  % Check for a trailing '/' in sys that will cause problems (in various
  % places) later:
  if strcmp(sys(end), '/'),
      sys = sys(1:end-1);
  end
  [mdl, rest] = strtok(sys, '/');
  % Is it a subsystem?     
  isSubSystem = ~isempty(rest); 
  
  if bdIsLoaded(mdl),
      isloaded = true;
  else
      % Let load_system handle any errors about the file not being found:
      load_system(mdl);
      isloaded = false;
  end
  
  % Get Simulink's version of the path represented by sys to guard against
  % problems with spaces replacing newlines, etc.
  if isSubSystem,
      sys = getfullname(sys);
  end

end % checkopen


%=========================================================================
function result = locSfBlockType(handleList, blockType)
%LOCSFBLOCKTYPE True if the block handle is for the specified type
%
% Types: 

switch blockType
    case 'EMChart'
        chartType = 2;
    case 'TruthTable'
        chartType = 1;
    otherwise
        chartType = 0;
end

if iscell(handleList)
    blockHandle = [handleList{:}];
else
    blockHandle = handleList;
end

try
  result = zeros(size(blockHandle));
  for k = 1:length(blockHandle)
      chartId = sf('Private','block2chart', blockHandle(k));
      result(k) = double(~isempty( ...
          sf( ...
          'find', chartId, ...
          'chart.type', chartType)));
  end
catch E_ignored 
    DAStudio.error('Simulink:utility:sldiagnosticsSpecialFindFailed')
end

end % locSfBlockType

%=========================================================================
function [uList, nDups] = findUniqueObjs(iList)
% Return an array of objs (uList) that are unique in iList. 'nDups' 
% returns the number of duplicates of unique elements in iList
    
    tmpList       = sort(iList);
    [uList, I] = unique(tmpList);
    
    nDups = diff([0 I]);
end % findUniqueObjs


function str = i_position_string(str_in)
% Utility to add dashes to front and end of messages:
targetLen = 48;
dashLen = floor((targetLen - length(str_in))/2);
dashes = repmat('-', 1, dashLen);
str = [dashes, ' ', str_in, ' ', dashes];
if length(str)/2 ~=floor( length(str)/2 )
    % Even things up with an additional '-'
    str = ['-', str];
end    
end

function strOut = i_right_justify(strIn)
% Pad a cell-array of strings with leading spaces and append a semicolon:
strOut = strIn;
L = max(cellfun(@length, strOut));
for jj=1:numel(strOut)
    strOut{jj} = [repmat(' ', 1, L - length(strOut{jj})), strOut{jj}, ':'];
end
end

function str = i_msg(key, varargin)
% Thin wrapper on DAStudio.message to remove clutter from string generation
% code:
key = ['Simulink:utility:' key];
str = DAStudio.message(key, varargin{:});
end


%[EOF] sldiagnostics.m
