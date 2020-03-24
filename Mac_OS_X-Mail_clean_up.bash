#! /bin/bash
killall Mail
sqlite3 ~/Library/Mail/V2/MailData/Envelope\ Index vacuum;
