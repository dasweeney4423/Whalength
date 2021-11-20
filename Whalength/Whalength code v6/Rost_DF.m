function [handles]=Rost_DF(handles,hObject)

%allows user to indicate points along axis of whale with ginputc
%updates handles to be used in Whalength.m with total whale length

H=handles.H;
rect=handles.rect;

set(handles.text8, 'String', '   ')
CF=handles.CF;
%Define constants for lens corrections - constants and calculations by Pascal Sirguey
 load(fullfile([CF '\Whalength data\' 'CAL.mat']))

w=0;
ct=1;
X=[];
Y=[];


SL=max(abs([rect(3),rect(4)]));

set(handles.text9,'String','Click at end of Dorsal Fin, right-click to zoom')



[x1,y1,butt]=ginputcross(1);%indicate end of DF
    
    if butt==3; %if right click zoom in on point
        
        plot(X,Y,'LineStyle','-','Color','k','Marker','x')
        xlim([x1-SL/4, x1+SL/4])
        ylim([y1-SL/6, y1+SL/6])
        [x2,y2,butt]=ginputcross(1);
        
        rx=x2;
        ry=y2;
        
        
%     elseif isempty(butt)
%         break
    else
        rx=x1;
        ry=y1;
        
    end
xlim([rect(1), rect(1)+rect(3)])
ylim([rect(2), rect(2)+rect(4)])

Lvec=handles.Lvec;

%coordinates of TL curve
xf=Lvec(1,:);
yf=Lvec(2,:);

DIST=bsxfun(@hypot,xf-rx,yf-ry);
INDEX = find(DIST==min(DIST));

% [MM, xINDEX] = min(abs(xf-rx));
% [MM, yINDEX] = min(abs(yf-ry));
% 
% INDEX = round(mean(xINDEX,yINDEX));

xf=xf(1:INDEX);
yf=yf(1:INDEX);


hold on
plot(xf, yf, 'k','Linewidth',2)
xlim([rect(1), rect(1)+rect(3)])
ylim([rect(2), rect(2)+rect(4)])

PP=[(xf-.5)-IW/2; IH/2-(yf-.5)]*SCALE_F; %calculate pixel indices


T1 = PP(:,1:end-1);
T2 = PP(:,2:end);
%calculate corrected  length
xmes = T1(1,:);
ymes = T1(2,:);
xp = PPA(1);
yp = PPA(2);
x = xmes-xp;
y = ymes-yp;
r = sqrt(x.^2+y.^2);
dr = k1*r.^3+k2*r.^5+k3*r.^7;
T1c = [xmes-xp+x.*dr./r+p1*(r.^2+2*x.^2)+2*p2*x.*y+b1*x+b2*y; ymes-yp+y.*dr./r+p2*(r.^2+2*y.^2)+2*p1*x.*y]; %corrected pixel indices for first loc

xmes = T2(1,:);
ymes = T2(2,:);
xp = PPA(1);
yp = PPA(2);
x = xmes-xp;
y = ymes-yp;
r = sqrt(x.^2+y.^2);
dr = k1*r.^3+k2*r.^5+k3*r.^7;
T2c = [xmes-xp+x.*dr./r+p1*(r.^2+2*x.^2)+2*p2*x.*y+b1*x+b2*y; ymes-yp+y.*dr./r+p2*(r.^2+2*y.^2)+2*p1*x.*y]; %corrected pixel indices for 2nd loc

Dc = sqrt((T2c(1,:)-T1c(1,:)).*(T2c(1,:)-T1c(1,:))+(T2c(2,:)-T1c(2,:)).*(T2c(2,:)-T1c(2,:)))*H/fc;    %corrected length over ground(sea): to be stored in excel file somhow

Lcum=zeros(1,length(Dc));
Lcum(1)=Dc(1);

for nn=2:length(Dc);
    Lcum(nn)=Dc(nn)+Lcum(nn-1);
end

LvecRDF=[xf; yf; Lcum, 0];
RDF=Lcum(end);
handles.RDF=RDF;
handles.LvecRDF=LvecRDF;
TL = handles.TL;
if H==1
    RDF = RDF./TL*100;
    handles.RDF=RDF;
    set(handles.text8, 'String', strjoin({'Width (%TL):', num2str(RDF)})); %print length under image
else
    set(handles.text8, 'String', strjoin({'Length (m):', num2str(RDF)})); %print length under image
end

set(handles.text9,'String','Measure any widths then check Image Qualities are set for this image.')

guidata(hObject,handles)

end