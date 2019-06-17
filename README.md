# JARVIS

This is a telegram bot meant to be a fun project I set as challenge to myself in order to learn new stuff everyday.
I decided to put it out there for those interested in learning how to get a hello world bot up and running in no time.

# REQUIREMENTS
You need to create you bot manually on the telegram app itself by starting a conversation with the **@BotFather** (just type it on the global search)
1. Create you bot following the instructions from the **@Botfather**
1. Save your bot's api key
1. Have very basic understanding of web programming

# Steps
1. Create a server using any backend framework of your choice. (I made this on ruby on rails as part of my personal challenge)
1. Setup one endpoint to connect to your bot through a webhook
1. Refer to the original telegram's BOT API documentation to understand the request's json and available methods
1. Do the logic you want (see code on `main_controller.rb` to have an idea)
1. Host your server wherever you want (heroku is a good choice)
1. After having your server on production connect the bot's webhook to the endpoint of which it will send requests to by running this command: `curl -F "url=https://yourdomain/enpoint-name"  https://api.telegram.org/bot<your_api_token>/setWebhook`
1. Voilà you should have a responsive bot

# Communication
When a user sends a message to the bot it passes through telegram's servers and when a webhook is pointing
to an endpoint the server is going to automatically send a request with the `updates` to your own server where you can handle 
everything the way you want and send back a response to the telegram's server which will forward it to the bot so it 
can deliver the response to the original user

# What does this bot do?
I call it a Botler(Butler bot) as all it does is things that are interesting to my personal life like fetch the price of the dollar
and bitcoin in my currency, search for songs on spotify and responding my questions with YES or NO sending appropriate gifs.

More features will be added as I see fit to my needs or general fun   

# Ruby On Rails
* Ruby version 2.6.1
* Rails version 5.2.3
