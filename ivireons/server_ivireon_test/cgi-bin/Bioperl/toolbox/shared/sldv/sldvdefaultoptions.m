function opts = sldvdefaultoptions(obj)

%   Copyright 2009 The MathWorks, Inc.
    
    persistent sldvexist
    
    if isempty(sldvexist)
        sldvexist = license('test','Simulink_Design_Verifier') && exist('slavteng','file')==3;
    end

    if nargin<1 || ~sldvexist
        opts = Sldv.Options();
    else
        opts = sldvoptions(obj);
    end
end