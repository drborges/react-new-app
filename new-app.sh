#!/bin/bash

git init

#
# Creates project structure
#
mkdir -p lib/components/Card
mkdir -p test/components

#
# Create default package.json file
#
echo '{
  "name": "my-app",
  "version": "1.0.0",
  "description": "",
  "author": "",
  "license": "MIT",
  "main": "lib/index.jsx",
  "scripts": {
    "build": "./node_modules/webpack/bin/webpack.js --config webpack.config.js",
    "build:watch": "./node_modules/webpack/bin/webpack.js --config webpack.config.js --watch",
    "serve": "./node_modules/webpack-dev-server/bin/webpack-dev-server.js",
    "test": "mocha",
    "test:watch": "mocha -w"
  }
}
' > package.json

#
# Install all required npm dependencies
#
brew install yarn || true

yarn add react react-dom webpack react-dom babel-plugin-react-css-modules
yarn add --dev webpack-dev-server
yarn add --dev babel-cli babel-polyfill babel-loader babel-core
yarn add --dev babel-preset-env babel-preset-react
yarn add --dev cssnext postcss-import postcss-loader postcss-sass sugarss
yarn add --dev style-loader css-loader sass-loader node-sass postcss-scss extract-text-webpack-plugin
yarn add --dev babel-plugin-transform-decorators-legacy babel-plugin-transform-class-properties babel-plugin-transform-es2015-computed-properties babel-plugin-transform-object-rest-spread
yarn add --dev mocha chai sinon jsdom enzyme react-addons-test-utils sinon-chai chai-enzyme

#
# Create .gitignore file
#
echo 'node_modules/
npm-debug.log
yarn-error.log
bundle.js
' > .gitignore

#
# Create .babelrc file
#
echo '{
  "presets": ["env", "react"],
  "plugins": [
    "transform-class-properties",
    "transform-decorators-legacy",
    "transform-object-rest-spread",
    "transform-es2015-computed-properties",
    [
      "react-css-modules",
      {
        "generateScopedName": "[path]___[name]__[local]___[hash:base64:5]",
        "filetypes": {
          ".scss": "postcss-scss"
        }
      }
    ],
  ]
}
' > .babelrc

#
# Create webpack.config.js file
#
echo '/* eslint-disable filenames/match-regex, import/no-commonjs */
module.exports = {
  devtool: "eval-source-map",
  entry: [
    "babel-polyfill",
  ],
  output: {
    filename: "bundle.js",
  },
  resolve: {
    extensions: [".js", ".jsx", ".scss", ".css"],
  },
  module: {
    rules: [
      {
        test: /\.(s)?css$/,
        exclude: [/node_modules/],
        use: [
          "style-loader",
          "css-loader?importLoader=1&modules&localIdentName=[path]___[name]__[local]___[hash:base64:5]",
          "postcss-loader",
          "sass-loader",
        ],
      },
      {
        test: /\.js(x)?$/,
        exclude: /node_modules/,
        use: "babel-loader",
      },
    ]
  }
}
' > webpack.config.js

#
# Create .editorconfig file
#
echo '# top-most EditorConfig file
root = true

# Unix-style newlines with a newline ending every file
[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 2
insert_final_newline = true
trim_trailing_whitespace = true

[*.md]
trim_trailing_whitespace = false
' > .editorconfig

#
# Create some component samples
#
echo 'import React from "react"

import "./index.scss"

export const Card = ({ children, title, greedy }) => (
  <section styleName={`card ${greedy ? "greedy" : ""}`}>
    <section styleName="header">
      <h1>{title}</h1>
    </section>
    <section styleName="body">
      {children}
    </section>
  </section>
)

Card.defaultProps = {
  greedy: false,
}

export default Card
' > lib/components/Card/index.jsx

echo '.card {
  display: flex;
  flex-direction: column;

  margin: 5px;
  border-radius: 3px;
  box-shadow: 0 0 4px 0 #ddd;
  border: thin solid #ddd;

  background-color: #fff;

  &.greedy {
    flex-basis: 100%;
  }

  .header {
    margin: 0;
    padding: 10px;

    h1 {
      margin: 0;
    }
  }

  .header:hover {
    cursor: grab;
  }

  .body {
    padding: 10px;
  }
}
' > lib/components/Card/index.scss

echo 'import React from "react"

import "./index.scss"

export const Dashboard = ({ children }) => (
  <section styleName="dashboard">
    {children}
  </section>
)

export default Dashboard
' > lib/components/Dashboard/index.jsx

echo '.dashboard {
  display: flex;
  flex-wrap: wrap;
  font-family: "Open Sans",arial,sans-serif;

  & > * {
    flex-grow: 1;
  }
}
' > lib/components/Dashboard/index.scss

#
# Create React code entry point
#
echo 'import React from "react"
import ReactDOM from "react-dom"

import { Dashboard, Card } from "./components"

const dashboard =
  <Dashboard>
    <Card title="Daily Appointments">
      <div>LOL 1</div>
    </Card>
    <Card title="Hourly Appointments">
      <div>LOL 2</div>
    </Card>
    <Card title="Appointments Per Source" greedy>
      <div>LOL 3</div>
    </Card>
    <Card title="Net Sales">
      <div>LOL 4</div>
    </Card>
    <Card title="Net Volume">
      <div>LOL 5</div>
      <div>LOL 5</div>
      <div>LOL 5</div>
    </Card>
  </Dashboard>

ReactDOM.render(
  dashboard,
  document.getElementById("app"),
)
' > lib/index.jsx

#
# Create the app's entry point index.html
#
echo '<html>
  <body>
    <section id="app"></section>
    <script src="bundle.js"></script>
  </body>
</html>
' > index.html

#
# Create spec.helper.js
#
echo '
require("babel-register")()
var JSDOM = require("jsdom").JSDOM
var dom = new JSDOM("", {
  url: "https://example.org/",
  referrer: "https://example.com/",
  contentType: "text/html",
  userAgent: "Mellblomenator/9000",
  includeNodeLocations: true,
})

var chai = require("chai")
var sinonChai = require("sinon-chai")
var chaiEnzyme = require("chai-enzyme")
var exposedProperties = ["window", "navigator", "document"]

chai.use(chaiEnzyme())
chai.use(sinonChai)

global.window = dom.window
global.document = dom.window.document

documentRef = document
' > test/spec.helper.js

#
# Create spec example file
#
echo '
import React from "react"
import { expect } from "chai"
import { mount, render } from "enzyme"
import { Card } from "../../lib/components"

describe("A suite", () => {
  it("contains spec with an expectation", () => {
    const wrapper = mount(<Card title="My Card" greedy />)
    expect(wrapper.find("h1")).to.have.text("My Card")
  })
})
' > test/components/Card.spec.js

#
# Create mocha.opts file
#
echo '
--require babel-polyfill
--require test/spec.helper.js
--reporter spec
--recursive
--ui bdd
--growl
' > test/mocha.opts

#
# Configure postcss
#
echo 'module.exports = {
  syntax: "postcss-scss",
  plugins: {
    "cssnext": {},
    "autoprefixer": {},
    "cssnano": {}
  }
}
' > postcss.config.js

#
# Configures React Storybook inheriting the root webpack config
#
npm i -g @storybook/cli@3.0.0-alpha.0
getstorybook

echo '
module.exports = require("../webpack.config.js")
' > .storybook/webpack.config.js

rm stories/index.js

echo 'import React from "react"
import { storiesOf } from "@storybook/react"
import { Dashboard, Card } from "../lib/components"

storiesOf("Dashboard", module)
  .add("Empty Dashboard", () =>
    <Dashboard>
      <Card title="Daily Appointments">
        <div>LOL 1</div>
      </Card>
      <Card title="Hourly Appointments">
        <div>LOL 2</div>
      </Card>
      <Card title="Appointments Per Source" greedy>
        <div>LOL 3</div>
      </Card>
      <Card title="Net Sales">
        <div>LOL 4</div>
      </Card>
      <Card title="Net Volume">
        <div>LOL 5</div>
        <div>LOL 5</div>
        <div>LOL 5</div>
      </Card>
    </Dashboard>
  )
' > stories/index.js