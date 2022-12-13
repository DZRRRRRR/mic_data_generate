function [F,T,X]=ssl_stft(x,window,noverlap,nfft,fs)

% Inputs:x: nchan x nsampl  window = blackman(wlen);
% Output:X: nbin x nfram x nchan matrix 

    [nchan,~]=size(x);
    [Xtemp,F,T,~] = spectrogram(x(1,:),window,noverlap,nfft,fs); % S nbin x nframe
    nbin = length(F);
    nframe = length(T);
    X = zeros(nbin,nframe,nchan);
    X(:,:,1) = Xtemp;
    for ichan = 2:nchan
        X(:,:,ichan) = spectrogram(x(ichan,:),window,noverlap,nfft,fs); 
    end

end