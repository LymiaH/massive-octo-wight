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

% Last Modified by GUIDE v2.5 26-May-2017 09:29:25

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

% Update handles structure
guidata(hObject, handles);

%Run setup script
setup;
%Make the axis blank by default.
handles.imageDefault = [0, 0; 0, 0];
axes(handles.axes1);
imshow(handles.imageDefault);

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
    
%For every pedestrian that was detected, put bounding boxes over the image
axes(handles.axes1);
imagesc(im) ; 
axis off
for ii= 1:length(bbox.box)
    rectangle('Position', bbox.box{ii}, 'EdgeColor','g','LineWidth',2);
    text(bbox.box{ii}(1)-10, bbox.box{ii}(2)-10, sprintf('%.3f', bbox.score{ii}), 'Color', 'red','FontSize',14);
end    
            
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
