function setPointer(this, pointerType)

    % Copyright 2010 The MathWorks, Inc.
    
    set(this.HDialog, 'Pointer', pointerType);
    drawnow;