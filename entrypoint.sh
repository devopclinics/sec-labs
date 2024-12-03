#!/bin/bash

# Read the GOTTY_USER from the environment
USER_NAME=${GOTTY_USER}

# Check if the user exists, and create it if it doesn't
if ! id -u "$USER_NAME" > /dev/null 2>&1; then
  # Temporarily using root to create the user
  useradd -m -s /bin/bash "$USER_NAME"
  # Grant the user sudo privileges (if required)
  echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER_NAME
  chmod 0440 /etc/sudoers.d/$USER_NAME
fi

# Switch to the user created (or already existing) and run GoTTY
exec su -c "gotty --permit-write --reconnect /bin/bash" "$USER_NAME"
