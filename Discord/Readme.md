# A simple discord bot communication using ZeroMQ 

### Installation
- Place `config.json`, `package.json`, `index.js`, `Discord.nut` and `JSON.nut` in your server directory.
- Run `npm i` in the directory to install modules.
- Load JSON.nut and Discord.nut (in that order) in your server scripts.

> You may create separate directory for bot as per your desire, but config.json is required by both Squirrel and node.js scripts.

### Configuration
The `config.json` file contains:
- `string` **Token:** bot's token.
- `string` **Push:** socket port to push from node.js and listen at Squirrel.
- `string` **Pull:** socket port to push from Squirrel and listen at node.js.
- `bool` **TrackDMs**: whether to track direct messages.
- `bool` **TrackAll**: whether to track messages from all channels the bot has access to.
- `array<string>` **Listen:** the list of channels to track messages from, obsolete if *TrackAll* is set to true.

![Discord Bot](https://i.imgur.com/bQGPyDs.gif)
