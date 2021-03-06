#/bin/bash
NEW_DISPLAY=42
DONE="no"

while [ "$DONE" == "no" ]
do
  out=$(xdpyinfo -display :${NEW_DISPLAY} 2>&1)
  if [[ "$out" == name* ]] || [[ "$out" == Invalid* ]]
  then
    # command succeeded; or failed with access error;  display exists
    (( NEW_DISPLAY+=1 ))
  else
    # display doesn't exist
    DONE="yes"
  fi
done

echo "Using first available display :${NEW_DISPLAY}"

OLD_DISPLAY=${DISPLAY}
umask 0077                                        # use safe default permissions
mkdir -p "$HOME/.vnc"                             # create config directory
chmod go-rwx "$HOME/.vnc"                         # enforce safe permissions
vncpasswd -f <<<"$password" >"$HOME/.vnc/passwd"  # generate and write a password
 
vncserver ":${NEW_DISPLAY}"  -localhost -geometry 1600x1200 -depth 16
export DISPLAY=:${NEW_DISPLAY}

"$@"

export DISPLAY=${OLD_DISPLAY}
vncserver -kill ":${NEW_DISPLAY}"