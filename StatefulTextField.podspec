Pod::Spec.new do |spec|
  spec.name = "StatefulTextField"
  spec.version = "1.0.0"
  spec.summary = "A UITextField subclass with built in live validation and formatting."
  spec.homepage = "https://jimjoyce.github.io"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Jim Joyce" => 'jjoyce1@me.com' }
  # spec.social_media_url = "http://twitter.com/thoughtbot"

  spec.platform = :ios, "11.0"
  spec.requires_arc = true
  spec.source = { git: "git@github.com:JimJoyce/StatefulTextField.git", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "stateful-textfield/**/*.{h,swift}"
  spec.swift_version = "5.2"

end