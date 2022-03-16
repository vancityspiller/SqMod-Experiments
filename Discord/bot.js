// ======================================================= //
// dependencies included in package.json
// run: npm install
// ======================================================= //

const Config = require('./config.json');

const ZMQ = {

    Instance    : require('zeromq'),
    Socket      : undefined,
    Listener    : undefined,

    // ------------------------------------------------------- //

    Init() {
        this.Socket     = this.Instance.socket('push');
        this.Listener   = this.Instance.socket('pull');

        console         .log(`[>] (ZMQ) PUSH Socket - ${Config.Push}`);
        this.Socket     .bindSync('tcp://127.0.0.1:' + Config.Push);

        console         .log(`[>] (ZMQ) PULL Socket - ${Config.Pull}`);
        this.Listener   .connect('tcp://127.0.0.1:' + Config.Pull);

        const __this = this;
        this.Listener.on('message', function(Message) {
            __this.Receive(Message);
        });
    },

    // ------------------------------------------------------- //
    
    Transmit(Key, Message) {

        // Send the message as is if it's a string
        if(typeof(Message) == "string")
        this.Socket.send([Key, Message]);

        // Send it as JSON if its an object
        if(typeof(Message) == "object") {

            try {
                this.Socket.send([Key, JSON.stringify(Message)]);
            } catch(e) { 
                console.log('[x] JSON decoding error @ZMQ.Transmit.'); 
                return;
            }
        }
    },

    // ------------------------------------------------------- //

    Receive(Data) {

        try {
            Data = JSON.parse(Data);
        } catch(e) { 
            console.log('[x] JSON parsing error @ZMQ.Receive.'); 
            return;
        }

        switch(Data.Function)
        {
            case "SendMessage":
                Discord.Send.Message(Data);
                break;
    
            case "SendDM":
                Discord.Send.Direct(Data);
                break;

            case "SendEmbed":
                Discord.Send.Embed(Data);
                break;

            default:
                break;
        }
    }
}

// ======================================================= //

const Discord = {

    Instance    : require('discord.js'),
    Bot         : undefined,

    Ready       : false,

    // ------------------------------------------------------- //

    Init() {

        this.Bot = new this.Instance.Client();
        this.Bot.login(Config.Token);

        // ------------------------------------------------------- //

        const __this = this;
        this.Bot.on('ready', () => {

            __this.Ready = true;
            console.log(`\n[.] (Discord) Bot Ready - ${__this.Bot.user.tag}.\n`);
    
            // tell the server that discord bot is ready
            ZMQ.Transmit('Event', {
                Event   : `Bot logged in as ${this.Bot.user.tag}`,
                Message : `Tracking ${Config.TrackAll ? "All" : Config.Listen.length.toString()} channels`
            });
        });
        
        this.Bot.on('message', Message => {
            __this.Filter(Message);
        });
    },

    // ------------------------------------------------------- //

    Filter(Message) {

        // don't forward the message
        // sent by the bot itself
        if(Message.author.id === this.Bot.user.id) {
            return;
        }

        // forward direct messages
        if(Message.member === null) {

            // if DM tracking is enabled
            if(Config.TrackDMs === true) {
                this.Receive(Message);
            }

            return;
        }

        // ------------------------------------------------------- //

        if(Config.TrackAll === true) {
            this.Receive(Message);
            return;
        }

        if(Config.Listen.find(function(element) { return element === Message.channel.id; })) {
            this.Receive(Message);
            return;
        }
    },

    // ------------------------------------------------------- //

    Receive(Message) {

        console.log(`[>] (Discord) ${Message.author.username} [#${Message.channel.name}] ${Message.content}`);
        
        // ------------------------------------------------------- //

        // create an outline object
        // to send as JSON string
        const Message_ = {
            
            User    : null,
            Member  : null,
            Server  : null,
            Content : Message.content
        };

        // store user details
        Message_.User = {

            ID  : Message.author.id,
            Name: Message.author.username,
            Tag : Message.author.discriminator
        };

        // if the message is not a direct message
        // store the details of server & member
        if(Message.member) {

            const s_Roles = [], s_Names = [];
            Message.member.roles.cache.array().forEach(element => {

                s_Roles.push(element.id);
                s_Names.push(element.name);
            });

            Message_.Member = {

                ID          : Message.member.id,
                Name        : Message.member.nickname === null ? Message.author.username : Message.member.nickname,
                Roles       : {
                    Names   : s_Names,
                    IDs     : s_Roles
                }
            };

            Message_.Server = {

                ID          : Message.guild.id,
                Name        : Message.guild.name,
                Channel     : {
                    ID      : Message.channel.id,
                    Name    : Message.channel.name
                }
            }
        }

        ZMQ.Transmit("DiscordMessage", Message_);
    },

    // ------------------------------------------------------- //

    Send: {

        // ------------------------------------------------------- //
        // Send a message

        Message(Data) {

            // the channel is cached?
            const Channel = Discord.Bot.channels.cache.array()
                .find(channel => channel.id === Data.Channel);
        
            if(Channel) Channel.send(Data.Message);
        },

        // ------------------------------------------------------- //
        // Direct message

        Direct(Data) {

            // the user is cached?
            const User = Discord.Bot.users.cache.get(Data.User);
            if(User) User.send(Data.Message);
        },

        // ------------------------------------------------------- //
        // Embed

        Embed(Data) {

            // the channel is cached?
            const Channel = Discord.Bot.channels.cache.array()
                    .find(Channel => Channel.id === Data.Channel);
        
            // Abort if the channel is not found
            if(Channel === undefined) {
                return;
            }
        
            const Embed = new Discord.Instance.MessageEmbed().setTimestamp();
        
            // ------------------------------------------------------- //
            // Set parameters //
        
            if(Data.Embed.Color)        Embed.setColor(Data.Embed.Color);
            if(Data.Embed.Title)        Embed.setTitle(Data.Embed.Title);
            if(Data.Embed.URL)          Embed.setURL(Data.Embed.URL);
            if(Data.Embed.Description)  Embed.setDescription(Data.Embed.Description);
            if(Data.Embed.Author.Name)  Embed.setAuthor(Data.Embed.Author.Name, Data.Embed.Author.Image, Data.Embed.Author.URL);
            if(Data.Embed.Thumbnail)    Embed.setThumbnail(Data.Embed.Thumbnail);
            if(Data.Embed.Footer.Text)  Embed.setFooter(Data.Embed.Footer.Text, Data.Embed.Footer.Image);
        
            // ------------------------------------------------------- //
            // Send the message //

            Channel.send(Embed);
        }
    }
}

// ======================================================= //

ZMQ.Init();
Discord.Init();

// ======================================================= //