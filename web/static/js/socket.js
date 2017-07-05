// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"

const token = document.head.querySelector("[name=token]").content
let socket = new Socket("/socket", {params: {token: token}})

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
let gameChannel = socket.channel("game:play", {"name": prompt("Please, enter your name:")})
gameChannel.join()
  .receive("ok", resp => {
    console.log("Joined successfully", resp);
    channelUserId = resp.id;
  })
  .receive("error", resp => { console.log("Unable to join", resp) })

document.addEventListener("keydown", event => {
  switch (event.which) {
    case 38:
      gameChannel.push("change_direction", {direction: "up"})
      break;
    case 40:
      gameChannel.push("change_direction", {direction: "down"})
      break;
    case 37:
      gameChannel.push("change_direction", {direction: "left"})
      break;
    case 39:
      gameChannel.push("change_direction", {direction: "right"})
      break;
  }

})

gameChannel.on("new_frame", payload => {
    renderFrame(payload.frame, channelUserId);
})

function renderFrame(frame, userId) {
  var canvas = document.getElementById("game");
  var context = canvas.getContext("2d");
  context.clearRect(0, 0, canvas.width, canvas.height);

  renderPlayers(frame, userId);
  renderFood(frame);
  renderHud(frame, userId);
  renderLeaderboards(frame);
}

function renderLeaderboards(frame) {
  var sorted = frame.players.sort(function(a, b){
    return b.score - a.score;
  });

  var leaderboardsHTML = "Leaderboards<br><br>";
  sorted.forEach (function(player){
    leaderboardsHTML += player.name + " - " + player.score + "<br>";
  })
  document.getElementById("leaderboards").innerHTML = leaderboardsHTML;
}

function renderPlayers(frame, userId) {
  frame.players.forEach (function(player) {
    if (player.id == userId) {
      renderPlayer(player, "#ff0000");
    } else {
      renderPlayer(player);
    }
  });
}

function renderHud(frame, userId) {
  frame.players.forEach (function(player) {
    if (player.id == userId) {
      document.getElementById("score").innerHTML = "Score: " + player.score;
    }
  });
}

function renderFood(frame) {
  frame.food.forEach(function(food) {
    renderSquare(food.x, food.y);
  });
}

function renderPlayer(player, color) {
  player.body.forEach (function(square) {
    renderSquare(square.x, square.y, color);
  });
}

function renderSquare(x, y, color = "#000") {
  var canvas = document.getElementById("game");
  var context = canvas.getContext("2d");
  context.fillStyle = color;
  context.fillRect(x * 10, y * 10, 10, 10);
}

export default socket
