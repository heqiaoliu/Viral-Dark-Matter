function f = structwebfigure(hnd)
    [serialized, width, height, az, el, bgcolor] = savewebfigure(hnd);

    import java.util.UUID;
    id = UUID.randomUUID();

    f.uuid = char(id.toString()); 
    f.figData= serialized;
    f.width = width;
    f.height = height;
    f.rotation = az;
    f.elevation = el;
    f.backgroundColor = bgcolor;      
end