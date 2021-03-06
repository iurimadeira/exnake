// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import { Socket } from "phoenix"

const Differ = require('./differ');
var differ = new Differ();

const GameRenderer = require('./game_renderer');
var gameRenderer = new GameRenderer();

const token = document.head.querySelector("[name=token]").content
let socket = new Socket("/socket", { params: { token: token } })

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

socket.connect()

// Now that you are connected, you can join channels with a topic:
let channelUserId = null;
let gameChannel = socket.channel("game:play", { "name": prompt("Please, enter your name:") })

gameChannel.join()
  .receive("ok", resp => {
    console.log("Joined successfully", resp);
    channelUserId = resp.id;
  })
  .receive("error", resp => { console.log("Unable to join", resp) })

document.addEventListener("keydown", event => {
  switch (event.which) {
    case 38:
      gameChannel.push("change_direction", { direction: "up" })
      break;
    case 40:
      gameChannel.push("change_direction", { direction: "down" })
      break;
    case 37:
      gameChannel.push("change_direction", { direction: "left" })
      break;
    case 39:
      gameChannel.push("change_direction", { direction: "right" })
      break;
  }

})

var lastFrame;
var count;

gameChannel.on("starting_state", payload => {
  count = payload.count;
  lastFrame = payload.frame;
  gameRenderer.renderFrame(payload.frame, channelUserId);
  console.log(`starting_state count: ${payload.count}`);
})

gameChannel.on("new_frame", payload => {
  if (lastFrame != undefined && payload.count == count + 1) {
    var frameString = differ.decode(JSON.stringify(lastFrame), payload.delta);
    var frame = JSON.parse(frameString)
    count = payload.count;
    lastFrame = frame;
    gameRenderer.renderFrame(frame, channelUserId);
    console.log(`new_frame count: ${payload.count}`);
  } else {
    console.log(`Wrong count. Skipping... Previous: ${count} | New: ${payload.count}`);
  }
})

export default socket
