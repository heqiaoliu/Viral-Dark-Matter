function helperSelectMATFile(this, fullPath)

    % Copyright 2010 The MathWorks, Inc.

    % This helper will be used from GUIMain to launch Import GUI with a 
    % particular MAT-file selected
    this.BaseWSOrMAT = 'mat';
    set(this.ImportFromMATEdit, 'String', fullPath);
    this.MATFileName = fullPath;
    this.callback_importRadio(this.ImportFromMATRadio,[]);
end