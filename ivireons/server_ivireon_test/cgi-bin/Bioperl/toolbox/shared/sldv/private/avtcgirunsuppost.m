function varargout = avtcgirunsuppost

% $Revision: 1.1.6.1 $ $Date: 2010/01/25 22:43:56 $
% Copyright 2005-2010 The MathWorks, Inc.

    [object,sourceVect,msgVect,msgidVect] = avtcgirunsupcollect('getall');                                            
    [objectDiag,sourceVectDiag,msgVectDiag,msgidVectDiag] = avtcgirunsupcollect('getallDiag');      
    
    r_object = [];
    r_sourceVect = {};
    r_msgVect = {};        
	r_msgidVect = {};
    
    jump = 0;
    if ~isempty(objectDiag) && ~isempty(msgVectDiag) && ~isempty(sourceVectDiag),
        n = length(objectDiag);
        
        I = find(objectDiag(1:(n-1))~=objectDiag(2:n));
        m = length(I);
        I(m+1) = n;
        
        base = 1;
        for i=1:m+1,
            r_object(i) = objectDiag(base);
            r_sourceVect(i) = sourceVectDiag(base);
            [r_msgVect{i}, ind] = unique(msgVectDiag(base:I(i)));
			r_msgidVect{i} = msgidVectDiag(base+ind-1);
            base = I(i)+1;
        end
        
        r_object = fliplr(r_object);
        r_sourceVect = fliplr(r_sourceVect);
        r_msgVect = fliplr(r_msgVect);
		r_msgidVect = fliplr(r_msgidVect);
        
        jump = m+1;
    end    
    
    if ~isempty(object) && ~isempty(msgVect) && ~isempty(sourceVect)
        warnings = strcmp(sourceVect, 'sldv_stubbed');
        wObjs = object(warnings);
        wMsgs = msgVect(warnings);
        wSrcs = sourceVect(warnings);
        wIds = msgidVect(warnings);
        eObjs = object(~warnings);
        eMsgs = msgVect(~warnings);
        eSrcs = sourceVect(~warnings);
        eIds = msgidVect(~warnings);
       
        n = length(wObjs);
        if n>0
            [s_object I] = sort(wObjs);
            s_sourceVect = wSrcs(I);
            s_msgVect = wMsgs(I);
            s_msgidVect = wIds(I);
            I = find(s_object(1:(n-1))~=s_object(2:n));
            m = length(I)+1;
            I(m) = n;
            base = 1;
            for i=1:m
                h = s_object(base);
                if ishandle(h)
                    r_msgVect{jump+i} = { s_msgVect{base} };
                    r_msgidVect{jump+i} = { s_msgidVect{base} };
                else % SF or EML, we can have several warning on the same obj
                    [r_msgVect{jump+i}, ind] = unique(s_msgVect(base:I(i)));
                    r_msgidVect{jump+i} = s_msgidVect(base+ind-1);
                end
                r_object(jump+i) = h;
                r_sourceVect(jump+i) = s_sourceVect(base);
                base = I(i)+1;
            end
            jump = jump+m;
        end
        
        n = length(eObjs);
        if n>0
            [s_object I] = sort(eObjs);
            s_sourceVect = eSrcs(I);
            s_msgVect = eMsgs(I);
            s_msgidVect = eIds(I);
            I = find(s_object(1:(n-1))~=s_object(2:n));
            m = length(I)+1;
            I(m) = n;
            base = 1;
            for i=1:m
                r_object(jump+i) = s_object(base);
                r_sourceVect(jump+i) = s_sourceVect(base);
                [r_msgVect{jump+i}, ind] = unique(s_msgVect(base:I(i)));
                r_msgidVect{jump+i} = s_msgidVect(base+ind-1);
                base = I(i)+1;
            end
        end
    end
    varargout(1) = {r_object};
    varargout(2) = {r_sourceVect};
    varargout(3) = {r_msgVect};        
	varargout(4) = {r_msgidVect};

% LocalWords:  getall sldv
