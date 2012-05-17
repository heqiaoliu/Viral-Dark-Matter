function varargout = cpselect(varargin)
%CPSELECT Control point selection tool. 
%   CPSELECT is a graphical user interface that enables you to select
%   control points from two related images.
%
%   CPSELECT(INPUT,BASE) returns control points in CPSTRUCT. INPUT is the
%   image that needs to be warped to bring it into the coordinate system of the
%   BASE image. INPUT and BASE can be either variables that contain grayscale,
%   truecolor, or binary images or strings that identify files containing these
%   same types of images.
%
%   CPSELECT(INPUT,BASE,CPSTRUCT_IN) starts CPSELECT with an initial set of
%   control points that are stored in CPSTRUCT_IN. This syntax allows you to
%   restart CPSELECT with the state of control points previously saved in
%   CPSTRUCT_IN.
%
%   CPSELECT(INPUT,BASE,XYINPUT_IN,XYBASE_IN) starts CPSELECT with a set of
%   initial pairs of control points. XYINPUT_IN and XYBASE_IN are M-by-2
%   matrices that store the INPUT and BASE coordinates respectively.
%
%   H = CPSELECT(INPUT,BASE,...) returns a handle H to the tool. CLOSE(H)
%   closes the tool.
%
%   CPSELECT(...,PARAM1,VAL1,PARAM2,VAL2,...) starts CPSELECT, specifying
%   parameters and corresponding values that control various aspects of the
%   tool. Parameter names can be abbreviated, and case does not matter.
%
%   Parameters include:
%
%   'Wait'             Logical scalar that controls whether CPSELECT
%                      waits for the user to finish the task of selecting
%                      points. If set to FALSE (the default) you can
%                      run CPSELECT at the same time as you run other 
%                      programs in MATLAB. If set to TRUE, you must
%                      finish the task of selecting points before doing
%                      anything else in MATLAB. 
%
%                      The value affects the output arguments:
%                        
%                         H = CPSELECT(...,'Wait',false) returns a handle 
%                         H to the tool. CLOSE(H) closes the tool.
%
%                         [XYINPUT_OUT,XYBASE_OUT] = CPSELECT(...,'Wait',true)
%                         returns the selected pairs of points. XYINPUT_OUT 
%                         and XYBASE_OUT are P-by-2 matrices that store the 
%                         INPUT and BASE coordinates respectively.
%
%   Class Support
%   -------------
%   The images can be truecolor, grayscale, or binary. A truecolor image can be
%   uint8, uint16, single, or double. A grayscale image can be uint8, uint16,
%   int16, single, or double. A binary image is of class logical.
%
%   Example 1
%   ---------
%   Start tool with saved images.
%
%       cpselect('westconcordaerial.png','westconcordorthophoto.png')
%
%   Example 2
%   ---------
%   Start tool with workspace images and points.
%
%       I = checkerboard;
%       J = imrotate(I,30);
%       base_points = [11 11; 41 71];
%       input_points = [14 44; 70 81];
%       cpselect(J,I,input_points,base_points);
%
%   Example 3
%   ---------  
%   Register an aerial photo to an orthophoto.
%  
%       aerial = imread('westconcordaerial.png');
%       figure, imshow(aerial)
%       figure, imshow('westconcordorthophoto.png')
%       load westconcordpoints % load some points that were already picked     
%
%       % Ask CPSELECT to wait for you to pick some more points
%       [aerial_points,ortho_points] = ...
%          cpselect(aerial,'westconcordorthophoto.png',...
%                     input_points,base_points,...
%                     'Wait',true);
%
%       t_concord = cp2tform(aerial_points,ortho_points,'projective');
%       info = imfinfo('westconcordorthophoto.png');
%       aerial_registered = imtransform(aerial,t_concord,...
%                                       'XData',[1 info.Width],...
%                                       'YData',[1 info.Height]);
%       figure, imshow(aerial_registered)                         
%
%   See also CPCORR, CP2TFORM, CPSTRUCT2PAIRS, IMTRANSFORM, IMTOOL.

%   Copyright 2005-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2009/04/15 23:11:59 $

%   Input-output specs
%   ------------------ 
%   INPUT,BASE:   filenames each containing a grayscale or truecolor image
%
%                OR 
%
%                real, full matrix
%                can be intensity or truecolor
%                uint8, uint16, double, or logical
%
%        Note: INPUT can be a filename while BASE is a variable or vice versa.
%
%   CPSTRUCT:    structure containing control point pairs with fields:
%                   inputPoints
%                   basePoints
%                   inputBasePairs
%                   ids
%                   inputIdPairs
%                   baseIdPairs
%                   isInputPredicted
%                   isBasePredicted
%
%   XYINPUT_IN, XYBASE_IN: M-by-2 matrices with control point coordinates.
%                          real, full, finite

% Don't run on platforms without Java figures
% immagboxjava/javacomponent need Java figures
if ~isJavaFigure
  eid = sprintf('Images:%s:cpselectNotAvailableOnThisPlatform',mfilename);
  error(eid,'%s','CPSELECT is not available on this platform.');
end

[input, base, cpstruct, args] = ParseInputs(varargin{:});

if args.Wait && nargout~=2
  eid = sprintf('Images:%s:Expected2OutputArgs',mfilename);
  error(eid,'%s expects 2 output arguments when WAIT is true.',upper(mfilename))
end

% get names to label images
inputImageName = getImageName(varargin{1},inputname(1));
baseImageName = getImageName(varargin{2},inputname(2));

toolIdStream = idStreamFactory('CpselectInstance');
toolNumber = toolIdStream.nextId(); 

toolName = sprintf('Control Point Selection Tool %d',toolNumber);

%Create invisible figure
hFig = figure('Toolbar','none',...
              'Menubar','none',...
              'HandleVisibility','callback',...
              'IntegerHandle','off',...
              'NumberTitle','off',...
              'Tag','cpselect',...
              'Name',toolName,...
              'Visible','off',...       % turn visibility off to prevent flash
              'DeleteFcn',@deleteTool,...
              'Position',getInitialPosition());
          
suppressPlotTools(hFig);

          
% Set default 'HitTest','off' as workaround to HG issue
% We only want to manually turn on 'HitTest' for objects that will have
% a 'ButtonDownFcn' set.
turnOffDefaultHitTestFigChildren(hFig);

[hScrollPanels,hImInput,hImBase,hSpInput,hSpBase] = ...
    leftRightImscrollpanel(hFig,input,base);
[hOverviewPanels,hImOvInput,hImOvBase] = ...
    leftRightImoverviewpanel(hFig,hImInput,hImBase);

% Stores the id returned by IPTADDCALLBACK for the image object's
% ButtonDownFcn callback.
ovInputImageButtonDownFcnId = [];
ovBaseImageButtonDownFcnId = [];

% Create titles
inputDetailLabel = sprintf('Input Detail: %s',inputImageName); 
baseDetailLabel = sprintf('Base Detail: %s',baseImageName); 
hMagPanel = lockRatioMagPanel(hFig,hImInput,hImBase,inputDetailLabel,baseDetailLabel);

% Turn on HitTest so ButtonDownFcn will fire when images are clicked
set([hImInput hImBase hImOvInput hImOvBase],'HitTest','on')

% Overall flow panel
hflow = uiflowcontainer('v0',...
                        'Parent',hFig,...
                        'FlowDirection','topdown',...
                        'Margin',1);

%Reparent subpanels 
set(hMagPanel,'Parent',hflow);
set(hMagPanel,'HeightLimits',[30 30]); % pin height

set(hScrollPanels,'Parent',hflow)
set(hOverviewPanels,'Parent',hflow)

% Get the scroll panel API to programmatically control the view
apiInput = iptgetapi(hSpInput);
apiBase = iptgetapi(hSpBase);

cpModeManager = makeUIModeManager(@makeDefaultModeCurrent);

toolbar = uitoolbar(hFig);

pointButtons = makePointButtons(toolbar);
buttons = navToolFactory(toolbar);

[addItem, addPredictItem, zoomInItem, zoomOutItem, panItem,...
 editMenuItems overviewMenuItem] = deal([]);
createMenubar % initialize menu items

% Set up modes such that tool and menu items stay in sync
% Must be defined after calling createToolbar, createMenubar  
activateAddPointMode = cpModeManager.addMode(...
  pointButtons.addPoint,  addItem,       @makeAddModeCurrent);
cpModeManager.addMode(...
  pointButtons.addPredict,addPredictItem,@makeAddPredictModeCurrent);
cpModeManager.addMode(...
  buttons.zoomInTool,     zoomInItem,    @makeZoomInModeCurrent);
cpModeManager.addMode(...
  buttons.zoomOutTool,    zoomOutItem,   @makeZoomOutModeCurrent);
cpModeManager.addMode(...
  buttons.panTool,        panItem,       @makePanModeCurrent);

pointItems = struct('addMenuItem',addItem,...
                    'addPredictMenuItem',addPredictItem,...
                    'addButton',pointButtons.addPoint,...
                    'addPredictButton',pointButtons.addPredict,...
                    'activateAddPointMode',activateAddPointMode);
cpAPI = cpManager(cpstruct,hImInput,hImOvInput,hImBase,hImOvBase,...
                  editMenuItems,pointItems);

% Initializing for function scope
cpstruct2Export = [];

% Start tool ready to add points
activateAddPointMode();

% Set up pointer manager
iptPointerManager(hFig);

set(hFig,'Visible','on'); % turn on visibility after all drawn to avoid flash

% Initialize magnification of images.
% Note: Need to call DRAWNOW here to make sure figure has come up before 
%       calling setMagnification or images won't be centered.
drawnow 
findInitMag = @(api) 2 * findZoomMag('in', api.findFitMag());
apiInput.setMagnification(findInitMag(apiInput))
apiBase.setMagnification(findInitMag(apiBase))

if args.Wait 
  uiwait(hFig)
  
  % Resuming because user either selected file->close from menus or clicked
  % close button of figure.  Both code paths lead to UIRESUME being called
  % which brings us back to here.
  if ishghandle(hFig)
      % If the figure handle still exists, we need to get the data out of it and
      % close the figure.
      cpstruct2Export = getCpstruct2Export();      
      close(hFig)   
  end
  
  [inputPoints,basePoints] = cpstruct2pairs(cpstruct2Export);
  
  varargout{1} = inputPoints;
  varargout{2} = basePoints;
  
else  
  set(hFig,'CloseRequestFcn',@closeRequestCpselect);
  
  if (nargout > 0)
    % Only return handle if caller requested it.
    varargout{1} = hFig;
  end

end

  %-------------------------------------
  function cpstruct = getCpstruct2Export
      cpstruct = cppairsvector2cpstruct(cpAPI.getInputBasePairs());
  end

  %-----------------------------------
  function setDetailImageMode(fun,ptr)

    removeDetailImageMode      
    
    enterFcn = @(f,cp) setptr(f,ptr);    
    iptSetPointerBehavior(hImInput, enterFcn);
    iptSetPointerBehavior(hImBase,  enterFcn);

    apiInput.setImageButtonDownFcn(fun)
    apiBase.setImageButtonDownFcn(fun)    
    
  end

  %-----------------------------
  function removeDetailImageMode
    
    fun = [];
    apiInput.setImageButtonDownFcn(fun)
    apiBase.setImageButtonDownFcn(fun)    
    
  end

  %-------------------------------
  function setAllImageCursors(ptr)
      
    enterFcn = @(f,cp) set(f, 'Pointer', ptr);
    
    iptSetPointerBehavior(hImInput,   enterFcn);
    iptSetPointerBehavior(hImBase,    enterFcn);
    iptSetPointerBehavior(hImOvInput, enterFcn);
    iptSetPointerBehavior(hImOvBase,  enterFcn);
    
  end
  
  %--------------------------------
  function setAllImageMode(fun,ptr)

    removeAllImageMode      

    setAllImageCursors(ptr)

    apiInput.setImageButtonDownFcn(fun)
    apiBase.setImageButtonDownFcn(fun)    
        
    if ~isempty(fun)
      ovInputImageButtonDownFcnId = iptaddcallback(hImOvInput,'ButtonDownFcn',fun);
      ovBaseImageButtonDownFcnId = iptaddcallback(hImOvBase,'ButtonDownFcn',fun);      
    else
      ovInputImageButtonDownFcnId = [];
      ovBaseImageButtonDownFcnId = [];
    end
    
  end

  %--------------------------
  function removeAllImageMode

    fun = [];
    
    apiInput.setImageButtonDownFcn(fun)
    apiBase.setImageButtonDownFcn(fun)    
  
    if ~isempty(ovInputImageButtonDownFcnId)
      iptremovecallback(hImOvInput,'ButtonDownFcn',ovInputImageButtonDownFcnId);
    end
    
    if ~isempty(ovBaseImageButtonDownFcnId)
      iptremovecallback(hImOvBase,'ButtonDownFcn',ovBaseImageButtonDownFcnId);
    end
    
  end

  %----------------------------------------
  function makeDefaultModeCurrent(varargin)

    fun = '';
    ptr = 'arrow';

    setAllImageMode(fun,ptr)

  end

  %---------------------------------------
  function makeZoomInModeCurrent(varargin)

    fun = @imzoomin;
    ptr = 'glassplus';    
    
    setDetailImageMode(fun,ptr)

  end

  %----------------------------------------
  function makeZoomOutModeCurrent(varargin)

    fun = @imzoomout;
    ptr = 'glassminus';
    
    setDetailImageMode(fun,ptr)

  end

  %------------------------------------
  function makePanModeCurrent(varargin)

    fun = @impan;
    ptr = 'hand';
    
    setDetailImageMode(fun,ptr)

  end

  %------------------------------------
  function makeAddModeCurrent(varargin)

    removeAllImageMode
    
    ptr = 'crosshair';
    setAllImageCursors(ptr)
    
    funInput = cpAPI.addInputPoint;
    funBase = cpAPI.addBasePoint;    

    wireInputImages(funInput)
    wireBaseImages(funBase)

  end
  
  %-------------------------------------------
  function makeAddPredictModeCurrent(varargin)

    removeAllImageMode      
    
    ptr = 'crosshair';
    setAllImageCursors(ptr)    
    
    funInput = cpAPI.addInputPointPredictBase;
    funBase = cpAPI.addBasePointPredictInput;    
 
    wireInputImages(funInput)
    wireBaseImages(funBase)

  end
    
  %---------------------------------
  function wireInputImages(funInput)
    
    apiInput.setImageButtonDownFcn(funInput)
        
    if ~isempty(funInput)
      ovInputImageButtonDownFcnId = iptaddcallback(hImOvInput,'ButtonDownFcn',funInput);
    else
      ovInputImageButtonDownFcnId = [];
    end

  end

  %-------------------------------
  
  function wireBaseImages(funBase)

    apiBase.setImageButtonDownFcn(funBase)    
        
    if ~isempty(funBase)
      ovBaseImageButtonDownFcnId = iptaddcallback(hImOvBase,'ButtonDownFcn',funBase);
    else
      ovBaseImageButtonDownFcnId = [];
    end
    
  end

  %----------------------------
  function deleteTool(varargin)
  
    if args.Wait
        cpstruct2Export = getCpstruct2Export();
    end
      
    % This call to delete is for performance purposes.  With larger numbers of
    % control points, delete occurs faster if hggroups defining control points
    % and their associated APIs containing callback functions are deleted in
    % advance of normal deletion order.
    delete(findobj(hFig,'Type','hggroup'));
    
    toolIdStream.recycleId(toolNumber);
    iptremovecallback(hFig,'KeyPressFcn',cpAPI.getKeyPressId())
    iptremovecallback(hFig,'WindowKeyPressFcn',cpAPI.getWindowKeyPressId())

  end  
  
  
  %---------------------------
  function createMenubar
  
    filemenu = uimenu(hFig, 'Label','&File','Tag','file menu');

    editmenu = uimenu(hFig, 'Label','&Edit','Tag','edit menu');    
    
    viewmenu = uimenu(hFig, 'Label','&View','Tag','view menu');
    
    toolmenu = uimenu(hFig, 'Label','&Tools','Tag','tools menu');
    
    if isJavaFigure
      uimenu(hFig, 'Label', '&Window','Callback', winmenu('callback'),...
             'Tag','winmenu');
    end

    helpmenu = uimenu(hFig, 'Label','&Help','Tag','help menu');
    
    % File menu items
    s = [];
    s.Parent = filemenu;

    if ~args.Wait
      % only add Export menu item if 'Wait',false
      s.Label = '&Export Points to Workspace';
      s.Accelerator = 'E';
      s.Callback = @exportPoints;
      uimenu(s);
    end

    s.Label = '&Close Control Point Selection Tool';
    s.Accelerator = 'W';
    s.Callback = @closeCpselect;
    uimenu(s);
    
    % Edit menu items
    s = [];
    s.Parent = editmenu;
    
    s.Label = '&Delete Active Pair';
    s.Callback = @deleteActivePair;
    editMenuItems.deleteActivePair = uimenu(s);

    s.Label = 'Delete Active &Input Point';
    s.Callback = @deleteActiveInputPoint;
    editMenuItems.deleteActiveInputPoint = uimenu(s);
    
    s.Label = 'Delete Active &Base Point';
    s.Callback = @deleteActiveBasePoint;
    editMenuItems.deleteActiveBasePoint = uimenu(s);

    % View menu items    
    s = [];
    s.Parent = viewmenu;

    s.Label = '&Overview Images';
    s.Checked = 'on';
    s.Callback = @toggleShowOverview;
    overviewMenuItem = uimenu(s);
    
    % Tools menu items
    s = [];
    s.Parent = toolmenu;

    s.Label = '&Add Points';
    addItem = uimenu(s);

    s.Label = 'Add Points &Predict Matches';
    addPredictItem = uimenu(s);
    
    s.Label = '&Zoom In';
    zoomInItem = uimenu(s);

    s.Label = 'Zoom &Out';
    zoomOutItem = uimenu(s);

    s.Label = 'Pa&n';
    panItem = uimenu(s);

    % Help menu items     
    s.Parent = helpmenu;
    s.Label = '&Control Point Selection Tool Help';
    s.Callback = @showCPSTHelp;
    uimenu(s);
    iptstandardhelp(helpmenu);
    
  end
  
  %------------------------------------------
  function okPressed = exportPoints(varargin)

    cpstruct2Export = getCpstruct2Export();
    [inputPoints,basePoints] = cpstruct2pairs(cpstruct2Export);

    if isempty(inputPoints)
        warndlg('You have not added any valid control point pairs. Add valid pairs before exporting.')
        return
    end
    
    checkboxlabels = {'Input points of valid pairs',...
                      'Base points of valid pairs',...
                      'Structure with all points'};
    
    defaultvarnames = {'input_points',...
                       'base_points',...
                       'cpstruct'};
    
    exportTitle = 'Export Points to Workspace';
    
    selected = [true true false];
    
    items2export = {inputPoints, basePoints, cpstruct2Export};
    
    [dummy,okPressed] = ...
        export2wsdlg(checkboxlabels,defaultvarnames,items2export,...
                     exportTitle,selected);
    
  end

  %-------------------------------
  function closeCpselect(varargin)

    if ~args.Wait
      unsavedPoints = cpAPI.getNeedToSave();
      
      if unsavedPoints
        saveIfUserRequestsSave()
      else
        delete(hFig)
      end

    else
      % Waiting for user to hit close which they've done.
      uiresume(hFig)
      
    end      
    
  end

  %------------------------------
  function saveIfUserRequestsSave

      button = questdlg('Do you want to save the control points?',...
                        'Control Point Selection Tool');
      
      if isempty(button)
          % user hit close button on dialog
          return
      end
      
      if strcmp(button,'Yes')
          okPressed = exportPoints();
          
          if okPressed
              delete(hFig)
          end
          
      elseif strcmp(button,'No')
          delete(hFig)
          
      end

  end
  
  %--------------------------------------
  function closeRequestCpselect(varargin)

    try
      unsavedPoints = cpAPI.getNeedToSave();
    
      if unsavedPoints
        button = questdlg('Unsaved control points will be lost if you choose OK.',...
                          'Control Point Selection Tool',...
                          'OK','Cancel','OK');
        
        if isempty(button)
          % user hit close button on dialog
          return
        end
        
        if strcmp(button,'OK')
          delete(hFig)
        
        end
        
      else
        delete(hFig)
        
      end

    catch m_exception
      % For some reason cpAPI not initialized
      delete(hFig)
    end
    
  end

  %----------------------------------------
  function toggleShowOverview(src,varargin)
    
    % If you just clicked on a menu item, it has the 'Checked' 
    % status from prior to your click.
    previouslyChecked = strcmp(get(src,'Checked'),'on');          
    showOverview = ~previouslyChecked;
  
    state = logical2onoff(showOverview);
    set(overviewMenuItem,'Checked',state)
    set(hOverviewPanels,'Visible',state)
    
  end
  
end % cpselect
   
%-------------------------------------------------------------
function [input, base, cpstruct, args] = ParseInputs(varargin)

  % defaults
  args.Wait = false;
  first_param_idx = [];
  
  % initialize empty cpstruct
  cpstruct = struct('inputPoints',{},...
                    'basePoints',{},...
                    'inputBasePairs',{},...
                    'ids',{},...
                    'inputIdPairs',{},...
                    'baseIdPairs',{},...
                    'isInputPredicted',{},...
                    'isBasePredicted',{});

  iptchecknargin(2,6,nargin,mfilename); 

  input = parseImage(varargin{1});
  base = parseImage(varargin{2});
  
  switch nargin
   case 2
    % CPSTRUCT = CPSELECT(INPUT,BASE)
    return;
    
   case 3
    % CPSTRUCT = CPSELECT(INPUT,BASE,CPSTRUCT)

    % TO DO: add more validation on cpstruct
    if iscpstruct(varargin{3})
      cpstruct = varargin{3};
    else
      eid = sprintf('Images:%s:CPSTRUCTMustBeStruct',mfilename);
      error(eid,'%s: CPSTRUCT must be a structure.',upper(mfilename));
    end
    
   case 4
    
    if ischar(varargin{3})
      first_param_idx = 3;
    else
      
      % CPSTRUCT = CPSELECT(INPUT,BASE,XYINPUT_IN,XYINPUT_OUT)    
      cpstruct = loadAndValidatePoints(varargin{3:4});
      
    end
    
  otherwise  
    
    if ischar(varargin{5})
      first_param_idx = 5;
      
      % CPSTRUCT = CPSELECT(INPUT,BASE,XYINPUT_IN,XYINPUT_OUT,PARAM,VAL,...)    
      cpstruct = loadAndValidatePoints(varargin{3:4});
      
    else
      eid = sprintf('Images:%s:expected5thArgString',mfilename);      
      error(eid,'%s: Expected fifth input argument to be a string.',upper(mfilename))
      
    end
      
  end

  if ~isempty(first_param_idx)
    %parse param name/value pairs
    valid_params = {'Wait'};
    args = parseParamValuePairs(varargin(first_param_idx:end),valid_params,...
                                first_param_idx-1,...
                                mfilename);
  end
  
end

%--------------------------------------------------------------
function cpstruct = loadAndValidatePoints(xyinput_in,xybase_in)
  
  iptcheckinput(xyinput_in,{'double'},...
                {'real','nonsparse','finite','2d','nonempty'},...
                mfilename,'XYINPUT_IN',3);
  iptcheckinput(xybase_in, {'double'},...
                {'real','nonsparse','finite','2d','nonempty'},...
                mfilename,'XYBASE_IN',4);
      
  eid = sprintf('Images:%s:expectedMby2',mfilename);
      
  if size(xyinput_in,1) ~= size(xybase_in,1) || ...
        size(xyinput_in,2) ~= 2 || size(xybase_in,2) ~= 2  
    error(eid,'%s: XYINPUT_IN and XYBASE_IN must be M-by-2.',upper(mfilename));
  end
      
  cpstruct = xy2cpstruct(xyinput_in,xybase_in);

end
    
%------------------------------------------------------------------------
function args = parseParamValuePairs(in,valid_params,num_pre_param_args,...
                                     function_name)

  if rem(length(in),2)~=0
    eid = sprintf('Images:%s:oddNumberArgs',function_name);
    error(eid,...
          'Function %s expected an even number of parameter/value arguments.',...
          upper(function_name));
  end    

  for k = 1:2:length(in)
    prop_string = iptcheckstrs(in{k}, valid_params, function_name,...
                               'PARAM', num_pre_param_args + k);
    
    switch prop_string
     case 'Wait'
      iptcheckinput(in{k+1}, {'logical'},...
                    {'scalar'}, ...
                    mfilename, 'WAIT', num_pre_param_args+k+1);
      args.(prop_string) = in{k+1};
      
     otherwise
      eid = sprintf('Images:%s:unrecognizedParameter',function_name);
      error(eid,'%s','The parameter, %s, is not recognized by %s',...
            prop_string,function_name);
      
    end
  end

end

%-------------------------------
function [img] = parseImage(arg)

img = []; %#ok<NASGU>

if ischar(arg)
    try 
        info = imfinfo(arg);
        if strncmp(info.ColorType,'indexed',length(info.ColorType))
            eid = sprintf('Images:%s:imageMustBeGrayscale',mfilename);
            error(eid,'%s: %s must be a grayscale image.',upper(mfilename),arg);
        end
        img = imread(arg);
    catch m_exception
        eid = sprintf('Images:%s:imageNotValid',mfilename);
        error(eid,'%s: %s must be a valid image file.',upper(mfilename),arg);
    end
else 
    img = arg;
end

end

%----------------------------------------------------
function cpstruct = xy2cpstruct(xyinput_in,xybase_in)

% Create a cpstruct given two lists of equal numbers of points.

M = size(xyinput_in,1);
ids = (0:M-1)';
isPredicted = zeros(M,1);

% assign fields to cpstruct
cpstruct.inputPoints = xyinput_in;
cpstruct.basePoints = xybase_in;
cpstruct.inputBasePairs = bsxfun(@plus, ones(size(ids,1), 2), ids);
cpstruct.ids = ids;
cpstruct.inputIdPairs = cpstruct.inputBasePairs;
cpstruct.baseIdPairs = cpstruct.inputBasePairs;
cpstruct.isInputPredicted = isPredicted;
cpstruct.isBasePredicted = isPredicted;

end

%------------------------------
function showCPSTHelp(varargin)

    topic = 'cpselect_gui';
    helpview([docroot '/toolbox/images/images.map'],topic);

end    

%-------------------------------------------
function buttons = makePointButtons(toolbar)

  % Common properties
  s.toolConstructor            = @uitoggletool;
  s.properties.Parent          = toolbar;
  s.iconConstructor            = @makeToolbarIconFromPNG;
  s.iconRoot                   = ipticondir;    
  
  % Add points
  s.icon                       = 'point.png';
  s.properties.TooltipString   = 'Add points';
  s.properties.Tag             = lower(s.properties.TooltipString);    
  buttons.addPoint             = makeToolbarItem(s);
  
  % Add points and predict matches
  s.icon                       = 'point_predicted.png';
  s.properties.TooltipString   = 'Add points and predict matches';
  s.properties.Tag             = lower(s.properties.TooltipString);    
  buttons.addPredict           = makeToolbarItem(s);

end

%------------------------------------
function initPos = getInitialPosition
    
    wa = getWorkArea();
    
    % Specify fraction of work area to fill
    SCALE = 0.8; 
            
    w = SCALE*wa.width;
    h = SCALE*wa.height;
    x = wa.left + (wa.width - w)/2;
    y = wa.bottom + (wa.height - h)/2; 
    
    initPos = round([x y w h]);
    
end
