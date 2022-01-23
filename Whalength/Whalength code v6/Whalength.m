function varargout = Whalength(varargin)
% WHALENGTH MATLAB code for Whalength.fig WINDOWS VERSION
%      WHALENGTH, by itself, creates a new WHALENGTH or raises the existing
%      singleton*.
%
%      H = WHALENGTH returns the handle to a new WHALENGTH or the handle to
%      the existing singleton*.
%
%      WHALENGTH('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WHALENGTH.M with the given input arguments.
%
%      WHALENGTH('Property','Value',...) creates a new WHALENGTH or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Whalength_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Whalength_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

%   Eva Leunissen
%   eva.leunissen@gmail.com

% Last Modified by GUIDE v2.5 20-Oct-2019 20:18:30
% June 2018: replaced 'count' variable with 'COUNT' to avoid conflict with count function in latest version of Matlab 
% Oct 2019: add .csv and/or .txt output
%           add "DF width" button
%           shorten width lines as percentage of body length
%           fixed 5% width calculation bug

% For the latest version of the code please visit https://github.com/EvaLeunissen/Whalength


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Whalength_OpeningFcn, ...
    'gui_OutputFcn',  @Whalength_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Whalength is made visible.
function Whalength_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Whalength (see VARARGIN)

% Choose default output for Whalength
CF=cd; %current directory
if isdir('Whalength data')==0
mkdir('Whalength data')
else
end
handles.output = hObject;
handles.oldpath=[];
handles.xfile=[];
handles.fnsh=[];
handles.Sing_im=[];
handles.H=[];
handles.theta=0;

sheet=1; %define default excel sheet to be sheet 1
handles.sheet=sheet;
set(handles.text7, 'String', '    ')
set(handles.text6, 'String', '    ')
sharp=1;
water='Calm'; %define state of water to be 'Calm' by default, unless it is changed with the radio button to 'Ruffled'
flukes='straight';
sides='N';
unotes=[];
use_setD='Yes';
use_setO='Yes';
try
    load(fullfile([CF '\Whalength data\' 'drone.mat']))
    use_setD=questdlg(strjoin({'Use previous settings?:  ', drone_sys, ' ',photos,', offset: ',num2str(CLoffset), 'cm'}),'Previous settings','Yes','No, change settings','Yes');
catch %if no previous settings saved
    drone_sys=questdlg('Which setup?','System settings','I1P','I2P','I1P');
    photos=questdlg('Picture type?','Picture settings','Photos','Video stills','Photos');
    Offset = inputdlg({'Give offset between camera image plane and LIDAR in cm'},'Offset', [1 60]);
    CLoffset=str2num(cell2mat(Offset));
end %set drone settings

if strcmp(use_setD,'Yes')==0
    drone_sys=questdlg('Which setup?','System settings','I1P','I2P','I1P');
    photos=questdlg('Picture type?','Picture settings','Photos','Video stills','Photos');
    Offset = inputdlg({'Give offset between camera image plane and LIDAR in cm...'},'Offset', [1 60]);
    CLoffset=str2num(cell2mat(Offset));
else
end

%output settings
try
    load(fullfile([CF '\Whalength data\' 'out_fmt.mat']))
    use_setO=questdlg(strjoin({'Use previous output format?:  ', out_fmt}),'Previous settings','Yes','No, change settings','Yes');
catch
    out_fmt=questdlg('Output format?','Output format','.xlsx','.csv','.txt','.xlsx');
end



if strcmp(use_setO,'Yes')==0
    out_fmt=questdlg('Output format?','Output format','.xlsx','.csv','.txt','.xlsx');
else
end 

handles.out_fmt=out_fmt;

if strcmp(drone_sys,'I1P')==1 && strcmp(photos,'Photos')==1
    drone=1;
elseif strcmp(drone_sys,'I1P')==1 && strcmp(photos,'Video stills')==1
    drone=2;
elseif strcmp(drone_sys,'I2P')==1 && strcmp(photos,'Photos')==1
    drone=3;
elseif strcmp(drone_sys,'I2P')==1 && strcmp(photos,'Video stills')==1
    drone=4;
else
end
    
handles.drone=drone;


%Define image resolution, Calibrated lens characteristics, and offsets
if drone==1
    fc = 24.851372;             %corrected focal length
PPA = [0.203089;-0.087931]; %difference between matlab centre and photo centre
k1 = -9.1303e-005;          %radial offsets
k2 = 8.4284e-007;
k3 = -3.7862e-009;
p1 = -3.1598e-005;          %centre offsets
p2 = 2.0922e-005;
b1 = 7.0190e-004;           %other offsets
b2 = -1.4177e-004;
IH = 3456;
IW = 4608;
SCALE_F=0.003758;
elseif drone==2 %I1P VID STILLS
        fc = 29.81122;             %corrected focal length
PPA = [0.237438;-0.162665]; %difference between matlab centre and photo centre
k1 = 8.881e-005;          %radial offsets
k2 = 2.2957e-008;
k3 = -3.4605e-010;
p1 = 6.3978e-006;          %centre offsets
p2 = 1.7525e-005;
b1 = 1.2427e-004;           %other offsets
b2 = -1.5233e-004;
IH = 2160;
IW = 3840;
SCALE_F=0.00451;
elseif drone==3 %I2P PHOTOS
        fc = 24.295944;             %corrected focal length
PPA = [0.033057;-0.036885]; %difference between matlab centre and photo centre
k1 = -4.1148e-005;          %radial offsets
k2 = 7.4199e-007;
k3 = -4.2507e-009;
p1 = 1.1429e-005;          %centre offsets
p2 = 9.8552e-006;
b1 = 4.8496e-004;           %other offsets
b2 = 2.2903e-004;
IH = 3956;
IW = 5280;
SCALE_F=0.00328;
elseif drone==4 %I2P VID STILLS
        fc = 24.463790;             %corrected focal length
PPA = [0.012890;0.020223]; %difference between matlab centre and photo centre
k1 = -3.4886e-005;          %radial offsets
k2 = 8.1458e-007;
k3 = -5.3827e-009;
p1 = 2.7922e-005;          %centre offsets
p2 = 4.0171e-006;
b1 = -4.5126e-004;           %other offsets
b2 = -1.5222e-004;
IH = 2160;
IW = 3840;
SCALE_F=0.00451;
end
if isempty(CLoffset)==1
    CLoffset=0;
else 
end
handles.CLoffset=CLoffset;
save(fullfile([CF '\Whalength data\' 'drone.mat']),'drone','drone_sys','photos','CLoffset')
save(fullfile([CF '\Whalength data\' 'out_fmt.mat']),'out_fmt')
set(handles.text33, 'String', strjoin({'Settings:', drone_sys, '',photos,', Offset:',num2str(CLoffset), 'cm',', Output:',num2str(out_fmt)}))
save(fullfile([CF '\Whalength data\' 'CAL.mat']),'fc','PPA','k1','k2','k3','p1','p2','b1','b2','IH','IW','SCALE_F')
handles.CF=CF;
save(fullfile([CF '\Whalength data\' 'Imquals.mat']),'sharp','water','flukes','sides','unotes')
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Whalength wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Whalength_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
% Choose default command line output for trialgui
handles.output = hObject;


guidata(hObject, handles);


% --- Executes on button press in pushbutton1. select folder
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ds = uigetdir(cd,'Select folder for a day of images...'); %cd starts in current folder

set(handles.text10, 'String', '    ') %clear previous displayed filename for output excel file
set(handles.text6, 'String', '    ') 
pathd = ds;
handles.pathd=pathd;                  %store day folder directory in 'path' in handles structure
fname=strsplit(pathd,'\\');

handles.dayfd=fname{end};
set(handles.text7,'String',fname(end))

handles.bestim_ind=1; %setting starting index for images and subfolders to 1 by default, will de different if an image to start from instead is entered.
handles.subf_ind=1;
guidata(hObject,handles)  % Save the handles structure.
uiresume(gcbf)

% --- Executes on button press in pushbutton2. Load excel file
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    oldpath = handles.pathd;    %get previous file path
catch
    oldpath = [];
end
if~isempty(oldpath)
    fds=strsplit(oldpath,'\\');
    ll=length(fds{end});
    oldpath=oldpath(1:end-ll-1); %create path to folder which contains day folder ie one step back from pathd
    handles.oldpath=oldpath;
    [xfile,pathx] = uigetfile(fullfile(oldpath,'*.xlsx'),'Select excel file...');
else
    [xfile,pathx] = uigetfile(fullfile('*.xlsx'),'Select excel file...');
end

set(handles.text6,'String',xfile)
handles.pathx=pathx;
handles.xfile=xfile;

sheet=handles.sheet;
[ndata, text, alldata] = xlsread(fullfile(pathx,xfile),sheet);
handles.xcelall=alldata;            % 'alldata' contains the spreadsheet as a cells structure, with a cell
                                    % for each entry, annd contains Nan if excel cell was empty
handles.xceln=ndata;

pathd=handles.pathd;       %get path of folder for each day of images

% subdirs = regexp(genpath(pathd),['[^;]*'],'match'); %get names of subdirectories within day folder - these will not all be true image folders
% n_subs=length(subdirs);       % number of subfolders in day folder, not all of these entries are actually proper image folders
% cc=1;
% for ind=1:n_subs;       %for each subdirectory:
%     
%     files = dir(fullfile(subdirs{ind},'*.jpg'));               %get jpg filenames in source directory
%     
%     if ~isempty(files)              %if there are image files in this subfolder...
%         
%         imdirs{cc}=subdirs{ind};     %...store the directory of this subfolder in imdirs structure
%         
%         ims{cc}=files;               %store image names in ims structure
%         
%         cc=cc+1;                      %COUNTer
%         
%     else
%         
%     end
% end
% handles.cc=cc;
% ff=1; %COUNTer
% 
% for nf=2:size(alldata,1); %For each cell under the heading 'Folder':
%     
%     if isnan(alldata{nf,1})==0; %if cell does not contain NaN...
%         subfolders{ff}=alldata{nf,1};    %store folder name in 'subfolders' structure
%         nfind(ff)=nf;                    %store cell row number in nfind
%         ff=ff+1;
%         
%     else
%     end
% end
%store best image names (with notes and lidar heights) from excel file with corresp subfolder name, may
%include 'NaN's for blank spaces in excel sheet but will deal with that
%later

subfolders=alldata(2:end,1);
bestims=alldata(2:end,4);
notes=alldata(2:end,3);
tilt=alldata(2:end,9);
heights=alldata(2:end,10);
cor_time=alldata(2:end,7);
contents=alldata(2:end,2);
cc=size(bestims,1);

% for ni=1:length(nfind);
%     if ni~=length(nfind)  %for all but the last image
%         bestims{ni,1}=alldata{%ndata(nfind(ni)-1:nfind(ni+1)-2,1);
%         notes{ni,1}=text(nfind(ni):nfind(ni+1)-1,3);
%         tilt{ni,1}=ndata(nfind(ni)-1:nfind(ni+1)-2,6); %read values for tilt (or NaN if not provided) from column I
%         heights{ni,1}=ndata(nfind(ni)-1:nfind(ni+1)-2,7); %read 5s median lidar heigh from column J
%         cor_time{ni,1}=ndata(nfind(ni)-1:nfind(ni+1)-2,4); %corrected time
%         contents{ni,1}=text(nfind(ni):nfind(ni+1)-1,2);
%     else
%         bestims{ni,1}=ndata(nfind(ni)-1:end,1);
%         notes{ni,1}=text(nfind(ni):end,3);
%         tilt{ni,1}=ndata(nfind(ni)-1:end,6);
%         heights{ni,1}=ndata(nfind(ni)-1:end,7);
%         cor_time{ni,1}=ndata(nfind(ni)-1:end,4);
%         contents{ni,1}=text(nfind(ni):end,2);
%     end
% end
handles.cc=cc;
handles.contents=contents;
handles.cor_time=cor_time;
handles.bestims=bestims;
handles.subfolders=subfolders;
%handles.imdirs=imdirs;
handles.bestims=bestims;
%handles.ims=ims;
handles.tilt=tilt;
handles.heights=heights;
handles.notes=notes;
guidata(hObject,handles)            % Save the handles structure.





% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% RUN button
CF=handles.CF;
 load(fullfile([CF '\Whalength data\' 'CAL.mat']))
if ~isempty(handles.xfile) && ~isempty(handles.oldpath)
    
    oops=0; %is set to zero each time an image is loaded and is changed only when 'Redo image' button is pressed and sets oops to 1
    save(fullfile([CF '\Whalength data\' 'oops.mat']),'oops')
    set(handles.text8, 'String', '   ');
    set(handles.text10, 'String', '   ')
    fnsh=0;
    save(fullfile([CF '\Whalength data\' 'fnsh.mat']),'fnsh');
    
    pad='0000';             %to be used to construct image names
    clear A
    %Defining output excel file headers for each column
    A{1,5}='Image quality';
    A{1,13}='Body width along body axis at 10% increments (if no lidar height, widths given as % of total length (TL)';
    A{1,32}='Body width along body axis at 5% increments (if no lidar height, widths given as % of total length (TL)';
    A(2,1:51)={'Whale ID','Image date','Corrected time','Filename','Image sharpness (1-4)','Flukes up? (@surface/straight/drooped)',...
    'Water (calm/ruffled)','Sides clear? (Y/N)','Tilt (degrees)','Corrected height (m)','Total Length (m)','"Pixel length" (to be scaled by height in m)',...
    'Width at 10% TL','Width at 20% TL','Width at 30% TL','Width at 40% TL','Width at 50% TL','Width at 60% TL',...
    'Width at 70% TL','Width at 80% TL','Width at 90% TL','Width @ eye','Rostrum-eye','Rostrum-BH','Rostrum-DF',...
    'Fluke width','BH-DF insert.','Width @ DF','Folder','Label (for mult.whales per image)','Notes','Width at 5% TL','Width at 10% TL',...
    'Width at 15% TL','Width at 20% TL','Width at 25% TL','Width at 30% TL','Width at 35% TL','Width at 40% TL',...
    'Width at 45% TL','Width at 50% TL','Width at 55% TL','Width at 60% TL','Width at 65% TL','Width at 70% TL',...
    'Width at 75% TL','Width at 80% TL','Width at 85% TL','Width at 90% TL','Width at 95% TL','Content'};
    
    handles.A=A;
    save(fullfile([CF '\Whalength data\' 'A.mat']),'A') %first time A is saved
    COUNT=3;
    save(fullfile([CF '\Whalength data\' 'COUNT.mat']),'COUNT')
    handles.COUNT=COUNT;
    subf_ind=handles.subf_ind;
    bestim_ind=handles.bestim_ind;
    cc=handles.cc;
    subfolders=handles.subfolders;
    %imdirs=handles.imdirs;
    bestims=handles.bestims;
    %ims=handles.ims;
    tilt=handles.tilt;
    heights=handles.heights;
    notes=handles.notes;
    cor_time=handles.cor_time;
    contents=handles.contents;
    pathd=handles.pathd;
    
    %read image files within each subfolder and check that the folder name in
    %the excel sheet matches that in the directories in imdirs
    for ind=subf_ind:cc;
        load(fullfile([CF '\Whalength data\' 'fnsh.mat']))
        if fnsh==1;
            break
        else
        end
        
        
        if isdir(fullfile(pathd,subfolders{ind}))==1 && unique(isnan(subfolders{ind}))==0 %~isempty(strfind(imdirs{ind},subfolders{ind})) %if the folder name in the excel sheet matches the name in the directory...
            set(handles.text13, 'String', '   ')
            %for ind2=bestim_ind:length(bestims{ind})+1 %for each of the best images in the subfolder
                load(fullfile([CF '\Whalength data\' 'COUNT.mat']))
     
%                 if ind==cc+1
%                     break
%                 else
%                 end
                
                oops=0; %is set to zero each time an image is loaded and is changed only when 'Redo image' button s pressed and sets oops to 1
                save(fullfile([CF '\Whalength data\' 'oops.mat']),'oops')
                load(fullfile([CF '\Whalength data\' 'fnsh.mat']))
                if fnsh==1;
                    break
                else
                end
                
                set(handles.checkbox3,'Value',0)
                set(handles.edit4,'String','Edit text')
                unotes=[];
                save(fullfile([CF '\Whalength data\' 'Imquals.mat']),'unotes','-append')
                if isnan(bestims{ind})==0 %and if it is not a blank cell
%                     bin=num2str(bestims{ind}(ind2));
%                     l=length(bin); %number of 'numbers' in best image, ie 16 has 2 numbers
%                     imnum=strcat(pad(1:end-l),bin); %4-number image number
%                     subfolder_ims=dir(fullfile([pathd '\' subfolders{ind}],'*.jpg'));
%                     imcell=struct2cell(subfolder_ims(end,1));
%                     
%                     imnameS = imcell{1};                %sample image name in this subfolder
                    imname=bestims{ind}; %image name as read from excel sheet - should match image filename exactly                    
                    listing=dir(fullfile([pathd '\' subfolders{ind} '\' imname]));
                    dattims=strsplit(listing.date);
                    
                    %handles.curr_im_dir=[imdirs{ind} '\' imname];
                    C = imread(fullfile([pathd '\' subfolders{ind} '\' imname]));   %read the image
                    handles.C=C;
                    handles.dattims=dattims;
                    
                    set(handles.text4, 'String', imname(1:end-4));              %show image name above image in GUI
                    try
                        set(handles.text5, 'String', strcat('Notes: ', cell2mat(notes{ind})));   %show any notes above image
                    catch
                        set(handles.text5, 'String', ' ');
                    end
                        theta=tilt{ind}; %tilt angle in degress, NaN if not provided
                    if isnan(theta)==1
                        theta=0;            % if theta not provided, assume tilt is zero
                    else
                    end
                    handles.theta=theta;
                    CLoffset=handles.CLoffset;
                    H=(heights{ind}*cos(theta*pi/180)+CLoffset)/100;       %lidar height, read from excel sheet, corrected for tilt and offset of camera height relative to lidar (1.5cm below lidar) and converted to metres
                    handles.H=H;
                    CT=cor_time{ind};
                    handles.CT=CT;
                    try
                        CONT=contents{ind};
                    catch
                        CONT=[];
                    end
                    handles.CONT=CONT;
                    handles.subfolder=subfolders{ind};
                    hold off
                    image(C);
                    xlim([0.5 IW+0.5])
                    ylim([0.5 IH+0.5])
                    axis equal                      %makes image square
                    axis off
                    
                    if isnan(H) | H==1 | H<2;
                        H=1;
                        handles.H=H;
                        handles=meas_whale(handles,hObject);
                        load(fullfile([CF '\Whalength data\' 'A.mat']),'A')
                        load(fullfile([CF '\Whalength data\' 'COUNT.mat']),'COUNT')
                        handles.A=A; %updates A in handles after measuring
                        
                        handles.COUNT=COUNT;
                        TL=handles.TL;
                        subfolder=handles.subfolder;
                        
                        A{COUNT,1}=inputdlg({'Provide ID number for this measured whale'},'Whale ID', [1 60]); %get whale ID after measuring whale

                        A{COUNT,2}=dattims{1};
                        A{COUNT,3}=datestr(CT,'HH:MM:SS');
                        A{COUNT,9}=theta;
                        A{COUNT,10}='N/A';
                        A{COUNT,29}=subfolder;
                        A{COUNT,4}=get(handles.text4,'String');
                        A{COUNT,11}='TL';
                        A{COUNT,12}=TL/H; %'pixel length' to be scaled by height in metres
                        A{COUNT,51}=CONT;
                        
                        save(fullfile([CF '\Whalength data\' 'A.mat']),'A')
                        handles.A=A;
                        
                        guidata(hObject,handles)
                        
                    else
                        
                        handles=meas_whale(handles,hObject);
                        
                        load(fullfile([CF '\Whalength data\' 'A.mat']),'A')
                        load(fullfile([CF '\Whalength data\' 'COUNT.mat']),'COUNT')
                        handles.A=A; %updates A in handles after measuring
                        
                        handles.COUNT=COUNT;
                        TL=handles.TL;
                        subfolder=handles.subfolder;

                        A{COUNT,1}=inputdlg({'Provide ID number for this measured whale'},'Whale ID', [1 60]); %get whale ID after measuring whale
                        
                        A{COUNT,2}=dattims{1};
                        A{COUNT,3}=datestr(CT,'HH:MM:SS');
                        A{COUNT,9}=theta;
                        A{COUNT,10}=H;
                        A{COUNT,29}=subfolder;
                        A{COUNT,4}=get(handles.text4,'String');
                        A{COUNT,11}=TL;
                        A{COUNT,12}=TL/H; %'pixel length' to be scaled by height in metres
                        A{COUNT,51}=CONT;
                        
                        save(fullfile([CF '\Whalength data\' 'A.mat']),'A')
                        handles.A=A;
                        
                        guidata(hObject,handles)
                        
                    end
                    
                    waitfor(handles.checkbox3,'Value'); %waits for 'Correct?' checkbox to be ticked so image properties are set before moving on to next whale or image
                    load(fullfile([CF '\Whalength data\' 'A.mat']))
                    load(fullfile([CF '\Whalength data\' 'Imquals.mat']))
                    drawnow()
                    A{COUNT,5}=sharp;
                    A{COUNT,7}=water;
                    A{COUNT,6}=flukes;
                    A{COUNT,8}=sides;
                    A{COUNT,31}=unotes;
                    dayfd=handles.dayfd;
                    path=handles.pathd;
                    filename = strcat(dayfd, ' lengths');
                    
                    out_fmt=handles.out_fmt;
                    if strcmp(out_fmt,'.xlsx')==1                   
                        xlswrite(fullfile([path '\' filename '.xlsx']),A)
                    elseif strcmp(out_fmt,'.csv')==1
                        AT=cell2table(A);
                        writetable(AT,fullfile([path '\' filename '.csv']),'Delimiter',',','WriteVariableNames',0)
                    elseif strcmp(out_fmt,'.txt')==1
                        AT=cell2table(A);
                        writetable(AT,fullfile([path '\' filename '.txt']),'Delimiter','tab','WriteVariableNames',0)
                    end
                    COUNT=COUNT+1;
                    handles.COUNT=COUNT;
                    save(fullfile([CF '\Whalength data\' 'A.mat']),'A')
                    save(fullfile([CF '\Whalength data\' 'COUNT.mat']),'COUNT')
                    set(handles.text9,'String','If more whales to measure in this picture click "Measure another whale". If finished with this image click "Next image"')
                    
                    uiwait(gcf) %waits for either 'next image' button or 'measure another whale' button or 'redo' button
                    load(fullfile([CF '\Whalength data\' 'oops.mat']))
                    while oops==1; %if the redo image button was pressed enter this while loop
                        set(handles.checkbox3,'Value',0)
                        set(handles.edit4,'String','Edit text')
                        unotes=[];
                        save(fullfile([CF '\Whalength data\' 'Imquals.mat']),'unotes','-append')
                        oops=0; %reset oops to zero
                        save(fullfile([CF '\Whalength data\' 'oops.mat']),'oops')

                        COUNT=COUNT-1; %reduce COUNTer by one
                        save(fullfile([CF '\Whalength data\' 'COUNT.mat']),'COUNT')
                        
                        image(C);
                        axis equal                      %makes image square
                        axis off
                        xlim([0.5 IW+0.5])
                        ylim([0.5 IH+0.5])
                        
                        if isnan(H) | H==1 | H<2;
                            H=1;
                            handles.H=H;
                            handles=meas_whale(handles,hObject);
                            load(fullfile([CF '\Whalength data\' 'A.mat']),'A')
                            load(fullfile([CF '\Whalength data\' 'COUNT.mat']),'COUNT')
                            handles.A=A; %updates A in handles after measuring
                            
                            handles.COUNT=COUNT;
                            TL=handles.TL;
                            subfolder=handles.subfolder;

                            A{COUNT,1}=inputdlg({'Provide ID number for this measured whale'},'Whale ID', [1 60]); %get whale ID after measuring whale
                            
                            A{COUNT,2}=dattims{1};
                            A{COUNT,3}=datestr(CT,'HH:MM:SS');
                            A{COUNT,9}=theta;
                            A{COUNT,10}='N/A';
                            A{COUNT,29}=subfolder;
                            A{COUNT,4}=get(handles.text4,'String');
                            A{COUNT,11}='TL';
                            A{COUNT,12}=TL/H; %'pixel length' to be scaled by height in metres
                            A{COUNT,51}=CONT;
                            
                            save(fullfile([CF '\Whalength data\' 'A.mat']),'A')
                            handles.A=A;
                            
                            guidata(hObject,handles)
                            
                        else
                            
                            handles=meas_whale(handles,hObject);
                            
                            load(fullfile([CF '\Whalength data\' 'A.mat']),'A')
                            load(fullfile([CF '\Whalength data\' 'COUNT.mat']),'COUNT')
                            handles.A=A; %updates A in handles after measuring
                            
                            handles.COUNT=COUNT;
                            TL=handles.TL;
                            subfolder=handles.subfolder;

                            A{COUNT,1}=inputdlg({'Provide ID number for this measured whale'},'Whale ID', [1 60]); %get whale ID after measuring whale
                            
                            A{COUNT,2}=dattims{1};
                            A{COUNT,3}=datestr(CT,'HH:MM:SS');
                            A{COUNT,9}=theta;
                            A{COUNT,10}=H;
                            A{COUNT,29}=subfolder;
                            A{COUNT,4}=get(handles.text4,'String');
                            A{COUNT,11}=TL;
                            A{COUNT,12}=TL/H; %'pixel length' to be scaled by height in metres
                            A{COUNT,51}=CONT;
                            
                            save(fullfile([CF '\Whalength data\' 'A.mat']),'A')
                            handles.A=A;
                             
                            guidata(hObject,handles)
                            
                        end
                        
                        waitfor(handles.checkbox3,'Value'); %waits for 'Correct?' checkbox to be ticked so image properties are set before moving on to next whale or image
                        load(fullfile([CF '\Whalength data\' 'A.mat']))
                        load(fullfile([CF '\Whalength data\' 'Imquals.mat']))
                        drawnow()
                        A{COUNT,5}=sharp;
                        A{COUNT,7}=water;
                        A{COUNT,6}=flukes;
                        A{COUNT,8}=sides;
                        A{COUNT,31}=unotes;
                        
                        COUNT=COUNT+1;
                        handles.COUNT=COUNT;
                        
                        dayfd=handles.dayfd;
                        path=handles.pathd;
                    filename = strcat(dayfd, ' lengths');
                    
                    out_fmt=handles.out_fmt;
                    if strcmp(out_fmt,'.xlsx')==1                   
                        xlswrite(fullfile([path '\' filename '.xlsx']),A)
                    elseif strcmp(out_fmt,'.csv')==1
                        AT=cell2table(A);
                        writetable(AT,fullfile([path '\' filename '.csv']),'Delimiter',',','WriteVariableNames',0)
                    elseif strcmp(out_fmt,'.txt')==1
                        AT=cell2table(A);
                        writetable(AT,fullfile([path '\' filename '.txt']),'Delimiter','tab','WriteVariableNames',0)
                    end
                        save(fullfile([CF '\Whalength data\' 'A.mat']),'A')
                        save(fullfile([CF '\Whalength data\' 'COUNT.mat']),'COUNT')
                        set(handles.text9,'String','If more whales to measure in this picture click "Measure another whale". If finished with this image click "Next image"')
                        
                        uiwait(gcf) %waits for either 'next image' button or 'measure another whale' button or 'redo' button
                        load(fullfile([CF '\Whalength data\' 'oops.mat']))
                        
                    end
                    
                    if ind==cc %&& ind2==length(bestims{ind});
                        set(handles.text4, 'String', strjoin({imname(1:end-4), ' (Last image for this Folder)'}));
                    else
                    end
                    
                    
                else
                end
                
            
        elseif unique(isnan(subfolders{ind}))==0
            set(handles.text13, 'String', 'Make sure sheet number is correct')
        else
        end
    end
else
    set(handles.text13, 'String', 'Please load image folder and excel file')
end
guidata(hObject,handles)





% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%'NEXT IMAGE' button - allows for-loop processing best images to continue
set(handles.text8, 'String', '    ')

guidata(hObject,handles)
uiresume(gcbf)



function edit1_Callback(hObject, eventdata, handles) %input sheet number
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
sheet=str2double(get(hObject,'String'));
handles.sheet=sheet;
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, ~, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 'MEASURE ANOTHER WHALE' button - runs calculation code again if measuring more than one whale per picture
CF=handles.CF;
 load(fullfile([CF '\Whalength data\' 'CAL.mat']))
set(handles.checkbox3,'Value',0)
set(handles.edit4,'String','Edit text')
unotes=[];
save(fullfile([CF '\Whalength data\' 'Imquals.mat']),'unotes','-append')
C=handles.C;
hold off
image(C);
xlim([0.5 IW+0.5])
ylim([0.5 IH+0.5])
axis equal                      %makes image square
axis off
Lbl = inputdlg({'What whale from this image was just measured?'},'Identifier', [1 60]);

load(fullfile([CF '\Whalength data\' 'A.mat']))
load(fullfile([CF '\Whalength data\' 'COUNT.mat']))

A{COUNT-1,30}=Lbl{1};

subfolder=handles.subfolder;
%TL=handles.TL;
theta=handles.theta;
H=handles.H;
dattims=handles.dattims;
CT=handles.CT;
CONT=handles.CONT;

if H==1;
    
    handles=meas_whale(handles,hObject);
    TL=handles.TL;

    A{COUNT,1}=inputdlg({'Provide ID number for this measured whale'},'Whale ID', [1 60]); %get whale ID after measuring whale

    A{COUNT,2}=dattims{1};
    A{COUNT,3}=datestr(CT,'HH:MM:SS');
    A{COUNT,9}=theta;
    A{COUNT,10}='N/A';
    A{COUNT,29}=subfolder;
    A{COUNT,4}=get(handles.text4,'String');
    A{COUNT,11}='TL';
    A{COUNT,12}=TL/H; %'pixel length' to be scaled by height in metres
    A{COUNT,51}=CONT;
    
    guidata(hObject,handles)
    
else
    
    handles=meas_whale(handles,hObject);
    TL=handles.TL;

    A{COUNT,1}=inputdlg({'Provide ID number for this measured whale'},'Whale ID', [1 60]); %get whale ID after measuring whale

    A{COUNT,2}=dattims{1};
    A{COUNT,3}=datestr(CT,'HH:MM:SS');
    A{COUNT,9}=theta;
    A{COUNT,10}=H;
    A{COUNT,29}=subfolder;
    A{COUNT,4}=get(handles.text4,'String');
    A{COUNT,11}=TL;
    A{COUNT,12}=TL/H; %'pixel length' to be scaled by height in metres
    A{COUNT,51}=CONT;
    
end
save(fullfile([CF '\Whalength data\' 'A.mat']),'A')
waitfor(handles.checkbox3,'Value'); %waits for 'Correct?' checkbox to be ticked so image properties are set before moving on to next whale or image

load(fullfile([CF '\Whalength data\' 'A.mat']))
load(fullfile([CF '\Whalength data\' 'Imquals.mat']))

A{COUNT,5}=sharp;
A{COUNT,7}=water;
A{COUNT,6}=flukes;
A{COUNT,8}=sides;
A{COUNT,31}=unotes;

Lbl = inputdlg({'What whale from this image was just measured?'},'Identifier', [1 60]);
A{COUNT,30}=Lbl{1};
dayfd=handles.dayfd;
path=handles.pathd;
                    filename = strcat(dayfd, ' lengths');
                    
                    out_fmt=handles.out_fmt;
                    if strcmp(out_fmt,'.xlsx')==1                   
                        xlswrite(fullfile([path '\' filename '.xlsx']),A)
                    elseif strcmp(out_fmt,'.csv')==1
                        AT=cell2table(A);
                        writetable(AT,fullfile([path '\' filename '.csv']),'Delimiter',',','WriteVariableNames',0)
                    elseif strcmp(out_fmt,'.txt')==1
                        AT=cell2table(A);
                        writetable(AT,fullfile([path '\' filename '.txt']),'Delimiter','tab','WriteVariableNames',0)
                    end
save(fullfile([CF '\Whalength data\' 'A.mat']),'A')
COUNT=COUNT+1;
save(fullfile([CF '\Whalength data\' 'COUNT.mat']),'COUNT');

set(handles.text9,'String','If more whales to measure in this picture click "Measure another whale". If finished with this image click "Next image"')

uiwait(gcf) %wait for either next image or redo button
load(fullfile([CF '\Whalength data\' 'oops.mat']))
while oops==1; %if the redo image button was pressed enter this while loop
    set(handles.checkbox3,'Value',0)
    set(handles.edit4,'String','Edit text')
    unotes=[];
    save(fullfile([CF '\Whalength data\' 'Imquals.mat']),'unotes','-append')
    oops=0; %reset oops to zero
    save(fullfile([CF '\Whalength data\' 'oops.mat']),'oops')

    COUNT=COUNT-1; %reduce COUNTer by one
    save(fullfile([CF '\Whalength data\' 'COUNT.mat']),'COUNT')
    
    image(C);
    axis equal                      %makes image square
    axis off
    xlim([0.5 IW+0.5])
    ylim([0.5 IH+0.5])
    
    if isnan(H) | H==1 | H<2;
        H=1;
        handles.H=H;
        handles=meas_whale(handles,hObject);
        load(fullfile([CF '\Whalength data\' 'A.mat']),'A')
        load(fullfile([CF '\Whalength data\' 'COUNT.mat']),'COUNT')
        handles.A=A; %updates A in handles after measuring
        
        handles.COUNT=COUNT;
        TL=handles.TL;
        subfolder=handles.subfolder;

        A{COUNT,1}=inputdlg({'Provide ID number for this measured whale'},'Whale ID', [1 60]); %get whale ID after measuring whale
        
        A{COUNT,2}=dattims{1};
        A{COUNT,3}=datestr(CT,'HH:MM:SS');
        A{COUNT,9}=theta;
        A{COUNT,10}='N/A';
        A{COUNT,29}=subfolder;
        A{COUNT,4}=get(handles.text4,'String');
        A{COUNT,11}='TL';
        A{COUNT,12}=TL/H; %'pixel length' to be scaled by height in metres
        A{COUNT,51}=CONT;
       
        save(fullfile([CF '\Whalength data\' 'A.mat']),'A')
        handles.A=A;
       
        guidata(hObject,handles)
        
    else
        
        handles=meas_whale(handles,hObject);
        
        load(fullfile([CF '\Whalength data\' 'A.mat']),'A')
        load(fullfile([CF '\Whalength data\' 'COUNT.mat']),'COUNT')
        handles.A=A; %updates A in handles after measuring
        
        handles.COUNT=COUNT;
        TL=handles.TL;
        subfolder=handles.subfolder;

        A{COUNT,1}=inputdlg({'Provide ID number for this measured whale'},'Whale ID', [1 60]); %get whale ID after measuring whale
        
        A{COUNT,2}=dattims{1};
        A{COUNT,3}=datestr(CT,'HH:MM:SS');
        A{COUNT,9}=theta;
        A{COUNT,10}=H;
        A{COUNT,29}=subfolder;
        A{COUNT,4}=get(handles.text4,'String');
        A{COUNT,11}=TL;
        A{COUNT,12}=TL/H; %'pixel length' to be scaled by height in metres
        A{COUNT,51}=CONT;
       
        save(fullfile([CF '\Whalength data\' 'A.mat']),'A')
        handles.A=A;
        
        guidata(hObject,handles)
        
    end
    
    waitfor(handles.checkbox3,'Value'); %waits for 'Correct?' checkbox to be ticked so image properties are set before moving on to next whale or image
    load(fullfile([CF '\Whalength data\' 'A.mat']))
    load(fullfile([CF '\Whalength data\' 'Imquals.mat']))
    drawnow()
    A{COUNT,5}=sharp;
    A{COUNT,7}=water;
    A{COUNT,6}=flukes;
    A{COUNT,8}=sides;
    A{COUNT,31}=unotes;
   
    COUNT=COUNT+1;
    handles.COUNT=COUNT;
    dayfd=handles.dayfd;
    path=handles.pathd;
                    filename = strcat(dayfd, ' lengths');
                    
                    out_fmt=handles.out_fmt;
                    if strcmp(out_fmt,'.xlsx')==1                   
                        xlswrite(fullfile([path '\' filename '.xlsx']),A)
                    elseif strcmp(out_fmt,'.csv')==1
                        AT=cell2table(A);
                        writetable(AT,fullfile([path '\' filename '.csv']),'Delimiter',',','WriteVariableNames',0)
                    elseif strcmp(out_fmt,'.txt')==1
                        AT=cell2table(A);
                        writetable(AT,fullfile([path '\' filename '.txt']),'Delimiter','tab','WriteVariableNames',0)
                    end
    save(fullfile([CF '\Whalength data\' 'A.mat']),'A')
    save(fullfile([CF '\Whalength data\' 'COUNT.mat']),'COUNT')
    set(handles.text9,'String','If more whales to measure in this picture click "Measure another whale". If finished with this image click "Next image"')
    
    uiwait(gcf) %waits for either 'next image' button or 'measure another whale' button or 'redo' button
    load(fullfile([CF '\Whalength data\' 'oops.mat']))
    
end

guidata(hObject,handles)
uiresume(gcbf)




% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%'FINISH' button
%Saves A as excel file in same folder as day image folder
CF=handles.CF;
load(fullfile([CF '\Whalength data\' 'A.mat']),'A')

dayfd=handles.dayfd;
path=handles.pathd;
                    filename = strcat(dayfd, ' lengths');
                    
                    out_fmt=handles.out_fmt;
                    if strcmp(out_fmt,'.xlsx')==1                   
                        xlswrite(fullfile([path '\' filename '.xlsx']),A)
                    elseif strcmp(out_fmt,'.csv')==1
                        AT=cell2table(A);
                        writetable(AT,fullfile([path '\' filename '.csv']),'Delimiter',',','WriteVariableNames',0)
                    elseif strcmp(out_fmt,'.txt')==1
                        AT=cell2table(A);
                        writetable(AT,fullfile([path '\' filename '.txt']),'Delimiter','tab','WriteVariableNames',0)
                    end
set(handles.text10, 'String', [filename out_fmt])
set(handles.pushbutton6, 'Value', 1)
fnsh=1;
save(fullfile([CF '\Whalength data\' 'fnsh.mat']),'fnsh')
set(handles.edit5,'String','Edit text')

guidata(gcbf,handles)
uiresume(gcbf)


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%MEASURE AT 10%TL button

%Define constants - constants and calculations by Pascal Sirguey
CF=handles.CF;
drone=handles.drone;
 load(fullfile([CF '\Whalength data\' 'CAL.mat']))



TL=handles.TL;
Lvec=handles.Lvec;
rect=handles.rect;
H=handles.H;
pct10TL=[0.1:0.1:0.9]*TL;
TLvec=Lvec(3,1:end);
xvec=Lvec(1,1:end-1);
yvec=Lvec(2,1:end-1);
pct10ws=zeros(1,9);
if H~=1
    ZP1=TL/3*150; %no. of pixels either side of click for first zoom
    ZP2=TL/5*150; %no. of pixels either side of click for 2nd zoom
else
    ZP1=TL/3*100*50; %no. of pixels either side of click for first zoom
    ZP2=TL/5*100*50; %no. of pixels either side of click for 2nd zoom
end

set(handles.text9,'String','Click where lines meet edge of whale, use right-click to zoom. Press ENTER to skip a measurement.')

for ind=1:length(pct10TL);
    % xlim([rect(1), rect(1)+rect(3)])
    % ylim([rect(2), rect(2)+rect(4)])
    ind10pct=find(TLvec>pct10TL(ind),1,'first');
    ind10pctv{ind}=ind10pct;
    %calculating perpendicular lines to clicked line segments on whale
    x1=xvec(ind10pct);
    y1=yvec(ind10pct);
    x0=xvec(ind10pct-1);
    y0=yvec(ind10pct-1);
    x2=xvec(ind10pct+1);
    y2=yvec(ind10pct+1);
    
    l=400; %length of one half of guideline
    m=(y2-y0)/(x2-x0); %gradient of length segment that 5% point is found on
    if m==0; %if the line segment is perfectly straight the inverse gradient is infinite!
        
        xg=[x1, x1];
        yg=[y1+l, y1-l];
        
    else
        mp=-1/m; %perpendicular gradient
        
        cp=y1-mp*x1; %intercept value of perp line
        
        %solving for plotting coordinates of ends of guideline
        a=1+mp^2;
        b=2*mp*cp-2*x1-2*y1*mp;
        c=cp^2+x1^2-2*y1*cp+y1^2-l^2;
        
        xg(1)=(-1*b+sqrt(b^2-4*a*c))/(2*a);
        xg(2)=(-1*b-sqrt(b^2-4*a*c))/(2*a);
        yg=mp*xg+cp;
        
    end
    % xv1=linspace(x1,xg(1),500);
    % yv1=mp*xv1+cp; %vector of points along one side of perpendicular line
    % xv2=linspace(x1,xg(2),500);
    % yv2=mp*xv2+cp; %vector of points along other side of perpendicular line
    % C=handles.C;
    hold on
    plot(x1,y1,'Marker','x','Color','b','LineStyle','none','MarkerSize',8,'LineWidth',2)
    
    plot(xg,yg,'LineStyle','-','Color','y')
    xlim([x1-ZP1, x1+ZP1])
    ylim([y1-ZP1, y1+ZP1])
    
    [xw1, yw1, butt]=ginputcross(1);
    
    if butt==3; %if right click zoom in on point
        
        xlim([xw1-ZP2, xw1+ZP2])
        ylim([yw1-ZP2, yw1+ZP2])
        [xw1,yw1,butt]=ginputcross(1);
        plot(xw1,yw1,'Marker','x','Color','y','LineStyle','none','MarkerSize',8,'LineWidth',2)
        xlim([x1-ZP1, x1+ZP1])
        ylim([y1-ZP1, y1+ZP1])
        
    elseif butt==1
        plot(xw1,yw1,'Marker','x','Color','y','LineStyle','none','MarkerSize',8,'LineWidth',2)
        
    else
        continue
    end
  
    [xw2, yw2, butt]=ginputcross(1);
    if butt==3; %if right click zoom in on point
        
        xlim([xw2-ZP2, xw2+ZP2])
        ylim([yw2-ZP2, yw2+ZP2])
        [xw2,yw2,butt]=ginputcross(1);
        plot(xw2,yw2,'Marker','x','Color','y','LineStyle','none','MarkerSize',8,'LineWidth',2)
        xlim([x1-ZP1, x1+ZP1])
        ylim([y1-ZP1, y1+ZP1])
        
    elseif butt==1
        plot(xw2,yw2,'Marker','x','Color','y','LineStyle','none','MarkerSize',8,'LineWidth',2)
    else
        continue
    end

    P1 = [(xw1-.5)-IW/2; IH/2-(yw1-.5)]*SCALE_F; %calculate pixel indices
    P2 = [(xw2-.5)-IW/2; IH/2-(yw2-.5)]*SCALE_F; %calculate pixel indices
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
    pct10ws(ind)=Dc; %stores width at each 5% interval
    if H==1;
        pct10ws(ind)=pct10ws(ind)*100/TL;
        set(handles.text8, 'String', strjoin({'Width (%TL):', num2str(pct10ws(ind))})); %print length under image
    else
        set(handles.text8, 'String', strjoin({'Width (m):', num2str(Dc)})); %print length under image
    end
    
    
    
end
xlim([rect(1), rect(1)+rect(3)])
ylim([rect(2), rect(2)+rect(4)])
hold off

% updata data storage cell, A
load(fullfile([CF '\Whalength data\' 'A.mat']))
load(fullfile([CF '\Whalength data\' 'COUNT.mat']))

A(COUNT,13:21)=num2cell(pct10ws);
save(fullfile([CF '\Whalength data\' 'A.mat']),'A')
set(handles.text9,'String','Measure widths, then set image qualities for this image then check "Correct?"')

guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function text4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in popupmenu1. define image sharpness
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1
CF=handles.CF;
sharp=get(hObject,'Value');
save(fullfile([CF '\Whalength data\' 'Imquals.mat']),'sharp','-append')

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1 - No longer used!.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

guidata(gcbf,handles)


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% SIDES CLEAR?
% Hint: get(hObject,'Value') returns toggle state of checkbox2
CF=handles.CF;
if (get(hObject,'Value') == get(hObject,'Max'))
    sides='Y';
else
    sides='N';
end
save(fullfile([CF '\Whalength data\' 'Imquals.mat']),'sides','-append')

guidata(gcbf,handles)

% --- Executes during object creation, after setting all properties.
function uipanel7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function uipanel7_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel1
% eventdata  structure with the following fields (see UIBUTTONGROUP)

% handles    structure with handles and user data (see GUIDATA)
CF=handles.CF;
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'radiobutton1'
        water='Calm';
    case 'radiobutton2'
        water='Ruffled';
end

save(fullfile([CF '\Whalength data\' 'Imquals.mat']),'water','-append')

guidata(hObject,handles)



% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% CORRECT?
% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in pushbutton8: WIDTH @ EYE.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CF=handles.CF;
COLOR='b';
handles.COLOR=COLOR;
[handles]=meas_width(handles);
W=handles.W;
load(fullfile([CF '\Whalength data\' 'A.mat']))
load(fullfile([CF '\Whalength data\' 'COUNT.mat']))

A{COUNT,22}=W;
save(fullfile([CF '\Whalength data\' 'A.mat']),'A')

% --- Executes on button press in pushbutton9: FLUKE WIDTH.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CF=handles.CF;
COLOR='g';
handles.COLOR=COLOR;
[handles]=meas_width(handles);
W=handles.W;
load(fullfile([CF '\Whalength data\' 'A.mat']))
load(fullfile([CF '\Whalength data\' 'COUNT.mat']))

A{COUNT,26}=W;
save(fullfile([CF '\Whalength data\' 'A.mat']),'A')

% --- Executes on button press in pushbutton10: ROSTRUM - BH.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CF=handles.CF;
COLOR='b';
handles.COLOR=COLOR;
[handles]=meas_width(handles);
W=handles.W;
load(fullfile([CF '\Whalength data\' 'A.mat']))
load(fullfile([CF '\Whalength data\' 'COUNT.mat']))

A{COUNT,24}=W;
save(fullfile([CF '\Whalength data\' 'A.mat']),'A')

% --- Executes on button press in pushbutton11: ROSTRUM - EYE.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CF=handles.CF;
COLOR='r';
handles.COLOR=COLOR;
[handles]=meas_width(handles);
W=handles.W;
load(fullfile([CF '\Whalength data\' 'A.mat']))
load(fullfile([CF '\Whalength data\' 'COUNT.mat']))

A{COUNT,23}=W;
save(fullfile([CF '\Whalength data\' 'A.mat']),'A')


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
CF=handles.CF;
contents = cellstr(get(hObject,'String'));
flukes=contents{get(hObject,'Value')};
save(fullfile([CF '\Whalength data\' 'Imquals.mat']),'flukes','-append')


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton12 - START OVER.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CF=handles.CF;
oops=1;
save(fullfile([CF '\Whalength data\' 'oops.mat']),'oops')
hold off
uiresume(gcbf)


% --- Executes on button press in pushbutton13 - SELECT SINGLE IMAGE.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CF=handles.CF;
drone=handles.drone;
try
    oldpath = handles.pathd;    %get previous file path
catch
    oldpath = [];
end
if~isempty(oldpath)
    fds=strsplit(oldpath,'\\');

    ll=length(fds{end});
    oldpath=oldpath(1:end-ll-1); %create path to folder which contains day folder ie one step back from pathd
    handles.oldpath=oldpath;

    [Sing_im,pathim] = uigetfile(fullfile(oldpath,'*.*'),'Select image...');
   
else

    [Sing_im,pathim] = uigetfile(fullfile('*.*'),'Select image...');
    
end

set(handles.text23,'String',Sing_im)
handles.pathd=pathim;
handles.subfolder=pathim;
handles.Sing_im=Sing_im;
handles.dayfd=Sing_im;
guidata(hObject,handles)            % Save the handles structure.



function edit2_Callback(hObject, eventdata, handles) %single image lidar height input
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
H=str2double(get(hObject,'String'));
handles.H=H;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton14 - GO: run single image analysis.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CF=handles.CF;
oops=0;
save(fullfile([CF '\Whalength data\' 'oops.mat']),'oops')
 load(fullfile([CF '\Whalength data\' 'CAL.mat']))
if ~isempty(handles.Sing_im) && ~isempty(handles.H)
    set(handles.text25, 'String', '    ')
   
    set(handles.text8, 'String', '   ');
    set(handles.text10, 'String', '   ')
    
    pathim=handles.pathd;
    Sing_im=handles.Sing_im;
   
    clear A
    %Defining output excel file headers for each column
    A{1,5}='Image quality';
    A{1,13}='Body width along body axis at 10% increments (if no lidar height, widths given as % of total length (TL)';
    A{1,32}='Body width along body axis at 5% increments (if no lidar height, widths given as % of total length (TL)';
    A(2,1:50)={'Whale ID','Image date','Corrected time','Filename','Image sharpness (1-4)','Flukes up? (@surface/straight/drooped)',...
    'Water (calm/ruffled)','Sides clear? (Y/N)','Tilt (degrees)','Corrected height (m)','Total Length (m)','"Pixel length" (to be scaled by height in m)',...
    'Width at 10% TL','Width at 20% TL','Width at 30% TL','Width at 40% TL','Width at 50% TL','Width at 60% TL',...
    'Width at 70% TL','Width at 80% TL','Width at 90% TL','Width @ eye','Rostrum-eye','Rostrum-BH','Rostrum-DF',...
    'Fluke width','BH-DF insertion','Width @ DF','Folder','Label (for mult.whales per image)','Notes','Width at 5% TL','Width at 10% TL',...
    'Width at 15% TL','Width at 20% TL','Width at 25% TL','Width at 30% TL','Width at 35% TL','Width at 40% TL',...
    'Width at 45% TL','Width at 50% TL','Width at 55% TL','Width at 60% TL','Width at 65% TL','Width at 70% TL',...
    'Width at 75% TL','Width at 80% TL','Width at 85% TL','Width at 90% TL','Width at 95% TL'};
    
    
    handles.A=A;
    save(fullfile([CF '\Whalength data\' 'A.mat']),'A') %first time A is saved
    COUNT=3;
    save(fullfile([CF '\Whalength data\' 'COUNT.mat']),'COUNT')
    handles.COUNT=COUNT;
    
    set(handles.text13, 'String', '   ')
    
    load(fullfile([CF '\Whalength data\' 'COUNT.mat']))
   
    set(handles.checkbox3,'Value',0)
    set(handles.edit4,'String','Edit text')
    unotes=[];
    save(fullfile([CF '\Whalength data\' 'Imquals.mat']),'unotes','-append')
    
    listing=dir(fullfile([pathim '\' Sing_im]));
    dattims=strsplit(listing.date);
    
    C = imread([pathim '\' Sing_im]);   %read the image
    handles.C=C;
    handles.dattims=dattims;
    
    set(handles.text4, 'String', Sing_im(1:end-4));              %show image name above image in GUI
    
    theta=handles.theta; %tilt angle from user input
        if isnan(theta)==1
           theta=0;            % if theta not provided, assume tilt is zero
        else
        end
    H=handles.H;       %lidar height from user input
    CLoffset=handles.CLoffset;
    H=H*cos(theta*pi/180)+CLoffset/100; %H corrected for tilt and camera offset relative to lidar, in metres
    handles.H=H;
    hold off
    image(C);
    xlim([0.5 IW+0.5])
    ylim([0.5 IH+0.5])
    axis equal                      %makes image square
    axis off
    
    if H==0 | isnan(H) | isempty(H)==1 | H<2;
        load(fullfile([CF '\Whalength data\' 'A.mat']),'A')
        load(fullfile([CF '\Whalength data\' 'COUNT.mat']),'COUNT')
        H=1;
        handles.H=H;
        handles=meas_whale(handles,hObject);
        TL=handles.TL;
        handles.A=A; %updates A in handles after measuring
        
        handles.COUNT=COUNT;

        A{COUNT,1}=inputdlg({'Provide ID number for this measured whale'},'Whale ID', [1 60]); %get whale ID after measuring whale
        
        A{COUNT,2}=dattims{1};
        A{COUNT,3}=dattims{2};
        A{COUNT,9}=theta;
        A{COUNT,10}='N/A';
        A{COUNT,29}=pathim;
        A{COUNT,4}=Sing_im;
        A{COUNT,11}='TL';
        A{COUNT,12}=TL/H; %'pixel length' to be scaled by height in metres
        
        save(fullfile([CF '\Whalength data\' 'A.mat']),'A')
        handles.A=A;
        handles.CT=dattims{2};
        handles.CONT=[];
        guidata(hObject,handles)
        
    else
        load(fullfile([CF '\Whalength data\' 'A.mat']),'A')
        load(fullfile([CF '\Whalength data\' 'COUNT.mat']),'COUNT')
        
        handles=meas_whale(handles,hObject);
        
        TL=handles.TL;

        A{COUNT,1}=inputdlg({'Provide ID number for this measured whale'},'Whale ID', [1 60]); %get whale ID after measuring whale
        
        A{COUNT,2}=dattims{1};
        A{COUNT,3}=dattims{2};
        A{COUNT,9}=theta;
        A{COUNT,10}=H;
        A{COUNT,29}=pathim;
        A{COUNT,4}=Sing_im;
        A{COUNT,11}=TL;
        A{COUNT,12}=TL/H; %'pixel length' to be scaled by height in metres
    end
    
    save(fullfile([CF '\Whalength data\' 'A.mat']),'A')
    handles.A=A;
    handles.CT=dattims{2};
    handles.CONT=[];
    guidata(hObject,handles)
    
    waitfor(handles.checkbox3,'Value'); %waits for 'Correct?' checkbox to be ticked so image properties are set before moving on to next whale or image
    load(fullfile([CF '\Whalength data\' 'A.mat']))
    load(fullfile([CF '\Whalength data\' 'Imquals.mat']))
    drawnow()
    A{COUNT,5}=sharp;
    A{COUNT,7}=water;
    A{COUNT,6}=flukes;
    A{COUNT,8}=sides;
    A{COUNT,31}=unotes;
    
    COUNT=COUNT+1;
    handles.COUNT=COUNT;
    save(fullfile([CF '\Whalength data\' 'A.mat']),'A')
    save(fullfile([CF '\Whalength data\' 'COUNT.mat']),'COUNT')
    set(handles.text9,'String','If more whales to measure in this picture click "Measure another whale". If finished with this image click "Finish"')
    
    uiwait(gcf) %waits for either 'Finish' button or 'measure another whale' button
    
else
    set(handles.text25, 'String', 'Please choose image and enter lidar height')
end
guidata(hObject,handles)



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
CF=handles.CF;
unotes=get(hObject,'String');
if iscell(unotes)
    unotes=unotes{1};
else
end
save(fullfile([CF '\Whalength data\' 'Imquals.mat']),'unotes','-append')

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles) %starting from non-first image in excel file
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double
CF=handles.CF;
startim=get(hObject,'String');
bestims=handles.bestims;
for ind=1:length(bestims)
    index = strcmpi(bestims{ind},startim);
    if index==1
        break
    else
    end
end
handles.subf_ind=ind;
handles.bestim_ind=index;
guidata(hObject,handles)



% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton17.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%MEASURE AT 5%TL button

%Define constants - constants and calculations by Pascal Sirguey
CF=handles.CF;
 load(fullfile([CF '\Whalength data\' 'CAL.mat']))

TL=handles.TL;
Lvec=handles.Lvec;
rect=handles.rect;
H=handles.H;
pct5TL=[0.05:0.05:0.95]*TL;
TLvec=Lvec(3,1:end);
xvec=Lvec(1,1:end-1);
yvec=Lvec(2,1:end-1);
pct5ws=zeros(1,19);
if H~=1
    ZP1=TL/3*150; %no. of pixels either side of click for first zoom
    ZP2=TL/5*150; %no. of pixels either side of click for 2nd zoom
else
    ZP1=TL/3*100*50; %no. of pixels either side of click for first zoom
    ZP2=TL/5*100*50; %no. of pixels either side of click for 2nd zoom
end
set(handles.text9,'String','Click where lines meet edge of whale, use right-click to zoom. Press ENTER to skip a measurement.')

for ind=1:length(pct5TL);
    % xlim([rect(1), rect(1)+rect(3)])
    % ylim([rect(2), rect(2)+rect(4)])
    ind5pct=find(TLvec>pct5TL(ind),1,'first');
    ind5pctv{ind}=ind5pct;
    %calculating perpendicular lines to clicked line segments on whale
    x1=xvec(ind5pct);
    y1=yvec(ind5pct);
    x0=xvec(ind5pct-1);
    y0=yvec(ind5pct-1);
    x2=xvec(ind5pct+1);
    y2=yvec(ind5pct+1);
    
    l=400; %length of one half of guideline
    m=(y2-y0)/(x2-x0); %gradient of length segment that 5% point is found on
    if m==0; %if the line segment is perfectly straight the inverse gradient is infinite!
        
        xg=[x1, x1];
        yg=[y1+l, y1-l];
        
    else
        mp=-1/m; %perpendicular gradient
        
        cp=y1-mp*x1; %intercept value of perp line
        
        %solving for plotting coordinates of ends of guideline
        a=1+mp^2;
        b=2*mp*cp-2*x1-2*y1*mp;
        c=cp^2+x1^2-2*y1*cp+y1^2-l^2;
        
        xg(1)=(-1*b+sqrt(b^2-4*a*c))/(2*a);
        xg(2)=(-1*b-sqrt(b^2-4*a*c))/(2*a);
        yg=mp*xg+cp;
        
    end
    % xv1=linspace(x1,xg(1),500);
    % yv1=mp*xv1+cp; %vector of points along one side of perpendicular line
    % xv2=linspace(x1,xg(2),500);
    % yv2=mp*xv2+cp; %vector of points along other side of perpendicular line
    % C=handles.C;
    hold on
    plot(x1,y1,'Marker','x','Color','b','LineStyle','none','MarkerSize',8,'LineWidth',2)
    
    plot(xg,yg,'LineStyle','-','Color','y')
    xlim([x1-ZP1, x1+ZP1])
    ylim([y1-ZP1, y1+ZP1])
    
    [xw1, yw1, butt]=ginputcross(1);
    
    if butt==3; %if right click zoom in on point
        
        xlim([xw1-ZP2, xw1+ZP2])
        ylim([yw1-ZP2, yw1+ZP2])
        [xw1,yw1,butt]=ginputcross(1);
        plot(xw1,yw1,'Marker','x','Color','y','LineStyle','none','MarkerSize',8,'LineWidth',2)
        xlim([x1-ZP1, x1+ZP1])
        ylim([y1-ZP1, y1+ZP1])
        
    elseif butt==1
        plot(xw1,yw1,'Marker','x','Color','y','LineStyle','none','MarkerSize',8,'LineWidth',2)
        
    else
        continue
    end
  
    [xw2, yw2, butt]=ginputcross(1);
    if butt==3; %if right click zoom in on point
        
        xlim([xw2-ZP2, xw2+ZP2])
        ylim([yw2-ZP2, yw2+ZP2])
        [xw2,yw2,butt]=ginputcross(1);
        plot(xw2,yw2,'Marker','x','Color','y','LineStyle','none','MarkerSize',8,'LineWidth',2)
        xlim([x1-ZP1, x1+ZP1])
        ylim([y1-ZP1, y1+ZP1])
        
    elseif butt==1
        plot(xw2,yw2,'Marker','x','Color','y','LineStyle','none','MarkerSize',8,'LineWidth',2)
    else
        continue
    end

    P1 = [(xw1-.5)-IW/2; IH/2-(yw1-.5)]*SCALE_F; %calculate pixel indices
    P2 = [(xw2-.5)-IW/2; IH/2-(yw2-.5)]*SCALE_F; %calculate pixel indices
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
    pct5ws(ind)=Dc; %stores width at each 5% interval
    if H==1;
        pct5ws(ind)=pct5ws(ind)*100/TL;
        set(handles.text8, 'String', strjoin({'Width (%TL):', num2str(pct5ws(ind))})); %print length under image
    else
        set(handles.text8, 'String', strjoin({'Width (m):', num2str(Dc)})); %print length under image
    end
    
    
    
end
xlim([rect(1), rect(1)+rect(3)])
ylim([rect(2), rect(2)+rect(4)])
hold off

% updata data storage cell, A
load(fullfile([CF '\Whalength data\' 'A.mat']))
load(fullfile([CF '\Whalength data\' 'COUNT.mat']))

A(COUNT,32:50)=num2cell(pct5ws);
save(fullfile([CF '\Whalength data\' 'A.mat']),'A')
set(handles.text9,'String','Measure widths, then set image qualities for this image then check "Correct?"')

guidata(hObject,handles)


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% if checked will use corrections as calculated by Pascal, otherwise
% assumes no abberation, with a focal length of 24.851372
% Hint: get(hObject,'Value') returns toggle state of checkbox4
drone=get(hObject,'Value');

handles.drone=drone;
set(handles.checkbox4,'Value',drone)
CF=handles.CF;

save(fullfile([CF '\Whalength data\' 'drone.mat']),'drone')
guidata(hObject,handles)



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double
theta=str2double(get(hObject,'String'));
handles.theta=theta;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton18.
function pushbutton18_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Offset = inputdlg({'Offset'},'Give offset between camera image plane and LIDAR in cm...', [1 60]);
CLoffset=str2num(cell2mat(Offset));
set(handles.text32,'String',{'Offset:';CLoffset})
CF=handles.CF;
handles.CLoffset=CLoffset;
save(fullfile([CF '\Whalength data\' 'Offset.mat']),'CLoffset')
guidata(hObject,handles)            % Save the handles structure.


% --- Executes during object creation, after setting all properties.
function text33_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text33 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in pushbutton19.
function pushbutton19_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CF=handles.CF;

[handles]=Rost_DF(handles,hObject);
RDF=handles.RDF;
load(fullfile([CF '\Whalength data\' 'A.mat']))
load(fullfile([CF '\Whalength data\' 'COUNT.mat']))

A{COUNT,25}=RDF;
save(fullfile([CF '\Whalength data\' 'A.mat']),'A')


% --- Executes on button press in pushbutton20.
function pushbutton20_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
CF=handles.CF;
COLOR='g';
handles.COLOR=COLOR;
[handles]=meas_width(handles);
W=handles.W;
load(fullfile([CF '\Whalength data\' 'A.mat']))
load(fullfile([CF '\Whalength data\' 'COUNT.mat']))

A{COUNT,27}=W;
save(fullfile([CF '\Whalength data\' 'A.mat']),'A')


% --- Executes on button press in pushbutton22. WIDTH @ DF
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

CF=handles.CF;
COLOR='r';
handles.COLOR=COLOR;
[handles]=meas_width(handles);
W=handles.W;

load(fullfile([CF '\Whalength data\' 'A.mat']))
load(fullfile([CF '\Whalength data\' 'COUNT.mat']))

A{COUNT,28}=W;
save(fullfile([CF '\Whalength data\' 'A.mat']),'A')
