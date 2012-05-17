function dialogKeyPress(this, ~, evnt)

%   Copyright 2010 The MathWorks, Inc.

    if (evnt.getKeyCode == java.awt.event.KeyEvent.VK_DELETE)        
            this.tableContextMenuCallback_delete();
    end
end