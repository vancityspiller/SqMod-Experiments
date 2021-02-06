// ------------------------------------------------------- //

/*
*   Simple discord bot for SqMod using ZeroMQ.
*	(~) Spiller
*/

// ------------------------------------------------------- //
// Dependencies //

// npm install zeromq@5
// npm install discord.js

const   Discord = require('discord.js'),
		ZeroMQ  = require('zeromq'),
		Reader	= require('fs');

console.log('\n[.] Dependencies have been loaded.\n');

// ------------------------------------------------------- //
// Configuration //

console.log('[.] Loading configuration.\n');
const Config = JSON.parse(Reader.readFileSync('config.json'));

// ------------------------------------------------------- //
// Initing Workers //

console.log('[.] Initing workers.\n');

const   Bot         = new Discord.Client(),
        Socket      = ZeroMQ.socket("push"),
		Listener    = ZeroMQ.socket("pull");
		
// ------------------------------------------------------- //
// Bind ports //

console	.log('[>] Logging discord bot.');
Bot     .login(Config.Token);

console	.log('[>] Binding PUSH Socket to port ' + Config.Push);
Socket  .bindSync('tcp://127.0.0.1:3000');

console	.log('[>] Binding PULL Socket to port ' + Config.Pull);
Listener.connect('tcp://127.0.0.1:' + Config.Pull);

// ------------------------------------------------------- //
// Events //

Bot.on('ready', () => {
	console.log('\n[.] Discord bot is now online.');

	// let the server know
	// the the bot is listening

	var Info 	= {
		Event	: "Ready",
		BotName	: Bot.user.tag,
		DMs		: Config.TrackDMs,
		Count	: Config.TrackAll ? "All" : Config.Listen.length.toString()
	};

	Client.Push("Event", Info);
});

// ------------------------------------------------------- //

Bot.on('message', Message => {

	// don't forward the message 
	// sent by the bot itself

	if(Message.author.id === Bot.user.id) {
		return;
	}
	
	// forward direct messages 
	// if enabled

	if(Message.member === null) {

		if(Config.TrackDMs === true) {
			Client.Receive(Message);
		}

		return;
	}

	if(Config.TrackAll === true) {
		Client.Receive(Message);
		return;
	}
	
	if(Config.Listen.find(function(element) { return element === Message.channel.id; })) {
		Client.Receive(Message);
		return;	
	}
	
});

// ------------------------------------------------------- //

Bot.on('error', Error => {

	var Info 	= {
		Event	: "Error",
		Message	: Error.message,
		Name 	: Error.name
	}

	Client.Push("Event", Info);
	
});

// ------------------------------------------------------- //
// Functions //

var Client = {};

// ------------------------------------------------------- //

Client.Push = function(mode, message) {

	// Send the message as 
	// is if it's a string

	if(typeof(message) == "string")
	Socket.send([mode, message]);
	
	// Send it as JSON 
	// if its an object

	if(typeof(message) == "object")
	Socket.send([mode, JSON.stringify(message)]);
}

// ------------------------------------------------------- //

Client.Receive = function(Message) {

	console.log('[>] Receive - ' + Message.author.username +  ' - ' + Message.content);

	// create an outline object
	// to send as JSON string

	var sMessage = {
		User	: null,
		Member	: null,
		Server	: null,
		Content	: Message.content
	};

	// store user details 

	sMessage.User = {

		ID:		Message.author.id,
		Name:	Message.author.username,
		Tag:	Message.author.discriminator
	};

	// if the message is not a
	// direct message

	if(Message.member != null) {

		// arrays for role and role names

		var s_Roles = [], s_Names = [];
		Message.member.roles.cache.array().forEach(element => {
			s_Roles.push(element.id);
			s_Names.push(element.name);
		});

		// store member details

		sMessage.Member = {
			ID			: Message.member.id,
			Name		: Message.member.nickname,
			Roles		: {
				Names	: s_Names,
				IDs		: s_Roles
			}
		};

		sMessage.Server = {
			ID			: Message.guild.id,
			Name		: Message.guild.name,
			Channel		: {
				ID		: Message.channel.id,
				Name	: Message.channel.name
			}
		}
	}
	
	Client.Push("Message", sMessage);
}

// ------------------------------------------------------- //

Client.Pull = function(Message) {
	const Data = JSON.parse(Message);

	switch(Data.Function)
	{
		case "Send":
			Client.Send(Data);
			break;

		case "Embed":
			Client.SendEmbed(Data);
			break;
	}
}

Listener.on('message', function(Message) {
	Client.Pull(Message);
});

// ------------------------------------------------------- //

Client.Send = function(Data) {
	// Find the channel
	const Channel = Bot.channels.cache.array().find(channel => channel.id === Data.Channel);
	
	if(Channel != undefined) {
		Channel.send(Data.Message);
	}
}

// ------------------------------------------------------- //

Client.SendEmbed = function(Data) {
	// Find the channel
	const Channel = Bot.channels.cache.array().find(channel => channel.id === Data.Channel);

	// Abort if the channel is not found
	if(Channel === undefined) {
		return;
	}
	
	// Create an embed
	var Embed = new Discord.MessageEmbed()
	.setTimestamp();

	// ------------------------------------------------------- //
	// Set parameters //

	if(Data.Embed.Color != null) 		// Color 
	Embed.setColor(Data.Embed.Color);

	if(Data.Embed.Title != null) 		// Title 
	Embed.setTitle(Data.Embed.Title);

	if(Data.Embed.URL != null) 			// URL
	Embed.setURL(Data.Embed.URL);

	if(Data.Embed.Description != null) 	// Description
	Embed.setDescription(Data.Embed.Description);

	if(Data.Embed.Author.Name != null) 	// Author
	Embed.setAuthor(Data.Embed.Author.Name, Data.Embed.Author.Image, Data.Embed.Author.URL);
	
	if(Data.Embed.Thumbnail != null) 	// Thumbnail
	Embed.setThumbnail(Data.Embed.Thumbnail);

	if(Data.Embed.Footer.Text != null) 	// Footer
	Embed.setFooter(Data.Embed.Footer.Text, Data.Embed.Footer.Image);

	// ------------------------------------------------------- //
	// Send the message //
	Channel.send(Embed);
}