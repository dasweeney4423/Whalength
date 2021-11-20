function [handles]=meas_width(handles)
%measure widths function
CF=handles.CF;
 load(fullfile([CF '\Whalength data\' 'CAL.mat']))
COLOR=handles.COLOR;

set(handles.text9,'String','Click to indicate endpoints on whale, use right-click to zoom.')
rect=handles.rect;
H=handles.H;
TL=handles.TL;
if H~=1
    ZP1=TL/3*150; %no. of pixels either side of click for first zoom
    ZP2=TL/5*150; %no. of pixels either side of click for 2nd zoom
else
    ZP1=TL/3*100*50; %no. of pixels either side of click for first zoom
    ZP2=TL/5*100*50; %no. of pixels either side of click for 2nd zoom
end
hold on
[x1,y1,butt]=ginputcross(1);

if butt==3; %if right click zoom in on point
    
    
    xlim([x1-ZP1, x1+ZP1])
    ylim([y1-ZP1, y1+ZP1])
    [x1,y1,butt]=ginputcross(1);
    plot(x1,y1,'Marker','x','Color',COLOR,'LineStyle','none','MarkerSize',8,'LineWidth',2)
    xlim([rect(1), rect(1)+rect(3)])
    ylim([rect(2), rect(2)+rect(4)])
    
elseif butt==1
    plot(x1,y1,'Marker','x','Color',COLOR,'LineStyle','none','MarkerSize',8,'LineWidth',2)
else
end


if ~isempty(butt) %if enter is pressed at any point the function leaves the field for this width empty
    
    [x2,y2,butt]=ginputcross(1);
    if butt==3; %if right click zoom in on point
        
        xlim([x2-ZP1, x2+ZP1])
        ylim([y2-ZP1, y2+ZP1])
        [x2,y2,butt]=ginputcross(1);
        plot(x2,y2,'Marker','x','Color',COLOR,'LineStyle','none','MarkerSize',8,'LineWidth',2)
        
    elseif butt==1
        plot(x2,y2,'Marker','x','Color',COLOR,'LineStyle','none','MarkerSize',8,'LineWidth',2)
    else
    end
    plot([x1,x2],[y1,y2],'LineStyle','-','Color',COLOR)
    xlim([rect(1), rect(1)+rect(3)])
    ylim([rect(2), rect(2)+rect(4)])
    
    if ~isempty(butt)
        
        xlim([rect(1), rect(1)+rect(3)])
        ylim([rect(2), rect(2)+rect(4)])
        P1 = [(x1-.5)-IW/2; IH/2-(y1-.5)]*SCALE_F; %calculate pixel indices
        P2 = [(x2-.5)-IW/2; IH/2-(y2-.5)]*SCALE_F; %calculate pixel indices
        T1 = P1;
        T2 = P2;
        xmes = T1(1);
        ymes = T1(2);
        xp = PPA(1);
        yp = PPA(2);
        x = xmes-xp;
        y = ymes-yp;
        r = sqrt(x^2+y^2);
        dr = k1*r^3+k2*r^5+k3*r^7;
        T1c(1,1) = xmes-xp+x*dr/r+p1*(r^2+2*x^2)+2*p2*x*y+b1*x+b2*y; %corrected pixel indices for first loc
        T1c(2,1) = ymes-yp+y*dr/r+p2*(r^2+2*y^2)+2*p1*x*y;
        xmes = T2(1);
        ymes = T2(2);
        xp = PPA(1);
        yp = PPA(2);
        x = xmes-xp;
        y = ymes-yp;
        r = sqrt(x^2+y^2);
        dr = k1*r^3+k2*r^5+k3*r^7;
        T2c(1,1) = xmes-xp+x*dr/r+p1*(r^2+2*x^2)+2*p2*x*y+b1*x+b2*y; %corrected pixel indices for 2nd loc
        T2c(2,1) = ymes-yp+y*dr/r+p2*(r^2+2*y^2)+2*p1*x*y;
        Dc = sqrt((T2c-T1c)'*(T2c-T1c))*H/fc;
        W=Dc;
        if H==1
            W=W/TL*100; %if lidar height was not given scale the width to be a percentage of the total length
            set(handles.text8, 'String', strjoin({'Width (%TL):', num2str(W)})); %print width under image
        else
            set(handles.text8, 'String', strjoin({'Width (m):', num2str(W)})); %print width under image
        end
    else
        W=[];
    end
else
    W=[];
end



xlim([rect(1), rect(1)+rect(3)])
ylim([rect(2), rect(2)+rect(4)])
hold off
% updata handles with width

handles.W=W;
end