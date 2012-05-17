function cbinfo = getCallbackInfo()

    cbinfo = public();
    return;
    
    function state = getMenuState( tag )
        state = 'Enabled';
    end

    function raiseMenuGenerateEvent( tag )
        
    end

    function components = getDockComponents()
        components = {};
    end

    function components = getTabComponents()
        components = {};
    end

    function components = getStatusComponents()
        components = {};
    end
    
    function checked = getMenuChecked( tag )
        checked = false;
    end

    function interfaces = getDIGInterfaces()
        % will want to return a list of MenuInterfaces
		mi.gatewayFile = 'studiotestprivate';
		mi.interfaceFile = 'testtreegetinterface';
		interfaces(1) = mi;
    end

    function interface = getMenuInterface()
        interface.interfaceFile = 'testGetInterface';
        interface.gatewayFile   = '';
    end

    function b = canCut()
        b = true;
    end

    function b = canCopy()
        b = true;
    end

    function b = canPaste()
        b = true;
    end

    function doCut()
        
    end

    function doCopy()
        
    end

    function doPaste()
        
    end

    function Undo()
    end

    function Redo()
    end

    function desc = UndoDescription()
        desc = 'This';
    end

    function desc = RedoDescription()
        desc = 'This';
    end

    function app = App()
        app = struct;
        
        app.canUndo = true;
        app.canRedo = true;
        app.undo    = @Undo;
        app.redo    = @Redo;
    end

    function o = public()
        o = struct;
        
        o.studio = struct;
        o.domain = struct;
        
        o.studio.getMenuState           = @getMenuState;
        o.studio.raiseMenuGenerateEvent = @raiseMenuGenerateEvent;
        o.studio.getDockComponents      = @getDockComponents;
        o.studio.getTabComponents       = @getTabComponents;
        o.studio.getStatusComponents    = @getStatusComponents;    
        o.studio.getMenuChecked         = @getMenuChecked;
        o.studio.getDIGInterfaces       = @getDIGInterfaces;
        o.studio.canUndo                = true;
        o.studio.canRedo                = true;
        o.studio.undo                   = @Undo;
        o.studio.redo                   = @Redo;
        o.studio.undoDescription        = 'This';
        o.studio.redoDescription        = 'That';
        
        %o.studio.App                    = @App;
        
        o.domain.getMenuInterface       = @getMenuInterface;
        o.domain.canCut                 = canCut;
        o.domain.canCopy                = canCopy;
        o.domain.canPaste               = canPaste;
        o.domain.doCut                  = @doCut;
        o.domain.doCopy                 = @doCopy;
        o.domain.doPaste                = @doPaste;
    end
end

