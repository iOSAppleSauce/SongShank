# SongShank

**A zero‑tap way to share the same song across all streaming apps.**  
Copy or share a track from Spotify, Apple Music, YouTube Music, TIDAL, Deezer, SoundCloud, or Bandcamp — SongShank instantly flips it into a single **song.link** page (with **Songwhip** fallback), so your friends can open it in whatever they use.

- ⚡️ Fast: hooks pasteboard + share flow
- 🔒 Private: ephemeral requests, no tracking
- 🧠 Smart: detects major music domains (incl. `*.bandcamp.com`)
- 🧰 Toggle in Settings → SongShank (with Respring)

### Requirements
- iOS 14+ (tested on 16.1.1)
- Rootless jailbreak (Dopamine / ElleKit, etc.)
- Theos build toolchain

### Build
On macOS/Linux with Theos installed:
```sh
make clean package
