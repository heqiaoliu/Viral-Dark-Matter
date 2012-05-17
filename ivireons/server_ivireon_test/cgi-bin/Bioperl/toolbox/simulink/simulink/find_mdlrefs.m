function  varargout = find_mdlrefs(modelName, varargin)
% FIND_MDLREFS finds referenced models and Model blocks
%
% find_mdlrefs finds all (or first level) Model blocks and referenced models in
% a specified model, optionally omitting or including any Protected Models.
%
% [refMdls, mdlBlks] = find_mdlrefs(modelName) finds all Model blocks and
% referenced models at any level of the specified model.
%
% [refMdls, mdlBlks] = find_mdlrefs(modelName, allLevels) is equivalent to the
% preceding syntax if allLevels is true.  If allLevels is false, the function
% searches only the top level of the specified model.
%
% [refMdls, mdlBlks] = find_mdlrefs(modelName, 'Param1', Val1, ...) searches the
% model as specified by the optional name/value pairs given by 'Param1', Val1,
% ...
%
%  Required Inputs:
%     modelName -- The name of the model to be searched.
%
%  Optional Inputs:
%     allLevels -- Whether to search all levels (true) or first level only
%     (false). Default: true.
%
%  The legal names and values for 'Param1', Val1, ... are:
%    'AllLevels' -- A logical value that specifies whether all levels should be
%    searched or just the first level.  Use true for all levels and false for
%    just the first level.  The default is true: the function searches all
%    levels.
%
%    'IncludeProtectedModels' -- A logical value that specifies whether or not
%    Protected Models should be included in the list of referenced models
%    output.  The names of any Protected Models listed end in '.mdlp'.  The
%    default is false: the function omits Protected Models from the list.
%
%    'Variants' -- This parameter controls how to treat Model blocks that have 
%    variants enabled.  This parameter has three possible values:
%      'ActiveVariants' - Evaluate the active variant in the workspace and
%      return only the active variant..
%      'ActivePlusCodeVariants' - Return all variant choices for Model blocks 
%      that use code variants.
%      'AllVariants' - Return all variant choices for any variant Model blocks.
%      The default is 'ActivePlusCodeVariants'.
%
%  Outputs:
%     refMdls -- An ordered list of referenced models found by the function.
%       The last element in the list is the name of the model passed in as the
%       first input.
%
%     mdlBlks -- A list of the Model blocks found by the function.
%
% Note that the function provides two different ways to search all levels of the
% specified model.  Both techniques give the same results, but only the
% name/value technique is compatible with specifying the optional input
% 'IncludeProtectedModels'.
    
%   Copyright 1994-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.17 $
    
    searchAll        = true;
    includeProtected = false;
    % Here are the possible settings for this parameter,
    %  ActivePlusCodeVariants, ActiveVariants, AllVariants
    includeVariants = 'ActivePlusCodeVariants'; % default

    % Check and parse inputs
    switch(nargin)
        case 0
            DAStudio.error('Simulink:modelReference:findMdlrefsUsage');
            
        case 1
            % Do nothing
            
        case 2
            % The value should be a logical
            if(check_logical_val_l(varargin{1}))
                searchAll = varargin{1};
            else
                DAStudio.error('Simulink:modelReference:findMdlrefsSecondArgTrueFalse');
            end % if
            
        otherwise
            % Look for name/value pairs
               
            % We should see an even number of varargins
            if(~ isequal(mod(length(varargin), 2), 0))
                DAStudio.error('Simulink:modelReference:findMdlrefsUsage');
            end % if
            
            for i = 1:2:length(varargin)
                name  = varargin{i};
                value = varargin{i + 1};
                
                if(~ ischar(name))
                    DAStudio.error('Simulink:modelReference:nameValuePairNeedsStringForName',...
                                   nargin - length(varargin) + i);
                end % if
                
                switch(name)
                    case 'AllLevels'
                        if(check_logical_val_l(value))
                            searchAll = value;
                        else
                            DAStudio.error('Simulink:modelReference:nameValuePairNeedsLogicalValue', name);
                        end % if
                        
                    case 'IncludeProtectedModels'
                        if(check_logical_val_l(value))
                            includeProtected = value;
                        else
                            DAStudio.error('Simulink:modelReference:nameValuePairNeedsLogicalValue', name);
                        end % if
                        
                    case 'Variants'
                        if ~ischar(value)
                            DAStudio.error('Simulink:modelReference:nameValuePairNeedsStringValue', name);
                        end
                      
                        switch value
                          case {'ActivePlusCodeVariants', 'ActiveVariants', 'AllVariants'}
                            includeVariants = value;
                            
                          otherwise
                            DAStudio.error('Simulink:modelReference:nameValuePairUnknownParameter', value);
                        end
                    
                    otherwise
                        DAStudio.error('Simulink:modelReference:nameValuePairUnknownParameter', name);
                end % switch
            end % for
    end % switch

    
    mdlsToClose = {};
    if ~ischar(modelName),
        % must be a handle to an open model
        if ~ishandle(modelName),
            DAStudio.error('Simulink:modelReference:findMdlrefsFirstArgModel');
        end
        
        modelName = get_param(modelName,'Name');
    else
        % load the model if it is not loaded
        mdlsToClose = load_model(modelName);
    end
    
    % Check outputs
    if nargout > 2
        DAStudio.error('Simulink:modelReference:findMdlrefsInvalidNumberOfOutputs');
    end
    
    [refMdls, mdlBlks] = ...
        get_all_models_and_model_blocks_l(modelName, {}, {}, searchAll, includeProtected, includeVariants, {});
    
    % Fill output
    varargout{1} = refMdls;
    varargout{2} = mdlBlks;
    
    slprivate('close_models', mdlsToClose);
end % find_mdlrefs
    
%% ------------------------------------------------------------------------
function [ioRefMdls, ioMdlBlks] = ...
      get_all_models_and_model_blocks_l(...
          iMdl, ...
          ioRefMdls, ...
          ioMdlBlks, ...
          searchAll, ...
          includeProtected, ...
          includeVariants, ...
          iPathToMdl)
  
  mdlsToClose = slprivate('load_model', iMdl);
  
  opts = {'FollowLinks', 'on', 'LookUnderMasks', 'all', ...
         'LookUnderReadProtectedSubsystems','on', ...
         'Variants', includeVariants};
  aBlks     = find_system(iMdl, opts{:}, 'BlockType', 'ModelReference');
  
  % Determine variants for the model ref blocks - this may error out
  slInternal('determineActiveVariant', aBlks);
   
  % get a list of all models referenced by the model blocks, including
  % variant models if the block has code variants
  switch includeVariants
    case 'ActivePlusCodeVariants'
      nonUniqueProtectedByBlock  = get_param(aBlks, 'CodeVariantProtectedModels');
      nonUniqueModelFilesByBlock = get_param(aBlks, 'CodeVariantModelFiles');
      nonUniqueModelFiles = [nonUniqueModelFilesByBlock{:}]';
      nonUniqueProtected  = [nonUniqueProtectedByBlock{:}]';
      
    case 'ActiveVariants'
      nonUniqueProtected  = get_param(aBlks, 'ProtectedModel');
      nonUniqueModelFiles = get_param(aBlks, 'ModelFile');

    case 'AllVariants'
      nonUniqueProtectedByBlock  = get_param(aBlks, 'ProtectedModels');
      nonUniqueModelFilesByBlock = get_param(aBlks, 'ModelFiles');
      nonUniqueModelFiles        = [nonUniqueModelFilesByBlock{:}]';
      nonUniqueProtected         = [nonUniqueProtectedByBlock{:}]';

  end
  
  
  if(isempty(nonUniqueProtected))
      protected = [];
  else
      protected = strcmp('on', nonUniqueProtected);
  end % if

  if((includeProtected) && ~isempty(protected))
      protectedModelFiles = unique(nonUniqueModelFiles(protected));
  else
      protectedModelFiles = {};
  end % if
  
  nonUniqueModelRefs = nonUniqueModelFiles(~protected);
  refMdls            = unique(nonUniqueModelRefs);
  
  % Remove the .mdl extension
  if ~isempty(refMdls)
    refMdls = regexprep(refMdls, '\.mdl$', '');
  end
  
  slprivate('close_models', mdlsToClose);

  ioMdlBlks = [ioMdlBlks; aBlks];

  pathToMdlRefsInMdl = [iPathToMdl, {iMdl}];
  
  if searchAll
    nRefMdls = length(refMdls);
    for i = 1:nRefMdls,
      refMdl = refMdls{i};
      
      if ~isempty(strmatch(refMdl, pathToMdlRefsInMdl, 'exact')),
        strPathToMdl = strcat_with_separator(pathToMdlRefsInMdl, ':');
        mdlRefLoop = [strPathToMdl, ':', refMdl];
        DAStudio.warning('Simulink:modelReference:detectedModelReferenceLoop', mdlRefLoop);
        continue;
      end
      
      matchIndex = strmatch(refMdl, ioRefMdls, 'exact');
      if isempty(matchIndex)
        [ioRefMdls, ioMdlBlks] = ...
            get_all_models_and_model_blocks_l(...
                refMdl, ioRefMdls, ioMdlBlks, searchAll, includeProtected, ...
                includeVariants, pathToMdlRefsInMdl);
      end
    end
  else
    ioRefMdls = [ioRefMdls; refMdls];
  end
  
  % Only add protected models that are not already on the list
  protectedModelFiles = setdiff(protectedModelFiles, ioRefMdls);
  
  ioRefMdls = [ioRefMdls; protectedModelFiles; {iMdl}];
end % get_all_models_and_model_blocks_l

%% ------------------------------------------------------------------------
function logicalOK = check_logical_val_l(val)
    logicalOK = ...
        ((islogical(val)) || ...
         ((isscalar(val))  && ...
          (isnumeric(val)) && ...
          (isreal(val))    && ...
          (val == 0 || val == 1)));
end % check_logical_val_l
