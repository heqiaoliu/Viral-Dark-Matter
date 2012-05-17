classdef mupad < handle
    %MUPAD Start MuPAD notebook interface
    %    NB = MUPAD opens a new blank MuPAD notebook and returns an object
    %    representing the notebook. A MuPAD notebook is a convenient environment
    %    for performing computations symbolically using the MuPAD language and
    %    documenting the results.
    %    NB = MUPAD(FILE) opens the notebook with file name FILE.
    %
    %    See also: sym, setVar, getVar
    
    %    Copyright 2008-2010 The MathWorks, Inc.
    
    properties(GetAccess='private',SetAccess='private')
        name = '';
        tmpfile = '';
    end
    methods(Hidden=true)
        function addlistener(obj,varargin)
            notUsed(obj,'addlistener');
        end
        function y=gt(obj,b) %#ok<STOUT,INUSD>
            notUsed(obj,'gt');
        end
        function y=ge(obj,b) %#ok<STOUT,INUSD>
            notUsed(obj,'ge');
        end
        function y=le(obj,b) %#ok<STOUT,INUSD>
            notUsed(obj,'le');
        end
        function y=lt(obj,b) %#ok<STOUT,INUSD>
            notUsed(obj,'lt');
        end
        function y=findobj(obj,varargin) %#ok<STOUT>
            notUsed(obj,'findobj');
        end
        function y=findprop(obj,varargin) %#ok<STOUT>
            notUsed(obj,'findprop');
        end
        function y=notify(obj,varargin) %#ok<STOUT>
            notUsed(obj,'notify');
        end
        function notUsed(obj,op) %#ok<MANU>
            error('symbolic:mupad:UnsupportedOperation',...
                'The method ''%s'' is not supported by the MUPAD class.',op);
        end
    end
    methods
        function nb = mupad(file)
            
            oldlist = getappdata(0,'SymbolicMuPADNotebooks');
            hndl = tempname;
            nb.tmpfile = hndl;
            [~,hndl] = fileparts(hndl);
            nb.name = hndl;
            if nargin == 0
                cmd = ['-handle ' hndl ...
                       ' -eval-command ''write("' nb.tmpfile '",x):''&'];
            else
                fbase = file;
                target = [strfind(file,'.mn#')  strfind(file,'.MN#')];
                if ~isempty(target)
                    fbase = file(1:(target(1)+2));
                end
                if ~exist(fbase,'file')
                    error('symbolic:mupad:InvalidFile',...
                          'File ''%s'' does not exist or cannot be opened.',fbase);
                end
                file = prependpwd(file);
                cmd = ['-handle ' hndl ' "' file '"&'];
            end
            symengine('call',cmd);
            % if specifying a file name to open MuPAD does not obey -eval-command so don't wait
            if nargin == 0 
                waitForFile(nb.tmpfile);
            end
            if isempty(oldlist)
                oldlist = nb;
                mupadshutdown; % register shutdown handler
                mlock;
            else
                oldlist(end+1) = nb;
            end
            setappdata(0,'SymbolicMuPADNotebooks',oldlist);
        end
        
        function setVar(nb,var,y)
            %setVar Assign variable in a notebook.
            %    setVar(NB,VAR,Y) assigns the sym object Y to variable VAR in the
            %    MuPAD notebook NB. VAR must be a valid variable name (see ISVARNAME).
            %    setVar(NB,Y) uses VAR=inputname(2) if the expression specifying Y
            %    is a simple unsubscripted variable name and VAR='ans' otherwise.
            %
            %    Example:
            %      syms x
            %      y = sin(x);
            %      setVar(nb,y)
            %      setVar(nb,'f',x^2+1)
            %
            %    See also: mupad, getVar, sym, isvarname, inputname
            
             error(nargchk(2,3,nargin,'struct'));
            if nargin == 2
                y = var;
                if ischar(y) && isvarname(y)
                    error('symbolic:mupad:setVar:MissingValue',...
                        'A value to assign must be specified.');
                end
                var = inputname(2);
                if isempty(var)
                    var = 'ans';
                end
            end
            if ~isvarname(var)
                error('symbolic:mupad:setVar:InvalidName',...
                    'Invalid variable name.');
            end
            % write value to temp file
            if ~isa(y,'sym')
                error('symbolic:mupad:setVar:InvalidValue',...
                    'The value to assign must be a sym object.');
            end
            cc = charcmd(y);
            if isequal(cc,var)
                error('symbolic:mupad:setVar:RecursiveAssignment',...
                    'Recursive assignment. Variables are symbolic by default in MuPAD.');
            end
            cmd = sprintf('%s := %s:', var, cc);
            evalin(symengine,cmd);
            for k = 1:numel(nb)
                nbk = nb(k);
                quietDelete(nbk.tmpfile);
                file = escape(nbk.tmpfile);
                feval(symengine,'write',['"' file '"'],var);
                readcmd = sprintf('read("%s"):',file);
                delcmd = sprintf('shell::removeFile("%s"):',file);
                % read value into MuPAD
                cmd = sprintf('-handle %s -eval-command ''%s%s''&',...
                              nbk.name, readcmd, delcmd);
                symengine('call',cmd);
                while exist(nbk.tmpfile,'file')
                    pause(.1)
                end
            end
            cmd = sprintf('delete %s', var);
            evalin(symengine,cmd);
        end
        
        function y = getVar(nb,var)
            %getVar Get a variable from a notebook.
            %    Y = getVar(NB,VAR) gets the variable VAR from notebook NB
            %    and returns the result as a sym object Y.
            %
            %    Example:
            %      f = getVar(nb,'f')
            %
            %    See also: mupad, setVar, sym
            
            error(nargchk(2,2,nargin,'struct'));
            if ~isscalar(nb)
                error('symbolic:mupad:getVar:MultiNotebook',...
                    'Cannot specify multiple notebooks simultaneously.');
            end
            if ~ischar(var) || ~isvarname(var)
                error('symbolic:mupad:getVar:VarName',...
                    'Second input must be a variable name.');
            end
            
            quietDelete(nb.tmpfile);
            donefile = [nb.tmpfile 'done'];
            writeCmd = sprintf('''fprint("%s",%s):write("%s",_unused):''',nb.tmpfile,var,donefile);
            cmd = ['-handle ' nb.name ' -eval-command ' writeCmd '&'];
            symengine('call',cmd);
            
            waitForFile(donefile);
            file = escape(nb.tmpfile);
            y = feval(symengine,'symobj::finput',['"' file '"']);
            pause(.1); % give minimum time to close donefile
            quietDelete(donefile);
        end
        
        function close(nb)
            %CLOSE Close a notebook
            %    CLOSE(NB) closes notebook NB
            %
            %    See also: mupad

            nb(~isvalid(nb)) = [];
            for k = 1:numel(nb)
                nbk = nb(k);
                if ~isempty(nbk.name)
                    quietDelete(nbk.tmpfile);
                    cmd = ['-close-handle ' nbk.name];
                    symengine('call',cmd);
                    appnb = getappdata(0,'SymbolicMuPADNotebooks');
                    if ~isempty(appnb)
                        appnb(appnb == nbk) = [];
                        setappdata(0,'SymbolicMuPADNotebooks',appnb);
                    end
                end
            end
        end
        
        function delete(nb)
            nb(~isvalid(nb)) = [];
            for k = 1:numel(nb)
                nbk = nb(k);
                quietDelete(nbk.tmpfile);
            end
        end
        
        function disp(nb) %#ok<MANU>
            disp('MuPAD notebook');
        end
        
    end
    
    methods(Static=true)
        function closeAllWindows
        %closeAllWindows Close all open notebooks
        %    closeAllWindows closes all MuPAD notebooks that were created
        %    using the mupad command.
        %
        %    See also: mupad
            
            nb = getappdata(0,'SymbolicMuPADNotebooks');
            if ~isempty(nb)
                rmappdata(0,'SymbolicMuPADNotebooks');
                close(nb);
            end
        end
    end
end

% replace \ with \\ while leaving \\ alone
function cmd = escape(cmd)
    cmd = strrep(cmd,'\','\\');
    cmd = strrep(cmd,'\\\\','\\');
end

% prepend the current directory if needed
function file = prependpwd(file)
    [p,f,ext] = fileparts(file);
    if isempty(p) || ~isfullpath(p)
        file = fullfile(pwd,file);
    end
end

% test for full path name
function isfull = isfullpath(p)
    if ispc
        p(p=='/') = '\';
        isfull = strncmp(p,'\\',2) || (length(p)>2 && strcmp(p(2:3),':\'));
    else
        isfull = p(1) == filesep;
    end
end

% delete file if it exists
function quietDelete(file)
    if exist(file,'file')
        delete(file);
    end
end

% wait for file to exist
function waitForFile(file)
    time = now;
    printedMessage = false;
    while ~exist(file,'file') 
        minutes = (now-time)*24*60;
        if minutes > 10 % ten minute timeout
            error('symbolic:mupad:MuPADTimeout','Timed out while waiting for MuPAD to respond.');
        elseif minutes > .5 && ~printedMessage
            fprintf('Starting MuPAD...');
            printedMessage = true;
        end
        pause(.1)
    end
end
