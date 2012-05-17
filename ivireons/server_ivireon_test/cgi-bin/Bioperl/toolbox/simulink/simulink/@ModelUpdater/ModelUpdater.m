%  class ModelUpdater 
%
%   helper object used by slupdate.
%
%   See also SLUPDATE, MODELADVISOR

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $ $Date: 2010/04/05 22:47:39 $

%   collects and calls functions registered by MathWorks products to update
%   a model to the latest release.  The object keeps track of all changes
%   suggested to the model an allows them to happen either immediately or
%   if requested at some future time before the object is destroyed.

classdef (Sealed=true) ModelUpdater < handle
    
    properties(SetAccess = 'private', GetAccess = 'protected')
        IsLibrary;
        CloseSimulink;
        
        Transactions;  % structure with blocknames, reasons, and function info
        UpdateMsgs;
        CompileCheck; % structure with block, data, and function handles
        
        Prompt;
        OnlyAnalysis;

        % function handles for checks
        ProductFH;             % default old checks run under BlockReplaceChecks
        LinkMappingFH;         % default old link mapping data  
        RegisteredProductFH;   % new check registration style functions (Simulink only for R2010A)
        
        TempName;
        UpdateContext;
        
        % to be static
        MapOldMaskToCurrent;
        OldMaskTypeCell;
        OldMasksCanNotHandle;
        
        NonMainRefBlock;
        NonMainMaskType;      
    end

    properties(SetAccess = 'private', GetAccess = 'public')
        CheckFlags;
        CompileState;  
        MyModel;
        
        ReplaceBlockReasonStr;
        RestoreLinkReasonStr;
        ConvertToLinkReasonStr;
        MiscUpdateReasonStr;
    end
        
    properties(Constant)
        PRECOMPILE     = 1;
        COMPILED       = 2;
        POSTCOMPILE    = 3;
        NOT_COMPILABLE = 4;        
    end
    
    methods % public
        % constructor/destructor must be in this file
        % myVarargin is already in cell array format from the 
        % function(s) that should call this one.
        function obj = ModelUpdater(varargin)
         
            if( nargin < 1 ) || ~ischar(varargin{1})
                DAStudio.error('Simulink:utility:slupdateNeedModelName');
            else if exist(varargin{1},'file') ~= 4 
                    DAStudio.error('Simulink:utility:slupdateCannotFindModel',varargin{1});
                else
                    obj.MyModel = varargin{1};
                end
            end

            setDefaults(obj);

            forceSysOpen(obj);
                        
            checkInputs(obj, nargin, {varargin{2:end}});
            
            obj.Transactions = cell2struct(cell(4,0), {'name','reason','done','functionSet'},1);            
            obj.UpdateMsgs   = cell2struct(cell(2,0), {'name','msg'},1);
            obj.CompileCheck = cell2struct(cell(5,0), {'block','dataCollectFH','postCompileCheckFH','fallbackFH','data'});
            generateTempName(obj);
             
            getRegisteredFunctions(obj);
            
            obj.ReplaceBlockReasonStr  = DAStudio.message('Simulink:utility:slupdateConvertToNewBlock');
            obj.RestoreLinkReasonStr   = DAStudio.message('Simulink:utility:slupdateRestoreLink');
            obj.ConvertToLinkReasonStr = DAStudio.message('Simulink:utility:slupdateConvertToLink');
            obj.MiscUpdateReasonStr    = DAStudio.message('Simulink:utility:slupdateMiscUpdate');
        end

        function cleanup(h)
            close_system(h.TempName,0);
            if h.CloseSimulink
                close_system('simulink',0);
            end
        end
        
        function setDefaults(h)
            h.UpdateContext = h.MyModel;
            h.CompileState = ModelUpdater.PRECOMPILE;
            h.OnlyAnalysis = false;

            % empty function handle lists
            h.ProductFH           = {};
            h.LinkMappingFH       = {};
            h.RegisteredProductFH = {};

            %default check flags = operatinmode update
            h.CheckFlags.BlockReplace = true;
            h.CheckFlags.Compiled = true;
            h.CheckFlags.LinkRestore = true;
        end
               
        function Prompt = getPrompt(h)
            Prompt = h.Prompt;
        end

        function h = setPrompt(h, prompt)
            h.Prompt = prompt;
        end

        function Update = doUpdate(h)
            if h.OnlyAnalysis
                Update = false;
            else
                Update = true;
            end
        end
        
        function context = getContext(h)
            context = h.UpdateContext;
        end
    end % methods public
    
%    methods % public external for use by slupdate
%         function updateModelForProducts(h)
%         function restoreBrokenLinks(h)
%         function generateReport(h)
%    end % methods public external
%
%     methods %public external for use by blocksets
%         %% designed to be used as part of a transaction
%         function             appendTransaction(h, name, reason, {funcSets})
%         function replace   = askToReplace(h,block)
%         function cleanName = cleanBlockName(h, blockName)
%         function funcSet   = uBlock2Link(h, block, libBlock)
%         function funcSet   = uReplaceBlock(h, oldBlock, newBlock, varargin)
%         function funcSet   = uReplaceBlockWithLink(h, block)
%         function funcSet   = uSafeSetParam(h, block, varargin)
%         function             appendCompileCheck(h, block, dataCollectFH, postcompileCheckFH, fallbackFH)
%
%         %% designed to be used as a transaction
%         function replaceBlockWithLink(h, block)
%
%         %% utility that products can use with the older format
%         %% replaceInfo to act on a set of blocks.
%         function replaceBlocks(h)
%
%     end % methods static external
%
%     methods(Access = 'private') % private external
%         function                   block2Link(h, oldBlock, newLink)
%         function                   checkInputs(h, myNargin, myVarargin)
%         function                   getRegisteredFunctions(h)
%         function replacementInfo = determineBrokenLinkReplacement(h, block)
%         function                   dispSkipping(h, name)
%         function                   dispUpdating(h,block,reason)
%         function                   fillLinkMappingData(h)
%         function libs            = findLibsInModel(h)
%         function                   forceSysOpen(h)
%         function updateInfo      = genAnalysisReport(h)
%         function                   generateTempName(h)
%         function                   getMappingOldMaskToCurrent(h)
%         function replacementInfo = getRefinedLinkMatch(h, block, mapping)
%         function                   doCompileChecks(h)
%     end


end
