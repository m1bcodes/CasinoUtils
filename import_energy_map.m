function planes = import_energy_map(fn)

fid = fopen(fn,"rt");

header=1;
planeHeader = 2;
lineDef = 3;
state=header;
lineno=0;

planes={};
while ~feof(fid)
    s = fgetl(fid);
    lineno=lineno+1;
    if mod(lineno,1000)==0
        fprintf("Reading line %d ...\r", lineno);
    end
    
    while ~isempty(s)
        switch state
            case header
                plane = parse_planeId(s);
                if ~isempty(plane)
                    state = planeHeader;
                end
                s=[];
            case planeHeader
                xx = parse_ph(s);
                if ~isempty(xx)
                    state = lineDef;
                    s=[];
                    yy=[];
                    map = [];
                else
                    return;
                end
            case lineDef
                [row, line] = parse_lineDef(s);
                if ~isempty(row)
                    yy=[yy; row];
                    map=[map; line];
                    s=[];
                else
                    planes=[planes struct('plane', plane, 'xx', xx', 'yy', yy, 'map', map)];
                    state = header;
                end
        end
    end
end

fclose(fid);
end

function p = parse_planeId(s)
p = regexp(s, "(?<planeid>\w+) plane (?<planeno>\d+)\s+. Position:\s*(?<pos>[\-0-9\.eE]+).*", 'names');
end

function xx = parse_ph(s)
c=strsplit(s,'nm');
xx = str2double(c);
if ~isfinite(xx(1))
    xx=[];
end
end

function [row, line] = parse_lineDef(s)
c = regexp(s,'(nm)|\s','split');
cy = str2double(c);
if ~isfinite(cy(1))
    row = [];
    line=[];
else
    row = cy(1);
    line=cy(3:end);
end
end