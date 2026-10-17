function fn() {
  return {
    round2: function (n) {
      return Math.round(n * 100) / 100;
    },
    alias: function (prefix) {
      return prefix + '-' +
        Math.random().toString(36).substring(2, 10);
    }
  };
}
