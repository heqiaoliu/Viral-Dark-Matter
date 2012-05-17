function slOrSf = isSLorSF(pj)
% Helper to check whether the handles in pj is Simulink/Stateflow
% -sramaswa

    slOrSf = false;

    % No Simulink which means no stateflow either
    if(exist('open_system','builtin') == 0)
        return;
    end

    if(isempty(pj.Handles))
        return;
    end

    handles = pj.Handles{:};

    if(~all(ishandle(handles)))
       return; 
    end

    if(all(isslhandle(handles)))
        slOrSf = true;
    else
        if(all(ishghandle(handles)))
            slOrSf = true;
            for i = 1:length(handles)
                isSfPortal = strcmpi(get(handles(i),'Tag'),'SF_PORTAL');
                slOrSf = slOrSf && isSfPortal;
                if(~slOrSf)
                    break;
                end
            end % for
        end % if
    end % if

end

% [EOF]
