classdef mupadengine < handle
    %MUPADENGINE MuPAD symbolic engine
    %   The MUPADENGINE class is the interface to the MuPAD symbolic engine
    %   used by the SYM class. Use the SYMENGINE function to obtain the active
    %   engine.
    %
    %   Example:
    %      eng = symengine;
    % 
    %   See also: symengine, mupadengine/feval, mupadengine/evalin, mupadengine/doc
    
    %   Copyright 2008-2009 The MathWorks, Inc.
    
    properties
        kind = 'mupad';
    end
    
    properties (GetAccess='private',SetAccess='private',Transient=true)
        cleanup = false;
    end
    
    
    methods(Hidden=true)
        function addlistener(obj)
            notUsed(obj,'addlistener');
        end
        function gt(obj)
            notUsed(obj,'gt');
        end
        function ge(obj)
            notUsed(obj,'ge');
        end
        function le(obj)
            notUsed(obj,'le');
        end
        function lt(obj)
            notUsed(obj,'lt');
        end
        function findobj(obj)
            notUsed(obj,'findobj');
        end
        function findprop(obj)
            notUsed(obj,'findprop');
        end
        function notify(obj)
            notUsed(obj,'notify');
        end
        function notUsed(obj,op) %#ok<MANU>
            error('symbolic:mupadengine:UnsupportedOperation',...
                'The method ''%s'' is not supported by the MUPADENGINE class.',op);
        end
    end
    
    methods
        
        function engine = mupadengine(cleanup)
            %MUPADENGINE Constructor
            %   The MUPADENGINE constructor should not be called by users.
            %   Call SYMENGINE to obtain the active engine.
            
            %   MUPADENGINE(CLEANUP) sets the cleanup state to true/false.
            if nargin ~= 1
                error('symbolic:mupadengine:DirectCall',...
                    'Call SYMENGINE to get a MUPADENGINE object.');
            end
            mlock;
            engine.cleanup = cleanup;
        end
        
        function delete(engine)
        if engine.cleanup && inmem('-isloaded','mupadmex')
            mupadmex(' ',6); % destroy the kernel process
        end
        end
        
        function [result,status] = evalin(engine,statement,outtype) %#ok<MANU,INUSD>
            %EVALIN Evaluate a MuPAD expression
            %   RESULT = EVALIN(ENGINE,EXPR) evaluates EXPR in the MuPAD
            %   engine ENGINE and returns the RESULT as a sym object. If
            %   the statement did not return a value the MuPAD null() value
            %   of type DOM_NULL is returned.
            %
            %   [RESULT,STATUS] = EVALIN(...) returns the error status
            %   in status and error message in RESULT if status is non-zero.
            %   If status is zero RESULT is a sym object and otherwise RESULT
            %   is a string.
            %
            %   Example:
            %   y = evalin(symengine,'k^2$k=1..5')
            %
            %   See also: symengine, mupadengine/feval
            
            %   EVALIN(...,'char') returns a char result instead of a sym object.

            if nargin == 3
                [res,status] = mupadmex(statement,0);
            else
                [res,status] = mupadmex(statement);
            end
            % Handle any error messages
            if status ~= 0 && nargout < 2
                error('symbolic:mupadengine:evalin:errmsg2',res);
            end
            % Handle statements
            if nargout > 0 || ~isa(res,'sym') || ~isNullObj(res)
                result = res; 
            end
        end
        
        function [S,err] = feval(engine,fcn,varargin)
            %FEVAL Evaluate a MuPAD function
            %   RESULT = FEVAL(ENGINE,FCN,x1,...,xn) evaluates the MuPAD function
            %   specified by FCN, which must be a function name or sym object, 
            %   at the given arguments x1,...,xn in the MuPAD engine ENGINE.
            %   The result is a sym object. Those x values that are not strings
            %   or sym objects are converted to sym objects.
            %
            %   [RESULT,STATUS] = FEVAL(ENGINE,FCN,...) returns the error status
            %   in status and error message in RESULT if status is non-zero.
            %   If status is zero RESULT is a sym object and otherwise RESULT
            %   is a string.
            %
            %   Example:
            %   syms x
            %   f = tan(x);
            %   g = feval(symengine,'rewrite',f,'sincos')
            %
            %   See also: symengine, mupadengine/evalin
            
            error(nargchk(2,inf,nargin,'struct'));
            if ~isa(fcn,'sym') && ~isfuncname(fcn)
                error('symbolic:mupadengine:feval:InvalidFunction',...
                      'Invalid function name ''%s''.',fcn);
            end
            [stmt,fcn2,args2] = feval2eval(fcn,varargin); %#ok extra args are for holding sym references
            [S,err] = evalin(engine,stmt);
            if nargout < 2 && err ~= 0
                if strfind(S,'Error: singularity')
                    S = nan;
                else
                    error('symbolic:mupadengine:feval:FevalError',S);
                end
            end
        end
        
        function trace(engine,onoff) %#ok<MANU>
            %TRACE Turn on MuPAD command tracing
            %    TRACE(ENGINE,'on') causes subsequent MuPAD commands and results to be printed.
            %    TRACE(ENGINE,'off') turns off this facility.
            %
            %    See also: symengine
            
            error(nargchk(2,2,nargin,'struct'));
            if ~any(strcmp(onoff,{'on','off'}))
                error('symbolic:mupadengine:trace:OnOff',...
                    'Trace value must be ''on'' or ''off''.');
            end
            mupadmex(onoff,5);
        end
        
        function doc(engine,topic) %#ok<MANU>
            %DOC Open MuPAD documentation
            %   DOC(ENGINE) opens the MuPAD Help browser.
            %   DOC(ENGINE,CMD) opens to the specified MuPAD command.
            %
            %   Example:
            %   doc(symengine,'int')
            %
            %   See also: symengine
            
            if nargin == 1
                topic = fullfile(mupadroot,'share','doc','en','getstarted.muphlp');
            end
            if strncmp(fliplr(topic),fliplr('.muphlp'),7)
                cmd = '-help-file';
            else
                cmd = '-help-command';
            end
            symengine('call',[ cmd ' "' topic '"&']);
        end
        
        function reset(engine) %#ok<MANU>
            %RESET Reset MuPAD engine
            %   RESET(ENGINE) restarts the MuPAD symbolic engine. All sym
            %   objects should be cleared and recomputed.
            %
            %   Example:
            %   reset(symengine)
            %
            %   See also: symengine
            
            if ispc
                clear mupadmex
            else
                mupadmex(' ',6);
            end
        end
        
        function disp(engine) %#ok<MANU>
            disp('MuPAD symbolic engine');
        end
        
        function collectGarbage(engine) %#ok<MANU>
            %collectGarbage Release unused memory in MuPAD
            %   collectGarbage(ENGINE) informs the MuPAD engine of results
            %   that are no longer needed by MATLAB. MuPAD may then reduce
            %   the amount of memory used by the process.
            %
            %   See also: symengine
            
            mupadmex(' ',2);
        end
    end
end

function ok = isfuncname(fcn)
% Return true if fcn is id or pkg::id
ok = false;
if ischar(fcn)
    fcn(fcn==':') = [];
    fcn(fcn=='_') = [];
    ok = isvarname(fcn);
end
end

function [statement,fcn2,args2] = feval2eval(fcn,args)
%FEVAL2EVAL Transform feval call into eval for mupadengine class
%   STMT = FEVAL2EVAL(FCN,ARGS) constructs the string FCN(ARGS{:}) to
%   evaluate in the symbolic engine.
fcn2 = fcn;   % to hold references
args2 = args; % to hold references
if ~ischar(fcn)
    if ~isa(fcn,'sym')
        fcn2 = sym(fcn);
    end
    statement = ['(' charcmd(fcn2) ')'];
else
    statement = fcn;
end
statement(end+1) = '(';
for k2 = 1:length(args)
    v = args{k2};
    if ~ischar(v)
        if ~isa(v,'sym')
            v = sym(v);
            args2{k2} = v;
        end
        v = charcmd(v);
    end
    statement = [statement v ','];
end
if statement(end)==','
    statement(end) = ')';
else
    statement(end+1) = ')';
end
end

function path = mupadroot
% mupadroot is one level up and over from mupadmex 
    mupmex = which('mupadmex');
    path = fileparts(mupmex);
    path = fullfile(path,'..','mupad');
end

