#!/bin/bash

# Author: Chris Long
# Date: 2023-07-30

# What size window (in seconds) should be used to calculate the mean volume
SAMPLE_WINDOW=10

# RTSP URL for your UniFi Camera
# https://help.ui.com/hc/en-us/articles/221314008-UniFi-Video-How-to-Utilize-RTSP-Directly-From-the-Camera#:~:text=To%20enable%2C%20go%20to%20Cameras,appear%20when%20it%20is%20enabled.
RTSP_URL=""

# The volume threshold for alerting
# Must be a negative number
VOLUME_THRESHOLD=-22

# How many seconds should the script pause before sending additional alerts
ALERT_SNOOZE_SECONDS=120

# Twilio Auth
# Values can be found at https://console.twilio.com/
TWILIO_ACCOUNT_SID=''
TWILIO_AUTH_TOKEN=''

# Twilio SMS Details
TEXT_RECIPIENT_NUMBER=''
TEXT_FROM_NUMBER=''
CAMERA_NAME="My camera"  # The value to be shown in the SMS - make it whatever you want

#######################################################
#######################################################

get_datetime() {
echo -n "[$(date '+%Y-%m-%d %H:%M:%S')]"
}

while true; do
  MEAN_VOLUME=$(/usr/bin/ffmpeg -i "$RTSP_URL" -t $SAMPLE_WINDOW -af volumedetect -f null /dev/null 2>&1 | grep mean_volume | grep -oE '\-\d+')
  echo "$(get_datetime): MEAN_VOLUME: $MEAN_VOLUME" | tee -a /opt/unifi-cam-volume-alert/unifi_volume_alert.log
  if [ "$MEAN_VOLUME" -ge "$VOLUME_THRESHOLD" ]; then
    echo "$(get_datetime): THRESHOLD_EXCEEDED ($VOLUME_THRESHOLD) -- MEAN_VOLUME: $MEAN_VOLUME" | tee -a /opt/unifi-cam-volume-alert/unifi_volume_alert.log
      curl -s "https://api.twilio.com/2010-04-01/Accounts/$TWILIO_ACCOUNT_SID/Messages.json" -X POST \
      --data-urlencode "To=$TEXT_RECIPIENT_NUMBER" \
      --data-urlencode "From=$TEXT_FROM_NUMBER" \
      --data-urlencode "Body=Sound detected on $CAMERA_NAME: $MEAN_VOLUME" \
      -u "$TWILIO_ACCOUNT_SID:$TWILIO_AUTH_TOKEN"
      sleep $ALERT_SNOOZE_SECONDS
  fi
done
