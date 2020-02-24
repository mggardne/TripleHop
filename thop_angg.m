%#######################################################################
%
%                 * Triple HOP ANGles Graphics Program *
%
%          M-File for digitizing trunk, knee, ankle and foot markers
%     in JPEG images of triple hop subjects.  There are usually 28
%     images (frontal and lateral images of right and left legs in 
%     static postures and in three trials).
%
%          The calculated angles between marker positions for each
%     image are written to a MS-Excel spreadsheet, thop_ang.xlsx, in
%     the main directory of the program.
%
%     NOTES:  1.  The JPEG image names must be in a specific
%                 format with specific identifiers separated by
%                 underscores ("_").
%
%             2.  Number of trial must be less than ten (10).
%
%             3.  Trial number for calibration images is zero (0).
%
%             4.  MS-Excel spreadsheet thop_ang.xlsx must not be open
%             when running this program.
%
%             5.  Note the joint angles are the interior angles between
%             the body segments and are not clinical joint angles which
%             have variously defined zero angles.
%
%     20-Feb-2020 * Mack Gardner-Morse
%

%#######################################################################
%
% Define Global Variables
%
global hb1 hb2 hb3 hb4 hb5 hb6 hb7;
global hm1 hmt1 hm2 hmt2 hm3 hmt3 hm4 hmt4 hm5 hmt5 hm6 hmt6 hm7 hmt7;
global x1 x2 x3 x4 x5 x6 x7 y1 y2 y3 y4 y5 y6 y7;
%
% Output MS_Excel Spreadsheet File Name
%
xlsnam = 'thop_ang.xlsx';
shtnam = '3hop';
%
if exist(xlsnam,'file')
  [~,txt] = xlsread(xlsnam,shtnam);
  irow = size(txt,1)+1; % First blank line in spreadsheet file
else
  irow = 1;
  hdr1 = {'File','Subj','Leg','Test','View','Trial', ...
          'Knee Ang','Hip Ang','Ankle Ang'};
%   xlswrite(xlsnam,hdr1,shtnam,['A' int2str(irow)]);
  th = table(hdr1);
  writetable(th,xlsnam,'Sheet',shtnam,'Range',['A', ...
             int2str(irow)],'WriteVariableNames',false);
  irow = irow+1;
end
%
% Get Hop Image File Names
%
% C= Calibration
% LI= Lateral Impact
% LF= Lateral Flexion
% FI= Frontal Impact
% FF= Frontal Flexion
%
[fnams,pnam] = uigetfile({'*.jpe*;*.jpg*', ...
             'JPEG image files (*.jpe*, *.jpg*)';
             '*.jpe*;*.jpg*;*.tif*;*.gif*;*.bmp*', ...
             'All image files (*.jpe*, *.jpg*, *.tif*, *.gif*, *.bmp*)';
             '*.*',  'All files (*.*)'},'Please Select Image Files', ...
             'MultiSelect', 'on');
%
if isequal(fnams,0)
  return;
end
%
if iscell(fnams)
  fnams = fnams';
else
  fnams = {fnams};      % Ensure names are a cell array
end
%
nf = size(fnams,1);
%
% Setup Figure Window
%
hf1 = figure;
orient landscape;
set(hf1,'WindowState','maximized');
drawnow;
%
% Setup Slider for Brightness
%
hs = uicontrol(hf1,'Style','slider');
set(gca,'Units','pixels');
pos = reshape(round(get(gca,'pos')),2,2)';
ci = ['val = get(hs,''Value''); imgb = im_dat+uint8(val); ' ...
      'set(ih,''CData'',imgb);'];
set(hs,'Position',[20 pos(1,2)+20 20 pos(4)-40],'Min',0, ...
    'Max',128,'Value',0,'Callback',ci);
set(hs,'BackgroundColor',[0.85 0.85 0.85]);
%
% Setup Radio Buttons
%
rpos = round((pos(4)-6*100)/2);
xy = [sum(pos(:,1))+10 sum(pos(:,2))-rpos];
%
% Frontal Points:
%
%  1 - ASIS- Front of the Hip
%
%  2 - GT- Side of the Hip
%
%  3 - LFE- Lateral Side of Knee
%
%  4 - MFE- Medial Side of Knee
%
%  5 - TT- Center of the Knee
%
%  6 - MM- Medial Side of Ankle
%
%  7 - DT- Distal Tibia just above the Ankle
%  7 - LM- Lateral Side of Ankle
%
% fpts = {'ASIS'; 'GT'; 'LFE'; 'MFE'; 'TT'; 'MM'; 'LM'};
fpts = {'ASIS'; 'GT'; 'LFE'; 'MFE'; 'TT'; 'MM'; 'DT'};
%
% Lateral Points:
%
%  1 - ASIS- Front of Hip
%
%  2 - PSIS- Back of the Hip
%
%  3 - GT- Hip bone
%
%  4 - MC- Mid Crest, This will be that point where the trunk line meets the belt
%
%  5 - LFE- Knee marker
%
%  6 - LM- Ankle Marker
%
%  7 - MTP- Outside of foot
%
lpts = {'ASIS'; 'PSIS'; 'GT'; 'MC'; 'LFE'; 'LM'; 'MTP'};
%
% Frontal Measurements:
%
% Knee Angle- Measured from ASIS-TT-DistalTibia
%
%     There is no Anatomical comparison here
%
%
% Lateral Measurements:
%
%  Ankle Angle- Measured from LFE-LM-MTP
%
%      Anatomical Zero is 90 Degrees
%
%  Knee Angle- Measured from LM-LFE-GT
%
%      Anatomical Zero is 180 Degrees
%
%  Hip Angle- Perpendicular to ASIS-PSIS line and femoral line
%
%  Trunk Angle- Not calculated
%
hb1 = uicontrol('Style','radiobutton','String','ASIS',...
                'Position', [xy 100 20],'Callback',@btnstate, ...
                'UserData',1);
%
hb2 = uicontrol('Style','radiobutton','String','GT',...
                'Position',[xy-[0 100] 100 20],'Callback',@btnstate, ...
                'UserData',2);
%
hb3 = uicontrol('Style','radiobutton','String','LFE',...
                'Position',[xy-[0 200] 100 20],'Callback',@btnstate, ...
                'UserData',3);
%
hb4 = uicontrol('Style','radiobutton','String','MFE',...
                'Position',[xy-[0 300] 100 20],'Callback',@btnstate, ...
                'UserData',4);
%
hb5 = uicontrol('Style','radiobutton','String','TT',...
                'Position',[xy-[0 400] 100 20],'Callback',@btnstate, ...
                'UserData',5);
%
hb6 = uicontrol('Style','radiobutton','String','MM',...
                'Position',[xy-[0 500] 100 20],'Callback',@btnstate, ...
                'UserData',6);
%
hb7 = uicontrol('Style','radiobutton','String', 'LM',...
                'Position',[xy-[0 600] 100 20],'Callback',@btnstate, ...
                'UserData',7);
%
% Next Plot Push Button
%
hb = uicontrol('Style', 'pushbutton', 'String', 'Close',...
               'Position', [20 20 50 20],'Callback',@nextplt);
%
% Loop through Hop Files
%
for k = 1:nf
%
% File Name
%
   fnam = fnams{k};
   [subj,ileg,itest,iview,trial] = pars_nam(fnam);
   idata = {fnam,subj,ileg,itest,iview};
   ti = table(idata);
%
% Plot Image
%
   im_dat = imread(fullfile(pnam,fnam));
   ih = imagesc(im_dat);
   axis equal;
   axis tight;
   hold on;
   axlim = axis;
   drawnow;
%
% Process Frontal and Lateral Views Separately
%
% Frontal View
%
   if startsWith(iview,'F')
     for k = 1:7
        eval(['set(hb' int2str(k) ',''String'',' ' fpts{k} ' ');']);
     end
%
     for k = [2:4 6]
        eval(['set(hb' int2str(k) ',''Enable'',''off'');']);
     end
%
     uiwait(hf1);
%
% Calculate Knee Angle
%
     TT = [x5 y5];
     ASIS2TT = [x1 y1]-TT;             % Vector along femur
     DT2TT = [x7 y7]-TT;               % Vector along tibia
     ASIS2TT = ASIS2TT./norm(ASIS2TT); % Normalize
     DT2TT = DT2TT./norm(DT2TT);       % Normalize
     knee_ang = rad2deg(acos(dot(ASIS2TT,DT2TT)));
%
     adata = [trial knee_ang];
%
% Lateral View
%
   else
     for k = 1:7
        eval(['set(hb' int2str(k) ',''String'',' ' lpts{k} ' ');' ]);
        eval(['set(hb' int2str(k) ',''Enable'',''on'');']);
     end
     set(hb4,'Enable','off');
%
     uiwait(hf1);
%
% Calculate Hip Angle
%
     ASIS = [x1 y1];
     PSIS = [x2 y2];
     midpt = (ASIS-PSIS)/2;            % Midpoint of line between ASIS and PSIS
     ASIS2PSIS = ASIS-PSIS;            % Vector
     slp = -ASIS2PSIS(1)/ASIS2PSIS(2); % Slope of perpendicular line
     b = midpt(2)-slp*midpt(1);        % Intercept of perpendicular line
     x2 = midpt(1)-1;                  % X of second point on perpendicular line
     y2 = slp*x2+b;                    % Y of second point on perpendicular line
     pvec = [x2-midpt(1) y2-midpt(2)]; % Vector along perpendicular line
     pvec = pvec./norm(pvec);          % Normalize
     GT = [x3 y3];
     LFE = [x5 y5];
     fvec = LFE-GT;     % Vector along femur
     fvec = fvec./norm(fvec);          % Normalize
     hip_ang = rad2deg(acos(dot(pvec,fvec)));
%
     LM = [x6 y6];
     tvec = LM-LFE;     % Vector along tibia
     tvec = tvec./norm(tvec);          % Normalize
     knee_ang = rad2deg(acos(dot(fvec,tvec)));
%
     MTP = [x7 y7];
     mvec = LM-MTP;     % Vector along foot
     mvec = mvec./norm(mvec);          % Normalize
     ankle_ang = rad2deg(acos(dot(mvec,tvec)));
%
     adata = [trial knee_ang hip_ang ankle_ang];
     ta = table(adata);
%
   end
%
% Write Angles Out to Spreadsheet
%
%    xlswrite(xlsnam,idata,shtnam,['A' int2str(irow)]);
%    xlswrite(xlsnam,adata,shtnam,['F' int2str(irow)]);
   writetable(ti,xlsnam,'Sheet',shtnam,'Range',['A', ...
              int2str(irow)],'WriteVariableNames',false);
   writetable(ta,xlsnam,'Sheet',shtnam,'Range',['F', ...
              int2str(irow)],'WriteVariableNames',false);

   irow = irow+1;
%
end
%
close(hf1);
%
return
%
function btnstate(source,event);
%BTNSTATE  Callback function for radio buttons for digitizing points on
%          triple hop images.
%
%          BTNSTATE(SOURCE,EVENT) checks the state of the value and
%          either gets the coordinates of a point or deletes the marker
%          on the image.
%
%          NOTES:  1.  Must have at least three (3) points.  
%
%          21-Mar-2019 * Mack Gardner-Morse
%

%#######################################################################
%
% Global Variables
%
global hm1 hmt1 hm2 hmt2 hm3 hmt3 hm4 hmt4 hm5 hmt5 hm6 hmt6 hm7 hmt7;
%
% Get Radio Button Number
%
nbtn = get(source,'UserData');
%
% Get Current State of Radio Button
%
sbtn = int2str(nbtn);
%
val = logical(get(source,'Value'));
%
% Get Coordinates or Delete Marker
%
if val
  mstr = get(source,'String');
  [px,py] = ginput(1);
  eval(['hm' sbtn ' = plot(px,py,''r+'',''MarkerSize'',8,', ...
        '''LineWidth'',1);']);
  eval(['hmt' sbtn ' = text(px+1,py+1,mstr,''Color'',''r'',', ...
        '''FontSize'',10,''FontWeight'',''bold'');']);
else
  if exist(['hm' sbtn],'var');
    eval(['delete(hm' sbtn ');']);
    eval(['delete(hmt' sbtn ');']);
  end
end
%
end
%
function nextplt(source,event);
%NEXTPLT   Callback function for push button for digitizing points on
%          triple hop images.
%
%          NEXTPLT(SOURCE,EVENT) gets the position data from the markers
%          and clears the axis and uicontrols.
%
%          NOTES:  None.  
%
%          25-Mar-2019 * Mack Gardner-Morse
%

%#######################################################################
%
% Global Variables
%
global hb1 hb2 hb3 hb4 hb5 hb6 hb7;
global hm1 hmt1 hm2 hmt2 hm3 hmt3 hm4 hmt4 hm5 hmt5 hm6 hmt6 hm7 hmt7;
global x1 x2 x3 x4 x5 x6 x7 y1 y2 y3 y4 y5 y6 y7;
%
% Get Marker Position Data
%
for k = 1:7
   ks = int2str(k);     % Button and plot number as a string
   hmk = ['hm' ks];
   if exist(hmk,'var');
     if isnumeric(eval(hmk))
       eval(['x' ks ' = NaN;']);
       eval(['y' ks ' = NaN;']);
     else
       if isvalid(eval(hmk));
         eval(['x' ks ' = get(hm' ks ',', ...
               '''XData'');']);
         eval(['y' ks ' = get(hm' ks ',', ...
               '''YData'');']);
         eval(['set(hb' ks ',''Value'',0);']);
         eval(['delete(hm' ks ');']);
         eval(['delete(hmt' ks ');']);
       else
         eval(['x' ks ' = NaN;']);
         eval(['y' ks ' = NaN;']);
       end
     end
   else
     eval(['x' ks ' = NaN;']);
     eval(['y' ks ' = NaN;']);
   end
end
%
uiresume(gcbf);
%
end
%
function [subj,ileg,itest,iview,trial] = pars_nam(jpg_nam);
%PARS_NAM  Function to parse the JPEG image name into subject number ID,
%          test leg (L/R), test type (C/F/I), image view (F/L) and trial
%          number.
%
%          PARS_NAM(JPG_NAM) returns the subject number ID as a
%          character array.
%
%          [SUBJ,ILEG,ITEST,IVIEW,TRIAL] = PARS_NAM(JPG_NAM) returns the
%          character subject number ID in SUBJ, "L" for the left leg or
%          "R" for the right leg in ILEG, "C" for the calibrate image or
%          "F" for the flexed image or "I" for the impact image in
%          ITEST, "F" for the frontal view or "L" for the lateral view
%          in IVIEW and the integer trial number in TRIAL.
%
%          NOTES:  1.  The JPEG image names must be in a specific
%                  format with specific identifiers separated by
%                  underscores ("_").
%
%                  2.  Number of trial must be less than ten (10).
%
%                  3.  Trial number for calibration images is zero (0).
%
%          21-Feb-2020 * Mack Gardner-Morse
%

%#######################################################################
%
% Find Underscores in JPG_NAM
%
idx = strfind(jpg_nam,'_');
%
% Parse JPG_NAM
%
subj = jpg_nam(1:idx(1)-1);
ileg = upper(jpg_nam(idx(1)+1));
itest = upper(jpg_nam(idx(2)+1));
if startsWith(itest,'C');
  iview = upper(jpg_nam(idx(3)+1));
  trial = 0;
else
  iview = itest;
  itest = upper(jpg_nam(idx(3)-1));
  trial = str2num(jpg_nam(idx(3)+1));
end
%
end