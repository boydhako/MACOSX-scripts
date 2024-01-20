#!/bin/bash
killall Mail 2>/dev/null
find ~/Library/Mail -type f -name "Envelope Index" -exec sqlite3 {} vacuum \;
