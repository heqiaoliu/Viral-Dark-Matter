function [origBlks,newBlks, errorOccurred]=sldiscmdl(sys,SampleTime,varargin)
%SLDISCMDL discretizes a simulink model containing continuous blocks.
%
%   Usage:
%      [ORIGBLKS, NEWBLKS]=SLDISCMDL(SYS,SAMPLETIME)
%      [ORIGBLKS, NEWBLKS]=SLDISCMDL(SYS,SAMPLETIME,METHOD)
%      [ORIGBLKS, NEWBLKS]=SLDISCMDL(SYS,SAMPLETIME,OPTIONS)
%      [ORIGBLKS, NEWBLKS]=SLDISCMDL(SYS,SAMPLETIME,METHOD,CF)
%      [ORIGBLKS, NEWBLKS]=SLDISCMDL(SYS,SAMPLETIME,METHOD,OPTIONS)
%      [ORIGBLKS, NEWBLKS]=SLDISCMDL(SYS,SAMPLETIME,METHOD,CF,OPTIONS)
%   ORIGBLKS    -- the original names of the continuous blocks
%   NEWBLKS     -- the new names of the discretized blocks
%   SYS         -- the model name
%   METHOD      -- 'zoh', 'foh', 'tustin','prewarp', 'matched'
%   SAMPLETIME  -- SampleTime or [sampletime offset]
%   CF          -- critical frequency
%   OPTIONS     -- a cell array: {target,ReplaceWith,PutInto,prompt},
%     target can be:
%           'all'      --discretize all continuous blocks
%           'selected' --discretize selected only
%           a full path name of a block in SYS.
%     ReplaceWith can be:
%           'parammask' --replace continuous blocks with parametric masks
%           'hardcoded' --replace continuous blocks with hard-coded discrete equivalents
%     PutInto can be:
%           'current'      --put changes into the current model
%           'configurable' --put changes into a configurable subsystem
%           'untitled'     --put changes into a new untitled window
%           'copy'         --put changes in a copy of the original model
%     prompt can be:
%           'on'   --show discretization information
%           'off'  --do not show discretization information

% $Revision: 1.10.4.13 $ $Date: 2009/12/28 04:38:31 $
% Copyright 1990-2007 The MathWorks, Inc.

error(nargchk(2, 7, nargin));
error(nargoutchk(0, 3, nargout));
origBlks     = [];
newBlks      = [];
errorOccurred = 0; 
%Check if sys is open. If not, then open it; otherwise, give an error message.
if isempty(find_system('SearchDepth', 0, 'Name', sys))    
  if exist(sys) == 4
    open_system(sys);
  else
    DAStudio.error('Simulink:components:discmdlMdlNotFound', sys);
  end
end

%Check if 'simulink3' is loaded
SLLib = 'simulink3';
if isempty(find_system('SearchDepth', 0, 'Name', SLLib))
    load_system(SLLib);
end

%Check validity fo SampleTime
try
  [isValidSampleTime, isValidOffset, SampleTime, offset] = getSampleTimeAndOffsetValues(SampleTime);
catch
  errorOccurred = 1; 
  if(nargout > 2 )
      import com.mathworks.toolbox.mdldisc.*;
      Util.showMsg(MdlDisc.getString('errwrongsampletime'), MdlDisc.getString('error.Dialog.Title'));
      return;
  end

end

if(~isValidSampleTime)
  errorOccurred = 1; 
  import com.mathworks.toolbox.mdldisc.*;
  Util.showMsg(MdlDisc.getString('errSampleTime'), MdlDisc.getString('error.Dialog.Title'));
  return;
end
if(~isValidOffset)
  errorOccurred = 1; 
  if(nargout > 2 )
      import com.mathworks.toolbox.mdldisc.*;
      Util.showMsg(MdlDisc.getString('errOffSet'), MdlDisc.getString('error.Dialog.Title'));
      return;
  end
end

%Default values
method  = 'zoh';
cf      = 0.0;
options = {'all', 'parammask', 'copy', 'on'};

%curBlk and configfunc are used by model discretizer GUI.
curBlk = '';
configfunc = '';
backup = '';
xstart = 0.0;
ystart = 0.0;
libName = '';
whichChoice = 0;

%Parse varargin
switch nargin
case 3
    if ischar(varargin{1})
        if strcmp(varargin{1}, 'prewarp')
            DAStudio.error('Simulink:components:discmdlCriticalFreq');
        end
        method = lower(varargin{1});
    else
        options = lower(varargin{1});
    end                
case 4    
    if ~ischar(varargin{1})
        DAStudio.error('Simulink:components:discmdlInvalidArg');
    else
        method = lower(varargin{1});
        if strcmp(method, 'prewarp')
            cf = getValidCriticalFreq(varargin{2}, SampleTime);
        else
            if isnumeric(varargin{2})
                DAStudio.error('Simulink:components:discmdlInvalidArgNum',...
                    sprintf('%g',varargin{2}));
            end
            options = varargin{2};
        end
    end
case 5
    method = lower(varargin{1});
    if strcmpi(method, 'prewarp')
       cf = getValidCriticalFreq(varargin{2}, SampleTime);
       options = varargin{3};
%        if ~strcmp(method,'prewarp') | ~isnumeric(cf) | ~iscell(options)
       if ~strcmp(method,'prewarp') | ~iscell(options)           
           DAStudio.error('Simulink:components:discmdlInvalidArg');
       end
   else
       options = varargin{2};
       curBlk = varargin{3};
       if ~iscell(options)
           DAStudio.error('Simulink:components:discmdlInvalidArg');
       end
       if strcmpi(options{3},'configurable')
          DAStudio.error('Simulink:components:discmdlInvalidArgStr', options{3});
       end
   end
case 6
    method = lower(varargin{1});
    if strcmp(method,'prewarp')
       cf = getValidCriticalFreq(varargin{2}, SampleTime);
       options = varargin{3};
%        if ~strcmp(method,'prewarp') | ~isnumeric(cf) | ~iscell(options)
       if ~strcmp(method,'prewarp') | ~iscell(options)    
          DAStudio.error('Simulink:components:discmdlInvalidArg');
       end
   else
       options = varargin{2};
       curBlk = varargin{3};
       arg4 = varargin{4};
       if ~strcmpi(options{3},'configurable')
          DAStudio.error('Simulink:components:discmdlInvalidArgStr', options{3});
       end
       configfunc = lower(arg4{1});
       backup = lower(arg4{2});
       libName = arg4{3};
       if length(arg4)==4
           whichChoice = arg4{4};
       end
   end
case 7
    method = lower(varargin{1});
    cf = getValidCriticalFreq(varargin{2}, SampleTime);
    options = varargin{3};
%     if ~strcmp(method,'prewarp') | ~isnumeric(cf) | ~iscell(options)
    if ~strcmp(method,'prewarp') | ~iscell(options)    
        DAStudio.error('Simulink:components:discmdlInvalidArg'); 
    end
    if ~strcmpi(options{3},'configurable')
        DAStudio.error('Simulink:components:discmdlInvalidArgStr', options{3});
    end 
    curBlk = varargin{4};
    %configfunc can be 'new', 'add', 'delete', 'replace', 'hardcode'
    %backup -- on: save a backup when modifying configurable subsystem.
    arg5 = varargin{5};
    configfunc = lower(arg5{1});
    backup = lower(arg5{2});
    libName = arg5{3};
    if length(arg5)==4
        whichChoice = arg5{4};
    end   
end

%check validity of input arguments
allowedMethod = {'zoh','foh','tustin','prewarp','matched'}';
allowedOp1 = {'all','selected','blockpath'}';
allowedOp2 = {'parammask','hardcoded'};
allowedOp3 = {'current','copy','untitled','configurable'};
allowedOp4 = {'on','off'};

allowedConfigfunc = {'new', 'add', 'delete', 'replace', 'hardcode'};

if isempty(strmatch(method,allowedMethod,'exact'))
    DAStudio.error('Simulink:components:discmdlInvalidTransform',method);
end
if length(options) ~= 4
   DAStudio.error('Simulink:components:discmdlInvalidNumberOption');
end
if isempty(strmatch(lower(options{2}),allowedOp2,'exact'))
    DAStudio.error('Simulink:components:discmdlInvalidOptionStr', options{2});
end
if isempty(strmatch(lower(options{3}),allowedOp3,'exact'))
    DAStudio.error('Simulink:components:discmdlInvalidOptionStr', options{3});
end
if isempty(strmatch(lower(options{4}),allowedOp4,'exact'))
    DAStudio.error('Simulink:components:discmdlInvalidOptionStr', options{4});
end

if ~isempty(configfunc)
   if isempty(strmatch(lower(configfunc), allowedConfigfunc, 'exact'))
       DAStudio.error('Simulink:components:discmdlInvalidArgStr', configfunc);
   end
end

%
% Libraries need to be unlocked before changes can be made to them.
%
isLibrary = strcmp(get_param(sys, 'BlockDiagramType'), 'library');
if isLibrary,
    set_param(sys, 'Lock', 'off');
end

discRules = rules;

%
% get the set of specified blocks and subsystems in SYS
%

if strcmp(lower(options{2}), 'parammask')
    ReplaceMethod = 1;
else 
    ReplaceMethod = 0;
end
prompt    = lower(options{4});
PutInto   = lower(options{3});

OKSample = 1;
OKoffset = 1;
 if ReplaceMethod == 0
     if ~isnumeric(SampleTime) 
         [SampleTime OKSample] = str2num(SampleTime);
     end
     if ~isnumeric(offset)
         [offset OKoffset] = str2num(offset);
     end
     if ~OKSample || ~OKoffset
         DAStudio.error('Simulink:components:discmdlWrongFormatSampleTime');
     end
     
    if strcmpi(varargin{1},'prewarp') 
     cf = getValidCriticalFreq(cf, SampleTime);
    end
 end



%Save a copy of the model SYS if options{3}=='copy'.
if strcmp(PutInto, 'copy')
    copysys = GetUniqueFileName(sys,'_disc_copy');
    save_system(sys,copysys);
    
    fprintf('Changes are saved in %s\n',copysys);
    optmp = options{1};
    if ~strcmp(lower(optmp),'all') & ~strcmp(lower(optmp),'selected')
        idx   = findstr(optmp, '/'); 
        options{1} = [copysys, optmp(idx:length(optmp))];
    end
    sys = copysys;
end

%Search for discretization candidates
  selected = [];
  names    = find_system(sys);
  switch lower(options{1})
  case 'all'
      selected = names(2:length(names));
  case 'selected'      
    k = 1;
    for i = 2:length(names)
        if strcmp(get_param(names{i}, 'selected'), 'on')
        selected{k} = names{i};
        k = k+1;
        end
    end
  otherwise
      if strcmpi(options{1},sys)
          selected = names(2:length(names));
      else
          selected{1} = options{1};
      end
  end
    
if isempty(libName) | strcmpi(libName, 'none')
   libName  = GetUniqueFileName(sys, '_disc_lib');
else
   set_param(libName,'Lock','off');   
end
hLib     = [];
idc      = 0;
idd      = 0;
origBlks1 = [];
newBlks1  = [];
discretizedBlks = [];
spacing  = 50;
xPos     = spacing;
yPos     = spacing;

%Open an 'Untitled' window if  PutInto=='untitled'
newUntitled = '';
xPosn = spacing;
yPosn = spacing;
if strcmp(PutInto, 'untitled')
    newUntitled = get_param(new_system, 'Name');
    open_system(newUntitled);
    pos1 = get_param(newUntitled, 'Location');
    pos2 = [pos1(1) pos1(2) pos1(1)+15*spacing pos1(2)+10*spacing];
    set_param(newUntitled, 'Location', pos2);
    xPosn = spacing;
    yPosn = spacing;
end


switch configfunc
case ''
case 'new'
    theSelected = options{1};       
    if get_param(theSelected,'handle') ~= get_param(curBlk,'handle')
        replace_block(sys, 'handle', get_param(curBlk,'handle'), theSelected, 'noprompt');
        set_param(curBlk,'LinkStatus','none')
        theSelected = curBlk;
    end

    parentBlk = get_param(curBlk, 'parent');
    window = findSystemWindow(parentBlk);
    open_system(parentBlk, window, 'browse', 'force');
    closeScopes(parentBlk);
    hilitediscblock(theSelected,3,[],[],0);
    
    origBlkPos  = get_param(theSelected, 'Position');       
    widthBlk    = origBlkPos(3) - origBlkPos(1);
    heightBlk   = origBlkPos(4) - origBlkPos(2);    
    if isempty(find_system('SearchDepth', 0, 'Name', libName))           
        hLib = new_system(libName, 'Library');
        save_system(hLib);
        set_param(hLib, 'Dirty','on');        
        add_param(sys,'disc_configurable_lib',libName);
%         open_system(hLib);
        tmploc = get_param(sys,'location');
        set_param(hLib, 'location', [tmploc(1),(tmploc(2)+tmploc(4))/2,tmploc(3),tmploc(4)+(tmploc(4)-tmploc(2))/2]);
    end
    [x, y] = getNewXY(libName, spacing);
    pos         = [x y widthBlk heightBlk];
    [curBlk, srcBlk] = SaveAsConfigurable(theSelected, pos, libName, SampleTime, offset, ...
                          method, cf, ReplaceMethod, discRules);
    hilitediscblock(theSelected,2,[],[],0);
    newBlks = curBlk;
    origBlks = srcBlk;
    return;
case 'add'   
    theSelected = options{1};
    if isempty(strmatch(libName, lower(get_param(curBlk,'templateblock'))))
        return;
    end
    parentBlk = get_param(curBlk, 'parent');
    templateBlk = get_param(curBlk,'templateblock');
    window = findSystemWindow(parentBlk);
    open_system(parentBlk, window, 'browse', 'force');
    hilitediscblock(curBlk,3,[],[],0);    
    tmpBlk = replace_block(sys,'handle',get_param(curBlk,'handle'),theSelected,'noprompt');
    tmpBlk = tmpBlk{1};
    set_param(tmpBlk,'linkstatus','none');
    [hasContinuousBlk, origs, news] = DiscretizeSubsystem(tmpBlk, SampleTime, offset, ...
                         method, cf, ReplaceMethod, 'current', discRules, 'off');
    tmpLibBlks = find_system(libName,'searchdepth',1);
    for jj = 1:length(tmpLibBlks),
        if ~isempty(findstr(tmpLibBlks{jj},get_param(theSelected,'name')))
           tmpPos = get_param(tmpLibBlks{jj},'position');
           if tmpPos(3) > xstart
               xstart = tmpPos(3) + spacing;
               ystart = tmpPos(2);
               widthBlk = tmpPos(3) - tmpPos(1);
               heightBlk = tmpPos(4) - tmpPos(2);
           end
       end        
    end
    [x,y,w,h] = getAddXY(theSelected, spacing);
    tmpPos = [x, y, x + w, y + h];
    newDiscBlk = getNextMemberBlk(templateBlk);
    try
        newidx = str2num(newDiscBlk(length(newDiscBlk)));
        tmpPos = [(2+newidx-1)*(w+spacing)+spacing, y, (2+newidx-1)*(w+spacing)+spacing+w, y+h];
    catch
    end    
    add_block(tmpBlk, newDiscBlk,...
              'Position',tmpPos,...
              'Orientation',get_param(theSelected,'Orientation'),...
              'NamePlacement',get_param(theSelected,'NamePlacement'));
    oldMembers = get_param(templateBlk,'memberblocks');
    set_param(templateBlk,'memberblocks',...
              strcat(oldMembers,',',strrep(get_param(newDiscBlk,'name'),sprintf('\n'),' ')));
    set_param(templateBlk,'blockchoice',strrep(get_param(newDiscBlk,'name'),sprintf('\n'),' '));
%     save_system(libName);
    block2link(tmpBlk,templateBlk);
    hilitediscblock(tmpBlk,2,[],[],0);    
    newBlks = tmpBlk;
    origBlks = theSelected;
    return;
case 'delete'
%     open_system(libName);
    templateBlk = get_param(curBlk,'templateblock');
    oldMembers = get_param(templateBlk,'memberblocks');
    newMembers = strrep(oldMembers,sprintf(',%s', strrep(get_param(getMemberBlk(templateBlk,whichChoice),'name'),sprintf('\n'),' ')), '');
    blkToDel   = getMemberBlk(templateBlk,whichChoice);
    set_param(curBlk, 'linkstatus', 'none');
    set_param(templateBlk,'blockchoice',strrep(get_param(getMemberBlk(templateBlk,1),'name'),sprintf('\n'),' '));
    set_param(templateBlk,'memberblocks',newMembers);
    delete_block(blkToDel);
    newchoice = strrep(get_param(getMemberBlk(templateBlk,2),'name'),sprintf('\n'),' ');
    set_param(templateBlk,'blockchoice',newchoice);
%     save_system(libName);
    block2link(curBlk, templateBlk);
    set_param(curBlk, 'blockchoice', newchoice);

    newBlks  = curBlk;
    origBlks = options{1};
    return;
case 'replace'
    theSelected = options{1};
    
    parentBlk = get_param(curBlk, 'parent');
    window = findSystemWindow(parentBlk);
    open_system(parentBlk, window, 'browse', 'force');    
    hilitediscblock(curBlk,3,[],[],0);    
    if isempty(strmatch(libName, lower(get_param(curBlk,'templateblock'))))
        return;
    end
    templateBlk = get_param(curBlk,'templateblock');
    if whichChoice < 1 | whichChoice > getNumOfMemberBlks(templateBlk)
        DAStudio.error('Simulink:component:discmdlWrongIndex');
        return;
    end    
    tmpBlk = replace_block(sys,'handle',get_param(curBlk,'handle'),theSelected,'noprompt');
    tmpBlk = tmpBlk{1};
    set_param(tmpBlk,'linkstatus','none');
    [hasContinuousBlk, origs, news] = DiscretizeSubsystem(tmpBlk, SampleTime, offset, ...
                         method, cf, ReplaceMethod, 'current', discRules, 'off');
    replace_block(libName,'handle',get_param(getMemberBlk(templateBlk,whichChoice),'handle'),tmpBlk,'noprompt');
    set_param(templateBlk,'blockchoice',...
              strrep(get_param(getMemberBlk(templateBlk,whichChoice),'name'),sprintf('\n'),' '));
%     save_system(libName);
    block2link(tmpBlk,templateBlk); 
    hilitediscblock(tmpBlk,2,[],[],0);    
    newBlks = tmpBlk;
    origBlks = theSelected;
    return;
    
case 'hardcode'
    theSelected = options{1};
    
    parentBlk = get_param(curBlk, 'parent');
    window = findSystemWindow(parentBlk);
    open_system(parentBlk, window, 'browse', 'force');
    hilitediscblock(curBlk,3,[],[],0);    
    if isempty(strmatch(libName, lower(get_param(curBlk,'templateblock'))))
        return;
    end
    templateBlk = get_param(curBlk,'templateblock');
    tmpBlk = replace_block(sys,'handle',get_param(curBlk,'handle'),theSelected,'noprompt');
    tmpBlk = tmpBlk{1};
    set_param(tmpBlk,'linkstatus','none');
    [hasContinuousBlk, origs, news] = DiscretizeSubsystem(tmpBlk, SampleTime, offset, ...
                         method, cf, ReplaceMethod, 'current', discRules, 'off');
    hilitediscblock(tmpBlk,2,[],[],0);                     
    origBlks = theSelected;
    newBlks = tmpBlk;
    return;
end


%
% For each selected item, get the members and replace them 
% if they are discretizable.
%

  for i = 1:length(selected)
    if ~isempty(strmatch(selected{i}, discretizedBlks, 'exact'))
        continue;
    end
    try
       member = find_system(selected{i});
       %The first element of member is selected{i}.
    catch
       member = [];
       if length(selected) == 1
           DAStudio.error('Simulink:components:discmdlBlkNotExist',selected{1});
       end
    end    
    
    
    if length(member)>0 & strcmp(get_param(selected{i}, 'BlockType'), 'SubSystem') & ...
            strcmp(PutInto, 'configurable') & ...
            strcmp(get_param(selected{i}, 'linkstatus'), 'none')
    %save to a configurable subsystem
     if iscontinuous(selected{i}, discRules)
       if isempty(find_system(hLib))           
           hLib = new_system(libName, 'Library');
           save_system(hLib);
           set_param(hLib, 'Dirty', 'on');           
           open_system(hLib);
           tmploc = get_param(sys,'location');
           set_param(hLib, 'location', [tmploc(1),(tmploc(2)+tmploc(4))/2,tmploc(3),tmploc(4)+(tmploc(4)-tmploc(2))/2]);           
       end
       theSelected = selected{i};       
       origBlkPos  = get_param(theSelected, 'Position');       
       widthBlk    = origBlkPos(3) - origBlkPos(1);
       heightBlk   = origBlkPos(4) - origBlkPos(2);       
       pos         = [xPos yPos widthBlk heightBlk];
       yPos        = yPos + (2*spacing + heightBlk);         
       if strcmp(prompt, 'on')
          fprintf('\n-- discretizing ''%s'' and putting results into a configurable subsystem\n',...
              strrep(selected{i}, sprintf('\n'), ' '));
       end
       newBlk = SaveAsConfigurable(theSelected, pos, libName, SampleTime, offset, method, cf,...
                        ReplaceMethod, discRules);
       hilitediscblock(newBlk,2,[],[],0);
       idc           = idc+1;
       origBlks1{idc} = selected{i};       
       newBlks1{idc}  = newBlk;
       for j = 1:length(member),
           idd = idd + 1;
           discretizedBlks{idd} = member{j};
       end
     end  
        
    else
    %discretize continuous blocks
        [hasContinuousBlk, origs, news, xPosn, yPosn] = DiscretizeSubsystem(selected{i},SampleTime,offset,...
                                     method,cf,ReplaceMethod,PutInto,discRules,prompt,newUntitled,xPosn,yPosn);
        if hasContinuousBlk > 0
            for jj = 1:length(origs),
                idc =  idc + 1;
                origBlks1{idc} = origs{jj};
                newBlks1{idc}  = news{jj};
                idd = idd + 1;
                discretizedBlks{idd} = origs{jj};
            end
        end
        if hasContinuousBlk == 1
            %if member{1}, i.e. selected{i} is discretized
            for  jj = 2:length(member),
                idd = idd + 1;
                discretizedBlks{idd} = member{jj};
            end            
        end
        if hasContinuousBlk == 0 & ~strcmp(get_param(selected{i},'LinkStatus'),'none')
           fprintf('! %s is a reference block and may contain continuous blocks\n',selected{i});
        end
    end
    
  end

  origBlks = origBlks1;
  newBlks  = newBlks1;
%end function sldiscmdl  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% display warning message if the block is a masked builtin block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function warnMaskedBuiltIn(blkname)
   DAStduio.warning('Simulink:components:discmdlMaskedNotSupport',blkname);
%end warnMaskedBuiltIn

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ADDBLKTOUNTITLED adds a block to an untitled model.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [newBlk, newx, newy]=addBlkToUntitled(block, untitled, xpos, ypos, spacing)

      origBlkPos = get_param(block, 'Position');
      widthBlk   = origBlkPos(3) - origBlkPos(1);
      heightBlk  = origBlkPos(4) - origBlkPos(2);       
      pos        = [xpos ypos xpos+widthBlk ypos+heightBlk];
      newx      = xpos + spacing + widthBlk;
      newy      = ypos;
      if newx > 12*spacing
           newx  = spacing;
           newy  = newy + 2*spacing + heightBlk;
      end
      nName = strrep(block,'/', sprintf('\n'));
      newBlk = [untitled, '/', nName];
      add_block(block, newBlk, 'Position', pos, 'Name', nName);
      set_param(newBlk, 'ShowName', 'on');      

%end addBlkToUntitled

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GETDISCRETIZEFUNCTION returns the function handle that has the name 'fname'.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fhandle=getDiscretizeFunction(fname)

fhandle=str2func(fname);
if strcmp(getfield(functions(fhandle),'file'),'')
    fhandle=getinternaldiscfunction(fname);
end 

%end function getDiscretizeFunction

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Discretize a subsystem and save to a configurable subsystem.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [newBlk, varargout] = SaveAsConfigurable(subsys,pos,libName,SampleTime,...
                      offset,method,cf,ReplaceMethod, discRules)

xPos = pos(1);
yPos = pos(2);
widthBlk = pos(3);
heightBlk = pos(4);

spacing = 50;
origBlkName = get_param(subsys,'Name');
%Add Configurable subsystem
SLLib = 'simulink3';
try
    srcBlk = sprintf('%s/Signals\n& Systems/Configurable\nSubsystem',SLLib);
    find_system(srcBlk);
catch
    srcBlk = sprintf('%s/Subsystems/Configurable\nSubsystem',SLLib);
end
newConfigSSName = sprintf('%s\n(Configurable Subsystem)',origBlkName);
newConfigSSBlk = sprintf('%s/%s',libName,newConfigSSName);
if isempty(find_system(libName, 'searchdepth',1,'name', newConfigSSName))
    hNewConfigSS    = add_block(srcBlk, newConfigSSBlk, ...
      'Position', [xPos, yPos, xPos+widthBlk, yPos+heightBlk], ...
      'Orientation', get_param(subsys, 'Orientation'), ...
      'NamePlacement', get_param(subsys, 'NamePlacement'));
else
    hNewConfigSS = get_param(newConfigSSBlk, 'handle');
    tmpPos = get_param(newConfigSSBlk, 'Position');
    xPos = tmpPos(1);
    yPos = tmpPos(2);
end

%Copy original block to library
newSSName = origBlkName;
newSSBlk = sprintf('%s/%s',libName,newSSName);
if isempty(find_system(libName, 'searchdepth',1,'name', newSSName))
    hNewSSBlk = add_block(subsys, newSSBlk, ...
      'Position', [xPos+widthBlk+spacing, yPos, xPos+widthBlk+spacing+widthBlk, yPos+heightBlk]);
else
    hNewSSBlk = get_param(newSSBlk, 'handle');
end

%Add discretized block to library
discName = sprintf('%s\ndiscrete version 1',origBlkName);
if ~isempty(find_system(libName,'searchdepth',1,'name', discName))
    delete_block(sprintf('%s/%s',libName,discName));
end
hDiscBlk = add_block(subsys, sprintf('%s/%s',libName,discName), ...
  'Position', [xPos+2*(widthBlk+spacing), yPos, xPos+2*(widthBlk+spacing)+widthBlk, yPos+heightBlk]);

   try
       member = find_system([libName,'/',discName]);
   catch
       member = [];
   end

   hasContinuousBlk = 0;
   [hasContinuousBlk, origs, news] = DiscretizeSubsystem(member{1},SampleTime,offset,method,cf,ReplaceMethod,'current',discRules,'off');   
   if hasContinuousBlk == 1           
       set_param(news{1},'Name',discName);
   end

%Setup Configurable subsystem
set_param(hNewConfigSS,...
    'MemberBlocks',strrep([newSSName,',',...
     discName],sprintf('\n'),' '),...
     'BlockChoice', strrep(discName, sprintf('\n'),' '),...
     'AttributesFormatString','%<BlockChoice>',...
     'ShowName','on');

%Link subsys to the new configurable subsystem
block2link(subsys, sprintf('%s/%s', libName, newConfigSSName));
newBlk = subsys;
varargout{1} = newSSBlk;

%end  SaveAsConfigurable

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Get a unique file name
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fileName = GetUniqueFileName(baseName,addtxt)

baseName = [baseName,addtxt];
fileName = baseName;
counter = 1;

% Add number suffix if a model of this name already exists.
while (exist(fileName)==4) % Existing Simulink model name
  fileName = [baseName, num2str(counter)];
  counter=counter+1;
end

%end GetUniqueFileName

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% discretize a block or a subsystem
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hasContinuousBlk, origs, news, varargout] = DiscretizeSubsystem(subsys,SampleTime,...
                                      offset,method,cf,ReplaceMethod,PutInto,discRules,prompt, varargin)
        
        spacing = 50;
        if nargin == 12
            newUntitled = varargin{1};
            xPosn       = varargin{2};
            yPosn       = varargin{3};
            hiliteDiscretizedBlock = 1;
        else
            newUntitled = '';
            xPosn = spacing;
            yPosn = spacing;
            hiliteDiscretizedBlock = 0;
        end
        hasContinuousBlk = 0;
        origs = [];
        news = [];
        idc = 0;
        member = find_system(subsys);
        for j = 1:length(member)
                
                [isDiscretizable, discfcn] = chkrules(member{j}, discRules);
                if isDiscretizable
                    if strcmp(prompt,'on')
                        fprintf('\n-- discretizing ''%s'' using method ''%s''\n',...
                            strrep(member{j}, sprintf('\n'), ' '),discfcn);
                    end
                    theSelected = member{j};
                    if strcmp(PutInto,'untitled')
                        [theSelected,xPosn,yPosn] = addBlkToUntitled(theSelected,newUntitled,xPosn,yPosn,spacing);
                    end
	                newBlk = feval( getDiscretizeFunction(discfcn), theSelected, method,...
                                  SampleTime, offset, cf, ReplaceMethod);
                    if hiliteDiscretizedBlock          
                       hilitediscblock(newBlk,2,[],[],0);
                    end
                    idc           = idc + 1;
                    origs{idc} = member{j};
                    news{idc}  = newBlk;
                    hasContinuousBlk = j;
                end 
                if(strcmpi(get_param(member{j}, 'blocktype'), 'VariableTransportDelay') && ...
                    strcmpi(get_param(member{j}, 'VariableDelayType'), 'Variable transport delay'))
                    DAStudio.warning('Simulink:components:VariableTransportDelayNotSupported')                    
                end
            if hasContinuousBlk == 1
                break;
            end
        end
        if nargout == 5
            varargout{1} = xPosn;
            varargout{2} = yPosn;    
        end

% end DiscretizeSubsystem
function [isValidSampleTime, isValidOffset, SampleTime, offset] = getSampleTimeAndOffsetValues(SampleTime)
isValidSampleTime = 1;
isValidOffset     = 1;
offset = 0.0;

  [a, b] = size(SampleTime);
  if a ~= 1 || (b ~= 1 && b ~= 2) 
    isValidSampleTime = 0;
    return;
  end
  
  
  if iscell(SampleTime)
    if b==2
      offset = SampleTime{2};
    end
    SampleTime = SampleTime{1};
  else
    if b == 2
      offset = SampleTime(2);
    end
    SampleTime = SampleTime(1);
  end
  SampleTimeValue = SampleTime;
  
  if(ischar(SampleTime))
    SampleTimeValue = str2num(SampleTime);
    if(isempty(SampleTimeValue))
      isValidSampleTime = 0;
      return;
    end
    
    if (SampleTimeValue <= 0)
      isValidSampleTime = 0;
      return;
    end
  end
  if(ischar(offset))
    offsetValue = str2num(offset);
    if(isempty(offsetValue))
      isValidOffset = 0;
    return;
  end
  if (offsetValue < 0 || (offsetValue >= SampleTimeValue ))
    isValidOffset = 0;
    return;
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get a valid name (full path) for adding a member to a configurable subsystem
% block - a configurable subsystem block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function blkName = getNextMemberBlk(block)

% jj = getNumOfMemberBlks(block);
jj = 1;
blkName = '';
if jj > 0
    blkName = strcat(getContinuousBlk(block),sprintf('\ndiscrete version %d',jj));
    while ~isempty(strmatch(blkName,find_system(bdroot(block),'searchdepth',1)))
        jj = jj + 1;
        blkName = strcat(getContinuousBlk(block),sprintf('\ndiscrete version %d',jj));
    end
end

%end getNextMemberBlkName

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% blkName - a string in which '\n' is replaced by white-space
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function block = findMemberBlk(blkName,sysName)

tmpBlks = find_system(sysName,'searchdepth',1);
block = '';
for jj = 2:length(tmpBlks),
    tmpName = get_param(tmpBlks{jj},'name');
    if strcmpi(strrep(tmpName,sprintf('\n'),' '), blkName)
        block = tmpBlks{jj};
    end
end
%end findMemberBlk

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the continuous block (full path name) in a configurable subsystem 'block'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function conBlk = getContinuousBlk(block)

member = get_param(block,'memberblocks');
[t,r] = strtok(member,',');
continuousName = '';
while ~isempty(r)
    if isempty(findstr(lower(t),'discrete version'))
        continuousName = t;
        break;
    end
end
if isempty(continuousName)
    conBlk = '';
else
    conBlk = findMemberBlk(continuousName, bdroot(block));
end

%end getContinuousBlk

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the number of member blocks in a configurable subsystem
% block - the template block
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function nums = getNumOfMemberBlks(block)

member = get_param(block,'memberblocks');
nums = length(strread(member,'%s','delimiter',','));

%end getNumOfMemberBlks

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get the full path name of a member block from an index number
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function memBlk = getMemberBlk(block,index)

member = get_param(block,'memberblocks');
[t,r] = strtok(member,',');
for jj = 1:index-1,
    [t,r] = strtok(r,',');
end
memBlk = findMemberBlk(t,bdroot(block));

%end getMemberBlk

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get a new x,y for creating a new configurable subsystem
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, y] = getNewXY(libName,spacing)

tmpBlks = find_system(libName, 'searchdepth',1);
x = spacing;
y = spacing;
for jj = 2:length(tmpBlks)
    pos = get_param(tmpBlks{jj},'position');
    if pos(4) > y
        y = pos(4);
    end
end
y = y + 2 * spacing;

%end getNewXY

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% get x,y for adding a version to the configurable subsystem
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [x, y, w, h] = getAddXY(block, spacing)

tmpLibBlks = find_system(bdroot(block),'searchdepth',1);
x = spacing;
y = spacing;
w = spacing;
h = spacing;
for jj = 1:length(tmpLibBlks),
    if ~isempty(findstr(tmpLibBlks{jj},get_param(block,'name')))
       tmpPos = get_param(tmpLibBlks{jj},'position');
       if tmpPos(3) > x
           x = tmpPos(3) + spacing;
           y = tmpPos(2);
           w = tmpPos(3) - tmpPos(1);
           h = tmpPos(4) - tmpPos(2);
       end
    end        
end

%end getAddXY

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Find a open system window in the given hierarchy that is open.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function window = findSystemWindow(item)

window 				  = [];
parent			      = item;

while (~isempty(parent))
  window			  = find_system(parent, 'BlockType', 'SubSystem', 'open', 'on');
  if (isempty(window))
    window		      = find_system(parent, 'Type', 'block_diagram', 'open', 'on');
  end
  if (~isempty(window))
    window		      = window{1};
    break;
  end
  parent		      = get_param(parent, 'Parent');
end

%end findSystemWindow

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Close all open scopes.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function closeScopes(subsystem)

scopeToClose        = find_system(subsystem, 'BlockType', 'Scope');
for i               = 1 : length(scopeToClose)                % Close all open scopes.
  figId             = get_param(scopeToClose{i}, 'figure');
  if (figId > 0)
    set(figId, 'visible', 'off');
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Returns a valid critical frequency value, error out if cannot be evaluated.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function cf = getValidCriticalFreq(cfArg, SampleTime)

if ischar(SampleTime)
    Ts = str2num(SampleTime);
elseif isnumeric(SampleTime)
    Ts = SampleTime;
end;

if ischar(cfArg)
    cf = str2num(cfArg);
elseif isnumeric(cfArg)
    cf = cfArg;
else
    cf = [];
    DAStudio.error('Simulink:components:discmdlCriticalFreq');
end

if isempty(cf)
    DAStudio.error('Simulink:components:discmdlWrongFormatFreq');
else
    if (cf <= 0.0) || (cf >= pi/Ts)
       DAStudio.error('Simulink:components:discmdlCriticalFreqTooLarge');
    end
end

% [EOF] sldiscmdl.m









