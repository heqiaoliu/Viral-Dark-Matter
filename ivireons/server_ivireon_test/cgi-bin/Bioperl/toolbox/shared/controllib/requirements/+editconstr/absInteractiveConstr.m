classdef absInteractiveConstr < HeterogeneousHandle
% ABSINTERACTIVECONSTR  Abstract parent class for all interactive
% constraint classes (plotconstr, editconstr)
%
 
% Author(s): A. Stothert 25-Nov-2008
% Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.8.4 $ $Date: 2010/04/11 20:36:33 $

properties
    Requirement
    EventManager
    Activated
    HelpData
    Orientation
    Ts = 0;
end

 properties(SetObservable, AbortSet)
     Selected = false;
 end

properties(Access = 'protected')
    Listeners
    Data
end

properties(Access = 'private')
    DisplayUnits = {'none','none'};
end

%Interface methods for HeterogeneousHandle
methods(Sealed, Static, Access = 'protected')
    function obj = getDefaultScalarElement
        obj = editconstr.TimeResponse(srorequirement.timeresponse);
    end
end

methods(Sealed)
    function b = eq(this,h)
        %A == B does element by element comparisons between A and B
        %and returns a matrix of the same size with elements set to logical 1
        %where the relation is true and elements set to logical 0 where it is
        %not.  A and B must have the same dimensions unless one is a
        %scalar. A scalar can be compared with any size array. 
        
        if numel(h) == 1
            b = false(size(this));
            for ct=1:numel(this)
                b(ct) = eq@handle(this(ct),h);
            end
        elseif all(size(this)==size(h))
            b = false(size(this));
            for ct=1:numel(this)
                b(ct) = eq@handle(h(ct),this(ct));
            end
        elseif numel(this) == 1
            b = false(size(h));
            for ct=1:numel(h)
                b(ct) = eq@handle(this,h(ct));
            end
        else
            error('MATLAB:dimagree','Matrix dimensions must agree.')
        end
    end
end

methods(Access = 'protected')
    function this = absInteractiveConstr(SrcObj)
        this.Requirement  = SrcObj;
        this.Data         = SrcObj.getDataObj(this);
        this.EventManager = ctrluis.eventmgr;
        this.HelpData     = struct(...
            'MapFile',  '/mapfiles/control.map',...
            'EditHelp', 'sisoconstraintedit', ...
            'CSHTopic', '');
        
        %Add listeners to data object
        L = handle.listener(this.Data,'ObjectBeingDestroyed', {@localDestroy this});
        this.Listeners = L;
    end
end

methods
    function T = recordon(this)
        %RECORDON create a transaction to record changes to this object
        T = ctrluis.transaction(this.Data,...
           'Name',ctrlMsgUtils.message('Controllib:graphicalrequirements:msgEditConstraint'),...
            'OperationStore','on','InverseOperationStore','on');
    end
    function recordoff(this,T)
        %RECORDOFF store a transaction for undo/redo
        if ~isempty(T.Transaction.Operations)
            % Commit and stack transaction
            % RE: Only when something changed! (FocusLost listener triggers even w/o touching data)
            this.EventManager.record(T);
        else
            delete(T);
        end
    end
    function [CPX,CPY] = limitResize(this,CPX,CPY,moveIdx)
        %LIMITRESIZE limits resize values for a constraint.
        
        %Perform the limit check
        iElement = this.Data.getData('SelectedEdge');
        iElement = iElement(1);
        xCoords  = this.Data.getData('xdata');
        minSize  = eps;   %Percentage used to limit minimum constraint size.
        nEdge    = size(xCoords,1);
        switch moveIdx
            case 1
                %Left end selected
                if nEdge>1
                    %Limit left extent to left end of next constraint
                    if iElement > 1
                        leftLimit = xCoords(iElement-1,1);
                        CPX       = max(CPX,leftLimit*(1+minSize*sign(leftLimit)));
                    end
                end
                %Limit right extent to right end
                rightLimit = xCoords(iElement,2);
                CPX        = min(CPX,rightLimit*(1-minSize*sign(rightLimit)));
            case 2
                %Right end selected
                if nEdge>1
                    %Limit right extent to right end of next constraint
                    if iElement < nEdge
                        rightLimit = xCoords(iElement+1,2);
                        CPX        = min(CPX,rightLimit*(1-minSize*sign(rightLimit)));
                    end
                end
                %Limit left extent to left end
                leftLimit = xCoords(iElement,1);
                CPX       = max(CPX,leftLimit*(1+minSize*sign(leftLimit)));
        end
    end
    function units = getDisplayUnits(this,getwhat)
        %GETDISPLAYUNITS return the display units used
        switch getwhat
            case 'xunits', units = this.DisplayUnits{1};
            case 'yunits', units = this.DisplayUnits{2};
        end
    end
    function setDisplayUnits(this,setwhat,units)
        %SETDISPLAYUNITS set the display units used
        switch setwhat
            case 'xunits', this.DisplayUnits{1} = units;
            case 'yunits', this.DisplayUnits{2} = units;
        end
    end
    function Str = describe(this,keyword)
        %DESCRIBE return a string describing the requirement
        bUpper = strcmp(this.Data.Type,'upper');
        if bUpper
            Str = ctrlMsgUtils.message('Controllib:graphicalrequirements:msgUpperLimit');
        else
            Str = ctrlMsgUtils.message('Controllib:graphicalrequirements:msgLowerLimit');
        end
        
        if (nargin == 2) && strcmp(keyword, 'detail')
            XUnits = this.getDisplayUnits('xunits');
            Range = unitconv(this.Data.getData('xData'), ...
                this.Data.getData('xUnits'), ...
                XUnits);
            Range = Range(:);
            if bUpper
               Str = ctrlMsgUtils.message('Controllib:graphicalrequirements:msgUpperLimitFromTo', ...
                  sprintf('%0.3g',min(Range)), sprintf('%0.3g',max(Range)), XUnits);
            else
               Str = ctrlMsgUtils.message('Controllib:graphicalrequirements:msgLowerLimitFromTo', ...
                  sprintf('%0.3g',min(Range)), sprintf('%0.3g',max(Range)), XUnits);
            end
        end
    end
    function hReq = getRequirementObject(this)
       hReq = this.Requirement;
    end
end
end

function localDestroy(~,~,this)
delete(this)
end
