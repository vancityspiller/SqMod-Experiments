// ------------------------------------------------------- //

/*
*   Simple discord bot for SqMod using ZeroMQ.
*	(~) Spiller
*/

// ------------------------------------------------------- //

SqCore.On().ScriptLoaded.Connect(this, function ()
{
	// Make a global context 
	Context <- SqZMQ.Context();

	// Init an instance
	Discord <- CDiscord();

	// Process every 100ms
	SqRoutine(this, SqZMQ.Process, 100);
});

// ------------------------------------------------------- //

class CDiscord
{
	Config 	= null;
	Sockets = null;

	// ------------------------------------------------------- //

	constructor()
	{
		// ------------------------------------------------------- //
		// Instances //

		this.Sockets = 
		{
			Listener  	= Context.Socket(SqZmq.PULL),
			Socket		= Context.Socket(SqZmq.PUSH)
		};

		// ------------------------------------------------------- //
		// Load Config //

		Config = JSON.ParseFile("config.json");

		// ------------------------------------------------------- //
		// Bind ZMQ to ports //

		this.Sockets.Listener	.Connect (format("tcp://127.0.0.1:%s", this.Config.Push));
		this.Sockets.Socket		.Bind	 (format("tcp://127.0.0.1:%s", this.Config.Pull));
		
		SqLog.Scs(format("ZeroMQ Connected @ PUSH %s, PULL %s", this.Config.Pull, this.Config.Push));

		// ------------------------------------------------------- //

		Sockets.Listener.OnData(this.OnData);
	}

	// ------------------------------------------------------- //

	function OnData(Data, IsMulti)
	{
		// I'm not really using any 
		// single stringed data 

		if(!IsMulti) return 1;
		local Info = JSON.Parse(Data[1]);
		
		// Determine the type of data
		switch(Data[0])
		{
			case "Event":
			{
				Discord.OnEvent(Info);
				break;
			}

			case "Message":
			{
				Discord.OnMessage(Info);
				break;
			}
			
		}		
	}

	// ------------------------------------------------------- //

	function OnEvent(Info)
	{
		switch(Info.Event)
		{
			case "Ready":
			{
				SqLog.Inf(format("Discord logged in as %s.", Info.BotName));
				SqLog.Inf(format("Tracking Direct Messages: %s.", Info.DMs ? "true" : "false"));
				SqLog.Inf(format("Tracking %s channels.", Info.Count));
			}

			case "Error":
			{
				SqLog.Dbg(format("Discord Error: %s - %s", Info.Name, Info.Message));
				break;
			}
			
		}
	}

	// ------------------------------------------------------- //

	function OnMessage(Info)
	{
		SqLog.Inf("Message Received: ");
		foreach(Key, Value in Info)
		{
			SqLog.Inf(Key + ": " + Value);

			if(typeof(Value) == "table")
			{
				foreach(Key_, Value_ in Value)
				SqLog.Inf("   " + Key_ + ": " + Value_);
			}
		}
		
	}

	// ------------------------------------------------------- //

	function SendMessage(Channel, Message)
	{
		local Data = 
		{
			Function 	= "Send",
			Message		= Message,
			Channel		= Channel
		};

		this.Sockets.Socket.SendString(JSON.Stringify(Data));
		return 1;
	}

	// ------------------------------------------------------- //

	function CreateEmbed()
	{
		// this function returns an
		// outline table, NOT an object

		local Table = 
		{
			Color 		= null,
			Title		= null,
			URL			= null,
			Author		= {
				Name	= null,
				Image	= null,
				URL		= null
			},
			Description = null,
			Thumbnail	= null,
			Footer 		= {
				Text	= null,
				Image 	= null
			}
		};

		return Table;
	}

	// ------------------------------------------------------- //

	function SendEmbed(Channel, EmbedData)
	{
		local Data = 
		{
			Function 	= "Embed",
			Channel 	= Channel,
			Embed		= EmbedData
		};

		this.Sockets.Socket.SendString(JSON.Stringify(Data));
		return 1;
	}

	// ------------------------------------------------------- //
}