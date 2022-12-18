clear
close all
%% parameter
signal_folder = 'D:/workspace/声学项目/data/train_speech_simulateOut';
% noise_file = '../48k_ego_noise.mat';
noise_file = 'Gauss';
output_dir = './output_egonoise_0_1';
load('array_pos.mat')
SNRs = [30,10,5,0,-5,-10,-15,-20,-25,-30,-35,-40,-45,-50];
% SNRs  = [-10, 0, 10];
tau_resolution = 0.1;
freq_H = 8000;
freq_L = 100;
Length = 10240;
out_fs = 48000;
wlen = 512*4;
noverlap = 0.5*wlen;
is_save = 0;
is_display = 1;
ch = 30;
max_shift_sample = -1; % -1 自动计算
%% path_process
generate_GCCsignal(signal_folder,noise_file,output_dir,SNRs,tau_resolution,freq_H,freq_L,array_pos,Length,out_fs,wlen,noverlap,is_save,is_display,ch,max_shift_sample)

%%

