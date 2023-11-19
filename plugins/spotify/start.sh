#!/usr/bin/env bash

if [[ -n "$SOUND_DISABLE_SPOTIFY" ]]; then
  echo "Spotify is disabled, exiting..."
  exit 0
fi

# --- ENV VARS ---
# SOUND_DEVICE_NAME: Set the device broadcast name for Spotify
# SOUND_SPOTIFY_BITRATE: Set the playback bitrate
SOUND_DEVICE_NAME=${SOUND_DEVICE_NAME:-"balenaSound Spotify $(echo "$BALENA_DEVICE_UUID" | cut -c -4)"}
SOUND_SPOTIFY_BITRATE=${SOUND_SPOTIFY_BITRATE:-320}
SOUND_SPOTIFY_DISABLE_NORMALISATION=DISABLE
SOUND_SPOTIFY_ENABLE_CACHE=ENABLE

# SOUND_SPOTIFY_DISABLE_NORMALISATION: Disable volume normalization
if [[ -z ${SOUND_SPOTIFY_DISABLE_NORMALISATION+x} ]]; then
  set -- "$@" \
    --enable-volume-normalisation
fi

# SOUND_SPOTIFY_USERNAME: Login username for Spotify
# SOUND_SPOTIFY_PASSWORD: Login password for Spotify
if [[ -n "$SOUND_SPOTIFY_USERNAME" ]] && [[ -n "$SOUND_SPOTIFY_PASSWORD" ]]; then
  set -- "$@" \
    --username "$SOUND_SPOTIFY_USERNAME" \
    --password "$SOUND_SPOTIFY_PASSWORD"
fi

# SOUND_SPOTIFY_ENABLE_CACHE: Enable Spotify audio cache
if [[ -z ${SOUND_SPOTIFY_ENABLE_CACHE+x} ]]; then
  set -- "$@" \
    --disable-audio-cache
fi

# Start librespot
# We use set/$@ because librespot for some reason does not like env vars and quote escapes
echo "Starting Spotify plugin..."
echo "Device name: $SOUND_DEVICE_NAME"
[[ -n "$SOUND_SPOTIFY_USERNAME" ]] && [[ -n "$SOUND_SPOTIFY_PASSWORD" ]] && echo "Using provided credentials for Spotify login."
[[ -n ${SOUND_SPOTIFY_DISABLE_NORMALISATION+x} ]] && echo "Volume normalization disabled."
[[ -n ${SOUND_SPOTIFY_ENABLE_CACHE+x} ]] && echo "Spotify audio cache enabled."

set -- /usr/bin/librespot \
  --backend pipe \
  --name "$SOUND_DEVICE_NAME" \
  --cache /var/cache/raspotify \
  --volume-ctrl linear \
  --initial-volume=30 \
  -v \
  | pacat --latency-msec=20
#  --bitrate "$SOUND_SPOTIFY_BITRATE" \
#  --format S32 \
#  --dither none \

  "$@"

exec "$@"
