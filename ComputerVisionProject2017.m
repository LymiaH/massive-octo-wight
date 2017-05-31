function varargout = ComputerVisionProject2017(varargin)
% COMPUTERVISIONPROJECT2017 MATLAB code for ComputerVisionProject2017.fig
%      COMPUTERVISIONPROJECT2017, by itself, creates a new COMPUTERVISIONPROJECT2017 or raises the existing
%      singleton*.
%
%      H = COMPUTERVISIONPROJECT2017 returns the handle to a new COMPUTERVISIONPROJECT2017 or the handle to
%      the existing singleton*.
%
%      COMPUTERVISIONPROJECT2017('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COMPUTERVISIONPROJECT2017.M with the given input arguments.
%
%      COMPUTERVISIONPROJECT2017('Property','Value',...) creates a new COMPUTERVISIONPROJECT2017 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ComputerVisionProject2017_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ComputerVisionProject2017_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ComputerVisionProject2017

% Last Modified by GUIDE v2.5 30-May-2017 11:59:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ComputerVisionProject2017_OpeningFcn, ...
                   'gui_OutputFcn',  @ComputerVisionProject2017_OutputFcn, ...
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


% --- Executes just before ComputerVisionProject2017 is made visible.
function ComputerVisionProject2017_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ComputerVisionProject2017 (see VARARGIN)

% Choose default command line output for ComputerVisionProject2017
handles.output = hObject;



%Run setup script
setup;

%Load the trained model
handles.net = load('data/trainedNet/trainedNet-caffe-alex.mat');

%Make the axis blank by default.
handles.imageDefault = [0, 0; 0, 0];
axes(handles.axes1);
imshow(handles.imageDefault);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ComputerVisionProject2017 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ComputerVisionProject2017_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Load Image
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Allows user to load an image into the GUI
[FileName, PathName] = uigetfile({'*.*';'*.jpg';'*.png'},'Select an image');

%Store the image to be used in the handles variable
handles.imageToBeUsed = strcat(PathName, FileName);

%Read the image
im = imread(handles.imageToBeUsed);

%Plot image on the first axes
axes(handles.axes1);
imshow(im);

%Store the varaibles so it is accessible in another Callbacks and functions
guidata(hObject,handles);


% --- Executes on button press in pushbutton3.
% --- Method 1 Pedestrian Detection
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get the image that was loaded in the gui
im = imread(handles.imageToBeUsed);

%Load the trained model
net = load('data/trainedNet/trainedNet.mat');

%Change the last layer to softmax so the net can classify
net.layers{end}.type = 'softmax';

%Start Timer
tic;

%Set Window (boundary box) size
windowSize = [100,250];
    
%Corner of window
Xmin = 1; 
Ymin = 1;

%Get coordinates for the edges of the image
[Ymax, Xmax, d] = size(im);

%Create Boundary box struct to hold boxes that detect pedestrians
bbox = struct();
bbox.box = [];
count = 1;
%Loop through the possible windows 
for y = Ymin:(windowSize(2)/2):(Ymax - windowSize(2))
    for x = Xmin:(windowSize(1)):(Xmax - windowSize(1))
		%Get the boundary box window coordinates
        windowBox =  [x, y, windowSize(1)-1, windowSize(2)-1];
		
        %Crop the window out of the image
        windowIm = imcrop(im, windowBox);
		
		%Preprocess window image
        im_ =single(windowIm);
        im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
        im_ = im_ - net.meta.imageMean ;
		
		%Pass window image to the CNN to extract features
        res = vl_simplenn(net,im_);
		
		%Get the classification results
        scores = squeeze(gather(res(end).x)) ;
        [bestScore, best] = max(scores) ;
            
        %If the window detects a pedestrian, put the window image coordinates in the boundary box struct
        if(best ==  1)
			bbox.box{count} = windowBox;
            bbox.score{count} = bestScore;
            count = count + 1;
        end      
    end
end
    

%To deal with some of the vertical overlap, loop over the bboxes to find where x coordinate
%is the same. Then only keep the highest bbox
for ii = 1:length(bbox.box)
    for jj = ii+1:length(bbox.box)
        if jj <= length(bbox.box)&& ~isempty(bbox.box{ii}) && ~isempty(bbox.box{jj})
            if bbox.box{ii}(1) == bbox.box{jj}(1) 
                 if bbox.score{ii}>bbox.score{jj}
                     bbox.box{jj} = [];
                     bbox.score{jj}=[];
                 else
                     bbox.box{ii} =[];
                     bbox.score{ii}=[];
                 end
            end
        end
    end
end


%For every pedestrian that was detected, put bounding boxes over the image
axes(handles.axes1);
imshow(im) ; 
axis off
for ii= 1:length(bbox.box)
    if~isempty(bbox.box{ii})
        rectangle('Position', bbox.box{ii}, 'EdgeColor','g','LineWidth',2);
        text(bbox.box{ii}(1)-10, bbox.box{ii}(2)-10, sprintf('%.3f', bbox.score{ii}), 'Color', 'red','FontSize',14);
    end
end

%End timer
elapsedTime = round(toc*1000);

%Print the detection time in the gui
detectionTimeLabel = sprintf('%.f ms', elapsedTime);
set(handles.edit1, 'String', detectionTimeLabel);
guidata(hObject,handles);

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4.
% --- Method 2 Pedestrian Detection
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Get the image that was loaded in the gui
%im = imread(handles.imageToBeUsed);


%Start Timer
tic;

%Lets the image show in the GUI
axes(handles.axes1);

%find bounding boxes
find_bbox(handles, handles.net,handles.imageToBeUsed,handles.ratio,handles.interval)

%End timer
elapsedTime = round(toc*1000);

%Print the detection time in the gui
detectionTimeLabel = sprintf('%.f ms', elapsedTime);
set(handles.edit1, 'String', detectionTimeLabel);
guidata(hObject,handles);



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
if isfield(handles,'interval')
    handles.interval = str2double(get(hObject,'String'));
    guidata(hObject,handles);
end

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

%Sets the default sigma value. It was set as 2 in GUIDE.
handles.interval = str2double(get(hObject,'String'));
guidata(hObject,handles);



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
if isfield(handles,'ratio')
    handles.ratio = str2double(get(hObject,'String'));
    guidata(hObject,handles);
end


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%Sets the default sigma value. It was set as 2 in GUIDE.
handles.ratio = str2double(get(hObject,'String'));
guidata(hObject,handles);
