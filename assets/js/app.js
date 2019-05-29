// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
import socket from "./socket"

// -- Chat Implementation -- //

// 'chat_room:1/1' follows the logic: BOOKCLUB_ID/CHAPTER_NUMBER.
// So here, we're connecting to the Bookclub ID 1 and talking at the
// chapter 1. You can say 'chat_room:1233/12' to connect to the
// Bookclub ID 1233 and talk at the chapter 12.
var channel = socket.channel('chat_room:1/2', {});

// Here's the listening part.
channel.on('shout', function (payload) {
  var timestamp = payload.inserted_at;
  var name = payload.user_display_name;
  var msg = payload.text;

  var li = document.createElement("li");
  var content = timestamp + ' - <b>' + name + '</b>: ' + msg;

  li.innerHTML = content;
  ul.appendChild(li);
});

// Proceed with connecting the channel.
channel.join();

// Here's the UI setup.
// 1. Message list.
var ul = document.getElementById('chatbox');
// 2. The message text.
var text = document.getElementById('msg_text');

// Listening for user's inputs.
text.addEventListener('keypress', function (event) {
  if (event.keyCode == 13 && text.value.length > 0) {

    // Replacing newlines from the begining and end of the message.
    var msg = text.value;
    msg = msg.replace(/^\s+|\s+$/g, '');

    var msg_action = msg.split(' ');

    if (msg_action[0] == '/load') {

      channel.push('load', {
        last_message_timestamp: msg_action[1]
      });

    } else {

      // Here is how a message is sent.
      channel.push('shout', {
        text: msg
      });

    }

    // Just reseting the UI message typing box.
    text.value = '';
  }
});

