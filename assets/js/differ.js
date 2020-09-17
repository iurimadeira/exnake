var _ = require('./lodash');

function differ() {
  this.decode = function (last, delta) {
    var acc =
      _.reduce(delta, function (acc, operation) {
        switch (Object.keys(operation)[0]) {
          case "eq":
            var addition = last.substring(acc.location, acc.location + operation.eq);
            acc.location += operation.eq;
            acc.decoded = acc.decoded.concat(addition);
            break;
          case "ins":
            acc.decoded = acc.decoded.concat(operation.ins);
            break;
          case "del":
            acc.location += operation.del;
            break;
        }

        return acc;
      }, { location: 0, decoded: "" });

    return acc.decoded;
  }
}

module.exports = differ;