# Audio-Signal-Processing-Coursework

## Signal Reconstruction from STFT Magnitude

There are two part in this project: signal reconstruction from STFT magnitude spectra and Time-Scale
Modification (TSM). In the first part, we implement 3 algorithm: GL, RTISI, and RTISI-LA, followed
by comparison of their performance based on SER function mentioned in the paper [3]. In the second
part, we employ the RTISI-LA method on Time-Scale Modification, and compare its performance with
classic WSOLA method on the given sample data.

## Linear Predictive Coding and Reconstruction

Linear predictive coding (LPC) is a widely used technique in audio signal compression. The philosophy
of LPC is related to the human voice production. Then vocal fold generate the sound source e(n),
which then go through a linear, time-varying filter h(n). The output signal can be represented as:
x(n) = e(n) ∗ h(n)

The source signal could be an quasi-periodic pulses (voiced speech) or random noise (unvoiced speech).
The filter is modeled as all-pole filter, which can be represented as:
If we could extract the coefficients ak, k = 1...p of the all pole filter, then we can reconstruct the signal
x(n) by using the current input e(n) and past samples x(n−k), k = 1...p using the following equation

In this report, we implement a Vocoder based on LPC method above, to achieve signal compression
and reconstruction. To be more specific, we first cut the signal into small frames and then for each
frame, we add a window function and then encoded the windowed signal into a few coefficients based
on LPC method. These coefficients include:
1. Pitch
2. Gain
3. Poles coefficients ak, k = 1...p

Then, we try to reconstruct each frame signals based on these coefficients and overlap add them to
recover the original signal. Finally, we evaluate the quality of the synthesized signal by ear.
There is a trade-off between the compression rate and the quality of the synthesized speech. Our
goal is to use the least number of coefficients to reconstruct the original signal with the best quality.
After experiment, we found that, for a 16 kHz frame rate speech signal, we only need to store 454
samples per second to resynthesize the original signal in a pretty high standard.
