# Daily Quote Screensaver

A simple XScreenSaver‐based screensaver that displays a new quote every 5 mintues, centered on your screen using OSD.

---

## 1. Prerequisites

On Ubuntu/Debian:

```bash
sudo apt update
sudo apt install xscreensaver xscreensaver-demo xosd-bin
```

## 2. Prepare your quotes file

Create a file at `~/quotes.txt`.

Put exactly one quote per line, in the order you want them shown. For example:

```
How You Do Anything Is How You Do Everything. – Cheri Huber
The only limit to our realization of tomorrow is our doubts of today. – Franklin D. Roosevelt
Life isn’t about finding yourself. Life is about creating yourself. – George Bernard Shaw
...
```

## 3. Make the OSD wrapper script executable

```
chmod +x ~/bin/quote_saver_osd.sh
```

## 4. Configure XScreenSaver

1. Generate a default config if you haven’t already:

```
xscreensaver-demo
```

2. Open `~/.xscreensaver` in your editor.

3. In the programs: block, add one line:

```
programs:                                                                     \
  …                                                                           \n\
 "Daily Quote – OSD" /home/the-squid/bin/quote_saver_osd.sh                 \n\
```

4. Set cycling to something large. You can cahnge the `cycle` parameter to `cycle: 12:00:00` 

5. Restart XScreenSaver:

```
xscreensaver-command -restart
```

6. Pick one of these:

###### GNOME/KDE “Startup Applications”

Open your desktop’s “Startup Applications” (or “Autostart”) settings.

Add a new entry:

```
Name: XScreenSaver

Command: xscreensaver -nosplash
```

Save. Now each time you log in, the daemon will launch automatically.

###### ~/.xsession or ~/.xprofile

If you’re using a plain X session (no desktop‐environment autostart GUI), put this line near the top of your ~/.xsession (or ~/.xprofile):

`xscreensaver -nosplash &`

That will fire up the daemon when you log in graphically.

###### User systemd service

If you prefer systemd, you can drop a unit in `~/.config/systemd/user/xscreensaver.service`:

```
[Unit]
Description=XScreenSaver daemon

[Service]
ExecStart=/usr/bin/xscreensaver -nosplash

[Install]
WantedBy=default.target
```

Then enable it:


`systemctl --user enable xscreensaver.service`

Any of those will ensure the screensaver daemon is running in the background as soon as you log in – without polluting your shell startup.


7. Auto-Lock on Suspend / Resume

Open the Startup Applications (sometimes called “Session and Startup” or “Autostart”) utility in your desktop environment.

- Click Add (or “New”).
- Fill in the fields:
    - Name: XSS-Lock (or “Lock on Suspend”)
    - Command:
      - xss-lock -- xscreensaver-command --lock &
    - Comment: 
      - Automatically lock on suspend/idle

 - Save or OK
 - Close the Startup Applications window.

Now, every time you log in, xss-lock will launch in the background, watching for suspend or DPMS events and invoking xscreensaver-command --lock when needed.

## 5. How It Works

- GUI Preview (xscreensaver-demo) is detected and skipped.

- Real screensaver (after idle timeout) fades to black, then:

    1. Calculates today’s quote index from quotes.txt.

    2. Launches osd_cat centered on each monitor’s screen for 24 h.

    3. Waits until you dismiss the screensaver—on deactivate XScreenSaver sends SIGTERM, which kills osd_cat and exits.

## 6. Troubleshooting

Clear a stuck quote:

```
pkill osd_cat
```

Adjust display duration:

Modify `--delay=86400` to the number of seconds you want the quote to remain.

## 7. Customizing

If you want to change the font, look into the line in the scrip:

```
-misc-fixed-medium-r-normal--30-*-*-*-*-*-iso8859-1
│      │     │     │      │  │ │ │ │ │   └── character encoding
│      │     │     │      │  │ │ │ │ └──── pixel aspect (wildcard)
│      │     │     │      │  │ │ │ └────── point size (wildcard)
│      │     │     │      │  │ │ └──────── orientation (wildcard)
│      │     │     │      │  │ └────────── weight (wildcard)
│      │     │     │      │  └──────────── pitch (wildcard)
│      │     │     │      └─────────────── height in pixels (30)
│      │     │     └────────────────────── average width (“normal”)
│      │     └──────────────────────────── slant (“r” = roman/upright)
│      └────────────────────────────────── weight (“medium”)
└──────────────────────────────────────── foundry/family (“misc-fixed”)

```
