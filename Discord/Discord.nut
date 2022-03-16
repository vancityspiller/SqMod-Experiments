ZMQ <-
{
    Config  = JSON.ParseFile("config.json"),
    Context = SqZMQ.Context(),
    Sockets = { Listener = null, Sender = null },

    // ------------------------------------------------------- //

    function Init()
    {
        Sockets.Listener    = Context.Socket(SqZmq.PULL);
        Sockets.Sender      = Context.Socket(SqZmq.PUSH);

        Sockets.Listener    .Connect("tcp://127.0.0.1:{}", Config.Push);
        Sockets.Sender      .Connect("tcp://127.0.0.1:{}", Config.Pull);

        SqLog.Scs("[ZMQ] PUSH {}, PULL {}.", Config.Pull, Config.Push);

        Sockets.Listener.OnData(function(Received, IsMulti)
        {
            if(!IsMulti) return;
            local Data = JSON.Parse(Received[1]);

            if(Received[0] == "Event") printf("[ZMQ] [EVENT] {} - {}.", Data.Event, Data.Message);
            else if(Received[0] == "DiscordMessage") Discord.OnMessage(Data);
        });
    }

    // ------------------------------------------------------- //

    function Push(Data)
    {
        Sockets.Sender.SendString(JSON.Encode(Data));
    }
}

// ======================================================= //

Discord <-
{
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

    function CreateEmbed()
    {
        local Embed =
        {
            Color       = null,
            Title       = null,
            URL         = null,
            Author      = {
                Name    = null,
                Image   = null,
                URL     = null
            },
            Description = null,
            Thumbnail   = null,
            Footer      = {
                Text    = null,
                Image   = null
            }
        };

        return Embed;
    }

    // ------------------------------------------------------- //

    function SendMessage(Channel, Message)
    {
        ZMQ.Push(JSON.Encode({

            Type        = "SendMessage",
            Message     = Message,
            Channel     = Channel
        }));
    }

    // ------------------------------------------------------- //

    function SendDM(UserID, Message)
    {
        ZMQ.Push(JSON.Encode({

            Type        = "SendDM",
            Message     = Message,
            User        = UserID
        }));
    }

    // ------------------------------------------------------- //

    function SendEmbed(Channel, Embed)
    {
        ZMQ.Push(JSON.Encode({

            Type        = "SendEmbed",
            Embed       = Embed,
            Channel     = Channel
        }));
    }
}

// ======================================================= //

ZMQ.Init();
SqRoutine(this, SqZMQ.Process, 100);