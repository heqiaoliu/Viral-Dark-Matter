function varargout = sldemo_mdlref_util(modelName, action, varargin)
% sldemo_mdlref_util controls the Model Reference demo callbacks

% Copyright 1990-2010 The MathWorks, Inc.
% $Revision: 1.1.6.7 $

if strcmp(modelName, 'sldemo_mdlref_conversion')
    handle_sldemo_mdlref_conversion(modelName, action);
    
elseif strcmp(modelName, 'sldemo_mdlref_fcncall')
    output = handle_sldemo_mdlref_fcncall(modelName, action, varargin{:});
    if ~isempty(output)
        varargout{1} = output;
    end 
elseif strcmp(modelName, 'sldemo_mdlref_dsm')
    output = handle_sldemo_mdlref_dsm(modelName, action, varargin{:});
    if ~isempty(output)
        varargout{1} = output;
    end 
elseif strcmp(modelName, 'sldemo_mdlref_protect')
    output = handle_sldemo_mdlref_protect(modelName, action, varargin{:});
    if ~isempty(output)
        varargout{1} = output;
    end 
elseif strcmp(modelName, 'sldemo_mdlref_depgraph')
    output = handle_sldemo_mdlref_depgraph(modelName, action, varargin{:});
    if ~isempty(output)
        varargout{1} = output;
    end
end



function output = handle_sldemo_mdlref_depgraph(~, action, varargin)
output = [];
switch(action)
  case('cleanup')
    clear mex;
      
    startdir = varargin{1};
    tempdir  = varargin{2};
    
    cd(startdir);
    rmpath(startdir);
    rmdir(tempdir, 's');
end % switch
%endfunction


function output = handle_sldemo_mdlref_protect(~, action, varargin)
output = [];
switch(action)
  case('cleanup')
    startdir = varargin{1};
    tempdir  = varargin{2};
    
    cd(startdir);
    rmpath(startdir);
    rmdir(tempdir, 's');
end % switch
%endfunction

function output = handle_sldemo_mdlref_dsm(modelName, action, varargin)
output = [];
switch(action)
    % setup for demo
  case {'setup'} 

    output = pwd;
    newdir = tempname;
    mkdir(newdir);
    cd(newdir);
    
  case{'sim'} 
    
    if (isempty(find_system('Name',modelName)))
        open_system(modelName); 
    end
    evalc('sim(modelName)');
    assignin('base','dsmout',dsmout);
    
    plot(tout, yout);
    title('Simulation of model hierarchy sharing data store ErrorCond');
    ylabel('Input to model block A, and output of Switch');
    xlabel('Time (sec)');        
    
  case{'close'} 
    
    evalin('base','bdclose sldemo_mdlref_dsm');
    evalin('base','bdclose sldemo_mdlref_dsm_bot;');
    evalin('base','bdclose sldemo_mdlref_dsm_bot2;');
    evalin('base','clear tout yout ErrorCond dsmout');
    clear sldemo_mdlref_dsm_bot_msf;
    clear sldemo_mdlref_dsm_bot2_msf;
    newdir = pwd;
    origdir = varargin{1};
    cd(origdir);
    rmdir(newdir,'s'); 
  otherwise
end
%endfunction

function output = handle_sldemo_mdlref_fcncall(modelName, action, varargin)
output = [];
switch(action)
  case {'setup'} 
    output = pwd;
    newdir = tempname;
    mkdir(newdir);
    cd(newdir);
    
  case{'sim'} 
    if (isempty(find_system('Name', modelName)))
        open_system(modelName); 
    end
    cmd = ['sim(''', modelName, ''')']; 
    evalc(cmd);
    
  case{'close'} 
    newdir = pwd;
    origdir = varargin{1};
    close_system(modelName, 0);
    close_system([modelName,'_cntr'], 0);
    clear sldemo_mdlref_fcncall_cntr_msf;
    clear sldemo_mdlref_fcncall_sfun;
    if ~isempty(origdir)
        cd(origdir);
        rmdir(newdir,'s'); 
    end
end
%endfunction

function handle_sldemo_mdlref_conversion(modelName, action)
mdlRef = 'sldemo_bus_counter';
if strcmp(action, 'convert')
    
    % Convert the model
    open_system(modelName);
    
    ssBlk = find_system(modelName, ...
                        'SearchDepth',1,...
                        'BlockType','SubSystem', ...
                        'Name', 'Bus Counter');
    
    if isempty(ssBlk) 
        error('Simulink:sldemo_mdlref_util:NoSubsystem', ...
              ['Cannot find atomic subsystem ''Bus Counter''', ...
               'in sldemo_mdlref_conversion demo']);
    else
        clean_mdlref_conversion_l(mdlRef);
        
        %% make sure the model name is unique. Otherwise, the conversion
        %% tool will report an error
        
        thisModel = 'sldemo_bus_counter';
        idx = 0;
        newModel = thisModel;
        while exist(newModel) || exist([newModel,'_bus']) %#ok
            idx = idx + 1;
            intPostFix = sprintf('%d',idx);
            newModel = [thisModel, intPostFix];
        end
        if ~strcmp(thisModel, newModel)
            warning('Simulink:sldemo_mdlref_util:InvalidModelRef', ...
                    ['Model name ''%s'' is already ', ...
                     'exist. Using ''%s'' as the ', ...
                     'new model name.'], thisModel, newModel);
        end
        thisModel = newModel;
        
        % This may throw an error message
        Simulink.SubSystem.convertToModelReference( ...
            'sldemo_mdlref_conversion/Bus Counter',thisModel, ...
            'ReplaceSubsystem', true, ...
            'BusSaveFormat','Object'); 
        close_system(thisModel);
    end
elseif strcmp(action,'exit')
    if bdIsLoaded('sldemo_mdlref_conversion')
        close_system('sldemo_mdlref_conversion', 0);
    end
    
    clean_mdlref_conversion_l(mdlRef)
end
%endfunction

% Function  clean_mdlref_conversion_l ---------------------------------------
% Abstratc: This function closes the models and clear workspace variables 
% added for sldemo_mdlref_conversion demo.
%
function clean_mdlref_conversion_l(mdlRef)

if bdIsLoaded(mdlRef)
    close_system(mdlRef, 0);
end

mdlRefMdl = [mdlRef,'.mdl'];
busFile   = [mdlRef,'_bus.m'];

% Remove sldemo_bus_counter.mdl if it is in the current directory
if ~isempty(dir(mdlRefMdl))
    delete(mdlRefMdl);
end

if ~isempty(dir(busFile))
    delete(busFile);
end

evalin('base','clear COUNTERBUS COUNTERBUSOUT LIMITBUS');

%endfunction            
