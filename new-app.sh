#!/bin/bash

git init

#
# Creates project structure
#
mkdir -p lib/{components,api}
mkdir -p test/{components,api}

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
# Create .nvmrc with the latest node version
#
echo 'v7.6.0' > .nvmrc

nvm use

#
# Install all required npm dependencies
#
brew install yarn || true

yarn add react react-dom webpack react-dom babel-plugin-react-css-modules
yarn add --dev webpack-dev-server
yarn add --dev babel-cli babel-polyfill babel-loader babel-core
yarn add --dev babel-preset-env babel-preset-react
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
# Create a Github API client
#
echo 'const Api = {
  user(username) {
    return {
      async repositories() {
        const response = await fetch(`https://api.github.com/users/${username}/repos`)
        const repos = await response.json()
        console.log(repos)
        return repos
      }
    }
  }
}

export default Api
' > lib/api/github.js

#
# Create dummy React component
#
echo 'import React from "react"
import github from "../api/github"

export const Repo = ({ name }) => (
  <li className="repo">{name}</li>
)

export default class GithubRepos extends React.Component {
  state = { repos: [] }

  componentDidMount() {
    (async () => {
      const repos = await github.user(this.props.username).repositories()
      this.setState({ repos })
    })()
  }

  render() {
    const repos = this.state.repos.map((repo, i) =>
      <Repo key={i} name={repo.name} />
    )

    return (
      <ul className="github-repos">
        {repos}
      </ul>
    )
  }
}
' > lib/components/GithubRepos.jsx

#
# Create React code entry point
#
echo 'import React from "react"
import ReactDOM from "react-dom"
import GithubRepos from "./components/GithubRepos"

ReactDOM.render(
  <GithubRepos username="drborges" />,
  document.getElementById("app")
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
import { shallow, render } from "enzyme"
import { Repo } from "../../lib/components/GithubRepos"

describe("A suite", () => {
  it("contains spec with an expectation", () => {
    const wrapper = shallow(<Repo name="reactjs" />)
    expect(wrapper.find("li")).to.have.className("repo")
    expect(wrapper).to.contain("reactjs")
  })
})
' > test/components/Repo.spec.js

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
