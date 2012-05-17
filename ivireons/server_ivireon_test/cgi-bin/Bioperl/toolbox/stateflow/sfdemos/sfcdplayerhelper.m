function result = sfcdplayerhelper(method,varargin)

persistent sRadioRequest;
persistent sCdRequest;
persistent sInsertDisc;
persistent sEjectDisc;

result = 0;

if(isempty(sCdRequest))
    sCdRequest = double(CdRequestMode.STOP);
end

if(isempty(sRadioRequest))
    sRadioRequest = double(RadioRequestMode.OFF);
end

if(isempty(sInsertDisc))
    sInsertDisc = false;
end

if(isempty(sEjectDisc))
    sEjectDisc = false;
end

switch(method)
    case 'get_radio_request'
        result = double(sRadioRequest);
    case 'get_cd_request'
        result = double(sCdRequest);
    case 'set_radio_request'
        sRadioRequest = varargin{1};
        result = sRadioRequest;
    case 'set_cd_request'
        sCdRequest = varargin{1};
        result = sCdRequest;
    case 'set_insert_disc'
        sInsertDisc = true;
        result =  sInsertDisc;
    case 'get_insert_disc'
        result =  sInsertDisc;
        if(sInsertDisc)
            sInsertDisc = false; % toggle after the first access to mimic a trigger
        end
    case 'set_eject_disc'
        sEjectDisc = true;
        result =  sEjectDisc;
    case 'get_eject_disc'
        result =  sEjectDisc;
        if(sEjectDisc)
            sEjectDisc = false; % toggle after the first access to mimic a trigger
        end
    otherwise
        error('Stateflow:DemoInternalError','Unknown method');
end
end