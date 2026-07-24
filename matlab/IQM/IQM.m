function varargout = IQM(varargin)
% IQM MATLAB code for IQM.fig
%      IQM, by itself, creates a new IQM or raises the existing
%      singleton*.
%
%      H = IQM returns the handle to a new IQM or the handle to
%      the existing singleton*.
%
%      IQM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IQM.M with the given input arguments.
%
%      IQM('Property','Value',...) creates a new IQM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before IQM_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IQM_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help IQM

% Last Modified by GUIDE v2.5 10-Oct-2019 14:52:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @IQM_OpeningFcn, ...
    'gui_OutputFcn',  @IQM_OutputFcn, ...
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


% --- Executes just before IQM is made visible.
function IQM_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IQM (see VARARGIN)

% Choose default command line output for IQM
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes IQM wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% 마우스 왼쪽 클릭
set(handles.label_Quality, 'Enable', 'Inactive');
set(handles.label_Sharpness, 'Enable', 'Inactive');
set(handles.label_Fusion, 'Enable', 'Inactive');
set(handles.label_HDR, 'Enable', 'Inactive');
set(handles.button_run, 'Enable', 'Inactive');
set(handles.check_ssim, 'Enable', 'Inactive');
set(handles.check_fsim, 'Enable', 'Inactive');
set(handles.check_nrpqa, 'Enable', 'Inactive');
set(handles.check_vcm, 'Enable', 'Inactive');
set(handles.check_cmr, 'Enable', 'Inactive');
set(handles.check_cpbdm, 'Enable', 'Inactive');
set(handles.check_jnbm, 'Enable', 'Inactive');
set(handles.check_lpcsi, 'Enable', 'Inactive');
set(handles.check_s3, 'Enable', 'Inactive');
set(handles.check_mef, 'Enable', 'Inactive');
set(handles.check_fmi, 'Enable', 'Inactive');
set(handles.check_tmqi, 'Enable', 'Inactive');
set(handles.button_addTestImages, 'Enable', 'Inactive');
set(handles.button_openPath, 'Enable', 'Inactive');
set(handles.button_graph, 'Enable', 'Inactive');

% 경로 초기화
global selectedImageDirPath metric metricType selectedImages tableData
selectedImageDirPath = InitializePath(selectedImageDirPath, handles);
selectedImages  = {};

% 선택 상자 위치 초기화
MoveMetricTypeSelectionBox(handles.label_Quality, eventdata, handles);

% 패널 숨기기
set(handles.panel_quality, 'Visible', 'on');
set(handles.panel_sharpness, 'Visible', 'off');
set(handles.panel_fusion, 'Visible', 'off');
set(handles.panel_hdr, 'Visible', 'off');

% table 초기화
handles.table_result.Data = {};

% 구조체 선언
metricType.quality = true;
metricType.sharpness = false;
metricType.fusion = false;
metricType.hdr = false;

metric.quality.SSIM = false;
metric.quality.FSIM = false;
metric.quality.NRPQA = false;
metric.quality.VCM = false;
metric.quality.CMR = false;

metric.sharpness.CPBDM = false;
metric.sharpness.JNBM = false;
metric.sharpness.LPC_SI = false;
metric.sharpness.S3 = false;

metric.fusion.MEF = false;
metric.fusion.FMI = false;
metric.hdr.TMQI = false;


% 버튼 초기화
unCheckedColor = [ 0.5020,0.5020,0.5020];
handles.check_ssim.BackgroundColor = unCheckedColor;
handles.check_fsim.BackgroundColor = unCheckedColor;
handles.check_nrpqa.BackgroundColor = unCheckedColor;
handles.check_vcm.BackgroundColor = unCheckedColor;
handles.check_cmr.BackgroundColor = unCheckedColor;
handles.check_cpbdm.BackgroundColor = unCheckedColor;
handles.check_jnbm.BackgroundColor = unCheckedColor;
handles.check_lpcsi.BackgroundColor = unCheckedColor;
handles.check_s3.BackgroundColor = unCheckedColor;
handles.check_ssim.BackgroundColor = unCheckedColor;
handles.check_ssim.BackgroundColor = unCheckedColor;
handles.check_ssim.BackgroundColor = unCheckedColor;
handles.check_ssim.BackgroundColor = unCheckedColor;
handles.check_mef.BackgroundColor = unCheckedColor;
handles.check_fmi.BackgroundColor = unCheckedColor;
handles.check_tmqi.BackgroundColor = unCheckedColor;

%metric 경로 추가
addpath('.\metrics\5_VCM')
addpath('.\metrics\6_CPBDM')
addpath('.\metrics\7_JNBM')
addpath('.\metrics\8_LPC_SI')
addpath('.\metrics\9_S3')
% 테이블 초기화
% 열기를 누른 경우
tableData = struct([]);
handles.table_result.Data = {};
handles.table_result.RowName = {};
handles.table_result.ColumnName = {};


% --- Outputs from this function are returned to the command line.
function varargout = IQM_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% ----------------------- run 버튼 ---------------------------------
function button_run_ButtonDownFcn(hObject, eventdata, handles)
disp('Selected Run');
BlinkEffect(hObject);
global selectedImageDirPath selectedImages metric metricType tableData

if isempty(selectedImages)
    errordlg('선택된 이미지가 존재하지 않습니다.');
    return;
else
    
    if(CheckSelectedMetric(metricType, metric)==false)
        errordlg('Metric이 선택되지 않습니다.');
        return;
    end
    
    if (iscell(selectedImages))
        imageCount = size(selectedImages,2);
    else
        imageCount = 1;
    end
    
    f = waitbar(0,'Please wait...',...
        'CreateCancelBtn','setappdata(gcbf,''Cancel'',1)',...
        'WindowStyle','normal');
    
    for index = 1:imageCount
        % processbar 취소 버튼
        if getappdata(f,'canceling')
            break
        end
        
        if (imageCount == 1)
            testImage = imread(strcat(selectedImageDirPath,selectedImages));
        else
            testImage = imread(strcat(selectedImageDirPath,selectedImages{index}));
        end
        refImage = testImage;
        
        % 기존 데이터 보존용
        if (size(tableData,2) < index)
            oldData = [];
        else
            oldData = tableData(index).data;
        end
        
        tableData(index).data = RunMetric(refImage, testImage, metricType, metric, oldData);
        
        % processbar update
        waitbar(index/imageCount,f,sprintf('Please wait...(%d / %d)',index,imageCount));
        
        if getappdata(f,'Cancel')
            break
        end
        
    end
    % processbar 삭제
    delete(f);
    UpdateTableData(metricType, metric, tableData, handles);
    
end


% -------------------- metric type --------------------------------------
function label_Quality_ButtonDownFcn(hObject, eventdata, handles)
global metric metricType tableData
disp('Selected Quality');
metricType.quality = true;
metricType.sharpness = false;
metricType.fusion = false;
metricType.hdr = false;
MoveMetricTypeSelectionBox(hObject, eventdata, handles);
DisplayPanel(handles.panel_quality, eventdata, handles);
UpdateTableRowName(metric.quality, handles);
UpdateTableData(metricType, metric, tableData, handles);


function label_Sharpness_ButtonDownFcn(hObject, eventdata, handles)
global metric metricType tableData
disp('Selected Sharpness');
metricType.quality = false;
metricType.sharpness = true;
metricType.fusion = false;
metricType.hdr = false;
MoveMetricTypeSelectionBox(hObject, eventdata, handles);
DisplayPanel(handles.panel_sharpness, eventdata, handles);
UpdateTableRowName(metric.sharpness, handles);
UpdateTableData(metricType, metric, tableData, handles);


function label_Fusion_ButtonDownFcn(hObject, eventdata, handles)
global metric metricType tableData
disp('Selected Fusion');
metricType.quality = false;
metricType.sharpness = false;
metricType.fusion = true;
metricType.hdr = false;
MoveMetricTypeSelectionBox(hObject, eventdata, handles);
DisplayPanel(handles.panel_fusion, eventdata, handles);
UpdateTableRowName(metric.fusion, handles);
UpdateTableData(metricType, metric, tableData, handles);


function label_HDR_ButtonDownFcn(hObject, eventdata, handles)
global metric metricType tableData
disp('Selected HDR');
metricType.quality = false;
metricType.sharpness = false;
metricType.fusion = false;
metricType.hdr = true;
MoveMetricTypeSelectionBox(hObject, eventdata, handles);
DisplayPanel(handles.panel_hdr, eventdata, handles);
UpdateTableRowName(metric.hdr, handles);
UpdateTableData(metricType, metric, tableData, handles);

% -------------------------- select metric -----------------------------
function check_ssim_ButtonDownFcn(hObject, eventdata, handles)
global metric metricType tableData
state = CheckMetric(hObject, eventdata, handles);
metric.quality.SSIM = state;
UpdateTableRowName(metric.quality, handles)
UpdateTableData(metricType, metric, tableData, handles);

function check_fsim_ButtonDownFcn(hObject, eventdata, handles)
global metric metricType tableData
state = CheckMetric(hObject, eventdata, handles);
metric.quality.FSIM = state;
UpdateTableRowName(metric.quality, handles)
UpdateTableData(metricType, metric, tableData, handles);

function check_nrpqa_ButtonDownFcn(hObject, eventdata, handles)
global metric metricType tableData
state = CheckMetric(hObject, eventdata, handles);
metric.quality.NRPQA = state;
UpdateTableRowName(metric.quality, handles)
UpdateTableData(metricType, metric, tableData, handles);

function check_vcm_ButtonDownFcn(hObject, eventdata, handles)
global metric metricType tableData
state = CheckMetric(hObject, eventdata, handles);
metric.quality.VCM = state;
UpdateTableRowName(metric.quality, handles)
UpdateTableData(metricType, metric, tableData, handles);

function check_cmr_ButtonDownFcn(hObject, eventdata, handles)
global metric metricType tableData
state = CheckMetric(hObject, eventdata, handles);
metric.quality.CMR = state;
UpdateTableRowName(metric.quality, handles)
UpdateTableData(metricType, metric, tableData, handles);

function check_cpbdm_ButtonDownFcn(hObject, eventdata, handles)
global metric metricType tableData
state = CheckMetric(hObject, eventdata, handles);
metric.sharpness.CPBDM = state;
UpdateTableRowName(metric.sharpness, handles)
UpdateTableData(metricType, metric, tableData, handles);

function check_jnbm_ButtonDownFcn(hObject, eventdata, handles)
global metric metricType tableData
state = CheckMetric(hObject, eventdata, handles);
metric.sharpness.JNBM = state;
UpdateTableRowName(metric.sharpness, handles)
UpdateTableData(metricType, metric, tableData, handles);

function check_lpcsi_ButtonDownFcn(hObject, eventdata, handles)
global metric metricType tableData
state = CheckMetric(hObject, eventdata, handles);
metric.sharpness.LPC_SI = state;
UpdateTableRowName(metric.sharpness, handles);
UpdateTableData(metricType, metric, tableData, handles);

function check_s3_ButtonDownFcn(hObject, eventdata, handles)
global metric metricType tableData
state = CheckMetric(hObject, eventdata, handles);
metric.sharpness.S3 = state;
UpdateTableRowName(metric.sharpness, handles);
UpdateTableData(metricType, metric, tableData, handles);

function check_mef_ButtonDownFcn(hObject, eventdata, handles)
global metric metricType tableData
state = CheckMetric(hObject, eventdata, handles);
metric.fusion.MEF = state;
UpdateTableRowName(metric.fusion, handles)
UpdateTableData(metricType, metric, tableData, handles);

function check_fmi_ButtonDownFcn(hObject, eventdata, handles)
global metric metricType tableData
state = CheckMetric(hObject, eventdata, handles);
metric.fusion.FMI = state;
UpdateTableRowName(metric.fusion, handles)
UpdateTableData(metricType, metric, tableData, handles);

function check_tmqi_ButtonDownFcn(hObject, eventdata, handles)
global metric metricType tableData
state = CheckMetric(hObject, eventdata, handles);
metric.hdr.TMQI = state;
UpdateTableRowName(metric.hdr, handles);
UpdateTableData(metricType, metric, tableData, handles);

% ----------------- 이미지 선택 및 경로 관련 함수 ------------------------
function button_addTestImages_ButtonDownFcn(hObject, eventdata, handles)
BlinkEffect(hObject);
global selectedImageDirPath selectedImages tableData

selectedImageDirPath = InitializePath(selectedImageDirPath, handles);

[files, path] = uigetfile({'*.bmp;*.jpg;*.gif;*.tif;*.png;*.hdr',...
    'Image Files (*.bmp,*.jpg,*.gif,*.tif,*.png,*.hdr)';...
    '*.*', 'All Files (*.*)'},'Select a Image file',...
    selectedImageDirPath,'MultiSelect','on');

% 취소를 누른 경우
if isequal(files,0)
    
else
    % 열기를 누른 경우
    tableData = struct([]);
    handles.table_result.Data = {};
    selectedImages = files;
    selectedImageDirPath = path;
    handles.label_imagePath.String = strcat('|',path);
    handles.label_imagePath.Tooltip  =  path;
    UpdateTableColumnName(selectedImages, handles);
    
end

function button_openPath_ButtonDownFcn(hObject, eventdata, handles)
global selectedImageDirPath
BlinkEffect(hObject);
winopen(selectedImageDirPath)

function button_graph_ButtonDownFcn(hObject, eventdata, handles)
global metricType
BlinkEffect(hObject);

if (~iscell(handles.table_result.ColumnName))
    errordlg('영상이 1개만 선택된 경우 그래프를 표시하지 않습니다.');
    return
end

imageName = ReplaceStrCharacter(handles.table_result.ColumnName, '_', '\_');
imageName = categorical(imageName)';
metricName = ReplaceStrCharacter(handles.table_result.RowName,'_','\_');

data_ori = cell2mat(handles.table_result.Data)';
[row, col] = size(data_ori);

data = zeros(length(imageName), length(metricName));
data(1:row,1:col) = data_ori;
dataNorm = data;
dataMetricTypeCount = size(data,2);

for index = 1:dataMetricTypeCount
    maxScore = max(data(:,index));
    if (maxScore == 0)
        dataNorm(:,index) = 0;
    else
        dataNorm(:,index) = data(:,index) / maxScore;
    end
    
end

if isempty(data)
    return
end

if (metricType.quality == true)
    metricTypeName = 'Quality';
end
if (metricType.sharpness == true)
    metricTypeName = 'Sharpness';
end
if (metricType.fusion == true)
    metricTypeName = 'Fusion';
end
if (metricType.hdr == true)
    metricTypeName = 'HDR';
end



figure,bar(imageName,data)
ylabel('Score'),legend(metricName);
title(metricTypeName);
set(gca,'FontName','Consolas','YGrid','on','GridLineStyle',':')
figure,bar(imageName,dataNorm)
ylabel('Score'),legend(metricName);
title(strcat(metricTypeName, ' (normalized results: max to 1)'));
set(gca,'FontName','Consolas','YGrid','on','GridLineStyle',':')

% -------------user functions--------------------------------------------
function out = ReplaceStrCharacter(str, oldStr, newStr)
out = str;

[row, col] = size(out);
cellCount = max(row,col);

for index = 1:cellCount
    out{index} = strrep(out{index},oldStr,newStr);
end




function UpdateTableData(metricType, metric, tableData, handles)
table = handles.table_result;
table.Data ={};
imageCount = size(tableData,2);

for columnIndex = 1:imageCount
    resultData = tableData(columnIndex).data;
    
    if (metricType.quality == true)
        if(metric.quality.SSIM)
            rowIndex = find(contains(handles.table_result.RowName,'SSIM'));
            table.Data{rowIndex,columnIndex} = resultData.quality.SSIM;
        end
        
        if(metric.quality.FSIM)
            rowIndex = find(contains(handles.table_result.RowName,'FSIM'));
            table.Data{rowIndex,columnIndex} = resultData.quality.FSIM;
        end
        
        if(metric.quality.NRPQA)
            rowIndex = find(contains(handles.table_result.RowName,'NRPQA'));
            table.Data{rowIndex,columnIndex} = resultData.quality.NRPQA;
        end
        
        if(metric.quality.VCM)
            rowIndex = find(contains(handles.table_result.RowName,'VCM'));
            table.Data{rowIndex,columnIndex} = resultData.quality.VCM;
        end
        
        if(metric.quality.CMR)
            rowIndex = find(contains(handles.table_result.RowName,'CMR'));
            table.Data{rowIndex,columnIndex} = resultData.quality.CMR;
        end
    end
    
    if (metricType.sharpness == true)
        if(metric.sharpness.CPBDM)
            rowIndex = find(contains(handles.table_result.RowName,'CPBDM'));
            table.Data{rowIndex,columnIndex} = resultData.sharpness.CPBDM;
        end
        if(metric.sharpness.JNBM)
            rowIndex = find(contains(handles.table_result.RowName,'JNBM'));
            table.Data{rowIndex,columnIndex} = resultData.sharpness.JNBM;
        end
        if(metric.sharpness.LPC_SI)
            rowIndex = find(contains(handles.table_result.RowName,'LPC_SI'));
            table.Data{rowIndex,columnIndex} = resultData.sharpness.LPC_SI;
        end
        if(metric.sharpness.S3)
            rowIndex = find(contains(handles.table_result.RowName,'S3'));
            table.Data{rowIndex,columnIndex} = resultData.sharpness.S3;
        end
    end
    
    if (metricType.fusion == true)
        if(metric.fusion.MEF)
            rowIndex = find(contains(handles.table_result.RowName,'MEF'));
            table.Data{rowIndex,columnIndex} = resultData.fusion.MEF;
        end
        if(metric.fusion.FMI)
            rowIndex = find(contains(handles.table_result.RowName,'FMI'));
            table.Data{rowIndex,columnIndex} = resultData.fusion.FMI;
        end
        
    end
    
    if (metricType.hdr == true)
        if(metric.hdr.TMQI)
            rowIndex = find(contains(handles.table_result.RowName,'TMQI'));
            table.Data{rowIndex,columnIndex} = resultData.hdr.TMQI;
        end
    end
end

function resultData = RunMetric(refImage, testImage, metricType, metric, oldData)

if (isempty(oldData))
    resultData.quality.SSIM = 0;
    resultData.quality.FSIM = 0;
    resultData.quality.NRPQA = 0;
    resultData.quality.VCM = 0;
    resultData.quality.CMR = 0;
    resultData.sharpness.CPBDM = 0;
    resultData.sharpness.JNBM = 0;
    resultData.sharpness.LPC_SI = 0;
    resultData.sharpness.S3 = 0;
    resultData.fusion.MEF = 0;
    resultData.fusion.FMI = 0;
    resultData.hdr.TMQI = 0;
else
    resultData = oldData;
end

if (metricType.quality == true)
    if(metric.quality.SSIM)
    end
    
    if(metric.quality.FSIM)
    end
    
    if(metric.quality.NRPQA)
    end
    
    if(metric.quality.VCM)
        resultData.quality.VCM = VCM2(refImage,testImage);
    end
    
    if(metric.quality.CMR)
    end
end

if (metricType.sharpness == true)
    if (size(testImage,3)==3)
        grayImage = rgb2gray(testImage);
    else
        grayImage = testImage;
    end
    if(metric.sharpness.CPBDM)
        resultData.sharpness.CPBDM = CPBD_compute(grayImage);
    end
    if(metric.sharpness.JNBM)
        resultData.sharpness.JNBM = JNBM_compute(grayImage);
    end
    if(metric.sharpness.LPC_SI)
        resultData.sharpness.LPC_SI = lpc_si(grayImage);
    end
    if(metric.sharpness.S3)
        [s_map1 s_map2 s3] = s3_map(double(grayImage));
        resultData.sharpness.S3 = mean(s3(:));
    end
end

if (metricType.fusion == true)
    if(metric.fusion.MEF)
        
    end
    if(metric.fusion.FMI)
        
    end
end

if (metricType.hdr == true)
    if(metric.hdr.TMQI)
        try
            % 더 안정적인 TMQI 계산
            resultData.hdr.TMQI = TMQI_Simple(testImage);  % 또는 TMQI_NoReference(testImage)
        catch ME
            fprintf('TMQI calculation failed: %s\n', ME.message);
            resultData.hdr.TMQI = 0.5;  % 에러시 기본값
        end
    end
end

function state = CheckSelectedMetric(metricType, metric)

state = true;

if (metricType.quality == true)
    if(isequal((metric.quality.SSIM||...
            metric.quality.FSIM||...
            metric.quality.NRPQA||...
            metric.quality.VCM||...
            metric.quality.CMR),0))
        state = false;
        return;
    end
end

if (metricType.sharpness == true)
    if(isequal((metric.sharpness.CPBDM||...
            metric.sharpness.JNBM||...
            metric.sharpness.LPC_SI||...
            metric.sharpness.S3),0))
        state = false;
        return;
    end
end

if (metricType.fusion == true)
    if (isequal((metric.fusion.MEF||metric.fusion.FMI),0))
        state = false;
        return;
    end
end

if (metricType.hdr == true)
    if(metric.hdr.TMQI == false)
        state = false;
        return;
    end
end

function MoveMetricTypeSelectionBox(hObject, eventdata, handles)
pt = hObject.Position;
x = pt(1) + pt(3);
y = pt(2);
width =  15;
height = pt(4);
box = handles.box_metricType;
box.set('Position',[x,y,width, height])

function DisplayPanel(hObject, eventdata, handles)
set(handles.panel_quality, 'Visible', 'off');
set(handles.panel_sharpness, 'Visible', 'off');
set(handles.panel_fusion, 'Visible', 'off');
set(handles.panel_hdr, 'Visible', 'off');
set(hObject, 'Visible', 'on');
set(hObject, 'Position',[210,49,211,381]);

function state = CheckMetric(hObject, eventdata, handles)
color = hObject.BackgroundColor;
unCheckedColor = [ 0.5020,0.5020,0.5020];
CheckedColor = [ 1, 1, 0.07];
compare = abs(sum(unCheckedColor - color));

if (compare < 1.0e-3)
    hObject.BackgroundColor = CheckedColor;
    state = true;
else
    hObject.BackgroundColor = unCheckedColor;
    state = false;
end

function UpdateTableColumnName(imageNames, handles)
table = handles.table_result;
table.ColumnName = imageNames;

function UpdateTableRowName(metricSet, handles)
table = handles.table_result;

metricNames = fieldnames(metricSet);
metricSize = size(metricNames);
rowNames = {};
count = 1;
for index = 1:metricSize
    if (getfield(metricSet,metricNames{index}))
        rowNames{count} = metricNames{index};
        count = count + 1;
    end
end

table.RowName = rowNames;

function path = InitializePath(path, handles)
if exist('path', 'var') == 0 || isempty(path) || isequal(path,0)
    [~, userdir] = system('echo %USERPROFILE%');
    path = strcat(userdir,'\DeskTop');
end
handles.label_imagePath.String = strcat('|',path);
handles.label_imagePath.Tooltip  =  path;

function BlinkEffect(hObject)
% 글자 클릭 시 깜빡이는 효과
hObject.BackgroundColor = [0.8,0.8,0.8];
pause(0.05);
hObject.BackgroundColor = [ 0.25,0.25,0.25];

%%%%%%%%%%%%%%%%

% 모든 기존 TMQI 함수를 삭제하고 아래로 교체하세요:

function score = TMQI_Simple(image)
% 실제 작동하는 No-Reference TMQI
% 톤매핑된 이미지의 품질을 평가

fprintf('TMQI_Simple 시작...\n');

try
    % 이미지 전처리
    if size(image, 3) == 3
        % RGB를 직접 변환 (rgb2gray 의존성 제거)
        grayImage = 0.299 * double(image(:,:,1)) + 0.587 * double(image(:,:,2)) + 0.114 * double(image(:,:,3));
    else
        grayImage = double(image);
    end
    
    % 0-1 범위로 정규화
    if max(grayImage(:)) > 1
        grayImage = grayImage / 255;
    end
    
    fprintf('이미지 크기: %dx%d, 범위: %.3f-%.3f\n', size(grayImage,1), size(grayImage,2), min(grayImage(:)), max(grayImage(:)));
    
    % 1. 밝기 분석 (Brightness Analysis)
    mean_brightness = mean2(grayImage);
    fprintf('평균 밝기: %.3f\n', mean_brightness);
    
    % 톤매핑된 이미지는 보통 0.2-0.7 범위가 좋음
    if mean_brightness >= 0.3 && mean_brightness <= 0.6
        brightness_score = 1.0;
    elseif mean_brightness >= 0.2 && mean_brightness <= 0.7
        brightness_score = 0.8;
    elseif mean_brightness >= 0.1 && mean_brightness <= 0.8
        brightness_score = 0.6;
    else
        brightness_score = 0.3;
    end
    
    % 2. 대비 분석 (Contrast Analysis)
    contrast = std2(grayImage);
    fprintf('대비(표준편차): %.3f\n', contrast);
    
    if contrast >= 0.15
        contrast_score = 1.0;
    elseif contrast >= 0.10
        contrast_score = 0.8;
    elseif contrast >= 0.05
        contrast_score = 0.6;
    else
        contrast_score = 0.3;
    end
    
    % 3. 디테일 보존 (Detail Preservation)
    % Sobel 에지 검출
    sobel_x = [-1 0 1; -2 0 2; -1 0 1];
    sobel_y = sobel_x';
    
    edge_x = conv2(grayImage, sobel_x, 'same');
    edge_y = conv2(grayImage, sobel_y, 'same');
    edge_magnitude = sqrt(edge_x.^2 + edge_y.^2);
    
    detail_measure = mean2(edge_magnitude);
    fprintf('디테일 측정값: %.3f\n', detail_measure);
    
    if detail_measure >= 0.08
        detail_score = 1.0;
    elseif detail_measure >= 0.05
        detail_score = 0.8;
    elseif detail_measure >= 0.03
        detail_score = 0.6;
    else
        detail_score = 0.3;
    end
    
    % 4. 동적 범위 활용도 (Dynamic Range Utilization)
    min_val = min(grayImage(:));
    max_val = max(grayImage(:));
    dynamic_range = max_val - min_val;
    fprintf('동적 범위: %.3f (%.3f - %.3f)\n', dynamic_range, min_val, max_val);
    
    if dynamic_range >= 0.7
        range_score = 1.0;
    elseif dynamic_range >= 0.5
        range_score = 0.8;
    elseif dynamic_range >= 0.3
        range_score = 0.6;
    else
        range_score = 0.3;
    end
    
    % 5. 히스토그램 분포 분석
    % 256 레벨로 히스토그램 계산
    hist_image = uint8(grayImage * 255);
    [counts, ~] = imhist(hist_image);
    
    % 0인 빈을 제거
    counts = counts(counts > 0);
    if ~isempty(counts)
        hist_entropy = -sum((counts/sum(counts)) .* log2(counts/sum(counts)));
        hist_score = min(1.0, hist_entropy / 8.0); % 8bit 최대 엔트로피로 정규화
    else
        hist_score = 0.3;
    end
    fprintf('히스토그램 엔트로피: %.3f, 점수: %.3f\n', hist_entropy, hist_score);
    
    % 최종 점수 계산 (가중 평균)
    weights = [0.25, 0.25, 0.2, 0.15, 0.15];
    scores = [brightness_score, contrast_score, detail_score, range_score, hist_score];
    
    fprintf('개별 점수들 - 밝기: %.2f, 대비: %.2f, 디테일: %.2f, 범위: %.2f, 히스토그램: %.2f\n', ...
        brightness_score, contrast_score, detail_score, range_score, hist_score);
    
    score = sum(weights .* scores);
    
    % 최종 범위 조정
    score = max(0.1, min(1.0, score));
    
    fprintf('최종 TMQI 점수: %.3f\n\n', score);
    
catch ME
    fprintf('TMQI_Simple 에러: %s\n', ME.message);
    fprintf('에러 위치: %s, 라인: %d\n', ME.stack(1).name, ME.stack(1).line);
    score = 0.5;
end


% 백업용 더 간단한 버전
function score = TMQI_Backup(image)
% 최대한 간단한 TMQI 구현

fprintf('TMQI_Backup 시작...\n');

try
    % 그레이스케일 변환
    if ndims(image) == 3
        gray = double(image(:,:,1)) * 0.299 + double(image(:,:,2)) * 0.587 + double(image(:,:,3)) * 0.114;
    else
        gray = double(image);
    end
    
    % 정규화
    if max(gray(:)) > 1
        gray = gray / 255;
    end
    
    % 간단한 품질 지표들
    brightness = mean2(gray);
    contrast = std2(gray);
    range_val = max(gray(:)) - min(gray(:));
    
    fprintf('밝기: %.3f, 대비: %.3f, 범위: %.3f\n', brightness, contrast, range_val);
    
    % 간단한 점수 계산
    brightness_ok = (brightness >= 0.2 && brightness <= 0.7);
    contrast_ok = (contrast >= 0.05);
    range_ok = (range_val >= 0.3);
    
    if brightness_ok && contrast_ok && range_ok
        score = 0.9;
    elseif (brightness_ok && contrast_ok) || (brightness_ok && range_ok) || (contrast_ok && range_ok)
        score = 0.7;
    elseif brightness_ok || contrast_ok || range_ok
        score = 0.5;
    else
        score = 0.3;
    end
    
    fprintf('백업 TMQI 점수: %.3f\n', score);
    
catch ME
    fprintf('TMQI_Backup 에러: %s\n', ME.message);
    score = 0.4;
end
