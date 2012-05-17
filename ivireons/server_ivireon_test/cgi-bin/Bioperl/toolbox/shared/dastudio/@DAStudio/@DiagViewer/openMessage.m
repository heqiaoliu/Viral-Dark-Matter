function openMessage(h, msg)
%  openMessage
%
%  If the message specifies an open function, this method executes the
%  function. Otherwise it opens the model, subsystem, or chart that 
%  contains the message source and highlights the source.
%
%  Copyright 2008-2010 The MathWorks, Inc.

  if ~isa(msg, 'DAStudio.DiagMsg')
      ME = MException('DiagnosticViewer:OpenMessage', ...
      'Specified object is not a message.');
     throw(ME);
  end
  
  blkHandle = [];

  % If there is an open function simply call
  % evaluation for that function
  if ~isempty(msg.openFcn) 
    try 
      eval(msg.openFcn);
    catch ME
      disp(['Error occurred in custom message open function:\n' ...
           ME.identifier ME.message]);
    end
  else
    if ~isempty(msg.AssocObjectHandles)
      
      for i = 1:length(msg.AssocObjectHandles)
        blkHandle = msg.AssocObjectHandles(i);
        try
          % If this is not a valid handle (e.g., it has been closed),
          %     reopen the parent system (by name) and update the handle
          %     accordingly before moving forward
          if ~ishandle(blkHandle)
              
              blkName = msg.AssocObjectNames{i};
              % Remove slashses and any successive chars in blkName to get
              %     parentName
              parentDiagramName = regexprep(blkName, '/.*','');
              load_system(parentDiagramName);
              blkHandle = get_param(blkName, 'handle');
              msg.AssocObjectHandles(i) = blkHandle;
              
          end
              
          if strcmp(get_param(blkHandle,'Type'), 'block') && ...
                ~strcmp(get_param(blkHandle,'iotype'), 'none')
            bd = bdroot(blkHandle);
            sigandscopemgr('Create', bd);
          elseif strcmp(get_param(blkHandle, 'Type'), 'block_diagram')
              open_system(blkHandle);
          else
            hilite_system(blkHandle, 'error');	 
          end
        catch %#ok<CTCH>
        end
      end
      
    else
  
      if ~isempty(msg.sourceObject),
        switch ml_type(msg.sourceObject, 1),
          case 'sl_handle', open_system(msg.sourceObject, 'force');
          case 'sf_handle', sf('Open', msg.sourceObject);
          otherwise
        end
      else
        if ~isempty(msg.SourceFullName),
          try open_system(msg.sourceFullName); 
          catch %#ok<CTCH>
          end 
        end
      end 
      
    end
  
    %
    % Open the selected Object
    %
    switch msg.component,
      case 'Simulink'
        if ~isempty(blkHandle)
          try open_block_and_parent_l(blkHandle); 
          catch %#ok<CTCH>
          end
        end
      case 'Stateflow'
        if ~isempty(blkHandle) 
          open_system(blkHandle); 
        end
        if ~isempty(msg.sourceObject),
          sf('Open', msg.sourceObject);
        end
    end
    
  h.isMessageOpen = true;
  
  end

end
%
function [theType, conflict] = ml_type(obj, sfIsHere)
%ML_TYPE  Extracts the type of the given input wrt standard MATLAB types,
%         HG, Simulink, and Stateflow handles.  Handle conflicts between
%         Stateflow and Simulink or Stateflow and HG are detected if
%         requested.

  theType = 'unknown';
  conflict = false;
  
  if iscell(obj), theType = 'cell'; return; end
  
  if isobject(obj)
    theType = 'object';
    switch(class(obj))
     case 'activex', theType = 'activex';
    end;
    return;
  end

  if ischar(obj) 
    theType = 'string';
    return;
  end
  if islogical(obj)
    theType = 'bool';  
    return; 
  end
  if isstruct(obj)
    theType = 'struct'; 
    return; 
  end

  %
  % Resolve handle (Stateflow handles take precedence if it is present).
  %
  if isnumeric(obj)
    
    if ~isempty(obj)
      
      if (sfIsHere && obj==fix(obj) && sf('ishandle', obj))
        theType = 'sf_handle';  
      end
      
      if ishandle(obj)
        
        if isempty(find_system('handle', obj)),
          if strcmp(theType, 'sf_handle')
            conflict = true;
          else
            theType = 'hg_handle';
          end
          return
        else
          if strcmp(theType, 'sf_handle')
            conflict = true;
          else
            theType = 'sl_handle';
          end
          return
        end
        
      end
      
    end

    theType = 'numeric';
    
  end
  
end





