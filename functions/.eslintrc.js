module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  extends: [
    'eslint:recommended',
    'google',
  ],
  rules: {
    'eol-last': 0,
    'no-multiple-empty-lines': ['error', {'max': 1, 'maxEOF': 0}],
  },
};