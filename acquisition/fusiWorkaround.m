function varargout = fusiWorkaround(varargin)
% FUSIWORKAROUND MATLAB code for fusiWorkaround.fig
%      FUSIWORKAROUND, by itself, creates a new FUSIWORKAROUND or raises the existing
%      singleton*.
%
%      H = FUSIWORKAROUND returns the handle to a new FUSIWORKAROUND or the handle to
%      the existing singleton*.
%
%      FUSIWORKAROUND('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FUSIWORKAROUND.M with the given input arguments.
%
%      FUSIWORKAROUND('Property','Value',...) creates a new FUSIWORKAROUND or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fusiWorkaround_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fusiWorkaround_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fusiWorkaround

% Last Modified by GUIDE v2.5 12-Dec-2018 16:49:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @fusiWorkaround_OpeningFcn, ...
    'gui_OutputFcn',  @fusiWorkaround_OutputFcn, ...
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


% --- Executes just before fusiWorkaround is made visible.
function fusiWorkaround_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fusiWorkaround (see VARARGIN)

global SCAN
% Choose default command line output for fusiWorkaround
handles.output = hObject;

p = dat.paths;
handles.textLocal.String = sprintf('Local repo: %s', p.localRepository);
handles.textFull.String = sprintf('Full data: %s', SCAN.folderFullData);
handles.checkBFFilt.Value = 1;
handles.saveBF = handles.checkBF.Value;
handles.saveBFFilt = handles.checkBFFilt.Value;
if ~isempty(varargin)
    handles.fusVersion = varargin{1};
else
    handles.fusVersion = 'v19.4b';
end

if handles.checkBF.Value || handles.checkBFFilt.Value
    if isequal(handles.fusVersion, '')
    diskSpaceWarning;
end
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fusiWorkaround wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fusiWorkaround_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in RUN_pushbutton.
function RUN_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to RUN_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global SCAN

switch handles.fusVersion
    case 'v19.4b'
        po = procObj(handles);
        set(hObject, 'Enable', 'off', 'String', 'Running...');
        handles.checkBF.Enable = 'off';
        handles.checkBFFilt.Enable = 'off';
        nFrames = ceil(7200/SCAN.periodFilm); % nFrames for two hour recording
        SCAN.FilmDoppler(max(SCAN.Nimag, nFrames), SCAN.periodFilm, 'LQ', po);
        set(hObject, 'Enable', 'on', 'String', 'START (paused)');
        handles.checkBF.Enable = 'on';
        handles.checkBFFilt.Enable = 'on';
    case 'R07PX'
        pof = procObjFast(handles);
        set(hObject, 'Enable', 'off', 'String', 'Running...');
        handles.checkBF.Enable = 'off';
        handles.checkBFFilt.Enable = 'off';
        if (handles.checkBF.Value || handles.checkBFFilt.Value)
            % make sure the full data will be saved
            SCAN.fullData = 1;
            SCAN.H.fullData.Value = 1;
        % create a new folder for the full data
            SCAN.fileNames = ...
                fullfile(SCAN.folderFullData, ['current_', datestr(now, 'HHMMSS'), '_BF']);
            mkdir(SCAN.fileNames);
            % show the warning dialog with disk space info
            diskSpaceWarning(SCAN);
        end
        
        [xx, zz, tt] = SCAN.getAxis;
        singleBlockDuration = SCAN.parSeq.HQ.NfrBk*tt(1);
        nBlocks = SCAN.Nblock; % nBlocks to average for each frame
        nFrames = ceil(7200/singleBlockDuration/nBlocks); % two hours of recording
        SCAN.Nimag = nFrames;
        I = SCAN.FilmFast(2, nBlocks, nFrames, pof);
        SCAN.Nimag = str2num(SCAN.H.Nimag.String);
        set(hObject, 'Enable', 'on', 'String', 'START (paused)');
        handles.checkBF.Enable = 'on';
        handles.checkBFFilt.Enable = 'on';
        saveDopplerMovie(SCAN)
        renameFullData(SCAN);
        
        dummyPath = 'D:\junk';
        mkSuccess = true;
        if ~exist(dummyPath, 'dir')
            [mkSuccess, message] = mkdir(dummyPath);
        end
        if mkSuccess
            fprintf('Dummy %s folder successfully created\n', dummyPath);
            setFolder(dummyPath); %also creates subfolders (fus, fulldata, info, images)
            SCAN.fulldata = SCAN.folderFullData;
            SCAN.fileNames = ...
                fullfile(SCAN.folderFullData, ['current_', datestr(now, 'HHMMSS'), '_BF']);
            mkdir(SCAN.fileNames);
            % turn off full data saving
            SCAN.fullData = 0;
            SCAN.H.fullData.Value = 0;

        else
            error('There was a problem creating %s. %s\n', dummyPath, message');
        end
        setFileName('test'); % sets SCAN.experimentName
%         SCAN.fulldata = 'Z:\testNewVersion';
    otherwise
        warning(sprintf('Fus version ''%s'' not supported', handles.fusVersion));
end

% --- Executes on button press in checkBF.
function checkBF_Callback(hObject, eventdata, handles)
% hObject    handle to checkBF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkBF

handles.saveBF = hObject.Value ~= 0;
if hObject.Value
    diskSpaceWarning;
end
guidata(hObject, handles);



% --- Executes on button press in checkBFFilt.
function checkBFFilt_Callback(hObject, eventdata, handles)
% hObject    handle to checkBFFilt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkBFFilt

handles.saveBFFilt = hObject.Value ~= 0;
if hObject.Value
    diskSpaceWarning;
end
guidata(hObject, handles);
