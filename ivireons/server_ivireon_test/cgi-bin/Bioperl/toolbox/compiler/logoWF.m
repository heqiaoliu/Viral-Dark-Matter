function wf = logoWF(varargin)
    evalc('logo');
    set(logoFig,'Visible','off'); 
    
    switch nargin
        case 3
            set(logoFig,'Color',[varargin{1} varargin{2} varargin{3}]);
    end
    
    wf = webfigure(logoFig);
    close(logoFig);
end

