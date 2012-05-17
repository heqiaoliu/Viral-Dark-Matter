function hout = associate(h, arrayh, hFig)
%ASSOCIATE Associate the graphical frames with the spec frame
%   ASSOCIATE(H, ARRAYH) Associate the graphical frames with the spec frame.
%   If the appropriate graphical frame is not in ARRAYH this method will
%   create the frame and pass it as an output.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $  $Date: 2005/06/16 08:38:56 $

% If the specs frame is not rendered it cannot hold another frame
if ~isrendered(h),
    error(generatemsgid('objectNotRendered'), ...
        'Only a rendered object can be associated with graphical components');
end

if nargin == 2, hFig = gcf; end

% Create the empty default hout vector.  hout is the vector of new frames.
hout   = [];
fnames = whichframes(h);
for i = 1:length(fnames)
    
    hframes = {};

    % If the frame is already in the container, skip it
    if isempty(findhandle(h, fnames{i})),

        % Find the specified frame from the vector provided
        hframe = findhandle(h, arrayh, fnames{i});
        if isempty(hframe),
            
            % If the frame was not found, feval its name, which is its constructor
            hframe = feval(fnames{i});
            
            % Since this frame is new, save it in the hout vector
            if isempty(hout),
                hout = hframe;
            else
                hout = [hout hframe];
            end
        end
        
        % hframes is the vector of all frames used (not just the new ones)
        hframes{i} = hframe;
    end
    hframes = [hframes{:}];
    
end

if ~isempty(hframes),
    addcomponent(h, hframes);
end

hframes = allchild(h);

% Make sure all the frames are rendered
for i = 1:length(hframes),
    if ~isrendered(hframes(i)),
        render(hframes(i), hFig);
    end
end

% Make sure that the GUI reflects the values from the container.
setGUIvals(h);

% [EOF]
