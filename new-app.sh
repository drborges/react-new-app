#!/bin/bash

git init

#
# Create default package.json file
#
echo '{
  "name": "lucy",
  "version": "1.0.0",
  "description": "",
  "author": "",
  "license": "MIT",
  "main": "app/index.jsx",
  "scripts": {
    "build": "./node_modules/webpack/bin/webpack.js --config webpack.config.js",
    "build:watch": "./node_modules/webpack/bin/webpack.js --config webpack.config.js --watch",
    "serve": "./node_modules/webpack-dev-server/bin/webpack-dev-server.js"
  }
}
' > package.json

#
# Install all required npm dependencies
#
brew install yarn || true
yarn add react react-dom
yarn add --dev babel-cli babel-preset-env babel-preset-react babel-polyfill babel-loader babel-core webpack webpack-dev-server babel-plugin-transform-decorators babel-plugin-transform-class-properties babel-plugin-transform-es2015-computed-properties

#
# Create .gitignore file
#
echo 'node_modules/
npm-debug.log
' > .gitignore

#
# Create .babelrc file
#
echo '{
  "presets": ["env", "react"],
  "plugins": [
    "transform-decorators",
    "transform-class-properties",
    "transform-es2015-computed-properties"
  ]
}
' > .babelrc

#
# Create webpack.config.js file
#
echo 'module.exports = {
  entry: ["babel-polyfill", "./app/index.jsx"],
  output: {
    filename: "bundle.js"
  },
  resolve: {
    extensions: [".js", ".jsx"]
  },
  module: {
    loaders: [
      { test: /\.js|\.jsx$/, exclude: /node_modules/, loader: "babel-loader" }
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
# Creates project structure
#
mkdir -p app/{components,clients}
mkdir -p spec/{components,clients}

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
' > app/clients/github.js

#
# Create dummy React component
#
echo 'import React from "react"
import github from "../clients/github"

const Repo = ({ name }) => (
  <li className="repo">{name}</li>
)

class GithubRepos extends React.Component {
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

export default GithubRepos
' > app/components/GithubRepos.jsx

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
' > app/index.jsx

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
