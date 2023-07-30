# Unifi Cam Volume Alert

Configure SMS-based alerting based on the volume level recorded by your Unifi (or any RTSP enabled) camera.

This has been a commonly requested feature from Ubiquiti:
* https://community.ui.com/questions/UniFi-Protect-Sound-Alert-Noise-Alert-Decibel-Alert-2-Year-Follow-Up/89e12217-ffc8-41d5-8084-d52503c37e4d
* https://community.ui.com/questions/Unifi-Protect-Sound-Alert-Noise-Alert-Decibel-Alert/79f708dd-f036-4d61-9f2e-9cd6ef27cc62
* https://www.reddit.com/r/UNIFI/comments/12a03r5/unifi_protect_g4_instant_notify_on_sound_trigger/

This script exposes a very barebones way of accomplishing this goal. FFMPEG has [a simple way of detecting the volume level of an audio/video steam](https://stevebarbera.medium.com/volume-detection-for-a-audio-stream-dbe727085783), so I decided to leverage this in conjunction with SMS alerting to build this functionality.


# How it works
A shell script runs FFMPEG against a recorded slice of video from an RTSP stream and FFMPEG calclates the mean volume of the audio from the clip. That value is compared against a user-defined threshold, and if it's louder, it makes a call to the Twilio API to deliver an SMS to the end user.


# Installation
1. If FFMPEG isn't already installed, `apt-get install ffmpeg`
2. Clone this directory to `/opt/unifi-cam-volume-alert`
3. Edit the varibles in `/opt/unifi-cam-volume-alert/unifi_volume_alert.sh`
4. Move the systemd unit file: `mv /opt/unifi-cam-volume-alert/unifi-cam-volume-alert.service`
5. (Optional) Move the logrotate file `mv /opt/unifi-cam-volume-alert/unfi-cam-volume-alert.logrotate /etc/logrotate.d/`
6. (Optional to start at boot) `sudo systemctl enable unifi-cam-volume-alert.service`
7. Start the service: `sudo systemctl daemon-reload && systemctl start unfi-cam-volume-alert.service`

The log file is located at `/opt/unifi-cam-volume-alert/unifi_volume_alert.log`

