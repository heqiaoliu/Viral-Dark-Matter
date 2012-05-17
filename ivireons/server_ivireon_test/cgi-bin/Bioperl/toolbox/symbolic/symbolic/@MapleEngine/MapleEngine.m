classdef MapleEngine < handle
    %MapleEngine Maple symbolic engine
    %   The MapleEngine class is the interface to the Maple symbolic engine
    %   used by the SYM class. Use the SYMENGINE function to obtain the active
    %   engine.
    %
    %   Example:
    %      eng = symengine;


    %   Copyright 2008 The MathWorks, Inc.

    properties
        kind = 'maple';
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
            error('symbolic:MapleEngine:UnsupportedOperation',...
                'The method ''%s'' is not supported by the MapleEngine class.',op);
        end
    end

    methods

    function eng=MapleEngine()
    %MapleEngine Constructor
    %   The MapleEngine constructor should not be called by users.
    %   Call SYMENGINE to obtain the active engine.
        
        mapleengine('init');
    end

    function delete(engine) %#ok<MANU>
        mapleengine('delete');
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

            %   shows MuPAD doc because the links from MATLAB's doc
            %   use symengine.

        engine = mupadengine(false);
        doc(engine,topic);
    end        
    
        function reset(engine) %#ok<MANU>
            %RESET Reset Maple engine
            %   RESET(ENGINE) restarts the Maple symbolic engine. All sym
            %   objects should be cleared and recomputed.
            %
            %   Example:
            %   reset(symengine)
            %
            %   See also: symengine
            
            mapleengine('reset');
        end
        
        function disp(engine) %#ok<MANU>
        disp('Maple gateway symbolic engine');
    end
    end
end
