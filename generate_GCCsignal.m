function generate_GCCsignal(inSig_folder,inNoise_file,output_dir,SNRs,tau_resolution,freq_H,freq_L,array_pos,Length,out_fs,wlen,noverlap,is_save,is_display,ch)
    
    %% path process
    if  strcmp('Gauss',inNoise_file)
        noiseType = 'Gauss';
    elseif exist(inNoise_file,'file')
        noiseType = 'file';
    else
        assert(-1==1,'Unknow noise type or noiseFile is not exited');
    end

    for ss =1: length(SNRs)
        output_subdir = [output_dir,'/',num2str(SNRs(ss))];
        if ~exist(output_subdir,'dir')
            mkdir(output_subdir)
        end
    end

    %% load noise data
    if strcmp(noiseType, 'file')
        ego_all_noise = load(inNoise_file);
        [~,ego_noise_N_sample] = size(ego_all_noise.mic_all_data);
    end

    %% param
    [N_mic,~] = size(array_pos);
    pair = get_pair(N_mic,63);
    N_pair = size(pair);
    
    resolution = tau_resolution;
    freq_H = freq_H;
    freq_L = freq_L;

    % stft

    window = hann(wlen);
    nfft = wlen;
    c = 343;                % 声速

    count = 0;

    %% generate process 
    subdir = dir(inSig_folder);
    for i = 1:length(subdir)
        if subdir(i).isdir||isequal( subdir( i ).name, '.' )||...
            isequal( subdir( i ).name, '..')
            continue;
        end
   
        subdirpath = fullfile( inSig_folder, subdir(i).name);

        %% load data
        mic_signals = load(subdirpath);
        mic_signal = mic_signals.mic_signal;
        delay_time = mic_signals.delay_time;
        source_info = mic_signals.source_info;
        [N_mic2,~] = size(mic_signal);
        assert(N_mic2 == N_mic,'the N_mics of mic_signal and ego_signal is not same!');

        if Length ~= -1
            if length(mic_signal)>=Length
                mic_signal = mic_signal(:,1:Length);
            else
                assert(-1==1,'the input Length is bigger than the length of signal!');
            end
        end
        
        fs = source_info(4);
        if out_fs ~= -1
            mic_signal = resample(double(mic_signal'),out_fs,fs);
            mic_signal = single(mic_signal');
            fs = out_fs;
        end
        
        %% param
        source_pos = [source_info(1),source_info(2),source_info(3)];
        [~,N_samples] = size(mic_signal);
        tou_idea = (delay_time(pair(:,1))-delay_time(pair(:,2)))*fs;
        %% SNR mix
        start_indx = ceil((ego_noise_N_sample-N_samples)*rand());
        end_indx = start_indx + N_samples-1;
        ego_noise = ego_all_noise.mic_all_data(:,start_indx:end_indx);
        en_signal = sum(sum(mic_signal.^2));
        en_noise = sum(sum(ego_noise.^2));
        
        %% processing
        for s = 1:length(SNRs)
            count = count+1;
            SNR = SNRs(s);
            if strcmp(noiseType,'Gauss')
                mix_signal = awgn(mic_signal,SNR,'measured');
            elseif strcmp(noiseType,'file')
                mix_signal = (10^(SNR/10)*en_noise/en_signal)^(1/2)*mic_signal + ego_noise;
            else
                assert(-1==1,'noise mix error')
            end
            [F,T,mic_stft] = ssl_stft(mix_signal,window, noverlap, nfft, fs);
            [n_freq,n_t,n_ch] = size(mic_stft);
            
            freq_H_indx = find(F<freq_H,1,"last");
            freq_L_indx = find(F>freq_L,1,'first');

            d_mic_pos = array_pos(pair(:,1),:)-array_pos(pair(:,2),:);
            d_mic_pos2 = d_mic_pos.^2;
            d_mic_pos_max = max(sqrt(d_mic_pos2(:,1)+d_mic_pos2(:,2)));
            tou_max = d_mic_pos_max/c;
            max_shift_sample = floor(tou_max*fs);
            X2 = zeros(N_pair(1),2*max_shift_sample+1);
            
            mic_signal_stft_pair1 = mic_stft(freq_L_indx:freq_H_indx,:,pair(:,1));
            mic_signal_stft_pair2 = mic_stft(freq_L_indx:freq_H_indx,:,pair(:,2));
        
            cov = mic_signal_stft_pair1.*conj(mic_signal_stft_pair2);
        
            cov = cov./abs(cov);

            tou = -max_shift_sample:resolution:max_shift_sample;

            for tou_indx = 1:1:length(tou)
                PHAT = exp(1j*2*pi*F(freq_L_indx:freq_H_indx)*(tou(tou_indx)/fs));
                PHAT = repmat(PHAT,1,n_t,N_pair(1));
                y = real(cov.*PHAT);
                y = reshape(y,[],N_pair(1));
                X2(:,tou_indx) = sum(y,1);
            end
            if is_save
                save([output_dir,'/',num2str(SNR),'/',num2str(count),'.mat'],'X2',"source_pos",'tou_idea','fs','resolution','freq_H','freq_L','SNR','tou');
            end
            if is_display
                ch = ch;
                tou_i = tou_idea(ch)
                [~,in] = max(X2(ch,:));
                in = tou(in)
                figure(1);
                subplot(4,floor(length(SNRs)/3),s)
                plot(tou,X2(ch,:)); 
                hold on
                line([tou_i,tou_i],[min(X2(ch,:)),max(X2(ch,:))],'Color','red')
                title(['SNR',num2str(SNR)])
                hold off
            end
        end
    end


end




