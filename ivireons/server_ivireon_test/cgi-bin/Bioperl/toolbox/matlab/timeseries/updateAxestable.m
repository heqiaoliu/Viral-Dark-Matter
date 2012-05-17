function updateAxesTable(h,type,model,startRow,col)
%
% tstool utility function

%   Copyright 2005-2006 The MathWorks, Inc.

%% Callback for user edits the Axes Panel of the Property Editor
%% Update the @timeplot
switch col
    case 0
        if isa(h,'resppack.respplot')
            if strcmp(type,'X')
                h.InputName{startRow+1} = model.getValueAt(startRow,0); 
                % Manually update the axesgrid, since the AxesTable ViewChange listeners
                % may try to reset it before the @resplot/@waveplto listeners
                % can take affect.
                h.AxesGrid.ColumnLabel = h.InputName;
            elseif strcmp(type,'Y')
                h.OutputName{startRow+1} = model.getValueAt(startRow,0);
                % Manually update the axesgrid, since the AxesTable ViewChange listeners
                % may try to reset it before the @resplot/@waveplto listeners
                % can take affect.
                h.AxesGrid.RowLabel = h.OutputName;           
            end
        elseif isa(h,'wavepack.waveplot') && strcmp(type,'Y')
            h.ChannelName{startRow+1} = model.getValueAt(startRow,0);
            % Manually update the axesgrid, since the AxesTable ViewChange listeners
            % may try to reset it before the @resplot/@waveplto listeners
            % can take affect.
            h.AxesGrid.RowLabel = h.ChannelName;
        end
    case 1
        if strcmp(type,'Y')
            Ylimmode = h.Axesgrid.YlimMode;
            Ylimmode{startRow+1} = model.getValueAt(startRow,1);
            h.Axesgrid.YlimMode = Ylimmode;
        else
            Xlimmode = h.Axesgrid.XlimMode;
            Xlimmode{startRow+1} = model.getValueAt(startRow,1);
            h.Axesgrid.XlimMode = Xlimmode;
        end
    case {2,3}
        for r=1:2
            if ischar(model.getValueAt(startRow,1+r))
                tmp = eval(model.getValueAt(startRow,1+r),'[]');
                if isempty(tmp)
                    oldylim=h.Axesgrid.getylim(startRow+1);
                    model.setValueAtNoCallback(num2str(oldylim(r)),startRow,1+r);
                    %awtinvoke(model,'setValueAt(Ljava/lang/Object;II)',java.lang.String(num2str(oldylim(r))),startRow,1+r);
                    return
                else
                    lim(r)=tmp;
                end
            else
                lim(r) = model.getValueAt(startRow,1+r);
            end
        end
        if lim(2)<=lim(1)
            errordlg('The MIN limit must be smaller than the MAX limit','Time Series Tools','modal')
            oldylim=h.Axesgrid.getylim(startRow+1);
            model.setValueAtNoCallback(num2str(oldylim(1)),startRow,2);
            model.setValueAtNoCallback(num2str(oldylim(2)),startRow,3);
            return
        end
        if strcmp(type,'Y')
            h.Axesgrid.setylim(lim,startRow+1);
        else
            h.Axesgrid.setxlim(lim,startRow+1);
        end   
end

%% Send a viewchnage to refeesh absolute x axes time labels
h.AxesGrid.send('viewchange')
