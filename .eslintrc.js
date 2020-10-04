module.exports = {
  env: {
    commonjs: true,
    es2021: true,
    node: true,
  },
  extends: ["airbnb-base", "prettier"],
  plugins: ["prettier"],
  parserOptions: {
    ecmaVersion: 12,
  },
  rules: {
    "no-console": "off",
    "no-shadow": "off",
    "no-unused-vars": ["error", { argsIgnorePattern: "^_" }],
  },
};
