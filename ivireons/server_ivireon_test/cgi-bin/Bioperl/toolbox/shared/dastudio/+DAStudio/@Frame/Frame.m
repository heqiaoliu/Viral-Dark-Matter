classdef Frame < handle

    % Copyright 2007 The Mathworks, Inc

    properties
        FrameFile = '';
        FrameInfo = [];
    end

    methods
        function this = Frame(varargin)
            for i = 1:2:nargin
                this.(varargin{i}) = varargin{i+1};
            end
        end

        function this = set.FrameFile(this, newFrameFile)
            this.FrameFile = newFrameFile;
            this.FrameInfo = [];
        end

        function FrameInfo = get.FrameInfo(this)

            if ~isempty(this.FrameInfo)
                FrameInfo = this.FrameInfo;
                return
            end
            
            if ~isempty(this.FrameFile)
                % rectangle and frame information
                emptySys = get_param(new_system, 'Object');
                tmpPortal = Portal.Portal;
                tmpPortal.targetObject = emptySys;
                [sysFrameRect, renderframeinfo] = render(this, tmpPortal);
                close_system(emptySys.Handle, 0); % cleanup

                % Get image size
                imgSize.width     = tmpPortal.size.x;
                imgSize.height    = tmpPortal.size.y;

                % Note: sysFrameRect = [left, top, width, height]; in pixels
                tmpMargins.top    = sysFrameRect(2);
                tmpMargins.left   = sysFrameRect(1);
                tmpMargins.bottom = imgSize.height - (sysFrameRect(2) + sysFrameRect(4));
                tmpMargins.right  = imgSize.width  - (sysFrameRect(1) + sysFrameRect(3));

                % Calculate frame size, do not include "paper margins"
                frameSize.top    = tmpMargins.top    - renderframeinfo.margins.top;
                frameSize.left   = tmpMargins.left   - renderframeinfo.margins.left;
                frameSize.bottom = tmpMargins.bottom - renderframeinfo.margins.bottom;
                frameSize.right  = tmpMargins.right  - renderframeinfo.margins.right;

                % Get source size
                srcSize.width  = imgSize.width  - tmpMargins.left - tmpMargins.right;
                srcSize.height = imgSize.height - tmpMargins.top  - tmpMargins.bottom;

                % Variable, this is the frame.  Size is dependent on the source size.
                FrameInfo.Frame.top    = frameSize.top    / srcSize.height;
                FrameInfo.Frame.left   = frameSize.left   / srcSize.width;
                FrameInfo.Frame.bottom = frameSize.bottom / srcSize.height;
                FrameInfo.Frame.right  = frameSize.right  / srcSize.width;

                % Fixed, this is the paper margin
                FrameInfo.PaperMargin = renderframeinfo.margins;

            else
                noMargins.top    = 0;
                noMargins.left   = 0;
                noMargins.bottom = 0;
                noMargins.right  = 0;

                FrameInfo.PaperMargin = noMargins;
                FrameInfo.Frame       = noMargins;
            end

        end

        function [sysFrameRect, renderframeinfo] = render(this, portal, margins)

            treatPointsAsPixels = false;
            
            renderframeinfo = renderframe('initialize', ...
                this.FrameFile, ...
                1, ...
                treatPointsAsPixels);
            
            [null null sysFrameRect] = renderframe('render', ...
                portal.targetObject, ...
                portal);
            renderframe('reset');

            if (nargin > 2)
                portal.minimumMargins.clear;
                portal.minimumMargins.top    = margins.top;
                portal.minimumMargins.left   = margins.left;
                portal.minimumMargins.bottom = margins.bottom;
                portal.minimumMargins.right  = margins.right;
            end
            
        end

    end
end