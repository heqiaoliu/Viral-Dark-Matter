function studio = genericStudio(varargin)

    %studio = DAS.Studio;
    %studio.initialize;
    %studio.createApplication('GenericM3I:StudioApp','GenericM3I');
    
    studio = DAS.Studio( GLUE2.GenericM3IStudioApp );
    studio.initialize;

    gs = studio.App;

    if(nargin >= 1) 
        in1 = varargin{1};
        if(ischar(in1)) 
            uri   = in1;
            gs.setMetaUri(uri);
        elseif(isa(in1, 'M3I.Model'))
            gs.addModel(in1);
        else 
            error('glue:studio:genericStudio:unknownArgument', 'unknown argument passed to genericStudio. falid arguments are filename:string or M3I.Model');
        end
    end    
    
    studio.show;
end
