clear
close all
%% parameter
signal_folder = 'D:/workspace/声学项目/data/train_speech_simulateOut';
noise_file = '../48k_ego_noise.mat';
output_dir = './output_egonoise_0_1';
load('array_pos.mat')
SNRs = [30,10,5,0,-5,-10,-15,-20,-25,-30];
tau_resolution = 1;
freq_H = 8000;
freq_L = 100;
Length = 2048;
out_fs = 48000;
window = hann(wlen);
noverlap = 0.5*wlen;
%% path_process
generate_GCCsignal(signal_folder,noise_file,output_dir,SNRs,tau_resolution,freq_H,freq_L,array_pos,Length,out_fs,window,noverlap)

%%

