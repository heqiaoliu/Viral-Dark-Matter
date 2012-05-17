function setTitle(h, title)
%  SETTITLE
%  Sets the title of the Diagnostic Viewer window (i.e., the Model
%  Explorer instance that serves as the DV's window).
%
%  Copyright 1990-2008 The MathWorks, Inc.


  h.Title = title;
  if isa(h.Explorer, 'DAStudio.Explorer')
    h.Explorer.set('title', h.Title);
  end

end
  