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

% Last Modified by GUIDE v2.5 25-May-2017 16:44:58

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
im = imread(handles.imageToBeUsed);
net = load('data/trainedNet/trainedNet.mat');
net.layers{end}.type = 'softmax';

tic;
%Height of pedestrians in the image database are between 180-390
%pixels.
%Window size should be big enough to see the pedestrians 
windowSize = [100,250];
    
%Corner of window
Xmin = 1; 
Ymin = 1;

[Ymax, Xmax, d] = size(im);

%need error checking
bbox = struct();
bbox.box = [];
count = 1;
    %Loop through the possible windows 
    for y = Ymin:(windowSize(2)/2):(Ymax - windowSize(2))
        for x = Xmin:(windowSize(1)):(Xmax - windowSize(1))
            windowBox =  [x, y, windowSize(1)-1, windowSize(2)-1];
            %windowBox = [20,20,100,300]
            %Crop the window out of the image
            windowIm = imcrop(im, windowBox);
            im_ =single(windowIm);
            im_ = imresize(im_, net.meta.normalization.imageSize(1:2)) ;
            im_ = im_ - net.meta.imageMean ;
            res = vl_simplenn(net,im_);
            scores = squeeze(gather(res(end).x)) ;
            [bestScore, best] = max(scores) ;
            
            %If the window detects a pedestrian
           if(best ==  1)
                bbox.box{count} = windowBox;
                bbox.score{count} = bestScore;
                count = count + 1;
%                figure(1) ; clf ;  imagesc(im) ; 
%                rectangle('Position', windowBox, 'EdgeColor','g','LineWidth',2);
%                title(sprintf('%s (%d), score %.3f',...
%                  net.meta.classes.description{best}, best, bestScore)) ;
           end
            
            
        end
    end
    

    
    %Put bounding boxes over the image
    axes(handles.axes1);
    
    imagesc(im) ; 
    axis off
    for ii= 1:length(bbox.box)
     rectangle('Position', bbox.box{ii}, 'EdgeColor','g','LineWidth',2);
     text(bbox.box{ii}(1)-10, bbox.box{ii}(2)-10, sprintf('%.3f', bbox.score{ii}), 'Color', 'red','FontSize',14);
    end    
            
elapsedTime = toc*1000;


% --- Executes during object creation, after setting all properties.
function text4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
