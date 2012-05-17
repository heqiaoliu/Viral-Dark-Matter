classdef ImageProfilePanel < handle
    % This undocumented class may be removed in a future release.
    
    % obj = imageProfilePanel(h_parent,h_im,init_roi_pos,roi_geometry,method,num_samples)
    % creates an image profile panel object. H_PARENT is the parent of the
    % profile panel. H_IM is the handle of the target image. INIT_ROI_POS
    % is the initial position of the ROI if it was specified, otherwise
    % INIT_ROI_POS is empty. ROI_GEOMETRY is a string that specifies the
    % geometry of the ROI to be used in defining the profile. METHOD is a
    % string that specifies the interpolation method to use. NUM_SAMPLES is
    % the number of samples to use along the ROI in computing the profile.
    % NUM_SAMPLES is empty if not specified.
    
    %   Copyright 2008 The MathWorks, Inc.
    %   $Revision: 1.1.6.2 $ $Date: 2008/12/22 23:47:35 $
    
    properties (SetAccess = 'private', GetAccess = 'public')
        
        h_panel
        h_bottom_panel
        h_bottom_axes
        
        h_start_button
        h_rotate_button
        h_button_panel
        
        h_profile_axes
        h_profile_axes_panel
        
        h_blue_line
        h_green_line
        h_red_line
        
        h_image_ax
        h_im
        h_roi
        
        roi_geometry
        interp_method
        init_roi_pos
        num_samples
        
        initial_text_string
        h_bottom_text
        
    end
    
    methods
        
        function obj = ImageProfilePanel(h_parent,h_im,init_roi_pos,roi_geometry,method,num_samples)
            
            obj.h_im = h_im;
            obj.h_image_ax = ancestor(h_im,'axes');
            
            obj.h_panel = uipanel('Parent',h_parent,...
                'BorderType','none');
            
            obj.h_profile_axes_panel = uipanel('Parent',obj.h_panel,...
                'Units','normalized',...
                'Position',[0 .1 .9 .9]);
            
            obj.h_button_panel = uipanel('Parent',obj.h_panel,...
                'Units','Normalized',...
                'Position',[.9 0 .1 1],...
                'ResizeFcn',@(varargin) obj.layoutButtonPanel(),...
                'BorderType','None');
                                    
            obj.h_start_button = uicontrol('Style','PushButton',...
                'Parent',obj.h_button_panel,...
                'Units','Pixels',...
                'Position',[5 200 30 30],...
                'Callback',@(h_button,ed) obj.startProfile(),...
                'Tag','profile button',...
                'TooltipString','Create Profile');
            
            obj.h_rotate_button = uicontrol('Style','ToggleButton',...
                'Parent',obj.h_button_panel,...
                'Units','Pixels',...
                'Enable','off',...
                'Position',[5 0 30 30],...
                'Callback',@(h_button,ed) obj.rotateProfileView(),...
                'Tag','rotate button',...
                'TooltipString','Rotate View');
            
            obj.h_profile_axes = axes('Parent',obj.h_profile_axes_panel,...
                'OuterPosition',[0 0 1 1],...
                'DeleteFcn',@(varargin) obj.deleteTool(),...
                'Tag','profile axes');
            
            obj.h_blue_line = line('Parent',obj.h_profile_axes,...
                'Visible','off',...
                'Color','blue',...
                'Tag','blue profile line');
            
            obj.h_green_line = line('Parent',obj.h_profile_axes,...
                'Visible','off',...
                'Color','green',...
                'Tag','green profile line');
            
            obj.h_red_line = line('Parent',obj.h_profile_axes,...
                'Visible','off',...
                'Color','red',...
                'Tag','red profile line');
            
            obj.initial_text_string = 'Click on profile button to create image profile.';
            
            obj.h_bottom_panel = uipanel('Parent',obj.h_panel,...
                'Units','Normalized',...
                'Position',[0 0 1 .1],...
                'BorderType','None');
                                    
            obj.h_bottom_text = uicontrol('parent', obj.h_bottom_panel,...
                                    'units', 'normalized', ...
                                    'tag', 'profile instructions text',...
                                    'style', 'text', ...
                                    'HorizontalAlignment', 'left', ...
                                    'String', obj.initial_text_string,...
                                    'Position',[0.01 0 1 1]);

           
            obj.roi_geometry = roi_geometry;
            obj.interp_method = method;
            obj.init_roi_pos = init_roi_pos;
            obj.num_samples = num_samples;
            
            rotate_icon = load(fullfile(matlabroot,'toolbox','matlab','icons','rotate.mat'));
            profile_icon = imread(fullfile(matlabroot,'toolbox','images','icons','profile.png'));
            
            set(obj.h_rotate_button,'CData',rotate_icon.cdata);
            set(obj.h_start_button,'CData',profile_icon);
            
            % Initialize position of buttons on button panel;
            obj.layoutButtonPanel();
            
            initial_position_specified = ~isempty(obj.init_roi_pos);
            if initial_position_specified
                obj.startProfile()
            end
            
        end
        
    end
    
    methods (Access = 'private')
        
        function deleteTool(obj)
            % Delete ROI if associated profile axes is destroyed.
            
            if (~isempty(obj.h_roi) && isvalid(obj.h_roi))
                delete(obj.h_roi);
            end
            
        end
        
        function layoutButtonPanel(obj)
            
            panel_pos_pixels = getpixelposition(obj.h_button_panel);
            panel_height = panel_pos_pixels(4);
            button_pos = get(obj.h_rotate_button,'Position');
            button_size = button_pos(3:4);
            
            buffer = 5;
            start_button_y = panel_height - buffer - button_size(2);
            
            rotate_button_y = start_button_y - buffer - button_size(2);
            
            set(obj.h_start_button,'Position',[buffer start_button_y button_size]);
            set(obj.h_rotate_button,'Position',[buffer rotate_button_y button_size]);
            
        end
        
        function rotateProfileView(obj)
            
            rotate3d(obj.h_profile_axes);
            
        end
                
        function TF = is3DProfile(obj)
            
            TF = size(obj.h_roi.getPosition(),1) > 2;
            
        end
        
        function TF = isRGBProfile(obj)
            
            TF = ndims(get(obj.h_im,'CData')) > 2;
            
        end
        
        function startProfile(obj)
            
            % If we are re-drawing profile, don't want rotate button to get
            % out of sync with actual rotate mode of profile axes. Pop
            % toggle button into "up" state each time profile is redrawn.
            set(obj.h_rotate_button,'Value',false);
            rotate3d(obj.h_profile_axes,'off');
            
            % Disable profile button until initial placement is finished.
            set(obj.h_start_button,'Enable','off');
            set(obj.h_rotate_button,'Enable','off');
            
            h_old_roi = findall(obj.h_image_ax,'tag','imline','-or',...
                'tag','imfreehand','-or',...
                'tag','impoly');
            
            if ~isempty(h_old_roi)
                % In this codepath, the user is hitting the start placement
                % button and has already previously positioned an ROI. We
                % want to delete the previous ROI and begin interactive
                % placement of another ROI.
                delete(h_old_roi);
                obj.init_roi_pos = [];
            end
            
            set([obj.h_red_line,obj.h_blue_line,obj.h_green_line],...
                'Visible','off');
            view(obj.h_profile_axes,2);
            
            set(obj.h_bottom_text,'String','Click on image to start profiling.');
            
            switch (obj.roi_geometry)
                case 'line'
                    fcn = makeConstrainToRectFcn('imline',...
                        get(obj.h_image_ax,'XLim'),...
                        get(obj.h_image_ax,'YLim'));
                    obj.h_roi = imline(obj.h_image_ax,obj.init_roi_pos,'PositionConstraintFcn',fcn);
                case 'polyline'
                    fcn = makeConstrainToRectFcn('impoly',...
                        get(obj.h_image_ax,'XLim'),...
                        get(obj.h_image_ax,'YLim'));
                    obj.h_roi = impoly(obj.h_image_ax,obj.init_roi_pos,'Closed',false,'PositionConstraintFcn',fcn);
                case 'freehand'
                    fcn = makeConstrainToRectFcn('imfreehand',...
                        get(obj.h_image_ax,'XLim'),...
                        get(obj.h_image_ax,'YLim'));
                    obj.h_roi = imfreehand(obj.h_image_ax,'Closed',false,'PositionConstraintFcn',fcn);
                otherwise
                    % This code path is not possible, inputParser prevents
                    % bad input.
            end
            
            % If user closed parent figure during placement, h_bottom_text
            % and h_start_button may have been destroyed and may no longer
            % be valid handles.
            if ishghandle(obj.h_bottom_text)
                set(obj.h_bottom_text,'String',obj.initial_text_string);
            end
            
            if ishghandle(obj.h_start_button)
                set(obj.h_start_button,'Enable','on');
            end
            
            % User aborted placement of ROI, don't continue setting up
            % aspects of GUI that depend on ROI.
            if ~isempty(obj.h_roi)
                % Allow profile display to live update as ROI is moved.
                obj.h_roi.addNewPositionCallback(@(pos) obj.roiPositionChanged());
                
                set(obj.h_blue_line,'Visible','on');
                if obj.isRGBProfile()
                    set([obj.h_green_line,obj.h_red_line],'Visible','on');
                end
                
                if obj.is3DProfile()
                    set(obj.h_rotate_button,'Enable','on');
                end
                
                % Initialize profile plot with current position of ROI
                obj.roiPositionChanged();
                
            end
            
        end
        
        function setAxesLimits(obj)
            
            % Set limits of intensity axes to min/max of data range of
            % target image.
            im_data = get(obj.h_im,'CData');
            min_intensity = min(im_data(:));
            max_intensity = max(im_data(:));

            % If image is uniform, slightly adjust axes around data to
            % ensure that 'YLim' or 'ZLim' of axes is increasing. HG
            % requires increasing axes limits.
            if min_intensity == max_intensity
                min_intensity = min_intensity - eps;
                max_intensity = max_intensity + eps;
            end
            
            intensity_limits = [min_intensity max_intensity];
            
            if obj.is3DProfile()
                set(obj.h_profile_axes,...
                    'YLimMode','auto',...
                    'ZLimMode','manual',...
                    'ZLim',intensity_limits);
            else
                set(obj.h_profile_axes,...
                    'YLimMode','manual',...
                    'YLim',intensity_limits,...
                    'ZLimMode','auto');
            end
            
        end
        
        function setCurrentView(obj)
            
            obj.setAxesLimits();
            if obj.is3DProfile()
                view(obj.h_profile_axes,3)
                set(obj.h_rotate_button,'Enable','on');
                set(get(obj.h_profile_axes,'XLabel'),'String','X');
                set(get(obj.h_profile_axes,'YLabel'),'String','Y');
            else
                view(obj.h_profile_axes,2);
                set(obj.h_rotate_button,'Enable','off');
                set(get(obj.h_profile_axes,'XLabel'),'String','Distance Along Profile');
            end
            
        end
        
        function roiPositionChanged(obj)
            
            [cx,cy,c] = obj.computeProfile();
            lines = [obj.h_red_line,obj.h_green_line,obj.h_blue_line];
            
            obj.setCurrentView();
            
            if obj.isRGBProfile()
                for i = 1:3
                    if obj.is3DProfile()
                        set(lines(i),'XData',cx,'YData',cy,'ZData',c(:,:,i));
                    else
                        set(lines(i),'XData',hypot(cx-cx(1),cy-cy(1)),'YData',c(:,:,i),'ZData',[]);
                    end
                end
            else % Non-RGB images
                
                if obj.is3DProfile()
                    set(obj.h_blue_line,'XData',cx,'YData',cy,'ZData',c);
                else
                    set(obj.h_blue_line,'XData',hypot(cx-cx(1),cy-cy(1)),'YData',c,'ZData',[]);
                end
                
            end
              
        end
        
    end
    
    methods (Hidden = true)
        
        % computeProfile is public but hidden so that the ImageProfile
        % object can update itself based on the current state of the
        % profile ROI.
        function [cx,cy,c] = computeProfile(obj)
            
            pos = obj.h_roi.getPosition();
            x = pos(:,1)';
            y = pos(:,2)';
            
            x_data = get(obj.h_im,'XData');
            y_data = get(obj.h_im,'YData');
            
            num_samples_specified = ~isempty(obj.num_samples);
            if num_samples_specified
                [cx,cy,c] = improfile(x_data,y_data,get(obj.h_im,'CData'),x,y,obj.num_samples,obj.interp_method);
            else
                [cx,cy,c] = improfile(x_data,y_data,get(obj.h_im,'CData'),x,y,obj.interp_method);
            end
            
        end
        
    end
    
end