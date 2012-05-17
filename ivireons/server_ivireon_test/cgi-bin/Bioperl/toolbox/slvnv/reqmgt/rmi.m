function [varargout] = rmi(method, obj, varargin)
% RMI Requirements Management Interface API
%
%   RESULT = RMI(METHOD, OBJ) is the basic form of all Requirements
%   Management API calls.  METHOD is one of the methods defined below.  
%   OBJ is a Stateflow API object or the handle of a Simulink object.
%
%
% Query and modify requirement links:
%
%   Requirement links are represented in MATLAB in a structure
%   array with the following format:
%
%     REQLINKS(k).description - Requirement description (menu label)
%     REQLINKS(k).doc         - Document name
%     REQLINKS(k).id          - Location within the above document
%     REQLINKS(k).keywords    - User keywords (Tag on dialog)
%     REQLINKS(k).linked      - Indicates if the link should be reported
%     REQLINKS(k).reqsys      - Link type registration name 
%                               ('other' is used for built-ins)
%
%     The first character in the .id field has the special purpose of
%     defining the type of identifier in the rest of the field:
%
%     ? - Search text located somewhere in the document
%     @ - Named item such as a bookmark, function, or HTML anchor
%     # - Page number or item number  
%     > - Line number
%     $ - Sheet range for a spreadsheet
%
%     examples id fields:  #21 $A5 @my_item ?Text_to_find >3156
%
%   REQLINKS = RMI('createEmpty') returns an empty instance of the 
%   requirement links data structure. 
%
%   REQLINKS = RMI('get',OBJ) gets the requirement links for OBJ.
%
%   REQLINKS = RMI('get',OBJ, GRPIDX) gets the requirement links 
%   associated with group GRPIDX for the Signal Builder block OBJ.
%
%   RMI('set',OBJ,REQLINKS) sets the requirement links for OBJ.
%
%   RMI('set',OBJ,REQLINKS, GRPIDX) sets the requirement links 
%   associated with group GRPIDX for the Signal Builder block OBJ.
%
%   RMI('cat',OBJ,REQLINKS) appends REQLINKS to the end of the
%   existing array of requirement links OBJ.
%
%   CNT = RMI('count',OBJ) returns number of requirement links  
%   for OBJ
%
%   RMI('clearAll',OBJ) deletes all requirements links for OBJ.
%   RMI('clearAll',OBJ,'deep') deletes all requirements links in 
%   the model pointed by OBJ.
%
% Navigation and display configuration
%
%   CMDSTR = RMI('navCmd',OBJ) gets the MATLAB command string CMDSTR 
%   that is used to navigate to OBJ using a globally unique
%   identifier. (NOTE: The object OBJ must already have a globally
%   unique identifier)
%
%   [CMDSTR, TITLESTR] = RMI('navCmd',OBJ) gets the MATLAB command 
%   string as above and also returns a description string that can  
%   be embedded in an external document.
%
%   GUIDSTR = RMI('guidGet',OBJ) returns the globally unique 
%   identifier for OBJ.  If OBJ does not have an identifier one will
%   be created.
%
%   OBJ = RMI('guidLookup',MODELH,GUIDSTR) returns the object OBJ inside
%   model MODELH that has the globally unique identifier GUIDSTR.
%
%   RMI('highlightModel',OBJ) highlights objects in the parent model 
%   of OBJ that have linked requirements.
%
%   RMI('unhighlightModel',OBJ) removes highlighting of requirement 
%   objects.
%
%   RMI('view',OBJ,INDEX) navigate to the INDEX'th requirement of OBJ.
%
%   DIALOGH = RMI('edit',OBJ) open the requirements dialog for OBJ 
%   and return a handle to the dialog, DIALOGH.
%
%   RMI('objCopy',OBJ) copies the requirement and reset guid string
%
% Tool setup and management
%
%   RMI setup - setup the requirement management tool for this
%   machine.
%
%   RMI register LINKTYPENAME - Register the custom link type 
%   LINKTYPENAME.  
%
%   RMI unregister LINKTYPENAME - Remove the custom link type 
%   LINKTYPENAME from the registered list.  
%
%   RMI linktypeList - Display a list of the currently registered link
%   types. 
%
% Consistency checks
%
%   RMI('check',OBJ,FIELD,N) checks validity of the FIELD field of the
%   Nth requirement link of OBJ.
%
%   RMI('probe', OBJ) probes the model for presence of requirement types
%   Called from Model Advisor Pre-check actions to know which setup steps to run.
%   Returns: [has_doors_reqs, has_word_reqs, has_excel_reqs]
%
%   RMI('checkdoc', docName) - checks validity of Simulink reference
%   links in external documents like Microsoft Word and IBM Rational DOORS.
%   Returns a total number of detected problems. Generates an HTML report.
%   Adjusts broken references to provide information messages or fix-me
%   shortcuts.
% 
%   RMI('checkdoc') - as above, but will prompt for the document name.
%
%   Copyright 2003-2010 The MathWorks, Inc.

    persistent  initialized;
    persistent  noinit_use;
    mlock;

    if isempty(initialized)
        initialized = false;
        noinit_use = {'guidGet', 'objCopy'};
    end

    if ~initialized && ...
            ~any(strcmpi(method, noinit_use)) 
        rmi.initialize();
        initialized = true;
    end
    
    % Cache variable argument size
    nvarargin = length(varargin);

    switch(lower(method))
    case 'init'
        % Do nothing

    case 'refresh'
        rmi.initialize();

    case 'ishandlevalid'
        if (isa(obj,'DAStudio.Object'))
            varargout{1} = obj.rmiIsSupported;
        else
            [~, objH, ~] = rmi.resolveobj(obj);
            varargout{1} = ~isempty(objH);
        end

    case 'getmodelh'
        varargout{1} = [];
        if (~isempty(obj))
            varargout{1} = rmisl.getmodelh(obj(1));
        end

    case 'guidlookup'
        varargout{1} = rmisl.guidlookup(obj,varargin{1});

    case 'guidget'
        varargout{1} = rmi.guidGet(obj);
        
    case 'hasrequirements'
        switch nvarargin
            case 0
                varargout{1} = rmi.objHasReqs(obj, []); 
            case 1
                varargout{1} = rmi.objHasReqs(obj, varargin{1}); 
            otherwise
                varargout{1} = rmi.objHasReqs(obj, varargin{1}, varargin{2}); 
        end

    case 'get'
        varargout{1} = rmi.getReqs(obj, varargin{:});

    case 'set'
        rmi.setReqs(obj, varargin{:});

    case 'move'
        rmi.moveReqs(obj, varargin{1});

    case 'cat'
        switch nvarargin
            case 1
                reqs = varargin{1};
            otherwise
                error('SLVNV:rmi:InvalidArgumentNumber','Invalid number of arguments ');
        end

        % Append requirements
        varargout{1} = rmi.catReqs(obj, reqs);

    case 'catempty'
        switch nvarargin
        case 0
            count = 1;
        case 1
            count = varargin{1};
        otherwise
            error('SLVNV:rmi:InvalidArgumentNumber','Invalid number of arguments ');
        end;

        % Append empty requirements
        emptyReqs = rmi.createEmptyReqs(count);
        varargout{1} = rmi.catReqs(obj, emptyReqs);

    case 'createempty'
        switch nvarargin
        case 0
            count = 1;
        case 1
            count = varargin{1};
        otherwise
            error('SLVNV:rmi:InvalidArgumentNumber','Invalid number of arguments ');
        end;

        % Append empty requirements
        varargout{1} = rmi.createEmptyReqs(count);

    case 'clearall'
        if nvarargin >= 1
            if strcmpi(varargin{1},'deep')
                rmi.modelClearAll(obj);
                return;
            end
        end
        % Delete all requirements
        rmi.clearAll(obj);

    case 'delete'
        switch nvarargin
        case 2
            index = varargin{1};
            count = varargin{2};
        otherwise
            error('SLVNV:rmi:InvalidArgumentNumber','Invalid number of arguments ');
        end;

        % Delete
        rmi.deleteReqs(obj, (index-1) + (1:count));

    case 'objcopy'
        rmi.objCopy(obj, varargin{:});
    
    case 'view'
        switch nvarargin
        case 0
            % Get requirements
            reqs = rmi.getReqs( obj);

            % If more than 1 requirement, bring up editor
            if length(reqs) > 1
                rmi.editReqs(obj);
            elseif length(reqs) == 1
                rmi.navigateToReq(obj, 1);
            end;

        case 1
            % Get index of requirement
            reqIndex = varargin{1};

            % Navigate to requirement
            rmi.navigateToReq(obj, reqIndex);

        otherwise
            error('SLVNV:rmi:InvalidArgumentNumber','Invalid number of arguments ');
        end;

    case 'edit'
        vars = varargin;
        if ischar(obj)
            if strncmp(obj,'rmimdladvobj',12)
                % We want to resolve the case rmimdladvobj
                % in that case, the arguments are quoted,
                % we eval them.  
                [isSf,obj,err] = rmi.resolveobj(obj); %#ok
                if isempty(obj)
                    error('SLVNV:rmi:InvalidReference','Invalid reference. Please rerun the Model Advisor');
                end
                for i=1:nvarargin
                    vars{i} = eval(vars{i});
                end
            end
        end
        varargout{1} = rmi.editReqs(obj, vars{:});

    case 'descriptions'
        [varargout{1}, varargout{2}] = rmi.getDescStrings(obj, varargin{:});

    case 'codecomment'
        % Return comment string
        varargout{1} = rmi.getCommentString(obj);

    case 'highlight'
        % Note that calling this directly will cause stale Explorer button
        % and tools->Requirements menu items, hence this is not published
        % in help list at the top.
        % Also, model handle is expected in 'obj'. This method is
        % internal use only and not meant to be fully foolproof.
        state = varargin{1};
        if strcmp(state, 'on')
            rmisl.highlight(obj);
        elseif strcmp(state, 'off')
            rmisl.unhighlight(obj);
        else
            error('rmi:highlight', 'Invalid option: %s', state);
        end
        
    case 'highlightmodel'
        modelH = rmisl.getmodelh(obj);
        set_param(modelH,'ReqHilite','on');
        % Note that we can not simply call local highlightModel(modelH),
        % because Simulink Editor needs to be notified that the model is
        % being RMI-highlighted.
        
    case 'getobjwithreqs'
        varargout{1} = rmisl.getObjWithReqs(obj);                
        
    case 'gethandleswithrequirements'
        [varargout{1}, varargout{2}] = rmisl.getHandlesWithRequirements(obj);

    case 'unhighlightmodel'
        modelH = rmisl.getmodelh(obj);
        set_param(modelH,'ReqHilite','off');
        % Note that we can not simply call local unhighlightModel(modelH),
        % because Simulink Editor needs to be notified that the model is
        % being unhighlighted.

    case 'permute'
        switch nvarargin
        case 1
            indices = varargin{1};
        otherwise
            error('SLVNV:rmi:InvalidArgumentNumber','Invalid number of arguments ');
        end;

        % Return permutation
        varargout{1} = rmi.permuteReqs(obj, indices);

    case 'count'
        varargout{1} = rmi.countReqs(obj);

    case 'doorssync'
        if reqmgtprivate('is_doors_running')
            rmi.doorssync(obj, varargin{:});
        end
        
    case 'report'
        rmi.reqReport(obj, varargin{:});

	case 'setup'
	    status = false; %#ok
        if ispc
            status = setup_actx();
            if status && is_doors_installed()
                status = setup_doors();
            end
        else
            disp('Setup is only needed for Windows machines');
	        status = true;
        end
        if nargout > 0
            varargout{1} = status;
        end

	case 'register'
	    if nargout
	        varargout{1} = rmi.registerLinktype(obj,varargin{:});
	    else
	        rmi.registerLinktype(obj,varargin{:});
	    end

	case 'unregister'
	    if nargout
	        varargout{1} = rmi.unregisterLinktype(obj,varargin{:});
	    else
	        rmi.unregisterLinktype(obj,varargin{:});
	    end
        
	case 'navcmd'
	    [navcmd, dispStr] = rmi.objinfo(obj);
	    varargout{1} = navcmd;
	    if nargout>1
	        varargout{2} = dispStr;
	    end

	case 'linktypelist'
	    varargout = cell(nargout,1);
	    [varargout{:}] = rmi.listLinkTypes;


    % Consistency checks
    case 'check'
        if nvarargin < 1
            error('SLVNV:rmi:InvalidArgumentNumber','Not enough arguments');
        end 
        if nvarargin > 1
            reqs = rmi.getReqs(obj,varargin{2},1);
        else
            reqs = rmi.getReqs(obj);
        end
        modelH = rmisl.getmodelh(obj);
        
        switch lower(varargin{1})
            case 'doc'
                for i=1:length(reqs)
                    status(i) = req_check_doc(reqs(i).reqsys, reqs(i).doc, modelH); %#ok<*AGROW>
                    varargout{1} = status;
                end
            case 'id'
                for i=1:length(reqs)
                    status(i) = req_check_id(reqs(i).reqsys, reqs(i).doc, reqs(i).id, modelH);
                    varargout{1} = status;
                end
            case 'description'
                desc = {};
                for i=1:length(reqs)
                    [status(i) desc{i}] = req_check_desc(reqs(i), modelH);
                end
                varargout{1} = status;
                varargout{2} = desc;
            case 'pathtype'
                new_path = {};
                for i=1:length(reqs)
                    [status(i) new_path{i}] = req_check_path(reqs(i).reqsys, reqs(i).doc, modelH);
                end
                varargout{1} = status;
                varargout{2} = new_path;
            case 'modeladvisor'
                if nvarargin > 1
                    error('SLVNV:rmi:InvalidArgumentNumber','Too many arguments');
                end 
                
                filterSettings = rmi.settings_mgr('get','filterSettings');
                if filterSettings.enabled && filterSettings.filterConsistency
                    reply = questdlg('User Tag filters active. Your results will be incomplete.', ...
                         'Requirements: Consistency Checking', ...
                         'Continue', 'Turn filters off', 'Cancel', 'Continue');
                     if isempty(reply)
                         reply = 'Continue';
                     end
                     if strcmp(reply, 'Turn filters off')
                         filterSettings.filterConsistency = false;
                         rmi.settings_mgr('set', 'filterSettings', filterSettings);
                     elseif strcmp(reply, 'Cancel')
                         return;
                     end
                end
                
                ma = Simulink.ModelAdvisor.getModelAdvisor(modelH, 'new');
                ma.TaskAdvisorRoot.changeSelectionStatus(false); %deselect all
                p=ma.getTaskObj('_SYSTEM_By Task_Requirement consistency checking');
                p.changeSelectionStatus(true);
                modeladvisor(modelH);
                me=ma.MAExplorer;
                imme = DAStudio.imExplorer(me);
                imme.collapseTreeNode(ma.TaskAdvisorCellArray{1});
                imme.selectTreeViewNode(p);
                imme.expandTreeNode(p);

            otherwise
                error('SLVNV:rmi:UnknownCheck','Unknown check');
        end

    case 'probe'
        modelH = rmisl.getmodelh(obj);
        [varargout{1}, varargout{2}, varargout{3}] = rmi.probeReqs(modelH);

    case 'setprop'
        % Setting the document can take as argument a single object, or
        % a cell array of objects, and a single requirement, or a 
        % cell array of cell array of objects.
        %
        % Setting the id, or label can only take a single object
        % and a single requirement.
        
        switch varargin{3}
            case 'doc'
                % Make obj a cellarray of handles
                % accepted inputs are: a single path, a single handle,
                % a cellarray of paths, and a cellarray of handles.
                if ~iscell(obj)
                    obj = { obj };
                end
                for i=1:length(obj)
                    [isSf, objH, errMsg] = rmi.resolveobj(obj{i}); %#ok
                    if ~isempty(objH)
                        obj{i} = objH;
                    end
                end
        
                % Make reqs_id a cellarray of cellarray of identifiers
                % Accepted syntax are: a single identifier, or a cellarray of
                % cellarray of identifiers
                if ~iscell(varargin{2})
                    reqs_id = { varargin(2) };
                else
                    reqs_id = varargin{2};
                end
        
                % Find the requirements
                for i=1:length(obj)
                    for j=1:length(reqs_id{i})
                        reqs{i}{j} = rmi.getReqs(obj{i},reqs_id{i}{j},1);
                    end
                end

                if nvarargin == 3
                    % Get the type of the document we are updating
                    [~,~,ext] = fileparts(reqs{1}{1}.doc);
            	    linkType = rmi.linktype_mgr('resolve', reqs{1}{1}.reqsys, ext);

                    % Note that empty linkType may indicate a totally
                    % invalid requirement. In this case we will also
                    % provide a FileChooser so that user can correct the entry.
                    if isempty(linkType) || linkType.IsFile
                        if isempty(linkType)
                            title = 'Locate target document';
                        else
	                    title = 'Locate substitute document';
                        end
	                    [filename,pathname,fid] =  uigetfile('*',title);
	                    if fid == 0 % User hit Cancel
	                        return;
	                    end
	                    modelH = rmisl.getmodelh(obj{1});
                        modelPath = get_param(modelH,'FileName');
                        currDir = pwd;
                        doc = selection_link_docpath([pathname filename], modelPath, currDir);
                    elseif ~isempty(linkType.BrowseFcn)
                        doc = strtrim(feval(linkType.BrowseFcn));
                        if isempty(doc)
                            return
                        end
                    end
                else
                    doc = modeladvisorprivate('HTMLjsencode', varargin{4}, 'decode');
                end
                % At the end, we update everybody with the new document
                for i=1:length(obj)
                    for j=1:length(reqs{i})
                        reqs{i}{j}.doc = doc;
                        rmi.setReqs(obj{i},reqs{i}{j},reqs_id{i}{j},1);
                    end
                end
                return;
                
            case 'id'
                if nvarargin ~= 4
                    error('SLVNV:rmi:InvalidArgumentNumber','Wrong number of arguments');
                end
                [isSf, objH, errMsg] = rmi.resolveobj(obj); %#ok
                if ~isempty(objH)
                    obj = objH;
                end
                req_id = varargin{2};
                req = rmi.getReqs(obj,req_id,1);
                req.id = modeladvisorprivate('HTMLjsencode', varargin{4}, 'decode');
                % save changes
                rmi.setReqs(obj,req,req_id,1);
                
            case 'description'
                h=[]; % May need a handle for "Please wait..."
                if (varargin{1})
                    h = msgbox('Updating link information', 'Please wait', 'modal');
                end

                if nvarargin ~= 4
                    warning('SLVNV:rmi:InvalidArgumentNumber','Possibly missing ''Description'' info.');
                    descr = '';
                else
                    descr = varargin{4};
                end
                [isSf, objH, errMsg] = rmi.resolveobj(obj); %#ok
                if ~isempty(objH)
                    obj = objH;
                end
                req_id = varargin{2};
                req = rmi.getReqs(obj,req_id,1);
                req.description = modeladvisorprivate('HTMLjsencode', descr, 'decode');
                % save changes:
                rmi.setReqs(obj,req,req_id,1);
                if (~isempty(h))
                    delete(h);
                end
            otherwise
                error('SLVNV:rmi:UnknownProperty','Unknown property');
        end
        
        
    case 'docs'
        % make sure the model is loaded
        load_system(obj);
        modelH = get_param(obj,'Handle');
        if isempty(varargin)
            % put together a cell array of unique document names
            varargout{1} = rmi.list_docs(modelH);
        else
            switch varargin{1}
                case { 'all', 'simulink', 'stateflow' }
                    % we want both list of docs and corresponding counters
                    [varargout{1}, varargout{2}, varargout{3}] = rmi.count_docs(modelH, varargin{1});
                otherwise
                    error('SLVNV:rmi:docs', ['Unknown option: ' varargin{1}]);
            end
        end
        
    case 'checkdoc'
        if nargin == 1  % doc name not supplied
            varargout{1} = rmiref.checkDoc();
        else
            docname = obj; % second arg is a filename or a DOORS module 
            varargout{1} = rmiref.checkDoc(docname);
        end
        
    otherwise
        error('SLVNV:rmi:UnknownMethod','Unknown Method');
    end
    
        
