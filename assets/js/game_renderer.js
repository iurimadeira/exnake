function gameRenderer() {

  // Colors
  let enemiesColor = '#A10EEC'; //Purple
  let gridColor = '#00E6FE'; //Cyan
  let foodColor = '#FD1999'; //Pink
  let uiColor = '#FFF'; //Yellow
  let playerColor = '#99FC20'; //Green
  let glowFactor = 20;

  // Map Size
  let mapWidth = 160;
  let mapHeight = 90;

  this.renderPlayerScore = function (name, score, ranking, line) {
    var canvas = document.getElementById("game");
    var context = canvas.getContext("2d");
    var paddedRanking = ("000" + ranking).slice(-3);
    var paddedName = ("          " + name.toUpperCase()).slice(-10);
    var paddedScore = ("000000" + score).slice(-6);
    context.shadowColor = uiColor;
    context.fillStyle = uiColor;
    context.font = "16px VCR_OSD_MONO";
    context.fillText(paddedRanking + " " + paddedName + " " + paddedScore, 30, 30 + (20 * line));
  }

  this.renderScore = function (frame, userId) {
    var that = this
    frame.players.forEach(function (player, index) {
      if (index < 10) {
        that.renderPlayerScore(player.name, player.score, index + 1, index);
      } else if (player.id == userId && index > 10) {
        that.renderPlayerScore(player.name, player.score, index + 1, 10);
      }
    });
  }

  this.renderHud = function (frame, userId) {
    this.renderScore(frame, userId);
  }

  this.squareXSize = function () {
    return window.innerWidth / mapWidth;
  }

  this.squareYSize = function () {
    return window.innerHeight / mapHeight;
  }

  this.renderSquare = function (x, y, color = "#000") {
    var canvas = document.getElementById("game");
    var context = canvas.getContext("2d");
    context.shadowColor = color;
    context.fillStyle = color;
    context.fillRect(x * this.squareXSize(), y * this.squareYSize(), this.squareXSize(), this.squareYSize());
  }

  this.renderFood = function (frame) {
    var that = this
    frame.food.forEach(function (food) {
      that.renderSquare(food.x, food.y, foodColor);
    });
  }

  this.renderPlayer = function (player, color) {
    var that = this
    player.body.forEach(function (square) {
      that.renderSquare(square.x, square.y, color);
    });
  }

  this.drawGridLine = function (context, direction, step) {
    let offset = 15;
    let spaceBetweenLines = 30;
    let position = (step * spaceBetweenLines) + offset;
    let result = false;

    context.strokeStyle = gridColor;
    context.shadowColor = gridColor;
    context.lineWidth = 1;

    if (direction == 'vertical' && position <= window.innerWidth) {
      context.beginPath();
      context.moveTo(position, 0);
      context.lineTo(position, window.innerHeight);
      context.stroke();
      result = true;
    } else if (direction == 'horizontal' && position <= window.innerHeight) {
      context.beginPath();
      context.moveTo(0, position);
      context.lineTo(window.innerWidth, position);
      context.stroke();
      result = true;
    }

    return result;
  }

  this.renderBackgroundGrid = function () {
    var canvas = document.getElementById("game");
    var context = canvas.getContext("2d");

    let verticalStep = 0;
    let horizontalStep = 0;
    while (true) {
      if (this.drawGridLine(context, 'vertical', verticalStep) == false) {
        break;
      }
      verticalStep = verticalStep + 1;
    }
    while (true) {
      if (this.drawGridLine(context, 'horizontal', horizontalStep) == false) {
        break;
      }
      horizontalStep = horizontalStep + 1;
    }
  }

  this.renderPlayers = function (frame, userId) {
    var that = this
    frame.players.forEach(function (player) {
      if (player.id == userId) {
        that.renderPlayer(player, playerColor);
      } else {
        that.renderPlayer(player, enemiesColor);
      }
    });
  }

  this.renderFrame = function (frame, userId) {
    var canvas = document.getElementById("game");
    var context = canvas.getContext("2d");
    context.canvas.width = window.innerWidth;
    context.canvas.height = window.innerHeight;
    context.clearRect(0, 0, canvas.width, canvas.height);
    context.shadowBlur = glowFactor;

    this.renderBackgroundGrid();
    this.renderHud(frame, userId);
    this.renderPlayers(frame, userId);
    this.renderFood(frame);
  }

}

module.exports = gameRenderer;